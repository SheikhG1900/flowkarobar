import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_pricing.dart';
import 'package:flowpaisa/features/inventory/data/inventory_repository.dart';
import 'package:flowpaisa/features/inventory/domain/batch_models.dart';
import 'package:flowpaisa/features/inventory/domain/order_costing.dart';
import 'package:flowpaisa/features/orders/domain/bundle_pricing.dart';
import 'package:flowpaisa/features/orders/domain/order_shipment.dart';
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
    final order = await getOrder(orderUuid);
    if (order == null) return 0;
    final paymentType = order.orderType == 'SALE' ? 'CASH_IN' : 'CASH_OUT';
    final sum = await (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amount.sum()])
          ..where(_db.transactions.orderUuid.equals(orderUuid) &
              _db.transactions.type.equals(paymentType) &
              _db.transactions.isOrderCost.equals(false) &
              _db.transactions.isDeleted.equals(false)))
        .getSingle()
        .then((row) => row.read(_db.transactions.amount.sum()) ?? 0.0);
    return sum;
  }

  /// Customer/supplier payments linked to this order (excludes related costs).
  Stream<List<Transaction>> watchPaymentsForOrder(String orderUuid) {
    return (_db.select(_db.orders)
          ..where((o) => o.uuid.equals(orderUuid)))
        .watch()
        .asyncExpand((orders) {
      if (orders.isEmpty) return Stream.value(const <Transaction>[]);
      final paymentType =
          orders.first.orderType == 'SALE' ? 'CASH_IN' : 'CASH_OUT';
      return (_db.select(_db.transactions)
            ..where((t) =>
                t.orderUuid.equals(orderUuid) &
                t.type.equals(paymentType) &
                t.isOrderCost.equals(false) &
                t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();
    });
  }

  /// Operating costs linked to this order (courier, etc.).
  Stream<List<Transaction>> watchOrderCostsForOrder(String orderUuid) {
    return (_db.select(_db.transactions)
          ..where((t) =>
              t.orderUuid.equals(orderUuid) &
              t.isOrderCost.equals(true) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<void> recordOrderCost({
    required String orderUuid,
    required double amount,
    required String accountUuid,
    DateTime? date,
    String? description,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Cost amount must be greater than zero');
    }
    await _db.transaction(() async {
      final order = await getOrder(orderUuid);
      if (order == null) return;
      final when = date ?? DateTime.now();
      final trimmed = description?.trim();
      final desc = (trimmed != null && trimmed.isNotEmpty)
          ? trimmed
          : 'Cost for ${order.orderNumber}';
      await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              uuid: const Uuid().v4(),
              amount: amount,
              type: 'CASH_OUT',
              contactUuid: Value(order.contactUuid),
              orderUuid: Value(orderUuid),
              description: Value(desc),
              date: when,
              accountUuid: Value(accountUuid),
              processedDate: Value(when),
              isOrderCost: const Value(true),
              isNotSynced: const Value(true),
            ),
          );
    });
  }

  Future<void> deleteOrderCost({
    required String orderUuid,
    required String costUuid,
  }) async {
    await _db.transaction(() async {
      final cost = await (_db.select(_db.transactions)
            ..where((t) =>
                t.uuid.equals(costUuid) &
                t.orderUuid.equals(orderUuid) &
                t.isOrderCost.equals(true) &
                t.isDeleted.equals(false)))
          .getSingleOrNull();
      if (cost == null) return;
      await (_db.update(_db.transactions)..where((t) => t.uuid.equals(costUuid)))
          .write(
        TransactionsCompanion(
          isDeleted: const Value(true),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> _refreshOrderPaymentStatus(String orderUuid) async {
    final order = await getOrder(orderUuid);
    if (order == null) return;

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
  }

  /// Remaining amount that can still be allocated to this order.
  /// When [excludingPaymentUuid] is set (correction), that payment's amount
  /// is treated as available again.
  Future<double> maxPayableAmountForOrder(
    String orderUuid, {
    String? excludingPaymentUuid,
  }) async {
    final order = await getOrder(orderUuid);
    if (order == null) return 0;
    final paid = await getPaidAmountForOrder(orderUuid);
    var excluded = 0.0;
    if (excludingPaymentUuid != null) {
      final tx = await (_db.select(_db.transactions)
            ..where((t) =>
                t.uuid.equals(excludingPaymentUuid) &
                t.orderUuid.equals(orderUuid) &
                t.isOrderCost.equals(false) &
                t.isDeleted.equals(false)))
          .getSingleOrNull();
      excluded = tx?.amount ?? 0;
    }
    return (order.totalAmount - (paid - excluded))
        .clamp(0, double.infinity)
        .toDouble();
  }

  Future<void> recordOrderPayment({
    required String orderUuid,
    required double amount,
    required String accountUuid,
    DateTime? date,
    String? description,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment amount must be greater than zero');
    }
    await _db.transaction(() async {
      final order = await getOrder(orderUuid);
      if (order == null) return;

      final maxAllowed = await maxPayableAmountForOrder(orderUuid);
      if (amount > maxAllowed + 0.001) {
        throw StateError(
          'Payment exceeds remaining balance ($maxAllowed)',
        );
      }

      final isSale = order.orderType == 'SALE';
      final when = date ?? DateTime.now();
      final trimmed = description?.trim();
      final desc = (trimmed != null && trimmed.isNotEmpty)
          ? trimmed
          : (isSale
              ? 'Collection for ${order.orderNumber}'
              : 'Payment for ${order.orderNumber}');
      await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              uuid: const Uuid().v4(),
              amount: amount,
              type: isSale ? 'CASH_IN' : 'CASH_OUT',
              contactUuid: Value(order.contactUuid),
              orderUuid: Value(orderUuid),
              description: Value(desc),
              date: when,
              accountUuid: Value(accountUuid),
              processedDate: Value(when),
              isNotSynced: const Value(true),
            ),
          );

      await _refreshOrderPaymentStatus(orderUuid);
    });
  }

  /// Correct an existing order-linked payment, then recompute order status.
  Future<void> updateOrderPayment({
    required String orderUuid,
    required String paymentUuid,
    required double amount,
    required String accountUuid,
    DateTime? date,
    String? description,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Payment amount must be greater than zero');
    }
    await _db.transaction(() async {
      final order = await getOrder(orderUuid);
      if (order == null) {
        throw StateError('Order not found');
      }

      final payment = await (_db.select(_db.transactions)
            ..where((t) =>
                t.uuid.equals(paymentUuid) &
                t.orderUuid.equals(orderUuid) &
                t.isOrderCost.equals(false) &
                t.isDeleted.equals(false)))
          .getSingleOrNull();
      if (payment == null) {
        throw StateError('Payment not found for this order');
      }

      final maxAllowed = await maxPayableAmountForOrder(
        orderUuid,
        excludingPaymentUuid: paymentUuid,
      );
      if (amount > maxAllowed + 0.001) {
        throw StateError(
          'Payment exceeds remaining balance ($maxAllowed)',
        );
      }

      final when = date ?? payment.date;
      final trimmed = description?.trim();
      await (_db.update(_db.transactions)
            ..where((t) => t.uuid.equals(paymentUuid)))
          .write(
        TransactionsCompanion(
          amount: Value(amount),
          accountUuid: Value(accountUuid),
          date: Value(when),
          processedDate: Value(when),
          description: Value(
            (trimmed != null && trimmed.isNotEmpty) ? trimmed : null,
          ),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await _refreshOrderPaymentStatus(orderUuid);
    });
  }

  /// Soft-delete an order-linked payment, then recompute order status.
  Future<void> deleteOrderPayment({
    required String orderUuid,
    required String paymentUuid,
  }) async {
    await _db.transaction(() async {
      final payment = await (_db.select(_db.transactions)
            ..where((t) =>
                t.uuid.equals(paymentUuid) &
                t.orderUuid.equals(orderUuid) &
                t.isOrderCost.equals(false) &
                t.isDeleted.equals(false)))
          .getSingleOrNull();
      if (payment == null) {
        throw StateError('Payment not found for this order');
      }

      await (_db.update(_db.transactions)
            ..where((t) => t.uuid.equals(paymentUuid)))
          .write(
        TransactionsCompanion(
          isDeleted: const Value(true),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await _refreshOrderPaymentStatus(orderUuid);
    });
  }

  /// Marks sale delivered (FEFO consume) or receives remaining purchase qty.
  /// Prefer [deliverSaleShipment] / qty-based receive for partial flows.
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

    // Bundle groups: deliver remaining whole packages first.
    final groups = await getGroupsForOrder(orderUuid);
    for (final g in groups) {
      final openPkgs = g.packageQty - g.deliveredPackageQty;
      if (openPkgs > 1e-9) {
        await deliverSalePackages(
          orderUuid: orderUuid,
          groupUuid: g.uuid,
          packageQty: openPkgs,
        );
      }
    }

    // Standalone (non-group) lines only.
    final items = await (_db.select(_db.orderItems)
          ..where((oi) =>
              oi.orderUuid.equals(orderUuid) & oi.isDeleted.equals(false)))
        .get();
    final lines = <({String orderItemUuid, double quantity})>[];
    for (final item in items) {
      if (item.groupUuid != null && item.groupUuid!.trim().isNotEmpty) {
        continue;
      }
      final open = item.quantity - item.deliveredQuantity;
      if (open > 1e-9) {
        lines.add((orderItemUuid: item.uuid, quantity: open));
      }
    }
    if (lines.isEmpty) return;
    await deliverSaleShipment(orderUuid: orderUuid, lines: lines);
  }

  /// Partial or full sale delivery. Consumes stock only for the given qtys.
  Future<void> deliverSaleShipment({
    required String orderUuid,
    required List<({String orderItemUuid, double quantity})> lines,
    DateTime? deliveredAt,
    String? notes,
    double? packageQty,
  }) async {
    if (lines.isEmpty) {
      throw ArgumentError('delivery lines required');
    }

    await _db.transaction(() async {
      final order = await getOrder(orderUuid);
      if (order == null) throw StateError('Order not found: $orderUuid');
      if (order.orderType != 'SALE') {
        throw StateError('Goods delivery only for sale orders');
      }
      if (order.deliveryStatus == 'CANCELLED') {
        throw StateError('Cannot deliver a cancelled order');
      }

      final orderItems = await (_db.select(_db.orderItems)
            ..where((oi) =>
                oi.orderUuid.equals(orderUuid) & oi.isDeleted.equals(false)))
          .get();
      final byId = {for (final i in orderItems) i.uuid: i};

      final deliveryUuid = const Uuid().v4();
      final when = deliveredAt ?? DateTime.now();
      await _db.into(_db.goodsDeliveries).insert(
            GoodsDeliveriesCompanion.insert(
              uuid: deliveryUuid,
              orderUuid: orderUuid,
              deliveredAt: when,
              notes: Value(notes),
            ),
          );

      for (final line in lines) {
        if (line.quantity <= 1e-9) continue;
        final item = byId[line.orderItemUuid];
        if (item == null) {
          throw StateError('Order item not found: ${line.orderItemUuid}');
        }
        final open = item.quantity - item.deliveredQuantity;
        if (line.quantity > open + 1e-9) {
          throw StateError(
            'Deliver ${line.quantity} exceeds open $open for ${item.productNameSnapshot}',
          );
        }

        final unitCogs =
            await _applySaleStockForQuantity(item, line.quantity);

        await _db.into(_db.goodsDeliveryLines).insert(
              GoodsDeliveryLinesCompanion.insert(
                uuid: const Uuid().v4(),
                deliveryUuid: deliveryUuid,
                orderItemUuid: item.uuid,
                productUuid: Value(item.productUuid),
                quantity: line.quantity,
                unitCogs: Value(unitCogs),
                packageQty: Value(packageQty),
              ),
            );

        final nextDelivered = item.deliveredQuantity + line.quantity;
        await (_db.update(_db.orderItems)
              ..where((oi) => oi.uuid.equals(item.uuid)))
            .write(
          OrderItemsCompanion(
            deliveredQuantity: Value(nextDelivered),
            isNotSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
        // Keep in-memory map fresh for multi-line same item (shouldn't happen).
        byId[item.uuid] = item.copyWith(deliveredQuantity: nextDelivered);
      }

      await _refreshSaleDeliveryStatus(orderUuid);
    });
  }

  /// Delivers whole packages for a bundle group (all components in BOM proportion).
  Future<void> deliverSalePackages({
    required String orderUuid,
    required String groupUuid,
    required double packageQty,
    DateTime? deliveredAt,
    String? notes,
  }) async {
    if (packageQty <= 1e-9) {
      throw ArgumentError('packageQty must be > 0');
    }
    // Whole packages only (allow small float noise).
    final whole = packageQty.roundToDouble();
    if ((packageQty - whole).abs() > 1e-6) {
      throw ArgumentError('Bundle dispatch must be whole packages');
    }

    await _db.transaction(() async {
      final group = await (_db.select(_db.orderLineGroups)
            ..where((g) =>
                g.uuid.equals(groupUuid) &
                g.orderUuid.equals(orderUuid) &
                g.isDeleted.equals(false)))
          .getSingleOrNull();
      if (group == null) {
        throw StateError('Order line group not found: $groupUuid');
      }
      final openPkgs = group.packageQty - group.deliveredPackageQty;
      if (whole > openPkgs + 1e-9) {
        throw StateError(
          'Deliver $whole packages exceeds open $openPkgs for ${group.nameSnapshot}',
        );
      }

      final items = await (_db.select(_db.orderItems)
            ..where((oi) =>
                oi.orderUuid.equals(orderUuid) &
                oi.groupUuid.equals(groupUuid) &
                oi.isDeleted.equals(false)))
          .get();
      if (items.isEmpty) {
        throw StateError('No lines for group $groupUuid');
      }

      final lines = <({String orderItemUuid, double quantity})>[];
      for (final item in items) {
        final perPkg = item.bundleComponentQty;
        if (perPkg == null || perPkg <= 1e-9) {
          throw StateError(
            'Missing bundleComponentQty on ${item.productNameSnapshot}',
          );
        }
        // Guard: delivered must stay a multiple of per-package qty.
        final addQty = perPkg * whole;
        final next = item.deliveredQuantity + addQty;
        final packagesAlongLine = next / perPkg;
        if ((packagesAlongLine - packagesAlongLine.roundToDouble()).abs() >
            1e-6) {
          throw StateError(
            'Delivered qty for ${item.productNameSnapshot} must stay a multiple of $perPkg',
          );
        }
        lines.add((orderItemUuid: item.uuid, quantity: addQty));
      }

      await deliverSaleShipment(
        orderUuid: orderUuid,
        lines: lines,
        deliveredAt: deliveredAt,
        notes: notes,
        packageQty: whole,
      );

      await (_db.update(_db.orderLineGroups)
            ..where((g) => g.uuid.equals(groupUuid)))
          .write(
        OrderLineGroupsCompanion(
          deliveredPackageQty: Value(group.deliveredPackageQty + whole),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> _refreshSaleDeliveryStatus(String orderUuid) async {
    final items = await (_db.select(_db.orderItems)
          ..where((oi) =>
              oi.orderUuid.equals(orderUuid) & oi.isDeleted.equals(false)))
        .get();
    if (items.isEmpty) return;

    var allDone = true;
    var anyDelivered = false;
    for (final i in items) {
      if (i.deliveredQuantity > 1e-9) anyDelivered = true;
      if (i.deliveredQuantity + 1e-9 < i.quantity) allDone = false;
    }

    final status = allDone
        ? 'DELIVERED'
        : anyDelivered
            ? 'PARTIALLY_DELIVERED'
            : 'PENDING';

    await (_db.update(_db.orders)..where((o) => o.uuid.equals(orderUuid)))
        .write(
      OrdersCompanion(
        deliveryStatus: Value(status),
        deliveredDate: Value(allDone ? DateTime.now() : null),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
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

  Future<List<OrderItem>> getItemsForOrder(String orderUuid) {
    return (_db.select(_db.orderItems)
          ..where((oi) =>
              oi.orderUuid.equals(orderUuid) & oi.isDeleted.equals(false)))
        .get();
  }

  Stream<List<OrderLineGroup>> watchGroupsForOrder(String orderUuid) {
    return (_db.select(_db.orderLineGroups)
          ..where((g) =>
              g.orderUuid.equals(orderUuid) & g.isDeleted.equals(false))
          ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
        .watch();
  }

  Future<List<OrderLineGroup>> getGroupsForOrder(String orderUuid) {
    return (_db.select(_db.orderLineGroups)
          ..where((g) =>
              g.orderUuid.equals(orderUuid) & g.isDeleted.equals(false))
          ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
        .get();
  }

  Stream<List<OrderCharge>> watchChargesForOrder(String orderUuid) {
    return (_db.select(_db.orderCharges)
          ..where((c) =>
              c.orderUuid.equals(orderUuid) & c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
        .watch();
  }

  Future<List<OrderCharge>> getChargesForOrder(String orderUuid) {
    return (_db.select(_db.orderCharges)
          ..where((c) =>
              c.orderUuid.equals(orderUuid) & c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
        .get();
  }

  /// Sale delivery history (newest first), with line names from order items.
  Stream<List<OrderShipmentView>> watchDeliveriesForOrder(String orderUuid) {
    return (_db.select(_db.goodsDeliveries)
          ..where((d) =>
              d.orderUuid.equals(orderUuid) & d.isDeleted.equals(false))
          ..orderBy([(d) => OrderingTerm.desc(d.deliveredAt)]))
        .watch()
        .asyncMap((deliveries) async {
      if (deliveries.isEmpty) return const <OrderShipmentView>[];
      final items = await getItemsForOrder(orderUuid);
      final nameByItem = {
        for (final i in items) i.uuid: i.productNameSnapshot,
      };
      final unitByItem = {for (final i in items) i.uuid: i.unit};
      final result = <OrderShipmentView>[];
      for (final delivery in deliveries) {
        final lines = await (_db.select(_db.goodsDeliveryLines)
              ..where((l) =>
                  l.deliveryUuid.equals(delivery.uuid) &
                  l.isDeleted.equals(false)))
            .get();
        result.add(
          OrderShipmentView(
            uuid: delivery.uuid,
            at: delivery.deliveredAt,
            notes: delivery.notes,
            lines: [
              for (final line in lines)
                OrderShipmentLineView(
                  productName:
                      nameByItem[line.orderItemUuid] ?? line.productUuid ?? '—',
                  quantity: line.quantity,
                  unit: unitByItem[line.orderItemUuid] ?? '',
                ),
            ],
          ),
        );
      }
      return result;
    });
  }

  /// Purchase receipt history (newest first), with line names from order items.
  Stream<List<OrderShipmentView>> watchReceiptsForOrder(String orderUuid) {
    return (_db.select(_db.goodsReceipts)
          ..where((r) =>
              r.orderUuid.equals(orderUuid) & r.isDeleted.equals(false))
          ..orderBy([(r) => OrderingTerm.desc(r.receivedAt)]))
        .watch()
        .asyncMap((receipts) async {
      if (receipts.isEmpty) return const <OrderShipmentView>[];
      final items = await getItemsForOrder(orderUuid);
      final nameByItem = {
        for (final i in items) i.uuid: i.productNameSnapshot,
      };
      final unitByItem = {for (final i in items) i.uuid: i.unit};
      final result = <OrderShipmentView>[];
      for (final receipt in receipts) {
        final lines = await (_db.select(_db.goodsReceiptLines)
              ..where((l) =>
                  l.receiptUuid.equals(receipt.uuid) &
                  l.isDeleted.equals(false)))
            .get();
        result.add(
          OrderShipmentView(
            uuid: receipt.uuid,
            at: receipt.receivedAt,
            notes: receipt.notes,
            freightAmount: receipt.freightAmount,
            dutyAmount: receipt.dutyAmount,
            lines: [
              for (final line in lines)
                OrderShipmentLineView(
                  productName:
                      nameByItem[line.orderItemUuid] ?? line.productUuid,
                  quantity: line.quantity,
                  unit: unitByItem[line.orderItemUuid] ?? '',
                ),
            ],
          ),
        );
      }
      return result;
    });
  }

  // ==========================================
  // Sale & Purchase Order Operations
  // ==========================================

  Future<void> createOrder({
    required OrdersCompanion order,
    required List<OrderItemsCompanion> items,
    List<OrderChargesCompanion> charges = const [],
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

      for (final charge in charges) {
        final desc = charge.description.present
            ? charge.description.value.trim()
            : '';
        final amount =
            charge.amount.present ? charge.amount.value : 0.0;
        if (desc.isEmpty || amount <= 0) continue;
        final now = DateTime.now();
        final chargeUuid =
            charge.uuid.present ? charge.uuid.value : const Uuid().v4();
        await _db.into(_db.orderCharges).insert(
              charge.copyWith(
                uuid: Value(chargeUuid),
                orderUuid: Value(uuid),
                description: Value(desc),
                amount: Value(amount),
                isNotSynced: const Value(true),
                createdAt:
                    charge.createdAt.present ? charge.createdAt : Value(now),
                updatedAt:
                    charge.updatedAt.present ? charge.updatedAt : Value(now),
              ),
            );
      }

      // Sales: explode selling-product / bundle picks into group + physical lines.
      final toInsert = isSale
          ? await _expandSaleItemsForInsert(
              orderUuid: uuid,
              items: itemsWithIds,
            )
          : itemsWithIds;

      final inserted = <OrderItem>[];
      for (final item in toInsert) {
        // Purchase: planned landed unit cost from PO pricing.
        // Sale: keep caller COGS (service unit cost / product WAC); FEFO
        // overwrites goods on deliver. Never stamp sell price as COGS.
        final plannedCost = planned[item.uuid.value] ?? item.unitPrice.value;
        final saleCogs = item.purchasePriceSnapshot.present
            ? item.purchasePriceSnapshot.value
            : 0.0;
        final now = DateTime.now();
        final companion = item.copyWith(
          orderUuid: Value(uuid),
          purchasePriceSnapshot: Value(isSale ? saleCogs : plannedCost),
          receivedQuantity: const Value(0.0),
          deliveredQuantity: item.deliveredQuantity.present
              ? item.deliveredQuantity
              : const Value(0.0),
          isNotSynced: const Value(true),
          // Explicit timestamps: some migrated DBs lack SQL DEFAULT on these cols.
          createdAt: item.createdAt.present ? item.createdAt : Value(now),
          updatedAt: item.updatedAt.present ? item.updatedAt : Value(now),
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
          // Whole packages for groups + remaining standalone lines.
          await markDelivered(uuid);
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
      final productUuid = item.productUuid;
      if (productUuid == null || productUuid.isEmpty) continue;
      final product = await _inventory.getProduct(productUuid);
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

    await receivePurchaseShipment(
      orderUuid: orderUuid,
      lines: lines,
      freightAmount: freightAmount,
      dutyAmount: dutyAmount,
    );
  }

  /// Partial or full purchase receive for selected line quantities.
  Future<void> receivePurchaseShipment({
    required String orderUuid,
    required List<ReceiveLineInput> lines,
    double freightAmount = 0,
    double dutyAmount = 0,
  }) {
    return _inventory.receivePurchaseShipment(
      orderUuid: orderUuid,
      lines: lines,
      freightAmount: freightAmount,
      dutyAmount: dutyAmount,
    );
  }

  /// Consume stock for [quantity] on this sale line and refresh weighted COGS.
  /// Returns shipment unit COGS for the delivery line.
  Future<double> _applySaleStockForQuantity(
    OrderItem item,
    double quantity,
  ) async {
    if (quantity <= 1e-9) return 0;

    // Legacy pre-v21 header lines (no product, selling-product ref only).
    final spUuid = item.sellingProductUuid?.trim();
    final hasProduct =
        item.productUuid != null && item.productUuid!.trim().isNotEmpty;
    if (!hasProduct && spUuid != null && spUuid.isNotEmpty) {
      return _applySellingProductSaleStock(item, spUuid, quantity);
    }

    final productUuid = item.productUuid;
    if (productUuid == null || productUuid.isEmpty) return 0;

    final product = await _inventory.getProduct(productUuid);
    if (product == null) return 0;
    if (product.isService) {
      return item.purchasePriceSnapshot;
    }

    String? batchUuid = item.batchUuid;
    double shipmentUnitCogs = item.purchasePriceSnapshot;

    if (batchUuid != null && item.deliveredQuantity <= 1e-9) {
      final batch = await _inventory.getBatch(batchUuid);
      if (batch == null) {
        throw StateError('Batch not found: $batchUuid');
      }
      await _inventory.consumeFromBatch(
        batchUuid: batchUuid,
        quantity: quantity,
      );
      shipmentUnitCogs = batch.effectiveCost;
    } else {
      final allocations = await _inventory.consumeFefo(
        productUuid: productUuid,
        quantity: quantity,
      );
      if (allocations.isEmpty) return shipmentUnitCogs;
      batchUuid = allocations.first.batchUuid;
      final costSum = allocations.fold<double>(
        0,
        (s, a) => s + a.quantity * a.effectiveCost,
      );
      shipmentUnitCogs = costSum / quantity;
    }

    final prevQty = item.deliveredQuantity;
    final prevCogs = item.purchasePriceSnapshot;
    final nextQty = prevQty + quantity;
    final weighted = nextQty > 1e-9
        ? ((prevQty * prevCogs) + (quantity * shipmentUnitCogs)) / nextQty
        : shipmentUnitCogs;

    await (_db.update(_db.orderItems)..where((oi) => oi.uuid.equals(item.uuid)))
        .write(
      OrderItemsCompanion(
        batchUuid: Value(batchUuid),
        purchasePriceSnapshot: Value(weighted),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return shipmentUnitCogs;
  }

  /// Legacy: explode selling-product components and FEFO/BATCH-consume each.
  Future<double> _applySellingProductSaleStock(
    OrderItem item,
    String sellingProductUuid,
    double quantity,
  ) async {
    final components = await (_db.select(_db.sellingProductComponents)
          ..where((c) =>
              c.sellingProductUuid.equals(sellingProductUuid) &
              c.isDeleted.equals(false)))
        .get();
    if (components.isEmpty) return item.purchasePriceSnapshot;

    var costSum = 0.0;
    for (final component in components) {
      final needQty = component.quantity * quantity;
      if (needQty <= 1e-9) continue;

      final product = await _inventory.getProduct(component.productUuid);
      if (product == null) continue;
      if (product.isService) {
        costSum += product.purchasePrice * needQty;
        continue;
      }

      final batchScope = component.consumeMode == SellingConsumeMode.batch
          ? component.batchNumber
          : null;
      final allocations = await _inventory.consumeFefo(
        productUuid: component.productUuid,
        quantity: needQty,
        batchNumber: batchScope,
      );
      for (final a in allocations) {
        costSum += a.quantity * a.effectiveCost;
      }
    }

    final shipmentUnitCogs = quantity > 1e-9 ? costSum / quantity : costSum;
    final prevQty = item.deliveredQuantity;
    final prevCogs = item.purchasePriceSnapshot;
    final nextQty = prevQty + quantity;
    final weighted = nextQty > 1e-9
        ? ((prevQty * prevCogs) + (quantity * shipmentUnitCogs)) / nextQty
        : shipmentUnitCogs;

    await (_db.update(_db.orderItems)..where((oi) => oi.uuid.equals(item.uuid)))
        .write(
      OrderItemsCompanion(
        // Multi-lot bundles: leave batchUuid null (lineage backlog 4.6).
        purchasePriceSnapshot: Value(weighted),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return shipmentUnitCogs;
  }

  /// Turns selling-product sale lines into [OrderLineGroups] + physical items.
  Future<List<OrderItemsCompanion>> _expandSaleItemsForInsert({
    required String orderUuid,
    required List<OrderItemsCompanion> items,
  }) async {
    final out = <OrderItemsCompanion>[];
    for (final item in items) {
      final spUuid = item.sellingProductUuid.present
          ? item.sellingProductUuid.value?.trim()
          : null;
      final productUuid = item.productUuid.present
          ? item.productUuid.value?.trim()
          : null;

      // Direct product (or already-expanded) line.
      if (spUuid == null || spUuid.isEmpty) {
        out.add(item);
        continue;
      }
      // Catalog pin: selling product that is a single product link may also
      // set productUuid — still explode from BOM so stock is always physical.
      final components = await (_db.select(_db.sellingProductComponents)
            ..where((c) =>
                c.sellingProductUuid.equals(spUuid) &
                c.isDeleted.equals(false)))
          .get();
      if (components.isEmpty) {
        // No BOM: keep as soft-ref line if it already has a product.
        if (productUuid != null && productUuid.isNotEmpty) {
          out.add(item.copyWith(sellingProductUuid: const Value(null)));
        } else {
          throw StateError(
            'Selling product $spUuid has no components to explode',
          );
        }
        continue;
      }

      final packageQty = item.quantity.value;
      final bundleList = item.unitPrice.value;
      final bundleDisc = item.discountedUnitPrice.present
          ? item.discountedUnitPrice.value
          : null;
      final bundleDiscountAmt =
          item.discountAmount.present ? item.discountAmount.value : 0.0;

      final sellingProduct = await (_db.select(_db.sellingProducts)
            ..where((s) =>
                s.uuid.equals(spUuid) & s.isDeleted.equals(false)))
          .getSingleOrNull();
      final spUnit = sellingProduct?.unit?.trim();
      final packageUnit =
          (spUnit != null && spUnit.isNotEmpty) ? spUnit : 'Pkg';

      final inputs = <BundleComponentInput>[];
      for (final c in components) {
        final product = await _inventory.getProduct(c.productUuid);
        if (product == null) {
          throw StateError('Component product missing: ${c.productUuid}');
        }
        inputs.add(
          BundleComponentInput(
            productUuid: product.uuid,
            productName: product.name,
            unit: product.unit,
            isService: product.isService,
            bundleComponentQty: c.quantity,
            // Simple weight for allocation — not authoritative COGS.
            individualUnitCost: product.purchasePrice,
            consumeMode: c.consumeMode,
            batchNumber: c.batchNumber,
          ),
        );
      }

      final allocated = allocateBundlePrices(
        components: inputs,
        packageQty: packageQty,
        bundleUnitPrice: bundleList,
        bundleDiscountedUnitPrice: bundleDisc,
        bundleDiscountAmount: bundleDiscountAmt,
      );
      final unitCostSnap = bundleUnitCostOf(inputs);
      final groupUuid = const Uuid().v4();
      final now = DateTime.now();
      final name = item.productNameSnapshot.value;
      final catalogName = item.catalogNameSnapshot.present
          ? item.catalogNameSnapshot.value
          : null;
      final catalogItemUuid =
          item.catalogItemUuid.present ? item.catalogItemUuid.value : null;

      await _db.into(_db.orderLineGroups).insert(
            OrderLineGroupsCompanion.insert(
              uuid: groupUuid,
              orderUuid: orderUuid,
              nameSnapshot: name,
              catalogNameSnapshot: Value(catalogName),
              catalogItemUuid: Value(catalogItemUuid),
              sellingProductUuid: Value(spUuid),
              packageQty: packageQty,
              unit: Value(packageUnit),
              unitPrice: bundleList,
              discountedUnitPrice: Value(bundleDisc),
              discountAmount: Value(bundleDiscountAmt),
              unitCostSnapshot: Value(unitCostSnap),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      for (final a in allocated) {
        if (a.quantity <= 1e-12) continue;
        out.add(
          OrderItemsCompanion.insert(
            uuid: const Uuid().v4(),
            orderUuid: orderUuid,
            productUuid: Value(a.productUuid),
            catalogItemUuid: Value(catalogItemUuid),
            sellingProductUuid: const Value(null),
            groupUuid: Value(groupUuid),
            bundleComponentQty: Value(a.bundleComponentQty),
            productNameSnapshot: a.productName,
            quantity: a.quantity,
            unitPrice: a.unitPrice,
            discountedUnitPrice: Value(a.discountedUnitPrice),
            discountAmount: Value(a.discountAmount),
            catalogNameSnapshot: Value(catalogName),
            purchasePriceSnapshot: Value(a.individualUnitCost),
            unit: Value(a.unit),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
    }
    return out;
  }

  // ==========================================
  // Returns & Refunds
  // ==========================================

  /// Returns whole packages for a sale bundle group (stock restore + refund line).
  /// Refund amount defaults to [packageQty] × group discounted package price.
  Future<void> returnSalePackages({
    required String orderUuid,
    required String groupUuid,
    required double packageQty,
    required String? accountUuid,
    DateTime? date,
    String? notes,
    double? refundAmountOverride,
  }) async {
    if (packageQty <= 1e-9) {
      throw ArgumentError('packageQty must be > 0');
    }
    final whole = packageQty.roundToDouble();
    if ((packageQty - whole).abs() > 1e-6) {
      throw ArgumentError('Bundle return must be whole packages');
    }

    await _db.transaction(() async {
      final order = await getOrder(orderUuid);
      if (order == null || order.orderType != 'SALE') {
        throw StateError('Sale order not found: $orderUuid');
      }
      final group = await (_db.select(_db.orderLineGroups)
            ..where((g) =>
                g.uuid.equals(groupUuid) &
                g.orderUuid.equals(orderUuid) &
                g.isDeleted.equals(false)))
          .getSingleOrNull();
      if (group == null) {
        throw StateError('Order line group not found: $groupUuid');
      }
      if (whole > group.deliveredPackageQty + 1e-9) {
        throw StateError(
          'Return $whole packages exceeds delivered ${group.deliveredPackageQty}',
        );
      }

      final items = await (_db.select(_db.orderItems)
            ..where((oi) =>
                oi.orderUuid.equals(orderUuid) &
                oi.groupUuid.equals(groupUuid) &
                oi.isDeleted.equals(false)))
          .get();
      if (items.isEmpty) {
        throw StateError('No lines for group $groupUuid');
      }

      final when = date ?? DateTime.now();
      final discUnit = group.discountedUnitPrice ?? group.unitPrice;
      final refund = refundAmountOverride ?? (discUnit * whole);
      final returnUuid = const Uuid().v4();
      final returnNumber =
          'RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final returnItems = <OrderReturnItemsCompanion>[];
      for (final item in items) {
        final perPkg = item.bundleComponentQty;
        if (perPkg == null || perPkg <= 1e-9) {
          throw StateError(
            'Missing bundleComponentQty on ${item.productNameSnapshot}',
          );
        }
        final qty = perPkg * whole;
        if (qty > item.deliveredQuantity + 1e-9) {
          throw StateError(
            'Return qty $qty exceeds delivered ${item.deliveredQuantity} for ${item.productNameSnapshot}',
          );
        }
        final productUuid = item.productUuid;
        if (productUuid == null || productUuid.isEmpty) continue;

        // refundUnitPrice here is inventory cost hint when restoring without a lot.
        returnItems.add(
          OrderReturnItemsCompanion.insert(
            uuid: const Uuid().v4(),
            returnUuid: returnUuid,
            productUuid: productUuid,
            quantity: qty,
            refundUnitPrice: item.purchasePriceSnapshot,
            batchUuid: Value(item.batchUuid),
          ),
        );

        await (_db.update(_db.orderItems)..where((oi) => oi.uuid.equals(item.uuid)))
            .write(
          OrderItemsCompanion(
            deliveredQuantity: Value(item.deliveredQuantity - qty),
            isNotSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      await createReturn(
        returnOrder: OrderReturnsCompanion.insert(
          uuid: returnUuid,
          returnNumber: returnNumber,
          orderType: 'SALE',
          date: when,
          contactUuid: Value(order.contactUuid),
          orderUuid: orderUuid,
          notes: Value(notes),
        ),
        returnItems: returnItems,
        refundAmount: refund,
        accountUuid: accountUuid,
      );

      await (_db.update(_db.orderLineGroups)..where((g) => g.uuid.equals(groupUuid)))
          .write(
        OrderLineGroupsCompanion(
          deliveredPackageQty: Value(group.deliveredPackageQty - whole),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      await _refreshSaleDeliveryStatus(orderUuid);
    });
  }

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
