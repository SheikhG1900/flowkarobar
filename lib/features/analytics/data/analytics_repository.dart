import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';

class AnalyticsRepository {
  final AppDatabase _database;

  AnalyticsRepository(this._database);

  Future<List<CategoryExpense>> getExpensesByCategory(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final query = _database.selectOnly(_database.transactions)
      ..addColumns([
        _database.transactions.categoryUuid,
        _database.transactions.amount.sum()
      ])
      ..where(
          _database.transactions.date.isBetweenValues(startOfMonth, endOfMonth))
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
    final result = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..where(_database.transactions.type.equals(type))
          ..where(_database.transactions.date.isBetweenValues(start, end))
          ..where(_database.transactions.isDeleted.equals(false)))
        .getSingle();
    return result.read(_database.transactions.amount.sum()) ?? 0.0;
  }

  Future<List<ContactSummary>> getContactSummaries(
      DateTime start, DateTime end) async {
    final contactsWithPayables = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.contactUuid])
          ..where(_database.payables.date.isBetweenValues(start, end))
          ..where(_database.payables.isDeleted.equals(false))
          ..groupBy([_database.payables.contactUuid]))
        .get()
        .then((rows) =>
            rows.map((r) => r.read(_database.payables.contactUuid)!).toSet());
    final contactsWithReceivables =
        await (_database.selectOnly(_database.receivables)
              ..addColumns([_database.receivables.contactUuid])
              ..where(_database.receivables.date.isBetweenValues(start, end))
              ..where(_database.receivables.isDeleted.equals(false))
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
            ..where(_database.payables.isDeleted.equals(false)))
          .getSingle()
          .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
      final totalReceivable = await (_database.selectOnly(_database.receivables)
            ..addColumns([_database.receivables.amount.sum()])
            ..where(_database.receivables.contactUuid.equals(contactUuid))
            ..where(_database.receivables.date.isBetweenValues(start, end))
            ..where(_database.receivables.isDeleted.equals(false)))
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
    final contactsWithPayables = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.contactUuid])
          ..where(_database.payables.isDeleted.equals(false))
          ..groupBy([_database.payables.contactUuid]))
        .get()
        .then((rows) =>
            rows.map((r) => r.read(_database.payables.contactUuid)!).toSet());
    final contactsWithReceivables =
        await (_database.selectOnly(_database.receivables)
              ..addColumns([_database.receivables.contactUuid])
              ..where(_database.receivables.isDeleted.equals(false))
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
            ..where(_database.payables.isDeleted.equals(false)))
          .getSingle()
          .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
      final totalReceivable = await (_database.selectOnly(_database.receivables)
            ..addColumns([_database.receivables.amount.sum()])
            ..where(_database.receivables.contactUuid.equals(contactUuid))
            ..where(_database.receivables.isDeleted.equals(false)))
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

  Future<FinancialSummary> getFinancialSummary(
      DateTime start, DateTime end) async {
    final totalPayable = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.amount.sum()])
          ..where(_database.payables.date.isBetweenValues(start, end))
          ..where(_database.payables.isDeleted.equals(false)))
        .getSingle()
        .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
    final totalReceivable = await (_database.selectOnly(_database.receivables)
          ..addColumns([_database.receivables.amount.sum()])
          ..where(_database.receivables.date.isBetweenValues(start, end))
          ..where(_database.receivables.isDeleted.equals(false)))
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
    final totalPayable = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.amount.sum()])
          ..where(_database.payables.isDeleted.equals(false)))
        .getSingle()
        .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
    final totalReceivable = await (_database.selectOnly(_database.receivables)
          ..addColumns([_database.receivables.amount.sum()])
          ..where(_database.receivables.isDeleted.equals(false)))
        .getSingle()
        .then((row) => row.read(_database.receivables.amount.sum()) ?? 0.0);
    final totalExpense = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..where(_database.transactions.type.equals('EXPENSE'))
          ..where(_database.transactions.isDeleted.equals(false)))
        .getSingle()
        .then((row) => row.read(_database.transactions.amount.sum()) ?? 0.0);
    final totalIncome = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..where(_database.transactions.type.equals('INCOME'))
          ..where(_database.transactions.isDeleted.equals(false)))
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
      final totalPayable = await (_database.selectOnly(_database.payables)
            ..addColumns([_database.payables.amount.sum()])
            ..where(_database.payables.date.isBetweenValues(start, end))
            ..where(_database.payables.isDeleted.equals(false)))
          .getSingle()
          .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);
      final totalReceivable = await (_database.selectOnly(_database.receivables)
            ..addColumns([_database.receivables.amount.sum()])
            ..where(_database.receivables.date.isBetweenValues(start, end))
            ..where(_database.receivables.isDeleted.equals(false)))
          .getSingle()
          .then((row) => row.read(_database.receivables.amount.sum()) ?? 0.0);
      trends.add(PayableReceivableTrend(
          month: start,
          totalPayable: totalPayable,
          totalReceivable: totalReceivable));
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
  PayableReceivableTrend(
      {required this.month,
      required this.totalPayable,
      required this.totalReceivable});
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
