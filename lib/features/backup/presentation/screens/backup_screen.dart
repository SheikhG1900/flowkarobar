import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/backup/data/sync/sync_scheduler.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:flowpaisa/shared/widgets/glass_card.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/premium_badge.dart';
import 'dart:ui';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(backupProvider);
    final notifier = ref.read(backupProvider.notifier);
    final isPremium = PremiumGate.isPremium(ref);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final activeCashbook = ref.watch(activeCashbookProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.googleDrive),
            const SizedBox(width: 8),
            if (!isPremium) const PremiumBadge(isSmall: true, showLock: true),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Auth Section
                  _buildAuthSection(context, state, notifier, l10n),

                  if (state.currentUser != null) ...[
                    const SizedBox(height: 24),
                    _buildCashbookHeader(context, theme),
                    const SizedBox(height: 24),
                    _buildSyncSection(context, state, notifier, l10n),
                    const SizedBox(height: 24),
                    _buildBackupControls(context, state, notifier, l10n),
                    const SizedBox(height: 24),
                    _buildCloudCashbooks(context, state, notifier, l10n),
                    const SizedBox(height: 24),
                    _buildBackupsList(context, state, notifier, l10n),
                  ],
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (state.isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              activeCashbook.color),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Processing...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: activeCashbook.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Premium Lock Overlay
          if (!isPremium)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFFA500)
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.cloud_upload_outlined,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.premiumFeature,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.cloudBackupPremiumDesc,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 15),
                            FilledButton(
                              onPressed: () =>
                                  PremiumGate.showPremiumDialog(context),
                              child: Text(l10n.unlockPremium),
                            ),
                          ],
                        ),
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

  Widget _buildCashbookHeader(BuildContext context, ThemeData theme) {
    final activeCashbook = ref.watch(activeCashbookProvider);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activeCashbook.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              activeCashbook.icon,
              color: activeCashbook.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.activeCashbook,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  activeCashbook.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.syncAndBackupApplyTo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthSection(
    BuildContext context,
    BackupState state,
    BackupNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    if (state.currentUser != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            GoogleUserCircleAvatar(
              identity: state.currentUser!,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.currentUser!.displayName ?? l10n.unknown,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    state.currentUser!.email,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => notifier.signOut(),
              tooltip: l10n.signOut,
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.signInGoogleToBackup,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: l10n.signInGoogle,
            gradient: AppColors.getPrimaryGradient(theme.colorScheme.primary),
            icon: Icons.login,
            onPressed: () => notifier.signIn(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.googleServicesNote,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSyncSection(
    BuildContext context,
    BackupState state,
    BackupNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.synchronization,
              style: theme.textTheme.titleLarge,
            ),
            DropdownButton<String>(
              value: state.syncInterval,
              items: [
                DropdownMenuItem(value: 'manual', child: Text(l10n.manual)),
                ...[12, 24, 36, 48, 60, 72, 84, 96].map((h) => DropdownMenuItem(
                      value: h.toString(),
                      child: Text('$h ${l10n.hours}'),
                    )),
              ],
              onChanged: (v) => v != null ? notifier.setSyncInterval(v) : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.sync, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.syncActive,
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (state.lastSyncTime != null)
                              Text(
                                l10n.lastSync(
                                    AppDateFormatter.formatRelativeTime(
                                        state.lastSyncTime!, context)),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.syncDescription,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.localVersion(state.localVersion),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.cloudVersion(state.cloudVersion),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: state.cloudVersion > state.localVersion
                                    ? Colors.orange
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight:
                                    state.cloudVersion > state.localVersion
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: l10n.syncNow,
                gradient:
                    AppColors.getPrimaryGradient(theme.colorScheme.primary)
                        .withOpacity(0.8),
                icon: Icons.sync,
                onPressed: () async {
                  await SyncScheduler.triggerOnDemandSync();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.syncTriggered)),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackupControls(
    BuildContext context,
    BackupState state,
    BackupNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.backup, // Using backupNow as header too or we can add "Backup"
              style: theme.textTheme.titleLarge,
            ),
            DropdownButton<String>(
              value: state.backupInterval,
              items: [
                DropdownMenuItem(value: 'manual', child: Text(l10n.manual)),
                DropdownMenuItem(value: 'weekly', child: Text(l10n.weekly)),
                DropdownMenuItem(value: 'monthly', child: Text(l10n.monthly)),
              ],
              onChanged: (v) =>
                  v != null ? notifier.setBackupInterval(v) : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.backupDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.lastBackupTime != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.history, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        l10n.lastBackupAt(AppDateFormatter.formatDateTime(
                            state.lastBackupTime!.toLocal())),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              GradientButton(
                label: l10n.backupNow,
                gradient:
                    AppColors.getSecondaryGradient(theme.colorScheme.primary)
                        .withOpacity(0.8),
                icon: Icons.backup,
                onPressed: () async {
                  print('Backup button pressed');
                  await notifier.backup();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCloudCashbooks(
    BuildContext context,
    BackupState state,
    BackupNotifier notifier,
    AppLocalizations l10n,
  ) {
    if (state.availableCashbookIds.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final activeCashbook = ref.watch(activeCashbookProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cloud Cashbooks',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.availableCashbookIds.length,
            itemBuilder: (context, index) {
              final id = state.availableCashbookIds[index];
              final metadata = state.cashbookMetadata[id];
              final name =
                  metadata?.name ?? (id == 'default' ? 'Main' : 'Cloud DB');
              final isSelected =
                  id == (state.selectedCloudCashbookId ?? activeCashbook.id);

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => notifier.loadBackupsForCashbook(id),
                  onLongPress: id == activeCashbook.id
                      ? null
                      : () => _showDeleteCloudCashbookDialog(
                          context, notifier, id, name),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? Icons.folder_open : Icons.folder,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : null,
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : null,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (id != 'default' && id != activeCashbook.id)
                          Text(
                            id.length > 8 ? id.substring(0, 8) : id,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 8,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackupsList(
    BuildContext context,
    BackupState state,
    BackupNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final activeCashbook = ref.watch(activeCashbookProvider);
    if (state.backups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(l10n.noBackupsFound),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.availableBackups,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => notifier.loadBackups(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.backups.length,
          itemBuilder: (context, index) {
            final file = state.backups[index];
            final sizeMb =
                (int.parse(file.size ?? '0') / 1024 / 1024).toStringAsFixed(2);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SwipeableListItem(
                enableEdit: true,
                enableDelete: true,
                editIcon: Icons.restore,
                editLabel: l10n.restore,
                editBackgroundColor: theme.colorScheme.primary,
                deleteBackgroundColor: theme.colorScheme.error,
                borderRadius: 16,
                onEdit: () => _showRestoreDialog(
                  context,
                  notifier,
                  file.id!,
                  l10n,
                  cashbookId:
                      state.selectedCloudCashbookId ?? activeCashbook.id,
                  cloudCashbookName: state
                      .cashbookMetadata[
                          state.selectedCloudCashbookId ?? activeCashbook.id]
                      ?.name,
                ),
                onDelete: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.delete),
                      content: Text(l10n.confirmDelete(l10n.backup)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.error),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.delete),
                        ),
                      ],
                    ),
                  );
                  if (result == true) {
                    await notifier.deleteBackup(file.id!);
                  }
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: activeCashbook.color.withValues(
                              alpha: theme.brightness == Brightness.dark
                                  ? 0.1
                                  : 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: activeCashbook.color.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.description_outlined,
                            color: activeCashbook.color),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppDateFormatter.formatDateTime(
                                  (file.createdTime ?? DateTime.now())
                                      .toLocal()),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${file.name} • $sizeMb MB',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showDeleteCloudCashbookDialog(
    BuildContext context,
    BackupNotifier notifier,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cloud Backups?'),
        content: Text(
          'This will permanently delete all backups and sync data for "$name" from Google Drive. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteCloudCashbook(id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(
    BuildContext context,
    BackupNotifier notifier,
    String fileId,
    AppLocalizations l10n, {
    String? cashbookId,
    String? cloudCashbookName,
  }) {
    final theme = Theme.of(context);
    final activeCashbook = ref.read(activeCashbookProvider);
    final localCashbooks = ref.read(cashbooksProvider);

    // Check if this cashbook ID exists locally
    final isLocallyAvailable =
        cashbookId != null && localCashbooks.any((c) => c.id == cashbookId);
    final isActive = cashbookId != null && cashbookId == activeCashbook.id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isActive
            ? l10n.restoreBackupTitle
            : (isLocallyAvailable
                ? l10n.overrideExistingCashbookTitle
                : l10n.restoreToNewCashbookTitle)),
        content: Text(isActive
            ? l10n.restoreBackupMessage
            : (isLocallyAvailable
                ? l10n.overrideExistingCashbookMessage(
                    cloudCashbookName ?? 'another cashbook',
                    activeCashbook.name)
                : l10n.restoreToNewCashbookMessage(
                    cloudCashbookName ?? 'another cashbook'))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          if (!isActive && isLocallyAvailable) ...[
            // Case: Different cashbook but exists locally -> Override ACTIVE
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Overriding ACTIVE cashbook with this cloud data (as requested)
                await _performRestore(context, notifier, fileId, l10n,
                    cashbookId: activeCashbook.id, isNew: false);
              },
              style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error),
              child: Text(l10n.restoreOptionOverride),
            ),
          ] else if (!isActive && !isLocallyAvailable) ...[
            // Case: Different cashbook and NOT local -> Override (active) and New
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Overriding ACTIVE cashbook with this cloud data
                await _performRestore(context, notifier, fileId, l10n,
                    cashbookId: activeCashbook.id, isNew: false);
              },
              style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error),
              child: Text(l10n.restoreOptionOverride),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performRestore(context, notifier, fileId, l10n,
                    cashbookId: cashbookId, isNew: true);
              },
              child: Text(l10n.restoreOptionNewEntry),
            ),
          ] else ...[
            // Case: Is Active -> Just Restore
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performRestore(context, notifier, fileId, l10n,
                    cashbookId: activeCashbook.id, isNew: false);
              },
              child: Text(l10n.restore),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _performRestore(
    BuildContext context,
    BackupNotifier notifier,
    String fileId,
    AppLocalizations l10n, {
    String? cashbookId,
    required bool isNew,
  }) async {
    try {
      if (cashbookId != null) {
        await notifier.restoreToCashbook(fileId, cashbookId);
      } else {
        await notifier.restore(fileId);
      }

      // Invalidate the database provider to force a fresh connection
      ref.invalidate(databaseProvider);
      // Also invalidate other related providers to refresh the UI
      ref.invalidate(activeCashbookProvider);

      if (context.mounted) {
        if (isNew) {
          final name =
              ref.read(backupProvider).cashbookMetadata[cashbookId]?.name ??
                  'Restored';
          ToastUtils.showSuccessToast(
              context, ref, l10n.restoreSuccessNew(name));
        } else {
          _showPostRestoreOptions(context, notifier, l10n);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.restoreFailed(e.toString()));
      }
    }
  }

  void _showPostRestoreOptions(
    BuildContext context,
    BackupNotifier notifier,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Text(l10n.restoreSuccessful),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.restoreSuccessfulMessage),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sync_problem,
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.syncRecovery,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.syncRecoveryDescription,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        try {
                          await notifier.resetSyncAfterRestore();
                          if (context.mounted) {
                            ToastUtils.showSuccessToast(
                                context, ref, l10n.syncManifestReset);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ToastUtils.showErrorToast(context, ref,
                                l10n.failedToResetSync(e.toString()));
                          }
                        }
                      },
                      icon: const Icon(Icons.restart_alt, size: 18),
                      label: Text(l10n.resetCloudSync),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
