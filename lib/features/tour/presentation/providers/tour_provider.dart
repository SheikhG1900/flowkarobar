import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';

/// Key for storing tour completion status in SharedPreferences
const String _tourCompletedKey = 'app_tour_completed';

/// Provider to check if the tour has been completed
final tourCompletedProvider = FutureProvider<bool>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(_tourCompletedKey) ?? false;
});

/// Provider to check if tour should be shown (not completed yet)
final shouldShowTourProvider = FutureProvider<bool>((ref) async {
  final completed = await ref.watch(tourCompletedProvider.future);
  return !completed;
});

/// Provider for marking tour as completed
final tourNotifierProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TourNotifier(prefs);
});

/// Notifier for managing tour state
class TourNotifier {
  TourNotifier(this._prefs);

  final SharedPreferences _prefs;

  /// Mark the tour as completed
  Future<void> markTourCompleted() async {
    await _prefs.setBool(_tourCompletedKey, true);
  }

  /// Reset tour completion (for testing or re-showing)
  Future<void> resetTour() async {
    await _prefs.remove(_tourCompletedKey);
  }

  /// Check if tour is completed
  bool get isCompleted => _prefs.getBool(_tourCompletedKey) ?? false;
}
