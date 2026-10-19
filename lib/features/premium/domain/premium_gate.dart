import 'dart:math';
import 'package:flutter/material.dart' hide Category;
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
import 'package:flowpaisa/features/categories/data/categories_repository.dart';
import 'package:flowpaisa/features/transactions/data/schedules_repository.dart';

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

  final config = PremiumGate.featureRegistry['transactions']!;
  return PremiumGate._calculateLimits(config.dailyLimit!, config.monthlyLimit!,
      dailyUsed, monthlyUsed);
});

final receivableLimitsProvider =
    FutureProvider.autoDispose<UsageLimits>((ref) async {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return UsageLimits.unlimited();

  final tracker = ref.read(usageTrackerRepositoryProvider);
  final dailyUsed = await tracker.getReceivableCountToday();
  final monthlyUsed = await tracker.getReceivableCountThisMonth();

  final config = PremiumGate.featureRegistry['receivables']!;
  return PremiumGate._calculateLimits(config.dailyLimit!, config.monthlyLimit!,
      dailyUsed, monthlyUsed);
});

final payableLimitsProvider =
    FutureProvider.autoDispose<UsageLimits>((ref) async {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return UsageLimits.unlimited();

  final tracker = ref.read(usageTrackerRepositoryProvider);
  final dailyUsed = await tracker.getPayableCountToday();
  final monthlyUsed = await tracker.getPayableCountThisMonth();

  final config = PremiumGate.featureRegistry['payables']!;
  return PremiumGate._calculateLimits(config.dailyLimit!, config.monthlyLimit!,
      dailyUsed, monthlyUsed);
});

final contactLimitsProvider =
    FutureProvider.autoDispose<TotalLimits>((ref) async {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return TotalLimits.unlimited();

  // Watch contacts list
  final contacts = await ref.watch(contactsListProvider.future);
  final config = PremiumGate.featureRegistry['contacts']!;
  final used = contacts.length;

  return TotalLimits(
    remaining: max<int>(0, config.totalLimit! - used),
    canAdd: used < config.totalLimit!,
    total: config.totalLimit!,
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

  final config = PremiumGate.featureRegistry['categories']!;
  return TotalLimits(
    remaining: max<int>(0, config.totalLimit! - used),
    canAdd: used < config.totalLimit!,
    total: config.totalLimit!,
    used: used,
  );
});

final scheduleLimitsProvider =
    FutureProvider.autoDispose<TotalLimits>((ref) async {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return TotalLimits.unlimited();

  final repository = ref.read(schedulesRepositoryProvider);
  final used = await repository.getScheduleCount();

  final config = PremiumGate.featureRegistry['schedules']!;
  return TotalLimits(
    remaining: max<int>(0, config.totalLimit! - used),
    canAdd: used < config.totalLimit!,
    total: config.totalLimit!,
    used: used,
  );
});

final cashbookLimitsProvider = Provider.autoDispose<TotalLimits>((ref) {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return TotalLimits.unlimited();

  final cashbooks = ref.watch(cashbooksProvider);
  final used = cashbooks.length;

  final config = PremiumGate.featureRegistry['cashbooks']!;
  return TotalLimits(
    remaining: max<int>(0, config.totalLimit! - used),
    canAdd: used < config.totalLimit!,
    total: config.totalLimit!,
    used: used,
  );
});

final smartParsingLimitsProvider =
    FutureProvider.autoDispose<UsageLimits>((ref) async {
  final isPremium = ref.watch(premiumProvider).isPremium;
  if (isPremium) return UsageLimits.unlimited();

  final tracker = ref.read(usageTrackerRepositoryProvider);
  final monthlyUsed = tracker.getSmartParsingCountThisMonth();

  final config = PremiumGate.featureRegistry['smart_parsing']!;
  return PremiumGate._calculateLimits(config.monthlyLimit!, config.monthlyLimit!,
      monthlyUsed, monthlyUsed);
});

/// Defines the type of limit enforcement for a feature
enum LimitType {
  total, // Uses addSeq for "soft locking" (e.g., max 5 categories)
  usage  // Uses daily/monthly counters (e.g., 10 transactions/day)
}

/// Configuration for a premium feature
class PremiumFeatureConfig {
  final String name;
  final LimitType limitType;
  final int? totalLimit;
  final int? dailyLimit;
  final int? monthlyLimit;
  final String? seqFieldName; // e.g., 'addSeq' or 'budgetSeq'

  const PremiumFeatureConfig({
    required this.name,
    required this.limitType,
    this.totalLimit,
    this.dailyLimit,
    this.monthlyLimit,
    this.seqFieldName,
  });
}

class PremiumGate {
  // Central Registry of Premium Features and their enforcement logic
  static const Map<String, PremiumFeatureConfig> featureRegistry = {
    'contacts': PremiumFeatureConfig(
      name: 'Contacts',
      limitType: LimitType.total,
      totalLimit: 10,
      seqFieldName: 'addSeq',
    ),
    'categories': PremiumFeatureConfig(
      name: 'Categories',
      limitType: LimitType.total,
      totalLimit: 5,
      seqFieldName: 'addSeq',
    ),
    'category_budgets': PremiumFeatureConfig(
      name: 'Category Budgets',
      limitType: LimitType.total,
      totalLimit: 1,
      seqFieldName: 'budgetSeq',
    ),
    'accounts': PremiumFeatureConfig(
      name: 'Accounts',
      limitType: LimitType.total,
      totalLimit: 1,
      seqFieldName: 'addSeq',
    ),
    'schedules': PremiumFeatureConfig(
      name: 'Transaction Schedules',
      limitType: LimitType.total,
      totalLimit: 2,
      seqFieldName: 'addSeq',
    ),
    'cashbooks': PremiumFeatureConfig(
      name: 'Cashbooks',
      limitType: LimitType.total,
      totalLimit: 2,
      seqFieldName: 'addSeq',
    ),
    'transactions': PremiumFeatureConfig(
      name: 'Transactions',
      limitType: LimitType.usage,
      dailyLimit: 10,
      monthlyLimit: 30,
    ),
    'receivables': PremiumFeatureConfig(
      name: 'Receivables',
      limitType: LimitType.usage,
      dailyLimit: 3,
      monthlyLimit: 10,
    ),
    'payables': PremiumFeatureConfig(
      name: 'Payables',
      limitType: LimitType.usage,
      dailyLimit: 3,
      monthlyLimit: 10,
    ),
    'smart_parsing': PremiumFeatureConfig(
      name: 'Smart Parsing',
      limitType: LimitType.usage,
      monthlyLimit: 10,
    ),
  };

  // Legacy constants maintained for UI compatibility (pointing to registry)
  static int get contactTotalLimit => featureRegistry['contacts']!.totalLimit!;
  static int get categoryTotalLimit => featureRegistry['categories']!.totalLimit!;
  static int get scheduleTotalLimit => featureRegistry['schedules']!.totalLimit!;
  static int get cashbookTotalLimit => featureRegistry['cashbooks']!.totalLimit!;
  static int get smartParsingMonthlyLimit => featureRegistry['smart_parsing']!.monthlyLimit!;
  static int get accountTotalLimit => featureRegistry['accounts']!.totalLimit!;
  static int get categoryBudgetTotalLimit => featureRegistry['category_budgets']!.totalLimit!;

  // Internal usage limits (pointing to registry)
  static int get _transactionDailyLimit => featureRegistry['transactions']!.dailyLimit!;
  static int get _transactionMonthlyLimit => featureRegistry['transactions']!.monthlyLimit!;
  static int get _receivableDailyLimit => featureRegistry['receivables']!.dailyLimit!;
  static int get _receivableMonthlyLimit => featureRegistry['receivables']!.monthlyLimit!;
  static int get _payableDailyLimit => featureRegistry['payables']!.dailyLimit!;
  static int get _payableMonthlyLimit => featureRegistry['payables']!.monthlyLimit!;

  // Helper to check if a feature uses sequence-based locking
  static bool usesSequenceLocking(String featureKey) => 
      featureRegistry[featureKey]?.limitType == LimitType.total;

  // Helper to check premium status (using read for callbacks)
  static bool isPremium(WidgetRef ref) {
    return ref.read(premiumProvider).isPremiumActive;
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
    final used = contacts.where((c) => (c.addSeq ?? 0) <= contactTotalLimit).length;

    return TotalLimits(
      remaining: max<int>(0, contactTotalLimit - used),
      canAdd: used < contactTotalLimit,
      total: contactTotalLimit,
      used: used,
    );
  }

  static Future<TotalLimits> getCategoryLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return TotalLimits.unlimited();
    }

    final expenses = await ref.read(categoriesByTypeProvider('EXPENSE').future);
    final incomes = await ref.read(categoriesByTypeProvider('INCOME').future);
    // Only count custom categories (isDefault == false) that are within the limit
    final customExpenses = expenses.where((c) => !c.isDefault && (c.addSeq ?? 0) <= categoryTotalLimit).toList();
    final customIncomes = incomes.where((c) => !c.isDefault && (c.addSeq ?? 0) <= categoryTotalLimit).toList();
    final used = customExpenses.length + customIncomes.length;

    return TotalLimits(
      remaining: max<int>(0, categoryTotalLimit - used),
      canAdd: used < categoryTotalLimit,
      total: categoryTotalLimit,
      used: used,
    );
  }

  static Future<TotalLimits> getScheduleLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return TotalLimits.unlimited();
    }

    final repository = ref.read(schedulesRepositoryProvider);
    final schedules = await repository.getAllSchedules();
    final used = schedules.where((s) => (s.addSeq ?? 0) <= scheduleTotalLimit).length;

    return TotalLimits(
      remaining: max<int>(0, scheduleTotalLimit - used),
      canAdd: used < scheduleTotalLimit,
      total: scheduleTotalLimit,
      used: used,
    );
  }

  static TotalLimits getCashbookLimits(WidgetRef ref) {
    if (isPremium(ref)) {
      return TotalLimits.unlimited();
    }

    final cashbooks = ref.read(cashbooksProvider);
    final used = cashbooks.where((c) => (c.addSeq ?? 0) <= cashbookTotalLimit).length;

    return TotalLimits(
      remaining: max<int>(0, cashbookTotalLimit - used),
      canAdd: used < cashbookTotalLimit,
      total: cashbookTotalLimit,
      used: used,
    );
  }

  static Future<UsageLimits> getSmartParsingLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return UsageLimits.unlimited();
    }

    final tracker = ref.read(usageTrackerRepositoryProvider);
    final monthlyUsed = tracker.getSmartParsingCountThisMonth();

    return _calculateLimits(smartParsingMonthlyLimit,
        smartParsingMonthlyLimit, monthlyUsed, monthlyUsed);
  }

  static Future<TotalLimits> getAccountLimits(WidgetRef ref) async {
    if (isPremium(ref)) {
      return TotalLimits.unlimited();
    }

    final accountsAsync = ref.read(accountsStreamProvider);
    final List<Account> accounts;
    if (accountsAsync.hasValue) {
      accounts = accountsAsync.value!;
    } else {
      accounts = await ref.read(accountsStreamProvider.future);
    }
    final used = accounts.where((a) => (a.addSeq ?? 0) <= accountTotalLimit).length;

    return TotalLimits(
      remaining: max(0, accountTotalLimit - used),
      canAdd: used < accountTotalLimit,
      total: accountTotalLimit,
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
              (c.monthlyBudget != null ||
                  c.quarterlyBudget != null ||
                  c.yearlyBudget != null) &&
              (c.budgetSeq ?? 0) <= categoryBudgetTotalLimit)
          .length;

      return TotalLimits(
        remaining: max(0, categoryBudgetTotalLimit - used),
        canAdd: used < categoryBudgetTotalLimit,
        total: categoryBudgetTotalLimit,
        used: used,
      );
    } catch (e) {
      // Fallback to allowing if check fails to avoid blocking user
      return TotalLimits(
        remaining: 0,
        canAdd: true,
        total: categoryBudgetTotalLimit,
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
