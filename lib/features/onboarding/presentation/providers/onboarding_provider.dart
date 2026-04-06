import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:flowpaisa/features/onboarding/presentation/screens/onboarding_screen.dart';

/// Tracks whether the marketing intro wizard has been completed (persisted in prefs).
class OnboardingCompletedNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(OnboardingScreen.onboardingKey) ?? false;
  }

  /// Updates in-memory tour flag (call after persisting prefs when needed).
  void setCompleted(bool value) => state = value;
}

final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool>(
  OnboardingCompletedNotifier.new,
);

/// Tracks whether the user has interacted with the dashboard customization feature.
class DashboardCustomizationSeenNotifier extends Notifier<bool> {
  static const String key = 'has_seen_dashboard_customization_v1';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(DashboardCustomizationSeenNotifier.key) ?? false;
  }

  Future<void> setSeen() async {
    if (state) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(DashboardCustomizationSeenNotifier.key, true);
    state = true;
  }
}

final dashboardCustomizationSeenProvider =
    NotifierProvider<DashboardCustomizationSeenNotifier, bool>(
  DashboardCustomizationSeenNotifier.new,
);

/// Tracks whether the user has seen the accounts guide.
class AccountsGuideSeenNotifier extends Notifier<bool> {
  static const String key = 'has_seen_accounts_guide_v1';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(AccountsGuideSeenNotifier.key) ?? false;
  }

  Future<void> setSeen() async {
    if (state) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AccountsGuideSeenNotifier.key, true);
    state = true;
  }
}

final accountsGuideSeenProvider =
    NotifierProvider<AccountsGuideSeenNotifier, bool>(
  AccountsGuideSeenNotifier.new,
);

/// Tracks whether the user has seen the transactions guide.
class TransactionsGuideSeenNotifier extends Notifier<bool> {
  static const String key = 'has_seen_transactions_guide_v1';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(TransactionsGuideSeenNotifier.key) ?? false;
  }

  Future<void> setSeen() async {
    if (state) return;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(TransactionsGuideSeenNotifier.key, true);
    state = true;
  }
}

final transactionsGuideSeenProvider =
    NotifierProvider<TransactionsGuideSeenNotifier, bool>(
  TransactionsGuideSeenNotifier.new,
);
