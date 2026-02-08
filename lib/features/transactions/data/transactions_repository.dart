import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/dashboard/domain/models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class TransactionsRepository {
  final AppDatabase _database;

  TransactionsRepository(this._database);

  // Get all transactions
  Stream<List<Transaction>> watchAllTransactions() {
    return (_database.select(_database.transactions)
          ..where((t) => t.isDeleted.equals(false)))
        .watch();
  }

  // Watch recent transactions
  Stream<List<Transaction>> watchRecentTransactions({int limit = 5}) {
    // We explicitly include the table in the stream to ensure Drift's
    // invalidation logic picks it up even after raw SQL updates
    return (_database.select(_database.transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.date),
            (t) => OrderingTerm.desc(t.createdAt)
          ])
          ..limit(limit))
        .watch();
  }

  // Watch transaction statistics for dashboard
  Stream<TransactionStats> watchTransactionStats() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final incomeOverall = _watchTotalSum(type: 'INCOME');
    final incomeMonth = _watchTotalSum(type: 'INCOME', start: startOfMonth);
    final expenseOverall = _watchTotalSum(type: 'EXPENSE');
    final expenseMonth = _watchTotalSum(type: 'EXPENSE', start: startOfMonth);
    final cashIncome =
        _watchTotalSum(type: 'INCOME', excludePaidRelationship: 'WILL_RECEIVE');
    final cashExpense =
        _watchTotalSum(type: 'EXPENSE', excludePaidRelationship: 'PAID_BY');

    return Rx.combineLatest6(
      incomeOverall,
      incomeMonth,
      expenseOverall,
      expenseMonth,
      cashIncome,
      cashExpense,
      (a, b, c, d, e, f) => TransactionStats(
        incomeOverall: a,
        incomeMonth: b,
        expenseOverall: c,
        expenseMonth: d,
        cashIncome: e,
        cashExpense: f,
      ),
    );
  }

  Stream<double> _watchTotalSum({
    required String type,
    DateTime? start,
    String? excludePaidRelationship,
  }) {
    final query = _database.selectOnly(_database.transactions);
    query.addColumns([_database.transactions.amount.sum()]);
    query.where(_database.transactions.type.equals(type));
    query.where(_database.transactions.isDeleted.equals(false));

    if (start != null) {
      query.where(_database.transactions.date.isBiggerOrEqualValue(start));
    }

    if (excludePaidRelationship != null) {
      if (excludePaidRelationship == 'WILL_RECEIVE') {
        query.join([
          leftOuterJoin(
            _database.receivables,
            _database.receivables.uuid
                .equalsExp(_database.transactions.linkedReceivableUuid),
          ),
        ]);
        query.where(_database.transactions.paidRelationship.isNull() |
            _database.transactions.paidRelationship
                .equals('WILL_RECEIVE')
                .not() |
            _database.receivables.status.equals('RECEIVED'));
      } else if (excludePaidRelationship == 'PAID_BY') {
        query.join([
          leftOuterJoin(
            _database.payables,
            _database.payables.uuid
                .equalsExp(_database.transactions.linkedPayableUuid),
          ),
        ]);
        query.where(_database.transactions.paidRelationship.isNull() |
            _database.transactions.paidRelationship.equals('PAID_BY').not() |
            _database.payables.status.equals('PAID'));
      }
    }

    return query
        .watchSingle()
        .map((row) => row.read(_database.transactions.amount.sum()) ?? 0.0);
  }

  // Get transactions by date range (Stream)
  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (_database.select(_database.transactions)
          ..where((t) =>
              t.date.isBetweenValues(start, end) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  // Get transactions by date range (Future)
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (_database.select(_database.transactions)
          ..where((t) =>
              t.date.isBetweenValues(start, end) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  // Get transaction by UUID
  Future<Transaction?> getTransactionByUuid(String uuid) {
    return (_database.select(_database.transactions)
          ..where((t) => t.uuid.equals(uuid) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  // Get transaction with details by UUID
  Future<TransactionWithDetails?> getTransactionWithDetailsByUuid(
      String uuid) async {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.transactions.contactUuid),
      ),
      leftOuterJoin(
        _database.payables,
        _database.payables.uuid
            .equalsExp(_database.transactions.linkedPayableUuid),
      ),
      leftOuterJoin(
        _database.receivables,
        _database.receivables.uuid
            .equalsExp(_database.transactions.linkedReceivableUuid),
      ),
    ]);

    query.where(_database.transactions.uuid.equals(uuid) &
        _database.transactions.isDeleted.equals(false));

    final rows = await query.get();
    if (rows.isEmpty) return null;

    final row = rows.first;
    return TransactionWithDetails(
      transaction: row.readTable(_database.transactions),
      category: row.readTableOrNull(_database.categories),
      contact: row.readTableOrNull(_database.contacts),
      linkedPayable: row.readTableOrNull(_database.payables),
      linkedReceivable: row.readTableOrNull(_database.receivables),
    );
  }

  // Watch transaction with details by UUID
  Stream<TransactionWithDetails?> watchTransactionWithDetailsByUuid(
      String uuid) {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.transactions.contactUuid),
      ),
      leftOuterJoin(
        _database.payables,
        _database.payables.uuid
            .equalsExp(_database.transactions.linkedPayableUuid),
      ),
      leftOuterJoin(
        _database.receivables,
        _database.receivables.uuid
            .equalsExp(_database.transactions.linkedReceivableUuid),
      ),
    ]);

    query.where(_database.transactions.uuid.equals(uuid) &
        _database.transactions.isDeleted.equals(false));

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final row = rows.first;
      return TransactionWithDetails(
        transaction: row.readTable(_database.transactions),
        category: row.readTableOrNull(_database.categories),
        contact: row.readTableOrNull(_database.contacts),
        linkedPayable: row.readTableOrNull(_database.payables),
        linkedReceivable: row.readTableOrNull(_database.receivables),
      );
    });
  }

  // Create transaction
  Future<String> createTransaction(TransactionsCompanion transaction) async {
    final uuid =
        transaction.uuid.present ? transaction.uuid.value : Uuid().v4();
    await _database.transaction(() async {
      await _database.into(_database.transactions).insert(
            transaction.copyWith(
              uuid: Value(uuid),
              isNotSynced: const Value(true),
            ),
          );
    });
    return uuid;
  }

  // Helper method to create transaction with individual parameters
  Future<String> createTransactionSimple({
    required double amount,
    required String type,
    String? description,
    required DateTime date,
    String? categoryUuid,
    String? contactUuid,
  }) {
    final uuid = const Uuid().v4();
    return createTransaction(
      TransactionsCompanion(
        uuid: Value(uuid),
        amount: Value(amount),
        type: Value(type),
        description: Value(description),
        date: Value(date),
        categoryUuid: Value(categoryUuid),
        contactUuid: Value(contactUuid),
      ),
    ).then((_) => uuid);
  }

  // Update transaction
  Future<bool> updateTransaction(Transaction transaction) async {
    return await _database.transaction(() async {
      return await _database.update(_database.transactions).replace(
            transaction.copyWith(isNotSynced: true),
          );
    });
  }

  // Delete transaction
  Future<int> deleteTransaction(String uuid) async {
    return await _database.transaction(() async {
      return await (_database.update(_database.transactions)
            ..where((t) => t.uuid.equals(uuid)))
          .write(const TransactionsCompanion(
        isDeleted: Value(true),
        isNotSynced: Value(true),
      ));
    });
  }

  // Get transactions by type (EXPENSE or INCOME)
  Stream<List<Transaction>> watchTransactionsByType(String type) {
    return (_database.select(_database.transactions)
          ..where((t) => t.type.equals(type) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  // Get transactions by category
  Stream<List<Transaction>> watchTransactionsByCategory(String categoryUuid) {
    return (_database.select(_database.transactions)
          ..where((t) =>
              t.categoryUuid.equals(categoryUuid) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  // Get total expense
  Future<double> getTotalExpense(DateTime? start, DateTime? end) async {
    final query = _database.selectOnly(_database.transactions)
      ..addColumns([_database.transactions.amount.sum()])
      ..where(_database.transactions.type.equals('EXPENSE') &
          _database.transactions.isDeleted.equals(false));

    if (start != null && end != null) {
      query.where(_database.transactions.date.isBetweenValues(start, end));
    }

    final result = await query.getSingle();
    return result.read(_database.transactions.amount.sum()) ?? 0.0;
  }

  // Get total income
  Future<double> getTotalIncome(DateTime? start, DateTime? end) async {
    final query = _database.selectOnly(_database.transactions)
      ..addColumns([_database.transactions.amount.sum()])
      ..where(_database.transactions.type.equals('INCOME') &
          _database.transactions.isDeleted.equals(false));

    if (start != null && end != null) {
      query.where(_database.transactions.date.isBetweenValues(start, end));
    }

    final result = await query.getSingle();
    return result.read(_database.transactions.amount.sum()) ?? 0.0;
  }

  // Import transaction from shared link
  Future<String> importFromSharedLink(dynamic sharedData) async {
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
    await createTransaction(
      TransactionsCompanion(
        uuid: Value(uuid),
        amount: Value(sharedData.amount),
        type: Value(sharedData.transactionType),
        description: Value(sharedData.description),
        date: Value(sharedData.date),
        contactUuid: Value(contactUuid),
        externalLinkId: Value(sharedData.externalLinkId),
      ),
    );
    return uuid;
  }

  // Get transaction by external link ID
  Future<Transaction?> getTransactionByExternalLinkId(String externalLinkId) {
    return (_database.select(_database.transactions)
          ..where((t) => t.externalLinkId.equals(externalLinkId)))
        .getSingleOrNull();
  }

  // Check if external link ID already exists
  Future<bool> checkIfExternalLinkExists(String externalLinkId) async {
    final transaction = await getTransactionByExternalLinkId(externalLinkId);
    return transaction != null;
  }

  // Watch transactions with category details
  Stream<List<TransactionWithCategory>> watchTransactionsWithCategory() {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
    ])
      ..where(_database.transactions.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_database.transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  // Watch transactions with ALL details (category + contact)
  // This method uses JOINs to fetch all related data in a single efficient query
  Stream<List<TransactionWithDetails>> watchTransactionsWithDetails() {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.transactions.contactUuid),
      ),
      leftOuterJoin(
        _database.payables,
        _database.payables.uuid
            .equalsExp(_database.transactions.linkedPayableUuid),
      ),
      leftOuterJoin(
        _database.receivables,
        _database.receivables.uuid
            .equalsExp(_database.transactions.linkedReceivableUuid),
      ),
    ])
      ..where(_database.transactions.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_database.transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.categories),
          contact: row.readTableOrNull(_database.contacts),
          linkedPayable: row.readTableOrNull(_database.payables),
          linkedReceivable: row.readTableOrNull(_database.receivables),
        );
      }).toList();
    });
  }

  // Get transactions with details by date range (Future)
  Future<List<TransactionWithDetails>> getTransactionsWithDetailsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.transactions.contactUuid),
      ),
      leftOuterJoin(
        _database.payables,
        _database.payables.uuid
            .equalsExp(_database.transactions.linkedPayableUuid),
      ),
      leftOuterJoin(
        _database.receivables,
        _database.receivables.uuid
            .equalsExp(_database.transactions.linkedReceivableUuid),
      ),
    ]);

    query.where(_database.transactions.date.isBetweenValues(start, end));
    query.where(_database.transactions.isDeleted.equals(false));
    query.orderBy([OrderingTerm.desc(_database.transactions.date)]);

    return query.get().then((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.categories),
          contact: row.readTableOrNull(_database.contacts),
          linkedPayable: row.readTableOrNull(_database.payables),
          linkedReceivable: row.readTableOrNull(_database.receivables),
        );
      }).toList();
    });
  }

  // Update transaction (with companion for partial updates)
  Future<void> updateTransactionWithCompanion(
      String uuid, TransactionsCompanion companion) async {
    await (_database.update(_database.transactions)
          ..where((t) => t.uuid.equals(uuid)))
        .write(companion.copyWith(isNotSynced: const Value(true)));
  }

  // Search transactions with details (paginated) - Stream version
  Stream<List<TransactionWithDetails>>
      watchTransactionsWithDetailsSearchPaginated({
    required String query,
    int limit = 50,
    int offset = 0,
  }) {
    final dbQuery = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.transactions.contactUuid),
      ),
      leftOuterJoin(
        _database.payables,
        _database.payables.uuid
            .equalsExp(_database.transactions.linkedPayableUuid),
      ),
      leftOuterJoin(
        _database.receivables,
        _database.receivables.uuid
            .equalsExp(_database.transactions.linkedReceivableUuid),
      ),
    ]);

    dbQuery.where(_database.transactions.description.contains(query));
    dbQuery.orderBy([OrderingTerm.desc(_database.transactions.date)]);
    dbQuery.limit(limit, offset: offset);

    return dbQuery.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.categories),
          contact: row.readTableOrNull(_database.contacts),
          linkedPayable: row.readTableOrNull(_database.payables),
          linkedReceivable: row.readTableOrNull(_database.receivables),
        );
      }).toList();
    });
  }

  // Search transactions with details (paginated) - Future version
  Future<List<TransactionWithDetails>>
      getTransactionsWithDetailsSearchPaginated({
    required String query,
    int limit = 50,
    int offset = 0,
  }) {
    final dbQuery = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.transactions.contactUuid),
      ),
      leftOuterJoin(
        _database.payables,
        _database.payables.uuid
            .equalsExp(_database.transactions.linkedPayableUuid),
      ),
      leftOuterJoin(
        _database.receivables,
        _database.receivables.uuid
            .equalsExp(_database.transactions.linkedReceivableUuid),
      ),
    ]);

    dbQuery.where(_database.transactions.description.contains(query));
    dbQuery.orderBy([OrderingTerm.desc(_database.transactions.date)]);
    dbQuery.limit(limit, offset: offset);

    return dbQuery.get().then((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.categories),
          contact: row.readTableOrNull(_database.contacts),
          linkedPayable: row.readTableOrNull(_database.payables),
          linkedReceivable: row.readTableOrNull(_database.receivables),
        );
      }).toList();
    });
  }

  // Get transactions with details (filtered and paginated) - Future version
  Future<List<TransactionWithDetails>>
      getTransactionsWithDetailsFilteredPaginated({
    required TransactionFilters filters,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.transactions.contactUuid),
      ),
      leftOuterJoin(
        _database.payables,
        _database.payables.uuid
            .equalsExp(_database.transactions.linkedPayableUuid),
      ),
      leftOuterJoin(
        _database.receivables,
        _database.receivables.uuid
            .equalsExp(_database.transactions.linkedReceivableUuid),
      ),
    ]);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where(_database.transactions.description.contains(searchQuery));
    }

    if (filters.startDate != null) {
      query.where(
          _database.transactions.date.isBiggerOrEqualValue(filters.startDate!));
    }
    if (filters.endDate != null) {
      query.where(
          _database.transactions.date.isSmallerOrEqualValue(filters.endDate!));
    }
    if (filters.type != null) {
      query.where(_database.transactions.type.equals(filters.type!));
    }
    if (filters.categoryUuids != null && filters.categoryUuids!.isNotEmpty) {
      query.where(
          _database.transactions.categoryUuid.isIn(filters.categoryUuids!));
    }
    if (filters.contactUuids != null && filters.contactUuids!.isNotEmpty) {
      query.where(
          _database.transactions.contactUuid.isIn(filters.contactUuids!));
    }
    if (filters.minAmount != null) {
      query.where(_database.transactions.amount
          .isBiggerOrEqualValue(filters.minAmount!));
    }
    if (filters.maxAmount != null) {
      query.where(_database.transactions.amount
          .isSmallerOrEqualValue(filters.maxAmount!));
    }

    query.where(_database.transactions.isDeleted.equals(false));

    query.orderBy([OrderingTerm.desc(_database.transactions.date)]);
    query.limit(limit, offset: offset);

    return query.get().then((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.categories),
          contact: row.readTableOrNull(_database.contacts),
          linkedPayable: row.readTableOrNull(_database.payables),
          linkedReceivable: row.readTableOrNull(_database.receivables),
        );
      }).toList();
    });
  }

  // Watch transactions with details (filtered and paginated) - Stream version
  Stream<List<TransactionWithDetails>>
      watchTransactionsWithDetailsFilteredPaginated({
    required TransactionFilters filters,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.transactions.contactUuid),
      ),
      leftOuterJoin(
        _database.payables,
        _database.payables.uuid
            .equalsExp(_database.transactions.linkedPayableUuid),
      ),
      leftOuterJoin(
        _database.receivables,
        _database.receivables.uuid
            .equalsExp(_database.transactions.linkedReceivableUuid),
      ),
    ]);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where(_database.transactions.description.contains(searchQuery));
    }

    if (filters.startDate != null) {
      query.where(
          _database.transactions.date.isBiggerOrEqualValue(filters.startDate!));
    }
    if (filters.endDate != null) {
      query.where(
          _database.transactions.date.isSmallerOrEqualValue(filters.endDate!));
    }
    if (filters.type != null) {
      query.where(_database.transactions.type.equals(filters.type!));
    }
    if (filters.categoryUuids != null && filters.categoryUuids!.isNotEmpty) {
      query.where(
          _database.transactions.categoryUuid.isIn(filters.categoryUuids!));
    }
    if (filters.contactUuids != null && filters.contactUuids!.isNotEmpty) {
      query.where(
          _database.transactions.contactUuid.isIn(filters.contactUuids!));
    }
    if (filters.minAmount != null) {
      query.where(_database.transactions.amount
          .isBiggerOrEqualValue(filters.minAmount!));
    }
    if (filters.maxAmount != null) {
      query.where(_database.transactions.amount
          .isSmallerOrEqualValue(filters.maxAmount!));
    }

    query.where(_database.transactions.isDeleted.equals(false));

    query.orderBy([OrderingTerm.desc(_database.transactions.date)]);
    query.limit(limit, offset: offset);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.categories),
          contact: row.readTableOrNull(_database.contacts),
          linkedPayable: row.readTableOrNull(_database.payables),
          linkedReceivable: row.readTableOrNull(_database.receivables),
        );
      }).toList();
    });
  }

  // Get transactions with details (paginated) - Stream version
  Stream<List<TransactionWithDetails>> watchTransactionsWithDetailsPaginated({
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.transactions.contactUuid),
      ),
      leftOuterJoin(
        _database.payables,
        _database.payables.uuid
            .equalsExp(_database.transactions.linkedPayableUuid),
      ),
      leftOuterJoin(
        _database.receivables,
        _database.receivables.uuid
            .equalsExp(_database.transactions.linkedReceivableUuid),
      ),
    ])
      ..where(_database.transactions.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_database.transactions.date)])
      ..limit(limit, offset: offset);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.categories),
          contact: row.readTableOrNull(_database.contacts),
          linkedPayable: row.readTableOrNull(_database.payables),
          linkedReceivable: row.readTableOrNull(_database.receivables),
        );
      }).toList();
    });
  }

  // Get transactions with details (paginated) - Future version for loading more
  Future<List<TransactionWithDetails>> getTransactionsWithDetailsPaginated({
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.uuid.equalsExp(_database.transactions.contactUuid),
      ),
      leftOuterJoin(
        _database.payables,
        _database.payables.uuid
            .equalsExp(_database.transactions.linkedPayableUuid),
      ),
      leftOuterJoin(
        _database.receivables,
        _database.receivables.uuid
            .equalsExp(_database.transactions.linkedReceivableUuid),
      ),
    ])
      ..where(_database.transactions.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_database.transactions.date)])
      ..limit(limit, offset: offset);

    return query.get().then((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.categories),
          contact: row.readTableOrNull(_database.contacts),
          linkedPayable: row.readTableOrNull(_database.payables),
          linkedReceivable: row.readTableOrNull(_database.receivables),
        );
      }).toList();
    });
  }
}

class TransactionWithCategory {
  final Transaction transaction;
  final Category? category;

  TransactionWithCategory({
    required this.transaction,
    this.category,
  });
}
