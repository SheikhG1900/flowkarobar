import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/widgets/add_cashbook_sheet.dart';
import 'package:flowpaisa/features/cashbooks/presentation/widgets/cloud_cashbook_selection_sheet.dart';
import 'package:flowpaisa/features/cashbooks/presentation/widgets/copy_preferences_dialog.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/backup/data/local_backup_service.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/premium_badge.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';

import 'package:flowpaisa/l10n/app_localizations.dart';

class CashbooksScreen extends ConsumerWidget {
  const CashbooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashbooks = ref.watch(cashbooksProvider);
    final activeId = ref.watch(activeCashbookIdProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Listen for background operation messages
    ref.listen(backupProvider, (previous, next) {
      if (next.lastSuccessMessage != null &&
          next.lastSuccessMessage != previous?.lastSuccessMessage) {
        ToastUtils.showSuccessToast(context, ref, next.lastSuccessMessage!);
      }
      if (next.lastErrorMessage != null &&
          next.lastErrorMessage != previous?.lastErrorMessage) {
        ToastUtils.showErrorToast(context, ref, next.lastErrorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myCashbooks),
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
                      l10n.createdLabel(
                          AppDateFormatter.formatDate(cashbook.createdAt)),
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
                            child: Text(
                              l10n.active,
                              style: const TextStyle(
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
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  Text(l10n.edit),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'backup',
                              child: Row(
                                children: [
                                  const Icon(Icons.backup_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  Text(l10n.takeBackup),
                                  const SizedBox(width: 8),
                                  const PremiumBadge(isSmall: true),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'restore_local',
                              child: Row(
                                children: [
                                  const Icon(Icons.file_download_outlined,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Text(l10n.restoreFromFile),
                                  const SizedBox(width: 8),
                                  const PremiumBadge(isSmall: true),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'copy_preferences',
                              child: Row(
                                children: [
                                  const Icon(Icons.copy_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  Text(l10n.copyPreferences),
                                  const SizedBox(width: 8),
                                  const PremiumBadge(isSmall: true),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'clear',
                              child: Row(
                                children: [
                                  const Icon(Icons.cleaning_services_outlined,
                                      size: 20, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(l10n.clearData,
                                      style: const TextStyle(
                                          color: Colors.orange)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'clear_cloud',
                              child: Row(
                                children: [
                                  const Icon(Icons.cloud_off_outlined,
                                      size: 20, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(l10n.clearCloud,
                                      style: const TextStyle(
                                          color: Colors.orange)),
                                  const SizedBox(width: 8),
                                  const PremiumBadge(isSmall: true),
                                ],
                              ),
                            ),
                            if (cashbook.id != 'default')
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_outline,
                                        size: 20, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text(l10n.delete,
                                        style:
                                            const TextStyle(color: Colors.red)),
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ref.watch(backupProvider).currentUser != null) ...[
            FloatingActionButton(
              heroTag: 'add_cloud_cashbook',
              backgroundColor: theme.colorScheme.secondaryContainer,
              onPressed: () => _showCloudSelectionSheet(context, ref),
              tooltip: l10n.addFromCloud,
              child: Icon(Icons.cloud_download,
                  color: theme.colorScheme.onSecondaryContainer),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            heroTag: 'add_local_cashbook',
            backgroundColor: theme.colorScheme.primary,
            onPressed: () => _showAddSheet(context),
            tooltip: l10n.addCashbook,
            child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }

  void _showCloudSelectionSheet(BuildContext context, WidgetRef ref) {
    // Refresh available cashbooks from cloud before showing
    ref.read(backupProvider.notifier).loadAvailableCashbooks();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CloudCashbookSelectionSheet(),
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
    final l10n = AppLocalizations.of(context)!;
    ref.read(activeCashbookIdProvider.notifier).setActive(cashbook.id);
    ToastUtils.showSuccessToast(
        context, ref, l10n.switchedToCashbook(cashbook.name));
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
    } else if (action == 'backup') {
      _showBackupOptions(context, ref, cashbook);
    } else if (action == 'restore_local') {
      _handleRestore(context, ref, cashbook);
    } else if (action == 'copy_preferences') {
      if (!PremiumGate.isPremium(ref)) {
        PremiumGate.showPremiumDialog(context);
        return;
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CopyPreferencesSheet(
          targetCashbookId: cashbook.id,
        ),
      );
    } else if (action == 'clear') {
      _showClearConfirmation(context, ref, cashbook);
    } else if (action == 'clear_cloud') {
      _showClearCloudDialog(context, ref, cashbook);
    } else if (action == 'delete') {
      _showDeleteConfirmation(context, ref, cashbook);
    }
  }

  void _showBackupOptions(
      BuildContext context, WidgetRef ref, Cashbook cashbook) {
    if (!PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.backupOptionsTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildBackupOption(
              context,
              icon: Icons.cloud_upload_outlined,
              title: l10n.backupToCloud,
              subtitle: l10n.backupToCloudSubtitle,
              color: Colors.blue,
              onTap: () async {
                Navigator.pop(context);
                final backupNotifier = ref.read(backupProvider.notifier);
                final backupState = ref.read(backupProvider);
                final screenContext = context; // Store screen context

                if (backupState.isBackingUp) {
                  ToastUtils.showInfoToast(
                      screenContext, ref, l10n.processing);
                  return;
                }

                // If not signed in, redirect to backup screen
                if (backupState.currentUser == null) {
                  Navigator.pushNamed(context, '/backup');
                  return;
                }

                // Run backup in background without busy dialog
                // Start the backup process without awaiting it here, 
                // so the UI remains interactive immediately.
                if (screenContext.mounted) {
                  ToastUtils.showInfoToast(
                      screenContext, ref, l10n.backgroundBackupStarted);
                }

                // Use a separate async block to handle the completion and toast
                () async {
                  try {
                    await backupNotifier.backup(l10n, targetCashbook: cashbook);
                  } catch (e) {
                    // Error is already handled in the provider state
                  }
                }();
              },
            ),
            const SizedBox(height: 12),
            _buildBackupOption(
              context,
              icon: Icons.file_upload_outlined,
              title: l10n.backupToFile,
              subtitle: l10n.backupToFileSubtitle,
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _handleBackup(context, ref, cashbook);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBackup(
      BuildContext context, WidgetRef ref, Cashbook cashbook) async {
    final theme = Theme.of(context);
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
        final l10n = AppLocalizations.of(context)!;
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
                  context, ref, l10n.exportSavedTo(result.path));
            }
          }
        } else {
          // Mobile behavior
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.backupReady),
              content: Text(l10n.backupReadyMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.done),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await LocalBackupService.saveToDownloads(filePath);
                      if (context.mounted) {
                        ToastUtils.showSuccessToast(
                            context, ref, l10n.savedToDownloads);
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ToastUtils.showErrorToast(
                            context, ref, l10n.errorOccurred(e.toString()));
                      }
                    }
                  },
                  child: Text(l10n.saveCopy),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                      foregroundColor: theme.colorScheme.onPrimary),
                  onPressed: () async {
                    Navigator.pop(context);
                    await LocalBackupService.shareBackupFile(filePath);
                  },
                  child: Text(l10n.share),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        Navigator.pop(context); // Close loading if still open
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
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
        final l10n = AppLocalizations.of(context)!;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.restore),
            content: Text(l10n.restoreBackupMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.restore),
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
            // Force a fresh AppDatabase instance and refresh any listeners
            ref.invalidate(databaseProvider);
            ref.invalidate(activeCashbookProvider);
          }

          if (context.mounted) {
            ToastUtils.showSuccessToast(context, ref, l10n.restoreSuccessful);
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  void _showClearConfirmation(
      BuildContext context, WidgetRef ref, Cashbook cashbook) {
    final l10n = AppLocalizations.of(context)!;
    final screenContext = context; // Store screen context
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 12),
              Text(l10n.clearData),
            ],
          ),
          content: Text(l10n.confirmDelete(cashbook.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await ref.read(cashbooksProvider.notifier).clearCashbookData(
                    cashbook.id,
                    context: screenContext,
                    shouldClearCloud: false);

                if (screenContext.mounted) {
                  ToastUtils.showSuccessToast(
                      screenContext, ref, l10n.cashbookUpdated);
                }
              },
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white),
              child: Text(l10n.clearData),
            ),
          ],
        );
      },
    );
  }

  void _showClearCloudDialog(
      BuildContext context, WidgetRef ref, Cashbook cashbook) {
    final l10n = AppLocalizations.of(context)!;
    final screenContext = context; // Store screen context
    final backupState = ref.watch(backupProvider);

    // If not signed in, redirect to backup screen
    if (backupState.currentUser == null) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.clearCloudTitle),
          content: Text(l10n.signInGoogleToBackup),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushNamed(screenContext, '/backup');
              },
              child: Text(l10n.googleDriveBackup),
            ),
          ],
        ),
      );
      return;
    }

    // Check premium
    if (!PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool clearBackups = false;
        bool clearSync = false;

        return StatefulBuilder(builder: (builderContext, setState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.cloud_off, color: Colors.orange),
                const SizedBox(width: 12),
                Text(l10n.clearCloudTitle),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.clearCloudMessage(cashbook.name)),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(l10n.clearBackups),
                  subtitle: Text(l10n.clearBackupsSubtitle),
                  value: clearBackups,
                  onChanged: (val) => setState(() => clearBackups = val ?? false),
                  activeColor: Colors.orange,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: Text(l10n.clearSyncHistory),
                  subtitle: Text(l10n.clearSyncHistorySubtitle),
                  value: clearSync,
                  onChanged: (val) => setState(() => clearSync = val ?? false),
                  activeColor: Colors.orange,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: (!clearBackups && !clearSync)
                    ? null
                    : () {
                        Navigator.pop(dialogContext);
                        if (screenContext.mounted) {
                          ToastUtils.showInfoToast(screenContext, ref,
                              l10n.backgroundCloudClearStarted);
                        }

                        // Use a separate async block to handle the completion and toast
                        () async {
                          try {
                            await ref
                                .read(backupProvider.notifier)
                                .clearGranularCloudData(cashbook.id,
                                    clearBackups: clearBackups,
                                    clearSync: clearSync);
                          } catch (e) {
                            // Error is already handled in the provider state
                          }
                        }();
                      },
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white),
                child: Text(l10n.clearSelectedCloudData),
              ),
            ],
          );
        });
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, Cashbook cashbook) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.red),
            const SizedBox(width: 12),
            Text(l10n.deleteCashbookTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteCashbookMessage(cashbook.name)),
            const SizedBox(height: 16),
            Text(
              l10n.deleteLocalOnlyNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(cashbooksProvider.notifier).deleteCashbook(cashbook.id);
              Navigator.pop(context);
              ToastUtils.showSuccessToast(context, ref, l10n.cashbookDeleted);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.deletePermanently),
          ),
        ],
      ),
    );
  }
}
