import 'package:flowpaisa/core/database/database.dart';

/// Account types
enum AccountType {
  cash,
  bank,
  savings,
  creditCard;

  String get value {
    switch (this) {
      case AccountType.cash:
        return 'CASH';
      case AccountType.bank:
        return 'BANK';
      case AccountType.savings:
        return 'SAVINGS';
      case AccountType.creditCard:
        return 'CREDIT_CARD';
    }
  }

  static AccountType fromValue(String value) {
    switch (value.toUpperCase()) {
      case 'CASH':
        return AccountType.cash;
      case 'BANK':
        return AccountType.bank;
      case 'SAVINGS':
        return AccountType.savings;
      case 'CREDIT_CARD':
        return AccountType.creditCard;
      default:
        return AccountType.cash;
    }
  }

  bool get isCreditCard => this == AccountType.creditCard;

  /// Credit card balance is a liability — negative means you owe money
  bool get balanceIsLiability => this == AccountType.creditCard;
}

/// Account with computed balance
class AccountWithBalance {
  final Account account;
  final double balance;

  /// Only for credit cards: amount currently billed and due
  final double? dueAmount;

  /// Only for credit cards: new charges not yet in a billing statement
  final double? unbilledAmount;

  AccountWithBalance({
    required this.account,
    required this.balance,
    this.dueAmount,
    this.unbilledAmount,
  });

  AccountType get type => AccountType.fromValue(account.type);

  /// Available credit for credit cards.
  /// Capped at [creditLimit] — overpayment doesn't inflate available credit.
  double? get availableCredit {
    if (!type.isCreditCard) return null;
    final limit = account.creditLimit ?? 0.0;
    return (limit + balance).clamp(0.0, limit);
  }

  /// Credit balance when card is overpaid (balance > 0).
  /// Represents money the bank owes the user.
  double get creditBalance => balance > 0 ? balance : 0.0;

  /// Display balance — always positive for UI, context determines meaning
  double get displayBalance => balance.abs();

  /// True if the account has a negative balance (cash/bank overdrawn, or credit card has outstanding)
  bool get isNegative => balance < 0;
}

/// Transfer with account details for display
class AccountTransferWithDetails {
  final AccountTransfer transfer;
  final Account? fromAccount;
  final Account? toAccount;

  AccountTransferWithDetails({
    required this.transfer,
    this.fromAccount,
    this.toAccount,
  });
}
