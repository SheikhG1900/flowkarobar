import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/inventory/data/inventory_repository.dart';
import 'package:flowpaisa/features/inventory/domain/batch_models.dart';
import 'package:flowpaisa/features/inventory/domain/order_costing.dart';
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

  /// Marks sale delivered (FEFO consume) or receives remaining purchase qty.
  Future<void> markDelivered(
    String orderUuid, {
    double freightAmount = 0,
    double dutyAmount = 0,
  }) async {
    final order = await getOrder(orderUuid);
    if (order == null || order.deliveryStatus == 'DELIVERED') return;

    if (order.orderType == 'PURCHASE') {
      await _receiveRemainingPurchase(
        orderUuid: orderUuid,
        freightAmount: freightAmount,
        dutyAmount: dutyAmount,
      );
      return;
    }

    await _db.transaction(() async {
      final items = await (_db.select(_db.orderItems)
            ..where((oi) =>
                oi.orderUuid.equals(orderUuid) & oi.isDeleted.equals(false)))
          .get();

      if (order.deliveryStatus != 'SHIPPED') {
        await _applySaleStock(items);
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
    double freightAmount = 0,
    double dutyAmount = 0,
  }) async {
    await _db.transaction(() async {
      final uuid = order.uuid.present ? order.uuid.value : const Uuid().v4();
      final isSale = order.orderType.value == 'SALE';
      final appliesStock = order.deliveryStatus.value == 'DELIVERED' ||
          order.deliveryStatus.value == 'SHIPPED';

      // Stamp planned unit costs (discounts only; freight applied at receive).
      final costInputs = items
          .map(
            (i) => OrderLineCostInput(
              id: i.uuid.present ? i.uuid.value : const Uuid().v4(),
              quantity: i.quantity.value,
              unitPrice: i.unitPrice.value,
              lineDiscount:
                  i.discountAmount.present ? i.discountAmount.value : 0,
            ),
          )
          .toList();
      // Ensure uuids exist on companions before insert
      final itemsWithIds = <OrderItemsCompanion>[];
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final itemUuid = item.uuid.present ? item.uuid.value : costInputs[i].id;
        itemsWithIds.add(item.copyWith(uuid: Value(itemUuid)));
      }
      final planned = computePlannedUnitCosts(
        lines: [
          for (final i in itemsWithIds)
            OrderLineCostInput(
              id: i.uuid.value,
              quantity: i.quantity.value,
              unitPrice: i.unitPrice.value,
              lineDiscount:
                  i.discountAmount.present ? i.discountAmount.value : 0,
            ),
        ],
        orderDiscount:
            order.discountAmount.present ? order.discountAmount.value : 0,
      );

      await _db.into(_db.orders).insert(
            order.copyWith(
              uuid: Value(uuid),
              isNotSynced: const Value(true),
            ),
          );

      final inserted = <OrderItem>[];
      for (final item in itemsWithIds) {
        final plannedCost = planned[item.uuid.value] ?? item.unitPrice.value;
        final companion = item.copyWith(
          orderUuid: Value(uuid),
          purchasePriceSnapshot: Value(plannedCost),
          receivedQuantity: const Value(0.0),
          isNotSynced: const Value(true),
        );
        await _db.into(_db.orderItems).insert(companion);
        inserted.add(
          await (_db.select(_db.orderItems)
                ..where((oi) => oi.uuid.equals(item.uuid.value)))
              .getSingle(),
        );
      }

      if (appliesStock) {
        if (isSale) {
          await _applySaleStock(inserted);
        } else {
          await _receiveRemainingPurchase(
            orderUuid: uuid,
            freightAmount: freightAmount,
            dutyAmount: dutyAmount,
          );
        }
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

  Future<void> _receiveRemainingPurchase({
    required String orderUuid,
    double freightAmount = 0,
    double dutyAmount = 0,
  }) async {
    final items = await (_db.select(_db.orderItems)
          ..where((oi) =>
              oi.orderUuid.equals(orderUuid) & oi.isDeleted.equals(false)))
        .get();

    final lines = <ReceiveLineInput>[];
    for (final item in items) {
      final product = await _inventory.getProduct(item.productUuid);
      if (product == null || product.isService) continue;
      final open = item.quantity - item.receivedQuantity;
      if (open <= 1e-9) continue;
      lines.add(
        ReceiveLineInput(
          orderItemUuid: item.uuid,
          quantity: open,
        ),
      );
    }
    if (lines.isEmpty) return;

    await _inventory.receivePurchaseShipment(
      orderUuid: orderUuid,
      lines: lines,
      freightAmount: freightAmount,
      dutyAmount: dutyAmount,
    );
  }

  Future<void> _applySaleStock(List<OrderItem> items) async {
    for (final item in items) {
      final product = await _inventory.getProduct(item.productUuid);
      if (product == null || product.isService) continue;

      String? batchUuid = item.batchUuid;
      double cogs = item.purchasePriceSnapshot;

      if (batchUuid != null) {
        final batch = await _inventory.getBatch(batchUuid);
        if (batch == null) {
          throw StateError('Batch not found: $batchUuid');
        }
        await _inventory.consumeFromBatch(
          batchUuid: batchUuid,
          quantity: item.quantity,
        );
        cogs = batch.effectiveCost;
      } else {
        final allocations = await _inventory.consumeFefo(
          productUuid: item.productUuid,
          quantity: item.quantity,
        );
        if (allocations.isEmpty) continue;
        batchUuid = allocations.first.batchUuid;
        final costSum = allocations.fold<double>(
          0,
          (s, a) => s + a.quantity * a.effectiveCost,
        );
        cogs = costSum / item.quantity;
      }

      await (_db.update(_db.orderItems)..where((oi) => oi.uuid.equals(item.uuid)))
          .write(
        OrderItemsCompanion(
          batchUuid: Value(batchUuid),
          purchasePriceSnapshot: Value(cogs),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
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
