import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Service to request in-app review (Google Play / App Store) with eligibility throttling.
/// Use [maybeRequestReview] after user-initiated successes; use [requestReview] for "Rate us" button.
class InAppReviewService {
  InAppReviewService(this._prefs, this._ref);

  final UserPreferencesRepository _prefs;
  final Ref _ref;

  static const int _minDaysBetweenPrompts = 30;
  static const int _minTransactionsForFirstPrompt = 10;
  static const String _keyLastRequestDate = 'in_app_review_last_request_date';
  static const String _keyLastRequestVersion = 'in_app_review_last_request_version';

  final InAppReview _review = InAppReview.instance;

  /// Returns true if the platform supports in-app review (e.g. Play Store / App Store).
  Future<bool> isAvailable() => _review.isAvailable();

  /// Requests review without eligibility check. Use for "Rate us" in Settings.
  Future<void> requestReview() async {
    if (!await isAvailable()) return;
    try {
      await _review.requestReview();
    } catch (_) {
      // Ignore; platform may not show dialog.
    }
  }

  /// Requests review only if eligible (first time, or 30+ days since last request, or app version changed).
  /// Call after user-initiated successes (export, save transaction, receipt scan save).
  Future<void> maybeRequestReview() async {
    if (!await isAvailable()) return;

    // Check transaction count threshold
    final transactionCount =
        await _ref.read(transactionsRepositoryProvider).getTotalTransactionCount();
    if (transactionCount < _minTransactionsForFirstPrompt) {
      return;
    }

    final lastDateStr = await _prefs.getPreference(_keyLastRequestDate);
    final lastVersion = await _prefs.getPreference(_keyLastRequestVersion);
    final info = await PackageInfo.fromPlatform();
    final currentVersion = '${info.version}+${info.buildNumber}';

    if (lastDateStr != null && lastVersion != null) {
      final lastDate = DateTime.tryParse(lastDateStr);
      if (lastDate != null && lastVersion == currentVersion) {
        if (DateTime.now().difference(lastDate).inDays < _minDaysBetweenPrompts) {
          return;
        }
      }
    }

    try {
      await _review.requestReview();
      await _prefs.setPreference(
        _keyLastRequestDate,
        DateTime.now().toIso8601String(),
        markUnsynced: false,
      );
      await _prefs.setPreference(
        _keyLastRequestVersion,
        currentVersion,
        markUnsynced: false,
      );
    } catch (_) {
      // Ignore
    }
  }
}

/// Provider for [InAppReviewService].
final inAppReviewServiceProvider = Provider<InAppReviewService>((ref) {
  final prefs = ref.watch(userPreferencesRepositoryProvider);
  return InAppReviewService(prefs, ref);
});
