import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/native_share.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_attachment_section.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:flowpaisa/features/transactions/presentation/screens/export_screen.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  drive.File? _latestCloudBackup;
  bool _isCheckingCloud = false;
  bool _isLoading = false;
  String _loadingStatus = '';
  double? _progressValue;

  @override
  void initState() {
    super.initState();
    // Check cloud backup in background after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCloudBackup();
    });
  }

  Future<void> _checkCloudBackup() async {
    final driveService = ref.read(googleDriveServiceProvider);
    if (driveService.isSignedIn) {
      if (mounted) {
        setState(() {
          _isCheckingCloud = true;
        });
      }
      try {
        final activeCashbook = ref.read(activeCashbookProvider);
        final backupService = ref.read(documentBackupServiceProvider);
        final backup = await backupService.getLatestCloudBackup(activeCashbook.id);
        if (mounted) {
          setState(() {
            _latestCloudBackup = backup;
          });
        }
      } catch (_) {
        // Ignore
      } finally {
        if (mounted) {
          setState(() {
            _isCheckingCloud = false;
          });
        }
      }
    }
  }

  String _getRelativeTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 1) return l10n.relativeJustNow;
    if (duration.inMinutes < 60) return l10n.relativeMinutesAgo(duration.inMinutes.toString());
    if (duration.inHours < 24) return l10n.relativeHoursAgo(duration.inHours.toString());
    return l10n.relativeDaysAgo(duration.inDays.toString());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(1)} ${suffixes[i]}";
  }

  void _previewAttachment(BuildContext context, AttachmentItem item) async {
    final isImage = item.mimeType.startsWith('image/') ||
        ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(
          p.extension(item.file.path).toLowerCase().replaceAll('.', ''),
        );
    final isPdf = item.mimeType == 'application/pdf' ||
        p.extension(item.file.path).toLowerCase() == '.pdf';

    if (isImage) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    item.file,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.share),
                  label: Text(AppLocalizations.of(context)!.share),
                  onPressed: () => _shareFile(item),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isPdf) {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        try {
          final fileUri = Uri.file(item.file.absolute.path);
          if (await item.file.exists()) {
            await launchUrl(fileUri);
          }
        } catch (_) {
          _shareFile(item);
        }
      } else {
        try {
          final bytes = await item.file.readAsBytes();
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => bytes,
            name: item.originalName,
          );
        } catch (e) {
          _shareFile(item);
        }
      }
    } else {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        try {
          final fileUri = Uri.file(item.file.absolute.path);
          if (await item.file.exists()) {
            await launchUrl(fileUri);
          }
        } catch (_) {
          _shareFile(item);
        }
      } else {
        _shareFile(item);
      }
    }
  }

  Future<void> _shareFile(AttachmentItem item) async {
    try {
      if (Platform.isAndroid) {
        await NativeShare.shareFile(item.file.path);
      } else {
        final xFile = XFile(
          item.file.path,
          mimeType: item.mimeType,
          name: item.originalName,
        );
        await SharePlus.instance.share(ShareParams(
          files: [xFile],
        ));
      }
    } catch (_) {
      // Fallback
    }
  }

  Future<void> _exportLocalBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _loadingStatus = 'Preparing Backup...';
          _progressValue = null;
        });
      }

      final backupService = ref.read(documentBackupServiceProvider);
      final exportService = ref.read(exportServiceProvider);
      final zipFile = await backupService.exportToZip();
      final fileName = p.basename(zipFile.path);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.backupReady),
            content: Text(l10n.backupReadyMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  try {
                    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                      final FileSaveLocation? result = await getSaveLocation(
                        suggestedName: fileName,
                        acceptedTypeGroups: [
                          const XTypeGroup(
                            label: 'ZIP Backup',
                            extensions: ['zip'],
                          ),
                        ],
                      );
                      if (result != null) {
                        await zipFile.copy(result.path);
                        ref.read(documentSyncRequiredProvider.notifier).markExportSuccessful();
                        if (context.mounted) {
                          ToastUtils.showSuccessToast(
                              context, ref, l10n.exportSavedTo(result.path));
                        }
                      }
                    } else {
                      await exportService.saveToDownloads(zipFile.path);
                      ref.read(documentSyncRequiredProvider.notifier).markExportSuccessful();
                      if (context.mounted) {
                        ToastUtils.showSuccessToast(
                            context, ref, l10n.savedToDownloads);
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ToastUtils.showErrorToast(
                          context, ref, l10n.errorSaving(e.toString()));
                    }
                  }
                },
                child: Text(l10n.saveCopy),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  try {
                    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                      final fileUri = Uri.file(zipFile.path);
                      if (await canLaunchUrl(fileUri)) {
                        await launchUrl(fileUri);
                        ref.read(documentSyncRequiredProvider.notifier).markExportSuccessful();
                      } else {
                        throw Exception('Could not open the backup file.');
                      }
                    } else {
                      await NativeShare.shareFile(zipFile.path);
                      ref.read(documentSyncRequiredProvider.notifier).markExportSuccessful();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ToastUtils.showErrorToast(
                          context, ref, l10n.errorSharing(e.toString()));
                    }
                  }
                },
                child: Text(Platform.isWindows || Platform.isMacOS || Platform.isLinux ? l10n.openFile : l10n.share),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      if (context.mounted) {
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  Future<void> _exportToPdf(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _loadingStatus = l10n.generatingPdfReport;
          _progressValue = null;
        });
      }

      final exportService = ref.read(exportServiceProvider);
      final currencySymbol = ref.read(currencySymbolProvider);
      final decimalPlaces = ref.read(currencyDecimalPlacesProvider);
      final currencyObj = ref.read(currentCurrencyProvider).value;

      final pdfBytes = await exportService.exportTransactionsWithAttachmentsToPDF(
        currencySymbol: currencySymbol,
        decimalPlaces: decimalPlaces,
        l10n: l10n,
        currencyObj: currencyObj,
      );

      final tempDir = await getTemporaryDirectory();
      final fileName = 'attachments_report_${AppDateFormatter.formatForFileName(DateTime.now())}.pdf';
      final pdfFile = File(p.join(tempDir.path, fileName));
      await pdfFile.writeAsBytes(pdfBytes);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.pdfReady),
            content: Text(l10n.pdfReportReady),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  try {
                    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                      final FileSaveLocation? result = await getSaveLocation(
                        suggestedName: fileName,
                        acceptedTypeGroups: [
                          const XTypeGroup(
                            label: 'PDF Document',
                            extensions: ['pdf'],
                          ),
                        ],
                      );
                      if (result != null) {
                        await pdfFile.copy(result.path);
                        ref.read(documentSyncRequiredProvider.notifier).markExportSuccessful();
                        if (context.mounted) {
                          ToastUtils.showSuccessToast(
                              context, ref, l10n.exportSavedTo(result.path));
                        }
                      }
                    } else {
                      await exportService.saveToDownloads(pdfFile.path);
                      ref.read(documentSyncRequiredProvider.notifier).markExportSuccessful();
                      if (context.mounted) {
                        ToastUtils.showSuccessToast(
                            context, ref, l10n.savedToDownloads);
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ToastUtils.showErrorToast(
                          context, ref, l10n.errorSaving(e.toString()));
                    }
                  }
                },
                child: Text(l10n.saveCopy),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  try {
                    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                      final fileUri = Uri.file(pdfFile.path);
                      if (await canLaunchUrl(fileUri)) {
                        await launchUrl(fileUri);
                        ref.read(documentSyncRequiredProvider.notifier).markExportSuccessful();
                      } else {
                        throw Exception('Could not open the PDF file.');
                      }
                    } else {
                      await exportService.sharePDFFile(pdfFile.path);
                      ref.read(documentSyncRequiredProvider.notifier).markExportSuccessful();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ToastUtils.showErrorToast(
                          context, ref, l10n.errorSharing(e.toString()));
                    }
                  }
                },
                child: Text(Platform.isWindows || Platform.isMacOS || Platform.isLinux ? l10n.openFile : l10n.share),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    foregroundColor: theme.colorScheme.onPrimary),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  ref.read(documentSyncRequiredProvider.notifier).markExportSuccessful();
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdfBytes,
                  );
                },
                child: Text(l10n.preview),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      if (context.mounted) {
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  Future<void> _exportCloudBackup(WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    if (kDebugMode) print('[DocumentsScreen] Starting Cloud Export...');
    try {
      if (mounted) {
        if (kDebugMode) print('[DocumentsScreen] Showing loading overlay...');
        setState(() {
          _isLoading = true;
          _loadingStatus = l10n.uploadingToCloud;
          _progressValue = 0.0;
        });
      }

      final activeCashbook = ref.read(activeCashbookProvider);
      final backupService = ref.read(documentBackupServiceProvider);
      
      if (kDebugMode) print('[DocumentsScreen] Uploading ZIP backup to Google Drive...');
      await backupService.uploadBackupToDrive(
        activeCashbook.id,
        cashbookName: activeCashbook.name,
        color: activeCashbook.colorCode,
        icon: activeCashbook.iconCodePoint,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _progressValue = progress;
              _loadingStatus = l10n.uploadingPercentage((progress * 100).toStringAsFixed(0));
            });
          }
        },
      );
      if (kDebugMode) print('[DocumentsScreen] Cloud upload completed successfully.');

      ref.read(documentSyncRequiredProvider.notifier).markExportSuccessful();

      if (mounted) {
        if (kDebugMode) print('[DocumentsScreen] Dismissing loading overlay...');
        setState(() {
          _isLoading = false;
          _progressValue = null;
        });
        ToastUtils.showSuccessToast(context, ref, l10n.backupExported);
        _checkCloudBackup(); // Refresh cloud backup info
      }
    } catch (e) {
      if (kDebugMode) print('[DocumentsScreen] Error during Cloud Export: $e');
      if (mounted) {
        if (kDebugMode) print('[DocumentsScreen] Dismissing loading overlay on error...');
        setState(() {
          _isLoading = false;
          _progressValue = null;
        });
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  Future<void> _importLocalBackup(WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    if (kDebugMode) print('[DocumentsScreen] Starting Local Import...');
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null || result.files.isEmpty) {
        if (kDebugMode) print('[DocumentsScreen] Local Import cancelled: No file selected.');
        return;
      }
      final path = result.files.single.path;
      if (path == null) return;

      final file = File(path);
      final backupService = ref.read(documentBackupServiceProvider);
      
      if (mounted) {
        if (kDebugMode) print('[DocumentsScreen] Showing loading overlay...');
        setState(() {
          _isLoading = true;
          _loadingStatus = l10n.importingBackup;
          _progressValue = null; // Local import is fast, no progress stream needed
        });
      }

      if (kDebugMode) print('[DocumentsScreen] Extracting and importing ZIP file...');
      await backupService.importFromZip(file);
      if (kDebugMode) print('[DocumentsScreen] Local Import completed successfully.');

      if (mounted) {
        if (kDebugMode) print('[DocumentsScreen] Dismissing loading overlay...');
        setState(() {
          _isLoading = false;
        });
        ToastUtils.showSuccessToast(context, ref, l10n.backupImported);
        // Refresh documents list
        ref.invalidate(displayDocumentsProvider);
      }
    } catch (e) {
      if (kDebugMode) print('[DocumentsScreen] Error during Local Import: $e');
      if (mounted) {
        if (kDebugMode) print('[DocumentsScreen] Dismissing loading overlay on error...');
        setState(() {
          _isLoading = false;
        });
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  Future<void> _importCloudBackup(WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    if (kDebugMode) print('[DocumentsScreen] Starting Cloud Import...');
    try {
      if (_latestCloudBackup == null) {
        if (kDebugMode) print('[DocumentsScreen] Cloud Import cancelled: No cloud backup metadata found.');
        return;
      }

      if (mounted) {
        if (kDebugMode) print('[DocumentsScreen] Showing loading overlay...');
        setState(() {
          _isLoading = true;
          _loadingStatus = l10n.downloadingFromCloud;
          _progressValue = 0.0;
        });
      }

      final backupService = ref.read(documentBackupServiceProvider);
      if (kDebugMode) print('[DocumentsScreen] Downloading and importing ZIP from Google Drive...');
      final fileSize = int.tryParse(_latestCloudBackup!.size ?? '0');
      await backupService.downloadAndImportFromDrive(
        _latestCloudBackup!.id!,
        fileSize: fileSize,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _progressValue = progress;
              _loadingStatus = l10n.downloadingPercentage((progress * 100).toStringAsFixed(0));
            });
          }
        },
      );
      if (kDebugMode) print('[DocumentsScreen] Cloud Import completed successfully.');

      ref.read(documentSyncRequiredProvider.notifier).markExportSuccessful();

      if (mounted) {
        if (kDebugMode) print('[DocumentsScreen] Dismissing loading overlay...');
        setState(() {
          _isLoading = false;
          _progressValue = null;
        });
        ToastUtils.showSuccessToast(context, ref, l10n.backupImported);
        // Refresh documents list
        ref.invalidate(displayDocumentsProvider);
      }
    } catch (e) {
      if (kDebugMode) print('[DocumentsScreen] Error during Cloud Import: $e');
      if (mounted) {
        if (kDebugMode) print('[DocumentsScreen] Dismissing loading overlay on error...');
        setState(() {
          _isLoading = false;
          _progressValue = null;
        });
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  void _showExportOptionsSheet(BuildContext parentContext) {
    final l10n = AppLocalizations.of(parentContext)!;
    final theme = Theme.of(parentContext);
    final driveService = ref.read(googleDriveServiceProvider);
    final isDriveConnected = driveService.isSignedIn;

    showModalBottomSheet(
      context: parentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: theme.colorScheme.surface,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.unarchive_rounded, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.exportOptions,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.selectExportDestination,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Option 1: Local Device
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.phone_android_rounded, color: theme.colorScheme.onSurface),
                        ),
                        title: Text(
                          l10n.localDevice,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Save a ZIP backup file to your device',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _exportLocalBackup(parentContext, ref);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Option 2: Google Drive (Cloud)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: isDriveConnected 
                            ? theme.colorScheme.primary.withValues(alpha: 0.04)
                            : null,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDriveConnected 
                                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                : theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.cloud_upload_rounded, 
                            color: isDriveConnected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        title: Text(
                          l10n.googleDriveCloud,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: _isCheckingCloud
                            ? Row(
                                children: [
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 1.5),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.checkingCloudBackup,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              )
                            : Text(
                                !isDriveConnected
                                    ? 'Sign in to Google Drive to backup'
                                    : _latestCloudBackup != null
                                        ? l10n.lastBackedUp(_getRelativeTime(parentContext, _latestCloudBackup!.createdTime!))
                                        : l10n.createCloudBackup,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDriveConnected 
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          if (!isDriveConnected) {
                            // Sign in
                            final driveService = ref.read(googleDriveServiceProvider);
                            final account = await driveService.signIn();
                            if (account != null) {
                              _checkCloudBackup();
                            }
                          } else {
                            _exportCloudBackup(ref);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Option 3: Export as PDF
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.picture_as_pdf_rounded, color: theme.colorScheme.error),
                        ),
                        title: Text(
                          l10n.exportAsPdf,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          l10n.exportAsPdfSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _exportToPdf(parentContext, ref);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showImportOptionsSheet(BuildContext parentContext) {
    final l10n = AppLocalizations.of(parentContext)!;
    final theme = Theme.of(parentContext);
    final driveService = ref.read(googleDriveServiceProvider);
    final isDriveConnected = driveService.isSignedIn;

    showModalBottomSheet(
      context: parentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: theme.colorScheme.surface,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.archive_rounded, color: theme.colorScheme.secondary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.importOptions,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.selectImportSource,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Option 1: Local Device
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.folder_open_rounded, color: theme.colorScheme.onSurface),
                        ),
                        title: Text(
                          l10n.localDevice,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Select a ZIP backup file from your device',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _importLocalBackup(ref);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Option 2: Google Drive (Cloud)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        color: (isDriveConnected && _latestCloudBackup != null)
                            ? theme.colorScheme.secondary.withValues(alpha: 0.04)
                            : null,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        enabled: isDriveConnected && !_isCheckingCloud && _latestCloudBackup != null,
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isDriveConnected && _latestCloudBackup != null)
                                ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                                : theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.cloud_download_rounded, 
                            color: (isDriveConnected && _latestCloudBackup != null) 
                                ? theme.colorScheme.secondary 
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        title: Text(
                          l10n.googleDriveCloud,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: _isCheckingCloud
                            ? Row(
                                children: [
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 1.5),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.checkingCloudBackup,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              )
                            : Text(
                                !isDriveConnected
                                    ? 'Sign in to Google Drive to restore'
                                    : _latestCloudBackup != null
                                        ? '${l10n.lastBackedUp(_getRelativeTime(parentContext, _latestCloudBackup!.createdTime!))} • ${_formatFileSize(int.parse(_latestCloudBackup!.size ?? '0'))}'
                                        : l10n.noCloudBackupFound,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: (isDriveConnected && _latestCloudBackup != null)
                                      ? theme.colorScheme.secondary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                        onTap: (isDriveConnected && _latestCloudBackup != null)
                            ? () {
                                Navigator.pop(sheetContext);
                                _importCloudBackup(ref);
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final documentsAsync = ref.watch(displayDocumentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.documents),
        elevation: 0,
        actions: [
          documentsAsync.maybeWhen(
            data: (docs) {
              final hasOrphans = docs.any((doc) => doc.isOrphan);
              if (!hasOrphans) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_rounded),
                tooltip: l10n.clearOrphans,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n.clearOrphans),
                      content: Text(l10n.clearOrphansConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            setState(() {
                              _isLoading = true;
                              _loadingStatus = l10n.clearOrphans;
                            });
                            try {
                              for (final doc in docs) {
                                if (doc.isOrphan) {
                                  if (doc.dbDoc == null) {
                                    if (await doc.file.exists()) {
                                      await doc.file.delete();
                                    }
                                  } else {
                                    await ref
                                        .read(transactionDocumentsRepositoryProvider)
                                        .deleteDocument(doc.uuid);
                                  }
                                }
                              }
                              ref.invalidate(displayDocumentsProvider);
                              if (context.mounted) {
                                ToastUtils.showSuccessToast(
                                  context,
                                  ref,
                                  l10n.orphansCleared,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ToastUtils.showErrorToast(
                                  context,
                                  ref,
                                  l10n.errorOccurred(e.toString()),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          child: Text(
                            l10n.delete,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Stack(
        children: [
          documentsAsync.when(
            data: (docs) {
              final filteredDocs = docs.where((doc) {
                return doc.originalName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
              }).toList();

              final totalSize = docs.fold<int>(0, (sum, doc) => sum + doc.fileSize);

              return Column(
                children: [
                  // Storage Summary Card
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGradient.colors.first.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.storageUsed,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatFileSize(totalSize),
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_done_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Visual progress bar with percentage text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: (totalSize / (100 * 1024 * 1024)).clamp(0.0, 1.0), // 100MB soft limit
                                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${((totalSize / (100 * 1024 * 1024)) * 100).toStringAsFixed(1)}%',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${docs.length} ${l10n.documents}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${l10n.storage} Max: 100 MB',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Backup & Restore Row (Prominent Action Buttons)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            title: l10n.exportBackup,
                            icon: Icons.unarchive_rounded,
                            gradient: AppColors.primaryGradient,
                            onTap: () {
                              final isPremium = ref.read(premiumProvider).isPremium;
                              if (isPremium) {
                                _showExportOptionsSheet(context);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PremiumScreen()),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            title: l10n.importBackup,
                            icon: Icons.archive_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00B8A3), Color(0xFF009980)], // Teal gradient
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            onTap: () {
                              final isPremium = ref.read(premiumProvider).isPremium;
                              if (isPremium) {
                                _showImportOptionsSheet(context);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PremiumScreen()),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: l10n.search,
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Documents List
                  Expanded(
                    child: filteredDocs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open_outlined,
                                  size: 64,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.noAttachments,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              final doc = filteredDocs[index];
                              final isImg = (doc.mimeType ?? '').startsWith('image/') ||
                                  ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(
                                    (doc.mimeType ?? '').toLowerCase(),
                                  );

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: doc.isOrphan
                                        ? Colors.orange.withValues(alpha: 0.3)
                                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.shadow.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceContainerHigh,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                            width: 1,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(11),
                                          child: doc.isMissingPhysicalFile
                                              ? Container(
                                                  color: Colors.orange.withValues(alpha: 0.1),
                                                  child: const Icon(
                                                    Icons.warning_amber_rounded,
                                                    color: Colors.orange,
                                                    size: 26,
                                                  ),
                                                )
                                              : (isImg
                                                  ? FutureBuilder<Directory>(
                                                      future: ref.read(transactionDocumentsRepositoryProvider).getDocumentsDirectory(),
                                                      builder: (context, snapshot) {
                                                        if (snapshot.hasData) {
                                                          final file = File(p.join(snapshot.data!.path, doc.fileName));
                                                          return Image.file(
                                                            file,
                                                            fit: BoxFit.cover,
                                                          );
                                                        }
                                                        return const Center(
                                                          child: SizedBox(
                                                            width: 16,
                                                            height: 16,
                                                            child: CircularProgressIndicator(strokeWidth: 2),
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Container(
                                                      color: Colors.red.withValues(alpha: 0.1),
                                                      child: const Icon(
                                                        Icons.picture_as_pdf_rounded,
                                                        color: Colors.red,
                                                        size: 26,
                                                      ),
                                                    )),
                                        ),
                                      ),
                                      if (doc.dbDoc?.isNotSynced == true)
                                        Positioned(
                                          right: -3,
                                          bottom: -3,
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: theme.cardColor,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.15),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: Colors.orange.withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.cloud_upload_outlined,
                                              size: 11,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          doc.originalName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      if (doc.isOrphan) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: Colors.orange.withValues(alpha: 0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            l10n.orphan,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: Colors.orange.shade800,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '${_formatFileSize(doc.fileSize)} • ${AppDateFormatter.formatDate(doc.createdAt)}${doc.isOrphan ? ' • ${l10n.orphanSubtitle}' : ''}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: doc.isOrphan
                                            ? Colors.orange.shade800
                                            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!doc.isMissingPhysicalFile)
                                        IconButton(
                                          icon: Icon(
                                            Icons.share_rounded,
                                            color: theme.colorScheme.primary,
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            final docRepo = ref.read(transactionDocumentsRepositoryProvider);
                                            final docDir = await docRepo.getDocumentsDirectory();
                                            final file = File(p.join(docDir.path, doc.fileName));
                                            final item = AttachmentItem(
                                              uuid: doc.uuid,
                                              file: file,
                                              originalName: doc.originalName,
                                              mimeType: doc.mimeType ?? 'application/octet-stream',
                                              fileSize: doc.fileSize,
                                            );
                                            _shareFile(item);
                                          },
                                          tooltip: l10n.share,
                                        ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: Text(l10n.delete),
                                              content: Text(l10n.deleteAttachmentConfirm),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: Text(l10n.cancel),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    if (doc.dbDoc == null) {
                                                      if (await doc.file.exists()) {
                                                        await doc.file.delete();
                                                      }
                                                    } else {
                                                      await ref
                                                          .read(transactionDocumentsRepositoryProvider)
                                                          .deleteDocument(doc.uuid);
                                                    }
                                                    ref.invalidate(displayDocumentsProvider);
                                                    if (context.mounted) {
                                                      ToastUtils.showSuccessToast(
                                                        context,
                                                        ref,
                                                        l10n.transactionDeleted,
                                                      );
                                                    }
                                                  },
                                                  child: Text(
                                                    l10n.delete,
                                                    style: const TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        tooltip: l10n.delete,
                                      ),
                                    ],
                                  ),
                                  onTap: doc.isMissingPhysicalFile
                                      ? null
                                      : () async {
                                          final docRepo = ref.read(transactionDocumentsRepositoryProvider);
                                          final docDir = await docRepo.getDocumentsDirectory();
                                          final file = File(p.join(docDir.path, doc.fileName));
                                          final item = AttachmentItem(
                                            uuid: doc.uuid,
                                            file: file,
                                            originalName: doc.originalName,
                                            mimeType: doc.mimeType ?? 'application/octet-stream',
                                            fileSize: doc.fileSize,
                                          );
                                          if (context.mounted) {
                                            _previewAttachment(context, item);
                                          }
                                        },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (err, _) => Center(child: Text(l10n.errorOccurred(err.toString()))),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppLoadingIndicator(size: 50),
                          if (_loadingStatus.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              _loadingStatus,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          if (_progressValue != null) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: 200,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _progressValue,
                                  backgroundColor: theme.colorScheme.surfaceContainerHigh,
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
