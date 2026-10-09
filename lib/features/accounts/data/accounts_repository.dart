import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

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

class AccountFlowSummary {
  final Account account;
  final double openingBalance;
  final double closingBalance;
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> transfersInBreakdown; // fromAccountUuid -> amount
  final Map<String, double> transfersOutBreakdown; // toAccountUuid -> amount

  double get totalTransfersIn => transfersInBreakdown.values.fold(0.0, (s, v) => s + v);
  double get totalTransfersOut => transfersOutBreakdown.values.fold(0.0, (s, v) => s + v);

  double get totalInflow => totalIncome + totalTransfersIn;
  double get totalOutflow => totalExpense + totalTransfersOut;
  double get netFlow => totalInflow - totalOutflow;

  AccountFlowSummary({
    required this.account,
    required this.openingBalance,
    required this.closingBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.transfersInBreakdown,
    required this.transfersOutBreakdown,
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

  Future<int> getNextAvailableSeq<T extends HasResultSet>(
      ResultSetImplementation<T, dynamic> table, GeneratedColumn<int> seqColumn) async {
    // Get isDeleted column from the table
    final isDeletedColumn = table.columnsByName['is_deleted'] as GeneratedColumn<bool>?;

    final query = _db.selectOnly(table)
      ..addColumns([seqColumn])
      ..where(seqColumn.isNotNull());

    // Filter out deleted records if the column exists
    if (isDeletedColumn != null) {
      query.where(isDeletedColumn.equals(false));
    }

    query.orderBy([OrderingTerm.asc(seqColumn)]);

    final rows = await query.get();
    final usedSeqs = rows.map((r) => r.read(seqColumn)!).toSet();

    // Start from 1 for new records (0 is reserved for defaults)
    int nextSeq = 1;
    while (usedSeqs.contains(nextSeq)) {
      nextSeq++;
    }
    return nextSeq;
  }

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  Stream<List<Account>> watchAllAccounts() {
    return (_db.select(_db.accounts)
          ..where((a) => a.isDeleted.equals(false))
          ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
        .watch();
  }

  Future<List<Account>> getAllAccounts() {
    return (_db.select(_db.accounts)
          ..where((a) => a.isDeleted.equals(false))
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
    final nextSeq = await getNextAvailableSeq(_db.accounts, _db.accounts.addSeq);
    await _db.into(_db.accounts).insert(
          account.copyWith(
            uuid: Value(uuid),
            isNotSynced: const Value(true),
            addSeq: Value(nextSeq),
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
    // Recompute when this account, its transactions, or ANY transfer change.
    return Rx.combineLatest3<Account?, List<AccountTransfer>, List<Transaction>,
        Account?>(
      _db.select(_db.accounts).watchSingleOrNull(),
      _db.select(_db.accountTransfers).watch(),
      _db.select(_db.transactions).watch(),
      (acc, _, __) => acc,
    ).asyncMap((acc) async {
      if (acc == null) return 0.0;
      return getAccountBalance(acc);
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

  Future<bool> updateTransfer(AccountTransfer transfer) {
    return _db.update(_db.accountTransfers).replace(
          transfer.copyWith(
            updatedAt: DateTime.now(),
            isNotSynced: true,
          ),
        );
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

  /// Get unified account flow summaries (opening/closing balance, inflows, outflows) for a date range.
  Future<List<AccountFlowSummary>> getAccountFlowSummaries(
      DateTime start, DateTime end) async {
    final accounts = await getAllAccounts();
    
    // Fetch all processed non-deleted transactions
    final txs = await (_db.select(_db.transactions)
          ..where((t) => t.isDeleted.equals(false) & t.processedDate.isNotNull()))
        .get();

    // Fetch all non-deleted transfers
    final transfers = await (_db.select(_db.accountTransfers)
          ..where((t) => t.isDeleted.equals(false)))
        .get();

    final List<AccountFlowSummary> summaries = [];

    for (final acc in accounts) {
      final isCreditCard = AccountType.fromValue(acc.type).isCreditCard;
      final openingDate = acc.openingDate;

      // Filter transactions and transfers relevant to this account
      final myTxs = txs.where((t) => t.accountUuid == acc.uuid && (openingDate == null || t.processedDate!.isAfter(openingDate) || t.processedDate!.isAtSameMomentAs(openingDate)));
      final myTransfers = transfers.where((t) => (t.fromAccountUuid == acc.uuid || t.toAccountUuid == acc.uuid) && (openingDate == null || t.date.isAfter(openingDate) || t.date.isAtSameMomentAs(openingDate)));

      // Calculate starting balance before 'start' date
      double balance = isCreditCard ? -acc.openingBalance.abs() : acc.openingBalance;

      final priorTxs = myTxs.where((t) => t.processedDate!.isBefore(start));
      final priorTransfers = myTransfers.where((t) => t.date.isBefore(start));

      for (final tx in priorTxs) {
        final isExpense = tx.type == 'EXPENSE';
        balance += isExpense ? -tx.amount : tx.amount;
      }

      for (final tf in priorTransfers) {
        final isFromThis = tf.fromAccountUuid == acc.uuid;
        balance += isFromThis ? -tf.amount : tf.amount;
      }

      final double openingBalance = balance;

      // Now calculate period figures (between start and end)
      final periodEnd = end.add(const Duration(days: 1)); // inclusive of end day
      final periodTxs = myTxs.where((t) =>
          (t.processedDate!.isAtSameMomentAs(start) || t.processedDate!.isAfter(start)) &&
          t.processedDate!.isBefore(periodEnd));
      
      final periodTransfers = myTransfers.where((t) =>
          (t.date.isAtSameMomentAs(start) || t.date.isAfter(start)) &&
          t.date.isBefore(periodEnd));

      double totalIncome = 0.0;
      double totalExpense = 0.0;
      for (final tx in periodTxs) {
        if (tx.type == 'EXPENSE') {
          totalExpense += tx.amount;
        } else {
          totalIncome += tx.amount;
        }
      }

      final Map<String, double> transfersInBreakdown = {};
      final Map<String, double> transfersOutBreakdown = {};

      for (final tf in periodTransfers) {
        if (tf.fromAccountUuid == acc.uuid) {
          transfersOutBreakdown[tf.toAccountUuid] =
              (transfersOutBreakdown[tf.toAccountUuid] ?? 0.0) + tf.amount;
        } else {
          transfersInBreakdown[tf.fromAccountUuid] =
              (transfersInBreakdown[tf.fromAccountUuid] ?? 0.0) + tf.amount;
        }
      }

      // Calculate closing balance
      double runningBal = openingBalance;
      runningBal += totalIncome - totalExpense;
      runningBal += transfersInBreakdown.values.fold(0.0, (s, v) => s + v);
      runningBal -= transfersOutBreakdown.values.fold(0.0, (s, v) => s + v);

      // Only add to summary if there's any activity or a non-zero opening balance
      final hasActivity = totalIncome > 0 ||
          totalExpense > 0 ||
          transfersInBreakdown.isNotEmpty ||
          transfersOutBreakdown.isNotEmpty;

      if (hasActivity || openingBalance.abs() > 0.01 || runningBal.abs() > 0.01) {
        summaries.add(AccountFlowSummary(
          account: acc,
          openingBalance: openingBalance,
          closingBalance: runningBal,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          transfersInBreakdown: transfersInBreakdown,
          transfersOutBreakdown: transfersOutBreakdown,
        ));
      }
    }

    // Sort by absolute closing balance
    summaries.sort((a, b) => b.closingBalance.abs().compareTo(a.closingBalance.abs()));
    return summaries;
  }

  // ---------------------------------------------------------------------------
  // Account Statement
  // ---------------------------------------------------------------------------

  /// Fetches a unified chronological statement for a specific account.
  ///
  /// Calculates starting balance, running balances, and maps transactions
  /// and transfers to unified StatementEntry objects.
  Future<List<StatementEntry>> getAccountStatement({
    required String accountUuid,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final account = await getAccountByUuid(accountUuid);
    if (account == null) return [];

    final isCreditCard = AccountType.fromValue(account.type).isCreditCard;
    final openingDate = account.openingDate;

    // 1. Fetch all transactions for this account (not deleted, processed)
    final txs = await (_db.select(_db.transactions)
          ..where((t) =>
              t.accountUuid.equals(accountUuid) &
              t.isDeleted.equals(false) &
              t.processedDate.isNotNull() &
              t.processedDate.isBiggerOrEqualValue(openingDate)))
        .get();

    // 2. Fetch all transfers involving this account (not deleted)
    final transfers = await (_db.select(_db.accountTransfers)
          ..where((t) =>
              (t.fromAccountUuid.equals(accountUuid) |
                  t.toAccountUuid.equals(accountUuid)) &
              t.isDeleted.equals(false) &
              t.date.isBiggerOrEqualValue(openingDate)))
        .get();

    // 3. Fetch categories and accounts for descriptive titles
    final categories = await _db.select(_db.categories).get();
    final otherAccounts = await _db.select(_db.accounts).get();

    // 4. Calculate starting balance (balance before startDate)
    // We start with the opening balance (negative for credit card)
    double balance = isCreditCard ? -account.openingBalance.abs() : account.openingBalance;

    // Combine all history prior to startDate to compute starting balance
    final priorTxs = txs.where((t) => t.processedDate!.isBefore(startDate));
    final priorTransfers = transfers.where((t) => t.date.isBefore(startDate));

    for (final tx in priorTxs) {
      final isExpense = tx.type == 'EXPENSE';
      if (isCreditCard) {
        // Credit card: expenses increase liability (decrease balance)
        // incomes decrease liability (increase balance)
        balance += isExpense ? -tx.amount : tx.amount;
      } else {
        // Cash/Bank: income increases balance, expense decreases balance
        balance += isExpense ? -tx.amount : tx.amount;
      }
    }

    for (final tf in priorTransfers) {
      final isFromThis = tf.fromAccountUuid == accountUuid;
      if (isCreditCard) {
        // Credit card: transfer out (from this) increases liability (decreases balance)
        // transfer in (to this) decreases liability (increases balance)
        balance += isFromThis ? -tf.amount : tf.amount;
      } else {
        // Cash/Bank: transfer in increases balance, transfer out decreases balance
        balance += isFromThis ? -tf.amount : tf.amount;
      }
    }

    // 5. Filter transactions and transfers that fall within the period
    final periodTxs = txs.where((t) =>
        t.processedDate!.isAtSameMomentAs(startDate) ||
        t.processedDate!.isAfter(startDate) && t.processedDate!.isBefore(endDate.add(const Duration(days: 1))));

    final periodTransfers = transfers.where((t) =>
        t.date.isAtSameMomentAs(startDate) ||
        t.date.isAfter(startDate) && t.date.isBefore(endDate.add(const Duration(days: 1))));

    // 6. Merge and sort all period items chronologically
    final mergedItems = <({DateTime date, dynamic object})>[];
    for (final tx in periodTxs) {
      mergedItems.add((date: tx.processedDate!, object: tx));
    }
    for (final tf in periodTransfers) {
      mergedItems.add((date: tf.date, object: tf));
    }

    // Sort ascending by date
    mergedItems.sort((a, b) => a.date.compareTo(b.date));

    // 7. Generate StatementEntry list with running balances
    final entries = <StatementEntry>[];
    double runningBal = balance;

    for (final item in mergedItems) {
      final obj = item.object;
      if (obj is Transaction) {
        final isExpense = obj.type == 'EXPENSE';
        final entryType = isExpense ? StatementEntryType.debit : StatementEntryType.credit;
        
        runningBal += isExpense ? -obj.amount : obj.amount;

        final category = categories.firstWhereOrNull((c) => c.uuid == obj.categoryUuid);
        final title = category?.name ?? (isExpense ? 'Expense' : 'Income');

        entries.add(StatementEntry(
          id: obj.uuid,
          date: obj.processedDate!,
          title: title,
          description: obj.description,
          amount: obj.amount,
          entryType: entryType,
          runningBalance: runningBal,
          originalObject: obj,
        ));
      } else if (obj is AccountTransfer) {
        final isFromThis = obj.fromAccountUuid == accountUuid;
        final entryType = isFromThis ? StatementEntryType.debit : StatementEntryType.credit;

        runningBal += isFromThis ? -obj.amount : obj.amount;

        final otherAccountUuid = isFromThis ? obj.toAccountUuid : obj.fromAccountUuid;
        final otherAcc = otherAccounts.firstWhereOrNull((a) => a.uuid == otherAccountUuid);
        final title = isFromThis
            ? 'Transfer to ${otherAcc?.name ?? 'Unknown'}'
            : 'Transfer from ${otherAcc?.name ?? 'Unknown'}';

        entries.add(StatementEntry(
          id: obj.uuid,
          date: obj.date,
          title: title,
          description: obj.description,
          amount: obj.amount,
          entryType: entryType,
          runningBalance: runningBal,
          originalObject: obj,
        ));
      }
    }

    // Return descending (most recent first) for UI presentation
    return entries.reversed.toList();
  }
}
