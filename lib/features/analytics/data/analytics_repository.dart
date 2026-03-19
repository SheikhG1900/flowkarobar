import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';

class AnalyticsRepository {
  final AppDatabase _database;

  AnalyticsRepository(this._database);

  Future<List<CategoryExpense>> getExpensesByCategory(
      DateTime start, DateTime end) async {
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate =
        DateTime(end.year, end.month, end.day, 23, 59, 59);
    final query = _database.selectOnly(_database.transactions)
      ..addColumns([
        _database.transactions.categoryUuid,
        _database.transactions.amount.sum()
      ])
      ..where(_database.transactions.date.isBetweenValues(startDate, endDate))
      ..where(_database.transactions.type.equals('EXPENSE'))
      ..where(_database.transactions.isDeleted.equals(false))
      ..groupBy([_database.transactions.categoryUuid]);
    final results = await query.get();
    final List<CategoryExpense> categoryExpenses = [];
    for (final row in results) {
      final categoryUuid = row.read(_database.transactions.categoryUuid);
      final totalAmount = row.read(_database.transactions.amount.sum()) ?? 0.0;
      if (categoryUuid != null && totalAmount > 0) {
        final category = await (_database.select(_database.categories)
              ..where((c) => c.uuid.equals(categoryUuid)))
            .getSingleOrNull();
        if (category != null) {
          categoryExpenses.add(
              CategoryExpense(category: category, totalAmount: totalAmount));
        }
      }
    }
    categoryExpenses.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return categoryExpenses;
  }

  Future<List<MonthlyFinancials>> getMonthlyTrends(int months) async {
    final now = DateTime.now();
    final List<MonthlyFinancials> trends = [];
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      final income = await _getTotalByType('INCOME', start, end);
      final expense = await _getTotalByType('EXPENSE', start, end);
      trends.add(
          MonthlyFinancials(month: start, income: income, expense: expense));
    }
    return trends;
  }

  Future<double> _getTotalByType(
      String type, DateTime start, DateTime end) async {
    // Exclude inactive: do not include expense/income linked to PENDING payable/receivable
    Expression<bool> whereExpr = _database.transactions.type.equals(type) &
        _database.transactions.date.isBetweenValues(start, end) &
        _database.transactions.isDeleted.equals(false);
    if (type == 'EXPENSE') {
      whereExpr = whereExpr &
          (_database.transactions.linkedPayableUuid.isNull() |
              _database.payables.status.equals('PAID'));
    }
    if (type == 'INCOME') {
      whereExpr = whereExpr &
          (_database.transactions.linkedReceivableUuid.isNull() |
              _database.receivables.status.equals('RECEIVED'));
    }
    final result = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..join([
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
          ..where(whereExpr))
        .getSingle();
    return result.read(_database.transactions.amount.sum()) ?? 0.0;
  }

  Future<List<ContactSummary>> getContactSummaries(
      DateTime start, DateTime end) async {
    // Contact summary: only outstanding (PENDING). Exclude PAID and RECEIVED.
    final contactsWithPayables = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.contactUuid])
          ..where(_database.payables.date.isBetweenValues(start, end))
          ..where(_database.payables.isDeleted.equals(false))
          ..where(_database.payables.status.equals('PENDING'))
          ..groupBy([_database.payables.contactUuid]))
        .get()
        .then((rows) =>
            rows.map((r) => r.read(_database.payables.contactUuid)!).toSet());
    final contactsWithReceivables =
        await (_database.selectOnly(_database.receivables)
              ..addColumns([_database.receivables.contactUuid])
              ..where(_database.receivables.date.isBetweenValues(start, end))
              ..where(_database.receivables.isDeleted.equals(false))
              ..where(_database.receivables.status.equals('PENDING'))
              ..groupBy([_database.receivables.contactUuid]))
            .get()
            .then((rows) => rows
                .map((r) => r.read(_database.receivables.contactUuid)!)
                .toSet());
    final allContactUuids = {
      ...contactsWithPayables,
      ...contactsWithReceivables
    };
    if (allContactUuids.isEmpty) return [];
    final List<ContactSummary> summaries = [];
    for (final contactUuid in allContactUuids) {
      final contact = await (_database.select(_database.contacts)
            ..where((c) => c.uuid.equals(contactUuid)))
          .getSingleOrNull();
      if (contact == null) continue;
      final totalPayable = await (_database.selectOnly(_database.payables)
            ..addColumns([_database.payables.amount.sum()])
            ..where(_database.payables.contactUuid.equals(contactUuid))
            ..where(_database.payables.date.isBetweenValues(start, end))
            ..where(_database.payables.isDeleted.equals(false))
            ..where(_database.payables.status.equals('PENDING')))
          .getSingle()
          .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
      final totalReceivable = await (_database.selectOnly(_database.receivables)
            ..addColumns([_database.receivables.amount.sum()])
            ..where(_database.receivables.contactUuid.equals(contactUuid))
            ..where(_database.receivables.date.isBetweenValues(start, end))
            ..where(_database.receivables.isDeleted.equals(false))
            ..where(_database.receivables.status.equals('PENDING')))
          .getSingle()
          .then((row) => row.read(_database.receivables.amount.sum()) ?? 0.0);
      summaries.add(ContactSummary(
          contact: contact,
          totalPayable: totalPayable,
          totalReceivable: totalReceivable));
    }
    summaries.sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
    return summaries;
  }

  Future<List<ContactSummary>> getAllTimeContactSummaries() async {
    // Contact summary: only outstanding (PENDING). Exclude PAID and RECEIVED.
    final contactsWithPayables = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.contactUuid])
          ..where(_database.payables.isDeleted.equals(false))
          ..where(_database.payables.status.equals('PENDING'))
          ..groupBy([_database.payables.contactUuid]))
        .get()
        .then((rows) =>
            rows.map((r) => r.read(_database.payables.contactUuid)!).toSet());
    final contactsWithReceivables =
        await (_database.selectOnly(_database.receivables)
              ..addColumns([_database.receivables.contactUuid])
              ..where(_database.receivables.isDeleted.equals(false))
              ..where(_database.receivables.status.equals('PENDING'))
              ..groupBy([_database.receivables.contactUuid]))
            .get()
            .then((rows) => rows
                .map((r) => r.read(_database.receivables.contactUuid)!)
                .toSet());
    final allContactUuids = {
      ...contactsWithPayables,
      ...contactsWithReceivables
    };
    if (allContactUuids.isEmpty) return [];
    final List<ContactSummary> summaries = [];
    for (final contactUuid in allContactUuids) {
      final contact = await (_database.select(_database.contacts)
            ..where((c) => c.uuid.equals(contactUuid)))
          .getSingleOrNull();
      if (contact == null) continue;
      final totalPayable = await (_database.selectOnly(_database.payables)
            ..addColumns([_database.payables.amount.sum()])
            ..where(_database.payables.contactUuid.equals(contactUuid))
            ..where(_database.payables.isDeleted.equals(false))
            ..where(_database.payables.status.equals('PENDING')))
          .getSingle()
          .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
      final totalReceivable = await (_database.selectOnly(_database.receivables)
            ..addColumns([_database.receivables.amount.sum()])
            ..where(_database.receivables.contactUuid.equals(contactUuid))
            ..where(_database.receivables.isDeleted.equals(false))
            ..where(_database.receivables.status.equals('PENDING')))
          .getSingle()
          .then((row) => row.read(_database.receivables.amount.sum()) ?? 0.0);
      summaries.add(ContactSummary(
          contact: contact,
          totalPayable: totalPayable,
          totalReceivable: totalReceivable));
    }
    summaries.sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
    return summaries;
  }

  /// Financial summary for the transaction list's current filters (date, type, category, contact, amount).
  Future<FinancialSummary> getFinancialSummaryForTransactionFilters(
      TransactionFilters filters) async {
    final totalExpense = await _getTransactionSumByFilter(filters, 'EXPENSE');
    final totalIncome = await _getTransactionSumByFilter(filters, 'INCOME');

    final bool hasDateFilter =
        filters.startDate != null || filters.endDate != null;
    final bool hasCategoryFilter = filters.categoryUuids != null &&
        filters.categoryUuids!.isNotEmpty;
    final bool hasContactFilter = filters.contactUuids != null &&
        filters.contactUuids!.isNotEmpty;

    final now = DateTime.now();
    final start = filters.startDate ?? DateTime(now.year, 1, 1);
    final end =
        filters.endDate ?? DateTime(now.year, now.month, now.day, 23, 59, 59);
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final totalPayable = await _getPayableTotalForFilters(
      hasDateFilter: hasDateFilter,
      startDate: startDate,
      endDate: endDate,
      categoryUuids: filters.categoryUuids,
      contactUuids: filters.contactUuids,
      minAmount: filters.minAmount,
      maxAmount: filters.maxAmount,
      statusCodes: filters.statusCodes,
    );
    final totalReceivable = await _getReceivableTotalForFilters(
      hasDateFilter: hasDateFilter,
      startDate: startDate,
      endDate: endDate,
      categoryUuids: filters.categoryUuids,
      contactUuids: filters.contactUuids,
      minAmount: filters.minAmount,
      maxAmount: filters.maxAmount,
      statusCodes: filters.statusCodes,
    );

    return FinancialSummary(
        totalPayable: totalPayable,
        totalReceivable: totalReceivable,
        totalExpense: totalExpense,
        totalIncome: totalIncome);
  }

  Future<double> _getPayableTotalForFilters({
    required bool hasDateFilter,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? categoryUuids,
    List<String>? contactUuids,
    double? minAmount,
    double? maxAmount,
    List<String>? statusCodes,
  }) async {
    final hasCategoryFilter =
        categoryUuids != null && categoryUuids.isNotEmpty;
    final hasContactFilter =
        contactUuids != null && contactUuids.isNotEmpty;

    // Payable summary = outstanding only (PENDING). Never include PAID.
    List<String> payableStatuses = [];
    final hasStatusFilter =
        statusCodes != null && statusCodes.isNotEmpty;
    if (hasStatusFilter) {
      if (statusCodes!.contains('PAYABLE')) {
        payableStatuses.add('PENDING');
      }
      // If a status filter is active but PAYABLE not selected, summary is zero.
      if (payableStatuses.isEmpty) {
        return 0.0;
      }
    } else {
      payableStatuses.add('PENDING');
    }

    if (hasCategoryFilter) {
      final joinExpr =
          _database.transactions.uuid.equalsExp(_database.payables.linkedExpenseUuid) |
              _database.transactions.uuid.equalsExp(_database.payables.linkedIncomeUuid);
      Expression<bool> whereExpr = _database.payables.isDeleted.equals(false) &
          _database.transactions.categoryUuid.isIn(categoryUuids);

      if (payableStatuses.isNotEmpty) {
        whereExpr =
            whereExpr & _database.payables.status.isIn(payableStatuses);
      }
      if (hasDateFilter) {
        whereExpr = whereExpr &
            _database.payables.date.isBetweenValues(startDate, endDate);
      }
      if (hasContactFilter) {
        whereExpr =
            whereExpr & _database.payables.contactUuid.isIn(contactUuids);
      }
      if (minAmount != null) {
        whereExpr = whereExpr &
            _database.payables.amount.isBiggerOrEqualValue(minAmount);
      }
      if (maxAmount != null) {
        whereExpr = whereExpr &
            _database.payables.amount.isSmallerOrEqualValue(maxAmount);
      }
      final query = _database.selectOnly(_database.payables)
        ..addColumns([_database.payables.amount.sum()])
        ..join([
          innerJoin(
            _database.transactions,
            joinExpr,
          ),
        ])
        ..where(whereExpr);
      final row = await query.getSingle();
      return row.read(_database.payables.amount.sum()) ?? 0.0;
    }

    Expression<bool> whereExpr = _database.payables.isDeleted.equals(false);
    if (payableStatuses.isNotEmpty) {
      whereExpr =
          whereExpr & _database.payables.status.isIn(payableStatuses);
    }
    if (hasDateFilter) {
      whereExpr = whereExpr &
          _database.payables.date.isBetweenValues(startDate, endDate);
    }
    if (hasContactFilter) {
      whereExpr =
          whereExpr & _database.payables.contactUuid.isIn(contactUuids!);
    }
    if (minAmount != null) {
      whereExpr = whereExpr &
          _database.payables.amount.isBiggerOrEqualValue(minAmount);
    }
    if (maxAmount != null) {
      whereExpr = whereExpr &
          _database.payables.amount.isSmallerOrEqualValue(maxAmount);
    }
    final query = _database.selectOnly(_database.payables)
      ..addColumns([_database.payables.amount.sum()])
      ..where(whereExpr);
    final row = await query.getSingle();
    return row.read(_database.payables.amount.sum()) ?? 0.0;
  }

  Future<double> _getReceivableTotalForFilters({
    required bool hasDateFilter,
    required DateTime startDate,
    required DateTime endDate,
    List<String>? categoryUuids,
    List<String>? contactUuids,
    double? minAmount,
    double? maxAmount,
    List<String>? statusCodes,
  }) async {
    final hasCategoryFilter =
        categoryUuids != null && categoryUuids.isNotEmpty;
    final hasContactFilter =
        contactUuids != null && contactUuids.isNotEmpty;

    // Receivable summary = outstanding only (PENDING). Never include RECEIVED.
    List<String> receivableStatuses = [];
    final hasStatusFilter =
        statusCodes != null && statusCodes.isNotEmpty;
    if (hasStatusFilter) {
      if (statusCodes!.contains('RECEIVABLE')) {
        receivableStatuses.add('PENDING');
      }
      // If a status filter is active but RECEIVABLE not selected, summary is zero.
      if (receivableStatuses.isEmpty) {
        return 0.0;
      }
    } else {
      receivableStatuses.add('PENDING');
    }

    if (hasCategoryFilter) {
      final joinExpr =
          _database.transactions.uuid.equalsExp(_database.receivables.linkedExpenseUuid) |
              _database.transactions.uuid.equalsExp(_database.receivables.linkedIncomeUuid);
      Expression<bool> whereExpr = _database.receivables.isDeleted.equals(false) &
          _database.transactions.categoryUuid.isIn(categoryUuids);

      if (receivableStatuses.isNotEmpty) {
        whereExpr = whereExpr &
            _database.receivables.status.isIn(receivableStatuses);
      }
      if (hasDateFilter) {
        whereExpr = whereExpr &
            _database.receivables.date.isBetweenValues(startDate, endDate);
      }
      if (hasContactFilter) {
        whereExpr =
            whereExpr & _database.receivables.contactUuid.isIn(contactUuids);
      }
      if (minAmount != null) {
        whereExpr = whereExpr &
            _database.receivables.amount.isBiggerOrEqualValue(minAmount);
      }
      if (maxAmount != null) {
        whereExpr = whereExpr &
            _database.receivables.amount.isSmallerOrEqualValue(maxAmount);
      }
      final query = _database.selectOnly(_database.receivables)
        ..addColumns([_database.receivables.amount.sum()])
        ..join([
          innerJoin(
            _database.transactions,
            joinExpr,
          ),
        ])
        ..where(whereExpr);
      final row = await query.getSingle();
      return row.read(_database.receivables.amount.sum()) ?? 0.0;
    }

    Expression<bool> whereExpr = _database.receivables.isDeleted.equals(false);
    if (receivableStatuses.isNotEmpty) {
      whereExpr = whereExpr &
          _database.receivables.status.isIn(receivableStatuses);
    }
    if (hasDateFilter) {
      whereExpr = whereExpr &
          _database.receivables.date.isBetweenValues(startDate, endDate);
    }
    if (hasContactFilter) {
      whereExpr =
          whereExpr & _database.receivables.contactUuid.isIn(contactUuids!);
    }
    if (minAmount != null) {
      whereExpr = whereExpr &
          _database.receivables.amount.isBiggerOrEqualValue(minAmount);
    }
    if (maxAmount != null) {
      whereExpr = whereExpr &
          _database.receivables.amount.isSmallerOrEqualValue(maxAmount);
    }
    final query = _database.selectOnly(_database.receivables)
      ..addColumns([_database.receivables.amount.sum()])
      ..where(whereExpr);
    final row = await query.getSingle();
    return row.read(_database.receivables.amount.sum()) ?? 0.0;
  }

  Future<double> _getTransactionSumByFilter(
      TransactionFilters filters, String type) async {
    if (filters.type != null && filters.type != type) return 0.0;
    Expression<bool> whereExpr = _database.transactions.type.equals(type) &
        _database.transactions.isDeleted.equals(false);
    if (filters.startDate != null) {
      final startDate = DateTime(filters.startDate!.year, filters.startDate!.month,
          filters.startDate!.day, 0, 0, 0);
      whereExpr = whereExpr &
          _database.transactions.date.isBiggerOrEqualValue(startDate);
    }
    if (filters.endDate != null) {
      final endDate = DateTime(filters.endDate!.year, filters.endDate!.month,
          filters.endDate!.day, 23, 59, 59);
      whereExpr =
          whereExpr & _database.transactions.date.isSmallerOrEqualValue(endDate);
    }
    if (filters.categoryUuids != null && filters.categoryUuids!.isNotEmpty) {
      whereExpr = whereExpr &
          _database.transactions.categoryUuid.isIn(filters.categoryUuids!);
    }
    if (filters.contactUuids != null && filters.contactUuids!.isNotEmpty) {
      whereExpr = whereExpr &
          _database.transactions.contactUuid.isIn(filters.contactUuids!);
    }
    if (filters.accountUuids != null && filters.accountUuids!.isNotEmpty) {
      whereExpr = whereExpr &
          _database.transactions.accountUuid.isIn(filters.accountUuids!);
    }
    if (filters.minAmount != null) {
      whereExpr = whereExpr &
          _database.transactions.amount
              .isBiggerOrEqualValue(filters.minAmount!);
    }
    if (filters.maxAmount != null) {
      whereExpr = whereExpr &
          _database.transactions.amount
              .isSmallerOrEqualValue(filters.maxAmount!);
    }

    // Status-based filters: PAID / RECEIVED / PAYABLE / RECEIVABLE / AUTO / SCHEDULED
    if (filters.statusCodes != null && filters.statusCodes!.isNotEmpty) {
      final statuses = filters.statusCodes!;
      Expression<bool>? statusExpr;

      bool has(String code) => statuses.contains(code);

      // Auto-generated transactions
      if (has('AUTO')) {
        final expr = _database.transactions.isAutoGenerated.equals(true);
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }
      
      // Scheduled transactions
      if (has('SCHEDULED')) {
        final expr = _database.transactions.isScheduled.equals(true);
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      // Join to payables/receivables to filter by their status
      // PAID / PAYABLE relate to payables
      if (has('PAID')) {
        final expr = _database.transactions.paidRelationship
                .isIn(['PAID_BY', 'RECEIVED_FROM']) &
            _database.payables.status.equals('PAID');
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }
      if (has('PAYABLE')) {
        final expr = _database.transactions.paidRelationship
                .isIn(['PAID_BY', 'RECEIVED_FROM']) &
            _database.payables.status.equals('PENDING');
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      // RECEIVED / RECEIVABLE relate to receivables
      if (has('RECEIVED')) {
        final expr = _database.transactions.paidRelationship
                .isIn(['PAID_FOR', 'WILL_RECEIVE']) &
            _database.receivables.status.equals('RECEIVED');
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }
      if (has('RECEIVABLE')) {
        final expr = _database.transactions.paidRelationship
                .isIn(['PAID_FOR', 'WILL_RECEIVE']) &
            _database.receivables.status.equals('PENDING');
        statusExpr = statusExpr == null ? expr : (statusExpr | expr);
      }

      if (statusExpr != null) {
        whereExpr = whereExpr & statusExpr;
      }
    }

    // Exclude inactive: do not include expense/income linked to PENDING payable/receivable
    if (type == 'EXPENSE') {
      whereExpr = whereExpr &
          (_database.transactions.linkedPayableUuid.isNull() |
              _database.payables.status.equals('PAID'));
    }
    if (type == 'INCOME') {
      whereExpr = whereExpr &
          (_database.transactions.linkedReceivableUuid.isNull() |
              _database.receivables.status.equals('RECEIVED'));
    }

    final query = _database.selectOnly(_database.transactions)
      ..addColumns([_database.transactions.amount.sum()])
      ..join([
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
      ..where(whereExpr);
    final row = await query.getSingle();
    return row.read(_database.transactions.amount.sum()) ?? 0.0;
  }

  Future<FinancialSummary> getFinancialSummary(
      DateTime start, DateTime end) async {
    // Financial balance: only outstanding (PENDING). Exclude PAID and RECEIVED.
    final totalPayable = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.amount.sum()])
          ..where(_database.payables.date.isBetweenValues(start, end))
          ..where(_database.payables.isDeleted.equals(false))
          ..where(_database.payables.status.equals('PENDING')))
        .getSingle()
        .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
    final totalReceivable = await (_database.selectOnly(_database.receivables)
          ..addColumns([_database.receivables.amount.sum()])
          ..where(_database.receivables.date.isBetweenValues(start, end))
          ..where(_database.receivables.isDeleted.equals(false))
          ..where(_database.receivables.status.equals('PENDING')))
        .getSingle()
        .then((row) => row.read(_database.receivables.amount.sum()) ?? 0.0);
    final totalExpense = await _getTotalByType('EXPENSE', start, end);
    final totalIncome = await _getTotalByType('INCOME', start, end);
    return FinancialSummary(
        totalPayable: totalPayable,
        totalReceivable: totalReceivable,
        totalExpense: totalExpense,
        totalIncome: totalIncome);
  }

  Future<FinancialSummary> getAllTimeFinancialSummary() async {
    // Financial balance: only outstanding (PENDING). Exclude PAID and RECEIVED.
    final totalPayable = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.amount.sum()])
          ..where(_database.payables.isDeleted.equals(false))
          ..where(_database.payables.status.equals('PENDING')))
        .getSingle()
        .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
    final totalReceivable = await (_database.selectOnly(_database.receivables)
          ..addColumns([_database.receivables.amount.sum()])
          ..where(_database.receivables.isDeleted.equals(false))
          ..where(_database.receivables.status.equals('PENDING')))
        .getSingle()
        .then((row) => row.read(_database.receivables.amount.sum()) ?? 0.0);
    // Exclude inactive: do not include expense/income linked to PENDING payable/receivable
    final expenseWhere = _database.transactions.type.equals('EXPENSE') &
        _database.transactions.isDeleted.equals(false) &
        (_database.transactions.linkedPayableUuid.isNull() |
            _database.payables.status.equals('PAID'));
    final totalExpense = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..join([
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
          ..where(expenseWhere))
        .getSingle()
        .then((row) => row.read(_database.transactions.amount.sum()) ?? 0.0);
    final incomeWhere = _database.transactions.type.equals('INCOME') &
        _database.transactions.isDeleted.equals(false) &
        (_database.transactions.linkedReceivableUuid.isNull() |
            _database.receivables.status.equals('RECEIVED'));
    final totalIncome = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..join([
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
          ..where(incomeWhere))
        .getSingle()
        .then((row) => row.read(_database.transactions.amount.sum()) ?? 0.0);
    return FinancialSummary(
        totalPayable: totalPayable,
        totalReceivable: totalReceivable,
        totalExpense: totalExpense,
        totalIncome: totalIncome);
  }

  Future<List<PayableReceivableTrend>> getPayableReceivableTrends(
      int months) async {
    final now = DateTime.now();
    final List<PayableReceivableTrend> trends = [];
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final pendingPayable = await (_database.selectOnly(_database.payables)
            ..addColumns([_database.payables.amount.sum()])
            ..where(_database.payables.date.isBetweenValues(start, end))
            ..where(_database.payables.isDeleted.equals(false))
            ..where(_database.payables.status.equals('PENDING')))
          .getSingle()
          .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
      final paidPayable = await (_database.selectOnly(_database.payables)
            ..addColumns([_database.payables.amount.sum()])
            ..where(_database.payables.date.isBetweenValues(start, end))
            ..where(_database.payables.isDeleted.equals(false))
            ..where(_database.payables.status.equals('PAID')))
          .getSingle()
          .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
      final totalPayable = pendingPayable + paidPayable;

      final pendingReceivable =
          await (_database.selectOnly(_database.receivables)
                ..addColumns([_database.receivables.amount.sum()])
                ..where(_database.receivables.date.isBetweenValues(start, end))
                ..where(_database.receivables.isDeleted.equals(false))
                ..where(_database.receivables.status.equals('PENDING')))
              .getSingle()
              .then((row) =>
                  row.read(_database.receivables.amount.sum()) ?? 0.0);
      final receivedReceivable =
          await (_database.selectOnly(_database.receivables)
                ..addColumns([_database.receivables.amount.sum()])
                ..where(_database.receivables.date.isBetweenValues(start, end))
                ..where(_database.receivables.isDeleted.equals(false))
                ..where(_database.receivables.status.equals('RECEIVED')))
              .getSingle()
              .then((row) =>
                  row.read(_database.receivables.amount.sum()) ?? 0.0);
      final totalReceivable = pendingReceivable + receivedReceivable;

      trends.add(PayableReceivableTrend(
          month: start,
          totalPayable: totalPayable,
          totalReceivable: totalReceivable,
          pendingPayable: pendingPayable,
          paidPayable: paidPayable,
          pendingReceivable: pendingReceivable,
          receivedReceivable: receivedReceivable));
    }
    return trends;
  }

  Future<List<ContactSummary>> getTopContactsByBalance(
      DateTime start, DateTime end, int limit) async {
    final summaries = await getContactSummaries(start, end);
    return summaries.take(limit).toList();
  }

  Future<StatusDistribution> getPaymentStatusDistribution(
      DateTime start, DateTime end) async {
    final pendingPayables = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.amount.sum()])
          ..where(_database.payables.date.isBetweenValues(start, end))
          ..where(_database.payables.status.equals('PENDING'))
          ..where(_database.payables.isDeleted.equals(false)))
        .getSingle()
        .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
    final paidPayables = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.amount.sum()])
          ..where(_database.payables.date.isBetweenValues(start, end))
          ..where(_database.payables.status.equals('PAID'))
          ..where(_database.payables.isDeleted.equals(false)))
        .getSingle()
        .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
    final cancelledPayables = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.amount.sum()])
          ..where(_database.payables.date.isBetweenValues(start, end))
          ..where(_database.payables.status.equals('CANCELLED'))
          ..where(_database.payables.isDeleted.equals(false)))
        .getSingle()
        .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
    final pendingReceivables =
        await (_database.selectOnly(_database.receivables)
              ..addColumns([_database.receivables.amount.sum()])
              ..where(_database.receivables.date.isBetweenValues(start, end))
              ..where(_database.receivables.status.equals('PENDING'))
              ..where(_database.receivables.isDeleted.equals(false)))
            .getSingle()
            .then((row) => row.read(_database.receivables.amount.sum()) ?? 0.0);
    final receivedReceivables =
        await (_database.selectOnly(_database.receivables)
              ..addColumns([_database.receivables.amount.sum()])
              ..where(_database.receivables.date.isBetweenValues(start, end))
              ..where(_database.receivables.status.equals('RECEIVED'))
              ..where(_database.receivables.isDeleted.equals(false)))
            .getSingle()
            .then((row) => row.read(_database.receivables.amount.sum()) ?? 0.0);
    final cancelledReceivables =
        await (_database.selectOnly(_database.receivables)
              ..addColumns([_database.receivables.amount.sum()])
              ..where(_database.receivables.date.isBetweenValues(start, end))
              ..where(_database.receivables.status.equals('CANCELLED'))
              ..where(_database.receivables.isDeleted.equals(false)))
            .getSingle()
            .then((row) => row.read(_database.receivables.amount.sum()) ?? 0.0);
    return StatusDistribution(
        pendingPayables: pendingPayables,
        paidPayables: paidPayables,
        cancelledPayables: cancelledPayables,
        pendingReceivables: pendingReceivables,
        receivedReceivables: receivedReceivables,
        cancelledReceivables: cancelledReceivables);
  }

  Future<List<CategoryIncome>> getIncomeByCategory(
      DateTime start, DateTime end) async {
    final query = _database.selectOnly(_database.transactions)
      ..addColumns([
        _database.transactions.categoryUuid,
        _database.transactions.amount.sum()
      ])
      ..where(_database.transactions.date.isBetweenValues(start, end))
      ..where(_database.transactions.type.equals('INCOME'))
      ..where(_database.transactions.isDeleted.equals(false))
      ..groupBy([_database.transactions.categoryUuid]);
    final results = await query.get();
    final List<CategoryIncome> categoryIncomes = [];
    for (final row in results) {
      final categoryUuid = row.read(_database.transactions.categoryUuid);
      final totalAmount = row.read(_database.transactions.amount.sum()) ?? 0.0;
      if (categoryUuid != null && totalAmount > 0) {
        final category = await (_database.select(_database.categories)
              ..where((c) => c.uuid.equals(categoryUuid)))
            .getSingleOrNull();
        if (category != null) {
          categoryIncomes.add(
              CategoryIncome(category: category, totalAmount: totalAmount));
        }
      }
    }
    categoryIncomes.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return categoryIncomes;
  }

  Future<CategoryStatistics> getCategoryStatistics(
      String categoryUuid, DateTime start, DateTime end) async {
    final category = await (_database.select(_database.categories)
          ..where((c) => c.uuid.equals(categoryUuid)))
        .getSingleOrNull();
    if (category == null) throw Exception('Category not found');

    final totalAmount = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..where(_database.transactions.categoryUuid.equals(categoryUuid))
          ..where(_database.transactions.date.isBetweenValues(start, end))
          ..where(_database.transactions.isDeleted.equals(false)))
        .getSingle()
        .then((row) => row.read(_database.transactions.amount.sum()) ?? 0.0);

    final transactionCount = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.uuid.count()])
          ..where(_database.transactions.categoryUuid.equals(categoryUuid))
          ..where(_database.transactions.date.isBetweenValues(start, end))
          ..where(_database.transactions.isDeleted.equals(false)))
        .getSingle()
        .then((row) => row.read(_database.transactions.uuid.count()) ?? 0);

    return CategoryStatistics(
      category: category,
      totalAmount: totalAmount,
      transactionCount: transactionCount,
    );
  }
}

class CategoryExpense {
  final Category category;
  final double totalAmount;
  CategoryExpense({required this.category, required this.totalAmount});
}

class MonthlyFinancials {
  final DateTime month;
  final double income;
  final double expense;
  MonthlyFinancials(
      {required this.month, required this.income, required this.expense});
}

class ContactSummary {
  final Contact contact;
  final double totalPayable;
  final double totalReceivable;
  final double balance;
  ContactSummary(
      {required this.contact,
      required this.totalPayable,
      required this.totalReceivable})
      : balance = totalReceivable - totalPayable;
}

class FinancialSummary {
  final double totalPayable;
  final double totalReceivable;
  final double totalExpense;
  final double totalIncome;
  final double netBalance;
  FinancialSummary(
      {required this.totalPayable,
      required this.totalReceivable,
      required this.totalExpense,
      required this.totalIncome})
      : netBalance = totalReceivable - totalPayable;
}

class PayableReceivableTrend {
  final DateTime month;
  final double totalPayable;
  final double totalReceivable;
  final double pendingPayable;
  final double paidPayable;
  final double pendingReceivable;
  final double receivedReceivable;
  PayableReceivableTrend({
    required this.month,
    required this.totalPayable,
    required this.totalReceivable,
    required this.pendingPayable,
    required this.paidPayable,
    required this.pendingReceivable,
    required this.receivedReceivable,
  });
}

class StatusDistribution {
  final double pendingPayables;
  final double paidPayables;
  final double cancelledPayables;
  final double pendingReceivables;
  final double receivedReceivables;
  final double cancelledReceivables;
  StatusDistribution(
      {required this.pendingPayables,
      required this.paidPayables,
      required this.cancelledPayables,
      required this.pendingReceivables,
      required this.receivedReceivables,
      required this.cancelledReceivables});
}

class CategoryIncome {
  final Category category;
  final double totalAmount;
  CategoryIncome({required this.category, required this.totalAmount});
}

class CategoryStatistics {
  final Category category;
  final double totalAmount;
  final int transactionCount;
  CategoryStatistics({
    required this.category,
    required this.totalAmount,
    required this.transactionCount,
  });
}
