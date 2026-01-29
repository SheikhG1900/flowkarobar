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
    if (kDebugMode) {
      print('SyncEngine: Starting sync for cashbook: ${_cashbook.name} (ID: ${_cashbook.id})');
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
      
      if (manifest.version > localMetadata.version) {
        if (kDebugMode) {
          print('SyncEngine: Catching up from ${localMetadata.version} to ${manifest.version}');
        }
        await _catchUp(manifest.version, localMetadata.version, cashbookFolderId, deviceId);
        
        // Refresh localMetadata variable for subsequent logic
        final updatedMetadata = await _getLocalMetadata(deviceId);
        localMetadata = updatedMetadata;
      }

      // Step 2: Lock Assessment
      if (manifest.lockedBy != null && manifest.lockedBy != deviceId) {
        final lockTime = manifest.lockedAt;
        if (lockTime != null && DateTime.now().toUtc().difference(lockTime).inMinutes < 60) {
          if (kDebugMode) {
            print('SyncEngine: Database is locked by another device: ${manifest.lockedBy}');
          }
          
          // Even if locked, we already caught up in Step 1, so update local version
          if (localMetadata.version < manifest.version) {
            if (kDebugMode) {
              print('SyncEngine: Updating local version to ${manifest.version} despite lock (pull complete)');
            }
            await _updateLocalMetadata(deviceId, manifest.version);
          }

          // Show countdown and keep updating it until lock expires or process finishes
          final prefs = await SharedPreferences.getInstance();
          while (DateTime.now().toUtc().difference(lockTime).inMinutes < 60) {
            final remainingMinutes = 60 - DateTime.now().toUtc().difference(lockTime).inMinutes;
            await prefs.setString('sync_status_${_cashbook.id}', 
                'Locked by another device. Force push allowed in $remainingMinutes min.');
            
            // Wait a minute before updating countdown again, or exit if we should
            await Future.delayed(const Duration(seconds: 30));
            
            // Re-check manifest occasionally to see if lock was released early
            final currentManifest = (await _getManifest(cashbookFolderId)).manifest;
            if (currentManifest.lockedBy == null) break;
          }
          
          await prefs.setString('sync_status_${_cashbook.id}', 'Success');
          return; // Abort push
        }
        if (kDebugMode) {
          print('SyncEngine: Lock expired or belongs to this device, proceeding...');
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
            print('SyncEngine: Updating local version from ${localMetadata.version} to ${manifest.version} (caught up from cloud)');
          }
          await _updateLocalMetadata(deviceId, manifest.version);
        }
        
        // Report success so UI refreshes
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sync_status_${_cashbook.id}', 'Success');
        return;
      }

      if (kDebugMode) {
        print('SyncEngine: Found local changes in ${localChanges.length} tables. Tables: ${localChanges.keys.join(', ')}');
      }

      // Step 3: Acquire Lock
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
            print('SyncEngine: Conflict detected (412) while acquiring lock, restarting sync');
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
      
      // Add summary to changes for local display
      final changesWithSummary = Map<String, List<Map<String, dynamic>>>.from(localChanges);
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
          print('SyncEngine: Releasing lock and updating version to $nextVersion at the same time...');
          print('SyncEngine: Final manifest content to upload: ${finalManifest.toJson()}');
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
          print('SyncEngine: Manifest updated (Version: $nextVersion, Lock: Released).');
        }

        // Update status to Success in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sync_status_${_cashbook.id}', 'Success');
        
        // Force a small delay to ensure SharedPreferences is flushed
        await Future.delayed(const Duration(milliseconds: 500));

        // Local Cleanup
        await _markLocalChangesSynced(localChanges);
        await _updateLocalMetadata(deviceId, nextVersion);
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
    if (kDebugMode) {
      print('SyncEngine: Writing version $version to local sync_metadata for device $deviceId');
    }
    await (_db.update(_db.syncMetadata)..where((t) => t.deviceId.equals(deviceId)))
        .write(SyncMetadataCompanion(
      version: Value(version),
      lastSyncAt: Value(DateTime.now().toUtc()),
    ));
    
    // Verify the write
    final verify = await _getLocalMetadata(deviceId);
    if (kDebugMode) {
      print('SyncEngine: Verified local version is now ${verify.version}');
    }
    
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

  Future<void> _catchUp(int remoteVersion, int localVersion, String folderId, String deviceId) async {
    for (int v = localVersion + 1; v <= remoteVersion; v++) {
      final fileName = 'v$v.json';
      if (kDebugMode) {
        print('SyncEngine: Pulling version $fileName...');
      }
      final fileId = await _driveService.getFileIdByName(fileName, folderId);
      if (fileId == null) {
        if (kDebugMode) {
          print('SyncEngine: Warning - Version file $fileName not found in cloud.');
        }
        continue;
      }

      final result = await _driveService.downloadFileWithETag(fileId);
      final versionFile = SyncVersionFile.fromJson(result.content);
      
      // Apply the changes for this specific version
      if (kDebugMode) {
        print('SyncEngine: Applying changes from $fileName (Changes keys: ${versionFile.changes.keys.join(', ')})');
      }
      await _applyChanges(versionFile.changes);
      
      // CRITICAL: Update local version number after EACH successful delta application
      // This ensures that if the process crashes at v8 (out of 10), 
      // the next run starts from v9.
      if (kDebugMode) {
        print('SyncEngine: Successfully applied $fileName. Updating local version to $v');
      }
      await _updateLocalMetadata(deviceId, v);
    }
  }

  Future<void> _applyChanges(Map<String, List<Map<String, dynamic>>> changes) async {
    await _db.transaction(() async {
      // Sort tables to respect foreign key constraints
      // Contacts and Categories should be first, then Transactions, then linked tables
      final tableOrder = [
        'categories', 
        'contacts', 
        'app_currencies',
        'transactions', 
        'receivables', 
        'payables', 
        'reminders', 
        'transaction_schedules'
      ];

      // CRITICAL: Filter out metadata keys like '_summary' BEFORE processing
      final sortedEntries = changes.entries
          .where((e) => !e.key.startsWith('_'))
          .toList()
        ..sort((a, b) {
          final indexA = tableOrder.indexOf(a.key);
          final indexB = tableOrder.indexOf(b.key);
          return indexA.compareTo(indexB);
        });

      if (kDebugMode) {
        print('SyncEngine: Applying changes for ${sortedEntries.length} tables');
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
            final isDefault = row['is_default'] == 1 || row['isDefault'] == true;
            if (isDefault) {
              // Skip default categories/currencies from cloud if they already exist locally
              // This prevents duplicates since local defaults have fixed UUIDs now
              final uuid = row['uuid'];
              final existing = await _db.customSelect(
                'SELECT COUNT(*) as count FROM $tableName WHERE uuid = ?',
                variables: [Variable.withString(uuid)],
              ).getSingle();
              
              if ((existing.data['count'] as num).toInt() > 0) {
                if (kDebugMode) {
                  print('SyncEngine: Skipping default $tableName entry with UUID $uuid (already exists)');
                }
                continue;
              }
            }
          }
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

    if (kDebugMode) {
      print('SyncEngine: Scanning ${tables.length} tables for unsynced changes...');
    }
    for (final tableName in tables) {
      try {
        // Check if table exists first to avoid SQL errors
        final tableCheck = await _db.customSelect(
          "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table' AND name='$tableName'"
        ).getSingle();
        
        if ((tableCheck.data['count'] as num).toInt() == 0) {
          if (kDebugMode) {
            print('SyncEngine: Table $tableName does not exist yet, skipping...');
          }
          continue;
        }

        final rows = await _db.customSelect(
          'SELECT * FROM $tableName WHERE is_not_synced = 1',
        ).get();

        if (rows.isNotEmpty) {
          if (kDebugMode) {
            print('SyncEngine: Table $tableName has ${rows.length} unsynced rows');
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

  Future<void> _markLocalChangesSynced(Map<String, List<Map<String, dynamic>>> changes) async {
    await _db.transaction(() async {
      for (final entry in changes.entries) {
        final tableName = entry.key;
        if (tableName.startsWith('_')) continue; // Skip metadata like _summary
        
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

    // Remove any keys that start with an underscore (like _summary)
    rowData.removeWhere((key, value) => key.startsWith('_'));

    // Convert boolean values to integers for SQLite if necessary
    rowData.forEach((key, value) {
      if (value is bool) {
        rowData[key] = value ? 1 : 0;
      }
    });

    // CRITICAL: Handle date fields. SQLite expects ISO8601 strings or integers.
    final dateFields = ['date', 'due_date', 'received_date', 'paid_date', 'created_at', 'updated_at', 'last_sync_at', 'reminder_date', 'last_used', 'last_generated_date', 'start_date', 'end_date'];
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
      final snakeKey = key.replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}');
      sqlData[snakeKey] = value;
    });

    final columns = sqlData.keys.join(', ');
    final placeholders = List.filled(sqlData.length, '?').join(', ');
    final updates = sqlData.keys.map((k) => '$k = EXCLUDED.$k').join(', ');

    try {
      await _db.customStatement(
        'INSERT INTO $tableName ($columns) VALUES ($placeholders) '
        'ON CONFLICT(uuid) DO UPDATE SET $updates',
        sqlData.values.toList(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('SyncEngine: Error upserting row into $tableName: $e');
        print('SyncEngine: Row data: $sqlData');
      }
      rethrow;
    }
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
