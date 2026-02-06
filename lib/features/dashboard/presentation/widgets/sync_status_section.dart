import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/backup/presentation/screens/backup_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';

class SyncStatusSection extends ConsumerWidget {
  const SyncStatusSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupState = ref.watch(backupProvider);
    final isPremium = PremiumGate.isPremium(ref);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isSyncing = backupState.syncStatus == 'Syncing...';
    final bool hasUnsynced = backupState.unsyncedCount > 0;
    final bool hasCloudUpdates = backupState.cloudVersion > backupState.localVersion;
    final bool isSignedIn = backupState.currentUser != null;

    // Hide section if nothing to sync and no updates available
    if (!isSyncing && !hasUnsynced && !hasCloudUpdates) {
      return const SizedBox.shrink();
    }

    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (isSyncing) {
      statusText = l10n.processing;
      statusIcon = Symbols.sync;
      statusColor = theme.colorScheme.primary;
    } else if (hasUnsynced && hasCloudUpdates) {
      statusText = l10n.synchronization; // "Sync needed" fallback
      statusIcon = Symbols.sync_problem;
      statusColor = AppColors.error;
    } else if (hasUnsynced) {
      statusText = l10n.changesToPush(backupState.unsyncedCount);
      statusIcon = Symbols.cloud_upload;
      statusColor = theme.colorScheme.primary;
    } else if (hasCloudUpdates) {
      statusText = l10n.updatesAvailable;
      statusIcon = Symbols.cloud_download;
      statusColor = theme.colorScheme.secondary;
    } else {
      statusText = l10n.dataSynced;
      statusIcon = Symbols.cloud_done;
      statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: AppLoadingIndicator(size: 16),
                  )
                : Icon(
                    statusIcon,
                    color: statusColor,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.syncStatusTitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  statusText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (isPremium && isSignedIn) {
                ref.read(backupProvider.notifier).triggerSync(l10n);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BackupScreen(),
                  ),
                );
              }
            },
            icon: Icon(
              isSyncing ? Symbols.sync : Symbols.sync,
              color: theme.colorScheme.primary,
            ),
            tooltip: l10n.syncNow,
          ),
        ],
      ),
    );
  }
}
