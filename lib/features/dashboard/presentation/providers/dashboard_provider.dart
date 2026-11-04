import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/dashboard/domain/models.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/businesses/presentation/providers/business_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
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
  // Watch activeBusinessProvider so that when the business changes, this provider
  // is fully re-evaluated and emits fresh statistics immediately.
  ref.watch(activeBusinessProvider);

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

// ==========================================================
// FLOWKAROBAR B2B2C COMMERCIAL DASHBOARD PROVIDERS
// ==========================================================

/// Stream of all products with stock warning counts
final lowStockAlertCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.selectOnly(db.products)
        ..addColumns([db.products.uuid.count()])
        ..where(db.products.isDeleted.equals(false) & 
               db.products.stockQuantity.isSmallerThan(db.products.minStockAlert)))
      .watchSingle()
      .map((row) => row.read(db.products.uuid.count()) ?? 0);
});

/// Stream of all batches expiring soon (60 days)
final expiringSoonCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final threshold = DateTime.now().add(const Duration(days: 60));
  return (db.selectOnly(db.productBatches)
        ..addColumns([db.productBatches.uuid.count()])
        ..where(db.productBatches.isDeleted.equals(false) &
               db.productBatches.totalQuantity
                   .isBiggerThan(db.productBatches.consumedQuantity) &
               db.productBatches.expiryDate.isSmallerThanValue(threshold)))
      .watchSingle()
      .map((row) => row.read(db.productBatches.uuid.count()) ?? 0);
});

/// Today's Net Sales Revenue Provider
final todaySalesRevenueProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  
  final query = db.selectOnly(db.orders)
    ..addColumns([db.orders.totalAmount.sum()])
    ..where(
      db.orders.orderType.equals('SALE') &
      db.orders.deliveryStatus.equals('DELIVERED') &
      db.orders.orderDate.isBiggerOrEqualValue(startOfDay) &
      db.orders.isDeleted.equals(false)
    );
  
  return query.watchSingle().map((row) => row.read(db.orders.totalAmount.sum()) ?? 0.0);
});

/// Overall Trade Receivables (What Customers Owe Us)
final outstandingReceivablesProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  
  // Outstanding = Sum(Sales Total Amount) - Sum(Sales Collections)
  final salesSumQuery = db.selectOnly(db.orders)
    ..addColumns([db.orders.totalAmount.sum()])
    ..where(db.orders.orderType.equals('SALE') & db.orders.isDeleted.equals(false));
    
  final collectionsQuery = db.selectOnly(db.transactions)
    ..addColumns([db.transactions.amount.sum()])
    ..where(db.transactions.type.equals('CASH_IN') & db.transactions.orderUuid.isNotNull() & db.transactions.isDeleted.equals(false));

  return Rx.combineLatest2(
    salesSumQuery.watchSingle(),
    collectionsQuery.watchSingle(),
    (salesRow, colRow) {
      final sales = salesRow.read(db.orders.totalAmount.sum()) ?? 0.0;
      final collections = colRow.read(db.transactions.amount.sum()) ?? 0.0;
      final diff = sales - collections;
      return diff > 0 ? diff : 0.0;
    },
  );
});

/// Overall Supplier Payables (What We Owe Suppliers)
final outstandingPayablesProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  
  // Outstanding = Sum(Purchases Total Amount) - Sum(Purchases Payments)
  final purchasesSumQuery = db.selectOnly(db.orders)
    ..addColumns([db.orders.totalAmount.sum()])
    ..where(db.orders.orderType.equals('PURCHASE') & db.orders.isDeleted.equals(false));
    
  final paymentsQuery = db.selectOnly(db.transactions)
    ..addColumns([db.transactions.amount.sum()])
    ..where(db.transactions.type.equals('CASH_OUT') & db.transactions.orderUuid.isNotNull() & db.transactions.isDeleted.equals(false));

  return Rx.combineLatest2(
    purchasesSumQuery.watchSingle(),
    paymentsQuery.watchSingle(),
    (purRow, payRow) {
      final purchases = purRow.read(db.orders.totalAmount.sum()) ?? 0.0;
      final payments = payRow.read(db.transactions.amount.sum()) ?? 0.0;
      final diff = purchases - payments;
      return diff > 0 ? diff : 0.0;
    },
  );
});
