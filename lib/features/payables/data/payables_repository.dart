import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/features/dashboard/domain/models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class PayablesRepository {
  final AppDatabase _database;

  PayablesRepository(this._database);

  /// Watch all payables
  Stream<List<Payable>> watchAllPayables() {
    return (_database.select(_database.payables)
          ..where((p) => p.isDeleted.equals(false))
          ..orderBy([(p) => OrderingTerm.desc(p.date)]))
        .watch();
  }

  /// Watch payable statistics for dashboard
  Stream<PayableStats> watchPayableStats() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final overall = _watchTotalSum();
    final month = _watchTotalSum(start: startOfMonth);
    final overdue = _watchTotalSum(onlyOverdue: true);

    return Rx.combineLatest3(
      overall,
      month,
      overdue,
      (a, b, c) => PayableStats(
        overall: a,
        month: b,
        overdue: c,
      ),
    );
  }

  Stream<double> _watchTotalSum({DateTime? start, bool onlyOverdue = false}) {
    final query = _database.selectOnly(_database.payables)
      ..addColumns([_database.payables.amount.sum()])
      ..where(_database.payables.status.equals('PENDING') &
          _database.payables.isDeleted.equals(false));

    if (start != null) {
      query.where(_database.payables.date.isBiggerOrEqualValue(start));
    }

    if (onlyOverdue) {
      final now = DateTime.now();
      query.where(_database.payables.dueDate.isSmallerThanValue(now));
    }

    return query
        .watchSingle()
        .map((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
  }

  /// Watch payables by status
  Stream<List<Payable>> watchPayablesByStatus(String status) {
    return (_database.select(_database.payables)
          ..where((p) => p.status.equals(status) & p.isDeleted.equals(false))
          ..orderBy([(p) => OrderingTerm.desc(p.date)]))
        .watch();
  }

  /// Watch payables with contact information
  Stream<List<PayableWithContact>> watchPayablesWithContacts() {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
    ]);

    query.where(_database.payables.isDeleted.equals(false));

    // Default order
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return PayableWithContact(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }

  /// Watch payables with contact information filtered by status
  Stream<List<PayableWithContact>> watchPayablesWithContactsByStatus(
      String status) {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
    ]);

    query.where(_database.payables.status.equals(status) &
        _database.payables.isDeleted.equals(false));
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return PayableWithContact(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }

  /// Watch payables with ALL linked data (contact + linked transaction + linked category)
  /// This method uses JOINs to fetch all related data in a single efficient query
  Stream<List<PayableWithLinkedData>> watchPayablesWithLinkedData(
      String status) {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.payables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.payables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(_database.payables.status.equals(status) &
        _database.payables.isDeleted.equals(false));
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return PayableWithLinkedData(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Watch payable with linked data by UUID
  Stream<PayableWithLinkedData?> watchPayableWithLinkedDataByUuid(String uuid) {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.payables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.payables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(_database.payables.uuid.equals(uuid) &
        _database.payables.isDeleted.equals(false));

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final row = rows.first;
      return PayableWithLinkedData(
        payable: row.readTable(_database.payables),
        contact: row.readTableOrNull(_database.contacts),
        linkedTransaction: row.readTableOrNull(_database.transactions),
        linkedCategory: row.readTableOrNull(_database.categories),
      );
    });
  }

  /// Update payable (with companion for partial updates)
  Future<int> updatePayableWithCompanion(
      String uuid, PayablesCompanion companion) {
    return (_database.update(_database.payables)
          ..where((p) => p.uuid.equals(uuid)))
        .write(companion.copyWith(isNotSynced: const Value(true)));
  }

  /// Get payable by UUID
  Future<Payable?> getPayableByUuid(String uuid) {
    return (_database.select(_database.payables)
          ..where((p) => p.uuid.equals(uuid) & p.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Get payable with linked data by UUID
  Future<PayableWithLinkedData?> getPayableWithLinkedDataByUuid(
      String uuid) async {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.payables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.payables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(_database.payables.uuid.equals(uuid) &
        _database.payables.isDeleted.equals(false));

    final rows = await query.get();
    if (rows.isEmpty) return null;

    final row = rows.first;
    return PayableWithLinkedData(
      payable: row.readTable(_database.payables),
      contact: row.readTableOrNull(_database.contacts),
      linkedTransaction: row.readTableOrNull(_database.transactions),
      linkedCategory: row.readTableOrNull(_database.categories),
    );
  }

  /// Create payable
  Future<String> createPayable(PayablesCompanion payable) async {
    final uuid = payable.uuid.present ? payable.uuid.value : Uuid().v4();
    await _database.into(_database.payables).insert(
          payable.copyWith(
            uuid: Value(uuid),
            isNotSynced: const Value(true),
          ),
        );
    return uuid;
  }

  /// Update payable
  Future<bool> updatePayable(Payable payable) {
    return _database.update(_database.payables).replace(
          payable.copyWith(isNotSynced: true),
        );
  }

  // Delete payable
  Future<int> deletePayable(String uuid) {
    return (_database.update(_database.payables)
          ..where((p) => p.uuid.equals(uuid)))
        .write(const PayablesCompanion(
      isDeleted: Value(true),
      isNotSynced: Value(true),
    ));
  }

  /// Mark payable as paid and activate linked transaction
  Future<void> markAsPaid(String payableUuid) async {
    await _database.transaction(() async {
      final payable = await getPayableByUuid(payableUuid);
      if (payable == null) return;

      // Update payable status and store paid date
      await _database.update(_database.payables).replace(
            payable.copyWith(
              status: 'PAID',
              paidDate: Value(DateTime.now()),
              updatedAt: DateTime.now(),
              isNotSynced: true,
            ),
          );

      // Auto-create expense if enabled (for non-linked payables like PAID_FOR/RECEIVED_FROM)
      if (payable.autoCreateExpense && payable.linkedExpenseUuid == null) {
        // Use a deterministic UUID based on payable UUID to prevent duplicates during sync
        final expenseUuid = "${payableUuid}_payment";
        await _database.into(_database.transactions).insert(
              TransactionsCompanion(
                uuid: Value(expenseUuid),
                amount: Value(payable.amount),
                type: const Value('EXPENSE'),
                categoryUuid: Value(null),
                contactUuid: Value(payable.contactUuid),
                description: Value(payable.description),
                date: Value(DateTime.now()),
                linkedPayableUuid: Value(payableUuid),
                isAutoGenerated: const Value(true), // Mark as auto-generated
                externalLinkId:
                    Value(expenseUuid), // Use as external link ID as well
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
                isNotSynced: const Value(true),
              ),
              mode: InsertMode
                  .insertOrReplace, // Ensure we merge if it already exists
            );

        // Link the expense back to payable
        await _database.update(_database.payables).replace(
              payable.copyWith(
                linkedExpenseUuid: Value(expenseUuid),
                status: 'PAID',
                paidDate: Value(DateTime.now()),
                updatedAt: DateTime.now(),
                isNotSynced: true,
              ),
            );
      }
    });
  }

  /// Get total pending payables
  Future<double> getTotalPendingPayables() async {
    final query = _database.selectOnly(_database.payables)
      ..addColumns([_database.payables.amount.sum()])
      ..where(_database.payables.status.equals('PENDING') &
          _database.payables.isDeleted.equals(false));

    final result = await query.getSingle();
    return result.read(_database.payables.amount.sum()) ?? 0.0;
  }

  /// Get count of overdue payables (PENDING with dueDate < now)
  Future<int> getOverduePayablesCount() async {
    final now = DateTime.now();
    final query = _database.selectOnly(_database.payables)
      ..addColumns([_database.payables.uuid.count()])
      ..where(
        _database.payables.status.equals('PENDING') &
            _database.payables.dueDate.isNotNull() &
            _database.payables.dueDate.isSmallerThanValue(now) &
            _database.payables.isDeleted.equals(false),
      );

    final result = await query.getSingle();
    return result.read(_database.payables.uuid.count()) ?? 0;
  }

  /// Get overdue payables (PENDING with dueDate < now) - Future version
  Future<List<Payable>> getOverduePayables() async {
    final now = DateTime.now();
    return (_database.select(_database.payables)
          ..where((p) =>
              p.status.equals('PENDING') &
              p.dueDate.isNotNull() &
              p.dueDate.isSmallerThanValue(now) &
              p.isDeleted.equals(false)))
        .get();
  }

  /// Get upcoming payables (PENDING with dueDate within next N days)
  Future<List<Payable>> getUpcomingPayables({int days = 1}) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    return (_database.select(_database.payables)
          ..where((p) =>
              p.status.equals('PENDING') &
              p.dueDate.isNotNull() &
              p.dueDate.isBiggerOrEqualValue(now) &
              p.dueDate.isSmallerOrEqualValue(futureDate) &
              p.isDeleted.equals(false)))
        .get();
  }

  /// Get all PENDING payables for a contact, ordered for bulk settlement.
  ///
  /// Ordering strategy:
  /// - First by date ascending (oldest first).
  /// - The bulk-settlement service will further prioritise overdue items
  ///   (dueDate < now) by splitting this list into overdue vs non-overdue
  ///   while preserving this stable order.
  Future<List<Payable>> getPendingPayablesForContactOrderedForSettlement(
      String contactUuid) {
    final query = _database.select(_database.payables)
      ..where((p) =>
          p.contactUuid.equals(contactUuid) &
          p.status.equals('PENDING') &
          p.isDeleted.equals(false))
      ..orderBy([(p) => OrderingTerm.asc(p.date)]);
    return query.get();
  }

  /// Get payables by contact
  Stream<List<Payable>> watchPayablesByContact(String contactUuid) {
    return (_database.select(_database.payables)
          ..where((p) =>
              p.contactUuid.equals(contactUuid) & p.isDeleted.equals(false))
          ..orderBy([(p) => OrderingTerm.desc(p.date)]))
        .watch();
  }

  /// Get payable by external link ID (for shared transactions)
  Future<Payable?> getPayableByExternalLinkId(String externalLinkId) {
    return (_database.select(_database.payables)
          ..where((p) =>
              p.externalLinkId.equals(externalLinkId) &
              p.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Check if external link ID already exists
  Future<bool> checkIfExternalLinkExists(String externalLinkId) async {
    final payable = await getPayableByExternalLinkId(externalLinkId);
    return payable != null;
  }

  /// Mark payable as paid by external link ID
  Future<void> markAsPaidByExternalLinkId(String externalLinkId) async {
    final payable = await getPayableByExternalLinkId(externalLinkId);
    if (payable != null && payable.status == 'PENDING') {
      await markAsPaid(payable.uuid);
    }
  }

  /// Import payable from shared link
  Future<String> importFromSharedLink(dynamic sharedData) async {
    // Import shared data (dynamic type for flexibility with SharedData classes)
    // Extract contact ID or create contact
    String? contactUuid;

    if (sharedData.contactPhone != null &&
        sharedData.contactPhone!.isNotEmpty) {
      // Find or create contact
      final contactsRepo = ContactsRepository(_database);
      contactUuid = await contactsRepo.findOrCreateContactByPhone(
        phone: sharedData.contactPhone!,
        name: sharedData.contactName ?? 'Unknown',
      );
    }

    final uuid = sharedData.externalLinkId ?? const Uuid().v4();
    await createPayable(
      PayablesCompanion(
        uuid: Value(uuid),
        contactUuid: Value(contactUuid!),
        amount: Value(sharedData.amount),
        description: Value(sharedData.description),
        date: Value(sharedData.date),
        dueDate: Value(sharedData.dueDate),
        status: const Value('PENDING'),
        externalLinkId: Value(sharedData.externalLinkId),
        autoCreateExpense: const Value(false),
      ),
    );
    return uuid;
  }

  /// Get payables with contact information by date range
  Future<List<PayableWithContact>> getPayablesWithContactsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
    ]);

    query.where(_database.payables.date.isBetweenValues(start, end));
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);

    return query.get().then((rows) {
      return rows.map((row) {
        return PayableWithContact(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }

  /// Watch payables with ALL linked data (paginated) - Stream version
  Stream<List<PayableWithLinkedData>> watchPayablesWithLinkedDataPaginated({
    required String status,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.payables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.payables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(_database.payables.status.equals(status) &
        _database.payables.isDeleted.equals(false));
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);
    query.limit(limit, offset: offset);

    return query.watch().map((rows) {
      return rows.map((row) {
        return PayableWithLinkedData(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Get payables with ALL linked data (paginated) - Future version for loading more
  Future<List<PayableWithLinkedData>> getPayablesWithLinkedDataPaginated({
    required String status,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.payables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.payables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(_database.payables.status.equals(status) &
        _database.payables.isDeleted.equals(false));
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);
    query.limit(limit, offset: offset);

    return query.get().then((rows) {
      return rows.map((row) {
        return PayableWithLinkedData(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Watch overdue payables with ALL linked data (PENDING payables where dueDate < now)
  Stream<List<PayableWithLinkedData>> watchPayablesWithLinkedDataOverdue() {
    final now = DateTime.now();
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.payables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.payables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(
      _database.payables.status.equals('PENDING') &
          _database.payables.dueDate.isNotNull() &
          _database.payables.dueDate.isSmallerThanValue(now),
    );
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return PayableWithLinkedData(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Get overdue payables with ALL linked data (paginated) - Future version for loading more
  Future<List<PayableWithLinkedData>>
      getPayablesWithLinkedDataPaginatedOverdue({
    int limit = 50,
    int offset = 0,
  }) {
    final now = DateTime.now();
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.payables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.payables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(
      _database.payables.status.equals('PENDING') &
          _database.payables.dueDate.isNotNull() &
          _database.payables.dueDate.isSmallerThanValue(now),
    );
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);
    query.limit(limit, offset: offset);

    return query.get().then((rows) {
      return rows.map((row) {
        return PayableWithLinkedData(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Watch overdue payables with ALL linked data (paginated) - Stream version
  Stream<List<PayableWithLinkedData>>
      watchPayablesWithLinkedDataPaginatedOverdue({
    int limit = 50,
    int offset = 0,
  }) {
    final now = DateTime.now();
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.payables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.payables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(
      _database.payables.status.equals('PENDING') &
          _database.payables.dueDate.isNotNull() &
          _database.payables.dueDate.isSmallerThanValue(now),
    );
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);
    query.limit(limit, offset: offset);

    return query.watch().map((rows) {
      return rows.map((row) {
        return PayableWithLinkedData(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Total amount for current list filters and status (for list summary).
  Future<double> getTotalAmountForFilters(
      PayableFilters filters, String status) async {
    final dateField = filters.filterByDueDate
        ? _database.payables.dueDate
        : _database.payables.date;

    Expression<bool> whereExpr;
    if (status == 'OVERDUE') {
      final now = DateTime.now();
      whereExpr = _database.payables.status.equals('PENDING') &
          _database.payables.dueDate.isNotNull() &
          _database.payables.dueDate.isSmallerThanValue(now) &
          _database.payables.isDeleted.equals(false);
    } else {
      whereExpr = _database.payables.status.equals(status) &
          _database.payables.isDeleted.equals(false);
    }
    if (filters.startDate != null) {
      whereExpr = whereExpr & dateField.isBiggerOrEqualValue(filters.startDate!);
    }
    if (filters.endDate != null) {
      whereExpr = whereExpr & dateField.isSmallerOrEqualValue(filters.endDate!);
    }
    if (filters.contactUuids != null && filters.contactUuids!.isNotEmpty) {
      whereExpr =
          whereExpr & _database.payables.contactUuid.isIn(filters.contactUuids!);
    }
    if (filters.minAmount != null) {
      whereExpr = whereExpr &
          _database.payables.amount.isBiggerOrEqualValue(filters.minAmount!);
    }
    if (filters.maxAmount != null) {
      whereExpr = whereExpr &
          _database.payables.amount.isSmallerOrEqualValue(filters.maxAmount!);
    }
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      final searchPattern = '%${filters.searchQuery}%';
      whereExpr = whereExpr &
          (_database.payables.description.like(searchPattern) |
              _database.contacts.name.like(searchPattern));
    }

    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      final query = _database.selectOnly(_database.payables)
        ..addColumns([_database.payables.amount.sum()])
        ..join([
          leftOuterJoin(
            _database.contacts,
            _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
          ),
        ])
        ..where(whereExpr);
      final row = await query.getSingle();
      return row.read(_database.payables.amount.sum()) ?? 0.0;
    }
    final query = _database.selectOnly(_database.payables)
      ..addColumns([_database.payables.amount.sum()])
      ..where(whereExpr);
    final row = await query.getSingle();
    return row.read(_database.payables.amount.sum()) ?? 0.0;
  }

  /// Get payables with details (filtered and paginated) - Future version
  Future<List<PayableWithLinkedData>>
      getPayablesWithLinkedDataFilteredPaginated({
    required PayableFilters filters,
    required String status,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.payables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.payables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    if (status == 'OVERDUE') {
      final now = DateTime.now();
      query.where(
        _database.payables.status.equals('PENDING') &
            _database.payables.dueDate.isNotNull() &
            _database.payables.dueDate.isSmallerThanValue(now) &
            _database.payables.isDeleted.equals(false),
      );
    } else {
      query.where(_database.payables.status.equals(status) &
          _database.payables.isDeleted.equals(false));
    }

    final dateField = filters.filterByDueDate
        ? _database.payables.dueDate
        : _database.payables.date;
    if (filters.startDate != null) {
      query.where(dateField.isBiggerOrEqualValue(filters.startDate!));
    }
    if (filters.endDate != null) {
      query.where(dateField.isSmallerOrEqualValue(filters.endDate!));
    }
    if (filters.contactUuids != null && filters.contactUuids!.isNotEmpty) {
      query.where(_database.payables.contactUuid.isIn(filters.contactUuids!));
    }
    if (filters.minAmount != null) {
      query.where(
          _database.payables.amount.isBiggerOrEqualValue(filters.minAmount!));
    }
    if (filters.maxAmount != null) {
      query.where(
          _database.payables.amount.isSmallerOrEqualValue(filters.maxAmount!));
    }

    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      final searchPattern = '%${filters.searchQuery}%';
      query.where(
        _database.payables.description.like(searchPattern) |
            _database.contacts.name.like(searchPattern),
      );
    }

    query.orderBy([OrderingTerm.desc(_database.payables.date)]);
    query.limit(limit, offset: offset);

    return query.get().then((rows) {
      return rows.map((row) {
        return PayableWithLinkedData(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Watch payables with details (filtered and paginated) - Stream version
  Stream<List<PayableWithLinkedData>>
      watchPayablesWithLinkedDataFilteredPaginated({
    required PayableFilters filters,
    required String status,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.payables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.payables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.payables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    if (status == 'OVERDUE') {
      final now = DateTime.now();
      query.where(
        _database.payables.status.equals('PENDING') &
            _database.payables.dueDate.isNotNull() &
            _database.payables.dueDate.isSmallerThanValue(now) &
            _database.payables.isDeleted.equals(false),
      );
    } else {
      query.where(_database.payables.status.equals(status) &
          _database.payables.isDeleted.equals(false));
    }

    final dateField = filters.filterByDueDate
        ? _database.payables.dueDate
        : _database.payables.date;
    if (filters.startDate != null) {
      query.where(dateField.isBiggerOrEqualValue(filters.startDate!));
    }
    if (filters.endDate != null) {
      query.where(dateField.isSmallerOrEqualValue(filters.endDate!));
    }
    if (filters.contactUuids != null && filters.contactUuids!.isNotEmpty) {
      query.where(_database.payables.contactUuid.isIn(filters.contactUuids!));
    }
    if (filters.minAmount != null) {
      query.where(
          _database.payables.amount.isBiggerOrEqualValue(filters.minAmount!));
    }
    if (filters.maxAmount != null) {
      query.where(
          _database.payables.amount.isSmallerOrEqualValue(filters.maxAmount!));
    }

    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      final searchPattern = '%${filters.searchQuery}%';
      query.where(
        _database.payables.description.like(searchPattern) |
            _database.contacts.name.like(searchPattern),
      );
    }

    query.orderBy([OrderingTerm.desc(_database.payables.date)]);
    query.limit(limit, offset: offset);

    return query.watch().map((rows) {
      return rows.map((row) {
        return PayableWithLinkedData(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }
}

/// Data class for payable with contact information
class PayableWithContact {
  final Payable payable;
  final Contact? contact;

  PayableWithContact({
    required this.payable,
    this.contact,
  });
}
