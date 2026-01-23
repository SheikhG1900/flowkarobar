import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/backup/data/sync/sync_scheduler.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
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
          // Content (Always rendered but maybe blurred)
          state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                        _buildSyncSection(context, state, l10n),
                        const SizedBox(height: 24),
                        _buildBackupControls(context, state, notifier, l10n),
                        const SizedBox(height: 24),
                        _buildBackupsList(context, state, notifier, l10n),
                      ],
                    ],
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
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
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
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.synchronization,
          style: theme.textTheme.titleLarge,
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
                        Text(
                          l10n.syncActive,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.syncDescription,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: l10n.syncNow,
                gradient: AppColors.getPrimaryGradient(theme.colorScheme.primary),
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
        Text(
          l10n.backup, // Using backupNow as header too or we can add "Backup"
          style: theme.textTheme.titleLarge,
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
                        l10n.lastBackupAt(AppDateFormatter.formatDate(
                                state.lastBackupTime!,
                                pattern: ref
                                    .watch(userProfileProvider)
                                    .dateFormat)),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              GradientButton(
                label: l10n.backupNow,
                gradient:
                    AppColors.getSecondaryGradient(theme.colorScheme.primary),
                icon: Icons.backup,
                onPressed: () => notifier.backup(),
              ),
            ],
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

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(AppDateFormatter.formatDate(
                    file.createdTime ?? DateTime.now(),
                    pattern: ref.watch(userProfileProvider).dateFormat)),
                subtitle: Text('${file.name} • $sizeMb MB'),
                trailing: IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () =>
                      _showRestoreDialog(context, notifier, file.id!, l10n),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showRestoreDialog(
    BuildContext context,
    BackupNotifier notifier,
    String fileId,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreBackupTitle),
        content: Text(l10n.restoreBackupMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await notifier.restore(fileId);
                if (context.mounted) {
                  _showPostRestoreOptions(context, notifier, l10n);
                }
              } catch (e) {
                if (context.mounted) {
                  ToastUtils.showErrorToast(
                      context, ref, l10n.restoreFailed(e.toString()));
                }
              }
            },
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
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
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sync_problem, size: 20, color: theme.colorScheme.primary),
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
                            ToastUtils.showSuccessToast(context, ref, l10n.syncManifestReset);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ToastUtils.showErrorToast(context, ref, l10n.failedToResetSync(e.toString()));
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
