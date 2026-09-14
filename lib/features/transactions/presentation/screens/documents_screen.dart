import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/native_share.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_attachment_section.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

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

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final backupService = ref.read(documentBackupServiceProvider);
      final zipFile = await backupService.exportToZip();
      
      if (Platform.isAndroid) {
        await NativeShare.shareFile(zipFile.path);
      } else {
        final xFile = XFile(
          zipFile.path,
          mimeType: 'application/zip',
          name: p.basename(zipFile.path),
        );
        await SharePlus.instance.share(ShareParams(
          files: [xFile],
        ));
      }
      if (context.mounted) {
        ToastUtils.showSuccessToast(context, ref, l10n.backupExported);
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) return;

      final file = File(path);
      final backupService = ref.read(documentBackupServiceProvider);
      
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: AppLoadingIndicator(),
          ),
        );
      }

      await backupService.importFromZip(file);

      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        ToastUtils.showSuccessToast(context, ref, l10n.backupImported);
        // Refresh documents list
        ref.invalidate(allDocumentsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        // Dismiss loading dialog if open
        Navigator.pop(context);
        ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final documentsAsync = ref.watch(allDocumentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.documents),
        elevation: 0,
      ),
      body: documentsAsync.when(
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
                      theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatFileSize(totalSize),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.storage,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Visual progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (totalSize / (100 * 1024 * 1024)).clamp(0.0, 1.0), // 100MB soft limit
                        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${docs.length} ${l10n.documents}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          '${l10n.storage} Max: 100 MB',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Backup & Restore Row
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.unarchive_outlined),
                        label: Text(l10n.exportBackup),
                        onPressed: () => _exportBackup(context, ref),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          foregroundColor: theme.colorScheme.onSecondaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.archive_outlined),
                        label: Text(l10n.importBackup),
                        onPressed: () => _importBackup(context, ref),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

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

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: isImg
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
                                            return const SizedBox.shrink();
                                          },
                                        )
                                      : const Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.red,
                                          size: 28,
                                        ),
                                ),
                              ),
                              title: Text(
                                doc.originalName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${_formatFileSize(doc.fileSize)} • ${AppDateFormatter.formatDate(doc.createdAt)}',
                                style: theme.textTheme.bodySmall,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.share_outlined),
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
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
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
                                                await ref
                                                    .read(transactionDocumentsRepositoryProvider)
                                                    .deleteDocument(doc.uuid);
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
                                  ),
                                ],
                              ),
                              onTap: () async {
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
    );
  }
}
