import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';

/// Keys for storing tour completion status in SharedPreferences
const String _tourDashboardKey = 'tour_completed_dashboard';
const String _tourTransactionsKey = 'tour_completed_transactions';
const String _tourAnalyticsKey = 'tour_completed_analytics';
const String _tourSettingsKey = 'tour_completed_settings';
const String _tourAddTransactionKey = 'tour_completed_add_transaction';

/// Provider for marking tours as completed
final tourNotifierProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TourNotifier(prefs);
});

/// Notifier for managing tour state
class TourNotifier {
  TourNotifier(this._prefs);

  final SharedPreferences _prefs;

  /// Mark a specific tour as completed
  Future<void> markTourCompleted(String key) async {
    await _prefs.setBool(key, true);
  }

  /// Check if a specific tour is completed
  bool isTourCompleted(String key) => _prefs.getBool(key) ?? false;

  /// Reset all tours (for testing)
  Future<void> resetAllTours() async {
    await _prefs.remove(_tourDashboardKey);
    await _prefs.remove(_tourTransactionsKey);
    await _prefs.remove(_tourAnalyticsKey);
    await _prefs.remove(_tourSettingsKey);
    await _prefs.remove(_tourAddTransactionKey);
    await _prefs.remove('app_tour_completed'); // Cleanup old key
  }

  // Helper getters for keys
  String get dashboardKey => _tourDashboardKey;
  String get transactionsKey => _tourTransactionsKey;
  String get analyticsKey => _tourAnalyticsKey;
  String get settingsKey => _tourSettingsKey;
  String get addTransactionKey => _tourAddTransactionKey;
}
