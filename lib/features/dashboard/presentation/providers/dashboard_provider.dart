import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/core/database/database.dart';

/// Dashboard statistics model
class DashboardStats {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<Transaction> recentTransactions;

  DashboardStats({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalBalance: 0.0,
      totalIncome: 0.0,
      totalExpense: 0.0,
      recentTransactions: [],
    );
  }
}

/// Provider for dashboard statistics
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  // Get the transactions repository
  final repository = ref.watch(transactionsRepositoryProvider);

  // Watch all transactions and calculate stats
  return repository.watchAllTransactions().map((transactions) {
    // Calculate totals
    // stats*: Used for "Income" and "Expense" display (Visual totals)
    // cash*: Used for "Balance" calculation (Actual cash on hand)

    double statsIncome = 0.0;
    double statsExpense = 0.0;

    double cashIncome = 0.0;
    double cashExpense = 0.0;

    for (final transaction in transactions) {
      if (transaction.type == 'INCOME') {
        statsIncome += transaction.amount;

        // If WILL_RECEIVE, it's accrued income (Receivable) but NO cash entered wallet yet.
        if (transaction.paidRelationship != 'WILL_RECEIVE') {
          cashIncome += transaction.amount;
        }
      } else if (transaction.type == 'EXPENSE') {
        statsExpense += transaction.amount;

        // If PAID_BY someone else, it's an expense record but NO cash left wallet yet.
        // So exclude from cashExpense calculation.
        if (transaction.paidRelationship != 'PAID_BY') {
          cashExpense += transaction.amount;
        }
      }
    }

    final totalBalance = cashIncome - cashExpense;

    // Get recent transactions (last 5)
    final recentTransactions = transactions.take(5).toList();

    return DashboardStats(
      totalBalance: totalBalance,
      totalIncome: statsIncome,
      totalExpense: statsExpense,
      recentTransactions: recentTransactions,
    );
  });
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
        data: (stats) => stats.totalIncome,
        loading: () => 0.0,
        error: (_, __) => 0.0,
      );
});

/// Provider for total expense
final totalExpenseProvider = Provider<double>((ref) {
  return ref.watch(dashboardStatsProvider).when(
        data: (stats) => stats.totalExpense,
        loading: () => 0.0,
        error: (_, __) => 0.0,
      );
});
