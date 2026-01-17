import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';

/// Filter for dashboard statistics (Overall or Monthly)
enum DashboardFilter { overall, monthly }

class DashboardFilterNotifier extends Notifier<DashboardFilter> {
  @override
  DashboardFilter build() => DashboardFilter.monthly;

  void setFilter(DashboardFilter filter) => state = filter;
}

final dashboardFilterProvider =
    NotifierProvider<DashboardFilterNotifier, DashboardFilter>(
        DashboardFilterNotifier.new);

/// Dashboard statistics model
class DashboardStats {
  final double totalBalance;
  final double incomeOverall;
  final double incomeMonth;
  final double expenseOverall;
  final double expenseMonth;
  final double payableOverall;
  final double payableMonth;
  final double receivableOverall;
  final double receivableMonth;
  final double overduePayable;
  final double overdueReceivable;
  final List<Transaction> recentTransactions;

  DashboardStats({
    required this.totalBalance,
    required this.incomeOverall,
    required this.incomeMonth,
    required this.expenseOverall,
    required this.expenseMonth,
    required this.payableOverall,
    required this.payableMonth,
    required this.receivableOverall,
    required this.receivableMonth,
    required this.overduePayable,
    required this.overdueReceivable,
    required this.recentTransactions,
  });

  // Getters for filtered values
  double income(DashboardFilter filter) =>
      filter == DashboardFilter.monthly ? incomeMonth : incomeOverall;
  double expense(DashboardFilter filter) =>
      filter == DashboardFilter.monthly ? expenseMonth : expenseOverall;
  double receivable(DashboardFilter filter) =>
      filter == DashboardFilter.monthly ? receivableMonth : receivableOverall;
  double payable(DashboardFilter filter) =>
      filter == DashboardFilter.monthly ? payableMonth : payableOverall;

  // Calculated Net Values
  double netCash(DashboardFilter filter) => income(filter) - expense(filter);
  double netCredit(DashboardFilter filter) =>
      receivable(filter) - payable(filter);

  factory DashboardStats.empty() {
    return DashboardStats(
      totalBalance: 0.0,
      incomeOverall: 0.0,
      incomeMonth: 0.0,
      expenseOverall: 0.0,
      expenseMonth: 0.0,
      payableOverall: 0.0,
      payableMonth: 0.0,
      receivableOverall: 0.0,
      receivableMonth: 0.0,
      overduePayable: 0.0,
      overdueReceivable: 0.0,
      recentTransactions: [],
    );
  }
}

/// Provider for dashboard statistics
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final transactionsAsync = ref.watch(allTransactionsProvider);
  final receivablesAsync = ref.watch(allReceivablesProvider);
  final payablesAsync = ref.watch(allPayablesProvider);

  if (transactionsAsync is AsyncData &&
      receivablesAsync is AsyncData &&
      payablesAsync is AsyncData) {
    final transactions = transactionsAsync.value!;
    final receivables = receivablesAsync.value!;
    final payables = payablesAsync.value!;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // 1. Transaction Stats (Income/Expense)
    double incomeOverall = 0.0;
    double incomeMonth = 0.0;
    double expenseOverall = 0.0;
    double expenseMonth = 0.0;

    double cashIncome = 0.0;
    double cashExpense = 0.0;

    for (final tx in transactions) {
      if (tx.type == 'INCOME') {
        incomeOverall += tx.amount;
        if (tx.date.isAfter(startOfMonth) ||
            tx.date.isAtSameMomentAs(startOfMonth)) {
          incomeMonth += tx.amount;
        }

        if (tx.paidRelationship != 'WILL_RECEIVE') {
          cashIncome += tx.amount;
        }
      } else if (tx.type == 'EXPENSE') {
        expenseOverall += tx.amount;
        if (tx.date.isAfter(startOfMonth) ||
            tx.date.isAtSameMomentAs(startOfMonth)) {
          expenseMonth += tx.amount;
        }

        if (tx.paidRelationship != 'PAID_BY') {
          cashExpense += tx.amount;
        }
      }
    }

    // 2. Receivable Stats
    double receivableOverall = 0.0;
    double receivableMonth = 0.0;
    double overdueReceivable = 0.0;

    for (final r in receivables) {
      if (r.status == 'PENDING') {
        receivableOverall += r.amount;
        if (r.date.isAfter(startOfMonth) ||
            r.date.isAtSameMomentAs(startOfMonth)) {
          receivableMonth += r.amount;
        }

        if (r.dueDate != null && r.dueDate!.isBefore(now)) {
          overdueReceivable += r.amount;
        }
      }
    }

    // 3. Payable Stats
    double payableOverall = 0.0;
    double payableMonth = 0.0;
    double overduePayable = 0.0;

    for (final p in payables) {
      if (p.status == 'PENDING') {
        payableOverall += p.amount;
        if (p.date.isAfter(startOfMonth) ||
            p.date.isAtSameMomentAs(startOfMonth)) {
          payableMonth += p.amount;
        }

        if (p.dueDate != null && p.dueDate!.isBefore(now)) {
          overduePayable += p.amount;
        }
      }
    }

    final totalBalance = cashIncome - cashExpense;
    final recentTransactions = transactions.take(5).toList();

    return Stream.value(DashboardStats(
      totalBalance: totalBalance,
      incomeOverall: incomeOverall,
      incomeMonth: incomeMonth,
      expenseOverall: expenseOverall,
      expenseMonth: expenseMonth,
      payableOverall: payableOverall,
      payableMonth: payableMonth,
      receivableOverall: receivableOverall,
      receivableMonth: receivableMonth,
      overduePayable: overduePayable,
      overdueReceivable: overdueReceivable,
      recentTransactions: recentTransactions,
    ));
  } else {
    return const Stream.empty();
  }
});

/// Provider for recent transactions (last 10)
final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(allTransactionsProvider).when(
        data: (transactions) => Stream.value(transactions.take(10).toList()),
        loading: () => Stream.value([]),
        error: (_, __) => Stream.value([]),
      );
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
