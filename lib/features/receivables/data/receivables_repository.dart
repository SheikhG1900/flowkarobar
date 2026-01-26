import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:flowpaisa/features/receivables/domain/models.dart';
import 'package:flowpaisa/features/dashboard/domain/models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class ReceivablesRepository {
  final AppDatabase _database;

  ReceivablesRepository(this._database);

  /// Watch all receivables
  Stream<List<Receivable>> watchAllReceivables() {
    return (_database.select(_database.receivables)
          ..orderBy([(r) => OrderingTerm.desc(r.date)]))
        .watch();
  }

  /// Watch receivable statistics for dashboard
  Stream<ReceivableStats> watchReceivableStats() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final overall = _watchTotalSum();
    final month = _watchTotalSum(start: startOfMonth);
    final overdue = _watchTotalSum(onlyOverdue: true);

    return Rx.combineLatest3(
      overall,
      month,
      overdue,
      (a, b, c) => ReceivableStats(
        overall: a,
        month: b,
        overdue: c,
      ),
    );
  }

  Stream<double> _watchTotalSum({DateTime? start, bool onlyOverdue = false}) {
    final query = _database.selectOnly(_database.receivables)
      ..addColumns([_database.receivables.amount.sum()])
      ..where(_database.receivables.status.equals('PENDING'));

    if (start != null) {
      query.where(_database.receivables.date.isBiggerOrEqualValue(start));
    }

    if (onlyOverdue) {
      final now = DateTime.now();
      query.where(_database.receivables.dueDate.isSmallerThanValue(now));
    }

    return query
        .watchSingle()
        .map((row) => row.read(_database.receivables.amount.sum()) ?? 0.0);
  }

  /// Watch receivables by status
  Stream<List<Receivable>> watchReceivablesByStatus(String status) {
    return (_database.select(_database.receivables)
          ..where((r) => r.status.equals(status))
          ..orderBy([(r) => OrderingTerm.desc(r.date)]))
        .watch();
  }

  /// Watch receivables with contact information
  Stream<List<ReceivableWithContact>> watchReceivablesWithContacts() {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.receivables.contactUuid),
      ),
    ]);

    // Default order
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReceivableWithContact(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }

  /// Watch receivables with contact information filtered by status
  Stream<List<ReceivableWithContact>> watchReceivablesWithContactsByStatus(
      String status) {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.receivables.contactUuid),
      ),
    ]);

    query.where(_database.receivables.status.equals(status));
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReceivableWithContact(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }

  /// Watch receivables with ALL linked data (contact + linked transaction + linked category)
  /// This method uses JOINs to fetch all related data in a single efficient query
  Stream<List<ReceivableWithLinkedData>> watchReceivablesWithLinkedData(
      String status) {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.receivables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.receivables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.receivables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid.equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(_database.receivables.status.equals(status));
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReceivableWithLinkedData(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Update receivable (with companion for partial updates)
  Future<int> updateReceivableWithCompanion(
      String uuid, ReceivablesCompanion companion) {
    return (_database.update(_database.receivables)
          ..where((r) => r.uuid.equals(uuid)))
        .write(companion);
  }

  /// Get receivable by UUID
  Future<Receivable?> getReceivableByUuid(String uuid) {
    return (_database.select(_database.receivables)
          ..where((r) => r.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  /// Get receivable with linked data by UUID
  Future<ReceivableWithLinkedData?> getReceivableWithLinkedDataByUuid(
      String uuid) async {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.receivables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.receivables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.receivables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid.equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(_database.receivables.uuid.equals(uuid));

    final rows = await query.get();
    if (rows.isEmpty) return null;

    final row = rows.first;
    return ReceivableWithLinkedData(
      receivable: row.readTable(_database.receivables),
      contact: row.readTableOrNull(_database.contacts),
      linkedTransaction: row.readTableOrNull(_database.transactions),
      linkedCategory: row.readTableOrNull(_database.categories),
    );
  }

  /// Create receivable
  Future<String> createReceivable(ReceivablesCompanion receivable) async {
    final uuid = receivable.uuid.present ? receivable.uuid.value : Uuid().v4();
    await _database.into(_database.receivables).insert(
          receivable.copyWith(
            uuid: Value(uuid),
            isNotSynced: const Value(true),
          ),
        );
    return uuid;
  }

  /// Update receivable
  Future<bool> updateReceivable(Receivable receivable) {
    return _database.update(_database.receivables).replace(
          receivable.copyWith(isNotSynced: true),
        );
  }

  // Delete receivable
  Future<int> deleteReceivable(String uuid) {
    return (_database.update(_database.receivables)..where((r) => r.uuid.equals(uuid)))
        .write(const ReceivablesCompanion(
          isDeleted: Value(true),
          isNotSynced: Value(true),
        ));
  }

  /// Mark receivable as received and activate linked transaction
  Future<void> markAsReceived(String receivableUuid) async {
    await _database.transaction(() async {
      final receivable = await getReceivableByUuid(receivableUuid);
      if (receivable == null) return;

      // Update receivable status and store received date
      await _database.update(_database.receivables).replace(
            receivable.copyWith(
              status: 'RECEIVED',
              receivedDate: Value(DateTime.now()),
              updatedAt: DateTime.now(),
              isNotSynced: true,
            ),
          );

      // Auto-create income if enabled (for PAID_FOR receivables and standalone receivables)
      // Skip if linkedIncomeUuid exists (WILL_RECEIVE case - already has linked income)
      if (receivable.autoCreateIncome && receivable.linkedIncomeUuid == null) {
        // Use a deterministic UUID based on receivable UUID to prevent duplicates during sync
        final incomeUuid = "${receivableUuid}_payment";
        await _database.into(_database.transactions).insert(
              TransactionsCompanion(
                uuid: Value(incomeUuid),
                amount: Value(receivable.amount),
                type: const Value('INCOME'),
                categoryUuid: Value(null),
                contactUuid: Value(receivable.contactUuid),
                description: Value(receivable.description),
                date: Value(DateTime.now()),
                linkedReceivableUuid: Value(receivableUuid),
                isAutoGenerated: const Value(true), // Mark as auto-generated
                externalLinkId: Value(incomeUuid), // Use as external link ID as well
                createdAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
                isNotSynced: const Value(true),
              ),
              mode: InsertMode.insertOrReplace, // Ensure we merge if it already exists
            );

        // Link the income back to receivable
        await _database.update(_database.receivables).replace(
              receivable.copyWith(
                linkedIncomeUuid: Value(incomeUuid),
                status: 'RECEIVED',
                receivedDate: Value(DateTime.now()),
                updatedAt: DateTime.now(),
                isNotSynced: true,
              ),
            );
      }
    });
  }

  /// Get total pending receivables
  Future<double> getTotalPendingReceivables() async {
    final query = _database.selectOnly(_database.receivables)
      ..addColumns([_database.receivables.amount.sum()])
      ..where(_database.receivables.status.equals('PENDING'));

    final result = await query.getSingle();
    return result.read(_database.receivables.amount.sum()) ?? 0.0;
  }

  /// Get count of overdue receivables (PENDING with dueDate < now)
  Future<int> getOverdueReceivablesCount() async {
    final now = DateTime.now();
    final query = _database.selectOnly(_database.receivables)
      ..addColumns([_database.receivables.uuid.count()])
      ..where(
        _database.receivables.status.equals('PENDING') &
        _database.receivables.dueDate.isNotNull() &
        _database.receivables.dueDate.isSmallerThanValue(now),
      );

    final result = await query.getSingle();
    return result.read(_database.receivables.uuid.count()) ?? 0;
  }

  /// Get overdue receivables (PENDING with dueDate < now) - Future version
  Future<List<Receivable>> getOverdueReceivables() async {
    final now = DateTime.now();
    return (_database.select(_database.receivables)
          ..where((r) =>
              r.status.equals('PENDING') &
              r.dueDate.isNotNull() &
              r.dueDate.isSmallerThanValue(now)))
        .get();
  }

  /// Get upcoming receivables (PENDING with dueDate within next N days)
  Future<List<Receivable>> getUpcomingReceivables({int days = 1}) async {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    return (_database.select(_database.receivables)
          ..where((r) =>
              r.status.equals('PENDING') &
              r.dueDate.isNotNull() &
              r.dueDate.isBiggerOrEqualValue(now) &
              r.dueDate.isSmallerOrEqualValue(futureDate)))
        .get();
  }

  /// Get receivables by contact
  Stream<List<Receivable>> watchReceivablesByContact(String contactUuid) {
    return (_database.select(_database.receivables)
          ..where((r) => r.contactUuid.equals(contactUuid))
          ..orderBy([(r) => OrderingTerm.desc(r.date)]))
        .watch();
  }

  /// Get receivable by external link ID (for shared transactions)
  Future<Receivable?> getReceivableByExternalLinkId(String externalLinkId) {
    return (_database.select(_database.receivables)
          ..where((r) => r.externalLinkId.equals(externalLinkId)))
        .getSingleOrNull();
  }

  /// Check if external link ID already exists
  Future<bool> checkIfExternalLinkExists(String externalLinkId) async {
    final receivable = await getReceivableByExternalLinkId(externalLinkId);
    return receivable != null;
  }

  /// Mark receivable as received by external link ID
  Future<void> markAsReceivedByExternalLinkId(String externalLinkId) async {
    final receivable = await getReceivableByExternalLinkId(externalLinkId);
    if (receivable != null && receivable.status == 'PENDING') {
      await markAsReceived(receivable.uuid);
    }
  }

  /// Import receivable from shared link
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
    await createReceivable(
      ReceivablesCompanion(
        uuid: Value(uuid),
        contactUuid: Value(contactUuid!),
        amount: Value(sharedData.amount),
        description: Value(sharedData.description),
        date: Value(sharedData.date),
        dueDate: Value(sharedData.dueDate),
        status: const Value('PENDING'),
        externalLinkId: Value(sharedData.externalLinkId),
        autoCreateIncome: const Value(true),
      ),
    );
    return uuid;
  }

  /// Get receivables with contact information by date range
  Future<List<ReceivableWithContact>> getReceivablesWithContactsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.receivables.contactUuid),
      ),
    ]);

    query.where(_database.receivables.date.isBetweenValues(start, end));
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);

    return query.get().then((rows) {
      return rows.map((row) {
        return ReceivableWithContact(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }

  /// Watch receivables with ALL linked data (paginated) - Stream version
  Stream<List<ReceivableWithLinkedData>>
      watchReceivablesWithLinkedDataPaginated({
    required String status,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.receivables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.receivables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.receivables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid.equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(_database.receivables.status.equals(status));
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);
    query.limit(limit, offset: offset);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReceivableWithLinkedData(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Get receivables with ALL linked data (paginated) - Future version for loading more
  Future<List<ReceivableWithLinkedData>> getReceivablesWithLinkedDataPaginated({
    required String status,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.receivables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.receivables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.receivables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid.equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(_database.receivables.status.equals(status));
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);
    query.limit(limit, offset: offset);

    return query.get().then((rows) {
      return rows.map((row) {
        return ReceivableWithLinkedData(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Watch overdue receivables with ALL linked data (PENDING receivables where dueDate < now)
  Stream<List<ReceivableWithLinkedData>>
      watchReceivablesWithLinkedDataOverdue() {
    final now = DateTime.now();
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.receivables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.receivables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.receivables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid.equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(
      _database.receivables.status.equals('PENDING') &
          _database.receivables.dueDate.isNotNull() &
          _database.receivables.dueDate.isSmallerThanValue(now),
    );
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReceivableWithLinkedData(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Get overdue receivables with ALL linked data (paginated) - Future version for loading more
  Future<List<ReceivableWithLinkedData>>
      getReceivablesWithLinkedDataPaginatedOverdue({
    int limit = 50,
    int offset = 0,
  }) {
    final now = DateTime.now();
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.receivables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.receivables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.receivables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid.equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(
      _database.receivables.status.equals('PENDING') &
          _database.receivables.dueDate.isNotNull() &
          _database.receivables.dueDate.isSmallerThanValue(now),
    );
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);
    query.limit(limit, offset: offset);

    return query.get().then((rows) {
      return rows.map((row) {
        return ReceivableWithLinkedData(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Watch overdue receivables with ALL linked data (paginated) - Stream version
  Stream<List<ReceivableWithLinkedData>>
      watchReceivablesWithLinkedDataPaginatedOverdue({
    int limit = 50,
    int offset = 0,
  }) {
    final now = DateTime.now();
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.receivables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.receivables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.receivables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid.equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    query.where(
      _database.receivables.status.equals('PENDING') &
          _database.receivables.dueDate.isNotNull() &
          _database.receivables.dueDate.isSmallerThanValue(now),
    );
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);
    query.limit(limit, offset: offset);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReceivableWithLinkedData(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Get receivables with details (filtered and paginated) - Future version
  Future<List<ReceivableWithLinkedData>> getReceivablesWithLinkedDataFilteredPaginated({
    required ReceivableFilters filters,
    required String status,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.receivables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.receivables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.receivables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid.equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    if (status == 'OVERDUE') {
      final now = DateTime.now();
      query.where(
        _database.receivables.status.equals('PENDING') &
            _database.receivables.dueDate.isNotNull() &
            _database.receivables.dueDate.isSmallerThanValue(now),
      );
    } else {
      query.where(_database.receivables.status.equals(status));
    }

    final dateField = filters.filterByDueDate ? _database.receivables.dueDate : _database.receivables.date;
    if (filters.startDate != null) {
      query.where(dateField.isBiggerOrEqualValue(filters.startDate!));
    }
    if (filters.endDate != null) {
      query.where(dateField.isSmallerOrEqualValue(filters.endDate!));
    }
    if (filters.contactUuids != null && filters.contactUuids!.isNotEmpty) {
      query.where(_database.receivables.contactUuid.isIn(filters.contactUuids!));
    }
    if (filters.minAmount != null) {
      query.where(_database.receivables.amount.isBiggerOrEqualValue(filters.minAmount!));
    }
    if (filters.maxAmount != null) {
      query.where(_database.receivables.amount.isSmallerOrEqualValue(filters.maxAmount!));
    }

    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      final searchPattern = '%${filters.searchQuery}%';
      query.where(
        _database.receivables.description.like(searchPattern) |
            _database.contacts.name.like(searchPattern),
      );
    }

    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);
    query.limit(limit, offset: offset);

    return query.get().then((rows) {
      return rows.map((row) {
        return ReceivableWithLinkedData(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Watch receivables with details (filtered and paginated) - Stream version
  Stream<List<ReceivableWithLinkedData>> watchReceivablesWithLinkedDataFilteredPaginated({
    required ReceivableFilters filters,
    required String status,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.receivables.contactUuid),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.uuid
                .equalsExp(_database.receivables.linkedExpenseUuid) |
            _database.transactions.uuid
                .equalsExp(_database.receivables.linkedIncomeUuid),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid.equalsExp(_database.transactions.categoryUuid),
      ),
    ]);

    if (status == 'OVERDUE') {
      final now = DateTime.now();
      query.where(
        _database.receivables.status.equals('PENDING') &
            _database.receivables.dueDate.isNotNull() &
            _database.receivables.dueDate.isSmallerThanValue(now),
      );
    } else {
      query.where(_database.receivables.status.equals(status));
    }

    final dateField = filters.filterByDueDate ? _database.receivables.dueDate : _database.receivables.date;
    if (filters.startDate != null) {
      query.where(dateField.isBiggerOrEqualValue(filters.startDate!));
    }
    if (filters.endDate != null) {
      query.where(dateField.isSmallerOrEqualValue(filters.endDate!));
    }
    if (filters.contactUuids != null && filters.contactUuids!.isNotEmpty) {
      query.where(_database.receivables.contactUuid.isIn(filters.contactUuids!));
    }
    if (filters.minAmount != null) {
      query.where(_database.receivables.amount.isBiggerOrEqualValue(filters.minAmount!));
    }
    if (filters.maxAmount != null) {
      query.where(_database.receivables.amount.isSmallerOrEqualValue(filters.maxAmount!));
    }

    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      final searchPattern = '%${filters.searchQuery}%';
      query.where(
        _database.receivables.description.like(searchPattern) |
            _database.contacts.name.like(searchPattern),
      );
    }

    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);
    query.limit(limit, offset: offset);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReceivableWithLinkedData(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }
}

/// Data class for receivable with contact information
class ReceivableWithContact {
  final Receivable receivable;
  final Contact? contact;

  ReceivableWithContact({
    required this.receivable,
    this.contact,
  });
}
