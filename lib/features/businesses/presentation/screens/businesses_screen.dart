import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:flowpaisa/features/businesses/domain/models/business_summary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/businesses/domain/models/business.dart';
import 'package:flowpaisa/features/businesses/presentation/providers/business_provider.dart';
import 'package:flowpaisa/features/businesses/presentation/widgets/add_business_sheet.dart';
import 'package:flowpaisa/features/businesses/presentation/widgets/cloud_business_selection_sheet.dart';
import 'package:flowpaisa/features/businesses/presentation/widgets/copy_preferences_dialog.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/backup/data/local_backup_service.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/shared/widgets/premium_badge.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:file_selector/file_selector.dart' as selector;
import 'dart:io';

import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';

class BusinessesScreen extends ConsumerWidget {
  const BusinessesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businesses = ref.watch(businessesProvider);
    final activeId = ref.watch(activeBusinessIdProvider);
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
      body: businesses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16).copyWith(
                  bottom: 80 + MediaQuery.of(context).padding.bottom),
              itemCount: businesses.length,
              itemBuilder: (context, index) {
                final business = businesses[index];
                final isActive = business.id == activeId;
                final color = business.color;
                final iconData = business.icon;
                final isPremium = ref.watch(premiumProvider).isPremium;
                final isLocked = !isPremium &&
                    business.id != 'default' &&
                    (business.addSeq ?? 0) >= PremiumGate.cashbookTotalLimit;

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
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: isLocked ? 0.5 : 1.0,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(iconData, color: color, size: 28),
                              ),
                              if (isLocked)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.outlineVariant,
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.lock,
                                      size: 10,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            business.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            l10n.createdLabel(AppDateFormatter.formatDate(
                                business.createdAt)),
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: isLocked
                              ? null
                              : PopupMenuButton<String>(
                                  onSelected: (value) => _handleAction(
                                      context, ref, value, business),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit_outlined,
                                              size: 20),
                                          const SizedBox(width: 8),
                                          Text(l10n.edit),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'backup',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.backup_outlined,
                                              size: 20),
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
                                          const Icon(Icons.restore, size: 20),
                                          const SizedBox(width: 8),
                                          Text(l10n.restore),
                                          const SizedBox(width: 8),
                                          const PremiumBadge(isSmall: true),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'copy_preferences',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.copy_outlined,
                                              size: 20),
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
                                          const Icon(
                                              Icons.cleaning_services_outlined,
                                              size: 20,
                                              color: Colors.orange),
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
                                    if (business.id != 'default')
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.delete_outline,
                                                size: 20, color: Colors.red),
                                            const SizedBox(width: 8),
                                            Text(l10n.delete,
                                                style: const TextStyle(
                                                    color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                          onTap: isLocked
                              ? () => PremiumGate.showPremiumDialog(context)
                              : (isActive
                                  ? null
                                  : () =>
                                      _switchBusiness(context, ref, business)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFloatingActionButton(
            heroTag: 'add_cloud_business',
            backgroundColor: theme.colorScheme.secondaryContainer,
            onPressed: () async {
              if (!PremiumGate.isPremium(ref)) {
                PremiumGate.showPremiumDialog(context);
                return;
              }
              final notifier = ref.read(backupProvider.notifier);
              if (ref.read(backupProvider).currentUser == null) {
                final success = await notifier.signInIfNeeded();
                if (!success) return; // Sign in failed or cancelled
              }
              if (context.mounted) {
                _showCloudSelectionSheet(context, ref);
              }
            },
            tooltip: l10n.addFromCloud,
            child: Icon(Icons.cloud_download,
                color: theme.colorScheme.onSecondaryContainer),
          ),
          const SizedBox(width: 16),
          AppFloatingActionButton(
            heroTag: 'add_local_business',
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
    // Refresh available businesses from cloud before showing
    ref.read(backupProvider.notifier).loadAvailableCashbooks();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CloudBusinessSelectionSheet(),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBusinessSheet(),
    );
  }

  void _switchBusiness(BuildContext context, WidgetRef ref, Business business) async {
    final l10n = AppLocalizations.of(context)!;
    
    // 1. Calculate summary for CURRENT business before switching
    try {
      final currentDb = ref.read(databaseProvider);
      final currentBusiness = ref.read(activeBusinessProvider);
      final prefs = ref.read(sharedPreferencesProvider);
      
      if (kDebugMode) {
        print('BusinessesScreen: Updating summary for ${currentBusiness.name} before switch');
      }
      
      // We must ensure the database is fully initialized before calculating
      await currentDb.customSelect('SELECT 1').getSingle();
      
      await BusinessSummaryService.calculateAndUpdate(prefs, currentDb, currentBusiness);
    } catch (e) {
      if (kDebugMode) print('Error updating summary before switch: $e');
    }

    // 2. Perform the switch
    ref.read(activeBusinessIdProvider.notifier).setActive(business.id);
    ToastUtils.showSuccessToast(
        context, ref, l10n.switchedToCashbook(business.name));
  }

  void _handleAction(
      BuildContext context, WidgetRef ref, String action, Business business) {
    if (action == 'edit') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddBusinessSheet(business: business),
      );
    } else if (action == 'backup') {
      _showBackupOptions(context, ref, business);
    } else if (action == 'restore_local') {
      _showRestoreOptions(context, ref, business);
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
          targetBusinessId: business.id,
        ),
      );
    } else if (action == 'clear') {
      _showClearConfirmation(context, ref, business);
    } else if (action == 'clear_cloud') {
      _showClearCloudDialog(context, ref, business);
    } else if (action == 'delete') {
      _showDeleteConfirmation(context, ref, business);
    }
  }

  void _showRestoreOptions(
      BuildContext context, WidgetRef ref, Business business) {
    final activeId = ref.read(activeBusinessIdProvider);
    final l10n = AppLocalizations.of(context)!;

    if (business.id == activeId) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.information),
          content: Text(l10n.cannotRestoreActiveCashbook),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
      return;
    }

    if (!PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }

    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.restoreOptionsTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.targetLabel}: ${business.name}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildBackupOption(
              context,
              icon: Icons.cloud_download_outlined,
              title: l10n.restoreFromCloud,
              subtitle: l10n.restoreFromCloudSubtitle,
              color: Colors.blue,
              onTap: () async {
                Navigator.pop(context);
                final notifier = ref.read(backupProvider.notifier);
                if (ref.read(backupProvider).currentUser == null) {
                  final success = await notifier.signInIfNeeded();
                  if (!success) return; // Sign in failed or cancelled
                }
                if (context.mounted) {
                  _showCloudRestoreSelection(context, ref, business);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildBackupOption(
              context,
              icon: Icons.file_download_outlined,
              title: l10n.restoreFromFile,
              subtitle: l10n.restoreFromFileSubtitle,
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _handleRestore(context, ref, business);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCloudRestoreSelection(
      BuildContext context, WidgetRef ref, Business business) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // 1. First, show a selection of all available cloud businesses
    ref.read(backupProvider.notifier).loadAvailableCashbooks();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String? expandedCloudId; // Local state for expansion

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: StatefulBuilder(builder: (context, setState) {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          l10n.selectCloudFolder,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.selectCloudFolderSubtitle,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final state = ref.watch(backupProvider);
                        if (state.isLoading && expandedCloudId == null) {
                          return const Center(
                              child: AppLoadingIndicator(size: 50));
                        }
                        if (state.availableCashbookIds.isEmpty) {
                          return Center(child: Text(l10n.noCloudFoldersFound));
                        }
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: state.availableCashbookIds.length,
                          padding: EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            MediaQuery.of(context).padding.bottom + 16,
                          ),
                          itemBuilder: (context, index) {
                            final cloudId = state.availableCashbookIds[index];
                            final metadata = state.cashbookMetadata[cloudId];
                            final name = metadata?.name ?? cloudId;
                            final color = metadata != null
                                ? Color(int.parse(
                                    metadata.color.replaceFirst('#', '0xFF')))
                                : Colors.grey;
                            final icon = metadata != null
                                ? IconHelper.getIconData(metadata.icon)
                                : Icons.folder_outlined;

                            final isExpanded = expandedCloudId == cloudId;

                            Widget trailingWidget;
                            if (isExpanded && state.isLoading) {
                              trailingWidget = const SizedBox(
                                width: 24,
                                height: 24,
                                child: AppLoadingIndicator(size: 24),
                              );
                            } else {
                              trailingWidget = Icon(isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more);
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                        color: isExpanded
                                            ? color
                                            : theme.dividerColor),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          color.withValues(alpha: 0.1),
                                      child: Icon(icon, color: color),
                                    ),
                                    title: Text(name),
                                    subtitle: Text(cloudId == 'default'
                                        ? 'Main Business'
                                        : 'Additional Business'),
                                    trailing: trailingWidget,
                                    onTap: () {
                                      if (isExpanded) {
                                        setState(() => expandedCloudId = null);
                                      } else {
                                        setState(
                                            () => expandedCloudId = cloudId);
                                        ref
                                            .read(backupProvider.notifier)
                                            .loadBackupsForCashbook(cloudId);
                                      }
                                    },
                                  ),
                                ),
                                if (isExpanded && !state.isLoading)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, bottom: 16),
                                    child: _buildBackupListInline(
                                        context, ref, business, cloudId, name),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildBackupListInline(BuildContext context, WidgetRef ref,
      Business targetBusiness, String cloudBusinessId, String cloudName) {
    final state = ref.watch(backupProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (state.backups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(l10n.noBackupsFound, style: theme.textTheme.bodySmall),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '${l10n.targetLabel}: ${targetBusiness.name}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...state.backups.map((backup) {
          final date = backup.createdTime != null
              ? AppDateFormatter.formatDateTime(backup.createdTime!.toLocal())
              : 'Unknown Date';
          final size = backup.size != null
              ? '${(int.parse(backup.size!) / 1024 / 1024).toStringAsFixed(2)} MB'
              : 'Unknown Size';

          return Card(
            margin: const EdgeInsets.only(bottom: 8, right: 8),
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.cloud_download,
                  color: Colors.blue, size: 20),
              title: Text(date, style: const TextStyle(fontSize: 13)),
              subtitle: Text(size, style: const TextStyle(fontSize: 11)),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(l10n.restore),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.restoreBackupMessage),
                        const SizedBox(height: 12),
                        Text(
                          '${l10n.targetLabel}: ${targetBusiness.name}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(l10n.cancel),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                            foregroundColor: theme.colorScheme.onPrimary),
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(l10n.restore),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final rootNavigator =
                      Navigator.of(context, rootNavigator: true);
                  final backupId = backup.id!;
                  final targetId = targetBusiness.id;
                  final backupNotifier = ref.read(backupProvider.notifier);

                  // Close the single sheet
                  Navigator.of(context).pop();

                  final rootContext = rootNavigator.context;
                  if (rootContext.mounted) {
                    ToastUtils.showInfoToast(
                        rootContext, ref, l10n.backgroundRestoreStarted);
                  }

                  unawaited(() async {
                    try {
                      await backupNotifier.restoreToCashbook(backupId, targetId,
                          l10n: l10n);
                    } catch (e) {
                      if (kDebugMode) print('Cloud restore failed: $e');
                      if (rootContext.mounted) {
                        ToastUtils.showErrorToast(
                            rootContext,
                            ref,
                            l10n.errorOccurred(
                                e.toString().replaceAll('Exception: ', '')));
                      }
                    }
                  }());
                }
              },
            ),
          );
        }),
      ],
    );
  }

  void _showBackupOptions(
      BuildContext context, WidgetRef ref, Business business) {
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
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
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
            const SizedBox(height: 8),
            Text(
              '${l10n.sourceLabel}: ${business.name}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
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
                final screenContext = context;

                if (backupState.isBackingUp) {
                  ToastUtils.showInfoToast(screenContext, ref, l10n.processing);
                  return;
                }

                // If not signed in, attempt to sign in
                if (backupState.currentUser == null) {
                  final success = await backupNotifier.signInIfNeeded();
                  if (!success) {
                    return; // Sign in failed or cancelled
                  }
                }

                if (screenContext.mounted) {
                  ToastUtils.showInfoToast(
                      screenContext, ref, l10n.backgroundBackupStarted);
                }

                () async {
                  try {
                    await backupNotifier.backup(l10n, targetCashbook: business);
                  } catch (e) {
                    if (screenContext.mounted) {
                      ToastUtils.showErrorToast(
                          screenContext,
                          ref,
                          l10n.errorOccurred(
                              e.toString().replaceAll('Exception: ', '')));
                    }
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
                _handleBackup(context, ref, business);
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
      BuildContext context, WidgetRef ref, Business business) async {
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
        child: AppLoadingIndicator(size: 50),
      ),
    );

    try {
      final filePath = await LocalBackupService.prepareBackupFile(business);

      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        Navigator.pop(context); // Close loading

        if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
          final fileName = filePath.split(Platform.pathSeparator).last;
          final selector.FileSaveLocation? result =
              await selector.getSaveLocation(
            suggestedName: fileName,
            acceptedTypeGroups: [
              const selector.XTypeGroup(
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
      BuildContext context, WidgetRef ref, Business business) async {
    if (!PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    try {
      if (kDebugMode)
        print(
            '[BusinessesScreen] Starting local restore process for: ${business.name}');
      final file = await LocalBackupService.pickBackupFile();

      if (file == null) {
        if (kDebugMode) print('[BusinessesScreen] No file selected, aborting');
        return;
      }

      if (kDebugMode) print('[BusinessesScreen] File selected: ${file.path}');

      if (!rootContext.mounted) {
        if (kDebugMode)
          print(
              '[BusinessesScreen] Error: Root context unmounted after file picking');
        return;
      }

      final confirmed = await showDialog<bool>(
        context: rootContext,
        barrierDismissible: false,
        builder: (dialogContext) {
          final theme = Theme.of(dialogContext);
          return AlertDialog(
            title: Text(l10n.restore),
            content: Text(l10n.restoreBackupMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    foregroundColor: theme.colorScheme.onPrimary),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.restore),
              ),
            ],
          );
        },
      );

      if (kDebugMode)
        print('[BusinessesScreen] Restore confirmation: $confirmed');

      if (confirmed == true) {
        if (rootContext.mounted) {
          if (kDebugMode)
            print('[BusinessesScreen] Showing background restore toast');
          ToastUtils.showInfoToast(
              rootContext, ref, l10n.backgroundRestoreStarted);
        }

        final notifier = ref.read(businessesProvider.notifier);
        final targetId = business.id;
        final targetName = business.name;

        unawaited(() async {
          try {
            if (kDebugMode)
              print('[BusinessesScreen] Calling restoreBusinessFromFile...');
            await notifier.restoreBusinessFromFile(targetId, file);

            if (kDebugMode)
              print('[BusinessesScreen] Restore logic completed successfully');
            if (rootContext.mounted) {
              ToastUtils.showSuccessToast(
                  rootContext, ref, l10n.restoreSuccessfulFor(targetName));
            }
          } catch (e) {
            if (kDebugMode)
              print('[BusinessesScreen] Error during background restore: $e');
            if (rootContext.mounted) {
              ToastUtils.showErrorToast(
                  rootContext, ref, l10n.errorOccurred(e.toString()));
            }
          }
        }());
      }
    } catch (e) {
      if (kDebugMode)
        print('[BusinessesScreen] Exception in _handleRestore: $e');
      if (rootContext.mounted) {
        ToastUtils.showErrorToast(
            rootContext, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  void _showClearConfirmation(
      BuildContext context, WidgetRef ref, Business business) {
    final l10n = AppLocalizations.of(context)!;
    final screenContext = context;
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
          content: Text(l10n.confirmDelete(business.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await ref.read(businessesProvider.notifier).clearBusinessData(
                    business.id,
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
      BuildContext context, WidgetRef ref, Business business) async {
    final l10n = AppLocalizations.of(context)!;
    final screenContext = context;
    final backupState = ref.watch(backupProvider);
    final backupNotifier = ref.read(backupProvider.notifier);

    // Check premium first
    if (!PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }

    // If not signed in, attempt to sign in
    if (backupState.currentUser == null) {
      final success = await backupNotifier.signInIfNeeded();
      if (!success) {
        return; // Sign in failed or cancelled
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool clearBackups = false;
        bool clearSync = false;
        bool clearDocuments = false;

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
                Text(l10n.clearCloudMessage(business.name)),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(l10n.clearBackups),
                  subtitle: Text(l10n.clearBackupsSubtitle),
                  value: clearBackups,
                  onChanged: (val) =>
                      setState(() => clearBackups = val ?? false),
                  activeColor: Colors.orange,
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: Text(l10n.clearDocuments),
                  subtitle: Text(l10n.clearDocumentsSubtitle),
                  value: clearDocuments,
                  onChanged: (val) =>
                      setState(() => clearDocuments = val ?? false),
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
                onPressed: (!clearBackups && !clearSync && !clearDocuments)
                    ? null
                    : () {
                        Navigator.pop(dialogContext);
                        if (screenContext.mounted) {
                          ToastUtils.showInfoToast(screenContext, ref,
                              l10n.backgroundCloudClearStarted);
                        }

                        () async {
                          try {
                            await ref
                                .read(backupProvider.notifier)
                                .clearGranularCloudData(business.id,
                                    clearBackups: clearBackups,
                                    clearSync: clearSync,
                                    clearDocuments: clearDocuments);
                          } catch (e) {
                            // Already handled
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
      BuildContext context, WidgetRef ref, Business business) {
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
            Text(l10n.deleteCashbookMessage(business.name)),
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
              ref.read(businessesProvider.notifier).deleteBusiness(business.id);
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
