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
  final String editLabel;
  final String deleteLabel;
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
    this.editLabel = 'Edit',
    this.deleteLabel = 'Delete',
    this.borderRadius = 16.0,
    this.backgroundMargin,
  });

  @override
  Widget build(BuildContext context) {
    // If both actions are disabled, return child without swipe functionality
    if (!enableEdit && !enableDelete) {
      return child;
    }

    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: (direction) async {
        // Add haptic feedback
        HapticFeedback.mediumImpact();

        if (direction == DismissDirection.endToStart && enableDelete) {
          // Swipe left to delete
          final confirmed = await _showConfirmDialog(
            context,
            title: 'Delete Item',
            message: 'Are you sure you want to delete this item?',
            confirmText: 'Delete',
            confirmColor: deleteBackgroundColor,
          );

          if (confirmed == true && onDelete != null) {
            onDelete!();
          }
          return false; // Don't dismiss, let the parent handle the deletion
        } else if (direction == DismissDirection.startToEnd && enableEdit) {
          // Swipe right to edit
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
                alignment: Alignment.centerLeft,
                margin: backgroundMargin,
                padding: const EdgeInsets.only(left: 20),
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
                      editLabel,
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
                alignment: Alignment.centerRight,
                margin: backgroundMargin,
                padding: const EdgeInsets.only(right: 20),
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
                      deleteLabel,
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
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: confirmColor,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
