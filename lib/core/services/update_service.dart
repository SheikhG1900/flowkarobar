import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service to handle in-app updates using Google Play's In-App Update API.
/// This feature is only available on Android devices with Google Play Services.
class UpdateService {
  /// Checks for available updates and triggers the update flow.
  /// 
  /// We prioritize 'Immediate Update' for the "instant" experience.
  /// This will show a full-screen dialog that handles the download and 
  /// installation without the user needing to leave the app.
  Future<void> checkForUpdate() async {
    // In-app updates are only supported on Android.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    try {
      // Check if an update is available on the Play Store
      final info = await InAppUpdate.checkForUpdate();
      
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          // Immediate Update: Full-screen, mandatory update flow.
          // The app will restart automatically after the update is installed.
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          // Flexible Update: Background download.
          // For a simple implementation, we start the download.
          // Note: To be fully robust, one would listen to the download status
          // and call completeFlexibleUpdate() once finished.
          await InAppUpdate.startFlexibleUpdate();
        }
      }
    } catch (e) {
      // Fail silently to ensure the app remains usable even if the update check fails.
      debugPrint('UpdateService: Error checking for updates: $e');
    }
  }
}

/// Provider for [UpdateService].
final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());
