import 'package:flutter/material.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';

/// A centralized, elevated, non-transparent pill that shows when a transaction was updated.
/// Displays an update icon and relative time within a styled orange border.
class RecentUpdatePill extends StatelessWidget {
  final DateTime updatedAt;
  final bool isCompact;

  const RecentUpdatePill({
    super.key,
    required this.updatedAt,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.orange.withValues(alpha: isDark ? 0.4 : 0.3),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.update_rounded,
            size: isCompact ? 10 : 12,
            color: Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            AppDateFormatter.formatRelativeTime(updatedAt, context),
            style: TextStyle(
              fontSize: isCompact ? 8.5 : 10,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
