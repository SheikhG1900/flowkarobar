import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/accounts/data/accounts_repository.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AccountsRepository(db);
});

/// Stream of all active accounts (without balance — lightweight)
final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountsRepositoryProvider).watchAllAccounts();
});

/// Stream of all accounts with computed balances
final accountsWithBalanceProvider =
    StreamProvider<List<AccountWithBalance>>((ref) {
  return ref.watch(accountsRepositoryProvider).watchAllAccountsWithBalance();
});

/// Single account with balance; stream refreshes on transfers & transactions.
/// (Named distinctly from any prior FutureProvider to avoid hot-reload type cache issues.)
final accountDetailWithBalanceProvider =
    StreamProvider.family<AccountWithBalance?, String>((ref, uuid) {
  // Keep in sync with aggregated balances (dashboard pins, detail screen, etc.).
  ref.watch(accountsWithBalanceProvider);
  return ref
      .watch(accountsRepositoryProvider)
      .watchAccountWithBalance(uuid);
});

/// Whether user has at least one account configured.
/// Uses [AsyncValue.asData] (Riverpod 3) so we read the latest emitted list; while
/// the stream is still loading before the first event, this is false until data arrives.
final hasAccountsProvider = Provider<bool>((ref) {
  final accounts = ref.watch(accountsStreamProvider);
  final data = accounts.asData;
  if (data == null) return false;
  return data.value.isNotEmpty;
});

/// Accounts valid for INCOME (excludes CREDIT_CARD)
final incomeAccountsProvider = Provider<List<Account>>((ref) {
  final accounts = ref.watch(accountsStreamProvider);
  return accounts
          .whenData((list) => list
              .where((a) =>
                  AccountType.fromValue(a.type) != AccountType.creditCard)
              .toList())
          .value ??
      [];
});

/// Accounts valid for EXPENSE (all types)
final expenseAccountsProvider = Provider<List<Account>>((ref) {
  final accounts = ref.watch(accountsStreamProvider);
  return accounts.value ?? [];
});

/// Stream of all transfers with from/to account details (for recent transfers list).
final allTransfersWithDetailsProvider =
    StreamProvider<List<AccountTransferWithDetails>>((ref) {
  return ref.watch(accountsRepositoryProvider).watchTransfersWithDetails();
});

/// Stream of transfers for a single account with from/to details.
final transfersForAccountProvider =
    StreamProvider.family<List<AccountTransferWithDetails>, String>((ref, accountUuid) {
  return ref
      .watch(accountsRepositoryProvider)
      .watchTransfersForAccountWithDetails(accountUuid);
});
