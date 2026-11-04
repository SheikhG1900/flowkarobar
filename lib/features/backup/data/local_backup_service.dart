import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flowpaisa/features/businesses/domain/models/business.dart';
import 'package:flowpaisa/core/utils/native_share.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/database/connection/native.dart' as native;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class LocalBackupService {
  /// Prepares a database backup file in the temporary directory
  static Future<String> prepareBackupFile(Business cashbook) async {
    // `cashbook.dbPath` is a logical name; Drift stores as '<name>.sqlite'.
    final dbFolder = await getApplicationDocumentsDirectory();
    final logicalName =
        cashbook.dbPath.replaceAll(RegExp(r'\.(db|sqlite)$'), '');
    
    // Ensure all data is flushed to the main file before copying
    if (!kIsWeb) {
      await native.checkpointDatabase(logicalName);
    }

    final dbFile = File(p.join(dbFolder.path, '$logicalName.sqlite'));

    // Debug logging to help diagnose path issues
    // (Will appear in debug console when running the app)
    // ignore: avoid_print
    print(
        '[LocalBackupService] Preparing backup for "${cashbook.name}" at path: ${dbFile.path}');

    if (!await dbFile.exists()) {
      throw Exception('Database file not found for ${cashbook.name}');
    }

    // Use a descriptive name with timestamp
    final timestamp = AppDateFormatter.formatForFileName(DateTime.now());
    final safeName = cashbook.name.replaceAll(RegExp(r'[^\w\s-]'), '_');
    final fileName = '${safeName}_backup_$timestamp.db';

    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, fileName));
    await dbFile.copy(tempFile.path);

    return tempFile.path;
  }

  /// Saves a file to the Downloads folder (Mobile only)
  static Future<void> saveToDownloads(String sourceFilePath) async {
    try {
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file not found');
      }

      // Handle Android scoped storage
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getDownloadsDirectory();
        }
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null) {
        throw Exception('Downloads directory not available');
      }

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = sourceFilePath.split(Platform.pathSeparator).last;
      String newPath = '${downloadsDir.path}/$fileName';

      // Handle duplicates
      final fileExtension = fileName.contains('.')
          ? fileName.substring(fileName.lastIndexOf('.'))
          : '';
      final nameWithoutExtension = fileExtension.isNotEmpty
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;

      int counter = 1;
      while (await File(newPath).exists()) {
        newPath =
            '${downloadsDir.path}/${nameWithoutExtension}_$counter$fileExtension';
        counter++;
      }

      await sourceFile.copy(newPath);
    } catch (e) {
      throw Exception('Error saving to downloads: $e');
    }
  }

  /// Shares a backup file
  static Future<void> shareBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist at path: $filePath');
      }

      if (Platform.isAndroid) {
        final success = await NativeShare.shareFile(filePath);
        if (!success) {
          throw Exception('Native share failed');
        }
      } else {
        final xFile = XFile(
          filePath,
          mimeType: 'application/x-sqlite3',
          name: filePath.split(Platform.pathSeparator).last,
        );

        final result = await SharePlus.instance.share(ShareParams(
          files: [xFile],
        ));
        if (result.status == ShareResultStatus.dismissed || result.status == ShareResultStatus.unavailable) {
          // Handle or ignore
        }
      }
    } catch (e) {
      throw Exception('Error sharing backup file: $e');
    }
  }

  /// Picks a .db or .sqlite file from the local filesystem
  static Future<File?> pickBackupFile() async {
    try {
      if (kDebugMode) print('[LocalBackupService] Opening file picker...');
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null) {
        if (kDebugMode) print('[LocalBackupService] File picker cancelled by user');
        return null;
      }

      if (result.files.isEmpty) {
        if (kDebugMode) print('[LocalBackupService] File picker returned empty list');
        return null;
      }
      
      final path = result.files.single.path;
      if (kDebugMode) print('[LocalBackupService] File picked: $path');
      
      if (path == null) return null;
      
      final file = File(path);
      if (!await file.exists()) {
        if (kDebugMode) print('[LocalBackupService] Error: Picked file does not exist on disk');
        return null;
      }

      return file;
    } catch (e) {
      if (kDebugMode) print('[LocalBackupService] Exception during file picking: $e');
      return null;
    }
  }
}
