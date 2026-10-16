import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Swipeable list item widget with Gmail-style swipe-to-reveal actions
/// Swipe left to reveal delete action, swipe right to reveal edit action
/// On desktop/web, it also displays a beautiful floating action capsule on hover.
class SwipeableListItem extends StatefulWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final List<Widget>? additionalHoverActions;
  final bool enableEdit;
  final bool enableDelete;
  final Color editBackgroundColor;
  final Color deleteBackgroundColor;
  final IconData editIcon;
  final IconData deleteIcon;
  final String? editLabel;
  final String? deleteLabel;
  final String? confirmTitle;
  final String? confirmMessage;
  final double borderRadius;
  final EdgeInsetsGeometry? backgroundMargin;
  final bool showHoverActions;

  const SwipeableListItem({
    super.key,
    required this.child,
    this.onEdit,
    this.onDelete,
    this.additionalHoverActions,
    this.enableEdit = true,
    this.enableDelete = true,
    this.editBackgroundColor = Colors.blue,
    this.deleteBackgroundColor = Colors.red,
    this.editIcon = Icons.edit,
    this.deleteIcon = Icons.delete,
    this.editLabel,
    this.deleteLabel,
    this.confirmTitle,
    this.confirmMessage,
    this.borderRadius = 16.0,
    this.backgroundMargin,
    this.showHoverActions = true,
  });

  @override
  State<SwipeableListItem> createState() => _SwipeableListItemState();
}

class _SwipeableListItemState extends State<SwipeableListItem> {
  bool _isHovered = false;
  late Key _dismissibleKey;

  @override
  void initState() {
    super.initState();
    _dismissibleKey = widget.key ?? (widget.child.key ?? UniqueKey());
  }

  @override
  void didUpdateWidget(SwipeableListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.key != oldWidget.key || widget.child.key != oldWidget.child.key) {
      _dismissibleKey = widget.key ?? (widget.child.key ?? _dismissibleKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // If both actions are disabled, return child without swipe functionality
    if (!widget.enableEdit && !widget.enableDelete) {
      return widget.child;
    }

    Widget swipeable = Dismissible(
      key: _dismissibleKey,
      confirmDismiss: (direction) async {
        // Add haptic feedback
        HapticFeedback.mediumImpact();

        // We keep the logical directions fixed:
        // startToEnd (Left-to-Right in LTR, Right-to-Left in RTL) always triggers Edit
        // endToStart (Right-to-Left in LTR, Left-to-Right in RTL) always triggers Delete
        // Since we used AlignmentDirectional for the backgrounds, they also flip.
        // This means in RTL, swiping from right (start) reveals Edit on the right, 
        // and swiping from left (end) reveals Delete on the left.

        if (direction == DismissDirection.endToStart && widget.enableDelete) {
          // Delete action (Right-to-Left in LTR, Left-to-Right in RTL)
          final confirmed = await _showConfirmDialog(
            context,
            title: widget.confirmTitle ?? l10n.deleteItem,
            message: widget.confirmMessage ?? l10n.confirmDeleteItem,
            confirmText: widget.deleteLabel ?? l10n.delete,
            confirmColor: widget.deleteBackgroundColor,
          );

          if (confirmed == true && widget.onDelete != null) {
            widget.onDelete!();
          }
          return false; // Don't dismiss, let the parent handle the deletion
        } else if (direction == DismissDirection.startToEnd && widget.enableEdit) {
          // Edit action (Left-to-Right in LTR, Right-to-Left in RTL)
          if (widget.onEdit != null) {
            widget.onEdit!();
          }
          return false; // Don't dismiss
        }

        return false;
      },
      background: widget.enableEdit
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                alignment: AlignmentDirectional.centerStart,
                margin: widget.backgroundMargin,
                padding: const EdgeInsetsDirectional.only(start: 20),
                decoration: BoxDecoration(
                  color: widget.editBackgroundColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.editIcon,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : widget.editBackgroundColor,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.editLabel ?? l10n.edit,
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : widget.editBackgroundColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      secondaryBackground: widget.enableDelete
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                alignment: AlignmentDirectional.centerEnd,
                margin: widget.backgroundMargin,
                padding: const EdgeInsetsDirectional.only(end: 20),
                decoration: BoxDecoration(
                  color: widget.deleteBackgroundColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.deleteIcon,
                      color: theme.brightness == Brightness.dark
                          ? Colors.white
                          : widget.deleteBackgroundColor,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.deleteLabel ?? l10n.delete,
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.white
                            : widget.deleteBackgroundColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      child: widget.child,
    );

    // Wrap in MouseRegion and Stack to show desktop hover actions
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          swipeable,
          if (widget.showHoverActions && (widget.onEdit != null || widget.onDelete != null))
            PositionedDirectional(
              end: 16,
              top: 0,
              bottom: 0,
              child: Center(
                widthFactor: 1.0,
                child: AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: IgnorePointer(
                    ignoring: !_isHovered,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.additionalHoverActions != null && widget.additionalHoverActions!.isNotEmpty) ...[
                            ...widget.additionalHoverActions!,
                            if ((widget.onEdit != null && widget.enableEdit) || (widget.onDelete != null && widget.enableDelete))
                              SizedBox(
                                height: 14,
                                child: VerticalDivider(
                                  width: 12,
                                  thickness: 1,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                                ),
                              ),
                          ],
                          if (widget.onEdit != null && widget.enableEdit)
                            IconButton(
                              icon: Icon(widget.editIcon),
                              color: theme.colorScheme.primary,
                              iconSize: 18,
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              tooltip: widget.editLabel ?? l10n.edit,
                              onPressed: widget.onEdit,
                            ),
                          if (widget.onEdit != null && widget.enableEdit && widget.onDelete != null && widget.enableDelete)
                            SizedBox(
                              height: 14,
                              child: VerticalDivider(
                                width: 12,
                                thickness: 1,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                              ),
                            ),
                          if (widget.onDelete != null && widget.enableDelete)
                            IconButton(
                              icon: Icon(widget.deleteIcon),
                              color: widget.deleteBackgroundColor,
                              iconSize: 18,
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              tooltip: widget.deleteLabel ?? l10n.delete,
                              onPressed: () async {
                                final confirmed = await _showConfirmDialog(
                                  context,
                                  title: widget.confirmTitle ?? l10n.deleteItem,
                                  message: widget.confirmMessage ?? l10n.confirmDeleteItem,
                                  confirmText: widget.deleteLabel ?? l10n.delete,
                                  confirmColor: widget.deleteBackgroundColor,
                                );

                                if (confirmed == true && widget.onDelete != null) {
                                  widget.onDelete!();
                                }
                              },
                            ),
                        ],
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
