import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

const String syncTaskName = 'com.flowpaisa.app.sync_task';

/// SharedPreferences keys for sync-in-progress guard (avoid duplicate tasks).
const String _syncInProgressKey = 'sync_in_progress';
const String _syncStartedAtKey = 'sync_started_at_ms';
/// Timeout in seconds after which the flag is considered stale (e.g. task crashed).
const int _syncInProgressTimeoutSeconds = 300; // 5 minutes

class SyncScheduler {
  /// Returns true if a sync task is currently considered in progress (flag set and not timed out).
  static Future<bool> isSyncInProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final startedAt = prefs.getInt(_syncStartedAtKey);
    if (startedAt == null) return false;
    final elapsedMs =
        DateTime.now().millisecondsSinceEpoch - startedAt;
    if (elapsedMs > _syncInProgressTimeoutSeconds * 1000) {
      return false; // Stale, consider released (e.g. task crashed).
    }
    return prefs.getBool(_syncInProgressKey) == true;
  }

  static Future<void> init() async {
    // Background tasks removed - logic moved to foreground catch-up
  }

  /// Cancels the periodic cloud sync task (e.g. on sign out).
  static Future<void> cancelAllSyncTasks() async {
    // Background tasks removed
  }

  static Future<void> scheduleDailySync() async {
    // Background tasks removed - logic moved to foreground catch-up
  }

  static Future<void> triggerOnDemandSync() async {
    // Background tasks removed - logic moved to foreground catch-up
  }
}
