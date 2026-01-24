import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/backup/data/google_drive_service.dart';
import 'package:flowpaisa/features/backup/data/backup_repository.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/features/backup/domain/models/sync_manifest.dart';
import 'package:flowpaisa/features/backup/data/sync/sync_scheduler.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final String syncInterval; // 'manual', '12', '24', '36', '48', '60', '72', '84', '96'
  final String backupInterval; // 'manual', 'weekly', 'monthly'
  final int localVersion;
  final int cloudVersion;
  final DateTime? lastSyncTime;
  final List<String> availableCashbookIds;
  final Map<String, CloudCashbookMetadata> cashbookMetadata; // id -> metadata
  final String? selectedCloudCashbookId;

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
    this.lastSyncTime,
    this.availableCashbookIds = const [],
    this.cashbookMetadata = const {},
    this.selectedCloudCashbookId,
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
    DateTime? lastSyncTime,
    List<String>? availableCashbookIds,
    Map<String, CloudCashbookMetadata>? cashbookMetadata,
    String? selectedCloudCashbookId,
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
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      availableCashbookIds: availableCashbookIds ?? this.availableCashbookIds,
      cashbookMetadata: cashbookMetadata ?? this.cashbookMetadata,
      selectedCloudCashbookId: selectedCloudCashbookId ?? this.selectedCloudCashbookId,
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
    
    final lastTime = await _repository.getLastBackupTime(cashbookId: activeCashbook.id);
    state = state.copyWith(lastBackupTime: lastTime);

    // Load settings from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      syncInterval: prefs.getString('sync_interval') ?? 'manual',
      backupInterval: prefs.getString('backup_interval') ?? 'manual',
    );

    await _refreshVersions();

    if (_driveService.isSignedIn) {
      await loadBackups();
      await _loadAvailableCashbooks();
    }
  }

  Future<void> _loadAvailableCashbooks() async {
    if (!_driveService.isSignedIn || !_driveService.isDriveApiInitialized) return;
    try {
      final folderNames = await _driveService.listCashbookIds();
      final Map<String, CloudCashbookMetadata> metadataMap = {};
      final List<String> ids = [];

      for (final name in folderNames) {
        if (name == 'FlowPaisa Backups') continue;
        
        final parts = name.split('|');
        final id = parts[0];
        
        // Default values
        String cashbookName = id == 'default' ? 'Main' : 'Cloud DB';
        String color = '#757575';
        String icon = Symbols.account_balance_wallet.codePoint.toString();

        if (parts.length >= 2) cashbookName = parts[1];
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
      print('Failed to load available cashbooks from cloud: $e');
    }
  }

  Future<void> _refreshVersions() async {
    final activeCashbook = ref.read(activeCashbookProvider);
    
    // 1. Get local version and last sync time
    // Use the existing database instance from the provider to avoid multiple instantiations
    final db = ref.read(databaseProvider);
    int localVersion = 0;
    DateTime? lastSyncTime;
    try {
      final metadata = await (db.select(db.syncMetadata)).get();
      if (metadata.isNotEmpty) {
        localVersion = metadata.map((m) => m.version).fold(0, (prev, v) => v > prev ? v : prev);
        lastSyncTime = metadata.map((m) => m.lastSyncAt).fold(null, (prev, v) => (v != null && (prev == null || v.isAfter(prev))) ? v : prev);
      }
    } catch (e) {
      print('Failed to load local version: $e');
    }

    // 2. Get cloud version
    int cloudVersion = 0;
    if (_driveService.isSignedIn && _driveService.isDriveApiInitialized) {
      try {
        final folderId = await _driveService.getOrCreateCashbookFolder(activeCashbook.id);
        final manifestFileId = await _driveService.getFileIdByName('manifest.json', folderId);
        if (manifestFileId != null) {
          final result = await _driveService.downloadFileWithETag(manifestFileId);
          final manifest = SyncManifest.fromJson(result.content);
          cloudVersion = manifest.version;
        }
      } catch (e) {
        print('Failed to load cloud manifest version: $e');
      }
    }

    state = state.copyWith(
      localVersion: localVersion,
      cloudVersion: cloudVersion,
      lastSyncTime: lastSyncTime,
    );
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
      state = state.copyWith(isLoading: true, selectedCloudCashbookId: cashbookId);
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
      final cloudName = metadata?.name ?? (cashbookId == 'default' ? 'Main Cashbook' : 'Restored Cashbook');
      final cloudColor = metadata?.color ?? '#757575';
      final cloudIcon = metadata?.icon ?? Symbols.account_balance_wallet.codePoint.toString();
      
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
        await ref.read(cashbooksProvider.notifier).addCashbookFromCloud(newCashbook);
        print('Created new local cashbook entry for cloud ID: $cashbookId with name: $cloudName, color: $cloudColor, icon: $cloudIcon');
      }

      // 3. Restore the data to the correct file path
      await _repository.restore(fileId, fileName: dbPath, cashbookId: cashbookId);
      
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

  Future<void> backup() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Ensure Drive API is initialized before proceeding
      if (!_driveService.isDriveApiInitialized) {
        print('Drive API not initialized, attempting initialization...');
        await _driveService.signIn(); // This triggers initialization
      }

      final activeCashbook = ref.read(activeCashbookProvider);
      print('Starting backup for cashbook: ${activeCashbook.name}, path: ${activeCashbook.dbPath}');
      
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
        if (e.toString().contains('Access was denied') || e.toString().contains('invalid_token')) {
          print('Access denied, attempting re-authentication...');
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
      
      print('Backup upload successful');
      
      // Refresh list and time
      final backups = await _driveService.listBackups(cashbookId: activeCashbook.id);
      final time = await _repository.getLastBackupTime(cashbookId: activeCashbook.id);
      
      state = state.copyWith(
        isLoading: false,
        backups: backups,
        lastBackupTime: time,
      );
      print('Backup state updated. Backups found: ${backups.length}');
    } catch (e, stack) {
      print('Backup failed with error: $e');
      print('Stack trace: $stack');
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
      
      // 1. Find the folder name (could be id or id|name)
      final folderNames = await _driveService.listCashbookIds();
      final folderName = folderNames.firstWhere(
        (name) => name == cashbookId || name.startsWith('$cashbookId|'),
        orElse: () => '',
      );

      if (folderName.isNotEmpty) {
        // 2. Get the root folder ID
        final rootFolderId = await _driveService.getOrCreateCashbookFolder('FlowPaisa Backups');
        
        // 3. Get the specific cashbook folder ID
        final folderId = await _driveService.getFileIdByName(folderName, rootFolderId);
        if (folderId != null) {
          await _driveService.deleteFile(folderId);
          print('Successfully deleted cloud folder: $folderName ($folderId)');
        }
      }

      // 4. Force state update by removing the ID locally before refreshing
      final updatedIds = state.availableCashbookIds.where((id) => id != cashbookId).toList();
      final updatedMetadata = Map<String, CloudCashbookMetadata>.from(state.cashbookMetadata)..remove(cashbookId);
      
      state = state.copyWith(
        availableCashbookIds: updatedIds,
        cashbookMetadata: updatedMetadata,
        // If the deleted cashbook was selected, switch back to active cashbook
        selectedCloudCashbookId: state.selectedCloudCashbookId == cashbookId 
            ? ref.read(activeCashbookProvider).id 
            : state.selectedCloudCashbookId,
      );

      // 5. Refresh from cloud to be sure
      await _loadAvailableCashbooks();
      
      // 6. If we switched selection, load backups for the new selection
      if (state.selectedCloudCashbookId != null) {
        await loadBackupsForCashbook(state.selectedCloudCashbookId!);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('Error deleting cloud cashbook: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
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
      final db = AppDatabase(fileName: activeCashbook.dbPath);
      int localVersion = 0;
      try {
        final metadata = await (db.select(db.syncMetadata)).get();
        if (metadata.isNotEmpty) {
          // Find max version or version for this device
          localVersion = metadata.map((m) => m.version).fold(0, (prev, v) => v > prev ? v : prev);
        }
      } finally {
        await db.close();
      }

      // 2. Reset cloud manifest to this version
      await _repository.resetSyncToVersion(activeCashbook.id, localVersion);
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final backupProvider = NotifierProvider<BackupNotifier, BackupState>(BackupNotifier.new);
