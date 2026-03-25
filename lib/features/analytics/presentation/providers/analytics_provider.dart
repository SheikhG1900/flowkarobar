import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/analytics/data/analytics_repository.dart';
import 'package:flowpaisa/features/accounts/data/accounts_repository.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/shared/models/date_range_state.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';

export 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart'
    show accountsWithBalanceProvider;

// Re-export for consumers that imported from here
export 'package:flowpaisa/shared/models/date_range_state.dart';

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

// Selected section index for expenses-by-category pie chart (tap highlight)
class SelectedExpenseCategoryIndexNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setIndex(int? index) {
    state = index;
  }
}

final selectedExpenseCategoryIndexProvider =
    NotifierProvider<SelectedExpenseCategoryIndexNotifier, int?>(
        SelectedExpenseCategoryIndexNotifier.new);

// Selected section index for income-by-category pie chart (tap highlight)
class SelectedIncomeCategoryIndexNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setIndex(int? index) {
    state = index;
  }
}

final selectedIncomeCategoryIndexProvider =
    NotifierProvider<SelectedIncomeCategoryIndexNotifier, int?>(
        SelectedIncomeCategoryIndexNotifier.new);

// Selected index for balance distribution pie chart
class SelectedBalanceAccountIndexNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setIndex(int? index) {
    state = index;
  }
}

final selectedBalanceAccountIndexProvider =
    NotifierProvider<SelectedBalanceAccountIndexNotifier, int?>(
        SelectedBalanceAccountIndexNotifier.new);

// Selected index for Trends Bar Chart
class SelectedTrendIndexNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setIndex(int? index) {
    state = index;
  }
}

final selectedTrendIndexProvider =
    NotifierProvider<SelectedTrendIndexNotifier, int?>(
        SelectedTrendIndexNotifier.new);

// Selected index for Payable/Receivable Trends Bar Chart
class SelectedPayableReceivableTrendIndexNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setIndex(int? index) {
    state = index;
  }
}

final selectedPayableReceivableTrendIndexProvider =
    NotifierProvider<SelectedPayableReceivableTrendIndexNotifier, int?>(
        SelectedPayableReceivableTrendIndexNotifier.new);

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
  final dateRange = ref.watch(selectedDateRangeProvider);
  return repository.getMonthlyTrendsForRange(
      dateRange.startDate, dateRange.endDate);
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
  final dateRange = ref.watch(selectedDateRangeProvider);
  return repository.getPayableReceivableTrendsForRange(
      dateRange.startDate, dateRange.endDate);
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

// ── Account Analytics Providers ─────────────────────────────────────────────

/// Spending (expense + income) grouped by account for the selected date range.
final accountSpendingProvider =
    FutureProvider.autoDispose<List<AccountSpending>>((ref) async {
  final repo = ref.watch(accountsRepositoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  return repo.getSpendingByAccount(dateRange.startDate, dateRange.endDate);
});

/// Transfer flow between accounts for the selected date range.
final transferFlowProvider =
    FutureProvider.autoDispose<List<TransferFlowItem>>((ref) async {
  final repo = ref.watch(accountsRepositoryProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  return repo.getTransferFlow(dateRange.startDate, dateRange.endDate);
});

// ── Analytics Section Visibility ────────────────────────────────────────────

enum AnalyticsSection {
  financialSummary,
  contactSummaries,
  expensesByCategory,
  incomeVsExpenseTrend,
  payablesVsReceivablesTrend,
  topContacts,
  paymentStatus,
  incomeByCategory,
  netWorth,
  balanceDistribution,
  spendingByAccount,
  creditUtilisation,
  transferFlow,
}

const _kHiddenSectionsKey = 'analytics_hidden_sections';

class AnalyticsSectionsNotifier extends Notifier<Set<AnalyticsSection>> {
  @override
  Set<AnalyticsSection> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getStringList(_kHiddenSectionsKey) ?? [];
    return stored
        .map((s) => AnalyticsSection.values.firstWhere(
              (e) => e.name == s,
              orElse: () => AnalyticsSection.financialSummary,
            ))
        .toSet();
  }

  bool isVisible(AnalyticsSection section) => !state.contains(section);

  void toggle(AnalyticsSection section) {
    final prefs = ref.read(sharedPreferencesProvider);
    final next = Set<AnalyticsSection>.from(state);
    if (next.contains(section)) {
      next.remove(section);
    } else {
      next.add(section);
    }
    state = next;
    prefs.setStringList(
        _kHiddenSectionsKey, next.map((e) => e.name).toList());
  }

  void selectAll() {
    final prefs = ref.read(sharedPreferencesProvider);
    state = {};
    prefs.remove(_kHiddenSectionsKey);
  }

  void deselectAll() {
    final prefs = ref.read(sharedPreferencesProvider);
    final all = AnalyticsSection.values.toSet();
    state = all;
    prefs.setStringList(
        _kHiddenSectionsKey, all.map((e) => e.name).toList());
  }
}

final analyticsSectionsProvider =
    NotifierProvider<AnalyticsSectionsNotifier, Set<AnalyticsSection>>(
        AnalyticsSectionsNotifier.new);
