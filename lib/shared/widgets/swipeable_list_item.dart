import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Swipeable list item widget with Gmail-style swipe-to-reveal actions
/// Swipe left to reveal delete action, swipe right to reveal edit action
class SwipeableListItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool enableEdit;
  final bool enableDelete;
  final Color editBackgroundColor;
  final Color deleteBackgroundColor;
  final IconData editIcon;
  final IconData deleteIcon;
  final String? editLabel;
  final String? deleteLabel;
  final double borderRadius;
  final EdgeInsetsGeometry? backgroundMargin;

  const SwipeableListItem({
    super.key,
    required this.child,
    this.onEdit,
    this.onDelete,
    this.enableEdit = true,
    this.enableDelete = true,
    this.editBackgroundColor = Colors.blue,
    this.deleteBackgroundColor = Colors.red,
    this.editIcon = Icons.edit,
    this.deleteIcon = Icons.delete,
    this.editLabel,
    this.deleteLabel,
    this.borderRadius = 16.0,
    this.backgroundMargin,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // If both actions are disabled, return child without swipe functionality
    if (!enableEdit && !enableDelete) {
      return child;
    }

    return Dismissible(
      key: key ?? UniqueKey(),
      confirmDismiss: (direction) async {
        // Add haptic feedback
        HapticFeedback.mediumImpact();

        // We keep the logical directions fixed:
        // startToEnd (Left-to-Right in LTR, Right-to-Left in RTL) always triggers Edit
        // endToStart (Right-to-Left in LTR, Left-to-Right in RTL) always triggers Delete
        // Since we used AlignmentDirectional for the backgrounds, they also flip.
        // This means in RTL, swiping from right (start) reveals Edit on the right, 
        // and swiping from left (end) reveals Delete on the left.

        if (direction == DismissDirection.endToStart && enableDelete) {
          // Delete action (Right-to-Left in LTR, Left-to-Right in RTL)
          final confirmed = await _showConfirmDialog(
            context,
            title: l10n.deleteItem,
            message: l10n.confirmDeleteItem,
            confirmText: l10n.delete,
            confirmColor: deleteBackgroundColor,
          );

          if (confirmed == true && onDelete != null) {
            onDelete!();
          }
          return false; // Don't dismiss, let the parent handle the deletion
        } else if (direction == DismissDirection.startToEnd && enableEdit) {
          // Edit action (Left-to-Right in LTR, Right-to-Left in RTL)
          if (onEdit != null) {
            onEdit!();
          }
          return false; // Don't dismiss
        }

        return false;
      },
      background: enableEdit
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                alignment: AlignmentDirectional.centerStart,
                margin: backgroundMargin,
                padding: const EdgeInsetsDirectional.only(start: 20),
                decoration: BoxDecoration(
                  color: editBackgroundColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      editIcon,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : editBackgroundColor,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      editLabel ?? l10n.edit,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : editBackgroundColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      secondaryBackground: enableDelete
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                alignment: AlignmentDirectional.centerEnd,
                margin: backgroundMargin,
                padding: const EdgeInsetsDirectional.only(end: 20),
                decoration: BoxDecoration(
                  color: deleteBackgroundColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      deleteIcon,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : deleteBackgroundColor,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deleteLabel ?? l10n.delete,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : deleteBackgroundColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      child: child,
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
