import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/backup/data/google_drive_service.dart';
import 'package:flowpaisa/features/backup/domain/models/sync_manifest.dart';
import 'package:flowpaisa/features/backup/domain/models/sync_version_file.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';

/// SQLite busy/lock: code 5 or 1555, or message "database is locked".
bool _isDatabaseLockedException(Object e) {
  final s = e.toString();
  return s.contains('database is locked') ||
      s.contains('1555') ||
      s.contains('code 5') ||
      s.contains('SQLITE_BUSY');
}

const int _kSyncRetryMaxAttempts = 3;
const Duration _kSyncRetryDelay = Duration(milliseconds: 300);

/// Runs [fn] and retries on database locked (SQLITE_BUSY) up to [_kSyncRetryMaxAttempts].
Future<void> _runWithRetryOnBusy(Future<void> Function() fn) async {
  int attempt = 0;
  while (true) {
    try {
      await fn();
      return;
    } catch (e) {
      if (!_isDatabaseLockedException(e) || attempt >= _kSyncRetryMaxAttempts) {
        rethrow;
      }
      attempt++;
      if (kDebugMode) {
        print(
            'SyncEngine: Database locked, retry $attempt/$_kSyncRetryMaxAttempts in ${_kSyncRetryDelay.inMilliseconds}ms');
      }
      await Future<void>.delayed(_kSyncRetryDelay);
    }
  }
}

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
    // Enable WAL mode for this connection
    try {
      await _db.customStatement('PRAGMA journal_mode=WAL;');
      await _db.customStatement('PRAGMA synchronous=NORMAL;');
      await _db.customStatement('PRAGMA busy_timeout=5000;');
    } catch (e) {
      if (kDebugMode) {
        print('SyncEngine: Warning - Failed to set WAL mode: $e');
      }
    }

    if (kDebugMode) {
      print(
          'SyncEngine: Starting sync for cashbook: ${_cashbook.name} (ID: ${_cashbook.id})');
    }
    if (!_driveService.isSignedIn) {
      if (kDebugMode) {
        print('SyncEngine: Error - User not signed in');
      }
      throw Exception('User not signed in');
    }

    try {
      final deviceId = await _getDeviceId();
      if (kDebugMode) {
        print('SyncEngine: Device ID: $deviceId');
      }

      // CRITICAL: Force a reload of SharedPreferences to clear any stale status
      // from previous runs before starting a new sync.
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      // Initial status update
      await _updateSyncStatus(deviceId, 'Pulling...', isStarting: true);

      // CRITICAL: Ensure we have a fresh manifest and local metadata
      // before deciding on the catch-up logic.
      final cashbookFolderId = await _driveService.getOrCreateCashbookFolder(
        _cashbook.id,
        cashbookName: _cashbook.name,
        color: _cashbook.colorCode,
        icon: _cashbook.iconCodePoint,
      );
      if (kDebugMode) {
        print('SyncEngine: Cashbook folder ID: $cashbookFolderId');
      }

      // Step 1: Catch-up
      if (kDebugMode) {
        print('SyncEngine: Fetching manifest...');
      }
      final manifestResult = await _getManifest(cashbookFolderId);
      SyncManifest manifest = manifestResult.manifest;
      String manifestEtag = manifestResult.etag;
      String? manifestFileId = manifestResult.fileId;
      if (kDebugMode) {
        print('SyncEngine: Cloud manifest version: ${manifest.version}');
      }

      var localMetadata = await _getLocalMetadata(deviceId);
      if (kDebugMode) {
        print('SyncEngine: Local metadata version: ${localMetadata.version}');
      }

      // Update cloud version in local metadata immediately after fetching manifest
      if (localMetadata.cloudVersion != manifest.version) {
        await _updateCloudVersion(deviceId, manifest.version);
        localMetadata = await _getLocalMetadata(deviceId);
      }

      if (manifest.version > localMetadata.version) {
        if (kDebugMode) {
          print(
              'SyncEngine: Catching up from ${localMetadata.version} to ${manifest.version}');
        }
        await _catchUp(manifest.version, localMetadata.version,
            cashbookFolderId, deviceId);

        // Refresh localMetadata variable for subsequent logic
        final updatedMetadata = await _getLocalMetadata(deviceId);
        localMetadata = updatedMetadata;

        // Update the cloud version in the state WITHOUT marking success yet
        // This ensures the UI reflects the new local version but stays in "Pulling..." state
        if (kDebugMode) {
          print(
              'SyncEngine: Catch-up complete. Updating local metadata WITHOUT Success status.');
        }
        await _updateLocalMetadata(
            deviceId, localMetadata.version, manifest.version,
            markAsSuccess: false);

        // CRITICAL: Notify Drift after catch-up so UI components like Recent Transactions refresh
        // even if the push phase is still pending or skipped.
        _db.markTablesUpdated({
          _db.transactions,
          _db.categories,
          _db.contacts,
          _db.accounts,
          _db.accountTransfers,
          _db.receivables,
          _db.payables
        });
      }

      // Step 2: Lock Assessment
      if (manifest.lockedBy != null && manifest.lockedBy != deviceId) {
        final lockTime = manifest.lockedAt;
        if (lockTime != null &&
            DateTime.now().toUtc().difference(lockTime).inMinutes < 60) {
          if (kDebugMode) {
            print(
                'SyncEngine: Database is locked by another device: ${manifest.lockedBy}');
          }

          // Even if locked, we already caught up in Step 1, so update local version
          if (localMetadata.version < manifest.version) {
            if (kDebugMode) {
              print(
                  'SyncEngine: Updating local version to ${manifest.version} despite lock (pull complete)');
            }
            // We use _updateLocalMetadata with markAsSuccess: true here because we are aborting
            // the push phase, so the pull phase is the final successful action.
            await _updateLocalMetadata(
                deviceId, manifest.version, manifest.version,
                markAsSuccess: true);
          } else {
            // Already caught up, just mark as success to refresh UI
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('sync_status_${_cashbook.id}', 'Success');
            await _updateLocalMetadata(
                deviceId, manifest.version, manifest.version,
                markAsSuccess: true);
          }
          return; // Abort push
        }
        if (kDebugMode) {
          print(
              'SyncEngine: Lock expired or belongs to this device, proceeding...');
        }
      }

      // Check for local changes
      if (kDebugMode) {
        print('SyncEngine: Checking for local changes...');
      }
      final localChanges = await _getLocalChanges();

      // CRITICAL: If no local changes, we still need to check if we caught up from cloud
      if (localChanges.isEmpty) {
        if (kDebugMode) {
          print('SyncEngine: No local changes to sync for ${_cashbook.name}');
        }

        // If our local version was behind and we caught up in Step 1, update local metadata now
        if (localMetadata.version < manifest.version) {
          if (kDebugMode) {
            print(
                'SyncEngine: Updating local version from ${localMetadata.version} to ${manifest.version} (caught up from cloud)');
          }
          await _updateLocalMetadata(
              deviceId, manifest.version, manifest.version,
              markAsSuccess: true);
        } else {
          // Already equal, just mark success to refresh UI
          await _updateLocalMetadata(
              deviceId, localMetadata.version, manifest.version,
              markAsSuccess: true);
        }

        return;
      }

      if (kDebugMode) {
        print(
            'SyncEngine: Found local changes in ${localChanges.length} tables. Tables: ${localChanges.keys.join(', ')}');
      }

      // Step 3: Acquire Lock
      await _updateSyncStatus(deviceId, 'Pushing...');
      if (kDebugMode) {
        print('SyncEngine: Acquiring lock...');
      }
      final lockedManifest = manifest.copyWith(
        lockedBy: deviceId,
        lockedAt: DateTime.now().toUtc(),
      );

      try {
        // Use the etag from Step 1 to ensure no one changed it while we were pulling
        manifestFileId = await _driveService.uploadFile(
          name: 'manifest.json',
          content: lockedManifest.toJson(),
          parentId: cashbookFolderId,
          etag: manifestEtag,
          fileId: manifestFileId,
        );
        if (kDebugMode) {
          print('SyncEngine: Lock acquired, manifest updated.');
        }
      } catch (e) {
        if (e.toString().contains('412')) {
          if (kDebugMode) {
            print(
                'SyncEngine: Conflict detected (412) while acquiring lock, restarting sync');
          }
          return sync(); // Restart
        }
        if (kDebugMode) {
          print('SyncEngine: Error uploading manifest to acquire lock: $e');
        }
        rethrow;
      }

      // Step 4: Execute & Commit
      final nextVersion = lockedManifest.version + 1;
      if (kDebugMode) {
        print('SyncEngine: Committing version $nextVersion...');
      }

      // Enable WAL mode for this connection
      try {
        await _db.customStatement('PRAGMA journal_mode=WAL;');
        await _db.customStatement('PRAGMA synchronous=NORMAL;');
        await _db.customStatement('PRAGMA busy_timeout=5000;');
      } catch (e) {
        // Ignore
      }

      // Add summary to changes for local display
      final changesWithSummary =
          Map<String, List<Map<String, dynamic>>>.from(localChanges);
      final summary = <Map<String, dynamic>>[];
      localChanges.forEach((table, rows) {
        summary.add({'table': table, 'count': rows.length});
      });
      changesWithSummary['_summary'] = summary;

      final versionFile = SyncVersionFile(
        version: nextVersion,
        createdAt: DateTime.now().toUtc(),
        deviceId: deviceId,
        changes: changesWithSummary,
      );

      try {
        // 1. Upload the version file first (the data)
        await _driveService.uploadFile(
          name: 'v$nextVersion.json',
          content: versionFile.toJson(),
          parentId: cashbookFolderId,
        );
        if (kDebugMode) {
          print('SyncEngine: Version file v$nextVersion.json uploaded.');
        }

        // 2. ATOMIC UPDATE: Increment version AND clear lock in ONE manifest upload
        final finalManifest = SyncManifest(
          version: nextVersion,
          lockedBy: null,
          lockedAt: null,
        );

        if (kDebugMode) {
          print(
              'SyncEngine: Releasing lock and updating version to $nextVersion at the same time...');
          print(
              'SyncEngine: Final manifest content to upload: ${finalManifest.toJson()}');
        }

        // We MUST fetch the very latest manifest metadata here to get the correct ETag
        // after our own lock acquisition in Step 3.
        final latestManifestResult = await _getManifest(cashbookFolderId);

        await _driveService.uploadFile(
          name: 'manifest.json',
          content: finalManifest.toJson(),
          parentId: cashbookFolderId,
          etag: latestManifestResult.etag,
          fileId: latestManifestResult.fileId,
        );
        if (kDebugMode) {
          print(
              'SyncEngine: Manifest updated (Version: $nextVersion, Lock: Released).');
        }

        // Local Cleanup MUST happen before we update the sync metadata to Success
        // so that the UI correctly sees unsyncedCount = 0 when it gets the Success status.
        await _markLocalChangesSynced(localChanges);

        // Update status to Success in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sync_status_${_cashbook.id}', 'Success');
        await prefs.reload(); // Ensure it's flushed

        await _updateSyncStatus(deviceId, 'Success', isEnding: true);

        // CRITICAL: Update local metadata with the new version and Success status
        // This mirrors the approach used in the pulling/catch-up phase.
        await _updateLocalMetadata(deviceId, nextVersion, nextVersion,
            markAsSuccess: true);

        // Force a small delay to ensure SharedPreferences is flushed
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        if (kDebugMode) {
          print('SyncEngine: Error during commit phase: $e');
        }
        // CRITICAL: Try to release the lock even if the version upload failed
        try {
          if (kDebugMode) {
            print('SyncEngine: Attempting emergency lock release...');
          }
          final emergencyManifestResult = await _getManifest(cashbookFolderId);
          // Only release if WE are the ones holding the lock
          if (emergencyManifestResult.manifest.lockedBy == deviceId) {
            final unlockedManifest = SyncManifest(
              version: emergencyManifestResult.manifest.version,
              lockedBy: null,
              lockedAt: null,
            );
            await _driveService.uploadFile(
              name: 'manifest.json',
              content: unlockedManifest.toJson(),
              parentId: cashbookFolderId,
              etag: emergencyManifestResult.etag,
              fileId: emergencyManifestResult.fileId,
            );
            if (kDebugMode) {
              print('SyncEngine: Emergency lock release successful.');
            }
          }
        } catch (releaseError) {
          if (kDebugMode) {
            print('SyncEngine: Emergency lock release failed: $releaseError');
          }
        }
        rethrow;
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('SyncEngine: Sync failed with error: $e');
        print('SyncEngine: Stack trace: $stack');
      }
      final deviceId = await _getDeviceId();
      await _updateSyncStatus(deviceId, 'Error: $e', isEnding: true);
      rethrow;
    }
  }

  Future<void> _updateSyncStatus(String deviceId, String status,
      {bool isStarting = false, bool isEnding = false}) async {
    try {
      if (kDebugMode) {
        print(
            'SyncEngine: Updating status to: $status (isStarting: $isStarting, isEnding: $isEnding) for device $deviceId');
      }

      // Enable WAL mode for this connection
      try {
        await _db.customStatement('PRAGMA journal_mode=WAL;');
        await _db.customStatement('PRAGMA synchronous=NORMAL;');
        await _db.customStatement('PRAGMA busy_timeout=5000;');
      } catch (e) {
        // Ignore lock errors during status updates
      }

      // CRITICAL: We update the status in SharedPreferences FIRST to ensure the UI
      // sees the change immediately even if the DB write is slightly delayed.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sync_status_${_cashbook.id}', status);
      // Force a reload to ensure other isolates see the change
      await prefs.reload();

      await _runWithRetryOnBusy(() async {
        await (_db.update(_db.syncMetadata)
              ..where((t) => t.deviceId.equals(deviceId)))
            .write(SyncMetadataCompanion(
          syncStatus: Value(status),
          syncStartedAt: isStarting
              ? Value(DateTime.now().toUtc())
              : (isEnding ? const Value(null) : const Value.absent()),
          // When updating status, we MUST NOT touch version or cloudVersion
          version: const Value.absent(),
          cloudVersion: const Value.absent(),
        ));
      });
    } catch (e) {
      if (kDebugMode) {
        print('SyncEngine: Failed to update sync status in DB: $e');
      }
    }
  }

  Future<({SyncManifest manifest, String etag, String? fileId})> _getManifest(
      String folderId) async {
    final fileId =
        await _driveService.getFileIdByName('manifest.json', folderId);
    if (fileId == null) {
      return (manifest: SyncManifest(version: 0), etag: '', fileId: null);
    }
    final result = await _driveService.downloadFileWithETag(fileId);
    return (
      manifest: SyncManifest.fromJson(result.content),
      etag: result.etag,
      fileId: fileId
    );
  }

  Future<SyncMetadataData> _getLocalMetadata(String deviceId) async {
    // Enable WAL mode for this connection
    try {
      await _db.customStatement('PRAGMA journal_mode=WAL;');
      await _db.customStatement('PRAGMA synchronous=NORMAL;');
      await _db.customStatement('PRAGMA busy_timeout=5000;');
    } catch (e) {
      // Ignore
    }

    final metadata = await (_db.select(_db.syncMetadata)
          ..where((t) => t.deviceId.equals(deviceId)))
        .getSingleOrNull();
    if (metadata == null) {
      final newMetadata = SyncMetadataData(
          deviceId: deviceId, version: 0, cloudVersion: 0, syncStatus: 'Idle');
      await _db.into(_db.syncMetadata).insert(newMetadata);
      return newMetadata;
    }
    return metadata;
  }

  Future<void> _updateLocalMetadata(
      String deviceId, int version, int cloudVersion,
      {bool markAsSuccess = false}) async {
    if (kDebugMode) {
      print(
          'SyncEngine: Writing version $version (Cloud: $cloudVersion) to local sync_metadata for device $deviceId (markAsSuccess: $markAsSuccess)');
    }

    // Enable WAL mode for this connection
    try {
      await _db.customStatement('PRAGMA journal_mode=WAL;');
      await _db.customStatement('PRAGMA synchronous=NORMAL;');
      await _db.customStatement('PRAGMA busy_timeout=5000;');
    } catch (e) {
      // Ignore
    }

    await (_db.update(_db.syncMetadata)
          ..where((t) => t.deviceId.equals(deviceId)))
        .write(SyncMetadataCompanion(
      version: Value(version),
      cloudVersion: Value(cloudVersion),
      lastSyncAt: Value(DateTime.now().toUtc()),
      syncStatus: markAsSuccess ? const Value('Success') : const Value.absent(),
      syncStartedAt: markAsSuccess ? const Value(null) : const Value.absent(),
    ));

    // Mark that this device has ever had sync data (for account-mismatch check at sign-in)
    if (version > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_local_sync_data', true);
    }

    // Verify the write
    final verify = await _getLocalMetadata(deviceId);
    if (kDebugMode) {
      print(
          'SyncEngine: Verified local version is now ${verify.version}, cloud version is ${verify.cloudVersion}');
    }

    if (markAsSuccess) {
      // CRITICAL: Also update the global sync_status to Success if we just finished
      // a catch-up or a push to ensure the UI refreshes
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sync_status_${_cashbook.id}', 'Success');
      } catch (e) {
        if (kDebugMode) {
          print('SyncEngine: Failed to update status in SharedPreferences: $e');
        }
      }
    }
  }

  Future<void> _saveProgress(String deviceId, int version) async {
    if (kDebugMode) {
      print(
          'SyncEngine: Saving progress - local version $version for device $deviceId');
    }

    // Enable WAL mode for this connection
    try {
      await _db.customStatement('PRAGMA journal_mode=WAL;');
      await _db.customStatement('PRAGMA synchronous=NORMAL;');
      await _db.customStatement('PRAGMA busy_timeout=5000;');
    } catch (e) {
      // Ignore
    }

    // CRITICAL: We only update the version number here.
    // We MUST NOT touch sync_status or sync_started_at during incremental progress.
    await _runWithRetryOnBusy(() async {
      await (_db.update(_db.syncMetadata)
            ..where((t) => t.deviceId.equals(deviceId)))
          .write(SyncMetadataCompanion(
        version: Value(version),
        syncStatus: const Value.absent(),
        syncStartedAt: const Value.absent(),
        cloudVersion: const Value.absent(),
      ));
    });

    // Verify the write immediately
    final verify = await _getLocalMetadata(deviceId);
    if (kDebugMode) {
      print(
          'SyncEngine: Verified progress - local version is now ${verify.version} in DB');
    }
  }

  Future<void> _updateCloudVersion(String deviceId, int cloudVersion) async {
    if (kDebugMode) {
      print(
          'SyncEngine: Updating cloud version to $cloudVersion in local sync_metadata for device $deviceId');
    }

    // Enable WAL mode for this connection
    try {
      await _db.customStatement('PRAGMA journal_mode=WAL;');
      await _db.customStatement('PRAGMA synchronous=NORMAL;');
      await _db.customStatement('PRAGMA busy_timeout=5000;');
    } catch (e) {
      // Ignore
    }

    // CRITICAL: We only update the cloud version here.
    // We MUST NOT touch sync_status or sync_started_at.
    await (_db.update(_db.syncMetadata)
          ..where((t) => t.deviceId.equals(deviceId)))
        .write(SyncMetadataCompanion(
      cloudVersion: Value(cloudVersion),
      syncStatus: const Value.absent(),
      syncStartedAt: const Value.absent(),
      version: const Value.absent(),
    ));

    // Verify the write
    final verify = await _getLocalMetadata(deviceId);
    if (kDebugMode) {
      print(
          'SyncEngine: Verified cloud version is now ${verify.cloudVersion} in DB');
    }
  }

  Future<void> _catchUp(int remoteVersion, int localVersion, String folderId,
      String deviceId) async {
    for (int v = localVersion + 1; v <= remoteVersion; v++) {
      final fileName = 'v$v.json';
      if (kDebugMode) {
        print('SyncEngine: Pulling version $fileName for device $deviceId...');
      }
      final fileId = await _driveService.getFileIdByName(fileName, folderId);
      if (fileId == null) {
        if (kDebugMode) {
          print(
              'SyncEngine: Warning - Version file $fileName not found in cloud.');
        }
        continue;
      }

      final result = await _driveService.downloadFileWithETag(fileId);
      final versionFile = SyncVersionFile.fromJson(result.content);

      // Apply the changes for this specific version
      if (kDebugMode) {
        print(
            'SyncEngine: Applying changes from $fileName (Changes keys: ${versionFile.changes.keys.join(', ')})');
      }
      await _applyChanges(versionFile.changes);

      // CRITICAL: Update local version number after EACH successful delta application
      // This ensures that if the process crashes at v8 (out of 10),
      // the next run starts from v9.
      if (kDebugMode) {
        print(
            'SyncEngine: Successfully applied $fileName. Updating local version to $v');
      }
      await _saveProgress(deviceId, v);
    }
  }

  Future<void> _applyChanges(
      Map<String, List<Map<String, dynamic>>> changes) async {
    // Enable WAL mode for this connection if not already enabled
    try {
      await _db.customStatement('PRAGMA journal_mode=WAL;');
      await _db.customStatement('PRAGMA synchronous=NORMAL;');
      await _db.customStatement('PRAGMA busy_timeout=5000;');
    } catch (e) {
      // Ignore
    }

    // CRITICAL: Use a transaction for the entire batch of changes
    await _db.transaction(() async {
      // Contacts and Categories should be first, then Accounts, then Transactions,
      // then transfers and linked tables, then preferences
      final tableOrder = [
        'categories',
        'contacts',
        'app_currencies',
        'accounts',
        'transactions',
        'account_transfers',
        'receivables',
        'payables',
        'reminders',
        'transaction_schedules',
        'user_preferences',
      ];

      // CRITICAL: Filter out metadata keys like '_summary' BEFORE processing
      final sortedEntries =
          changes.entries.where((e) => !e.key.startsWith('_')).toList()
            ..sort((a, b) {
              final indexA = tableOrder.indexOf(a.key);
              final indexB = tableOrder.indexOf(b.key);
              return indexA.compareTo(indexB);
            });

      if (kDebugMode) {
        print(
            'SyncEngine: Applying changes for ${sortedEntries.length} tables');
      }

      for (final entry in sortedEntries) {
        final tableName = entry.key;
        final rows = entry.value;
        if (kDebugMode) {
          print('SyncEngine: Applying ${rows.length} rows to $tableName');
        }

        for (final row in rows) {
          // Special handling for categories and currencies to avoid duplicates
          if (tableName == 'categories' || tableName == 'app_currencies') {
            final isDefault =
                row['is_default'] == 1 || row['isDefault'] == true;
            if (isDefault) {
              // For default categories/currencies, we still want to update their fields
              // (like budget fields) if they already exist, but skip INSERT to avoid duplicates.
              final uuid = row['uuid'];
              final existing = await _db.customSelect(
                'SELECT COUNT(*) as count FROM $tableName WHERE uuid = ?',
                variables: [Variable.withString(uuid)],
              ).getSingle();

              if ((existing.data['count'] as num).toInt() > 0) {
                if (kDebugMode) {
                  print(
                      'SyncEngine: Updating existing default $tableName entry with UUID $uuid');
                }
                // Fall through to _upsertRow which handles ON CONFLICT DO UPDATE
              } else {
                // If it doesn't exist, we let _upsertRow handle the INSERT
              }
            }
          }
          await _upsertRow(tableName, row);
        }
      }
    });

    // CRITICAL: Notify Drift that tables have been updated.
    // This ensures that all Stream-based watchers (like Recent Transactions) refresh.
    final updatedTableNames =
        changes.keys.where((k) => !k.startsWith('_')).toSet();
    if (updatedTableNames.isNotEmpty) {
      if (kDebugMode) {
        print(
            'SyncEngine: Marking tables as updated: ${updatedTableNames.join(', ')}');
      }
      // We map string table names to Drift's TableInfo objects
      final tableInfos = updatedTableNames
          .map((name) {
            switch (name) {
              case 'categories':
                return _db.categories;
              case 'contacts':
                return _db.contacts;
              case 'accounts':
                return _db.accounts;
              case 'transactions':
                return _db.transactions;
              case 'account_transfers':
                return _db.accountTransfers;
              case 'receivables':
                return _db.receivables;
              case 'payables':
                return _db.payables;
              case 'reminders':
                return _db.reminders;
              case 'app_currencies':
                return _db.appCurrencies;
              case 'transaction_schedules':
                return _db.transactionSchedules;
              case 'user_preferences':
                return _db.userPreferences;
              default:
                return null;
            }
          })
          .whereType<TableInfo>()
          .toSet();

      if (tableInfos.isNotEmpty) {
        _db.markTablesUpdated(tableInfos);

        // CRITICAL: Force a WAL checkpoint to ensure data is visible to other connections
        // and broadcast a change event that Riverpod can pick up.
        try {
          await _db.customStatement('PRAGMA wal_checkpoint(FULL);');
        } catch (e) {
          // Ignore errors if WAL mode is not enabled
        }
      }
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> _getLocalChanges() async {
    // Enable WAL mode for this connection
    try {
      await _db.customStatement('PRAGMA journal_mode=WAL;');
      await _db.customStatement('PRAGMA synchronous=NORMAL;');
      await _db.customStatement('PRAGMA busy_timeout=5000;');
    } catch (e) {
      // Ignore
    }

    final changes = <String, List<Map<String, dynamic>>>{};

    final tables = [
      'categories',
      'contacts',
      'app_currencies',
      'accounts',
      'transactions',
      'account_transfers',
      'receivables',
      'payables',
      'reminders',
      'transaction_schedules',
      'user_preferences',
    ];

    if (kDebugMode) {
      print(
          'SyncEngine: Scanning ${tables.length} tables for unsynced changes...');
    }
    for (final tableName in tables) {
      try {
        // Check if table exists first to avoid SQL errors
        final tableCheck = await _db
            .customSelect(
                "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table' AND name='$tableName'")
            .getSingle();

        if ((tableCheck.data['count'] as num).toInt() == 0) {
          if (kDebugMode) {
            print(
                'SyncEngine: Table $tableName does not exist yet, skipping...');
          }
          continue;
        }

        final rows = await _db
            .customSelect(
              'SELECT * FROM $tableName WHERE is_not_synced = 1',
            )
            .get();

        if (rows.isNotEmpty) {
          if (kDebugMode) {
            print(
                'SyncEngine: Table $tableName has ${rows.length} unsynced rows');
          }
          // Create a deep copy and ensure types are JSON-compatible
          changes[tableName] = rows.map((r) {
            final data = Map<String, dynamic>.from(r.data);
            // Ensure any non-standard types are converted
            return data;
          }).toList();
        }
      } catch (e) {
        if (kDebugMode) {
          print('SyncEngine: Error checking table $tableName for sync: $e');
        }
      }
    }

    if (changes.isEmpty) {
      if (kDebugMode) {
        print('SyncEngine: No unsynced rows found in any table.');
      }
    }
    return changes;
  }

  Future<void> _markLocalChangesSynced(
      Map<String, List<Map<String, dynamic>>> changes) async {
    final updatedTables = <String>{};

    await _db.transaction(() async {
      // Enable WAL mode for this connection
      try {
        await _db.customStatement('PRAGMA journal_mode=WAL;');
        await _db.customStatement('PRAGMA synchronous=NORMAL;');
        await _db.customStatement('PRAGMA busy_timeout=5000;');
      } catch (e) {
        // Ignore
      }

      for (final entry in changes.entries) {
        final tableName = entry.key;
        if (tableName.startsWith('_')) continue; // Skip metadata like _summary

        final rows = entry.value;
        if (rows.isNotEmpty) {
          updatedTables.add(tableName);
        }
        for (final row in rows) {
          final idColumn = tableName == 'user_preferences' ? 'key' : 'uuid';
          final idValue =
              tableName == 'user_preferences' ? row['key'] : row['uuid'];
          await _db.customStatement(
            'UPDATE $tableName SET is_not_synced = 0 WHERE $idColumn = ?',
            [idValue],
          );
        }
      }
    });

    // Notify drift of the changes so stream listeners update
    if (updatedTables.isNotEmpty) {
      final tableInfos = updatedTables
          .map((name) {
            switch (name) {
              case 'categories':
                return _db.categories;
              case 'contacts':
                return _db.contacts;
              case 'accounts':
                return _db.accounts;
              case 'transactions':
                return _db.transactions;
              case 'account_transfers':
                return _db.accountTransfers;
              case 'receivables':
                return _db.receivables;
              case 'payables':
                return _db.payables;
              case 'reminders':
                return _db.reminders;
              case 'app_currencies':
                return _db.appCurrencies;
              case 'transaction_schedules':
                return _db.transactionSchedules;
              case 'user_preferences':
                return _db.userPreferences;
              default:
                return null;
            }
          })
          .whereType<TableInfo>()
          .toSet();

      if (tableInfos.isNotEmpty) {
        _db.markTablesUpdated(tableInfos);
      }
    }
  }

  Future<void> _upsertRow(String tableName, Map<String, dynamic> data) async {
    // Enable WAL mode for this connection
    try {
      await _db.customStatement('PRAGMA journal_mode=WAL;');
      await _db.customStatement('PRAGMA synchronous=NORMAL;');
      await _db.customStatement('PRAGMA busy_timeout=5000;');
    } catch (e) {
      // Ignore
    }

    // Reset isNotSynced flag for incoming changes
    final rowData = Map<String, dynamic>.from(data);
    rowData['is_not_synced'] = 0;

    // Remove any keys that start with an underscore (like _summary)
    rowData.removeWhere((key, value) => key.startsWith('_'));

    // Convert boolean values to integers for SQLite if necessary
    rowData.forEach((key, value) {
      if (value is bool) {
        rowData[key] = value ? 1 : 0;
      }
    });

    // CRITICAL: Handle date fields. SQLite expects ISO8601 strings or integers.
    final dateFields = [
      'date',
      'due_date',
      'received_date',
      'paid_date',
      'processed_date',
      'opening_date',
      'created_at',
      'updated_at',
      'last_sync_at',
      'reminder_date',
      'last_used',
      'last_generated_date',
      'start_date',
      'end_date'
    ];
    for (final field in dateFields) {
      // Map JSON snake_case to potential camelCase if needed, though Drift uses snake_case for customSelect
      if (rowData.containsKey(field) && rowData[field] != null) {
        if (rowData[field] is DateTime) {
          rowData[field] = (rowData[field] as DateTime).toIso8601String();
        }
      }
    }

    // Map camelCase keys from JSON back to snake_case for SQL
    final Map<String, dynamic> sqlData = {};
    rowData.forEach((key, value) {
      // Convert camelCase to snake_case (e.g., monthlyBudget -> monthly_budget)
      final snakeKey = key
          .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'),
              (match) => '${match.group(1)}_${match.group(2)!.toLowerCase()}')
          .toLowerCase();
      sqlData[snakeKey] = value;
    });

    // user_preferences uses key as sync identity; id is auto-increment and differs per device.
    // Excluding id avoids UNIQUE constraint on id when applying remote rows.
    if (tableName == 'user_preferences') {
      sqlData.remove('id');
    }

    final columns = sqlData.keys.join(', ');
    final placeholders = List.filled(sqlData.length, '?').join(', ');
    final updates = sqlData.keys.map((k) => '$k = EXCLUDED.$k').join(', ');
    final conflictColumn = tableName == 'user_preferences' ? 'key' : 'uuid';

    await _runWithRetryOnBusy(() async {
      try {
        await _db.customStatement(
          'INSERT INTO $tableName ($columns) VALUES ($placeholders) '
          'ON CONFLICT($conflictColumn) DO UPDATE SET $updates',
          sqlData.values.toList(),
        );
      } catch (e) {
        if (kDebugMode) {
          print('SyncEngine: Error upserting row into $tableName: $e');
          print('SyncEngine: Row data: $sqlData');
        }
        rethrow;
      }
    });
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
