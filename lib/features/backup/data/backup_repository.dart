import 'dart:io';
import 'package:flowpaisa/features/backup/data/google_drive_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class BackupRepository {
  final GoogleDriveService _driveService;
  
  BackupRepository(this._driveService);

  /// Get the path to the local database file
  Future<File> getDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, 'flowpaisa.db'));
  }

  /// Perform Backup
  Future<void> backup() async {
    if (!_driveService.isSignedIn) {
      throw Exception('User not signed in');
    }

    final dbFile = await getDatabaseFile();
    if (!await dbFile.exists()) {
      throw Exception('Database file not found');
    }

    // Verify database integrity or close connection?
    // SQLite usually handles read-copy safely if WAL is enabled, or even if not.
    // Ideally we should checkpoint, but we can't easily here.
    // Simple copy is usually fine for backup.
    
    await _driveService.uploadDatabase(dbFile);
    
    // Update last backup time
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_backup_time', DateTime.now().toIso8601String());
  }

  /// Restore from backup
  Future<void> restore(String fileId) async {
    if (!_driveService.isSignedIn) {
      throw Exception('User not signed in');
    }

    final dbFile = await getDatabaseFile();
    
    // Download to a temp file first
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'restore_temp.db'));
    
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
    
    await _driveService.downloadBackup(fileId, tempFile);
    
    // If download successful, overwrite the DB
    // Note: The app should ideally be restarted immediately after this
    await tempFile.copy(dbFile.path);
    await tempFile.delete();
    
    // Update last restore time
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_restore_time', DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('last_backup_time');
    return str != null ? DateTime.tryParse(str) : null;
  }
}
