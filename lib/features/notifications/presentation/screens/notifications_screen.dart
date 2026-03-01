import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/notifications/presentation/providers/notification_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        centerTitle: true,
        actions: [
          if (notifications.isNotEmpty) ...[
            TextButton(
              onPressed: () {
                notifier.markAllAsRead();
                ToastUtils.showSuccessToast(
                    context, ref, l10n.allNotificationsMarkedRead);
              },
              child: Text(l10n.markAllRead),
            ),
          ],
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context, theme, l10n)
          : _buildNotificationsList(context, theme, notifications, notifier),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: notifications.isNotEmpty
          ? AppFloatingActionButton(
              onPressed: () => _showClearConfirmation(context, ref, l10n),
              backgroundColor: Colors.red.withValues(alpha: 0.9),
              foregroundColor: Colors.white,
              tooltip: l10n.clearAll,
              child: const Icon(Icons.delete_sweep_outlined),
            )
          : null,
    );
  }

  Widget _buildEmptyState(
      BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient:
                    AppColors.getPrimaryGradient(theme.colorScheme.primary),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.noNotifications,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noNotificationsDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      l10n.notificationsTip,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    ThemeData theme,
    List<NotificationItem> notifications,
    NotificationNotifier notifier,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationCard(
          notification: notification,
          onTap: () => notifier.markAsRead(notification.id),
        );
      },
    );
  }

  void _showClearConfirmation(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearAllNotifications),
        content: Text(l10n.clearAllNotificationsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(notificationProvider.notifier).clearAll();
              ToastUtils.showSuccessToast(
                  context, ref, l10n.notificationsCleared);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.clearAll),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.receivable:
        return Icons.arrow_downward;
      case NotificationType.payable:
        return Icons.arrow_upward;
      case NotificationType.milestone:
        return Icons.emoji_events;
      case NotificationType.backup:
        return Icons.cloud_upload;
      case NotificationType.reminder:
        return Icons.notifications;
      case NotificationType.sync:
        return Icons.sync;
    }
  }

  Color _getColor(ThemeData theme) {
    switch (notification.type) {
      case NotificationType.receivable:
        return AppColors.receivableColor;
      case NotificationType.payable:
        return AppColors.payableColor;
      case NotificationType.milestone:
        return Colors.amber;
      case NotificationType.backup:
        return theme.colorScheme.primary;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.sync:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = _getColor(theme);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: (notification.isUrgent == true) && (notification.isRead == false)
            ? color.withValues(alpha: 0.15)
            : (notification.isRead == true
                ? theme.cardColor
                : color.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              (notification.isUrgent == true) && (notification.isRead == false)
                  ? color
                  : (notification.isRead == true
                      ? theme.dividerColor.withValues(alpha: 0.1)
                      : color.withValues(alpha: 0.2)),
          width:
              (notification.isUrgent == true) && (notification.isRead == false)
                  ? 2.5
                  : (notification.isRead == true ? 1 : 2),
        ),
        boxShadow: [
          BoxShadow(
            color: (notification.isUrgent == true) &&
                    (notification.isRead == false)
                ? color.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: (notification.isUrgent == true) &&
                    (notification.isRead == false)
                ? 12
                : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              if ((notification.isUrgent == true) &&
                  (notification.isRead == false))
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(14),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.urgent,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getIcon(),
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if ((notification.isRead == false) &&
                                  (notification.isUrgent == false))
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: (notification.isUrgent == true) &&
                                      (notification.isRead == false)
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateTime(
                                    notification.dateTime, ref, l10n, context),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
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
  }

  String _formatDateTime(DateTime dateTime, WidgetRef ref,
      AppLocalizations l10n, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return AppDateFormatter.formatDate(dateTime);
    }
  }
}
