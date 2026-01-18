import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/widgets/add_cashbook_sheet.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/backup/data/local_backup_service.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/premium_badge.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';

class CashbooksScreen extends ConsumerWidget {
  const CashbooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashbooks = ref.watch(cashbooksProvider);
    final activeId = ref.watch(activeCashbookIdProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cashbooks'),
      ),
      body: cashbooks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cashbooks.length,
              itemBuilder: (context, index) {
                final cashbook = cashbooks[index];
                final isActive = cashbook.id == activeId;
                final color = cashbook.color;
                final iconData = cashbook.icon;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? color.withValues(alpha: isDark ? 0.15 : 0.1)
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? color : theme.dividerColor,
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isActive)
                        BoxShadow(
                          color: color.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconData, color: color, size: 28),
                    ),
                    title: Text(
                      cashbook.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      'Created ${AppDateFormatter.formatDate(cashbook.createdAt, pattern: ref.watch(userProfileProvider).dateFormat)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) =>
                              _handleAction(context, ref, value, cashbook),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'backup_local',
                              child: Row(
                                children: [
                                  Icon(Icons.file_upload_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Backup to File'),
                                  SizedBox(width: 8),
                                  PremiumBadge(isSmall: true),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'restore_local',
                              child: Row(
                                children: [
                                  Icon(Icons.file_download_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Restore from File'),
                                  SizedBox(width: 8),
                                  PremiumBadge(isSmall: true),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'clear',
                              child: Row(
                                children: [
                                  Icon(Icons.cleaning_services_outlined,
                                      size: 20, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Clear Data',
                                      style: TextStyle(color: Colors.orange)),
                                ],
                              ),
                            ),
                            if (cashbook.id != 'default')
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    onTap: isActive
                        ? null
                        : () => _switchCashbook(context, ref, cashbook),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        tooltip: 'Add Cashbook',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddCashbookSheet(),
    );
  }

  void _switchCashbook(BuildContext context, WidgetRef ref, Cashbook cashbook) {
    ref.read(activeCashbookIdProvider.notifier).setActive(cashbook.id);
    ToastUtils.showSuccessToast(context, ref, 'Switched to ${cashbook.name}');
  }

  void _handleAction(
      BuildContext context, WidgetRef ref, String action, Cashbook cashbook) {
    if (action == 'edit') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddCashbookSheet(cashbook: cashbook),
      );
    } else if (action == 'backup_local') {
      _handleBackup(context, ref, cashbook);
    } else if (action == 'restore_local') {
      _handleRestore(context, ref, cashbook);
    } else if (action == 'clear') {
      _showClearConfirmation(context, ref, cashbook);
    } else if (action == 'delete') {
      _showDeleteConfirmation(context, ref, cashbook);
    }
  }

  Future<void> _handleBackup(
      BuildContext context, WidgetRef ref, Cashbook cashbook) async {
    if (!PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final filePath = await LocalBackupService.prepareBackupFile(cashbook);

      if (context.mounted) {
        Navigator.pop(context); // Close loading

        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          final fileName = filePath.split(Platform.pathSeparator).last;
          final FileSaveLocation? result = await getSaveLocation(
            suggestedName: fileName,
            acceptedTypeGroups: [
              const XTypeGroup(
                label: 'SQLite Database',
                extensions: ['db'],
              ),
            ],
          );

          if (result != null) {
            final file = File(result.path);
            await File(filePath).copy(file.path);

            if (context.mounted) {
              ToastUtils.showSuccessToast(
                  context, ref, 'Backup saved to ${result.path}');
            }
          }
        } else {
          // Mobile behavior
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Backup Ready'),
              content: Text('Local backup for "${cashbook.name}" is ready.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await LocalBackupService.saveToDownloads(filePath);
                      if (context.mounted) {
                        ToastUtils.showSuccessToast(
                            context, ref, 'Saved to Downloads');
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ToastUtils.showErrorToast(
                            context, ref, 'Error saving: $e');
                      }
                    }
                  },
                  child: const Text('Save Copy'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await LocalBackupService.shareBackupFile(filePath);
                  },
                  child: const Text('Share'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading if still open
        ToastUtils.showErrorToast(context, ref, 'Backup failed: $e');
      }
    }
  }

  Future<void> _handleRestore(
      BuildContext context, WidgetRef ref, Cashbook cashbook) async {
    if (!PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }

    try {
      final file = await LocalBackupService.pickBackupFile();
      if (file == null) return;

      if (context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Cashbook?'),
            content: Text(
                'This will overwrite all data in "${cashbook.name}" with the selected backup file. This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Restore'),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          await ref
              .read(cashbooksProvider.notifier)
              .restoreCashbookFromFile(cashbook.id, file);

          // Invalidate database if it was active
          final activeId = ref.read(activeCashbookIdProvider);
          if (activeId == cashbook.id) {
            ref.invalidate(databaseProvider);
          }

          if (context.mounted) {
            ToastUtils.showSuccessToast(context, ref,
                'Cashbook "${cashbook.name}" restored successfully');
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, ref, 'Restore failed: $e');
      }
    }
  }

  void _showClearConfirmation(
      BuildContext context, WidgetRef ref, Cashbook cashbook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 12),
            Text('Clear Data?'),
          ],
        ),
        content: Text(
          'Are you sure you want to clear all data in "${cashbook.name}"? '
          'This will permanently delete all transactions, contacts, and other records. '
          'The cashbook itself will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(cashbooksProvider.notifier)
                  .clearCashbookData(cashbook.id);
              if (context.mounted) {
                ToastUtils.showSuccessToast(
                    context, ref, 'Data cleared for ${cashbook.name}');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, Cashbook cashbook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Cashbook?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${cashbook.name}"? '
          'ALL DATA within this cashbook will be PERMANENTLY LOST. '
          'This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(cashbooksProvider.notifier).deleteCashbook(cashbook.id);
              Navigator.pop(context);
              ToastUtils.showSuccessToast(
                  context, ref, 'Cashbook "${cashbook.name}" deleted');
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}
