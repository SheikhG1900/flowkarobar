import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/dashboard/domain/models.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

/// Main dashboard header balance view: cash from transactions vs net worth from accounts.
enum DashboardMainBalanceView { availableCash, netWorth }

class DashboardMainBalanceViewNotifier extends Notifier<DashboardMainBalanceView> {
  @override
  DashboardMainBalanceView build() => DashboardMainBalanceView.availableCash;

  void toggle() {
    state = state == DashboardMainBalanceView.availableCash
        ? DashboardMainBalanceView.netWorth
        : DashboardMainBalanceView.availableCash;
  }
}

final dashboardMainBalanceViewProvider =
    NotifierProvider<DashboardMainBalanceViewNotifier, DashboardMainBalanceView>(
        DashboardMainBalanceViewNotifier.new);

/// Same logic as analytics / pinned net-worth widget (assets − liabilities).
double dashboardNetWorthFromAccounts(List<AccountWithBalance> accounts) {
  double totalAssets = 0;
  double totalLiabilities = 0;
  for (final awb in accounts) {
    if (awb.type.isCreditCard) {
      if (awb.balance < 0) totalLiabilities += awb.balance.abs();
    } else {
      if (awb.balance > 0) {
        totalAssets += awb.balance;
      } else {
        totalLiabilities += awb.balance.abs();
      }
    }
  }
  return totalAssets - totalLiabilities;
}

/// Same logic as dashboard header available cash: sum of non–credit-card account balances.
double dashboardAvailableCashFromAccounts(List<AccountWithBalance> accounts) {
  double availableCash = 0;
  for (final awb in accounts) {
    if (!awb.type.isCreditCard) {
      availableCash += awb.balance;
    }
  }
  return availableCash;
}

class DashboardFilterNotifier extends Notifier<DashboardFilter> {
  @override
  DashboardFilter build() => DashboardFilter.monthly;

  void setFilter(DashboardFilter filter) => state = filter;
}

final dashboardFilterProvider =
    NotifierProvider<DashboardFilterNotifier, DashboardFilter>(
        DashboardFilterNotifier.new);

/// Notifier that caches the last dashboard stats for showing while loading.
class LastDashboardStatsNotifier extends Notifier<DashboardStats?> {
  @override
  DashboardStats? build() => null;

  void setLast(DashboardStats? value) => state = value;
}

/// Last known dashboard stats; used to show previous values while loading
/// (e.g. after invalidation) instead of placeholders.
final lastDashboardStatsProvider =
    NotifierProvider<LastDashboardStatsNotifier, DashboardStats?>(
        LastDashboardStatsNotifier.new);

/// Provider for dashboard statistics
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  // Watch activeCashbookProvider so that when the cashbook changes, this provider
  // is fully re-evaluated and emits fresh statistics immediately.
  ref.watch(activeCashbookProvider);

  final txRepo = ref.watch(transactionsRepositoryProvider);
  final receivableRepo = ref.watch(receivablesRepositoryProvider);
  final payableRepo = ref.watch(payablesRepositoryProvider);

  // We watch the sync status polling to ensure it stays active while the dashboard is visible.
  ref.watch(syncStatusPollingProvider);

  final txStatsStream = txRepo.watchTransactionStats();
  final recentTxStream = txRepo.watchRecentTransactions(limit: 5).distinct((prev, next) => const ListEquality().equals(prev, next));
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
  ).debounceTime(const Duration(milliseconds: 100)).distinct((prev, next) => prev == next);
});

/// Provider for recent transactions (last 10)
final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final txRepo = ref.watch(transactionsRepositoryProvider);

  // Also watch the sync status - if it goes from 'Pulling' to 'Idle' or 'Success', refresh
  final syncStatus = ref.watch(backupProvider.select((s) => s.syncStatus));
  if (syncStatus == 'Idle' || syncStatus == 'Success') {
    // This ensures we re-fetch after sync completes
  }

  return txRepo.watchRecentTransactions(limit: 10).distinct((prev, next) => const ListEquality().equals(prev, next)).debounceTime(const Duration(milliseconds: 100));
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
