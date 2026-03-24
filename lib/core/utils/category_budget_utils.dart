import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/shared/models/date_range_state.dart';

/// Resolves which budget column applies for [range.type].
double? budgetAmountForPeriod(Category category, DateRangeState range) {
  switch (range.type) {
    case DateRangeType.month:
      return category.monthlyBudget;
    case DateRangeType.quarter:
      return category.quarterlyBudget;
    case DateRangeType.year:
      return category.yearlyBudget;
    case DateRangeType.custom:
      return category.monthlyBudget;
  }
}
