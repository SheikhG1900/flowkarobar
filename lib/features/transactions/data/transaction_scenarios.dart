import 'package:flutter/material.dart';
import 'package:flowpaisa/features/transactions/domain/transaction_scenario.dart';

/// All transaction/schedule help scenarios. Labels are resolved via
/// [TransactionScenarioHelper.getLabel] using AppLocalizations.
class TransactionScenarios {
  TransactionScenarios._();

  static const List<TransactionScenario> all = [
    // --- Expense + Receivable (PAID_FOR) ---
    TransactionScenario(
      id: 'scenarioPaidForMeal',
      type: 'EXPENSE',
      relationship: 'PAID_FOR',
      icon: Icons.restaurant,
      sortOrder: 1,
    ),
    TransactionScenario(
      id: 'scenarioBoughtForSomeone',
      type: 'EXPENSE',
      relationship: 'PAID_FOR',
      icon: Icons.shopping_cart,
      sortOrder: 2,
    ),
    TransactionScenario(
      id: 'scenarioLentMoney',
      type: 'EXPENSE',
      relationship: 'PAID_FOR',
      icon: Icons.payments,
      sortOrder: 3,
    ),
/*	
    TransactionScenario(
      id: 'scenarioPaidBillForSomeone',
      type: 'EXPENSE',
      relationship: 'PAID_FOR',
      icon: Icons.receipt,
      sortOrder: 4,
    ),
*/
    TransactionScenario(
      id: 'scenarioSplitYouPaid',
      type: 'EXPENSE',
      relationship: 'PAID_FOR',
      icon: Icons.groups,
      sortOrder: 5,
    ),
    // --- Expense + Payable (PAID_BY) ---
/*    
    TransactionScenario(
      id: 'scenarioFriendPaidMeal',
      type: 'EXPENSE',
      relationship: 'PAID_BY',
      icon: Icons.restaurant,
      sortOrder: 10,
    ),
*/
    TransactionScenario(
      id: 'scenarioSomeonePaidBill',
      type: 'EXPENSE',
      relationship: 'PAID_BY',
      icon: Icons.receipt,
      sortOrder: 11,
    ),
/*
    TransactionScenario(
      id: 'scenarioColleaguePaidForYou',
      type: 'EXPENSE',
      relationship: 'PAID_BY',
      icon: Icons.payments,
      sortOrder: 12,
    ),
*/
    TransactionScenario(
      id: 'scenarioSplitTheyPaid',
      type: 'EXPENSE',
      relationship: 'PAID_BY',
      icon: Icons.groups,
      sortOrder: 13,
    ),
    TransactionScenario(
      id: 'scenarioPaySomeoneForServices',
      type: 'EXPENSE',
      relationship: 'PAID_BY',
      icon: Icons.miscellaneous_services,
      sortOrder: 14,
    ),
    // --- Income + Payable (RECEIVED_FROM) ---
/*
    TransactionScenario(
      id: 'scenarioBorrowedCash',
      type: 'INCOME',
      relationship: 'RECEIVED_FROM',
      icon: Icons.account_balance_wallet,
      sortOrder: 20,
    ),
*/
    TransactionScenario(
      id: 'scenarioLoanReceived',
      type: 'INCOME',
      relationship: 'RECEIVED_FROM',
      icon: Icons.handshake,
      sortOrder: 21,
    ),
/*
    TransactionScenario(
      id: 'scenarioBorrowedFromContact',
      type: 'INCOME',
      relationship: 'RECEIVED_FROM',
      icon: Icons.person,
      sortOrder: 22,
    ),
*/
    TransactionScenario(
      id: 'scenarioSalaryAdvance',
      type: 'INCOME',
      relationship: 'RECEIVED_FROM',
      icon: Icons.work,
      sortOrder: 23,
    ),
/*
    TransactionScenario(
      id: 'scenarioReceivedToRepay',
      type: 'INCOME',
      relationship: 'RECEIVED_FROM',
      icon: Icons.reply,
      sortOrder: 24,
    ),
*/
    // --- Income + Receivable (WILL_RECEIVE) ---
/*
    TransactionScenario(
      id: 'scenarioSalaryPending',
      type: 'INCOME',
      relationship: 'WILL_RECEIVE',
      icon: Icons.work,
      sortOrder: 30,
    ),
*/
    TransactionScenario(
      id: 'scenarioClientPaymentPending',
      type: 'INCOME',
      relationship: 'WILL_RECEIVE',
      icon: Icons.business,
      sortOrder: 31,
    ),
    TransactionScenario(
      id: 'scenarioPaymentPending',
      type: 'INCOME',
      relationship: 'WILL_RECEIVE',
      icon: Icons.person,
      sortOrder: 32,
    ),
    TransactionScenario(
      id: 'scenarioRentPending',
      type: 'INCOME',
      relationship: 'WILL_RECEIVE',
      icon: Icons.home,
      sortOrder: 33,
    ),
    TransactionScenario(
      id: 'scenarioSalePending',
      type: 'INCOME',
      relationship: 'WILL_RECEIVE',
      icon: Icons.sell,
      sortOrder: 34,
    ),
/*
    TransactionScenario(
      id: 'scenarioInvoicePending',
      type: 'INCOME',
      relationship: 'WILL_RECEIVE',
      icon: Icons.description,
      sortOrder: 35,
    ),
*/
    // --- Expense only ---
    TransactionScenario(
      id: 'scenarioPersonalExpense',
      type: 'EXPENSE',
      relationship: null,
      icon: Icons.shopping_bag,
      sortOrder: 40,
    ),
    TransactionScenario(
      id: 'scenarioBillPaid',
      type: 'EXPENSE',
      relationship: null,
      icon: Icons.receipt,
      sortOrder: 41,
    ),
    TransactionScenario(
      id: 'scenarioSubscription',
      type: 'EXPENSE',
      relationship: null,
      icon: Icons.subscriptions,
      sortOrder: 42,
    ),
    // --- Income only ---
    TransactionScenario(
      id: 'scenarioSalaryReceived',
      type: 'INCOME',
      relationship: null,
      icon: Icons.payments,
      sortOrder: 50,
    ),
/*
    TransactionScenario(
      id: 'scenarioFreelanceIncome',
      type: 'INCOME',
      relationship: null,
      icon: Icons.work,
      sortOrder: 51,
    ),

    TransactionScenario(
      id: 'scenarioGiftReceived',
      type: 'INCOME',
      relationship: null,
      icon: Icons.card_giftcard,
      sortOrder: 52,
    ),

    TransactionScenario(
      id: 'scenarioRefundReceived',
      type: 'INCOME',
      relationship: null,
      icon: Icons.replay,
      sortOrder: 53,
    ),
*/
  ];
}
