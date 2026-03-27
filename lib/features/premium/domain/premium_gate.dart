import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/data/usage_tracker_repository.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';

// Providers for dependencies
final usageTrackerRepositoryProvider = Provider<UsageTrackerRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UsageTrackerRepository(prefs);
});

// LIMIT PROVIDERS
// These providers automatically re-run when dependencies change

final transactionLimitsProvider =
    FutureProvider.autoDispose<UsageLimits>((ref) async {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return UsageLimits.unlimited();

  // Watch usage tracker (we need to invalidate this provider manually when counts change)
  final tracker = ref.read(usageTrackerRepositoryProvider);
  final dailyUsed = await tracker.getTransactionCountToday();
  final monthlyUsed = await tracker.getTransactionCountThisMonth();

  return PremiumGate._calculateLimits(PremiumGate._transactionDailyLimit,
      PremiumGate._transactionMonthlyLimit, dailyUsed, monthlyUsed);
});

final receivableLimitsProvider =
    FutureProvider.autoDispose<UsageLimits>((ref) async {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return UsageLimits.unlimited();

  final tracker = ref.read(usageTrackerRepositoryProvider);
  final dailyUsed = await tracker.getReceivableCountToday();
  final monthlyUsed = await tracker.getReceivableCountThisMonth();

  return PremiumGate._calculateLimits(PremiumGate._receivableDailyLimit,
      PremiumGate._receivableMonthlyLimit, dailyUsed, monthlyUsed);
});

final payableLimitsProvider =
    FutureProvider.autoDispose<UsageLimits>((ref) async {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return UsageLimits.unlimited();

  final tracker = ref.read(usageTrackerRepositoryProvider);
  final dailyUsed = await tracker.getPayableCountToday();
  final monthlyUsed = await tracker.getPayableCountThisMonth();

  return PremiumGate._calculateLimits(PremiumGate._payableDailyLimit,
      PremiumGate._payableMonthlyLimit, dailyUsed, monthlyUsed);
});

final contactLimitsProvider =
    FutureProvider.autoDispose<TotalLimits>((ref) async {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return TotalLimits.unlimited();

  // Watch contacts list
  final contacts = await ref.watch(contactsListProvider.future);
  final used = contacts.length;

  return TotalLimits(
    remaining: max<int>(0, PremiumGate._contactTotalLimit - used),
    canAdd: used < PremiumGate._contactTotalLimit,
    total: PremiumGate._contactTotalLimit,
    used: used,
  );
});

final categoryLimitsProvider =
    FutureProvider.autoDispose<TotalLimits>((ref) async {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return TotalLimits.unlimited();

  // Watch categories list (we need both types, but only count custom categories)
  final expenses = await ref.watch(categoriesByTypeProvider('EXPENSE').future);
  final incomes = await ref.watch(categoriesByTypeProvider('INCOME').future);
  // Only count custom categories (isDefault == false)
  final customExpenses = expenses.where((c) => !c.isDefault).toList();
  final customIncomes = incomes.where((c) => !c.isDefault).toList();
  final used = customExpenses.length + customIncomes.length;

  return TotalLimits(
    remaining: max<int>(0, PremiumGate._categoryTotalLimit - used),
    canAdd: used < PremiumGate._categoryTotalLimit,
    total: PremiumGate._categoryTotalLimit,
    used: used,
  );
});

final scheduleLimitsProvider =
    FutureProvider.autoDispose<TotalLimits>((ref) async {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return TotalLimits.unlimited();

  final repository = ref.read(schedulesRepositoryProvider);
  final used = await repository.getScheduleCount();

  return TotalLimits(
    remaining: max<int>(0, PremiumGate._scheduleTotalLimit - used),
    canAdd: used < PremiumGate._scheduleTotalLimit,
    total: PremiumGate._scheduleTotalLimit,
    used: used,
  );
});

final cashbookLimitsProvider = Provider.autoDispose<TotalLimits>((ref) {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return TotalLimits.unlimited();

  final cashbooks = ref.watch(cashbooksProvider);
  final used = cashbooks.length;

  return TotalLimits(
    remaining: max<int>(0, PremiumGate._cashbookTotalLimit - used),
    canAdd: used < PremiumGate._cashbookTotalLimit,
    total: PremiumGate._cashbookTotalLimit,
    used: used,
  );
});

final smartParsingLimitsProvider =
    FutureProvider.autoDispose<UsageLimits>((ref) async {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return UsageLimits.unlimited();

  final tracker = ref.read(usageTrackerRepositoryProvider);
  final monthlyUsed = tracker.getSmartParsingCountThisMonth();

  return PremiumGate._calculateLimits(PremiumGate._smartParsingMonthlyLimit,
      PremiumGate._smartParsingMonthlyLimit, monthlyUsed, monthlyUsed);
});

class PremiumGate {
  // Limits Configuration
  static const int _transactionDailyLimit = 10;
  static const int _transactionMonthlyLimit = 30;

  static const int _receivableDailyLimit = 3;
  static const int _receivableMonthlyLimit = 10;

  static const int _payableDailyLimit = 3;
  static const int _payableMonthlyLimit = 10;

  static const int _contactTotalLimit = 10;
  static const int _categoryTotalLimit = 5;
  static const int _scheduleTotalLimit = 2;
  static const int _cashbookTotalLimit = 2; // 1 default + 1 extra
  static const int _smartParsingMonthlyLimit = 10;
  static const int _accountTotalLimit = 1;
  static const int _categoryBudgetTotalLimit = 1;

  // Helper to check premium status (using read for callbacks)
  static bool isPremium(WidgetRef ref) {
    final state = ref.read(premiumProvider);
    if (!state.isPremium) return false;

    // If it's lifetime, it never expires
    if (state.subscriptionType == 'lifetime') return true;

    // If it's a subscription, check expiry date
    if (state.expiryDate != null) {
      return state.expiryDate!.isAfter(DateTime.now());
    }

    // Fallback for legacy premium status without type/expiry
    return true;
  }

  // --- Public API for getting limits ---

  static Future<UsageLimits> getTransactionLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return UsageLimits.unlimited();
    }

    final tracker = ref.read(usageTrackerRepositoryProvider);
    final dailyUsed = await tracker.getTransactionCountToday();
    final monthlyUsed = await tracker.getTransactionCountThisMonth();

    return _calculateLimits(_transactionDailyLimit, _transactionMonthlyLimit,
        dailyUsed, monthlyUsed);
  }

  static Future<UsageLimits> getReceivableLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return UsageLimits.unlimited();
    }

    final tracker = ref.read(usageTrackerRepositoryProvider);
    final dailyUsed = await tracker.getReceivableCountToday();
    final monthlyUsed = await tracker.getReceivableCountThisMonth();

    return _calculateLimits(
        _receivableDailyLimit, _receivableMonthlyLimit, dailyUsed, monthlyUsed);
  }

  static Future<UsageLimits> getPayableLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return UsageLimits.unlimited();
    }

    final tracker = ref.read(usageTrackerRepositoryProvider);
    final dailyUsed = await tracker.getPayableCountToday();
    final monthlyUsed = await tracker.getPayableCountThisMonth();

    return _calculateLimits(
        _payableDailyLimit, _payableMonthlyLimit, dailyUsed, monthlyUsed);
  }

  static Future<TotalLimits> getContactLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return TotalLimits.unlimited();
    }

    final contacts = await ref.read(contactsListProvider.future);
    final used = contacts.length;

    return TotalLimits(
      remaining: max<int>(0, _contactTotalLimit - used),
      canAdd: used < _contactTotalLimit,
      total: _contactTotalLimit,
      used: used,
    );
  }

  static Future<TotalLimits> getCategoryLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return TotalLimits.unlimited();
    }

    final expenses = await ref.read(categoriesByTypeProvider('EXPENSE').future);
    final incomes = await ref.read(categoriesByTypeProvider('INCOME').future);
    // Only count custom categories (isDefault == false)
    final customExpenses = expenses.where((c) => !c.isDefault).toList();
    final customIncomes = incomes.where((c) => !c.isDefault).toList();
    final used = customExpenses.length + customIncomes.length;

    return TotalLimits(
      remaining: max<int>(0, _categoryTotalLimit - used),
      canAdd: used < _categoryTotalLimit,
      total: _categoryTotalLimit,
      used: used,
    );
  }

  static Future<TotalLimits> getScheduleLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return TotalLimits.unlimited();
    }

    final repository = ref.read(schedulesRepositoryProvider);
    final used = await repository.getScheduleCount();

    return TotalLimits(
      remaining: max<int>(0, _scheduleTotalLimit - used),
      canAdd: used < _scheduleTotalLimit,
      total: _scheduleTotalLimit,
      used: used,
    );
  }

  static TotalLimits getCashbookLimits(WidgetRef ref) {
    if (isPremium(ref)) {
      return TotalLimits.unlimited();
    }

    final cashbooks = ref.read(cashbooksProvider);
    final used = cashbooks.length;

    return TotalLimits(
      remaining: max<int>(0, _cashbookTotalLimit - used),
      canAdd: used < _cashbookTotalLimit,
      total: _cashbookTotalLimit,
      used: used,
    );
  }

  static Future<UsageLimits> getSmartParsingLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return UsageLimits.unlimited();
    }

    final tracker = ref.read(usageTrackerRepositoryProvider);
    final monthlyUsed = tracker.getSmartParsingCountThisMonth();

    return _calculateLimits(_smartParsingMonthlyLimit,
        _smartParsingMonthlyLimit, monthlyUsed, monthlyUsed);
  }

  static Future<TotalLimits> getAccountLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return TotalLimits.unlimited();
    }

    final accountsAsync = ref.read(accountsStreamProvider);
    final List accounts;
    if (accountsAsync.hasValue) {
      accounts = accountsAsync.value!;
    } else {
      accounts = await ref.read(accountsStreamProvider.future);
    }
    final used = accounts.length;

    return TotalLimits(
      remaining: max(0, _accountTotalLimit - used),
      canAdd: used < _accountTotalLimit,
      total: _accountTotalLimit,
      used: used,
    );
  }

  static Future<TotalLimits> getCategoryBudgetLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return TotalLimits.unlimited();
    }

    try {
      // Fetch categories directly from repository to avoid stream hanging issues
      final repo = ref.read(categoriesRepositoryProvider);
      final categories = await repo.getAllCategories();

      final used = categories
          .where((c) =>
              c.monthlyBudget != null ||
              c.quarterlyBudget != null ||
              c.yearlyBudget != null)
          .length;

      return TotalLimits(
        remaining: max(0, _categoryBudgetTotalLimit - used),
        canAdd: used < _categoryBudgetTotalLimit,
        total: _categoryBudgetTotalLimit,
        used: used,
      );
    } catch (e) {
      // Fallback to allowing if check fails to avoid blocking user
      return TotalLimits(
        remaining: 0,
        canAdd: true,
        total: _categoryBudgetTotalLimit,
        used: 0,
      );
    }
  }

  // --- Internal Calculation Logic ---

  static UsageLimits _calculateLimits(
      int dailyLimit, int monthlyLimit, int usedToday, int usedThisMonth) {
    int dailyRemaining = dailyLimit - usedToday;
    int monthlyRemaining = monthlyLimit - usedThisMonth;

    // The effective remaining is the minimum of both
    int effectiveRemaining = min(dailyRemaining, monthlyRemaining);

    return UsageLimits(
      dailyRemaining: max(0, dailyRemaining),
      monthlyRemaining: max(0, monthlyRemaining),
      canAdd: effectiveRemaining > 0,
      dailyTotal: dailyLimit,
      monthlyTotal: monthlyLimit,
      dailyUsed: usedToday,
      monthlyUsed: usedThisMonth,
    );
  }

  // --- Dialogs ---

  static void showPremiumDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
    );
  }

  static void showLimitReachedDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Limit Reached'),
          ],
        ),
        content: Text(
          'You have reached the free limit for $feature. \n\n'
          'Upgrade to Premium for unlimited access and more features!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              showPremiumDialog(context);
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}

class UsageLimits {
  final int dailyRemaining;
  final int monthlyRemaining;
  final bool canAdd;
  final int dailyTotal;
  final int monthlyTotal;
  final int dailyUsed;
  final int monthlyUsed;
  final bool isUnlimited;

  UsageLimits({
    required this.dailyRemaining,
    required this.monthlyRemaining,
    required this.canAdd,
    required this.dailyTotal,
    required this.monthlyTotal,
    required this.dailyUsed,
    required this.monthlyUsed,
    this.isUnlimited = false,
  });

  factory UsageLimits.unlimited() {
    return UsageLimits(
      dailyRemaining: 9999,
      monthlyRemaining: 9999,
      canAdd: true,
      dailyTotal: 9999,
      monthlyTotal: 9999,
      dailyUsed: 0,
      monthlyUsed: 0,
      isUnlimited: true,
    );
  }
}

class TotalLimits {
  final int remaining;
  final bool canAdd;
  final int total;
  final int used;
  final bool isUnlimited;

  TotalLimits({
    required this.remaining,
    required this.canAdd,
    required this.total,
    required this.used,
    this.isUnlimited = false,
  });

  factory TotalLimits.unlimited() {
    return TotalLimits(
      remaining: 9999,
      canAdd: true,
      total: 9999,
      used: 0,
      isUnlimited: true,
    );
  }
}
