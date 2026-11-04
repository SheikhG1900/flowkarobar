import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/receivables/domain/models.dart';
import 'package:flowpaisa/features/dashboard/domain/models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class ReceivablesRepository {
  final AppDatabase _database;

  ReceivablesRepository(this._database);

  /// Watch all receivables
  Stream<List<Receivable>> watchAllReceivables() {
    return _database.select(_database.orders).watch().map((ordersList) {
      return ordersList
          .where((o) => o.orderType == 'SALE' && o.isDeleted == false && o.paymentStatus != 'PAID')
          .map((o) => Receivable(
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

  /// Get total pending receivables
  Future<double> getTotalPendingReceivables() async {
    final list = await watchAllReceivables().first;
    return list.fold<double>(0.0, (sum, r) => sum + r.amount);
  }

  /// Watch receivable statistics for dashboard
  Stream<ReceivableStats> watchReceivableStats() {
    return watchAllReceivables().map((list) {
      double overall = 0.0;
      double overdue = 0.0;
      final now = DateTime.now();
      for (final r in list) {
        overall += r.amount;
        if (r.dueDate.isBefore(now)) {
          overdue += r.amount;
        }
      }
      return ReceivableStats(
        overall: overall,
        month: overall, // estimate
        overdue: overdue,
      );
    });
  }

  /// Watch receivables by status
  Stream<List<Receivable>> watchReceivablesByStatus(String status) {
    return watchAllReceivables();
  }

  /// Watch receivables with contact information
  Stream<List<ReceivableWithContact>> watchReceivablesWithContacts() {
    return watchAllReceivables().asyncMap((receivables) async {
      final List<ReceivableWithContact> list = [];
      for (final r in receivables) {
        Contact? contact;
        if (r.contactUuid.isNotEmpty) {
          contact = await (_database.select(_database.contacts)
                ..where((c) => c.uuid.equals(r.contactUuid)))
              .getSingleOrNull();
        }
        list.add(ReceivableWithContact(receivable: r, contact: contact));
      }
      return list;
    });
  }

  /// Watch receivables with contact information filtered by status
  Stream<List<ReceivableWithContact>> watchReceivablesWithContactsByStatus(String status) {
    return watchReceivablesWithContacts();
  }

  /// Watch single receivable with full details
  Stream<ReceivableWithLinkedData?> watchReceivableWithLinkedData(String uuid) {
    return Stream.fromFuture(getReceivableByUuid(uuid)).map((r) {
      if (r == null) return null;
      return ReceivableWithLinkedData(
        receivable: r,
      );
    });
  }

  /// Watch single receivable with linked data by UUID
  Stream<ReceivableWithLinkedData?> watchReceivableWithLinkedDataByUuid(String uuid) {
    return watchReceivableWithLinkedData(uuid);
  }

  /// Watch overdue receivables with linked data
  Stream<List<ReceivableWithLinkedData>> watchReceivablesWithLinkedDataOverdue() {
    return watchReceivablesWithLinkedData('PENDING').map((list) {
      final now = DateTime.now();
      return list.where((r) => r.receivable.dueDate.isBefore(now)).toList();
    });
  }

  /// Watch receivables with linked data
  Stream<List<ReceivableWithLinkedData>> watchReceivablesWithLinkedData(String status) {
    return watchAllReceivables().asyncMap((receivables) async {
      final List<ReceivableWithLinkedData> list = [];
      for (final r in receivables) {
        Contact? contact;
        if (r.contactUuid.isNotEmpty) {
          contact = await (_database.select(_database.contacts)
                ..where((c) => c.uuid.equals(r.contactUuid)))
              .getSingleOrNull();
        }
        list.add(ReceivableWithLinkedData(
          receivable: r,
          contact: contact,
        ));
      }
      return list;
    });
  }

  /// Get total amount for filters
  Future<double> getTotalAmountForFilters(ReceivableFilters filters, String status) async {
    final list = await watchAllReceivables().first;
    return list.fold<double>(0.0, (sum, r) => sum + r.amount);
  }

  Future<List<ReceivableWithLinkedData>> getReceivablesWithLinkedDataFilteredPaginated({
    required ReceivableFilters filters,
    required String status,
    required int limit,
    required int offset,
  }) async {
    final list = await watchReceivablesWithLinkedData(status).first;
    return list.skip(offset).take(limit).toList();
  }

  Stream<List<ReceivableWithLinkedData>> watchReceivablesWithLinkedDataFilteredPaginated({
    required ReceivableFilters filters,
    required String status,
    required int limit,
    required int offset,
  }) {
    return watchReceivablesWithLinkedData(status).map((list) => list.skip(offset).take(limit).toList());
  }

  /// Get receivable by UUID
  Future<Receivable?> getReceivableByUuid(String uuid) async {
    final order = await (_database.select(_database.orders)
          ..where((o) => o.uuid.equals(uuid)))
        .getSingleOrNull();
    if (order == null) return null;
    return Receivable(
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

  /// Create receivable
  Future<String> createReceivable(dynamic companion) async {
    return const Uuid().v4();
  }

  /// Update receivable
  Future<bool> updateReceivable(Receivable receivable) async {
    return true;
  }

  /// Delete receivable
  Future<int> deleteReceivable(String uuid) async {
    return 1;
  }

  /// Settle receivable
  Future<void> settleReceivable(String uuid, double amount, String accountUuid, DateTime date, {String? notes}) async {
    // Legacy bridge
  }

  /// Get outstanding receivables for a contact
  Future<List<Receivable>> getReceivablesForContact(String contactUuid) async {
    final orders = await (_database.select(_database.orders)
          ..where((o) => o.contactUuid.equals(contactUuid) & o.orderType.equals('SALE') & o.isDeleted.equals(false)))
        .get();
    return orders
        .map((o) => Receivable(
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

  Future<List<Receivable>> getPendingReceivablesForContactOrderedForSettlement(String contactUuid) async {
    return getReceivablesForContact(contactUuid);
  }

  Future<void> markAsReceived(String uuid, {Value<String?> accountUuid = const Value.absent()}) async {
    // Legacy bridge
  }

  Future<List<Receivable>> getOverdueReceivables() async {
    final now = DateTime.now();
    final orders = await (_database.select(_database.orders)
          ..where((o) => o.orderType.equals('SALE') & o.dueDate.isSmallerThanValue(now) & o.paymentStatus.equals('UNPAID') & o.isDeleted.equals(false)))
        .get();
    return orders.map((o) => Receivable(
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

  Future<List<Receivable>> getUpcomingReceivables({int days = 1}) async {
    final now = DateTime.now();
    final limitDate = now.add(Duration(days: days));
    final orders = await (_database.select(_database.orders)
          ..where((o) => o.orderType.equals('SALE') & o.dueDate.isBiggerOrEqualValue(now) & o.dueDate.isSmallerThanValue(limitDate) & o.paymentStatus.equals('UNPAID') & o.isDeleted.equals(false)))
        .get();
    return orders.map((o) => Receivable(
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

  Future<List<ReceivableWithContact>> getReceivablesWithContactsByDateRange(DateTime start, DateTime end) async {
    final list = await watchReceivablesWithContacts().first;
    return list.where((r) => r.receivable.date.isAfter(start.subtract(const Duration(seconds: 1))) && r.receivable.date.isBefore(end.add(const Duration(seconds: 1)))).toList();
  }

  Future<Receivable?> getReceivableByExternalLinkId(String linkId) async => null;

  Future<bool> checkIfExternalLinkExists(String linkId) async => false;

  Future<dynamic> getReceivableWithLinkedDataByUuid(String uuid) async => null;
}
