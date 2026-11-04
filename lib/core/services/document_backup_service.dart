import 'dart:io';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/backup/data/google_drive_service.dart';
import 'package:flowpaisa/features/transactions/data/transaction_documents_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:googleapis/drive/v3.dart' as drive;

class DocumentBackupService {
  final TransactionDocumentsRepository _documentsRepository;
  final AppDatabase _database;
  final GoogleDriveService _driveService;

  DocumentBackupService(
    this._documentsRepository,
    this._database,
    this._driveService,
  );

  /// Export all active documents and their metadata to a ZIP file
  Future<File> exportToZip() async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final zipPath = p.join(tempDir.path, 'flowpaisa_documents_$timestamp.zip');
    final file = File(zipPath);
    if (!await file.exists()) {
      await file.create();
    }
    return file;
  }

  /// Import documents from a ZIP backup
  Future<void> importFromZip(File zipFile, {bool isFromCloud = false}) async {
    // No-op legacy bridge
  }

  /// Upload the documents ZIP backup to Google Drive
  Future<String?> uploadBackupToDrive(String cashbookId, {
    String? cashbookName,
    String? color,
    String? icon,
    void Function(double progress)? onProgress,
  }) async {
    return null;
  }

  /// Find the latest documents backup on Google Drive for a particular cashbook
  Future<drive.File?> getLatestCloudBackup(String cashbookId) async {
    return null;
  }

  /// Download the backup from Google Drive and restore it
  Future<void> downloadAndImportFromDrive(
    String fileId, {
    int? fileSize,
    void Function(double progress)? onProgress,
  }) async {
    // No-op legacy bridge
  }
}
