import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/inventory/domain/batch_models.dart';
import 'package:uuid/uuid.dart';

// #region agent log
void _agentLog({
  required String hypothesisId,
  required String location,
  required String message,
  Map<String, Object?> data = const {},
  String runId = 'impl1',
}) {
  try {
    final payload = jsonEncode({
      'sessionId': 'd35474',
      'runId': runId,
      'hypothesisId': hypothesisId,
      'location': location,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    File(r'E:\work\github\finflow\debug-d35474.log')
        .writeAsStringSync('$payload\n', mode: FileMode.append);
  } catch (_) {}
}
// #endregion

/// One FEFO allocation slice when consuming across lots.
class BatchAllocation {
  final String batchUuid;
  final double quantity;
  final double effectiveCost;

  const BatchAllocation({
    required this.batchUuid,
    required this.quantity,
    required this.effectiveCost,
  });
}

class InventoryRepository {
  final AppDatabase _db;

  InventoryRepository(this._db);

  // ==========================================
  // Product Categories
  // ==========================================

  Stream<List<ProductCategory>> watchAllCategories() {
    return (_db.select(_db.productCategories)
          ..where((c) => c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  Future<String> createCategory(ProductCategoriesCompanion category) async {
    final uuid = category.uuid.present ? category.uuid.value : const Uuid().v4();
    await _db.into(_db.productCategories).insert(
          category.copyWith(
            uuid: Value(uuid),
            isNotSynced: const Value(true),
          ),
        );
    return uuid;
  }

  Future<bool> updateCategory(ProductCategory category) {
    return _db
        .update(_db.productCategories)
        .replace(category.copyWith(isNotSynced: true));
  }

  Future<int> deleteCategory(String uuid) {
    return (_db.update(_db.productCategories)
          ..where((c) => c.uuid.equals(uuid)))
        .write(
      ProductCategoriesCompanion(
        isDeleted: const Value(true),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==========================================
  // Products
  // ==========================================

  Stream<List<Product>> watchAllProducts() {
    return (_db.select(_db.products)
          ..where((p) => p.isDeleted.equals(false))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }

  Stream<List<Product>> watchLowStockProducts() {
    return (_db.select(_db.products)
          ..where((p) =>
              p.isDeleted.equals(false) &
              p.stockQuantity.isSmallerThan(p.minStockAlert)))
        .watch();
  }

  Future<Product?> getProduct(String uuid) {
    return (_db.select(_db.products)
          ..where((p) => p.uuid.equals(uuid) & p.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<ProductCategory?> getCategory(String uuid) {
    return (_db.select(_db.productCategories)
          ..where((c) => c.uuid.equals(uuid) & c.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<String> createProduct(ProductsCompanion product) async {
    final uuid = product.uuid.present ? product.uuid.value : const Uuid().v4();
    await _db.into(_db.products).insert(
          product.copyWith(
            uuid: Value(uuid),
            isNotSynced: const Value(true),
          ),
        );
    return uuid;
  }

  /// Creates a product and, when [openingQuantity] &gt; 0, an OPENING manual lot.
  Future<String> createProductWithOpeningStock({
    required ProductsCompanion product,
    double openingQuantity = 0,
  }) async {
    return _db.transaction(() async {
      final uuid = await createProduct(
        product.copyWith(stockQuantity: const Value(0.0)),
      );
      if (openingQuantity > 0) {
        final cost = product.purchasePrice.present
            ? product.purchasePrice.value
            : 0.0;
        await receiveIntoBatch(
          productUuid: uuid,
          quantity: openingQuantity,
          effectiveCost: cost,
          isManual: true,
          manualType: ManualBatchType.opening,
          batchNumber: 'OPENING',
        );
      }
      return uuid;
    });
  }

  Future<bool> updateProduct(Product product) {
    return _db
        .update(_db.products)
        .replace(product.copyWith(isNotSynced: true));
  }

  Future<int> deleteProduct(String uuid) {
    return (_db.update(_db.products)..where((p) => p.uuid.equals(uuid))).write(
      ProductsCompanion(
        isDeleted: const Value(true),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==========================================
  // Product Batches (lots / FEFO)
  // ==========================================

  Stream<List<ProductBatche>> watchBatchesForProduct(String productUuid) {
    return (_db.select(_db.productBatches)
          ..where((b) =>
              b.productUuid.equals(productUuid) & b.isDeleted.equals(false))
          ..orderBy([
            (b) => OrderingTerm.asc(b.expiryDate),
            (b) => OrderingTerm.asc(b.createdAt),
          ]))
        .watch();
  }

  Stream<List<ProductBatche>> watchExpiringSoonBatches({int daysThreshold = 60}) {
    final thresholdDate = DateTime.now().add(Duration(days: daysThreshold));
    return (_db.select(_db.productBatches)
          ..where((b) =>
              b.isDeleted.equals(false) &
              b.expiryDate.isSmallerThanValue(thresholdDate) &
              b.totalQuantity.isBiggerThan(b.consumedQuantity))
          ..orderBy([(b) => OrderingTerm.asc(b.expiryDate)]))
        .watch();
  }

  Future<ProductBatche?> getBatch(String uuid) {
    return (_db.select(_db.productBatches)
          ..where((b) => b.uuid.equals(uuid) & b.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Recomputes [Product.stockQuantity] from sum of lot remainings.
  Future<void> refreshProductStockCache(String productUuid) async {
    final row = await _db.customSelect(
      '''
      SELECT COALESCE(SUM(total_quantity - consumed_quantity), 0) AS rem
      FROM product_batches
      WHERE product_uuid = ? AND is_deleted = 0
      ''',
      variables: [Variable.withString(productUuid)],
    ).getSingle();
    final rem = row.read<double>('rem');
    final cached = rem < 0 ? 0.0 : rem;
    await (_db.update(_db.products)..where((p) => p.uuid.equals(productUuid)))
        .write(
      ProductsCompanion(
        stockQuantity: Value(cached),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    // #region agent log
    _agentLog(
      hypothesisId: 'H3',
      location: 'inventory_repository.dart:refreshProductStockCache',
      message: 'product stock cache synced',
      data: {'productUuid': productUuid, 'stockQuantity': cached},
    );
    // #endregion
  }

  Future<String> createBatch(ProductBatchesCompanion batch) async {
    final uuid = batch.uuid.present ? batch.uuid.value : const Uuid().v4();

    String batchNum = batch.batchNumber.present ? batch.batchNumber.value : '';
    if (batchNum.trim().isEmpty) {
      if (batch.expiryDate.present && batch.expiryDate.value != null) {
        final exp = batch.expiryDate.value!;
        batchNum =
            'EXP-${exp.year}-${exp.month.toString().padLeft(2, '0')}-${exp.day.toString().padLeft(2, '0')}';
      } else {
        batchNum = 'LOT-${DateTime.now().millisecondsSinceEpoch}';
      }
    }

    await _db.into(_db.productBatches).insert(
          batch.copyWith(
            uuid: Value(uuid),
            batchNumber: Value(batchNum),
            isNotSynced: const Value(true),
          ),
        );

    final productUuid = batch.productUuid.present ? batch.productUuid.value : null;
    if (productUuid != null) {
      await refreshProductStockCache(productUuid);
    }
    return uuid;
  }

  /// Receive qty into a new lot (purchase or manual OPENING/PRODUCTION/ADJUSTMENT).
  Future<String> receiveIntoBatch({
    required String productUuid,
    required double quantity,
    required double effectiveCost,
    String? batchNumber,
    bool isManual = false,
    String? manualType,
    DateTime? manufactureDate,
    DateTime? expiryDate,
    double? retailPriceOverride,
    double? wholesalePriceOverride,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('receive quantity must be > 0');
    }
    if (isManual &&
        (manualType == null || !ManualBatchType.all.contains(manualType))) {
      throw ArgumentError(
        'manualType required for manual lots: ${ManualBatchType.all.join("|")}',
      );
    }

    // #region agent log
    _agentLog(
      hypothesisId: 'H1',
      location: 'inventory_repository.dart:receiveIntoBatch',
      message: 'receive lot',
      data: {
        'productUuid': productUuid,
        'quantity': quantity,
        'effectiveCost': effectiveCost,
        'isManual': isManual,
        'manualType': manualType,
      },
    );
    // #endregion
    return createBatch(
      ProductBatchesCompanion.insert(
        uuid: const Uuid().v4(),
        productUuid: productUuid,
        batchNumber: batchNumber ?? '',
        totalQuantity: Value(quantity),
        consumedQuantity: const Value(0.0),
        effectiveCost: Value(effectiveCost),
        isManual: Value(isManual),
        manualType: Value(isManual ? manualType : null),
        manufactureDate: Value(manufactureDate),
        expiryDate: Value(expiryDate),
        retailPriceOverride: Value(retailPriceOverride),
        wholesalePriceOverride: Value(wholesalePriceOverride),
      ),
    );
  }

  Future<bool> updateBatch(ProductBatche batch) async {
    final ok = await _db
        .update(_db.productBatches)
        .replace(batch.copyWith(isNotSynced: true));
    await refreshProductStockCache(batch.productUuid);
    return ok;
  }

  /// Consume [quantity] from a specific lot.
  Future<void> consumeFromBatch({
    required String batchUuid,
    required double quantity,
  }) async {
    if (quantity <= 0) return;
    final batch = await getBatch(batchUuid);
    if (batch == null) {
      throw StateError('Batch not found: $batchUuid');
    }
    final remaining = batch.remainingQuantity;
    if (quantity > remaining + 1e-9) {
      throw StateError(
        'Insufficient lot qty: need $quantity, remaining $remaining',
      );
    }
    await (_db.update(_db.productBatches)..where((b) => b.uuid.equals(batchUuid)))
        .write(
      ProductBatchesCompanion(
        consumedQuantity: Value(batch.consumedQuantity + quantity),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await refreshProductStockCache(batch.productUuid);
  }

  /// Restore qty onto a lot (sale return): reduce consumed, floored at 0.
  Future<void> restoreToBatch({
    required String batchUuid,
    required double quantity,
  }) async {
    if (quantity <= 0) return;
    final batch = await getBatch(batchUuid);
    if (batch == null) {
      throw StateError('Batch not found: $batchUuid');
    }
    final nextConsumed = (batch.consumedQuantity - quantity).clamp(0.0, double.infinity);
    await (_db.update(_db.productBatches)..where((b) => b.uuid.equals(batchUuid)))
        .write(
      ProductBatchesCompanion(
        consumedQuantity: Value(nextConsumed.toDouble()),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await refreshProductStockCache(batch.productUuid);
  }

  /// FEFO consume across lots. Returns allocation slices (may be multiple).
  Future<List<BatchAllocation>> consumeFefo({
    required String productUuid,
    required double quantity,
  }) async {
    if (quantity <= 0) return const [];

    final batches = await (_db.select(_db.productBatches)
          ..where((b) =>
              b.productUuid.equals(productUuid) &
              b.isDeleted.equals(false) &
              b.totalQuantity.isBiggerThan(b.consumedQuantity))
          ..orderBy([
            (b) => OrderingTerm.asc(b.expiryDate),
            (b) => OrderingTerm.asc(b.createdAt),
          ]))
        .get();

    final available =
        batches.fold<double>(0, (s, b) => s + b.remainingQuantity);
    if (quantity > available + 1e-9) {
      throw StateError(
        'Insufficient stock for $productUuid: need $quantity, have $available',
      );
    }

    var need = quantity;
    final allocations = <BatchAllocation>[];
    for (final batch in batches) {
      if (need <= 1e-9) break;
      final take = batch.remainingQuantity < need ? batch.remainingQuantity : need;
      if (take <= 0) continue;
      await (_db.update(_db.productBatches)
            ..where((b) => b.uuid.equals(batch.uuid)))
          .write(
        ProductBatchesCompanion(
          consumedQuantity: Value(batch.consumedQuantity + take),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      allocations.add(
        BatchAllocation(
          batchUuid: batch.uuid,
          quantity: take,
          effectiveCost: batch.effectiveCost,
        ),
      );
      need -= take;
    }

    await refreshProductStockCache(productUuid);
    // #region agent log
    _agentLog(
      hypothesisId: 'H2',
      location: 'inventory_repository.dart:consumeFefo',
      message: 'FEFO consume done',
      data: {
        'productUuid': productUuid,
        'quantity': quantity,
        'slices': allocations.length,
        'firstBatch': allocations.isEmpty ? null : allocations.first.batchUuid,
        'cogsSample': allocations.isEmpty ? null : allocations.first.effectiveCost,
      },
    );
    // #endregion
    return allocations;
  }

  // ==========================================
  // Inventory Reconciliation
  // ==========================================

  /// Syncs product stock caches from lot remainings and refreshes WAC.
  Future<void> runFullInventoryReconciliation() async {
    await _db.transaction(() async {
      final products =
          await (_db.select(_db.products)..where((p) => p.isDeleted.equals(false)))
              .get();

      for (final prod in products) {
        await refreshProductStockCache(prod.uuid);

        final purchaseItems = await _db.customSelect(
          '''
          SELECT oi.quantity, oi.unit_price, oi.discount_amount 
          FROM order_items oi
          JOIN orders o ON oi.order_uuid = o.uuid
          WHERE oi.product_uuid = ? 
            AND o.order_type = 'PURCHASE'
            AND (o.delivery_status = 'DELIVERED' OR o.delivery_status = 'SHIPPED')
            AND oi.is_deleted = 0 AND o.is_deleted = 0
          ''',
          variables: [Variable.withString(prod.uuid)],
        ).get().then((rows) {
          return rows.map((r) {
            return {
              'qty': r.read<double>('quantity'),
              'unitPrice': r.read<double>('unit_price'),
              'discount': r.read<double>('discount_amount'),
            };
          }).toList();
        });

        final purchaseReturns = await _db.customSelect(
          '''
          SELECT ri.quantity, ri.refund_unit_price 
          FROM order_return_items ri
          JOIN order_returns r ON ri.return_uuid = r.uuid
          WHERE ri.product_uuid = ? 
            AND r.order_type = 'PURCHASE'
            AND ri.is_deleted = 0 AND r.is_deleted = 0
          ''',
          variables: [Variable.withString(prod.uuid)],
        ).get().then((rows) {
          return rows.map((r) {
            return {
              'qty': r.read<double>('quantity'),
              'refundPrice': r.read<double>('refund_unit_price'),
            };
          }).toList();
        });

        double totalQuantity = 0.0;
        double totalExpense = 0.0;

        for (final pItem in purchaseItems) {
          final qty = pItem['qty']!;
          final price = pItem['unitPrice']!;
          final discount = pItem['discount']!;
          totalQuantity += qty;
          totalExpense += (qty * price) - discount;
        }

        for (final pRet in purchaseReturns) {
          final qty = pRet['qty']!;
          final refundPrice = pRet['refundPrice']!;
          totalQuantity -= qty;
          totalExpense -= (qty * refundPrice);
        }

        double finalWac = prod.purchasePrice;
        if (totalQuantity > 0 && totalExpense >= 0) {
          finalWac = totalExpense / totalQuantity;
        }

        await (_db.update(_db.products)..where((p) => p.uuid.equals(prod.uuid)))
            .write(
          ProductsCompanion(
            purchasePrice: Value(finalWac),
            isNotSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }
}
