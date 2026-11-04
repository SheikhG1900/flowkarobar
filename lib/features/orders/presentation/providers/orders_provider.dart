import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
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

final singleOrderProvider =
    FutureProvider.family<Order?, String>((ref, orderUuid) {
  return ref.watch(ordersRepositoryProvider).getOrder(orderUuid);
});

final orderPaidAmountProvider =
    FutureProvider.family<double, String>((ref, orderUuid) {
  return ref.watch(ordersRepositoryProvider).getPaidAmountForOrder(orderUuid);
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
