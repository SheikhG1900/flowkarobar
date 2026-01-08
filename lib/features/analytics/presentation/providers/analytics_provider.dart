import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/analytics/data/analytics_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

// Repository Provider
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.watch(databaseProvider));
});

// State Provider for Selected Month
final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, DateTime>(SelectedMonthNotifier.new);

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    return DateTime.now();
  }

  set state(DateTime newState) {
    super.state = newState;
  }
  
  void update(DateTime date) {
    state = date;
  }
}

// Expenses by Category Provider
final expensesByCategoryProvider = FutureProvider.autoDispose<List<CategoryExpense>>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  return repository.getExpensesByCategory(month);
});

// Monthly Trends Provider (Last 6 months)
final monthlyTrendsProvider = FutureProvider.autoDispose<List<MonthlyFinancials>>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  // Watch transactions to refresh when data changes
  // ref.watch(transactionsListProvider); // Optional: if we want auto-refresh
  return repository.getMonthlyTrends(6);
});
