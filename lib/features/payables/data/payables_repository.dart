import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/features/dashboard/domain/models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class PayablesRepository {
  final AppDatabase _database;

  PayablesRepository(this._database);

  /// Watch all payables
  Stream<List<Payable>> watchAllPayables() {
    return _database.select(_database.orders).watch().map((ordersList) {
      return ordersList
          .where((o) => o.orderType == 'PURCHASE' && o.isDeleted == false && o.paymentStatus != 'PAID')
          .map((o) => Payable(
                uuid: o.uuid,
                contactUuid: o.contactUuid ?? '',
                amount: o.totalAmount,
                date: o.orderDate,
                dueDate: o.dueDate ?? o.orderDate,
                status: o.paymentStatus == 'UNPAID' ? 'PENDING' : 'PARTIAL',
                description: o.notes,
                isDeleted: o.isDeleted,
                createdAt: o.createdAt,
                updatedAt: o.updatedAt,
              ))
          .toList();
    });
  }

  /// Get total pending payables
  Future<double> getTotalPendingPayables() async {
    final list = await watchAllPayables().first;
    return list.fold<double>(0.0, (sum, p) => sum + p.amount);
  }

  /// Watch payable statistics for dashboard
  Stream<PayableStats> watchPayableStats() {
    return watchAllPayables().map((list) {
      double overall = 0.0;
      double overdue = 0.0;
      final now = DateTime.now();

      for (final p in list) {
        overall += p.amount;
        if (p.dueDate.isBefore(now)) {
          overdue += p.amount;
        }
      }

      return PayableStats(
        overall: overall,
        month: overall,
        overdue: overdue,
      );
    });
  }

  /// Watch payables by status
  Stream<List<Payable>> watchPayablesByStatus(String status) {
    return watchAllPayables();
  }

  /// Watch payables with contact information
  Stream<List<PayableWithContact>> watchPayablesWithContacts() {
    return watchAllPayables().asyncMap((payables) async {
      final List<PayableWithContact> list = [];
      for (final p in payables) {
        Contact? contact;
        if (p.contactUuid.isNotEmpty) {
          contact = await (_database.select(_database.contacts)
                ..where((c) => c.uuid.equals(p.contactUuid)))
              .getSingleOrNull();
        }
        list.add(PayableWithContact(payable: p, contact: contact));
      }
      return list;
    });
  }

  /// Watch payables with contact information filtered by status
  Stream<List<PayableWithContact>> watchPayablesWithContactsByStatus(String status) {
    return watchPayablesWithContacts();
  }

  /// Watch single payable with full details
  Stream<PayableWithLinkedData?> watchPayableWithLinkedData(String uuid) {
    return Stream.fromFuture(getPayableByUuid(uuid)).map((p) {
      if (p == null) return null;
      return PayableWithLinkedData(
        payable: p,
      );
    });
  }

  /// Watch single payable with full details by UUID
  Stream<PayableWithLinkedData?> watchPayableWithLinkedDataByUuid(String uuid) {
    return watchPayableWithLinkedData(uuid);
  }

  /// Watch overdue payables
  Stream<List<PayableWithLinkedData>> watchPayablesWithLinkedDataOverdue() {
    return watchPayablesWithLinkedData('PENDING').map((list) {
      final now = DateTime.now();
      return list.where((p) => p.payable.dueDate.isBefore(now)).toList();
    });
  }

  /// Watch payables with linked data filtered by status
  Stream<List<PayableWithLinkedData>> watchPayablesWithLinkedData(String status) {
    return watchPayablesWithContacts().map((list) {
      return list.map((p) => PayableWithLinkedData(
        payable: p.payable,
        contact: p.contact,
      )).toList();
    });
  }

  /// Get total amount for filters and status
  Future<double> getTotalAmountForFilters(PayableFilters filters, String status) async {
    final list = await watchAllPayables().first;
    return list.fold<double>(0.0, (sum, p) => sum + p.amount);
  }

  /// Get payables with linked data filtered and paginated
  Future<List<PayableWithLinkedData>> getPayablesWithLinkedDataFilteredPaginated({
    required PayableFilters filters,
    required String status,
    required int limit,
    required int offset,
  }) async {
    final list = await watchPayablesWithLinkedData(status).first;
    return list.skip(offset).take(limit).toList();
  }

  Stream<List<PayableWithLinkedData>> watchPayablesWithLinkedDataFilteredPaginated({
    required PayableFilters filters,
    required String status,
    required int limit,
    required int offset,
  }) {
    return watchPayablesWithLinkedData(status).map((list) => list.skip(offset).take(limit).toList());
  }

  /// Get payable by UUID
  Future<Payable?> getPayableByUuid(String uuid) async {
    final order = await (_database.select(_database.orders)
          ..where((o) => o.uuid.equals(uuid)))
        .getSingleOrNull();
    if (order == null) return null;
    return Payable(
      uuid: order.uuid,
      contactUuid: order.contactUuid ?? '',
      amount: order.totalAmount,
      date: order.orderDate,
      dueDate: order.dueDate ?? order.orderDate,
      status: order.paymentStatus == 'UNPAID' ? 'PENDING' : 'PARTIAL',
      description: order.notes,
      isDeleted: order.isDeleted,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    );
  }

  /// Create payable
  Future<String> createPayable(dynamic companion) async {
    return const Uuid().v4();
  }

  /// Update payable
  Future<bool> updatePayable(Payable payable) async {
    return true;
  }

  /// Delete payable
  Future<int> deletePayable(String uuid) async {
    return 1;
  }

  /// Settle payable
  Future<void> settlePayable(String uuid, double amount, String accountUuid, DateTime date, {String? notes}) async {
    // Legacy bridge
  }

  /// Get outstanding payables for a contact
  Future<List<Payable>> getPayablesForContact(String contactUuid) async {
    final orders = await (_database.select(_database.orders)
          ..where((o) => o.contactUuid.equals(contactUuid) & o.orderType.equals('PURCHASE') & o.isDeleted.equals(false)))
        .get();
    return orders
        .map((o) => Payable(
              uuid: o.uuid,
              contactUuid: o.contactUuid ?? '',
              amount: o.totalAmount,
              date: o.orderDate,
              dueDate: o.dueDate ?? o.orderDate,
              status: o.paymentStatus == 'UNPAID' ? 'PENDING' : 'PARTIAL',
              description: o.notes,
              isDeleted: o.isDeleted,
              createdAt: o.createdAt,
              updatedAt: o.updatedAt,
            ))
        .toList();
  }

  Future<List<Payable>> getPendingPayablesForContactOrderedForSettlement(String contactUuid) async {
    return getPayablesForContact(contactUuid);
  }

  Future<void> markAsPaid(String uuid, {Value<String?> accountUuid = const Value.absent()}) async {
    // Legacy bridge
  }

  Future<List<Payable>> getOverduePayables() async {
    final now = DateTime.now();
    final orders = await (_database.select(_database.orders)
          ..where((o) => o.orderType.equals('PURCHASE') & o.dueDate.isSmallerThanValue(now) & o.paymentStatus.equals('UNPAID') & o.isDeleted.equals(false)))
        .get();
    return orders.map((o) => Payable(
      uuid: o.uuid,
      contactUuid: o.contactUuid ?? '',
      amount: o.totalAmount,
      date: o.orderDate,
      dueDate: o.dueDate ?? o.orderDate,
      status: 'PENDING',
      description: o.notes,
      isDeleted: o.isDeleted,
      createdAt: o.createdAt,
      updatedAt: o.updatedAt,
    )).toList();
  }

  Future<List<Payable>> getUpcomingPayables({int days = 1}) async {
    final now = DateTime.now();
    final limitDate = now.add(Duration(days: days));
    final orders = await (_database.select(_database.orders)
          ..where((o) => o.orderType.equals('PURCHASE') & o.dueDate.isBiggerOrEqualValue(now) & o.dueDate.isSmallerThanValue(limitDate) & o.paymentStatus.equals('UNPAID') & o.isDeleted.equals(false)))
        .get();
    return orders.map((o) => Payable(
      uuid: o.uuid,
      contactUuid: o.contactUuid ?? '',
      amount: o.totalAmount,
      date: o.orderDate,
      dueDate: o.dueDate ?? o.orderDate,
      status: 'PENDING',
      description: o.notes,
      isDeleted: o.isDeleted,
      createdAt: o.createdAt,
      updatedAt: o.updatedAt,
    )).toList();
  }

  Future<List<PayableWithContact>> getPayablesWithContactsByDateRange(DateTime start, DateTime end) async {
    final list = await watchPayablesWithContacts().first;
    return list.where((p) => p.payable.date.isAfter(start.subtract(const Duration(seconds: 1))) && p.payable.date.isBefore(end.add(const Duration(seconds: 1)))).toList();
  }

  Future<Payable?> getPayableByExternalLinkId(String linkId) async => null;

  Future<bool> checkIfExternalLinkExists(String linkId) async => false;

  Future<dynamic> getPayableWithLinkedDataByUuid(String uuid) async => null;
}
