import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/backup/data/google_drive_service.dart';
import 'package:flowpaisa/features/backup/data/backup_repository.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/features/backup/domain/models/sync_manifest.dart';
import 'package:flowpaisa/features/backup/data/sync/sync_scheduler.dart';
import 'package:flowpaisa/features/notifications/presentation/providers/notification_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'dart:async';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart' as import_device_info;
import 'package:drift/drift.dart';
import 'dart:io';

/// Provider for GoogleDriveService
final googleDriveServiceProvider = Provider<GoogleDriveService>((ref) {
  final service = GoogleDriveService();
  service.init(); // Initialize silently
  return service;
});

/// Provider for BackupRepository
final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final driveService = ref.watch(googleDriveServiceProvider);
  return BackupRepository(driveService);
});

class CloudCashbookMetadata {
  final String id;
  final String name;
  final String color;
  final String icon;

  CloudCashbookMetadata({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });
}

class AccountMismatchWarning {
  final String oldEmail;
  final String newEmail;

  AccountMismatchWarning({
    required this.oldEmail,
    required this.newEmail,
  });
}

/// State for Backup Screen
class BackupState {
  final bool isLoading;
  final bool isBackingUp;
  final GoogleSignInAccount? currentUser;
  final List<drive.File> backups;
  final DateTime? lastBackupTime;
  final String? error;

  // New settings and versioning fields
  final String
      syncInterval; // 'manual', '12', '24', '36', '48', '60', '72', '84', '96'
  final int localVersion;
  final int cloudVersion;
  final String? lockedBy;
  final DateTime? lockedAt;
  final DateTime? lastSyncTime;
  final List<String> availableCashbookIds;
  final Map<String, CloudCashbookMetadata> cashbookMetadata; // id -> metadata
  final String? selectedCloudCashbookId;
  final int unsyncedCount;
  final List<drive.File> deltaFiles;
  final String syncStatus; // 'Idle', 'Syncing...', 'Success', 'Error: ...'
  final DateTime? syncStartedAt;

  final String? lastSuccessMessage;
  final String? lastErrorMessage;
  
  final AccountMismatchWarning? accountMismatchWarning;
  final bool premiumExpiredLogout;

  BackupState({
    this.isLoading = false,
    this.isBackingUp = false,
    this.currentUser,
    this.backups = const [],
    this.lastBackupTime,
    this.error,
    this.syncInterval = 'manual',
    this.localVersion = 0,
    this.cloudVersion = 0,
    this.lockedBy,
    this.lockedAt,
    this.lastSyncTime,
    this.availableCashbookIds = const [],
    this.cashbookMetadata = const {},
    this.selectedCloudCashbookId,
    this.unsyncedCount = 0,
    this.deltaFiles = const [],
    this.syncStatus = 'Idle',
    this.syncStartedAt,
    this.lastSuccessMessage,
    this.lastErrorMessage,
    this.accountMismatchWarning,
    this.premiumExpiredLogout = false,
  });

  factory BackupState.initial() {
    return BackupState();
  }

  BackupState copyWith({
    bool? isLoading,
    bool? isBackingUp,
    GoogleSignInAccount? currentUser,
    List<drive.File>? backups,
    DateTime? lastBackupTime,
    String? error,
    String? syncInterval,
    int? localVersion,
    int? cloudVersion,
    String? lockedBy,
    DateTime? lockedAt,
    DateTime? lastSyncTime,
    List<String>? availableCashbookIds,
    Map<String, CloudCashbookMetadata>? cashbookMetadata,
    String? selectedCloudCashbookId,
    int? unsyncedCount,
    List<drive.File>? deltaFiles,
    String? syncStatus,
    DateTime? syncStartedAt,
    String? lastSuccessMessage,
    String? lastErrorMessage,
    AccountMismatchWarning? accountMismatchWarning,
    bool? premiumExpiredLogout,
    bool clearAccountMismatchWarning = false,
    bool clearPremiumExpiredLogoutFlag = false,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      isBackingUp: isBackingUp ?? this.isBackingUp,
      currentUser: currentUser ?? this.currentUser,
      backups: backups ?? this.backups,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      error: error,
      syncInterval: syncInterval ?? this.syncInterval,
      localVersion: localVersion ?? this.localVersion,
      cloudVersion: cloudVersion ?? this.cloudVersion,
      lockedBy: lockedBy ?? this.lockedBy,
      lockedAt: lockedAt ?? this.lockedAt,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      availableCashbookIds: availableCashbookIds ?? this.availableCashbookIds,
      cashbookMetadata: cashbookMetadata ?? this.cashbookMetadata,
      selectedCloudCashbookId:
          selectedCloudCashbookId ?? this.selectedCloudCashbookId,
      unsyncedCount: unsyncedCount ?? this.unsyncedCount,
      deltaFiles: deltaFiles ?? this.deltaFiles,
      syncStatus: syncStatus ?? this.syncStatus,
      syncStartedAt: syncStartedAt ?? this.syncStartedAt,
      lastSuccessMessage: lastSuccessMessage,
      lastErrorMessage: lastErrorMessage,
      accountMismatchWarning: clearAccountMismatchWarning
          ? null
          : (accountMismatchWarning ?? this.accountMismatchWarning),
      premiumExpiredLogout: clearPremiumExpiredLogoutFlag
          ? false
          : (premiumExpiredLogout ?? this.premiumExpiredLogout),
    );
  }
}

class BackupNotifier extends Notifier<BackupState> {
  late GoogleDriveService _driveService;
  late BackupRepository _repository;
  StreamSubscription<List<SyncMetadataData>>? _dbWatcherSubscription;
  final List<StreamSubscription> _unsyncedCountSubscriptions = [];

  @override
  BackupState build() {
    _driveService = ref.watch(googleDriveServiceProvider);
    _repository = ref.watch(backupRepositoryProvider);

    // Watch for cashbook changes to refresh state
    ref.listen(activeCashbookProvider, (previous, next) {
      if (previous?.id != next.id) {
        _init();
      }
    });

    // Trigger init post-build
    Future.microtask(() => _init());

    return BackupState.initial();
  }

  Future<void> _init() async {
    // Reset state to initial (except user) to avoid showing data from previous cashbook
    final currentUser = state.currentUser;
    final activeCashbook = ref.read(activeCashbookProvider);
    state = BackupState.initial().copyWith(
      currentUser: currentUser,
      selectedCloudCashbookId: activeCashbook.id,
    );

    // Wait for silent sign in
    await Future.delayed(const Duration(seconds: 1));

    if (_driveService.currentUser != state.currentUser) {
      state = state.copyWith(currentUser: _driveService.currentUser);
    }

    final lastTime =
        await _repository.getLastBackupTime(cashbookId: activeCashbook.id);
    state = state.copyWith(lastBackupTime: lastTime);

    // Load settings from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final syncInterval = prefs.getString('sync_interval') ?? 'manual';
    state = state.copyWith(
      syncInterval: syncInterval,
    );

    await _refreshVersions();
    _startDatabaseStatusWatcher();

    if (_driveService.isSignedIn) {
      // Check premium status (same logic as PremiumGate.isPremium but using Ref)
      final premiumState = ref.read(premiumProvider);
      bool isPremium = premiumState.isPremium;
      if (isPremium &&
          premiumState.subscriptionType != 'lifetime' &&
          premiumState.expiryDate != null) {
        isPremium = premiumState.expiryDate!.isAfter(DateTime.now());
      }
      if (!isPremium) {
        if (kDebugMode) {
          print('BackupNotifier: User is not premium but signed in. Signing out.');
        }
        await signOut();
        state = state.copyWith(premiumExpiredLogout: true);
        return;
      }

      await loadBackups();
      await _loadAvailableCashbooks();

      // Sync on startup so user gets updated data and keeps data saved when using the app
      if (kDebugMode) {
        print('BackupNotifier: Sync on startup triggered');
      }
      final cashbooksJson = prefs.getStringList('cashbooks_list');
      if (cashbooksJson != null && cashbooksJson.isNotEmpty) {
        await SyncScheduler.triggerOnDemandSync();
      } else {
        triggerSync(null);
      }
    }
  }

  Future<void> loadAvailableCashbooks() async {
    state = state.copyWith(isLoading: true);
    await _loadAvailableCashbooks();
    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadAvailableCashbooks() async {
    if (!_driveService.isSignedIn || !_driveService.isDriveApiInitialized)
      return;
    try {
      final folderNames = await _driveService.listCashbookIds();
      final Map<String, CloudCashbookMetadata> metadataMap = {};
      final List<String> ids = [];

      for (final name in folderNames) {
        if (name == 'Flowpaisa Backups') continue;

        final parts = name.split('|');
        final id = parts[0];

        // Skip if we already processed this ID (prevents duplicates)
        if (ids.contains(id)) continue;

        // Default values
        String cashbookName = id == 'default' ? 'Main' : 'Cloud DB';
        String color = '#757575';
        String icon = Symbols.account_balance_wallet.codePoint.toString();

        if (parts.length >= 2 && parts[1].isNotEmpty) cashbookName = parts[1];
        if (parts.length >= 4) {
          color = parts[2];
          icon = parts[3];
        }

        ids.add(id);
        metadataMap[id] = CloudCashbookMetadata(
          id: id,
          name: cashbookName,
          color: color,
          icon: icon,
        );
      }

      // Ensure the active cashbook ID is in the list and has its current metadata
      final activeCashbook = ref.read(activeCashbookProvider);
      if (!ids.contains(activeCashbook.id)) {
        ids.insert(0, activeCashbook.id);
      }
      metadataMap[activeCashbook.id] = CloudCashbookMetadata(
        id: activeCashbook.id,
        name: activeCashbook.name,
        color: activeCashbook.colorCode,
        icon: activeCashbook.iconCodePoint ?? '',
      );

      state = state.copyWith(
        availableCashbookIds: ids,
        cashbookMetadata: metadataMap,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load available cashbooks from cloud: $e');
      }
    }
  }

  Future<void> triggerSync(AppLocalizations? l10n) async {
    try {
      // Set isLoading to true ONLY if we are not already syncing
      if (state.syncStatus != 'Syncing...') {
        state = state.copyWith(
            isLoading: true, error: null, syncStatus: 'Syncing...');
      }

      // 1. Trigger the background task
      await SyncScheduler.triggerOnDemandSync();

      // 2. Start a periodic refresh timer to catch updates from the background isolate.
      // This is necessary because Drift streams don't automatically propagate
      // across isolates without a shared connection.
      _startSyncProgressTimer();

      // 3. Safety timeout: If background task doesn't report back, clear loading state
      Future.delayed(const Duration(seconds: 30), () {
        if (state.isLoading) {
          _checkFinalStatus();
        }
      });
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString(), syncStatus: 'Idle');
    }
  }

  Timer? _syncProgressTimer;

  void _startSyncProgressTimer() {
    _syncProgressTimer?.cancel();
    _syncProgressTimer =
        Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!ref.mounted || (!state.isLoading && state.syncStatus == 'Idle')) {
        timer.cancel();
        return;
      }

      // Force a refresh of versions and status from the database and SharedPreferences
      await _refreshSyncProgress();
    });
  }

  Future<void> _refreshSyncProgress() async {
    final db = ref.read(databaseProvider);
    final deviceId = await _getDeviceId();
    final activeCashbook = ref.read(activeCashbookProvider);
    final prefs = await SharedPreferences.getInstance();

    try {
      // 1. Refresh status from SharedPreferences (most reliable cross-isolate)
      // CRITICAL: We MUST reload SharedPreferences to see changes from the background isolate.
      await prefs.reload();
      final status =
          prefs.getString('sync_status_${activeCashbook.id}') ?? 'Idle';

      // 2. Refresh metadata from DB (bypass Drift's stream cache by doing a fresh get)
      final metadata = await (db.select(db.syncMetadata)
            ..where((t) => t.deviceId.equals(deviceId)))
          .getSingleOrNull();

      if (metadata != null) {
        final bool statusChanged = state.syncStatus != status;
        final bool localVerChanged = state.localVersion != metadata.version;
        final bool cloudVerChanged =
            state.cloudVersion != metadata.cloudVersion;
        final bool timeChanged = state.lastSyncTime != metadata.lastSyncAt;

        if (statusChanged ||
            localVerChanged ||
            cloudVerChanged ||
            timeChanged) {
          if (kDebugMode) {
            print(
                'BackupNotifier: Periodic Refresh - Status: $status, LocalVer: ${metadata.version}, CloudVer: ${metadata.cloudVersion}');
          }

          state = state.copyWith(
            syncStatus: status,
            localVersion: metadata.version,
            cloudVersion: metadata.cloudVersion,
            lastSyncTime: metadata.lastSyncAt,
            isLoading: status.contains('Syncing') ||
                status.contains('Pulling') ||
                status.contains('Pushing'),
          );

          // Force refresh unsynced count during sync progress
          _updateTotalUnsyncedCount();

          if (status == 'Success') {
            _syncProgressTimer?.cancel();
            _handleSyncSuccess();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('BackupNotifier: Failed periodic refresh: $e');
      }
    }
  }

  /// Public method to refresh cloud state (e.g., when app comes to foreground)
  Future<void> refreshCloudState() async {
    await _fetchCloudState();
  }

  Future<void> _checkFinalStatus() async {
    final activeCashbook = ref.read(activeCashbookProvider);
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final status =
        prefs.getString('sync_status_${activeCashbook.id}') ?? 'Idle';

    if (status != 'Syncing...') {
      state = state.copyWith(isLoading: false, syncStatus: status);
    } else {
      // If it's still Syncing after 15s, we allow the user to interact with the screen
      // while the blue bar continues to show progress
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshVersions() async {
    state = state.copyWith(isLoading: true);

    // 1. Fetch fresh cloud state (cloud version, lock status, delta files)
    await _fetchCloudState();

    // 2. Refresh unsynced counts
    await _updateTotalUnsyncedCount();

    state = state.copyWith(isLoading: false);
  }

  Future<void> _refreshVersions() async {
    // 1. Initial local version and cloud version from DB (Instant)
    final db = ref.read(databaseProvider);
    final deviceId = await _getDeviceId();
    try {
      final metadata = await (db.select(db.syncMetadata)
            ..where((t) => t.deviceId.equals(deviceId)))
          .getSingleOrNull();
      if (metadata != null) {
        state = state.copyWith(
          localVersion: metadata.version,
          cloudVersion: metadata.cloudVersion,
          lastSyncTime: metadata.lastSyncAt,
          syncStatus: metadata.syncStatus,
        );
        if (metadata.version > 0) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('has_local_sync_data', true);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('BackupNotifier: Failed to load initial metadata: $e');
      }
    }

    // 2. Initial unsynced count update (Instant)
    _updateTotalUnsyncedCount();

    // 3. Listen to unsynced counts
    try {
      // Cancel previous subscriptions to avoid leaks when cashbook changes
      for (final sub in _unsyncedCountSubscriptions) {
        sub.cancel();
      }
      _unsyncedCountSubscriptions.clear();

      // We watch the tables using their specific generated classes to satisfy Drift's type system.
      // This is the most reliable way to get updates whenever any row in the table changes.
      final streams = [
        db.select(db.categories).watch(),
        db.select(db.contacts).watch(),
        db.select(db.transactions).watch(),
        db.select(db.receivables).watch(),
        db.select(db.payables).watch(),
        db.select(db.reminders).watch(),
        db.select(db.appCurrencies).watch(),
        db.select(db.transactionSchedules).watch(),
        db.select(db.userPreferences).watch(),
      ];

      for (final stream in streams) {
        final subscription = stream.listen((_) {
          if (!ref.mounted) return;
          _updateTotalUnsyncedCount();
        });
        _unsyncedCountSubscriptions.add(subscription);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load unsynced count: $e');
      }
    }

    // 4. Fetch cloud state in background (Network - Non-blocking)
    _fetchCloudState();
  }

  Future<void> _fetchCloudState() async {
    if (!_driveService.isSignedIn || !_driveService.isDriveApiInitialized)
      return;

    final activeCashbook = ref.read(activeCashbookProvider);
    try {
      final folderId = await _driveService.getOrCreateCashbookFolder(
        activeCashbook.id,
        cashbookName: activeCashbook.name,
        color: activeCashbook.colorCode,
        icon: activeCashbook.iconCodePoint,
      );

      // Load manifest
      int cloudVersion = 0;
      final manifestFileId =
          await _driveService.getFileIdByName('manifest.json', folderId);
      if (manifestFileId != null) {
        final result = await _driveService.downloadFileWithETag(manifestFileId);
        final manifest = SyncManifest.fromJson(result.content);
        cloudVersion = manifest.version;
      }

      // Load list of sync delta files (v*.json) for the "review content" list on backup screen
      List<drive.File> deltaFiles = [];
      try {
        deltaFiles = await _driveService.listSyncFiles(folderId);
        // Sort by version number (v1.json, v2.json, ...) descending so newest first
        deltaFiles.sort((a, b) {
          final va = int.tryParse(
                  a.name?.replaceAll('v', '').replaceAll('.json', '') ?? '0') ??
              0;
          final vb = int.tryParse(
                  b.name?.replaceAll('v', '').replaceAll('.json', '') ?? '0') ??
              0;
          return vb.compareTo(va);
        });
      } catch (e) {
        if (kDebugMode) {
          print('BackupNotifier: Failed to list sync files: $e');
        }
      }

      if (!ref.mounted) return;
      state = state.copyWith(deltaFiles: deltaFiles);

      // CRITICAL: Ensure the row exists and update the cloud version.
      final deviceId = await _getDeviceId();
      final db = ref.read(databaseProvider);

      final currentMetadata = await (db.select(db.syncMetadata)
            ..where((t) => t.deviceId.equals(deviceId)))
          .getSingleOrNull();

      if (currentMetadata == null) {
        // Insert new row if it doesn't exist
        await db.into(db.syncMetadata).insert(SyncMetadataCompanion(
              deviceId: Value(deviceId),
              cloudVersion: Value(cloudVersion),
              version: const Value(0),
              syncStatus: const Value('Idle'),
            ));
        if (kDebugMode) {
          print(
              'BackupNotifier: Created new metadata row with cloud version $cloudVersion');
        }
      } else if (currentMetadata.cloudVersion != cloudVersion) {
        // Update existing row only if cloud version changed
        await (db.update(db.syncMetadata)
              ..where((t) => t.deviceId.equals(deviceId)))
            .write(SyncMetadataCompanion(
          cloudVersion: Value(cloudVersion),
        ));
        if (kDebugMode) {
          print(
              'BackupNotifier: Updated existing cloud version to $cloudVersion in DB');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch cloud state: $e');
      }
    }
  }

  Future<void> _updateTotalUnsyncedCount() async {
    final db = ref.read(databaseProvider);
    int total = 0;
    final tables = [
      'categories',
      'contacts',
      'transactions',
      'receivables',
      'payables',
      'reminders',
      'app_currencies',
      'transaction_schedules',
      'user_preferences',
    ];
    for (final table in tables) {
      try {
        // Use a more robust check for table existence
        final countResult = await db
            .customSelect(
                "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table' AND name='$table'")
            .getSingle();

        final tableExists = (countResult.data['count'] as num).toInt() > 0;
        if (!tableExists) continue;

        final rowsResult = await db
            .customSelect(
                'SELECT COUNT(*) as count FROM $table WHERE is_not_synced = 1')
            .getSingle();
        total += (rowsResult.data['count'] as num).toInt();
      } catch (e) {
        if (kDebugMode) {
          print('BackupNotifier: Error counting unsynced rows in $table: $e');
        }
      }
    }

    if (state.unsyncedCount != total) {
      state = state.copyWith(unsyncedCount: total);
    }
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = import_device_info.DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    }
    return 'unknown_device';
  }

  void _startDatabaseStatusWatcher() async {
    // Cancel any existing subscription first to prevent memory leaks and multiple listeners
    // updating the state with data from old databases when the active cashbook changes.
    await _dbWatcherSubscription?.cancel();
    _dbWatcherSubscription = null;

    final db = ref.read(databaseProvider);
    final deviceId = await _getDeviceId();

    if (kDebugMode) {
      print('BackupNotifier: Starting DB watcher for device: $deviceId');
    }

    // Use a stream that watches the entire table to be more resilient
    _dbWatcherSubscription = db.select(db.syncMetadata).watch().listen((list) {
      if (!ref.mounted) return;

      // Find the metadata for OUR device in the list
      final metadata = list.where((t) => t.deviceId == deviceId).firstOrNull;

      if (metadata != null) {
        String status = metadata.syncStatus;
        final startedAt = metadata.syncStartedAt;

        // Stuck sync detection: if started more than 10 minutes ago, treat as Idle
        if (startedAt != null &&
            DateTime.now().toUtc().difference(startedAt).inMinutes > 10) {
          status = 'Idle';
        }

        // CRITICAL: We only update the state if the incoming metadata has a different version,
        // status, or cloud version than what we currently have.
        // We also check for 'Success' specifically to trigger refreshes.
        if (state.syncStatus != status ||
            state.syncStartedAt != startedAt ||
            state.cloudVersion != metadata.cloudVersion ||
            state.localVersion != metadata.version ||
            state.lastSyncTime != metadata.lastSyncAt) {
          final bool wasSyncing = state.syncStatus.contains('Syncing') ||
              state.syncStatus.contains('Pulling') ||
              state.syncStatus.contains('Pushing');
          final bool isNowSuccess = status == 'Success';

          if (kDebugMode) {
            print(
                'BackupNotifier: DB Watcher - Status: $status, LocalVer: ${metadata.version}, CloudVer: ${metadata.cloudVersion}, DeviceID: ${metadata.deviceId}');
          }

          state = state.copyWith(
            syncStatus: status,
            syncStartedAt: startedAt,
            localVersion: metadata.version,
            cloudVersion: metadata.cloudVersion,
            lastSyncTime: metadata.lastSyncAt,
            isLoading: status.contains('Syncing') ||
                status.contains('Pulling') ||
                status.contains('Pushing'),
          );

          // Force refresh unsynced count when DB metadata changes
          _updateTotalUnsyncedCount();

          // CRITICAL: Also notify Drift that tables might have changed in the background
          // This ensures the UI isolate's stream listeners (like the dashboard) re-query.
          db.markTablesUpdated({
            db.categories,
            db.contacts,
            db.transactions,
            db.receivables,
            db.payables,
            db.reminders,
            db.appCurrencies,
            db.transactionSchedules,
          });

          // FORCE INVALIDATION: Explicitly tell Riverpod to discard the cached state
          // for these specific providers. This is the most aggressive way to refresh.
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recentTransactionsProvider);

    // If we just finished a sync (transitioned from syncing to success), trigger refreshes
          if (wasSyncing && isNowSuccess) {
            _handleSyncSuccess();
          } else if (isNowSuccess) {
            // Even if we weren't "syncing" (e.g. background sync finished),
            // if we are now in Success state, ensure we eventually go back to Idle
            _resetSuccessStatus();
          }
        }
      } else {
        if (kDebugMode) {
          print(
              'BackupNotifier: DB Watcher - No metadata found in table for device: $deviceId. Total rows: ${list.length}');
        }
      }
    });

    ref.onDispose(() {
      _dbWatcherSubscription?.cancel();
      for (final sub in _unsyncedCountSubscriptions) {
        sub.cancel();
      }
    });
  }

  Future<void> _handleSyncSuccess() async {
    // 1. Refresh local version and sync time from DB manually to ensure state is updated
    // even if the watcher hasn't fired yet
    final db = ref.read(databaseProvider);
    try {
      final deviceId = await _getDeviceId();
      final metadataList = await (db.select(db.syncMetadata)
            ..where((t) => t.deviceId.equals(deviceId)))
          .get();
      if (metadataList.isNotEmpty) {
        final metadata = metadataList.first;

        state = state.copyWith(
          localVersion: metadata.version,
          cloudVersion: metadata.cloudVersion,
          syncStatus: metadata.syncStatus,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('BackupNotifier: Failed to manual refresh after success: $e');
      }
    }

    // Refresh unsynced counts and cloud state immediately
    await _updateTotalUnsyncedCount();
    await _fetchCloudState();

    // Small delay to ensure SQLite has finished file operations in the background isolate
    await Future.delayed(const Duration(milliseconds: 500));

    // CRITICAL: Notify the main isolate's database connection that tables have been updated
    // in the background. This forces all Drift streams to re-query.
    if (kDebugMode) {
      print(
          'BackupNotifier: Notifying main isolate about background updates...');
    }
    db.markTablesUpdated({
      db.categories,
      db.contacts,
      db.transactions,
      db.receivables,
      db.payables,
      db.reminders,
      db.appCurrencies,
      db.transactionSchedules,
    });

    // FORCE REFRESH: Explicitly tell Riverpod to discard cached state
    ref.invalidate(allTransactionsProvider);
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(transactionsWithDetailsProvider);
    ref.invalidate(transactionsPaginatedProvider);
    ref.invalidate(payablesPaginatedProvider);
    ref.invalidate(receivablesPaginatedProvider);

    // Refresh summary providers
    ref.invalidate(allPayablesProvider);
    ref.invalidate(allReceivablesProvider);
    ref.invalidate(pendingPayablesCountProvider);
    ref.invalidate(pendingReceivablesCountProvider);
    ref.invalidate(overduePayablesCountProvider);
    ref.invalidate(overdueReceivablesCountProvider);
    ref.invalidate(totalPendingPayablesProvider);
    ref.invalidate(totalPendingReceivablesProvider);

    // Reset status to Idle after a delay in the database
    _resetSuccessStatus();
  }

  void _resetSuccessStatus() {
    Future.delayed(const Duration(seconds: 10), () async {
      if (!ref.mounted) return;
      final db = ref.read(databaseProvider);
      final deviceId = await _getDeviceId();

      // Only reset if it's still Success (don't overwrite a new sync that might have started)
      final currentMetadata = await (db.select(db.syncMetadata)
            ..where((t) => t.deviceId.equals(deviceId)))
          .getSingleOrNull();

      if (currentMetadata?.syncStatus == 'Success') {
        await (db.update(db.syncMetadata)
              ..where((t) => t.deviceId.equals(deviceId)))
            .write(SyncMetadataCompanion(
          syncStatus: const Value('Idle'),
          syncStartedAt: const Value(null),
        ));
      }
    });
  }

  Future<void> setSyncInterval(String interval) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sync_interval', interval);
    state = state.copyWith(syncInterval: interval);
    await SyncScheduler.scheduleDailySync();
  }

  Future<String> getDeltaFileContent(String fileId) async {
    // Ensure Drive API is initialized
    if (!_driveService.isSignedIn) return 'Not signed in';
    if (!_driveService.isDriveApiInitialized) {
      await _driveService.signIn();
    }

    try {
      final result = await _driveService.downloadFileWithETag(fileId);
      final dynamic jsonObject = json.decode(result.content);
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonObject);
    } catch (e) {
      if (e.toString().contains('Access was denied') ||
          e.toString().contains('401')) {
        try {
          await _driveService.reauthenticate();
          return getDeltaFileContent(fileId); // Retry once
        } catch (reauthError) {
          return 'Access denied. Please sign out and sign in again.';
        }
      }
      return 'Error loading content: $e';
    }
  }

  Future<String> getManifestContent() async {
    // Ensure Drive API is initialized
    if (!_driveService.isSignedIn) return 'Not signed in';
    if (!_driveService.isDriveApiInitialized) {
      await _driveService.signIn();
    }

    final activeCashbook = ref.read(activeCashbookProvider);
    try {
      final folderId = await _driveService.getOrCreateCashbookFolder(
        activeCashbook.id,
        cashbookName: activeCashbook.name,
        color: activeCashbook.colorCode,
        icon: activeCashbook.iconCodePoint,
      );
      final manifestFileId =
          await _driveService.getFileIdByName('manifest.json', folderId);
      if (manifestFileId != null) {
        final result = await _driveService.downloadFileWithETag(manifestFileId);
        final dynamic jsonObject = json.decode(result.content);
        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(jsonObject);
      }
      return 'Manifest not found';
    } catch (e) {
      if (e.toString().contains('Access was denied') ||
          e.toString().contains('401')) {
        try {
          await _driveService.reauthenticate();
          return getManifestContent(); // Retry once
        } catch (reauthError) {
          return 'Access denied. Please sign out and sign in again.';
        }
      }
      return 'Error loading manifest: $e';
    }
  }

  Future<void> signIn() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final account = await _driveService.signIn();
      
      if (account != null) {
        await _checkAccountMismatch(account.email);
      }
      
      state = state.copyWith(
        currentUser: account,
        isLoading: false,
      );
      await loadBackups();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> signInIfNeeded() async {
    // Already signed in
    if (state.currentUser != null) return true;

    state = state.copyWith(isLoading: true);
    try {
      // First try to sign in silently
      final account = await _driveService.init();
      
      if (account != null) {
        await _checkAccountMismatch(account.email);
        state = state.copyWith(
          isLoading: false,
          currentUser: account,
        );
        return true;
      }

      // If silent sign in fails, trigger the explicit sign in popup
      final explicitAccount = await _driveService.signIn();
      if (explicitAccount != null) {
        await _checkAccountMismatch(explicitAccount.email);
      }
      
      state = state.copyWith(
        isLoading: false,
        currentUser: explicitAccount,
      );
      return explicitAccount != null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> _checkAccountMismatch(String newEmail) async {
    final prefs = await SharedPreferences.getInstance();
    // Use last_sync_account_email (set on sign-out) so we detect account change even after user signed out
    final oldEmail = prefs.getString('last_sync_account_email');

    if (oldEmail != null && oldEmail != newEmail) {
      // Check if there is local sync history (flag is set when any sync writes version > 0)
      bool hasLocalSyncData = prefs.getBool('has_local_sync_data') ?? false;

      if (!hasLocalSyncData) {
        // Fallback: query active cashbook's DB (may be 0 if wrong cashbook or not yet written)
        final db = ref.read(databaseProvider);
        final deviceId = await _getDeviceId();
        final metadata = await (db.select(db.syncMetadata)
              ..where((t) => t.deviceId.equals(deviceId)))
            .getSingleOrNull();
        if (metadata != null && metadata.version > 0) {
          hasLocalSyncData = true;
          await prefs.setBool('has_local_sync_data', true);
        }
      }

      if (hasLocalSyncData) {
        state = state.copyWith(
          accountMismatchWarning: AccountMismatchWarning(
            oldEmail: oldEmail,
            newEmail: newEmail,
          ),
        );
      }
    }

    // Update the stored email
    await prefs.setString('sync_account_email', newEmail);
  }

  Future<void> clearAccountMismatchWarning() async {
    state = state.copyWith(clearAccountMismatchWarning: true);
  }

  void clearPremiumExpiredLogout() {
    state = state.copyWith(clearPremiumExpiredLogoutFlag: true);
  }

  Future<void> signOut() async {
    await _driveService.signOut();

    // Preserve last synced account for mismatch check on next sign-in; then clear current
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = prefs.getString('sync_account_email');
    if (currentEmail != null && currentEmail.isNotEmpty) {
      await prefs.setString('last_sync_account_email', currentEmail);
    }
    await prefs.remove('sync_account_email');

    await prefs.setString('sync_interval', 'manual');
    await SyncScheduler.cancelAllSyncTasks();

    state = BackupState.initial(); // Reset
  }

  Future<void> loadBackups() async {
    final activeCashbook = ref.read(activeCashbookProvider);
    await loadBackupsForCashbook(activeCashbook.id);
  }

  Future<void> loadBackupsForCashbook(String cashbookId) async {
    if (!_driveService.isSignedIn) return;

    // Ensure Drive API is initialized
    if (!_driveService.isDriveApiInitialized) {
      await _driveService.signIn();
    }

    try {
      state =
          state.copyWith(isLoading: true, selectedCloudCashbookId: cashbookId);
      final backups = await _driveService.listBackups(cashbookId: cashbookId);
      state = state.copyWith(
        isLoading: false,
        backups: backups,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load backups');
    }
  }

  Future<void> restoreToCashbook(String fileId, String cashbookId,
      {AppLocalizations? l10n}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      if (kDebugMode) {
        print('[BackupNotifier] Starting cloud restore for cashbook ID: $cashbookId');
        print('[BackupNotifier] Cloud file ID: $fileId');
      }

      // 1. Get the metadata from our cloud metadata map
      final metadata = state.cashbookMetadata[cashbookId];
      final cloudName = metadata?.name ??
          (cashbookId == 'default' ? 'Main Cashbook' : 'Restored Cashbook');
      final cloudColor = metadata?.color ?? '#757575';
      final cloudIcon =
          metadata?.icon ?? Symbols.account_balance_wallet.codePoint.toString();

      if (kDebugMode) {
        print('[BackupNotifier] Resolved cloud metadata: name=$cloudName, color=$cloudColor');
      }

      // 2. Find if we already have this cashbook locally
      final cashbooks = ref.read(cashbooksProvider);
      final existing = cashbooks.where((c) => c.id == cashbookId).toList();

      String dbPath;
      if (existing.isNotEmpty) {
        dbPath = existing.first.dbPath;
        if (kDebugMode) print('[BackupNotifier] Existing local cashbook found. dbPath: $dbPath');
      } else {
        // Create a NEW cashbook entry locally if it doesn't exist
        dbPath = 'cashbook_$cashbookId';
        final newCashbook = Cashbook(
          id: cashbookId,
          name: cloudName,
          colorCode: cloudColor,
          iconCodePoint: cloudIcon,
          dbPath: dbPath,
          createdAt: DateTime.now(),
        );
        await ref
            .read(cashbooksProvider.notifier)
            .addCashbookFromCloud(newCashbook);
        if (kDebugMode) print('[BackupNotifier] Created new local cashbook entry for ID: $cashbookId');
      }

      // 3. If active, we MUST close the database before repository.restore overwrites it
      final isActive = ref.read(activeCashbookIdProvider) == cashbookId;
      if (isActive) {
        if (kDebugMode) print('[BackupNotifier] Active cashbook. Closing database connection...');
        try {
          final db = ref.read(databaseProvider);
          await db.close();
          if (kDebugMode) print('[BackupNotifier] Database closed successfully');
        } catch (e) {
          if (kDebugMode) print('[BackupNotifier] Warning: Error closing database: $e');
        }
        clearDatabaseCache();
      }

      // 4. Restore the data to the correct file path
      if (kDebugMode) print('[BackupNotifier] Calling repository.restore...');
      await _repository.restore(fileId,
          fileName: dbPath, cashbookId: cashbookId);
      if (kDebugMode) print('[BackupNotifier] repository.restore completed');

      // 5. Invalidate providers to refresh UI
      if (isActive) {
        if (kDebugMode) print('[BackupNotifier] Invalidating providers to refresh UI...');
        ref.invalidate(databaseProvider);
        ref.invalidate(activeCashbookProvider);
      }

      state = state.copyWith(
        isLoading: false,
        lastSuccessMessage: l10n != null
            ? l10n.restoreSuccessfulFor(cloudName)
            : 'Restore successful for $cloudName',
      );
    } catch (e, stack) {
      if (kDebugMode) {
        print('[BackupNotifier] Error during cloud restore: $e');
        print('[BackupNotifier] Stack trace: $stack');
      }
      state = state.copyWith(isLoading: false, lastErrorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> backup(AppLocalizations l10n, {Cashbook? targetCashbook}) async {
    if (state.isBackingUp) return; // Prevent concurrent backups

    try {
      state = state.copyWith(isBackingUp: true, error: null);

      // Ensure Drive API is initialized before proceeding
      if (!_driveService.isDriveApiInitialized) {
        if (kDebugMode) {
          print('Drive API not initialized, attempting initialization...');
        }
        await _driveService.signIn(); // This triggers initialization
      }

      final Cashbook cashbook = targetCashbook ?? ref.read(activeCashbookProvider);
      if (kDebugMode) {
        print(
            'Starting backup for cashbook: ${cashbook.name}, path: ${cashbook.dbPath}');
      }

      try {
        await _repository.backup(
          fileName: cashbook.dbPath,
          cashbookId: cashbook.id,
          cashbookName: cashbook.name,
          color: cashbook.colorCode,
          icon: cashbook.iconCodePoint,
        );
      } catch (e) {
        // If access denied, try re-authenticating once
        if (e.toString().contains('Access was denied') ||
            e.toString().contains('invalid_token')) {
          if (kDebugMode) {
            print('Access denied, attempting re-authentication...');
          }
          await _driveService.reauthenticate();
          // Retry backup after re-auth
          await _repository.backup(
            fileName: cashbook.dbPath,
            cashbookId: cashbook.id,
            cashbookName: cashbook.name,
            color: cashbook.colorCode,
            icon: cashbook.iconCodePoint,
          );
        } else if (e.toString().contains('storage quota has been exceeded') || e.toString().contains('quotaExceeded')) {
          throw Exception("Google Drive storage is full. Please free up some space and try again.");
        } else {
          rethrow;
        }
      }

      if (kDebugMode) {
        print('Backup upload successful');
      }

      // Refresh list and time for the target cashbook
      final backups = await _driveService.listBackups(cashbookId: cashbook.id);
      final time = await _repository.getLastBackupTime(cashbookId: cashbook.id);

      // Only update state if the current view is for this cashbook
      final activeCashbook = ref.read(activeCashbookProvider);
      if (activeCashbook.id == cashbook.id) {
        state = state.copyWith(
          isBackingUp: false,
          backups: backups,
          lastBackupTime: time,
          lastSuccessMessage: l10n.notificationBackupSuccessMessage(cashbook.name),
        );
      } else {
        state = state.copyWith(
          isBackingUp: false,
          lastSuccessMessage: l10n.notificationBackupSuccessMessage(cashbook.name),
        );
      }

      if (kDebugMode) {
        print('Backup state updated. Backups found: ${backups.length}');
      }

      // Add local notification
      try {
        // Use the static method to ensure it's saved even if the notifier isn't active
        await NotificationNotifier.addNotificationStatic(
          title: l10n.notificationBackupSuccessTitle,
          message: l10n.notificationBackupSuccessMessage(cashbook.name),
          type: NotificationType.backup,
        );
        // Also update the active notifier if it exists
        ref.read(notificationProvider.notifier).refresh();
      } catch (e) {
        if (kDebugMode) {
          print('BackupNotifier: Failed to add notification: $e');
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('Backup failed with error: $e');
        print('Stack trace: $stack');
      }
      state = state.copyWith(isBackingUp: false, lastErrorMessage: e.toString());
    }
  }

  Future<void> deleteBackup(String fileId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _driveService.deleteFile(fileId);
      await loadBackups(); // Refresh list
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteCloudCashbook(String cashbookId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 1. Query for folders in both 'Sync Data' and 'Backups'
      final query =
          "mimeType = 'application/vnd.google-apps.folder' and name contains '$cashbookId' and trashed = false";
      final folders = await _driveService.listFoldersWithQuery(query);

      if (kDebugMode) {
        print(
            'BackupNotifier: Found ${folders.length} potential folders to delete for ID: $cashbookId');
      }

      bool deleted = false;
      if (folders.isNotEmpty) {
        for (final folder in folders) {
          if (folder.id != null) {
            final folderName = folder.name ?? '';
            // Double check that the folder name actually starts with this ID
            if (folderName == cashbookId ||
                folderName.startsWith('$cashbookId|')) {
              // CRITICAL: Check for parent folder to ensure we are only deleting from our app's structure
              // (Safety check: we don't want to delete random folders that happen to have the same ID)

              try {
                final children =
                    await _driveService.listAllFilesInFolder(folder.id!);
                if (kDebugMode) {
                  print(
                      'BackupNotifier: Folder ${folder.id} has ${children.length} children. Deleting them first...');
                }
                for (final child in children) {
                  if (child.id != null) {
                    await _driveService.deleteFile(child.id!);
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                  print(
                      'BackupNotifier: Warning - Failed to list/delete children for folder ${folder.id}: $e');
                }
              }

              await _driveService.deleteFile(folder.id!);
              if (kDebugMode) {
                print(
                    'BackupNotifier: Deleted cloud cashbook folder: ${folder.name} (${folder.id})');
              }
              deleted = true;
            }
          }
        }
      }

      if (!deleted) {
        if (kDebugMode) {
          print(
              'BackupNotifier: No matching folder found to delete for ID: $cashbookId');
        }
      }

      // 2. Refresh available cashbooks
      await _loadAvailableCashbooks();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        print('BackupNotifier: Error deleting cloud cashbook: $e');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> clearAllCloudData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 1. Find the root folder ID in appDataFolder
      final query =
          "name = 'Flowpaisa Backups' and 'appDataFolder' in parents and trashed = false";
      final list = await _driveService.listFoldersWithQuery(query);

      // 2. Delete the entire root folder if it exists
      if (list.isNotEmpty) {
        for (final folder in list) {
          if (folder.id != null) {
            await _driveService.deleteFile(folder.id!);
            if (kDebugMode) {
              print(
                  'BackupNotifier: Successfully deleted root Flowpaisa Backups folder (${folder.id})');
            }
          }
        }
      }

      // 3. Also check for any orphaned manifest.json or v*.json in the root appDataFolder
      // (Just in case they were created there by previous buggy versions)
      final orphanedQuery =
          "'appDataFolder' in parents and (name = 'manifest.json' or name contains 'v') and trashed = false";
      final orphanedFiles =
          await _driveService.listFilesWithQuery(orphanedQuery);
      for (final file in orphanedFiles) {
        if (file.id != null) {
          await _driveService.deleteFile(file.id!);
          if (kDebugMode) {
            print(
                'BackupNotifier: Deleted orphaned file: ${file.name} (${file.id})');
          }
        }
      }

      // 4. Reset local state
      state = state.copyWith(
        availableCashbookIds: [],
        cashbookMetadata: {},
        backups: [],
        cloudVersion: 0,
      );

      // 5. Reload available cashbooks
      await _loadAvailableCashbooks();
      await _refreshVersions();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        print('BackupNotifier: Error clearing all cloud data: $e');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> restore(String fileId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final activeCashbook = ref.read(activeCashbookProvider);
      await _repository.restore(fileId, fileName: activeCashbook.dbPath);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> resetSyncAfterRestore() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final activeCashbook = ref.read(activeCashbookProvider);

      // 1. Get local version from restored DB
      final db = ref.read(databaseProvider);
      int localVersion = 0;
      try {
        final metadata = await (db.select(db.syncMetadata)).get();
        if (metadata.isNotEmpty) {
          // Find max version or version for this device
          localVersion = metadata
              .map((m) => m.version)
              .fold(0, (prev, v) => v > prev ? v : prev);
        }
      } catch (e) {
        if (kDebugMode) {
          print('BackupNotifier: Error reading local version for reset: $e');
        }
      }

      // 2. Reset cloud manifest to this version
      await _repository.resetSyncToVersion(activeCashbook.id, localVersion);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> resetLocalSyncState() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final db = ref.read(databaseProvider);

      // 1. Mark all records in all tables as unsynced
      final tables = [
        'categories',
        'contacts',
        'transactions',
        'receivables',
        'payables',
        'reminders',
        'app_currencies',
        'transaction_schedules'
      ];

      for (final table in tables) {
        await db.customStatement('UPDATE $table SET is_not_synced = 1');
      }

      // 2. Reset local version to 0
      await db.customStatement('DELETE FROM sync_metadata');

      // 3. Refresh state
      await _refreshVersions();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> clearGranularCloudData(String cashbookId,
      {required bool clearBackups, required bool clearSync}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.clearCloudData(cashbookId,
          clearBackups: clearBackups, clearSync: clearSync);

      // If we cleared sync history, we should also reset local sync state for this cashbook
      // to avoid version mismatches next time we sync.
      if (clearSync) {
        final activeCashbook = ref.read(activeCashbookProvider);
        if (activeCashbook.id == cashbookId) {
          await resetLocalSyncState();
        }
      }

      await _loadAvailableCashbooks();
      await _refreshVersions();
      state = state.copyWith(
        isLoading: false,
        lastSuccessMessage: 'Cloud data cleared successfully',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, lastErrorMessage: e.toString());
      rethrow;
    }
  }
}

final backupProvider =
    NotifierProvider<BackupNotifier, BackupState>(BackupNotifier.new);
