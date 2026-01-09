import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/backup/data/google_drive_service.dart';
import 'package:flowpaisa/features/backup/data/backup_repository.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';

/// Provider for GoogleDriveService
final googleDriveServiceProvider = Provider<GoogleDriveService>((ref) {
  final service = GoogleDriveService();
  service.init(); // Initialize silently
  return service;
});

/// Provider for BackupRepository
final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final driveService = ref.watch(googleDriveServiceProvider);
  return BackupRepository(driveService);
});

/// State for Backup Screen
class BackupState {
  final bool isLoading;
  final GoogleSignInAccount? currentUser;
  final List<drive.File> backups;
  final DateTime? lastBackupTime;
  final String? error;

  BackupState({
    this.isLoading = false,
    this.currentUser,
    this.backups = const [],
    this.lastBackupTime,
    this.error,
  });

  BackupState copyWith({
    bool? isLoading,
    GoogleSignInAccount? currentUser,
    List<drive.File>? backups,
    DateTime? lastBackupTime,
    String? error,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      backups: backups ?? this.backups,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      error: error,
    );
  }
}

class BackupNotifier extends Notifier<BackupState> {
  late GoogleDriveService _driveService;
  late BackupRepository _repository;

  @override
  BackupState build() {
    _driveService = ref.watch(googleDriveServiceProvider);
    _repository = ref.watch(backupRepositoryProvider);
    
    // Trigger init post-build
    Future.microtask(() => _init());
    
    return BackupState();
  }

  Future<void> _init() async {
    // Wait for silent sign in
    await Future.delayed(const Duration(seconds: 1)); 
    
    if (_driveService.currentUser != state.currentUser) {
      state = state.copyWith(currentUser: _driveService.currentUser);
    }
    
    final lastTime = await _repository.getLastBackupTime();
    state = state.copyWith(lastBackupTime: lastTime);

    if (_driveService.isSignedIn) {
      await loadBackups();
    }
  }

  Future<void> signIn() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final account = await _driveService.signIn();
      state = state.copyWith(
        currentUser: account,
        isLoading: false,
      );
      await loadBackups();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _driveService.signOut();
    state = BackupState(); // Reset
  }

  Future<void> loadBackups() async {
    if (!_driveService.isSignedIn) return;
    try {
      state = state.copyWith(isLoading: true);
      final backups = await _driveService.listBackups();
      state = state.copyWith(
        isLoading: false,
        backups: backups,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load backups');
    }
  }

  Future<void> backup() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.backup();
      
      // Refresh list and time
      final backups = await _driveService.listBackups();
      final time = await _repository.getLastBackupTime();
      
      state = state.copyWith(
        isLoading: false,
        backups: backups,
        lastBackupTime: time,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> restore(String fileId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repository.restore(fileId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final backupProvider = NotifierProvider<BackupNotifier, BackupState>(BackupNotifier.new);
