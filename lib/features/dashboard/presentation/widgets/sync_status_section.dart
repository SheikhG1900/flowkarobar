import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/backup/presentation/screens/backup_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';

class SyncStatusSection extends ConsumerStatefulWidget {
  const SyncStatusSection({super.key});

  @override
  ConsumerState<SyncStatusSection> createState() => _SyncStatusSectionState();
}

class _SyncStatusSectionState extends ConsumerState<SyncStatusSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Scale animation with bounce effect
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Start animation after a small delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backupState = ref.watch(backupProvider);
    final isPremium = PremiumGate.isPremium(ref);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isSyncing = backupState.syncStatus == 'Syncing...' ||
        backupState.syncStatus == 'Processing...' ||
        backupState.syncStatus == 'Pulling...' ||
        backupState.syncStatus == 'Pushing...';
    final bool isSuccess = backupState.syncStatus == 'Success';
    final bool hasUnsynced = backupState.unsyncedCount > 0;
    final bool hasCloudUpdates =
        backupState.cloudVersion > backupState.localVersion;
    final bool isSignedIn = backupState.currentUser != null;

    // Hide section if nothing to sync, no updates available, and not in success/syncing state
    if (!isSyncing && !isSuccess && !hasUnsynced && !hasCloudUpdates) {
      // Reset animation when hiding
      if (_animationController.isAnimating || _animationController.value > 0) {
        _animationController.reset();
      }
      return const SizedBox.shrink();
    }

    // Restart animation when section appears
    if (!_animationController.isAnimating && _animationController.value == 0) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _animationController.forward();
        }
      });
    }

    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (isSyncing) {
      statusText = l10n.processing;
      statusIcon = Symbols.sync;
      statusColor = theme.colorScheme.primary;
    } else if (isSuccess) {
      statusText = l10n.dataSynced;
      statusIcon = Symbols.check_circle;
      statusColor = Colors.green;
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

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withValues(alpha: isDark ? 0.3 : 0.1),
                statusColor.withValues(alpha: isDark ? 0.4 : 0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withValues(alpha: 0.3),
                      statusColor.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSyncing
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: AppLoadingIndicator(size: 24),
                      )
                    : Icon(
                        statusIcon,
                        color: statusColor,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.syncStatusTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (!isSuccess)
                Container(
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
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
                      color: statusColor,
                      size: 24,
                    ),
                    tooltip: l10n.syncNow,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              if (isSuccess)
                Icon(
                  Symbols.check_circle,
                  color: Colors.green.withValues(alpha: 0.7),
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
