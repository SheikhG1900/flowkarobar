import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';

/// Service to handle in-app updates across platforms.
/// - Android: Uses Google Play's In-App Update API.
/// - Windows: Uses a custom hybrid auto-update system (Firebase Hosting + GitHub Releases).
class UpdateService {
  bool _isDownloading = false;

  /// Checks for available updates and triggers the platform-specific update flow.
  Future<void> checkForUpdate() async {
    // In-app updates via Play Store are only supported on Android.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    try {
      // Check if an update is available on the Play Store
      final info = await InAppUpdate.checkForUpdate();
      
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          // Immediate Update: Full-screen, mandatory update flow.
          // The app will restart automatically after the update is installed.
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          // Flexible Update: Background download.
          await InAppUpdate.startFlexibleUpdate();
        }
      }
    } catch (e) {
      // Fail silently to ensure the app remains usable even if the update check fails.
      debugPrint('UpdateService: Error checking for Android updates: $e');
    }
  }

  /// Checks for Windows desktop updates and triggers the custom update flow.
  Future<void> checkForWindowsUpdate(BuildContext context, WidgetRef ref) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) return;

    final notifier = ref.read(windowsUpdateStateProvider.notifier);
    notifier.setStatus(WindowsUpdateStatus.checking);

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

      // Fetch version.json from Firebase Hosting
      final dio = Dio();
      final response = await dio.get(
        'https://flow-paisa.firebaseapp.com/version.json',
        options: Options(
          headers: {'Cache-Control': 'no-cache'}, // Avoid caching issues
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        debugPrint('UpdateService: Successfully fetched version.json from Firebase: $data');
        final serverVersion = data['version'] as String;
        final serverBuild = data['buildNumber'] as int;
        final downloadUrl = data['url'] as String;
        final changelog = data['changelog'] as String? ?? 'Bug fixes and improvements.';

        debugPrint('UpdateService: Local Version: $currentVersion (Build: $currentBuild) | Server Version: $serverVersion (Build: $serverBuild)');

        if (_isNewerVersion(currentVersion, currentBuild, serverVersion, serverBuild)) {
          notifier.setStatus(
            WindowsUpdateStatus.updateAvailable,
            currentVersion: currentVersion,
            serverVersion: serverVersion,
            downloadUrl: downloadUrl,
            changelog: changelog,
          );
          if (context.mounted) {
            _showUpdateDialog(context, ref, serverVersion, downloadUrl, changelog);
          }
        } else {
          notifier.setStatus(
            WindowsUpdateStatus.upToDate,
            currentVersion: currentVersion,
            serverVersion: serverVersion,
          );
        }
      } else {
        notifier.setStatus(WindowsUpdateStatus.failed);
      }
    } catch (e) {
      debugPrint('UpdateService: Desktop update check failed: $e');
      notifier.setStatus(WindowsUpdateStatus.failed);
    }
  }

  /// Compares local version and build number with the server's version and build number.
  bool _isNewerVersion(String currentVersion, int currentBuild, String serverVersion, int serverBuild) {
    try {
      final currentParts = currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final serverParts = serverVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < 3; i++) {
        final currentPart = i < currentParts.length ? currentParts[i] : 0;
        final serverPart = i < serverParts.length ? serverParts[i] : 0;
        if (serverPart > currentPart) return true;
        if (serverPart < currentPart) return false;
      }

      return serverBuild > currentBuild;
    } catch (e) {
      // Fallback: If parsing fails, compare build numbers directly
      return serverBuild > currentBuild;
    }
  }

  /// Displays a beautifully styled update dialog matching Flowpaisa theme.
  void _showUpdateDialog(
    BuildContext context,
    WidgetRef ref,
    String serverVersion,
    String downloadUrl,
    String changelog,
  ) {
    final activeCashbook = ref.read(activeCashbookProvider);
    final primaryColor = activeCashbook.color;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false, // Force user to choose
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.system_update_alt_rounded, color: primaryColor, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Update Available',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A new version ($serverVersion) of Flowpaisa is available. Update now to get the latest features and improvements!',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "What's New:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        changelog,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Later',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: activeCashbook.foreColor(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                _showDownloadProgressDialog(context, ref, downloadUrl);
              },
              child: const Text('Update Now'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a linear progress dialog showing real-time download progress.
  void _showDownloadProgressDialog(BuildContext context, WidgetRef ref, String downloadUrl) {
    final activeCashbook = ref.read(activeCashbookProvider);
    final primaryColor = activeCashbook.color;
    final theme = Theme.of(context);

    double progress = 0.0;
    String statusText = 'Starting download...';
    CancelToken cancelToken = CancelToken();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (progressContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Start download if not already started
            _downloadAndInstall(
              downloadUrl,
              cancelToken,
              onProgress: (received, total) {
                if (total != -1) {
                  setState(() {
                    progress = received / total;
                    statusText = 'Downloading: ${(progress * 100).toStringAsFixed(0)}%';
                  });
                } else {
                  setState(() {
                    statusText = 'Downloading...';
                  });
                }
              },
              onError: (error) {
                if (progressContext.mounted) {
                  Navigator.pop(progressContext);
                  _showErrorDialog(context, ref, error);
                }
              },
            );

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Downloading Update',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress > 0 ? progress : null,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please do not close the application. Once finished, the installer will launch automatically.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    cancelToken.cancel();
                    Navigator.pop(progressContext);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Downloads the installer and launches it in a detached process.
  Future<void> _downloadAndInstall(
    String url,
    CancelToken cancelToken, {
    required void Function(int received, int total) onProgress,
    required void Function(String error) onError,
  }) async {
    if (_isDownloading) return;
    _isDownloading = true;

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/flowpaisa_setup.exe';

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: onProgress,
      );

      final file = File(filePath);
      if (await file.exists()) {
        // Launch installer detached and close the app
        await Process.start(filePath, [], runInShell: true, mode: ProcessStartMode.detached);
        exit(0);
      } else {
        onError('Downloaded installer file could not be found.');
      }
    } catch (e) {
      if (!cancelToken.isCancelled) {
        onError(e.toString());
      }
    } finally {
      _isDownloading = false;
    }
  }

  /// Displays an error dialog if the update download fails.
  void _showErrorDialog(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Update Failed', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'An error occurred while downloading the update:\n\n$error\n\nPlease check your internet connection and try again.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// Provider for [UpdateService].
final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());

/// Status of the Windows update check.
enum WindowsUpdateStatus {
  idle,
  checking,
  upToDate,
  updateAvailable,
  failed,
}

/// State for Windows update.
class WindowsUpdateState {
  final WindowsUpdateStatus status;
  final String? currentVersion;
  final String? serverVersion;
  final String? downloadUrl;
  final String? changelog;

  WindowsUpdateState({
    required this.status,
    this.currentVersion,
    this.serverVersion,
    this.downloadUrl,
    this.changelog,
  });

  WindowsUpdateState copyWith({
    WindowsUpdateStatus? status,
    String? currentVersion,
    String? serverVersion,
    String? downloadUrl,
    String? changelog,
  }) {
    return WindowsUpdateState(
      status: status ?? this.status,
      currentVersion: currentVersion ?? this.currentVersion,
      serverVersion: serverVersion ?? this.serverVersion,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      changelog: changelog ?? this.changelog,
    );
  }
}

/// Notifier to manage Windows update state.
class WindowsUpdateNotifier extends Notifier<WindowsUpdateState> {
  @override
  WindowsUpdateState build() {
    return WindowsUpdateState(status: WindowsUpdateStatus.idle);
  }

  void setStatus(
    WindowsUpdateStatus status, {
    String? currentVersion,
    String? serverVersion,
    String? downloadUrl,
    String? changelog,
  }) {
    state = state.copyWith(
      status: status,
      currentVersion: currentVersion,
      serverVersion: serverVersion,
      downloadUrl: downloadUrl,
      changelog: changelog,
    );
  }
}

/// Provider for Windows update state.
final windowsUpdateStateProvider =
    NotifierProvider<WindowsUpdateNotifier, WindowsUpdateState>(
        () => WindowsUpdateNotifier());

/// Icon widget to display Windows update status in the app bar.
class WindowsUpdateStatusIcon extends ConsumerWidget {
  const WindowsUpdateStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.windows) {
      return const SizedBox.shrink();
    }

    final updateState = ref.watch(windowsUpdateStateProvider);
    final activeCashbook = ref.watch(activeCashbookProvider);
    final primaryColor = activeCashbook.color;
    final theme = Theme.of(context);

    switch (updateState.status) {
      case WindowsUpdateStatus.checking:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onSurface),
            ),
          ),
        );
      case WindowsUpdateStatus.upToDate:
        return Tooltip(
          message: 'Flowpaisa is up to date',
          child: IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Flowpaisa is up to date! (v${updateState.currentVersion ?? ""})'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      case WindowsUpdateStatus.updateAvailable:
        return Tooltip(
          message: 'Update Available: Click to update',
          child: IconButton(
            icon: Icon(Icons.system_update_alt_rounded, color: primaryColor),
            onPressed: () {
              ref.read(updateServiceProvider).checkForWindowsUpdate(context, ref);
            },
          ),
        );
      case WindowsUpdateStatus.failed:
        return Tooltip(
          message: 'Update check failed: Click to retry',
          child: IconButton(
            icon: const Icon(Icons.error_outline_rounded, color: Colors.orange),
            onPressed: () {
              ref.read(updateServiceProvider).checkForWindowsUpdate(context, ref);
            },
          ),
        );
      case WindowsUpdateStatus.idle:
        return Tooltip(
          message: 'Check for updates',
          child: IconButton(
            icon: Icon(Icons.update_rounded, color: theme.colorScheme.onSurface),
            onPressed: () {
              ref.read(updateServiceProvider).checkForWindowsUpdate(context, ref);
            },
          ),
        );
    }
  }
}
