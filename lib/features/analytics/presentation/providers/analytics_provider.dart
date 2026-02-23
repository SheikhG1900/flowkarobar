import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/analytics/data/analytics_repository.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

// Enum for date range types
enum DateRangeType {
  month,
  quarter,
  year,
  custom,
}

// Date range state class
class DateRangeState {
  final DateTime startDate;
  final DateTime endDate;
  final DateRangeType type;

  DateRangeState({
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  DateRangeState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    DateRangeType? type,
  }) {
    return DateRangeState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
    );
  }

  // Helper factory constructors for different range types
  factory DateRangeState.currentMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return DateRangeState(
        startDate: start, endDate: end, type: DateRangeType.month);
  }

  factory DateRangeState.month(DateTime date) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    return DateRangeState(
        startDate: start, endDate: end, type: DateRangeType.month);
  }

  factory DateRangeState.quarter(int year, int quarter) {
    final startMonth = (quarter - 1) * 3 + 1;
    final start = DateTime(year, startMonth, 1);
    final end = DateTime(year, startMonth + 3, 0, 23, 59, 59);
    return DateRangeState(
        startDate: start, endDate: end, type: DateRangeType.quarter);
  }

  factory DateRangeState.year(int year) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59);
    return DateRangeState(
        startDate: start, endDate: end, type: DateRangeType.year);
  }

  factory DateRangeState.custom(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return DateRangeState(
        startDate: startDate, endDate: endDate, type: DateRangeType.custom);
  }
}

// Repository Provider
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.watch(databaseProvider));
});

// State Provider for Selected Date Range
final selectedDateRangeProvider =
    NotifierProvider<DateRangeNotifier, DateRangeState>(DateRangeNotifier.new);

class DateRangeNotifier extends Notifier<DateRangeState> {
  @override
  DateRangeState build() {
    return DateRangeState.currentMonth();
  }

  void updateRange(DateRangeState newRange) {
    state = newRange;
  }

  void nextPeriod() {
    switch (state.type) {
      case DateRangeType.month:
        final nextMonth =
            DateTime(state.startDate.year, state.startDate.month + 1, 1);
        state = DateRangeState.month(nextMonth);
        break;
      case DateRangeType.quarter:
        final currentQuarter = ((state.startDate.month - 1) ~/ 3) + 1;
        final nextQuarter = currentQuarter == 4 ? 1 : currentQuarter + 1;
        final nextYear = currentQuarter == 4
            ? state.startDate.year + 1
            : state.startDate.year;
        state = DateRangeState.quarter(nextYear, nextQuarter);
        break;
      case DateRangeType.year:
        state = DateRangeState.year(state.startDate.year + 1);
        break;
      case DateRangeType.custom:
        // For custom, don't change
        break;
    }
  }

  void previousPeriod() {
    switch (state.type) {
      case DateRangeType.month:
        final prevMonth =
            DateTime(state.startDate.year, state.startDate.month - 1, 1);
        state = DateRangeState.month(prevMonth);
        break;
      case DateRangeType.quarter:
        final currentQuarter = ((state.startDate.month - 1) ~/ 3) + 1;
        final prevQuarter = currentQuarter == 1 ? 4 : currentQuarter - 1;
        final prevYear = currentQuarter == 1
            ? state.startDate.year - 1
            : state.startDate.year;
        state = DateRangeState.quarter(prevYear, prevQuarter);
        break;
      case DateRangeType.year:
        state = DateRangeState.year(state.startDate.year - 1);
        break;
      case DateRangeType.custom:
        // For custom, don't change
        break;
    }
  }
}

// Expenses by Category Provider (uses full selected date range)
final expensesByCategoryProvider =
    FutureProvider.autoDispose<List<CategoryExpense>>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  return repository.getExpensesByCategory(
      dateRange.startDate, dateRange.endDate);
});

// Monthly Trends Provider (Last 6 months)
final monthlyTrendsProvider =
    FutureProvider.autoDispose<List<MonthlyFinancials>>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getMonthlyTrends(6);
});

// Contact Summaries Provider for selected range
final contactSummariesProvider =
    FutureProvider.autoDispose<List<ContactSummary>>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  return repository.getContactSummaries(dateRange.startDate, dateRange.endDate);
});

// All-time Contact Summaries Provider
final allTimeContactSummariesProvider =
    FutureProvider.autoDispose<List<ContactSummary>>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getAllTimeContactSummaries();
});

// Financial Summary Provider for selected range
final financialSummaryProvider =
    FutureProvider.autoDispose<FinancialSummary>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  return repository.getFinancialSummary(dateRange.startDate, dateRange.endDate);
});

// All-time Financial Summary Provider
final allTimeFinancialSummaryProvider =
    FutureProvider.autoDispose<FinancialSummary>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getAllTimeFinancialSummary();
});

// Payables vs Receivables Trend Provider (Last 6 months)
final payableReceivableTrendsProvider =
    FutureProvider.autoDispose<List<PayableReceivableTrend>>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getPayableReceivableTrends(6);
});

// Top Contacts by Balance Provider (Top 10)
final topContactsByBalanceProvider =
    FutureProvider.autoDispose<List<ContactSummary>>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  return repository.getTopContactsByBalance(
      dateRange.startDate, dateRange.endDate, 10);
});

// Payment Status Distribution Provider
final paymentStatusDistributionProvider =
    FutureProvider.autoDispose<StatusDistribution>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  return repository.getPaymentStatusDistribution(
      dateRange.startDate, dateRange.endDate);
});

// Income by Category Provider
final incomeByCategoryProvider =
    FutureProvider.autoDispose<List<CategoryIncome>>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  return repository.getIncomeByCategory(dateRange.startDate, dateRange.endDate);
});

// Category Statistics Provider
final categoryStatisticsProvider = FutureProvider.autoDispose
    .family<CategoryStatistics, String>((ref, categoryUuid) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  return repository.getCategoryStatistics(
      categoryUuid, dateRange.startDate, dateRange.endDate);
});

/// Financial summary for the transaction list, respecting current filters.
final transactionListSummaryProvider =
    FutureProvider.autoDispose<FinancialSummary>((ref) async {
  ref.watch(transactionsPaginatedProvider);
  final filters =
      ref.read(transactionsPaginatedProvider.notifier).currentFilters;
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getFinancialSummaryForTransactionFilters(filters);
});
