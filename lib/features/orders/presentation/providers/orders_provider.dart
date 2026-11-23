import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/orders/data/orders_repository.dart';
import 'package:flowpaisa/features/orders/data/invoice_pdf_service.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return OrdersRepository(db);
});

final invoicePdfServiceProvider = Provider<InvoicePdfService>((ref) {
  final db = ref.watch(databaseProvider);
  return InvoicePdfService(db);
});

final allOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(ordersRepositoryProvider).watchAllOrders();
});

final ordersByTypeStreamProvider =
    StreamProvider.family<List<Order>, String>((ref, orderType) {
  return ref.watch(ordersRepositoryProvider).watchOrdersByType(orderType);
});

final allReturnsStreamProvider = StreamProvider<List<OrderReturn>>((ref) {
  return ref.watch(ordersRepositoryProvider).watchAllReturns();
});

final todayOrdersStreamProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(ordersRepositoryProvider).watchTodayOrders();
});

final ordersForContactStreamProvider =
    StreamProvider.family<List<Order>, String>((ref, contactUuid) {
  return ref
      .watch(ordersRepositoryProvider)
      .watchOrdersForContact(contactUuid);
});

final orderItemsStreamProvider =
    StreamProvider.family<List<OrderItem>, String>((ref, orderUuid) {
  return ref.watch(ordersRepositoryProvider).watchItemsForOrder(orderUuid);
});

/// Fulfillable stock per sale line, resolved once per order open (not on qty edits).
final orderItemFulfillableQtyProvider =
    FutureProvider.family<Map<String, double?>, String>((ref, orderUuid) async {
  final ordersRepo = ref.watch(ordersRepositoryProvider);
  final order = await ordersRepo.getOrder(orderUuid);
  if (order == null || order.orderType != 'SALE') {
    return const <String, double?>{};
  }
  final items = await ordersRepo.getItemsForOrder(orderUuid);
  final inventory = ref.watch(inventoryRepositoryProvider);
  final result = <String, double?>{};
  for (final item in items) {
    // Heuristic: treat as service when no product/selling-product stock apply.
    final available = await inventory.fulfillableSaleQuantity(
      productUuid: item.productUuid,
      sellingProductUuid: item.sellingProductUuid,
    );
    result[item.uuid] = available;
  }
  return result;
});

final orderChargesStreamProvider =
    StreamProvider.family<List<OrderCharge>, String>((ref, orderUuid) {
  return ref.watch(ordersRepositoryProvider).watchChargesForOrder(orderUuid);
});

final singleOrderProvider =
    FutureProvider.family<Order?, String>((ref, orderUuid) {
  return ref.watch(ordersRepositoryProvider).getOrder(orderUuid);
});

final orderPaidAmountProvider =
    FutureProvider.family<double, String>((ref, orderUuid) {
  return ref.watch(ordersRepositoryProvider).getPaidAmountForOrder(orderUuid);
});

final orderPaymentsStreamProvider =
    StreamProvider.family<List<Transaction>, String>((ref, orderUuid) {
  return ref.watch(ordersRepositoryProvider).watchPaymentsForOrder(orderUuid);
});

final orderCostsStreamProvider =
    StreamProvider.family<List<Transaction>, String>((ref, orderUuid) {
  return ref.watch(ordersRepositoryProvider).watchOrderCostsForOrder(orderUuid);
});

/// Open sales = to collect; open purchases = to pay.
final openSalesOrdersProvider = Provider<AsyncValue<List<Order>>>((ref) {
  return ref.watch(ordersByTypeStreamProvider('SALE')).whenData(
        (list) => list.where((o) => o.paymentStatus != 'PAID').toList(),
      );
});

final openPurchaseOrdersProvider = Provider<AsyncValue<List<Order>>>((ref) {
  return ref.watch(ordersByTypeStreamProvider('PURCHASE')).whenData(
        (list) => list.where((o) => o.paymentStatus != 'PAID').toList(),
      );
});
