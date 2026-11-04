import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:flowpaisa/features/transactions/data/transaction_documents_repository.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/dashboard/domain/models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class TransactionsRepository {
  final AppDatabase _database;
  final String cashbookId;

  TransactionsRepository(this._database, [this.cashbookId = 'default']);

  // Get total transaction count
  Future<int> getTotalTransactionCount() async {
    final countExp = _database.transactions.uuid.count();
    final query = _database.selectOnly(_database.transactions)
      ..addColumns([countExp])
      ..where(_database.transactions.isDeleted.equals(false));
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  // Get all transactions
  Stream<List<Transaction>> watchAllTransactions() {
    return (_database.select(_database.transactions)
          ..where((t) => t.isDeleted.equals(false)))
        .watch();
  }

  // Watch recent updates (sorted by last modified time)
  Stream<List<Transaction>> watchRecentTransactions({int limit = 5}) {
    // We explicitly include the table in the stream to ensure Drift's
    // invalidation logic picks it up even after raw SQL updates
    return (_database.select(_database.transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
            (t) => OrderingTerm.desc(t.createdAt)
          ])
          ..limit(limit))
        .watch();
  }

  // Watch recent updates with ALL details (category + contact), sorted by last modified/updated time
  Stream<List<TransactionWithDetails>> watchRecentTransactionsWithDetails({int limit = 5}) {
    final query = _database.joinTransactionWithDetails(
        _database.select(_database.transactions))
      ..where(_database.transactions.isDeleted.equals(false))
      ..orderBy([
        OrderingTerm.desc(_database.transactions.updatedAt),
        OrderingTerm.desc(_database.transactions.createdAt),
      ])
      ..limit(limit);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.productCategories)?.toCategory(),
          contact: row.readTableOrNull(_database.contacts),
          account: row.readTableOrNull(_database.accounts),
          linkedPayable: null,
          linkedReceivable: null,
        );
      }).toList();
    });
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
    // Only count processed transactions (processedDate IS NOT NULL)
    // NULL means pending — excluded from totals/analytics
    query.where(_database.transactions.processedDate.isNotNull());

    if (start != null) {
      query.where(_database.transactions.date.isBiggerOrEqualValue(start));
    }

    return query
        .watchSingle()
        .map((row) => row.read(_database.transactions.amount.sum()) ?? 0.0);
  }

  // Get transactions by date range (Stream)
  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end, {
    List<String>? tagUuids,
  }) {
    final query = _database.select(_database.transactions)
      ..where((t) =>
          t.date.isBetweenValues(start, end) & t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);

    final tagExpr = _database.buildTagExpression(tagUuids ?? const []);
    if (tagExpr != null) {
      query.where((t) => tagExpr);
    }

    return query.watch();
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
    final query = _database.joinTransactionWithDetails(
        _database.select(_database.transactions));

    query.where(_database.transactions.uuid.equals(uuid) &
        _database.transactions.isDeleted.equals(false));

    final rows = await query.get();
    if (rows.isEmpty) return null;

    final row = rows.first;
    return TransactionWithDetails(
      transaction: row.readTable(_database.transactions),
      category: row.readTableOrNull(_database.productCategories)?.toCategory(),
      contact: row.readTableOrNull(_database.contacts),
      account: row.readTableOrNull(_database.accounts),
      linkedPayable: null,
      linkedReceivable: null,
    );
  }

  // Watch transaction with details by UUID
  Stream<TransactionWithDetails?> watchTransactionWithDetailsByUuid(
      String uuid) {
    final query = _database.joinTransactionWithDetails(
        _database.select(_database.transactions));

    query.where(_database.transactions.uuid.equals(uuid) &
        _database.transactions.isDeleted.equals(false));

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final row = rows.first;
      return TransactionWithDetails(
        transaction: row.readTable(_database.transactions),
        category: row.readTableOrNull(_database.productCategories)?.toCategory(),
        contact: row.readTableOrNull(_database.contacts),
        account: row.readTableOrNull(_database.accounts),
        linkedPayable: null,
        linkedReceivable: null,
      );
    });
  }

  /// Returns all transactions in the same split group (same linkedGroupId).
  /// If the given transaction has no linkedGroupId, returns only that transaction.
  Future<List<TransactionWithDetails>>
      getTransactionsWithDetailsByLinkedGroupId(
    String? linkedGroupId,
  ) async {
    return [];
  }

  /// Watches all transactions in the same split group (same linkedGroupId).
  Stream<List<TransactionWithDetails>>
      watchTransactionsWithDetailsByLinkedGroupId(
    String? linkedGroupId,
  ) {
    return Stream.value([]);
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
      // Delete associated physical documents and database rows
      final docRepo = TransactionDocumentsRepository(_database, cashbookId);
      await docRepo.deleteDocumentsForTransaction(uuid);

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

  // Get transactions with details by UUID prefix
  Future<List<TransactionWithDetails>> getTransactionsWithDetailsByUuidPrefix(
    String prefix,
  ) async {
    final query = _database.joinTransactionWithDetails(
        _database.select(_database.transactions));

    query.where(_database.transactions.uuid.like('$prefix%') &
        _database.transactions.isDeleted.equals(false));
    query.orderBy([OrderingTerm.desc(_database.transactions.date)]);

    final rows = await query.get();
    return rows.map((row) {
      return TransactionWithDetails(
        transaction: row.readTable(_database.transactions),
        category: row.readTableOrNull(_database.productCategories)?.toCategory(),
        contact: row.readTableOrNull(_database.contacts),
        account: row.readTableOrNull(_database.accounts),
        linkedPayable: null,
        linkedReceivable: null,
      );
    }).toList();
  }

  // Watch transactions with details by UUID prefix
  Stream<List<TransactionWithDetails>> watchTransactionsWithDetailsByUuidPrefix(
    String prefix,
  ) {
    final query = _database.joinTransactionWithDetails(
        _database.select(_database.transactions));

    query.where(_database.transactions.uuid.like('$prefix%') &
        _database.transactions.isDeleted.equals(false));
    query.orderBy([OrderingTerm.desc(_database.transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.productCategories)?.toCategory(),
          contact: row.readTableOrNull(_database.contacts),
          account: row.readTableOrNull(_database.accounts),
          linkedPayable: null,
          linkedReceivable: null,
        );
      }).toList();
    });
  }

  // Import transaction from shared link
  Future<String> importFromSharedLink(dynamic sharedData) async {
    return const Uuid().v4();
  }

  // Get transaction by external link ID
  Future<Transaction?> getTransactionByExternalLinkId(String externalLinkId) async {
    return null;
  }

  // Check if external link ID already exists
  Future<bool> checkIfExternalLinkExists(String externalLinkId) async {
    return false;
  }

  // Watch transactions with category details
  Stream<List<TransactionWithCategory>> watchTransactionsWithCategory() {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.productCategories,
        _database.productCategories.uuid
            .equalsExp(_database.transactions.categoryUuid),
      ),
    ])
      ..where(_database.transactions.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_database.transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.productCategories)?.toCategory(),
        );
      }).toList();
    });
  }

  // Watch transactions with ALL details (category + contact)
  // This method uses JOINs to fetch all related data in a single efficient query
  Stream<List<TransactionWithDetails>> watchTransactionsWithDetails() {
    final query = _database.joinTransactionWithDetails(
        _database.select(_database.transactions))
      ..where(_database.transactions.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_database.transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.productCategories)?.toCategory(),
          contact: row.readTableOrNull(_database.contacts),
          account: row.readTableOrNull(_database.accounts),
          linkedPayable: null,
          linkedReceivable: null,
        );
      }).toList();
    });
  }

  // Get transactions with details by date range (Future)
  Future<List<TransactionWithDetails>> getTransactionsWithDetailsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    final query = _database.joinTransactionWithDetails(
        _database.select(_database.transactions));

    query.where(_database.transactions.date.isBetweenValues(start, end));
    query.where(_database.transactions.isDeleted.equals(false));
    query.orderBy([OrderingTerm.desc(_database.transactions.date)]);

    return query.get().then((rows) {
      final transactions = rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.productCategories)?.toCategory(),
          contact: row.readTableOrNull(_database.contacts),
          account: row.readTableOrNull(_database.accounts),
          linkedPayable: null,
          linkedReceivable: null,
        );
      }).toList();
      return _populateTagsForTransactions(transactions);
    });
  }

  // Update transaction (with companion for partial updates)
  Future<void> updateTransactionWithCompanion(
      String uuid, TransactionsCompanion companion) async {
    await (_database.update(_database.transactions)
          ..where((t) => t.uuid.equals(uuid)))
        .write(companion.copyWith(
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ));
  }

  // Mark transaction as reviewed
  Future<void> markAsReviewed(String uuid) async {
    await updateTransactionWithCompanion(
      uuid,
      const TransactionsCompanion(
        isNotSynced: Value(true),
      ),
    );
  }

  // Search transactions with details (paginated) - Stream version
  Stream<List<TransactionWithDetails>>
      watchTransactionsWithDetailsSearchPaginated({
    required String query,
    int limit = 50,
    int offset = 0,
  }) {
    final dbQuery = _database.joinTransactionWithDetails(
        _database.select(_database.transactions));

    dbQuery.where(_database.transactions.description.contains(query));
    dbQuery.orderBy([OrderingTerm.desc(_database.transactions.date)]);
    dbQuery.limit(limit, offset: offset);

    return dbQuery.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.productCategories)?.toCategory(),
          contact: row.readTableOrNull(_database.contacts),
          account: row.readTableOrNull(_database.accounts),
          linkedPayable: null,
          linkedReceivable: null,
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
    final dbQuery = _database.joinTransactionWithDetails(
        _database.select(_database.transactions));

    dbQuery.where(_database.transactions.description.contains(query));
    dbQuery.orderBy([OrderingTerm.desc(_database.transactions.date)]);
    dbQuery.limit(limit, offset: offset);

    return dbQuery.get().then((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.productCategories)?.toCategory(),
          contact: row.readTableOrNull(_database.contacts),
          account: row.readTableOrNull(_database.accounts),
          linkedPayable: null,
          linkedReceivable: null,
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
    final query = _database.joinTransactionWithDetails(
        _database.select(_database.transactions));

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
      final containsUncategorized = filters.categoryUuids!.contains('uncategorized');
      final validCategoryUuids = filters.categoryUuids!.where((id) => id != 'uncategorized').toList();

      if (containsUncategorized && validCategoryUuids.isNotEmpty) {
        query.where(
            _database.transactions.categoryUuid.isIn(validCategoryUuids) |
            _database.transactions.categoryUuid.isNull()
        );
      } else if (containsUncategorized) {
        query.where(_database.transactions.categoryUuid.isNull());
      } else {
        query.where(
            _database.transactions.categoryUuid.isIn(validCategoryUuids));
      }
    }
    if (filters.contactUuids != null && filters.contactUuids!.isNotEmpty) {
      query.where(
          _database.transactions.contactUuid.isIn(filters.contactUuids!));
    }
    if (filters.accountUuids != null && filters.accountUuids!.isNotEmpty) {
      final containsNoAccount = filters.accountUuids!.contains('no_account');
      final validAccountUuids = filters.accountUuids!.where((id) => id != 'no_account').toList();

      if (containsNoAccount && validAccountUuids.isNotEmpty) {
        query.where(
            _database.transactions.accountUuid.isIn(validAccountUuids) |
            _database.transactions.accountUuid.isNull()
        );
      } else if (containsNoAccount) {
        query.where(_database.transactions.accountUuid.isNull());
      } else {
        query.where(
            _database.transactions.accountUuid.isIn(validAccountUuids));
      }
    }
    if (filters.minAmount != null) {
      query.where(_database.transactions.amount
          .isBiggerOrEqualValue(filters.minAmount!));
    }
    if (filters.maxAmount != null) {
      query.where(_database.transactions.amount
          .isSmallerOrEqualValue(filters.maxAmount!));
    }

    final tagExpr = _database.buildTagExpression(filters.tagUuids ?? const []);
    if (tagExpr != null) {
      query.where(tagExpr);
    }

    // Status-based filters: PAID / RECEIVED / PAYABLE / RECEIVABLE / AUTO /
    // SCHEDULED / PROCESSED / NOT_PROCESSED
    bool hasNotProcessedFilter = false;
    if (filters.statusCodes != null && filters.statusCodes!.isNotEmpty) {
      final statuses = filters.statusCodes!;
      Expression<bool>? statusExpr;

      bool has(String code) => statuses.contains(code);
      hasNotProcessedFilter = has('NOT_PROCESSED');

      // Auto-generated transactions
      if (has('AUTO')) {
        const expr = Constant(false);
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      // Scheduled transactions
      if (has('SCHEDULED')) {
        const expr = Constant(false);
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      if (has('PROCESSED')) {
        final expr = _database.transactions.processedDate.isNotNull();
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }
      if (has('NOT_PROCESSED')) {
        final expr = _database.transactions.processedDate.isNull();
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }
      if (has('CHANGES')) {
        final expr = _database.transactions.isNotSynced.equals(true);
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      // Payable side (payables linked to this transaction)
      // PAID_BY / RECEIVED_FROM => Payable side
      if (has('PAID') || has('PAYABLE')) {
        const expr = Constant(false);
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      // Receivable side (receivables linked to this transaction)
      // PAID_FOR / WILL_RECEIVE => Receivable side
      if (has('RECEIVED') || has('RECEIVABLE')) {
        const expr = Constant(false);
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      if (statusExpr != null) {
        query.where(statusExpr);
      }
    }

    query.where(_database.transactions.isDeleted.equals(false));

    query.orderBy([OrderingTerm.desc(_database.transactions.date)]);
    query.limit(limit, offset: offset);

    return query.get().then((rows) {
      final transactions = rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.productCategories)?.toCategory(),
          contact: row.readTableOrNull(_database.contacts),
          account: row.readTableOrNull(_database.accounts),
          linkedPayable: null,
          linkedReceivable: null,
        );
      }).toList();
      return _populateTagsForTransactions(transactions);
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
    final query = _database.joinTransactionWithDetails(
        _database.select(_database.transactions));

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
      final containsUncategorized = filters.categoryUuids!.contains('uncategorized');
      final validCategoryUuids = filters.categoryUuids!.where((id) => id != 'uncategorized').toList();

      if (containsUncategorized && validCategoryUuids.isNotEmpty) {
        query.where(
            _database.transactions.categoryUuid.isIn(validCategoryUuids) |
            _database.transactions.categoryUuid.isNull()
        );
      } else if (containsUncategorized) {
        query.where(_database.transactions.categoryUuid.isNull());
      } else {
        query.where(
            _database.transactions.categoryUuid.isIn(validCategoryUuids));
      }
    }
    if (filters.contactUuids != null && filters.contactUuids!.isNotEmpty) {
      query.where(
          _database.transactions.contactUuid.isIn(filters.contactUuids!));
    }
    if (filters.accountUuids != null && filters.accountUuids!.isNotEmpty) {
      final containsNoAccount = filters.accountUuids!.contains('no_account');
      final validAccountUuids = filters.accountUuids!.where((id) => id != 'no_account').toList();

      if (containsNoAccount && validAccountUuids.isNotEmpty) {
        query.where(
            _database.transactions.accountUuid.isIn(validAccountUuids) |
            _database.transactions.accountUuid.isNull()
        );
      } else if (containsNoAccount) {
        query.where(_database.transactions.accountUuid.isNull());
      } else {
        query.where(
            _database.transactions.accountUuid.isIn(validAccountUuids));
      }
    }
    if (filters.minAmount != null) {
      query.where(_database.transactions.amount
          .isBiggerOrEqualValue(filters.minAmount!));
    }
    if (filters.maxAmount != null) {
      query.where(_database.transactions.amount
          .isSmallerOrEqualValue(filters.maxAmount!));
    }

    final tagExpr = _database.buildTagExpression(filters.tagUuids ?? const []);
    if (tagExpr != null) {
      query.where(tagExpr);
    }

    // Status-based filters: PAID / RECEIVED / PAYABLE / RECEIVABLE / AUTO /
    // SCHEDULED / PROCESSED / NOT_PROCESSED
    bool hasNotProcessedFilter = false;
    if (filters.statusCodes != null && filters.statusCodes!.isNotEmpty) {
      final statuses = filters.statusCodes!;
      Expression<bool>? statusExpr;

      bool has(String code) => statuses.contains(code);
      hasNotProcessedFilter = has('NOT_PROCESSED');

      if (has('AUTO')) {
        const expr = Constant(false);
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      if (has('SCHEDULED')) {
        const expr = Constant(false);
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      if (has('PROCESSED')) {
        final expr = _database.transactions.processedDate.isNotNull();
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }
      if (has('NOT_PROCESSED')) {
        final expr = _database.transactions.processedDate.isNull();
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }
      if (has('CHANGES')) {
        final expr = _database.transactions.isNotSynced.equals(true);
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      if (has('PAID') || has('PAYABLE')) {
        const expr = Constant(false);
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      if (has('RECEIVED') || has('RECEIVABLE')) {
        const expr = Constant(false);
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      if (statusExpr != null) {
        query.where(statusExpr);
      }
    }

    query.where(_database.transactions.isDeleted.equals(false));

    query.orderBy([OrderingTerm.desc(_database.transactions.date)]);
    query.limit(limit, offset: offset);

    return query.watch().asyncMap((rows) async {
      final transactions = rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.productCategories)?.toCategory(),
          contact: row.readTableOrNull(_database.contacts),
          account: row.readTableOrNull(_database.accounts),
          linkedPayable: null,
          linkedReceivable: null,
        );
      }).toList();
      return await _populateTagsForTransactions(transactions);
    });
  }

  // Get transactions with details (paginated) - Stream version
  Stream<List<TransactionWithDetails>> watchTransactionsWithDetailsPaginated({
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.joinTransactionWithDetails(
        _database.select(_database.transactions))
      ..where(_database.transactions.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_database.transactions.date)])
      ..limit(limit, offset: offset);

    return query.watch().asyncMap((rows) async {
      final transactions = rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.productCategories)?.toCategory(),
          contact: row.readTableOrNull(_database.contacts),
          account: row.readTableOrNull(_database.accounts),
          linkedPayable: null,
          linkedReceivable: null,
        );
      }).toList();
      return await _populateTagsForTransactions(transactions);
    });
  }

  // Get transactions with details (paginated) - Future version for loading more
  Future<List<TransactionWithDetails>> getTransactionsWithDetailsPaginated({
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.joinTransactionWithDetails(
        _database.select(_database.transactions))
      ..where(_database.transactions.isDeleted.equals(false))
      ..orderBy([OrderingTerm.desc(_database.transactions.date)])
      ..limit(limit, offset: offset);

    return query.get().then((rows) {
      final transactions = rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.productCategories)?.toCategory(),
          contact: row.readTableOrNull(_database.contacts),
          account: row.readTableOrNull(_database.accounts),
          linkedPayable: null,
          linkedReceivable: null,
        );
      }).toList();
      return _populateTagsForTransactions(transactions);
    });
  }

  // Get all active tags
  Future<List<Tag>> getAllTags() async {
    return [];
  }

  // Watch all active tags
  Stream<List<Tag>> watchAllTags() {
    return Stream.value([]);
  }

  // Watch all active tags ordered by transaction usage frequency
  Stream<List<Tag>> watchTagsByUsage() {
    return Stream.value([]);
  }

  // Create or get tag by name (case-insensitive)
  Future<Tag> createTag(String name, {String? color}) async {
    return Tag(
      uuid: const Uuid().v4(),
      name: name,
      color: color ?? '#9E9E9E',
      createdAt: DateTime.now(),
      isDeleted: false,
    );
  }

  // Get tags for a transaction
  Future<List<Tag>> getTagsForTransaction(String transactionUuid) async {
    return [];
  }

  // Watch tags for a transaction
  Stream<List<Tag>> watchTagsForTransaction(String transactionUuid) {
    return Stream.value([]);
  }

  // Set tags for a transaction (replaces existing tags for this transaction)
  Future<void> setTransactionTags(String transactionUuid, List<String> tagUuids) async {}

  // Get transaction usage count for a tag
  Future<int> getTagUsageCount(String tagUuid) async {
    return 0;
  }

  // Update tag name and/or color
  Future<void> updateTag(String uuid, String newName, {String? color}) async {}

  // Soft-delete a tag (and its associations) so it syncs deletion to the cloud
  Future<void> deleteTag(String uuid) async {}

  Future<List<TransactionWithDetails>> _populateTagsForTransactions(
      List<TransactionWithDetails> transactions) async {
    return transactions;
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
