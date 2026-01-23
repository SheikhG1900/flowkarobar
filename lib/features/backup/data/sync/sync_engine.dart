import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/backup/data/google_drive_service.dart';
import 'package:flowpaisa/features/backup/domain/models/sync_manifest.dart';
import 'package:flowpaisa/features/backup/domain/models/sync_version_file.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class SyncEngine {
  final AppDatabase _db;
  final GoogleDriveService _driveService;
  final Cashbook _cashbook;

  SyncEngine({
    required AppDatabase db,
    required GoogleDriveService driveService,
    required Cashbook cashbook,
  })  : _db = db,
        _driveService = driveService,
        _cashbook = cashbook;

  Future<void> sync() async {
    if (!_driveService.isSignedIn) {
      throw Exception('User not signed in');
    }

    try {
      final deviceId = await _getDeviceId();
      final cashbookFolderId = await _driveService.getOrCreateCashbookFolder(_cashbook.id);
      
      // Step 1: Catch-up
      final manifestResult = await _getManifest(cashbookFolderId);
      SyncManifest manifest = manifestResult.manifest;
      String manifestEtag = manifestResult.etag;
      String? manifestFileId = manifestResult.fileId;

      final localMetadata = await _getLocalMetadata(deviceId);
      
      if (manifest.version > localMetadata.version) {
        await _catchUp(manifest.version, localMetadata.version, cashbookFolderId);
      }

      // Step 2: Lock Assessment
      if (manifest.lockedBy != null && manifest.lockedBy != deviceId) {
        final lockTime = manifest.lockedAt;
        if (lockTime != null && DateTime.now().toUtc().difference(lockTime).inMinutes < 60) {
          print('Database is locked by another device: ${manifest.lockedBy}');
          return; // Abort
        }
      }

      // Check for local changes
      final localChanges = await _getLocalChanges();
      if (localChanges.isEmpty) {
        print('No local changes to sync');
        // Still update local version if we caught up
        await _updateLocalMetadata(deviceId, manifest.version);
        return;
      }

      // Step 3: Acquire Lock
      manifest = manifest.copyWith(
        lockedBy: deviceId,
        lockedAt: DateTime.now().toUtc(),
      );

      try {
        manifestFileId = await _driveService.uploadFile(
          name: 'manifest.json',
          content: manifest.toJson(),
          parentId: cashbookFolderId,
          etag: manifestEtag,
          fileId: manifestFileId,
        );
      } catch (e) {
        if (e.toString().contains('412')) {
          print('Manifest changed while catching up, restarting sync');
          return sync(); // Restart
        }
        rethrow;
      }

      // Step 4: Execute & Commit
      final nextVersion = manifest.version + 1;
      final versionFile = SyncVersionFile(
        version: nextVersion,
        createdAt: DateTime.now().toUtc(),
        deviceId: deviceId,
        changes: localChanges,
      );

      await _driveService.uploadFile(
        name: 'v$nextVersion.json',
        content: versionFile.toJson(),
        parentId: cashbookFolderId,
      );

      // Update manifest: increment version, clear lock
      manifest = manifest.copyWith(
        version: nextVersion,
        lockedBy: null,
        lockedAt: null,
      );

      // Get new etag after lock update
      final latestManifest = await _getManifest(cashbookFolderId);
      
      await _driveService.uploadFile(
        name: 'manifest.json',
        content: manifest.toJson(),
        parentId: cashbookFolderId,
        etag: latestManifest.etag,
        fileId: manifestFileId,
      );

      // Local Cleanup
      await _markLocalChangesSynced(localChanges);
      await _updateLocalMetadata(deviceId, nextVersion);

      // ToastUtils.showSuccess('Sync completed successfully');
    } catch (e) {
      print('Sync failed: $e');
      // ToastUtils.showError('Sync failed: $e');
      rethrow;
    }
  }

  Future<({SyncManifest manifest, String etag, String? fileId})> _getManifest(String folderId) async {
    final fileId = await _driveService.getFileIdByName('manifest.json', folderId);
    if (fileId == null) {
      return (manifest: SyncManifest(version: 0), etag: '', fileId: null);
    }
    final result = await _driveService.downloadFileWithETag(fileId);
    return (manifest: SyncManifest.fromJson(result.content), etag: result.etag, fileId: fileId);
  }

  Future<SyncMetadataData> _getLocalMetadata(String deviceId) async {
    final metadata = await (_db.select(_db.syncMetadata)..where((t) => t.deviceId.equals(deviceId))).getSingleOrNull();
    if (metadata == null) {
      final newMetadata = SyncMetadataData(deviceId: deviceId, version: 0);
      await _db.into(_db.syncMetadata).insert(newMetadata);
      return newMetadata;
    }
    return metadata;
  }

  Future<void> _updateLocalMetadata(String deviceId, int version) async {
    await (_db.update(_db.syncMetadata)..where((t) => t.deviceId.equals(deviceId)))
        .write(SyncMetadataCompanion(
      version: Value(version),
      lastSyncAt: Value(DateTime.now().toUtc()),
    ));
  }

  Future<void> _catchUp(int remoteVersion, int localVersion, String folderId) async {
    for (int v = localVersion + 1; v <= remoteVersion; v++) {
      final fileName = 'v$v.json';
      final fileId = await _driveService.getFileIdByName(fileName, folderId);
      if (fileId == null) continue;

      final result = await _driveService.downloadFileWithETag(fileId);
      final versionFile = SyncVersionFile.fromJson(result.content);
      
      await _applyChanges(versionFile.changes);
    }
  }

  Future<void> _applyChanges(Map<String, List<Map<String, dynamic>>> changes) async {
    await _db.transaction(() async {
      for (final entry in changes.entries) {
        final tableName = entry.key;
        final rows = entry.value;

        for (final row in rows) {
          // Use custom insert with OnConflictUpdate
          // Note: This requires knowing the table. We can map table names to Drift tables.
          final table = _getTableByName(tableName);
          if (table == null) continue;

          // We'll use a raw query or a generic way if possible, 
          // but Drift works better with typed companions.
          // For simplicity, we'll implement a basic upsert logic.
          await _upsertRow(tableName, row);
        }
      }
    });
  }

  Future<Map<String, List<Map<String, dynamic>>>> _getLocalChanges() async {
    final changes = <String, List<Map<String, dynamic>>>{};
    
    final tables = [
      'categories', 'contacts', 'transactions', 'receivables', 
      'payables', 'reminders', 'app_currencies', 'transaction_schedules'
    ];

    for (final tableName in tables) {
      final rows = await _db.customSelect(
        'SELECT * FROM $tableName WHERE is_not_synced = 1',
      ).get();
      
      if (rows.isNotEmpty) {
        changes[tableName] = rows.map((r) => r.data).toList();
      }
    }

    return changes;
  }

  Future<void> _markLocalChangesSynced(Map<String, List<Map<String, dynamic>>> changes) async {
    await _db.transaction(() async {
      for (final entry in changes.entries) {
        final tableName = entry.key;
        final rows = entry.value;
        for (final row in rows) {
          final uuid = row['uuid'];
          await _db.customStatement(
            'UPDATE $tableName SET is_not_synced = 0 WHERE uuid = ?',
            [uuid],
          );
        }
      }
    });
  }

  Future<void> _upsertRow(String tableName, Map<String, dynamic> data) async {
    // Reset isNotSynced flag for incoming changes
    final rowData = Map<String, dynamic>.from(data);
    rowData['is_not_synced'] = 0;

    final columns = rowData.keys.join(', ');
    final placeholders = List.filled(rowData.length, '?').join(', ');
    final updates = rowData.keys.map((k) => '$k = EXCLUDED.$k').join(', ');

    await _db.customStatement(
      'INSERT INTO $tableName ($columns) VALUES ($placeholders) '
      'ON CONFLICT(uuid) DO UPDATE SET $updates',
      rowData.values.toList(),
    );
  }

  TableInfo? _getTableByName(String name) {
    // This is a helper to map table names to Drift table objects if needed
    // For raw SQL upsert, we don't strictly need it.
    return null;
  }

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    }
    return 'unknown_device';
  }
}
