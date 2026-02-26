import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/backup/presentation/screens/backup_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
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
      duration: const Duration(milliseconds: 500),
    );

    // Scale animation with stronger bounce effect
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_animationController);

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
    final activeCashbookId = ref.watch(activeCashbookIdProvider);
    
    // Ignore cross-cashbook status updates by returning early if the 
    // sync state does not belong to the currently active cashbook.
    if (backupState.selectedCloudCashbookId != null && 
        backupState.selectedCloudCashbookId != activeCashbookId) {
      if (_animationController.value != 0) {
        _animationController.reset();
      }
      return const SizedBox.shrink();
    }

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

    // Recalculate these values on every build to ensure reactivity
    final int localVer = backupState.localVersion;
    final int cloudVer = backupState.cloudVersion;
    final int updatesCount = cloudVer - localVer;
    final bool hasCloudUpdates = updatesCount > 0;

    final bool isSignedIn = backupState.currentUser != null;

    if (kDebugMode && (isSyncing || isSuccess || hasUnsynced || hasCloudUpdates)) {
      print('[SyncStatusSection] Active Cashbook: $activeCashbookId');
      print('[SyncStatusSection] Sync Status: ${backupState.syncStatus}');
      print('[SyncStatusSection] Local Ver: $localVer | Cloud Ver: $cloudVer');
      print('[SyncStatusSection] Unsynced Count: ${backupState.unsyncedCount}');
    }
    
    // Hide section if nothing to sync, no updates available, and not in success/syncing state
    if (!isSyncing && !isSuccess && !hasUnsynced && !hasCloudUpdates) {
      if (_animationController.value != 0) {
        _animationController.reset();
      }
      return const SizedBox.shrink();
    }

    // Start animation if it hasn't started yet
    if (_animationController.status == AnimationStatus.dismissed) {
      _animationController.forward();
    }

    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (isSyncing) {
      statusText = l10n.processing;
      statusIcon = Symbols.sync;
      statusColor = theme.colorScheme.primary;
    } else if (hasUnsynced) {
      statusText = l10n.changesToPush(backupState.unsyncedCount);
      statusIcon = Symbols.cloud_upload;
      statusColor = Colors.orange;
    } else if (hasCloudUpdates) {
      statusText = updatesCount == 1
          ? l10n.oneUpdateAvailable
          : l10n.multipleUpdatesAvailable(updatesCount);
      statusIcon = Symbols.cloud_download;
      statusColor = Colors.lightBlue;
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
              if ((hasUnsynced || hasCloudUpdates) && !isSyncing)
                Container(
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      if (isPremium) {
                        if (isSignedIn) {
                          ref.read(backupProvider.notifier).triggerSync(l10n);
                        } else {
                          final success = await ref.read(backupProvider.notifier).signInIfNeeded();
                          if (success) {
                            ref.read(backupProvider.notifier).triggerSync(l10n);
                          }
                        }
                      } else {
                        PremiumGate.showPremiumDialog(context);
                      }
                    },
                    icon: Icon(
                      Symbols.sync,
                      color: statusColor,
                      size: 24,
                    ),
                    tooltip: l10n.syncNow,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              if (isSuccess && !hasUnsynced && !hasCloudUpdates)
                Icon(
                  Symbols.check_circle,
                  color: statusColor.withValues(alpha: 0.7),
                  size: 28,
                ),
              if (isSyncing)
                Icon(
                  Symbols.clock_loader_20_rounded,
                  color: statusColor.withValues(alpha: 0.7),
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
