import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/inventory/domain/batch_models.dart';
import 'package:flowpaisa/features/inventory/domain/order_costing.dart';
import 'package:uuid/uuid.dart';

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

/// One line to receive against a PO item (1 shipment line → 1 lot).
class ReceiveLineInput {
  final String orderItemUuid;
  final double quantity;
  final String? batchNumber;
  final DateTime? manufactureDate;
  final DateTime? expiryDate;

  const ReceiveLineInput({
    required this.orderItemUuid,
    required this.quantity,
    this.batchNumber,
    this.manufactureDate,
    this.expiryDate,
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

  Stream<Product?> watchProduct(String uuid) {
    return (_db.select(_db.products)
          ..where((p) => p.uuid.equals(uuid) & p.isDeleted.equals(false)))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
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

  /// Creates a product and, when [openingQuantity] > 0, an OPENING manual lot.
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

  /// Resolves PO + supplier + receipt date for a purchase lot.
  Future<LotPurchaseContext?> getLotPurchaseContext(ProductBatche lot) async {
    if (lot.isManual) return null;
    final orderItemId = lot.orderItemUuid;
    if (orderItemId == null || orderItemId.isEmpty) return null;

    final item = await (_db.select(_db.orderItems)
          ..where(
              (oi) => oi.uuid.equals(orderItemId) & oi.isDeleted.equals(false)))
        .getSingleOrNull();
    if (item == null) return null;

    final order = await (_db.select(_db.orders)
          ..where(
              (o) => o.uuid.equals(item.orderUuid) & o.isDeleted.equals(false)))
        .getSingleOrNull();
    if (order == null) return null;

    String? supplierName;
    final contactUuid = order.contactUuid;
    if (contactUuid != null && contactUuid.isNotEmpty) {
      final contact = await (_db.select(_db.contacts)
            ..where((c) =>
                c.uuid.equals(contactUuid) & c.isDeleted.equals(false)))
          .getSingleOrNull();
      supplierName = contact?.name;
    }

    DateTime? receivedAt;
    final shipmentLineId = lot.shipmentLineUuid;
    if (shipmentLineId != null && shipmentLineId.isNotEmpty) {
      final line = await (_db.select(_db.goodsReceiptLines)
            ..where((l) =>
                l.uuid.equals(shipmentLineId) & l.isDeleted.equals(false)))
          .getSingleOrNull();
      if (line != null) {
        final receipt = await (_db.select(_db.goodsReceipts)
              ..where((r) =>
                  r.uuid.equals(line.receiptUuid) &
                  r.isDeleted.equals(false)))
            .getSingleOrNull();
        receivedAt = receipt?.receivedAt;
      }
    }

    return LotPurchaseContext(
      orderUuid: order.uuid,
      orderNumber: order.orderNumber,
      orderDate: order.orderDate,
      supplierName: supplierName,
      receivedAt: receivedAt,
    );
  }

  Future<Map<String, LotPurchaseContext>> getLotPurchaseContexts(
    Iterable<ProductBatche> lots,
  ) async {
    final map = <String, LotPurchaseContext>{};
    for (final lot in lots) {
      if (lot.isManual) continue;
      final ctx = await getLotPurchaseContext(lot);
      if (ctx != null) map[lot.uuid] = ctx;
    }
    return map;
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

    final productUuid =
        batch.productUuid.present ? batch.productUuid.value : null;
    if (productUuid != null) {
      await refreshProductStockCache(productUuid);
    }
    return uuid;
  }

  /// Receive qty into a new lot (manual OPENING/PRODUCTION/ADJUSTMENT, or raw insert).
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
    String? shipmentLineUuid,
    String? orderItemUuid,
    String? sourceLotUuid,
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
    if (!isManual && shipmentLineUuid == null) {
      throw ArgumentError('purchase lots require shipmentLineUuid');
    }

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
        shipmentLineUuid: Value(isManual ? null : shipmentLineUuid),
        orderItemUuid: Value(isManual ? null : orderItemUuid),
        sourceLotUuid: Value(sourceLotUuid),
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

  /// Manual lots only: set cost in place if unused; else split remaining to a new lot.
  /// Returns the lot uuid that holds the new cost (same or new).
  Future<String> updateManualLotEffectiveCost({
    required String lotUuid,
    required double newEffectiveCost,
  }) async {
    final lot = await getBatch(lotUuid);
    if (lot == null) throw StateError('Lot not found: $lotUuid');
    if (!lot.isManual) {
      throw StateError('Purchase lot cost is immutable; correct via PO/receive');
    }
    if ((newEffectiveCost - lot.effectiveCost).abs() < 1e-9) {
      return lotUuid;
    }

    if (lot.consumedQuantity <= 1e-9) {
      await (_db.update(_db.productBatches)..where((b) => b.uuid.equals(lotUuid)))
          .write(
        ProductBatchesCompanion(
          effectiveCost: Value(newEffectiveCost),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return lotUuid;
    }

    final remaining = lot.remainingQuantity;
    if (remaining <= 1e-9) {
      throw StateError('No remaining qty to reprice on lot $lotUuid');
    }

    return _db.transaction(() async {
      // Close remaining on old lot without inventing consumption.
      await (_db.update(_db.productBatches)..where((b) => b.uuid.equals(lotUuid)))
          .write(
        ProductBatchesCompanion(
          totalQuantity: Value(lot.consumedQuantity),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final newLotUuid = await receiveIntoBatch(
        productUuid: lot.productUuid,
        quantity: remaining,
        effectiveCost: newEffectiveCost,
        isManual: true,
        manualType: lot.manualType ?? ManualBatchType.adjustment,
        batchNumber: lot.batchNumber,
        manufactureDate: lot.manufactureDate,
        expiryDate: lot.expiryDate,
        retailPriceOverride: lot.retailPriceOverride,
        wholesalePriceOverride: lot.wholesalePriceOverride,
        sourceLotUuid: lot.uuid,
      );
      return newLotUuid;
    });
  }

  /// Reduce manual (or any) lot total, not below consumed.
  Future<void> reduceLotTotalQuantity({
    required String lotUuid,
    required double newTotalQuantity,
  }) async {
    final lot = await getBatch(lotUuid);
    if (lot == null) throw StateError('Lot not found: $lotUuid');
    if (newTotalQuantity < lot.consumedQuantity - 1e-9) {
      throw StateError(
        'totalQuantity cannot be less than consumed (${lot.consumedQuantity})',
      );
    }
    await (_db.update(_db.productBatches)..where((b) => b.uuid.equals(lotUuid)))
        .write(
      ProductBatchesCompanion(
        totalQuantity: Value(newTotalQuantity),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await refreshProductStockCache(lot.productUuid);
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
    final nextConsumed =
        (batch.consumedQuantity - quantity).clamp(0.0, double.infinity);
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
      final take =
          batch.remainingQuantity < need ? batch.remainingQuantity : need;
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
    return allocations;
  }

  // ==========================================
  // Goods receipts (1 shipment line → 1 lot)
  // ==========================================

  /// Receives stock against a purchase order. Each [lines] entry creates one
  /// receipt line and one lot with frozen landed [effectiveCost].
  Future<String> receivePurchaseShipment({
    required String orderUuid,
    required List<ReceiveLineInput> lines,
    double freightAmount = 0,
    double dutyAmount = 0,
    DateTime? receivedAt,
    String? notes,
  }) async {
    if (lines.isEmpty) {
      throw ArgumentError('receive lines required');
    }

    return _db.transaction(() async {
      final order = await (_db.select(_db.orders)
            ..where((o) => o.uuid.equals(orderUuid) & o.isDeleted.equals(false)))
          .getSingleOrNull();
      if (order == null) throw StateError('Order not found: $orderUuid');
      if (order.orderType != 'PURCHASE') {
        throw StateError('Goods receipt only for purchase orders');
      }

      final orderItems = await (_db.select(_db.orderItems)
            ..where((oi) =>
                oi.orderUuid.equals(orderUuid) & oi.isDeleted.equals(false)))
          .get();
      final byId = {for (final i in orderItems) i.uuid: i};

      // Validate open qty and build costing inputs for THIS shipment's lines
      // using full PO lines for discount weight, then scale landed onto received.
      final costInputs = orderItems
          .map((i) => OrderLineCostInput(
                id: i.uuid,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                lineDiscount: i.discountAmount,
              ))
          .toList();

      final plannedByLine = computePlannedUnitCosts(
        lines: costInputs,
        orderDiscount: order.discountAmount,
        freightAmount: 0,
        dutyAmount: 0,
      );

      // Landed share only across lines being received, by receive value weight.
      final receiveCostInputs = <OrderLineCostInput>[];
      for (final line in lines) {
        final item = byId[line.orderItemUuid];
        if (item == null) {
          throw StateError('Order item not found: ${line.orderItemUuid}');
        }
        final product = await getProduct(item.productUuid);
        if (product == null || product.isService) continue;
        if (line.quantity <= 0) {
          throw ArgumentError('receive qty must be > 0');
        }
        final open = item.quantity - item.receivedQuantity;
        if (line.quantity > open + 1e-9) {
          throw StateError(
            'Receive ${line.quantity} exceeds open $open for ${item.productNameSnapshot}',
          );
        }
        final planned = plannedByLine[item.uuid] ?? item.unitPrice;
        receiveCostInputs.add(
          OrderLineCostInput(
            id: item.uuid,
            quantity: line.quantity,
            unitPrice: planned,
            lineDiscount: 0,
          ),
        );
      }

      final landedUnitByLine = computePlannedUnitCosts(
        lines: receiveCostInputs,
        orderDiscount: 0,
        freightAmount: freightAmount,
        dutyAmount: dutyAmount,
      );

      final receiptUuid = const Uuid().v4();
      await _db.into(_db.goodsReceipts).insert(
            GoodsReceiptsCompanion.insert(
              uuid: receiptUuid,
              orderUuid: orderUuid,
              receivedAt: receivedAt ?? DateTime.now(),
              freightAmount: Value(freightAmount),
              dutyAmount: Value(dutyAmount),
              notes: Value(notes),
            ),
          );

      final receivedSoFar = <String, double>{
        for (final i in orderItems) i.uuid: i.receivedQuantity,
      };

      for (final line in lines) {
        final item = byId[line.orderItemUuid]!;
        final product = await getProduct(item.productUuid);
        if (product == null || product.isService) continue;

        final unitCost = landedUnitByLine[item.uuid] ??
            plannedByLine[item.uuid] ??
            item.unitPrice;

        final lineUuid = const Uuid().v4();
        await _db.into(_db.goodsReceiptLines).insert(
              GoodsReceiptLinesCompanion.insert(
                uuid: lineUuid,
                receiptUuid: receiptUuid,
                orderItemUuid: item.uuid,
                productUuid: item.productUuid,
                quantity: line.quantity,
                effectiveUnitCost: Value(unitCost),
                batchNumber: Value(line.batchNumber ?? ''),
                manufactureDate: Value(line.manufactureDate),
                expiryDate: Value(line.expiryDate),
              ),
            );

        final lotUuid = await receiveIntoBatch(
          productUuid: item.productUuid,
          quantity: line.quantity,
          effectiveCost: unitCost,
          isManual: false,
          batchNumber: line.batchNumber,
          manufactureDate: line.manufactureDate,
          expiryDate: line.expiryDate,
          shipmentLineUuid: lineUuid,
          orderItemUuid: item.uuid,
        );

        await (_db.update(_db.goodsReceiptLines)
              ..where((l) => l.uuid.equals(lineUuid)))
            .write(
          GoodsReceiptLinesCompanion(
            lotUuid: Value(lotUuid),
            isNotSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );

        final nextReceived =
            (receivedSoFar[item.uuid] ?? 0) + line.quantity;
        receivedSoFar[item.uuid] = nextReceived;

        await (_db.update(_db.orderItems)..where((oi) => oi.uuid.equals(item.uuid)))
            .write(
          OrderItemsCompanion(
            receivedQuantity: Value(nextReceived),
            purchasePriceSnapshot: Value(unitCost),
            batchUuid: Value(lotUuid),
            isNotSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );

        await (_db.update(_db.products)
              ..where((p) => p.uuid.equals(item.productUuid)))
            .write(
          ProductsCompanion(
            purchasePrice: Value(unitCost),
            isNotSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      // Refresh delivery status from received vs ordered.
      await _refreshPurchaseDeliveryStatus(orderUuid);
      return receiptUuid;
    });
  }

  Future<void> _refreshPurchaseDeliveryStatus(String orderUuid) async {
    final items = await (_db.select(_db.orderItems)
          ..where((oi) =>
              oi.orderUuid.equals(orderUuid) & oi.isDeleted.equals(false)))
        .get();
    if (items.isEmpty) return;

    var allDone = true;
    var anyReceived = false;
    for (final i in items) {
      final product = await getProduct(i.productUuid);
      if (product == null || product.isService) continue;
      if (i.receivedQuantity > 1e-9) anyReceived = true;
      if (i.receivedQuantity + 1e-9 < i.quantity) allDone = false;
    }

    final status = allDone
        ? 'DELIVERED'
        : anyReceived
            ? 'SHIPPED'
            : 'PENDING';

    await (_db.update(_db.orders)..where((o) => o.uuid.equals(orderUuid))).write(
      OrdersCompanion(
        deliveryStatus: Value(status),
        deliveredDate: Value(allDone ? DateTime.now() : null),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==========================================
  // Inventory Reconciliation
  // ==========================================

  /// Syncs product stock caches from lot remainings and refreshes WAC.
  Future<void> runFullInventoryReconciliation() async {
    await _db.transaction(() async {
      final products = await (_db.select(_db.products)
            ..where((p) => p.isDeleted.equals(false)))
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
