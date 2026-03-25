import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class AccountSpending {
  final Account account;
  final double totalExpense;
  final double totalIncome;
  AccountSpending({
    required this.account,
    required this.totalExpense,
    required this.totalIncome,
  });
}

class TransferFlowItem {
  final String fromAccountUuid;
  final String toAccountUuid;
  final double totalAmount;
  final int count;
  TransferFlowItem({
    required this.fromAccountUuid,
    required this.toAccountUuid,
    required this.totalAmount,
    required this.count,
  });
}

class AccountsRepository {
  final AppDatabase _db;

  AccountsRepository(this._db);

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  Stream<List<Account>> watchAllAccounts() {
    return (_db.select(_db.accounts)
          ..where((a) => a.isDeleted.equals(false) & a.isActive.equals(true))
          ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
        .watch();
  }

  Future<List<Account>> getAllAccounts() {
    return (_db.select(_db.accounts)
          ..where((a) => a.isDeleted.equals(false) & a.isActive.equals(true))
          ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
        .get();
  }

  Future<Account?> getAccountByUuid(String uuid) {
    return (_db.select(_db.accounts)
          ..where((a) => a.uuid.equals(uuid) & a.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<String> createAccount(AccountsCompanion account) async {
    final uuid = account.uuid.present ? account.uuid.value : const Uuid().v4();
    await _db.into(_db.accounts).insert(
          account.copyWith(
            uuid: Value(uuid),
            isNotSynced: const Value(true),
          ),
        );
    return uuid;
  }

  Future<bool> updateAccount(Account account) {
    return _db.update(_db.accounts).replace(
          account.copyWith(
            updatedAt: DateTime.now(),
            isNotSynced: true,
          ),
        );
  }

  Future<int> deleteAccount(String uuid) {
    return (_db.update(_db.accounts)..where((a) => a.uuid.equals(uuid))).write(
      const AccountsCompanion(
        isDeleted: Value(true),
        isNotSynced: Value(true),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Balance Calculation
  // ---------------------------------------------------------------------------

  /// Calculates the current balance for a single account.
  ///
  /// For CASH/BANK/SAVINGS:
  ///   balance = openingBalance + SUM(income) - SUM(expense) + transfers_in - transfers_out
  ///
  /// For CREDIT_CARD:
  ///   balance = openingBalance (negative) - SUM(expense) + SUM(transfers_in)
  ///   (opening balance is stored as negative to indicate liability)
  Future<double> getAccountBalance(Account account) async {
    final openingDate = account.openingDate;

    // Sum of income transactions processed on this account since openingDate
    final incomeQuery = _db.selectOnly(_db.transactions)
      ..addColumns([_db.transactions.amount.sum()])
      ..where(
        _db.transactions.accountUuid.equals(account.uuid) &
            _db.transactions.type.equals('INCOME') &
            _db.transactions.isDeleted.equals(false) &
            _db.transactions.processedDate.isNotNull() &
            _db.transactions.processedDate.isBiggerOrEqualValue(openingDate),
      );

    // Sum of expense transactions processed on this account since openingDate
    final expenseQuery = _db.selectOnly(_db.transactions)
      ..addColumns([_db.transactions.amount.sum()])
      ..where(
        _db.transactions.accountUuid.equals(account.uuid) &
            _db.transactions.type.equals('EXPENSE') &
            _db.transactions.isDeleted.equals(false) &
            _db.transactions.processedDate.isNotNull() &
            _db.transactions.processedDate.isBiggerOrEqualValue(openingDate),
      );

    // Transfers INTO this account
    final transfersInQuery = _db.selectOnly(_db.accountTransfers)
      ..addColumns([_db.accountTransfers.amount.sum()])
      ..where(
        _db.accountTransfers.toAccountUuid.equals(account.uuid) &
            _db.accountTransfers.isDeleted.equals(false) &
            _db.accountTransfers.date.isBiggerOrEqualValue(openingDate),
      );

    // Transfers OUT of this account
    final transfersOutQuery = _db.selectOnly(_db.accountTransfers)
      ..addColumns([_db.accountTransfers.amount.sum()])
      ..where(
        _db.accountTransfers.fromAccountUuid.equals(account.uuid) &
            _db.accountTransfers.isDeleted.equals(false) &
            _db.accountTransfers.date.isBiggerOrEqualValue(openingDate),
      );

    final incomeResult = await incomeQuery.getSingle();
    final expenseResult = await expenseQuery.getSingle();
    final transfersInResult = await transfersInQuery.getSingle();
    final transfersOutResult = await transfersOutQuery.getSingle();

    final income = incomeResult.read(_db.transactions.amount.sum()) ?? 0.0;
    final expense = expenseResult.read(_db.transactions.amount.sum()) ?? 0.0;
    final transfersIn =
        transfersInResult.read(_db.accountTransfers.amount.sum()) ?? 0.0;
    final transfersOut =
        transfersOutResult.read(_db.accountTransfers.amount.sum()) ?? 0.0;

    final type = AccountType.fromValue(account.type);
    if (type.isCreditCard) {
      // Credit card: opening balance is negative (liability).
      // Expenses & cash advances (transfersOut) increase liability.
      // Payments (transfersIn) reduce liability.
      return account.openingBalance - expense + transfersIn - transfersOut;
    } else {
      return account.openingBalance + income - expense + transfersIn -
          transfersOut;
    }
  }

  /// Returns balance as a reactive stream (re-emits on any transaction/transfer change).
  Stream<double> watchAccountBalance(Account account) {
    final incomeStream = (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amount.sum()])
          ..where(
            _db.transactions.accountUuid.equals(account.uuid) &
                _db.transactions.type.equals('INCOME') &
                _db.transactions.isDeleted.equals(false) &
                _db.transactions.processedDate.isNotNull() &
                _db.transactions.processedDate
                    .isBiggerOrEqualValue(account.openingDate),
          ))
        .watchSingle()
        .map((r) => r.read(_db.transactions.amount.sum()) ?? 0.0);

    final expenseStream = (_db.selectOnly(_db.transactions)
          ..addColumns([_db.transactions.amount.sum()])
          ..where(
            _db.transactions.accountUuid.equals(account.uuid) &
                _db.transactions.type.equals('EXPENSE') &
                _db.transactions.isDeleted.equals(false) &
                _db.transactions.processedDate.isNotNull() &
                _db.transactions.processedDate
                    .isBiggerOrEqualValue(account.openingDate),
          ))
        .watchSingle()
        .map((r) => r.read(_db.transactions.amount.sum()) ?? 0.0);

    final transfersInStream = (_db.selectOnly(_db.accountTransfers)
          ..addColumns([_db.accountTransfers.amount.sum()])
          ..where(
            _db.accountTransfers.toAccountUuid.equals(account.uuid) &
                _db.accountTransfers.isDeleted.equals(false) &
                _db.accountTransfers.date
                    .isBiggerOrEqualValue(account.openingDate),
          ))
        .watchSingle()
        .map((r) => r.read(_db.accountTransfers.amount.sum()) ?? 0.0);

    final transfersOutStream = (_db.selectOnly(_db.accountTransfers)
          ..addColumns([_db.accountTransfers.amount.sum()])
          ..where(
            _db.accountTransfers.fromAccountUuid.equals(account.uuid) &
                _db.accountTransfers.isDeleted.equals(false) &
                _db.accountTransfers.date
                    .isBiggerOrEqualValue(account.openingDate),
          ))
        .watchSingle()
        .map((r) => r.read(_db.accountTransfers.amount.sum()) ?? 0.0);

    final type = AccountType.fromValue(account.type);

    return incomeStream
        .asyncMap((income) async {
          final expense = await expenseStream.first;
          final transfersIn = await transfersInStream.first;
          final transfersOut = await transfersOutStream.first;
          if (type.isCreditCard) {
            // Expenses & cash advances (transfersOut) increase liability.
            // Payments (transfersIn) reduce liability.
            return account.openingBalance - expense + transfersIn - transfersOut;
          } else {
            return account.openingBalance + income - expense + transfersIn -
                transfersOut;
          }
        });
  }

  /// Calculates the credit card due amount:
  ///   dueAmount = openingBalance (abs) + SUM(expenses up to cycleDate) - SUM(ALL payments since openingDate)
  Future<double> getCreditCardDueAmount(Account account) async {
    if (!AccountType.fromValue(account.type).isCreditCard) return 0.0;

    final cycleDate = _currentCycleDate(account);
    final openingDate = account.openingDate;

    final expenseQuery = _db.selectOnly(_db.transactions)
      ..addColumns([_db.transactions.amount.sum()])
      ..where(
        _db.transactions.accountUuid.equals(account.uuid) &
            _db.transactions.type.equals('EXPENSE') &
            _db.transactions.isDeleted.equals(false) &
            _db.transactions.processedDate.isNotNull() &
            _db.transactions.processedDate.isBiggerOrEqualValue(openingDate) &
            _db.transactions.processedDate.isSmallerOrEqualValue(cycleDate),
      );

    final paymentsQuery = _db.selectOnly(_db.accountTransfers)
      ..addColumns([_db.accountTransfers.amount.sum()])
      ..where(
        _db.accountTransfers.toAccountUuid.equals(account.uuid) &
            _db.accountTransfers.isDeleted.equals(false) &
            _db.accountTransfers.date.isBiggerOrEqualValue(openingDate),
      );

    final expenseResult = await expenseQuery.getSingle();
    final paymentsResult = await paymentsQuery.getSingle();

    final expenses =
        expenseResult.read(_db.transactions.amount.sum()) ?? 0.0;
    final payments =
        paymentsResult.read(_db.accountTransfers.amount.sum()) ?? 0.0;

    final due = account.openingBalance.abs() + expenses - payments;
    return due < 0 ? 0.0 : due;
  }

  /// Unbilled: expenses after the current cycle date
  Future<double> getCreditCardUnbilledAmount(Account account) async {
    if (!AccountType.fromValue(account.type).isCreditCard) return 0.0;
    final cycleDate = _currentCycleDate(account);

    final query = _db.selectOnly(_db.transactions)
      ..addColumns([_db.transactions.amount.sum()])
      ..where(
        _db.transactions.accountUuid.equals(account.uuid) &
            _db.transactions.type.equals('EXPENSE') &
            _db.transactions.isDeleted.equals(false) &
            _db.transactions.processedDate.isNotNull() &
            _db.transactions.processedDate.isBiggerThanValue(cycleDate),
      );

    final result = await query.getSingle();
    return result.read(_db.transactions.amount.sum()) ?? 0.0;
  }

  /// Returns the most recent billing cycle date (on or before today).
  DateTime _currentCycleDate(Account account) {
    final cycleDay = account.billingCycleDay ?? 1;
    final now = DateTime.now();
    final thisMonth =
        DateTime(now.year, now.month, cycleDay.clamp(1, 28));
    if (thisMonth.isAfter(now)) {
      // Use previous month's cycle date
      final prev = DateTime(now.year, now.month - 1, cycleDay.clamp(1, 28));
      return prev;
    }
    return thisMonth;
  }

  /// Returns the next payment due date for a credit card.
  DateTime? getNextDueDate(Account account) {
    if (!AccountType.fromValue(account.type).isCreditCard) return null;
    final dueDays = account.paymentDueDays ?? 0;
    final cycleDate = _currentCycleDate(account);
    return cycleDate.add(Duration(days: dueDays));
  }

  // ---------------------------------------------------------------------------
  // Accounts with Balance (combined)
  // ---------------------------------------------------------------------------

  Future<List<AccountWithBalance>> getAllAccountsWithBalance() async {
    final accs = await getAllAccounts();
    final result = <AccountWithBalance>[];
    for (final acc in accs) {
      final balance = await getAccountBalance(acc);
      double? due;
      double? unbilled;
      if (AccountType.fromValue(acc.type).isCreditCard) {
        due = await getCreditCardDueAmount(acc);
        unbilled = await getCreditCardUnbilledAmount(acc);
      }
      result.add(AccountWithBalance(
        account: acc,
        balance: balance,
        dueAmount: due,
        unbilledAmount: unbilled,
      ));
    }
    return result;
  }

  Stream<List<AccountWithBalance>> watchAllAccountsWithBalance() {
    // Recompute when accounts, transfers, or any transaction change (balances depend on all three).
    return Rx.combineLatest3<List<Account>, List<AccountTransfer>, List<Transaction>,
        List<Account>>(
      watchAllAccounts(),
      _db.select(_db.accountTransfers).watch(),
      _db.select(_db.transactions).watch(),
      (accs, _, __) => accs,
    ).asyncMap((accs) async {
      final result = <AccountWithBalance>[];
      for (final acc in accs) {
        final balance = await getAccountBalance(acc);
        double? due;
        double? unbilled;
        if (AccountType.fromValue(acc.type).isCreditCard) {
          due = await getCreditCardDueAmount(acc);
          unbilled = await getCreditCardUnbilledAmount(acc);
        }
        result.add(AccountWithBalance(
          account: acc,
          balance: balance,
          dueAmount: due,
          unbilledAmount: unbilled,
        ));
      }
      return result;
    });
  }

  /// Single account balance; updates when this account, its transactions, or any transfer changes.
  Stream<AccountWithBalance?> watchAccountWithBalance(String accountUuid) {
    final accountStream = (_db.select(_db.accounts)
          ..where((a) =>
              a.uuid.equals(accountUuid) & a.isDeleted.equals(false)))
        .watch()
        .map((list) => list.isEmpty ? null : list.first);

    final transfersStream = _db.select(_db.accountTransfers).watch();

    final txsStream = (_db.select(_db.transactions)
          ..where((t) =>
              t.accountUuid.equals(accountUuid) & t.isDeleted.equals(false)))
        .watch();

    return Rx.combineLatest3<Account?, List<AccountTransfer>, List<Transaction>,
        Account?>(
      accountStream,
      transfersStream,
      txsStream,
      (acc, _, __) => acc,
    ).asyncMap((acc) async {
      if (acc == null) return null;
      final balance = await getAccountBalance(acc);
      double? due;
      double? unbilled;
      if (AccountType.fromValue(acc.type).isCreditCard) {
        due = await getCreditCardDueAmount(acc);
        unbilled = await getCreditCardUnbilledAmount(acc);
      }
      return AccountWithBalance(
        account: acc,
        balance: balance,
        dueAmount: due,
        unbilledAmount: unbilled,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Account Transfers
  // ---------------------------------------------------------------------------

  Future<String> createTransfer(AccountTransfersCompanion transfer) async {
    final uuid =
        transfer.uuid.present ? transfer.uuid.value : const Uuid().v4();
    await _db.into(_db.accountTransfers).insert(
          transfer.copyWith(
            uuid: Value(uuid),
            isNotSynced: const Value(true),
          ),
        );
    return uuid;
  }

  Future<List<AccountTransfer>> getTransfersForAccount(String accountUuid) {
    return (_db.select(_db.accountTransfers)
          ..where((t) =>
              (t.fromAccountUuid.equals(accountUuid) |
                  t.toAccountUuid.equals(accountUuid)) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Stream<List<AccountTransferWithDetails>> watchTransfersWithDetails() {
    final toAccounts = _db.accounts.createAlias('to_accounts');
    final query = _db.select(_db.accountTransfers).join([
      leftOuterJoin(
        _db.accounts,
        _db.accounts.uuid
            .equalsExp(_db.accountTransfers.fromAccountUuid),
      ),
      leftOuterJoin(
        toAccounts,
        toAccounts.uuid.equalsExp(_db.accountTransfers.toAccountUuid),
      ),
    ]);
    query.where(_db.accountTransfers.isDeleted.equals(false));
    query.orderBy([OrderingTerm.desc(_db.accountTransfers.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return AccountTransferWithDetails(
          transfer: row.readTable(_db.accountTransfers),
          fromAccount: row.readTableOrNull(_db.accounts),
          toAccount: row.readTableOrNull(toAccounts),
        );
      }).toList();
    });
  }

  /// Stream of transfers involving [accountUuid] (as from or to), with both account details.
  Stream<List<AccountTransferWithDetails>> watchTransfersForAccountWithDetails(
    String accountUuid,
  ) {
    final toAccounts = _db.accounts.createAlias('to_accounts');
    final query = _db.select(_db.accountTransfers).join([
      leftOuterJoin(
        _db.accounts,
        _db.accounts.uuid
            .equalsExp(_db.accountTransfers.fromAccountUuid),
      ),
      leftOuterJoin(
        toAccounts,
        toAccounts.uuid.equalsExp(_db.accountTransfers.toAccountUuid),
      ),
    ]);
    query.where(
      _db.accountTransfers.isDeleted.equals(false) &
          (_db.accountTransfers.fromAccountUuid.equals(accountUuid) |
              _db.accountTransfers.toAccountUuid.equals(accountUuid)),
    );
    query.orderBy([OrderingTerm.desc(_db.accountTransfers.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return AccountTransferWithDetails(
          transfer: row.readTable(_db.accountTransfers),
          fromAccount: row.readTableOrNull(_db.accounts),
          toAccount: row.readTableOrNull(toAccounts),
        );
      }).toList();
    });
  }

  Future<int> deleteTransfer(String uuid) {
    return (_db.update(_db.accountTransfers)
          ..where((t) => t.uuid.equals(uuid)))
        .write(const AccountTransfersCompanion(
      isDeleted: Value(true),
      isNotSynced: Value(true),
    ));
  }

  // ---------------------------------------------------------------------------
  // Negative Balance Check
  // ---------------------------------------------------------------------------

  /// Checks if adding an expense of [amount] to [account] would cause a negative balance.
  /// Only meaningful for CASH accounts.
  Future<bool> wouldCauseNegativeBalance(Account account, double amount) async {
    if (AccountType.fromValue(account.type) != AccountType.cash) return false;
    final currentBalance = await getAccountBalance(account);
    return (currentBalance - amount) < 0;
  }

  // ---------------------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------------------

  /// Expense & income totals grouped by account for a date range.
  Future<List<AccountSpending>> getSpendingByAccount(
      DateTime start, DateTime end) async {
    final accounts = await getAllAccounts();
    final List<AccountSpending> result = [];
    for (final acc in accounts) {
      final expenseRow = await (_db.selectOnly(_db.transactions)
            ..addColumns([_db.transactions.amount.sum()])
            ..where(_db.transactions.accountUuid.equals(acc.uuid))
            ..where(_db.transactions.type.equals('EXPENSE'))
            ..where(_db.transactions.isDeleted.equals(false))
            ..where(_db.transactions.processedDate.isNotNull())
            ..where(_db.transactions.date.isBetweenValues(start, end)))
          .getSingle();
      final incomeRow = await (_db.selectOnly(_db.transactions)
            ..addColumns([_db.transactions.amount.sum()])
            ..where(_db.transactions.accountUuid.equals(acc.uuid))
            ..where(_db.transactions.type.equals('INCOME'))
            ..where(_db.transactions.isDeleted.equals(false))
            ..where(_db.transactions.processedDate.isNotNull())
            ..where(_db.transactions.date.isBetweenValues(start, end)))
          .getSingle();
      final expense =
          expenseRow.read(_db.transactions.amount.sum()) ?? 0.0;
      final income =
          incomeRow.read(_db.transactions.amount.sum()) ?? 0.0;
      if (expense > 0 || income > 0) {
        result.add(AccountSpending(
            account: acc, totalExpense: expense, totalIncome: income));
      }
    }
    result.sort(
        (a, b) => b.totalExpense.compareTo(a.totalExpense));
    return result;
  }

  /// Total amount transferred between each account pair in a date range.
  Future<List<TransferFlowItem>> getTransferFlow(
      DateTime start, DateTime end) async {
    final rows = await (_db.select(_db.accountTransfers)
          ..where((t) =>
              t.isDeleted.equals(false) &
              t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.amount)]))
        .get();

    // Group by from+to pair
    final Map<String, TransferFlowItem> map = {};
    for (final t in rows) {
      final key = '${t.fromAccountUuid}→${t.toAccountUuid}';
      if (map.containsKey(key)) {
        map[key] = TransferFlowItem(
          fromAccountUuid: t.fromAccountUuid,
          toAccountUuid: t.toAccountUuid,
          totalAmount: map[key]!.totalAmount + t.amount,
          count: map[key]!.count + 1,
        );
      } else {
        map[key] = TransferFlowItem(
          fromAccountUuid: t.fromAccountUuid,
          toAccountUuid: t.toAccountUuid,
          totalAmount: t.amount,
          count: 1,
        );
      }
    }
    final list = map.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return list;
  }
}
