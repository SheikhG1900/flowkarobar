import 'package:flowpaisa/core/database/database.dart';

/// Filter for dashboard statistics (Overall or Monthly)
enum DashboardFilter { overall, monthly }

/// Dashboard statistics model (Agregated)
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

class TransactionStats {
  final double incomeOverall;
  final double incomeMonth;
  final double expenseOverall;
  final double expenseMonth;
  final double cashIncome;
  final double cashExpense;

  TransactionStats({
    required this.incomeOverall,
    required this.incomeMonth,
    required this.expenseOverall,
    required this.expenseMonth,
    required this.cashIncome,
    required this.cashExpense,
  });
}

class ReceivableStats {
  final double overall;
  final double month;
  final double overdue;

  ReceivableStats({
    required this.overall,
    required this.month,
    required this.overdue,
  });
}

class PayableStats {
  final double overall;
  final double month;
  final double overdue;

  PayableStats({
    required this.overall,
    required this.month,
    required this.overdue,
  });
}
