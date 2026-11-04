import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/inventory/data/inventory_repository.dart';
import 'package:flowpaisa/features/inventory/domain/batch_models.dart';
import 'package:uuid/uuid.dart';

class OrdersRepository {
  final AppDatabase _db;
  late final InventoryRepository _inventory;

  OrdersRepository(this._db) : _inventory = InventoryRepository(_db);

  // ==========================================
  // Basic Order Select & Streams
  // ==========================================

  Stream<List<Order>> watchAllOrders() {
    return (_db.select(_db.orders)
          ..where((o) => o.isDeleted.equals(false))
          ..orderBy([(o) => OrderingTerm.desc(o.orderDate)]))
        .watch();
  }

  Stream<List<Order>> watchOrdersByType(String orderType) {
    return (_db.select(_db.orders)
          ..where((o) =>
              o.isDeleted.equals(false) & o.orderType.equals(orderType))
          ..orderBy([(o) => OrderingTerm.desc(o.orderDate)]))
        .watch();
  }

  Stream<List<OrderReturn>> watchAllReturns() {
    return (_db.select(_db.orderReturns)
          ..where((r) => r.isDeleted.equals(false))
          ..orderBy([(r) => OrderingTerm.desc(r.date)]))
        .watch();
  }

  Future<String> nextOrderNumber(String orderType) async {
    final prefix = orderType == 'SALE' ? 'SO' : 'PO';
    final count = await (_db.selectOnly(_db.orders)
          ..addColumns([_db.orders.uuid.count()])
          ..where(_db.orders.orderType.equals(orderType)))
        .getSingle()
        .then((row) => row.read(_db.orders.uuid.count()) ?? 0);
    return '$prefix-${(count + 1).toString().padLeft(5, '0')}';
  }

  Future<double> getPaidAmountForOrder(String orderUuid) async {
    final sum = await (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amount.sum()])
          ..where(_db.transactions.orderUuid.equals(orderUuid) &
              _db.transactions.isDeleted.equals(false)))
        .getSingle()
        .then((row) => row.read(_db.transactions.amount.sum()) ?? 0.0);
    return sum;
  }

  Future<void> recordOrderPayment({
    required String orderUuid,
    required double amount,
    required String accountUuid,
  }) async {
    await _db.transaction(() async {
      final order = await getOrder(orderUuid);
      if (order == null) return;

      final isSale = order.orderType == 'SALE';
      await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              uuid: const Uuid().v4(),
              amount: amount,
              type: isSale ? 'CASH_IN' : 'CASH_OUT',
              contactUuid: Value(order.contactUuid),
              orderUuid: Value(orderUuid),
              description: Value(
                isSale
                    ? 'Collection for ${order.orderNumber}'
                    : 'Payment for ${order.orderNumber}',
              ),
              date: DateTime.now(),
              accountUuid: Value(accountUuid),
              processedDate: Value(DateTime.now()),
              isNotSynced: const Value(true),
            ),
          );

      final paid = await getPaidAmountForOrder(orderUuid);
      final status = paid <= 0
          ? 'UNPAID'
          : paid + 0.001 >= order.totalAmount
              ? 'PAID'
              : 'PARTIALLY_PAID';

      await (_db.update(_db.orders)..where((o) => o.uuid.equals(orderUuid)))
          .write(
        OrdersCompanion(
          paymentStatus: Value(status),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> markDelivered(String orderUuid) async {
    final order = await getOrder(orderUuid);
    if (order == null || order.deliveryStatus == 'DELIVERED') return;

    await _db.transaction(() async {
      final items = await (_db.select(_db.orderItems)
            ..where((oi) =>
                oi.orderUuid.equals(orderUuid) & oi.isDeleted.equals(false)))
          .get();

      if (order.deliveryStatus != 'SHIPPED') {
        await _applyStockForItems(
          isSale: order.orderType == 'SALE',
          items: items
              .map(
                (i) => OrderItemsCompanion(
                  uuid: Value(i.uuid),
                  orderUuid: Value(i.orderUuid),
                  productUuid: Value(i.productUuid),
                  productNameSnapshot: Value(i.productNameSnapshot),
                  quantity: Value(i.quantity),
                  unitPrice: Value(i.unitPrice),
                  discountAmount: Value(i.discountAmount),
                  taxRate: Value(i.taxRate),
                  batchUuid: Value(i.batchUuid),
                  purchasePriceSnapshot: Value(i.purchasePriceSnapshot),
                  unit: Value(i.unit),
                ),
              )
              .toList(),
          updateExistingItems: true,
        );
      }

      await (_db.update(_db.orders)..where((o) => o.uuid.equals(orderUuid)))
          .write(
        OrdersCompanion(
          deliveryStatus: const Value('DELIVERED'),
          deliveredDate: Value(DateTime.now()),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Stream<List<Order>> watchTodayOrders() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (_db.select(_db.orders)
          ..where((o) =>
              o.isDeleted.equals(false) &
              o.orderDate.isBiggerOrEqualValue(startOfDay) &
              o.orderDate.isSmallerThanValue(endOfDay)))
        .watch();
  }

  Stream<List<Order>> watchOrdersForContact(String contactUuid) {
    return (_db.select(_db.orders)
          ..where((o) =>
              o.contactUuid.equals(contactUuid) & o.isDeleted.equals(false))
          ..orderBy([(o) => OrderingTerm.desc(o.orderDate)]))
        .watch();
  }

  Future<Order?> getOrder(String uuid) {
    return (_db.select(_db.orders)
          ..where((o) => o.uuid.equals(uuid) & o.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Stream<List<OrderItem>> watchItemsForOrder(String orderUuid) {
    return (_db.select(_db.orderItems)
          ..where((oi) =>
              oi.orderUuid.equals(orderUuid) & oi.isDeleted.equals(false)))
        .watch();
  }

  // ==========================================
  // Sale & Purchase Order Operations
  // ==========================================

  Future<void> createOrder({
    required OrdersCompanion order,
    required List<OrderItemsCompanion> items,
    required double paymentAmount,
    required String? accountUuid,
  }) async {
    await _db.transaction(() async {
      final uuid = order.uuid.present ? order.uuid.value : const Uuid().v4();
      final isSale = order.orderType.value == 'SALE';
      final appliesStock = order.deliveryStatus.value == 'DELIVERED' ||
          order.deliveryStatus.value == 'SHIPPED';

      await _db.into(_db.orders).insert(
            order.copyWith(
              uuid: Value(uuid),
              isNotSynced: const Value(true),
            ),
          );

      final insertedItems = <OrderItemsCompanion>[];
      for (final item in items) {
        final itemUuid =
            item.uuid.present ? item.uuid.value : const Uuid().v4();
        final companion = item.copyWith(
          uuid: Value(itemUuid),
          orderUuid: Value(uuid),
          isNotSynced: const Value(true),
        );
        await _db.into(_db.orderItems).insert(companion);
        insertedItems.add(companion);
      }

      if (appliesStock) {
        await _applyStockForItems(
          isSale: isSale,
          items: insertedItems,
          updateExistingItems: true,
        );
      }

      if (paymentAmount > 0 && accountUuid != null) {
        final txType = isSale ? 'CASH_IN' : 'CASH_OUT';
        final txDesc = isSale
            ? 'Collected payment for Sale ${order.orderNumber.value}'
            : 'Upfront payment for Purchase ${order.orderNumber.value}';

        await _db.into(_db.transactions).insert(
              TransactionsCompanion.insert(
                uuid: const Uuid().v4(),
                amount: paymentAmount,
                type: txType,
                contactUuid: Value(order.contactUuid.value),
                orderUuid: Value(uuid),
                description: Value(txDesc),
                date: order.orderDate.value,
                accountUuid: Value(accountUuid),
                processedDate: Value(order.orderDate.value),
                isNotSynced: const Value(true),
              ),
            );
      }
    });
  }

  /// Applies lot receive (purchase) or FEFO consume (sale) and stamps COGS.
  Future<void> _applyStockForItems({
    required bool isSale,
    required List<OrderItemsCompanion> items,
    required bool updateExistingItems,
  }) async {
    for (final item in items) {
      final productUuid = item.productUuid.value;
      final qty = item.quantity.value;
      final itemUuid = item.uuid.value;

      // Skip services
      final product = await _inventory.getProduct(productUuid);
      if (product == null || product.isService) continue;

      if (isSale) {
        String? batchUuid = item.batchUuid.present ? item.batchUuid.value : null;
        double cogs = item.purchasePriceSnapshot.present
            ? item.purchasePriceSnapshot.value
            : 0.0;

        if (batchUuid != null) {
          final batch = await _inventory.getBatch(batchUuid);
          if (batch == null) {
            throw StateError('Batch not found: $batchUuid');
          }
          await _inventory.consumeFromBatch(
            batchUuid: batchUuid,
            quantity: qty,
          );
          cogs = batch.effectiveCost;
        } else {
          final allocations = await _inventory.consumeFefo(
            productUuid: productUuid,
            quantity: qty,
          );
          if (allocations.isEmpty) continue;
          batchUuid = allocations.first.batchUuid;
          final costSum = allocations.fold<double>(
            0,
            (s, a) => s + a.quantity * a.effectiveCost,
          );
          cogs = costSum / qty;
        }

        if (updateExistingItems) {
          await (_db.update(_db.orderItems)
                ..where((oi) => oi.uuid.equals(itemUuid)))
              .write(
            OrderItemsCompanion(
              batchUuid: Value(batchUuid),
              purchasePriceSnapshot: Value(cogs),
              isNotSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      } else {
        // Purchase receive → new non-manual lot; stamp unit price as effectiveCost
        final unitCost = item.unitPrice.value;
        String? batchUuid = item.batchUuid.present ? item.batchUuid.value : null;

        if (batchUuid == null) {
          batchUuid = await _inventory.receiveIntoBatch(
            productUuid: productUuid,
            quantity: qty,
            effectiveCost: unitCost,
            isManual: false,
          );
        } else {
          // Existing batch specified: increase total (rare path)
          final batch = await _inventory.getBatch(batchUuid);
          if (batch == null) {
            throw StateError('Batch not found: $batchUuid');
          }
          await (_db.update(_db.productBatches)
                ..where((b) => b.uuid.equals(batchUuid!)))
              .write(
            ProductBatchesCompanion(
              totalQuantity: Value(batch.totalQuantity + qty),
              effectiveCost: Value(unitCost),
              isNotSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ),
          );
          await _inventory.refreshProductStockCache(productUuid);
        }

        await (_db.update(_db.products)..where((p) => p.uuid.equals(productUuid)))
            .write(
          ProductsCompanion(
            purchasePrice: Value(unitCost),
            isNotSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );

        if (updateExistingItems) {
          await (_db.update(_db.orderItems)
                ..where((oi) => oi.uuid.equals(itemUuid)))
              .write(
            OrderItemsCompanion(
              batchUuid: Value(batchUuid),
              purchasePriceSnapshot: Value(unitCost),
              isNotSynced: const Value(true),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    }
  }

  // ==========================================
  // Returns & Refunds
  // ==========================================

  Future<void> createReturn({
    required OrderReturnsCompanion returnOrder,
    required List<OrderReturnItemsCompanion> returnItems,
    required double refundAmount,
    required String? accountUuid,
  }) async {
    await _db.transaction(() async {
      final uuid =
          returnOrder.uuid.present ? returnOrder.uuid.value : const Uuid().v4();
      final isSaleReturn = returnOrder.orderType.value == 'SALE';

      await _db.into(_db.orderReturns).insert(
            returnOrder.copyWith(
              uuid: Value(uuid),
              isNotSynced: const Value(true),
            ),
          );

      for (final item in returnItems) {
        final itemUuid =
            item.uuid.present ? item.uuid.value : const Uuid().v4();
        await _db.into(_db.orderReturnItems).insert(
              item.copyWith(
                uuid: Value(itemUuid),
                returnUuid: Value(uuid),
                isNotSynced: const Value(true),
              ),
            );

        final productUuid = item.productUuid.value;
        final product = await _inventory.getProduct(productUuid);
        if (product == null || product.isService) continue;

        final batchUuid = item.batchUuid.present ? item.batchUuid.value : null;
        final qty = item.quantity.value;

        if (isSaleReturn) {
          // Customer returns goods → restore onto lot (or OPENING-like if unknown)
          if (batchUuid != null) {
            await _inventory.restoreToBatch(
              batchUuid: batchUuid,
              quantity: qty,
            );
          } else {
            await _inventory.receiveIntoBatch(
              productUuid: productUuid,
              quantity: qty,
              effectiveCost: item.refundUnitPrice.value,
              isManual: true,
              manualType: ManualBatchType.adjustment,
              batchNumber: 'RET-${DateTime.now().millisecondsSinceEpoch}',
            );
          }
        } else {
          // Purchase return → consume from lot
          if (batchUuid != null) {
            await _inventory.consumeFromBatch(
              batchUuid: batchUuid,
              quantity: qty,
            );
          } else {
            await _inventory.consumeFefo(
              productUuid: productUuid,
              quantity: qty,
            );
          }
        }
      }

      if (refundAmount > 0 && accountUuid != null) {
        final txType = isSaleReturn ? 'CASH_OUT' : 'CASH_IN';
        final txDesc = isSaleReturn
            ? 'Cash Refund paid to Customer for Return ${returnOrder.returnNumber.value}'
            : 'Cash Refund received from Supplier for Return ${returnOrder.returnNumber.value}';

        await _db.into(_db.transactions).insert(
              TransactionsCompanion.insert(
                uuid: const Uuid().v4(),
                amount: refundAmount,
                type: txType,
                contactUuid: Value(returnOrder.contactUuid.value),
                orderUuid: Value(returnOrder.orderUuid.value),
                description: Value(txDesc),
                date: returnOrder.date.value,
                accountUuid: Value(accountUuid),
                processedDate: Value(returnOrder.date.value),
                isNotSynced: const Value(true),
              ),
            );
      }
    });
  }

  // ==========================================
  // Standalone Payments & Collections
  // ==========================================

  Future<void> recordLedgerSettlement({
    required String contactUuid,
    required double amount,
    required String accountUuid,
    required bool isCollection,
    required String? linkedOrderUuid,
  }) async {
    final txType = isCollection ? 'CASH_IN' : 'CASH_OUT';
    final txDesc = isCollection
        ? 'Stand-alone cash payment received from Customer'
        : 'Stand-alone credit bill paid to Supplier';

    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            uuid: const Uuid().v4(),
            amount: amount,
            type: txType,
            contactUuid: Value(contactUuid),
            orderUuid: Value(linkedOrderUuid),
            description: Value(txDesc),
            date: DateTime.now(),
            accountUuid: Value(accountUuid),
            processedDate: Value(DateTime.now()),
            isNotSynced: const Value(true),
          ),
        );
  }
}
