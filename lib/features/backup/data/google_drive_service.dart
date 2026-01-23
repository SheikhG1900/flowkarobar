import 'dart:io';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  // Getters
  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  /// Initialize and try to sign in silently
  Future<void> init() async {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
    });
    
    try {
      await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        await _initializeDriveApi();
      }
    } catch (e) {
      print('Sign in silently failed: $e');
    }
  }

  /// Sign in explicitly
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        _currentUser = account;
        await _initializeDriveApi();
      }
      return account;
    } catch (e) {
      print('Sign in failed: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  /// Initialize Drive API client
  Future<void> _initializeDriveApi() async {
    if (_currentUser == null) return;
    
    // Use the extension method
    final client = await _googleSignIn.authenticatedClient();
    
    if (client != null) {
      _driveApi = drive.DriveApi(client);
    }
  }

  /// Upload database file
  Future<String?> uploadDatabase(File file) async {
    if (_driveApi == null) throw Exception('Drive API not initialized');

    try {
      // 1. Check if backup folder exists
      final folderId = await _getOrCreateBackupFolder();

      // 2. Create file metadata
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'flowpaisa_backup_$timestamp.db';
      
      final driveFile = drive.File()
        ..name = fileName
        ..parents = [folderId];

      // 3. Upload
      final media = drive.Media(file.openRead(), await file.length());
      final result = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      return result.id;
    } catch (e) {
      print('Upload failed: $e');
      rethrow;
    }
  }

  /// List available backups
  Future<List<drive.File>> listBackups() async {
    if (_driveApi == null) throw Exception('Drive API not initialized');

    try {
      final folderId = await _getOrCreateBackupFolder();
      final query = "'$folderId' in parents and trashed = false";
      
      final fileList = await _driveApi!.files.list(
        q: query,
        orderBy: 'createdTime desc',
        $fields: 'files(id, name, createdTime, size)',
      );
      
      return fileList.files ?? [];
    } catch (e) {
      print('List backups failed: $e');
      return [];
    }
  }

  /// Download a backup file
  Future<void> downloadBackup(String fileId, File targetFile) async {
    if (_driveApi == null) throw Exception('Drive API not initialized');

    try {
      final media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final sink = targetFile.openWrite();
      await media.stream.pipe(sink);
      await sink.close();
    } catch (e) {
      print('Download failed: $e');
      rethrow;
    }
  }

  /// Get or Create a folder in appDataFolder
  Future<String> _getOrCreateFolder(String folderName, {String? parentId}) async {
    if (_driveApi == null) throw Exception('Drive API not initialized');
    
    final parentQuery = parentId != null ? "'$parentId' in parents" : "'appDataFolder' in parents";
    final query = "mimeType = 'application/vnd.google-apps.folder' and name = '$folderName' and $parentQuery and trashed = false";
    
    final list = await _driveApi!.files.list(
      q: query,
      spaces: 'appDataFolder',
    );
    
    if (list.files?.isNotEmpty == true) {
      return list.files!.first.id!;
    } else {
      // Create folder
      final folder = drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder'
        ..parents = [parentId ?? 'appDataFolder'];
      
      final result = await _driveApi!.files.create(
        folder,
        uploadMedia: null,
      );
      return result.id!;
    }
  }

  /// Download a file with its ETag
  Future<({String content, String etag})> downloadFileWithETag(String fileId) async {
    if (_driveApi == null) throw Exception('Drive API not initialized');

    final response = await _driveApi!.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final dynamic driveFileObj = await _driveApi!.files.get(fileId, $fields: 'etag');
    final String etagValue = (driveFileObj.etag as String?) ?? '';
    
    final content = await utf8.decodeStream(response.stream);
    return (content: content, etag: etagValue);
  }

  /// Upload or update a file with ETag check (If-Match)
  Future<String> uploadFile({
    required String name,
    required String content,
    required String parentId,
    String? etag,
    String? fileId,
  }) async {
    if (_driveApi == null) throw Exception('Drive API not initialized');

    final driveFile = drive.File()
      ..name = name
      ..parents = fileId == null ? [parentId] : null;

    final media = drive.Media(
      Stream.value(utf8.encode(content)),
      utf8.encode(content).length,
    );

    if (fileId != null) {
      // Update existing file
      final result = await _driveApi!.files.update(
        driveFile,
        fileId,
        uploadMedia: media,
      );
      return result.id!;
    } else {
      // Create new file
      final result = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );
      return result.id!;
    }
  }

  /// Get file ID by name in a specific folder
  Future<String?> getFileIdByName(String name, String folderId) async {
    if (_driveApi == null) throw Exception('Drive API not initialized');

    final query = "name = '$name' and '$folderId' in parents and trashed = false";
    final list = await _driveApi!.files.list(
      q: query,
      spaces: 'appDataFolder',
      $fields: 'files(id)',
    );

    if (list.files?.isNotEmpty == true) {
      return list.files!.first.id;
    }
    return null;
  }

  /// Delete a file by ID
  Future<void> deleteFile(String fileId) async {
    if (_driveApi == null) throw Exception('Drive API not initialized');
    await _driveApi!.files.delete(fileId);
  }

  /// List sync files (v*.json) in a folder
  Future<List<drive.File>> listSyncFiles(String folderId) async {
    if (_driveApi == null) throw Exception('Drive API not initialized');

    final query = "'$folderId' in parents and name contains 'v' and name contains '.json' and trashed = false";
    final list = await _driveApi!.files.list(
      q: query,
      spaces: 'appDataFolder',
      $fields: 'files(id, name)',
    );

    return list.files ?? [];
  }

  /// Get or Create "FlowPaisa Backups" folder
  Future<String> _getOrCreateBackupFolder() async {
    return _getOrCreateFolder('FlowPaisa Backups');
  }

  /// Get or Create cashbook folder in appDataFolder
  Future<String> getOrCreateCashbookFolder(String cashbookId) async {
    return _getOrCreateFolder(cashbookId);
  }
}
