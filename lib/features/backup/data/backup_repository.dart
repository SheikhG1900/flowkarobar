import 'dart:io';
import 'package:flowpaisa/features/backup/data/google_drive_service.dart';
import 'package:flowpaisa/features/backup/domain/models/sync_manifest.dart';
import 'package:flowpaisa/core/database/connection/native.dart' as native;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class BackupRepository {
  final GoogleDriveService _driveService;
  
  BackupRepository(this._driveService);

  /// Get the path to the local database file
  Future<File> getDatabaseFile({String? fileName}) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final rawName = fileName ?? 'flowpaisa';
    // `rawName` may contain an extension; Drift stores as '<name>.sqlite'.
    final logicalName =
        rawName.replaceAll(RegExp(r'\.(db|sqlite)$'), '');
    
    // Ensure data is flushed to the main file
    if (!kIsWeb) {
      await native.checkpointDatabase(logicalName);
    }

    final file = File(p.join(dbFolder.path, '$logicalName.sqlite'));
    // ignore: avoid_print
    print(
        '[BackupRepository] Resolved local DB file for backup/restore: ${file.path}');
    return file;
  }

  /// Perform Backup
  Future<void> backup({String? fileName, String? cashbookId, String? cashbookName, String? color, String? icon}) async {
    if (!_driveService.isSignedIn) {
      throw Exception('User not signed in');
    }

    final dbFile = await getDatabaseFile(fileName: fileName);
    if (!await dbFile.exists()) {
      throw Exception('Database file not found');
    }

    // Verify database integrity or close connection?
    // SQLite usually handles read-copy safely if WAL is enabled, or even if not.
    // Ideally we should checkpoint, but we can't easily here.
    // Simple copy is usually fine for backup.
    
    await _driveService.uploadDatabase(
      dbFile, 
      cashbookId: cashbookId, 
      cashbookName: cashbookName,
      color: color,
      icon: icon,
    );
    
    // Update last backup time specifically for this cashbook
    final prefs = await SharedPreferences.getInstance();
    final key = cashbookId != null ? 'last_backup_time_$cashbookId' : 'last_backup_time';
    await prefs.setString(key, DateTime.now().toIso8601String());
  }

  /// Clear granular cloud data
  Future<void> clearCloudData(String cashbookId,
      {required bool clearBackups, required bool clearSync}) async {
    if (!_driveService.isSignedIn) {
      throw Exception('User not signed in');
    }

    if (clearBackups && clearSync) {
      // If both are selected, we can just delete the entire cashbook folder structure
      // This is more efficient.
      await _driveService.deleteCashbookFromCloud(cashbookId);
    } else {
      if (clearBackups) {
        final folderId = await _driveService.getOrCreateBackupFolder(cashbookId);
        final backups = await _driveService.listBackups(cashbookId: cashbookId);
        for (final file in backups) {
          if (file.id != null) {
            await _driveService.deleteFile(file.id!);
          }
        }
      }

      if (clearSync) {
        final folderId =
            await _driveService.getOrCreateCashbookFolder(cashbookId);
        // 1. Delete manifest
        final manifestId =
            await _driveService.getFileIdByName('manifest.json', folderId);
        if (manifestId != null) {
          await _driveService.deleteFile(manifestId);
        }
        // 2. Delete all delta files
        final syncFiles = await _driveService.listSyncFiles(folderId);
        for (final file in syncFiles) {
          if (file.id != null) {
            await _driveService.deleteFile(file.id!);
          }
        }
      }
    }
  }

  /// Restore from backup
  Future<void> restore(String fileId, {String? fileName, String? cashbookId}) async {
    if (!_driveService.isSignedIn) {
      throw Exception('User not signed in');
    }

    final dbFile = await getDatabaseFile(fileName: fileName);
    
    // Download to a temp file first
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'restore_temp.db'));
    
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
    
    await _driveService.downloadBackup(fileId, tempFile);
    
    // If download successful, overwrite the DB.
    // To avoid mixing old WAL/SHM with the new main database, delete any
    // existing files for this database first.
    final walFile = File('${dbFile.path}-wal');
    final shmFile = File('${dbFile.path}-shm');
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    if (await walFile.exists()) {
      await walFile.delete();
    }
    if (await shmFile.exists()) {
      await shmFile.delete();
    }

    await tempFile.copy(dbFile.path);
    await tempFile.delete();
    
    // Update last restore time specifically for this cashbook
    final prefs = await SharedPreferences.getInstance();
    final key = cashbookId != null ? 'last_restore_time_$cashbookId' : 'last_restore_time';
    await prefs.setString(key, DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastBackupTime({String? cashbookId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = cashbookId != null ? 'last_backup_time_$cashbookId' : 'last_backup_time';
    final str = prefs.getString(key);
    return str != null ? DateTime.tryParse(str) : null;
  }

  /// Reset sync to a specific version (Make Prime)
  Future<void> resetSyncToVersion(String cashbookId, int version) async {
    if (!_driveService.isSignedIn) {
      throw Exception('User not signed in');
    }

    final folderId = await _driveService.getOrCreateCashbookFolder(cashbookId);
    
    // 1. Get current manifest
    final manifestFileId = await _driveService.getFileIdByName('manifest.json', folderId);
    if (manifestFileId == null) {
      throw Exception('Sync manifest not found for this cashbook');
    }

    final result = await _driveService.downloadFileWithETag(manifestFileId);
    SyncManifest manifest = SyncManifest.fromJson(result.content);

    // 2. Update manifest version
    manifest = manifest.copyWith(
      version: version,
      lockedBy: null,
      lockedAt: null,
    );

    await _driveService.uploadFile(
      name: 'manifest.json',
      content: manifest.toJson(),
      parentId: folderId,
      etag: result.etag,
      fileId: manifestFileId,
    );

    // 3. Delete cloud files for versions > target version
    final syncFiles = await _driveService.listSyncFiles(folderId);
    for (final file in syncFiles) {
      final fileName = file.name ?? '';
      final match = RegExp(r'v(\d+)\.json').firstMatch(fileName);
      if (match != null) {
        final fileVersion = int.tryParse(match.group(1) ?? '');
        if (fileVersion != null && fileVersion > version) {
          await _driveService.deleteFile(file.id!);
        }
      }
    }
  }
}
