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

/// State for Backup Screen
class BackupState {
  final bool isLoading;
  final GoogleSignInAccount? currentUser;
  final List<drive.File> backups;
  final DateTime? lastBackupTime;
  final String? error;

  // New settings and versioning fields
  final String
      syncInterval; // 'manual', '12', '24', '36', '48', '60', '72', '84', '96'
  final String backupInterval; // 'manual', 'weekly', 'monthly'
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

  BackupState({
    this.isLoading = false,
    this.currentUser,
    this.backups = const [],
    this.lastBackupTime,
    this.error,
    this.syncInterval = 'manual',
    this.backupInterval = 'manual',
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
  });

  factory BackupState.initial() {
    return BackupState();
  }

  BackupState copyWith({
    bool? isLoading,
    GoogleSignInAccount? currentUser,
    List<drive.File>? backups,
    DateTime? lastBackupTime,
    String? error,
    String? syncInterval,
    String? backupInterval,
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
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      backups: backups ?? this.backups,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      error: error,
      syncInterval: syncInterval ?? this.syncInterval,
      backupInterval: backupInterval ?? this.backupInterval,
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
    );
  }
}

class BackupNotifier extends Notifier<BackupState> {
  late GoogleDriveService _driveService;
  late BackupRepository _repository;

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
      backupInterval: prefs.getString('backup_interval') ?? 'manual',
    );

    await _refreshVersions();
    _startDatabaseStatusWatcher();

    if (_driveService.isSignedIn) {
      await loadBackups();
      await _loadAvailableCashbooks();

      // Auto-sync on startup if enabled
      if (syncInterval != 'manual') {
        if (kDebugMode) {
          print(
              'BackupNotifier: Auto-sync on startup triggered (interval: $syncInterval)');
        }

        // Process all cashbooks on startup instead of just the active one
        final prefs = await SharedPreferences.getInstance();
        final cashbooksJson = prefs.getStringList('cashbooks_list');
        if (cashbooksJson != null && cashbooksJson.isNotEmpty) {
          // We trigger the background task which already handles all cashbooks
          await SyncScheduler.triggerOnDemandSync();
        } else {
          // Fallback to active cashbook if list is empty
          triggerSync(null);
        }
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

      // 2. Safety timeout: If background task doesn't report back, clear loading state
      Future.delayed(const Duration(seconds: 15), () {
        if (state.isLoading && state.syncStatus == 'Syncing...') {
          // Check if it's still "Syncing..." in SharedPreferences
          _checkFinalStatus();
        }
      });
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString(), syncStatus: 'Idle');
    }
  }

  /// Public method to refresh cloud state (e.g., when app comes to foreground)
  Future<void> refreshCloudState() async {
    await _fetchCloudState();
  }

  Future<void> _checkFinalStatus() async {
    final activeCashbook = ref.read(activeCashbookProvider);
    final prefs = await SharedPreferences.getInstance();
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

    // 1. Refresh local version and sync time from DB
    final db = ref.read(databaseProvider);
    try {
      final metadata = await (db.select(db.syncMetadata)).get();
      if (metadata.isNotEmpty) {
        final localVersion = metadata
            .map((m) => m.version)
            .fold(0, (prev, v) => v > prev ? v : prev);
        final lastSyncTime = metadata.map((m) => m.lastSyncAt).fold<DateTime?>(
            null,
            (prev, v) =>
                (v != null && (prev == null || v.isAfter(prev))) ? v : prev);
        state = state.copyWith(
          localVersion: localVersion,
          lastSyncTime: lastSyncTime,
        );
      } else {
        state = state.copyWith(localVersion: 0, lastSyncTime: null);
      }
    } catch (e) {
      if (kDebugMode) {
        print('BackupNotifier: Failed to refresh local version: $e');
      }
    }

    // 2. Fetch fresh cloud state (cloud version, lock status, delta files)
    await _fetchCloudState();

    // 3. Refresh unsynced counts
    await _updateTotalUnsyncedCount();

    state = state.copyWith(isLoading: false);
  }

  Future<void> _refreshVersions() async {
    final db = ref.read(databaseProvider);

    // 1. Listen to local version changes
    final versionStream = db.select(db.syncMetadata).watch();
    versionStream.listen((metadata) {
      if (metadata.isNotEmpty) {
        final localVersion = metadata
            .map((m) => m.version)
            .fold(0, (prev, v) => v > prev ? v : prev);
        final lastSyncTime = metadata.map((m) => m.lastSyncAt).fold<DateTime?>(
            null,
            (prev, v) =>
                (v != null && (prev == null || v.isAfter(prev))) ? v : prev);
        state = state.copyWith(
          localVersion: localVersion,
          lastSyncTime: lastSyncTime,
        );
      } else {
        state = state.copyWith(localVersion: 0, lastSyncTime: null);
      }
    });

    // 2. Get initial local version
    try {
      final metadata = await (db.select(db.syncMetadata)).get();
      if (metadata.isNotEmpty) {
        final localVersion = metadata
            .map((m) => m.version)
            .fold(0, (prev, v) => v > prev ? v : prev);
        final lastSyncTime = metadata.map((m) => m.lastSyncAt).fold<DateTime?>(
            null,
            (prev, v) =>
                (v != null && (prev == null || v.isAfter(prev))) ? v : prev);
        state = state.copyWith(
          localVersion: localVersion,
          lastSyncTime: lastSyncTime,
        );
      } else {
        // Explicitly set to 0 if metadata is empty (e.g. after clear data)
        state = state.copyWith(localVersion: 0, lastSyncTime: null);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load local version: $e');
      }
    }

    // 3. Get initial cloud state
    await _fetchCloudState();

    // 4. Listen to unsynced counts
    try {
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
        final countStream = db
            .customSelect(
                'SELECT COUNT(*) as count FROM $table WHERE is_not_synced = 1')
            .watchSingle();

        final subscription = countStream.listen((countResult) {
          if (!ref.mounted) return;
          _updateTotalUnsyncedCount();
          // Also fetch cloud state when a sync might have happened (unsynced count drops to 0)
          final count = (countResult.data['count'] as num).toInt();
          if (count == 0) {
            _fetchCloudState();
          }
        });
        ref.onDispose(() => subscription.cancel());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load unsynced count: $e');
      }
    }

    // 5. Initial unsynced count update
    _updateTotalUnsyncedCount();
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
      String? lockedBy;
      DateTime? lockedAt;
      final manifestFileId =
          await _driveService.getFileIdByName('manifest.json', folderId);
      if (manifestFileId != null) {
        final result = await _driveService.downloadFileWithETag(manifestFileId);
        final manifest = SyncManifest.fromJson(result.content);
        cloudVersion = manifest.version;
        lockedBy = manifest.lockedBy;
        lockedAt = manifest.lockedAt;
      }

      // Load delta files
      final allDeltas = await _driveService.listSyncFiles(folderId);

      // Filter deltas that are above the current local version
      final localVersion = state.localVersion;
      final upcomingDeltas = allDeltas.where((file) {
        final ver = int.tryParse(
                file.name?.replaceAll('v', '').replaceAll('.json', '') ??
                    '0') ??
            0;
        return ver > localVersion;
      }).toList();

      // Sort ascending to show the next ones to sync first
      upcomingDeltas.sort((a, b) {
        final aVer = int.tryParse(
                a.name?.replaceAll('v', '').replaceAll('.json', '') ?? '0') ??
            0;
        final bVer = int.tryParse(
                b.name?.replaceAll('v', '').replaceAll('.json', '') ?? '0') ??
            0;
        return aVer.compareTo(bVer);
      });

      // If no upcoming deltas, show the last 5 synced deltas (descending)
      List<drive.File> displayDeltas;
      if (upcomingDeltas.isNotEmpty) {
        displayDeltas = upcomingDeltas.take(5).toList();
      } else {
        final syncedDeltas = allDeltas.where((file) {
          final ver = int.tryParse(
                  file.name?.replaceAll('v', '').replaceAll('.json', '') ??
                      '0') ??
              0;
          return ver <= localVersion && ver > 0;
        }).toList();
        syncedDeltas.sort((a, b) {
          final aVer = int.tryParse(
                  a.name?.replaceAll('v', '').replaceAll('.json', '') ?? '0') ??
              0;
          final bVer = int.tryParse(
                  b.name?.replaceAll('v', '').replaceAll('.json', '') ?? '0') ??
              0;
          return bVer.compareTo(aVer);
        });
        displayDeltas = syncedDeltas.take(5).toList();
      }

      state = state.copyWith(
        cloudVersion: cloudVersion,
        lockedBy: lockedBy,
        lockedAt: lockedAt,
        deltaFiles: displayDeltas,
      );
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
      'transaction_schedules'
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
    state = state.copyWith(unsyncedCount: total);
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
    final db = ref.read(databaseProvider);
    final deviceId = await _getDeviceId();

    final subscription = (db.select(db.syncMetadata)
          ..where((t) => t.deviceId.equals(deviceId)))
        .watchSingleOrNull()
        .listen((metadata) {
      if (!ref.mounted) return;

      if (metadata != null) {
        String status = metadata.syncStatus;
        final startedAt = metadata.syncStartedAt;

        // Stuck sync detection: if started more than 10 minutes ago, treat as Idle
        if (startedAt != null &&
            DateTime.now().toUtc().difference(startedAt).inMinutes > 10) {
          status = 'Idle';
        }

        if (state.syncStatus != status || state.syncStartedAt != startedAt) {
          state = state.copyWith(
            syncStatus: status,
            syncStartedAt: startedAt,
            localVersion: metadata.version,
            lastSyncTime: metadata.lastSyncAt,
            isLoading: status.contains('Syncing') ||
                status.contains('Pulling') ||
                status.contains('Pushing'),
          );

          // If status just changed to Success, trigger UI refreshes
          if (status == 'Success') {
            _handleSyncSuccess();
          }
        }
      }
    });

    ref.onDispose(() {
      subscription.cancel();
    });
  }

  Future<void> _handleSyncSuccess() async {
    // CRITICAL: Invalidate the database provider first.
    ref.invalidate(databaseProvider);

    // Then invalidate the specific list providers
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

    // Refresh unsynced counts and cloud state immediately
    await _updateTotalUnsyncedCount();
    await _fetchCloudState();

    // Reset status to Idle after a delay in the database
    Future.delayed(const Duration(seconds: 3), () async {
      if (!ref.mounted) return;
      final db = ref.read(databaseProvider);
      final deviceId = await _getDeviceId();
      await (db.update(db.syncMetadata)..where((t) => t.deviceId.equals(deviceId)))
          .write(SyncMetadataCompanion(
        syncStatus: const Value('Idle'),
        syncStartedAt: const Value(null),
      ));
    });
  }

  Future<void> setSyncInterval(String interval) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sync_interval', interval);
    state = state.copyWith(syncInterval: interval);
    await SyncScheduler.scheduleDailySync();
  }

  Future<void> setBackupInterval(String interval) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backup_interval', interval);
    state = state.copyWith(backupInterval: interval);
    // TODO: Implement auto backup scheduling if needed
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
      state = state.copyWith(
        currentUser: account,
        isLoading: false,
      );
      await loadBackups();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _driveService.signOut();
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

  Future<void> restoreToCashbook(String fileId, String cashbookId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 1. Get the metadata from our cloud metadata map
      final metadata = state.cashbookMetadata[cashbookId];
      final cloudName = metadata?.name ??
          (cashbookId == 'default' ? 'Main Cashbook' : 'Restored Cashbook');
      final cloudColor = metadata?.color ?? '#757575';
      final cloudIcon =
          metadata?.icon ?? Symbols.account_balance_wallet.codePoint.toString();

      // 2. Find if we already have this cashbook locally
      final cashbooks = ref.read(cashbooksProvider);
      final existing = cashbooks.where((c) => c.id == cashbookId).toList();

      String dbPath;
      if (existing.isNotEmpty) {
        dbPath = existing.first.dbPath;
      } else {
        // Create a NEW cashbook entry locally if it doesn't exist
        // This prevents overwriting the active cashbook with data from a different one
        dbPath = 'cashbook_$cashbookId.db';
        final newCashbook = Cashbook(
          id: cashbookId,
          name: cloudName,
          colorCode: cloudColor,
          iconCodePoint: cloudIcon,
          dbPath: dbPath,
          createdAt: DateTime.now(),
        );
        // Add to local list
        await ref
            .read(cashbooksProvider.notifier)
            .addCashbookFromCloud(newCashbook);
        if (kDebugMode) {
          print(
              'Created new local cashbook entry for cloud ID: $cashbookId with name: $cloudName, color: $cloudColor, icon: $cloudIcon');
        }
      }

      // 3. Restore the data to the correct file path
      await _repository.restore(fileId,
          fileName: dbPath, cashbookId: cashbookId);

      // 4. Invalidate providers to refresh UI
      // If we restored to a different cashbook, the user will need to switch to it
      // if it was the active one, refresh it
      if (ref.read(activeCashbookIdProvider) == cashbookId) {
        ref.invalidate(databaseProvider);
        ref.invalidate(activeCashbookProvider);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> backup(AppLocalizations l10n) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Ensure Drive API is initialized before proceeding
      if (!_driveService.isDriveApiInitialized) {
        if (kDebugMode) {
          print('Drive API not initialized, attempting initialization...');
        }
        await _driveService.signIn(); // This triggers initialization
      }

      final activeCashbook = ref.read(activeCashbookProvider);
      if (kDebugMode) {
        print(
            'Starting backup for cashbook: ${activeCashbook.name}, path: ${activeCashbook.dbPath}');
      }

      try {
        await _repository.backup(
          fileName: activeCashbook.dbPath,
          cashbookId: activeCashbook.id,
          cashbookName: activeCashbook.name,
          color: activeCashbook.colorCode,
          icon: activeCashbook.iconCodePoint,
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
            fileName: activeCashbook.dbPath,
            cashbookId: activeCashbook.id,
            cashbookName: activeCashbook.name,
            color: activeCashbook.colorCode,
            icon: activeCashbook.iconCodePoint,
          );
        } else {
          rethrow;
        }
      }

      if (kDebugMode) {
        print('Backup upload successful');
      }

      // Refresh list and time
      final backups =
          await _driveService.listBackups(cashbookId: activeCashbook.id);
      final time =
          await _repository.getLastBackupTime(cashbookId: activeCashbook.id);

      state = state.copyWith(
        isLoading: false,
        backups: backups,
        lastBackupTime: time,
      );
      if (kDebugMode) {
        print('Backup state updated. Backups found: ${backups.length}');
      }

      // Add local notification
      ref.read(notificationProvider.notifier).addNotification(
            title: l10n.notificationBackupSuccessTitle,
            message: l10n.notificationBackupSuccessMessage(activeCashbook.name),
            type: NotificationType.backup,
          );
    } catch (e, stack) {
      if (kDebugMode) {
        print('Backup failed with error: $e');
        print('Stack trace: $stack');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
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
}

final backupProvider =
    NotifierProvider<BackupNotifier, BackupState>(BackupNotifier.new);
