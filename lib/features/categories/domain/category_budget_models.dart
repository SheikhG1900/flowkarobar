import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/shared/models/date_range_state.dart';

/// Net activity for a category in [start]..[end]: sum(EXPENSE amounts) − sum(INCOME amounts),
/// counting only active transactions (not deleted, processed).
class CategoryPeriodStats {
  final double netAmount;
  final int transactionCount;

  const CategoryPeriodStats({
    required this.netAmount,
    required this.transactionCount,
  });
}

/// Budget + usage for one category and a calendar period.
class CategoryBudgetSnapshot {
  final Category category;
  final DateRangeState period;
  final double netAmount;
  final double? budgetAmount;
  final int transactionCount;

  const CategoryBudgetSnapshot({
    required this.category,
    required this.period,
    required this.netAmount,
    required this.budgetAmount,
    required this.transactionCount,
  });

  bool get hasBudget =>
      budgetAmount != null && budgetAmount! > 0;

  /// Progress 0..1 for bar; can exceed 1 when over budget / past target.
  double get progressRatio {
    if (!hasBudget) return 0;
    final cap = budgetAmount!;
    if (cap <= 0) return 0;
    if (category.type == 'INCOME') {
      // Savings target: achieved vs goal (same net formula).
      return netAmount / cap;
    }
    // Expense cap: consumption vs limit.
    return netAmount / cap;
  }

  /// Remaining budget (expense) or gap to target (income); negative when over.
  double get remainingOrGap {
    if (!hasBudget) return 0;
    return budgetAmount! - netAmount;
  }
}

/// Daily net amount for a category group, used for trend charts.
class DailyNetAmount {
  final DateTime date;
  final double netAmount;
  final double dailyNet;
  final int transactionCount;
  final bool hasData;

  const DailyNetAmount({
    required this.date,
    required this.netAmount,
    required this.dailyNet,
    required this.transactionCount,
    required this.hasData,
  });
}
