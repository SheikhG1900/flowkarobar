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
  bool get isDriveApiInitialized => _driveApi != null;

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
  Future<void> _initializeDriveApi({bool forceRefresh = false}) async {
    if (_currentUser == null) {
      print('Cannot initialize Drive API: No user signed in');
      return;
    }
    
    print('Initializing Drive API for user: ${_currentUser!.email} (forceRefresh: $forceRefresh)');
    try {
      if (forceRefresh) {
        // Clear tokens to force a fresh authentication
        await _googleSignIn.disconnect();
        final account = await _googleSignIn.signIn();
        if (account == null) return;
        _currentUser = account;
      }

      // Use the extension method
      final client = await _googleSignIn.authenticatedClient();
      
      if (client != null) {
        _driveApi = drive.DriveApi(client);
        print('Drive API successfully initialized');
      } else {
        print('Failed to get authenticated client');
      }
    } catch (e) {
      print('Error initializing Drive API: $e');
    }
  }

  /// Force re-authentication to fix invalid tokens
  Future<void> reauthenticate() async {
    await _initializeDriveApi(forceRefresh: true);
  }

  /// Upload database file
  Future<String?> uploadDatabase(File file, {String? cashbookId, String? cashbookName, String? color, String? icon}) async {
    if (_driveApi == null) {
      print('Drive API not initialized during upload attempt');
      throw Exception('Drive API not initialized');
    }

    try {
      // 1. Check if backup folder exists
      final folderId = await _getOrCreateBackupFolder(
        cashbookId: cashbookId, 
        cashbookName: cashbookName,
        color: color,
        icon: icon,
      );
      print('Backup folder ID: $folderId');

      // 2. Create file metadata
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'flowpaisa_backup_$timestamp.db';
      
      final driveFile = drive.File()
        ..name = fileName
        ..parents = [folderId];

      // 3. Upload
      final fileSize = await file.length();
      print('Uploading file: $fileName, size: $fileSize bytes');
      
      final media = drive.Media(file.openRead(), fileSize);
      final result = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      print('Upload complete. File ID: ${result.id}');
      return result.id;
    } catch (e) {
      print('Upload failed in GoogleDriveService: $e');
      rethrow;
    }
  }

  /// List available backups
  Future<List<drive.File>> listBackups({String? cashbookId}) async {
    if (_driveApi == null) throw Exception('Drive API not initialized');

    try {
      final folderId = await _getOrCreateBackupFolder(cashbookId: cashbookId);
      final query = "'$folderId' in parents and trashed = false";
      
      final fileList = await _driveApi!.files.list(
        q: query,
        orderBy: 'createdTime desc',
        spaces: 'appDataFolder',
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
  Future<String> _getOrCreateBackupFolder({String? cashbookId, String? cashbookName, String? color, String? icon}) async {
    final rootFolderId = await _getOrCreateFolder('FlowPaisa Backups');
    if (cashbookId != null) {
      // Format: id|name|color|icon
      String folderName = cashbookId;
      if (cashbookName != null) {
        folderName += '|$cashbookName';
        if (color != null && icon != null) {
          folderName += '|$color|$icon';
        }
      }
      
      // Check if folder with this ID exists
      final query = "mimeType = 'application/vnd.google-apps.folder' and '$rootFolderId' in parents and name contains '$cashbookId' and trashed = false";
      final list = await _driveApi!.files.list(q: query, spaces: 'appDataFolder');
      
      if (list.files?.isNotEmpty == true) {
        final existingFolder = list.files!.first;
        // Update folder name if metadata changed
        if (cashbookName != null && existingFolder.name != folderName) {
          await _driveApi!.files.update(
            drive.File()..name = folderName,
            existingFolder.id!,
          );
        }
        return existingFolder.id!;
      }
      
      return _getOrCreateFolder(folderName, parentId: rootFolderId);
    }
    return rootFolderId;
  }

  /// Get or Create cashbook folder in appDataFolder
  Future<String> getOrCreateCashbookFolder(String cashbookId) async {
    return _getOrCreateFolder(cashbookId);
  }

  /// List all folders in appDataFolder to find other cashbooks
  Future<List<String>> listCashbookIds() async {
    if (_driveApi == null) throw Exception('Drive API not initialized');

    final rootFolderId = await _getOrCreateFolder('FlowPaisa Backups');
    final query = "mimeType = 'application/vnd.google-apps.folder' and '$rootFolderId' in parents and trashed = false";
    final list = await _driveApi!.files.list(
      q: query,
      spaces: 'appDataFolder',
      $fields: 'files(id, name)',
    );

    return list.files?.map((f) => f.name!).toList() ?? [];
  }

  /// Get cashbook name from its folder (if available)
  Future<String?> getCashbookName(String cashbookId) async {
    if (_driveApi == null) throw Exception('Drive API not initialized');
    
    // We can't easily store metadata on folders, but we can look for a manifest
    final folderId = await getOrCreateCashbookFolder(cashbookId);
    final manifestId = await getFileIdByName('manifest.json', folderId);
    if (manifestId != null) {
      // final result = await downloadFileWithETag(manifestId);
      // final manifest = SyncManifest.fromJson(result.content);
      // If we add cashbookName to manifest later, we can return it here
    }
    return null;
  }
}
