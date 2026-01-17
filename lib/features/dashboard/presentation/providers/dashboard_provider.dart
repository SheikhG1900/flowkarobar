import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/dashboard/domain/models.dart';
import 'package:rxdart/rxdart.dart';

class DashboardFilterNotifier extends Notifier<DashboardFilter> {
  @override
  DashboardFilter build() => DashboardFilter.monthly;

  void setFilter(DashboardFilter filter) => state = filter;
}

final dashboardFilterProvider =
    NotifierProvider<DashboardFilterNotifier, DashboardFilter>(
        DashboardFilterNotifier.new);

/// Provider for dashboard statistics
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final txRepo = ref.watch(transactionsRepositoryProvider);
  final receivableRepo = ref.watch(receivablesRepositoryProvider);
  final payableRepo = ref.watch(payablesRepositoryProvider);

  final txStatsStream = txRepo.watchTransactionStats();
  final recentTxStream = txRepo.watchRecentTransactions(limit: 5);
  final receivableStatsStream = receivableRepo.watchReceivableStats();
  final payableStatsStream = payableRepo.watchPayableStats();

  return Rx.combineLatest4(
    txStatsStream,
    recentTxStream,
    receivableStatsStream,
    payableStatsStream,
    (txStats, recentTx, receivableStats, payableStats) {
      return DashboardStats(
        totalBalance: txStats.cashIncome - txStats.cashExpense,
        incomeOverall: txStats.incomeOverall,
        incomeMonth: txStats.incomeMonth,
        expenseOverall: txStats.expenseOverall,
        expenseMonth: txStats.expenseMonth,
        payableOverall: payableStats.overall,
        payableMonth: payableStats.month,
        receivableOverall: receivableStats.overall,
        receivableMonth: receivableStats.month,
        overduePayable: payableStats.overdue,
        overdueReceivable: receivableStats.overdue,
        recentTransactions: recentTx,
      );
    },
  );
});

/// Provider for recent transactions (last 10)
final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final txRepo = ref.watch(transactionsRepositoryProvider);
  return txRepo.watchRecentTransactions(limit: 10);
});

/// Provider for total balance
final totalBalanceProvider = Provider<double>((ref) {
  return ref.watch(dashboardStatsProvider).when(
        data: (stats) => stats.totalBalance,
        loading: () => 0.0,
        error: (_, __) => 0.0,
      );
});

/// Provider for total income
final totalIncomeProvider = Provider<double>((ref) {
  return ref.watch(dashboardStatsProvider).when(
        data: (stats) => stats.incomeOverall,
        loading: () => 0.0,
        error: (_, __) => 0.0,
      );
});

/// Provider for total expense
final totalExpenseProvider = Provider<double>((ref) {
  return ref.watch(dashboardStatsProvider).when(
        data: (stats) => stats.expenseOverall,
        loading: () => 0.0,
        error: (_, __) => 0.0,
      );
});
