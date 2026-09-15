import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
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

    final docs = await _documentsRepository.getAllDocuments();
    final docDir = await _documentsRepository.getDocumentsDirectory();

    // 1. Create a manifest list of all metadata
    final manifest = docs.map((doc) => {
      'uuid': doc.uuid,
      'transactionUuid': doc.transactionUuid,
      'fileName': doc.fileName,
      'originalName': doc.originalName,
      'fileSize': doc.fileSize,
      'mimeType': doc.mimeType,
      'createdAt': doc.createdAt.toIso8601String(),
      'updatedAt': doc.updatedAt.toIso8601String(),
    }).toList();

    // 2. Write manifest.json to a temporary file
    final manifestFile = File(p.join(tempDir.path, 'manifest.json'));
    await manifestFile.writeAsString(jsonEncode(manifest));

    // 3. Compress all files and manifest.json into ZIP
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    
    // Add manifest
    encoder.addFile(manifestFile);

    // Add all active physical document files
    for (final doc in docs) {
      final file = File(p.join(docDir.path, doc.fileName));
      if (await file.exists()) {
        encoder.addFile(file);
      }
    }

    encoder.close();

    // Clean up temporary manifest file
    if (await manifestFile.exists()) {
      await manifestFile.delete();
    }

    return File(zipPath);
  }

  /// Import documents and metadata from a ZIP file
  Future<void> importFromZip(File zipFile) async {
    final tempDir = await getTemporaryDirectory();
    final extractDir = Directory(p.join(tempDir.path, 'extracted_docs_${DateTime.now().millisecondsSinceEpoch}'));
    if (!await extractDir.exists()) {
      await extractDir.create(recursive: true);
    }

    try {
      // 1. Extract ZIP contents
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File(p.join(extractDir.path, filename));
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(data);
        }
      }

      // 2. Read manifest.json
      final manifestFile = File(p.join(extractDir.path, 'manifest.json'));
      if (!await manifestFile.exists()) {
        throw Exception('Invalid backup file: manifest.json is missing.');
      }

      final manifestContent = await manifestFile.readAsString();
      final List<dynamic> decodedManifest = jsonDecode(manifestContent);

      final docDir = await _documentsRepository.getDocumentsDirectory();

      // 3. Restore each document
      await _database.transaction(() async {
        for (final item in decodedManifest) {
          final uuid = item['uuid'] as String;
          final transactionUuid = item['transactionUuid'] as String;
          final fileName = item['fileName'] as String;
          final originalName = item['originalName'] as String;
          final fileSize = item['fileSize'] as int;
          final mimeType = item['mimeType'] as String?;
          final createdAt = DateTime.parse(item['createdAt'] as String);
          final updatedAt = DateTime.parse(item['updatedAt'] as String);

          // Copy physical file to local documents directory
          final sourceFile = File(p.join(extractDir.path, fileName));
          if (await sourceFile.exists()) {
            final targetFile = File(p.join(docDir.path, fileName));
            await sourceFile.copy(targetFile.path);

            // Upsert metadata into database
            final companion = TransactionDocumentsCompanion(
              uuid: Value(uuid),
              transactionUuid: Value(transactionUuid),
              fileName: Value(fileName),
              originalName: Value(originalName),
              fileSize: Value(fileSize),
              mimeType: Value(mimeType),
              createdAt: Value(createdAt),
              updatedAt: Value(updatedAt),
              isDeleted: const Value(false),
              isNotSynced: const Value(true),
            );

            await _database.into(_database.transactionDocuments).insertOnConflictUpdate(companion);
          }
        }
      });
    } finally {
      // Clean up extracted files
      if (await extractDir.exists()) {
        await extractDir.delete(recursive: true);
      }
    }
  }

  /// Upload the documents ZIP backup to Google Drive
  Future<String?> uploadBackupToDrive(String cashbookId, {
    String? cashbookName,
    String? color,
    String? icon,
    void Function(double progress)? onProgress,
  }) async {
    if (!_driveService.isSignedIn) {
      throw Exception('User not signed in');
    }

    // 1. Generate ZIP file
    final zipFile = await exportToZip();

    try {
      // 2. Get or Create backup folder on Google Drive
      final folderId = await _driveService.getOrCreateBackupFolder(
        cashbookId,
        cashbookName: cashbookName,
        color: color,
        icon: icon,
      );

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final driveFileName = 'flowpaisa_documents_backup_$timestamp.zip';

      // 3. Upload the ZIP file
      final fileId = await _driveService.uploadBinaryFile(
        zipFile,
        name: driveFileName,
        parentId: folderId,
        onProgress: onProgress,
      );

      return fileId;
    } finally {
      // Clean up local temporary ZIP file
      if (await zipFile.exists()) {
        await zipFile.delete();
      }
    }
  }

  /// Find the latest documents backup on Google Drive for a particular cashbook
  Future<drive.File?> getLatestCloudBackup(String cashbookId) async {
    if (!_driveService.isSignedIn || _driveService.driveApi == null) return null;

    try {
      final folderId = await _driveService.getOrCreateBackupFolder(cashbookId);
      final query = "'$folderId' in parents and name contains 'flowpaisa_documents_backup_' and trashed = false";

      final fileList = await _driveService.driveApi!.files.list(
        q: query,
        orderBy: 'createdTime desc',
        spaces: 'appDataFolder',
        $fields: 'files(id, name, createdTime, size)',
      );

      if (fileList.files?.isNotEmpty == true) {
        return fileList.files!.first;
      }
    } catch (_) {
      // Return null if failed or folder not found
    }
    return null;
  }

  /// Download the backup from Google Drive and restore it
  Future<void> downloadAndImportFromDrive(
    String fileId, {
    int? fileSize,
    void Function(double progress)? onProgress,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'temp_cloud_import_${DateTime.now().millisecondsSinceEpoch}.zip'));

    try {
      // 1. Download binary ZIP from Drive
      await _driveService.downloadBackup(fileId, tempFile, fileSize: fileSize, onProgress: onProgress);

      // 2. Import using the existing local ZIP import logic
      await importFromZip(tempFile);
    } finally {
      // 3. Clean up local temp ZIP file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
}
