import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/core/utils/native_share.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class LocalBackupService {
  /// Prepares a database backup file in the temporary directory
  static Future<String> prepareBackupFile(Cashbook cashbook) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, cashbook.dbPath));

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

        final result = await Share.shareXFiles([xFile]);
        if (result.status == ShareResultStatus.unavailable) {
          throw Exception('Sharing is not available on this device');
        }
      }
    } catch (e) {
      throw Exception('Error sharing backup file: $e');
    }
  }

  /// Picks a .db file from the local filesystem
  static Future<File?> pickBackupFile() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'SQLite Database',
      extensions: <String>['db'],
    );

    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );

    if (file == null) return null;
    return File(file.path);
  }
}
