import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';

class AnalyticsRepository {
  final AppDatabase _database;

  AnalyticsRepository(this._database);

  /// Get total expenses grouped by category for a specific month
  Future<List<CategoryExpense>> getExpensesByCategory(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final query = _database.selectOnly(_database.transactions)
      ..addColumns([
        _database.transactions.categoryId,
        _database.transactions.amount.sum(),
      ])
      ..where(_database.transactions.date.isBetweenValues(startOfMonth, endOfMonth))
      ..where(_database.transactions.type.equals('EXPENSE'))
      ..groupBy([_database.transactions.categoryId]);

    final results = await query.get();

    final List<CategoryExpense> categoryExpenses = [];

    for (final row in results) {
      final categoryId = row.read(_database.transactions.categoryId);
      final totalAmount = row.read(_database.transactions.amount.sum()) ?? 0.0;

      if (categoryId != null && totalAmount > 0) {
        final category = await (_database.select(_database.categories)
              ..where((c) => c.id.equals(categoryId)))
            .getSingleOrNull();

        if (category != null) {
          categoryExpenses.add(CategoryExpense(
            category: category,
            totalAmount: totalAmount,
          ));
        }
      }
    }

    // Sort by amount descending
    categoryExpenses.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return categoryExpenses;
  }

  /// Get Income vs Expense totals for the last [months] count
  Future<List<MonthlyFinancials>> getMonthlyTrends(int months) async {
    final now = DateTime.now();
    final List<MonthlyFinancials> trends = [];

    for (int i = months - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final income = await _getTotalByType('INCOME', start, end);
      final expense = await _getTotalByType('EXPENSE', start, end);

      trends.add(MonthlyFinancials(
        month: start,
        income: income,
        expense: expense,
      ));
    }

    return trends;
  }

  Future<double> _getTotalByType(String type, DateTime start, DateTime end) async {
    final result = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..where(_database.transactions.type.equals(type))
          ..where(_database.transactions.date.isBetweenValues(start, end)))
        .getSingle();

    return result.read(_database.transactions.amount.sum()) ?? 0.0;
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

  MonthlyFinancials({
    required this.month,
    required this.income,
    required this.expense,
  });
}

