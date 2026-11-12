import 'package:flutter/material.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

/// Small corner badge matching transaction list items.
class PendingSyncCornerBadge extends StatelessWidget {
  final double iconSize;

  const PendingSyncCornerBadge({super.key, this.iconSize = 12});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.cloud_upload_outlined,
        size: iconSize,
        color: Colors.orange,
      ),
    );
  }
}

/// Orange corner badge matching transaction details heroes.
class PendingSyncDetailBadge extends StatelessWidget {
  const PendingSyncDetailBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Tooltip(
      message: l10n.pendingSync,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.cloud_upload_outlined,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
