import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:rxdart/rxdart.dart';

class AnalyticsRepository {
  final AppDatabase _database;

  AnalyticsRepository(this._database);

  Future<List<CategoryExpense>> getExpensesByCategory(
      DateTime start, DateTime end, {List<String>? tagUuids}) async {
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final netAmount = _database.transactions.amount.sum();

    Expression<bool> whereExpr = _database.transactions.date.isBetweenValues(startDate, endDate) &
        _database.transactions.isDeleted.equals(false);

    final query = _database.selectOnly(_database.transactions)
      ..addColumns([_database.transactions.categoryUuid, netAmount])
      ..where(whereExpr)
      ..groupBy([_database.transactions.categoryUuid]);

    final results = await query.get();
    final List<CategoryExpense> categoryExpenses = [];
    for (final row in results) {
      final categoryUuid = row.read(_database.transactions.categoryUuid);
      final net = row.read(netAmount) ?? 0.0;

      if (categoryUuid != null) {
        final category = await (_database.select(_database.productCategories)
              ..where((c) => c.uuid.equals(categoryUuid)))
            .getSingleOrNull();
        if (category != null) {
          // Wrap ProductCategory into Category model for visual rendering
          categoryExpenses.add(CategoryExpense(
              category: Category(
                uuid: category.uuid,
                name: category.name,
                icon: category.icon ?? 'category',
                color: category.color ?? '#9E9E9E',
                type: 'EXPENSE',
                isDefault: false,
                isDeleted: category.isDeleted,
                createdAt: category.createdAt,
                updatedAt: category.updatedAt,
                isNotSynced: category.isNotSynced,
              ), 
              totalAmount: net.abs()));
        }
      }
    }
    categoryExpenses.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return categoryExpenses;
  }

  Future<List<MonthlyFinancials>> getMonthlyTrends(int months, {List<String>? tagUuids}) async {
    final now = DateTime.now();
    final List<MonthlyFinancials> trends = [];
    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      final income = await _getTotalByType('CASH_IN', start, end);
      final expense = await _getTotalByType('CASH_OUT', start, end);
      trends.add(
          MonthlyFinancials(month: start, income: income, expense: expense));
    }
    return trends;
  }

  Future<List<MonthlyFinancials>> getMonthlyTrendsForRange(
      DateTime rangeStart, DateTime rangeEnd, {List<String>? tagUuids}) async {
    final List<MonthlyFinancials> trends = [];
    DateTime cursor = DateTime(rangeStart.year, rangeStart.month, 1);
    while (!cursor.isAfter(DateTime(rangeEnd.year, rangeEnd.month, 1))) {
      final start = DateTime(cursor.year, cursor.month, 1);
      final end = DateTime(cursor.year, cursor.month + 1, 0, 23, 59, 59);
      final income = await _getTotalByType('CASH_IN', start, end);
      final expense = await _getTotalByType('CASH_OUT', start, end);
      trends.add(
          MonthlyFinancials(month: start, income: income, expense: expense));
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
    return trends;
  }

  Future<double> _getTotalByType(
      String type, DateTime start, DateTime end) async {
    Expression<bool> whereExpr = _database.transactions.type.equals(type) &
        _database.transactions.date.isBetweenValues(start, end) &
        _database.transactions.isDeleted.equals(false);

    final result = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..where(whereExpr))
        .getSingle();
    return result.read(_database.transactions.amount.sum()) ?? 0.0;
  }

  Future<List<ContactSummary>> getContactSummaries(
      DateTime start, DateTime end) async {
    return []; 
  }

  Future<List<ContactSummary>> getAllTimeContactSummaries() async {
    return [];
  }

  Future<FinancialSummary> getFinancialSummary(DateTime start, DateTime end, {List<String>? tagUuids}) async {
    final income = await _getTotalByType('CASH_IN', start, end);
    final expense = await _getTotalByType('CASH_OUT', start, end);
    return FinancialSummary(totalIncome: income, totalExpense: expense, netBalance: income - expense);
  }

  Future<FinancialSummary> getAllTimeFinancialSummary() async {
    final now = DateTime.now();
    final start = DateTime(now.year - 10, 1, 1);
    final end = DateTime(now.year + 10, 1, 1);
    return getFinancialSummary(start, end);
  }

  Future<List<PayableReceivableTrend>> getPayableReceivableTrendsForRange(DateTime start, DateTime end) async {
    return [];
  }

  Future<List<ContactSummary>> getTopContactsByBalance(DateTime start, DateTime end, int limit) async {
    return [];
  }

  Future<StatusDistribution> getPaymentStatusDistribution(DateTime start, DateTime end) async {
    return StatusDistribution();
  }

  Future<List<CategoryIncome>> getIncomeByCategory(DateTime start, DateTime end, {List<String>? tagUuids}) async {
    return [];
  }

  Future<CategoryStatistics> getCategoryStatistics(String categoryUuid, DateTime start, DateTime end, {List<String>? tagUuids}) async {
    return CategoryStatistics();
  }

  Stream<FinancialSummary> watchFinancialSummaryForTransactionFilters(TransactionFilters filters) {
    return Stream.value(FinancialSummary());
  }
}
