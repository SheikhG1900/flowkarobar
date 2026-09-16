import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:flowpaisa/core/utils/native_share.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class AttachmentItem {
  final String? uuid; // Null if pending
  final File file;
  final String originalName;
  final String mimeType;
  final int fileSize;

  AttachmentItem({
    this.uuid,
    required this.file,
    required this.originalName,
    required this.mimeType,
    required this.fileSize,
  });
}

class TransactionAttachmentSection extends ConsumerWidget {
  final List<AttachmentItem> attachments;
  final Function(List<AttachmentItem>) onAddMultiple;
  final Function(int) onDelete;
  final bool showEditWarning;

  const TransactionAttachmentSection({
    super.key,
    required this.attachments,
    required this.onAddMultiple,
    required this.onDelete,
    this.showEditWarning = false,
  });

  Future<void> _pickAttachment(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    // Show selection dialog/bottom sheet
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    l10n.addAttachment,
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: Text(l10n.camera),
              subtitle: Text(l10n.cameraSubtitle),
              onTap: () async {
                Navigator.pop(sheetContext);
                try {
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 70,
                    maxWidth: 1200,
                  );
                  if (pickedFile != null) {
                    final file = File(pickedFile.path);
                    final name = p.basename(file.path);
                    onAddMultiple([AttachmentItem(
                      file: file,
                      originalName: name,
                      mimeType: 'image/jpeg',
                      fileSize: await file.length(),
                    )]);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ToastUtils.showErrorToast(
                      context,
                      ref,
                      l10n.errorPickingImage(e.toString()),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: Text(l10n.gallery),
              subtitle: Text(l10n.gallerySubtitle),
              onTap: () async {
                Navigator.pop(sheetContext);
                try {
                  final picker = ImagePicker();
                  final pickedFiles = await picker.pickMultiImage(
                    imageQuality: 70,
                    maxWidth: 1200,
                  );
                  if (pickedFiles.isNotEmpty) {
                    final List<AttachmentItem> items = [];
                    for (final pickedFile in pickedFiles) {
                      final file = File(pickedFile.path);
                      final name = p.basename(file.path);
                      items.add(AttachmentItem(
                        file: file,
                        originalName: name,
                        mimeType: 'image/jpeg',
                        fileSize: await file.length(),
                      ));
                    }
                    onAddMultiple(items);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ToastUtils.showErrorToast(
                      context,
                      ref,
                      l10n.errorPickingImage(e.toString()),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(l10n.chooseDocument),
              subtitle: Text(l10n.chooseDocumentSubtitle),
              onTap: () async {
                Navigator.pop(sheetContext);
                try {
                  final List<XFile> pickedFiles = await openFiles(
                    acceptedTypeGroups: <XTypeGroup>[
                      const XTypeGroup(
                        label: 'documents',
                        extensions: <String>['pdf', 'jpg', 'jpeg', 'png', 'webp'],
                      ),
                    ],
                  );
                  if (pickedFiles.isNotEmpty) {
                    final List<AttachmentItem> items = [];
                    for (final pickedFile in pickedFiles) {
                      final file = File(pickedFile.path);
                      final name = p.basename(file.path);
                      final ext = p.extension(file.path).toLowerCase();
                      String mimeType = 'application/octet-stream';
                      if (ext == '.pdf') {
                        mimeType = 'application/pdf';
                      } else if (ext == '.jpg' || ext == '.jpeg') {
                        mimeType = 'image/jpeg';
                      } else if (ext == '.png') {
                        mimeType = 'image/png';
                      } else if (ext == '.webp') {
                        mimeType = 'image/webp';
                      }

                      items.add(AttachmentItem(
                        file: file,
                        originalName: name,
                        mimeType: mimeType,
                        fileSize: await file.length(),
                      ));
                    }
                    onAddMultiple(items);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ToastUtils.showErrorToast(
                      context,
                      ref,
                      l10n.errorPickingImage(e.toString()),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded, color: Colors.amber),
              title: Text(l10n.linkOrphan),
              subtitle: Text(l10n.linkOrphanSubtitle),
              onTap: () async {
                Navigator.pop(sheetContext);
                _showOrphanSelectionDialog(context, ref);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showOrphanSelectionDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final displayDocsAsync = ref.read(displayDocumentsProvider);

    displayDocsAsync.when(
      data: (docs) {
        final orphanDocs = docs.where((doc) => doc.isOrphan && !doc.isMissingPhysicalFile).toList();

        if (orphanDocs.isEmpty) {
          ToastUtils.showWarningToast(context, ref, l10n.noBackupsFound);
          return;
        }

        showDialog(
          context: context,
          builder: (dialogContext) {
            final selectedDocs = <DisplayDocument>{};
            final renamedNames = <String, String>{}; // Map of doc.uuid/fileName to custom name

            return StatefulBuilder(
              builder: (builderContext, setState) {
                return AlertDialog(
                  title: Text(l10n.selectOrphans),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 350,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: orphanDocs.length,
                      itemBuilder: (context, index) {
                        final doc = orphanDocs[index];
                        final isSelected = selectedDocs.contains(doc);
                        final isPdf = doc.mimeType == 'application/pdf' ||
                            p.extension(doc.file.path).toLowerCase() == '.pdf';
                        final isImg = (doc.mimeType ?? '').startsWith('image/') ||
                            ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(
                              p.extension(doc.file.path).toLowerCase().replaceAll('.', ''),
                            );

                        final displayName = renamedNames[doc.uuid] ?? doc.originalName;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            leading: GestureDetector(
                              onTap: () {
                                if (isPdf) {
                                  // Show option dialog for PDF: Open or Select
                                  showDialog(
                                    context: context,
                                    builder: (subContext) => AlertDialog(
                                      title: Text(doc.originalName),
                                      content: Text(l10n.chooseDocumentSubtitle),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(subContext);
                                            // Open PDF
                                            final item = AttachmentItem(
                                              uuid: doc.uuid,
                                              file: doc.file,
                                              originalName: doc.originalName,
                                              mimeType: doc.mimeType ?? 'application/pdf',
                                              fileSize: doc.fileSize,
                                            );
                                            _previewAttachment(context, item);
                                          },
                                          child: Text(l10n.openFile),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            Navigator.pop(subContext);
                                            // Select PDF
                                            setState(() {
                                              if (isSelected) {
                                                selectedDocs.remove(doc);
                                              } else {
                                                selectedDocs.add(doc);
                                              }
                                            });
                                          },
                                          child: Text(l10n.selected),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  // For images and others, just toggle selection
                                  setState(() {
                                    if (isSelected) {
                                      selectedDocs.remove(doc);
                                    } else {
                                      selectedDocs.add(doc);
                                    }
                                  });
                                }
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: isImg
                                      ? Image.file(
                                          doc.file,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.red.withValues(alpha: 0.1),
                                          child: const Icon(
                                            Icons.picture_as_pdf_rounded,
                                            color: Colors.red,
                                            size: 22,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            title: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${(doc.fileSize / 1024).toStringAsFixed(1)} KB',
                              style: theme.textTheme.bodySmall,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                                  onPressed: () {
                                    final textController = TextEditingController(text: p.basenameWithoutExtension(displayName));
                                    showDialog(
                                      context: context,
                                      builder: (renameContext) => AlertDialog(
                                        title: Text(l10n.renameFile),
                                        content: TextField(
                                          controller: textController,
                                          decoration: InputDecoration(
                                            labelText: l10n.fileName,
                                            hintText: l10n.enterFileName,
                                          ),
                                          autofocus: true,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(renameContext),
                                            child: Text(l10n.cancel),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              final newName = textController.text.trim();
                                              if (newName.isNotEmpty) {
                                                final ext = p.extension(doc.originalName);
                                                setState(() {
                                                  renamedNames[doc.uuid] = '$newName$ext';
                                                });
                                              }
                                              Navigator.pop(renameContext);
                                            },
                                            child: Text(l10n.save),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        selectedDocs.add(doc);
                                      } else {
                                        selectedDocs.remove(doc);
                                      }
                                    });
                                  },
                                  activeColor: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: selectedDocs.isEmpty
                          ? null
                          : () {
                              Navigator.pop(dialogContext);
                              final List<AttachmentItem> items = [];
                              for (final doc in selectedDocs) {
                                final customName = renamedNames[doc.uuid] ?? doc.originalName;
                                items.add(AttachmentItem(
                                  uuid: doc.uuid,
                                  file: doc.file,
                                  originalName: customName,
                                  mimeType: doc.mimeType ?? 'application/octet-stream',
                                  fileSize: doc.fileSize,
                                ));
                              }
                              onAddMultiple(items);
                            },
                      child: Text('${l10n.linkSelected} (${selectedDocs.length})'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      loading: () {},
      error: (_, __) {},
    );
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  attachments.isEmpty
                      ? l10n.attachments
                      : '${l10n.attachments} (${attachments.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
              onPressed: () => _pickAttachment(context, ref),
              tooltip: l10n.addAttachment,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (attachments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Text(
                l10n.noAttachments,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final item = attachments[index];
                final isImg = item.mimeType.startsWith('image/') ||
                    ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(
                      p.extension(item.file.path).toLowerCase().replaceAll('.', ''),
                    );

                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _previewAttachment(context, item),
                        child: Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(top: 10, right: 10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.dividerColor,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: isImg
                                ? Image.file(
                                    item.file,
                                    fit: BoxFit.cover,
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          item.originalName,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontSize: 8,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(l10n.delete),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.deleteAttachmentConfirm),
                                    if (showEditWarning && item.uuid != null) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        l10n.deleteAttachmentEditWarning,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.orange.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(l10n.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      onDelete(index);
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
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
