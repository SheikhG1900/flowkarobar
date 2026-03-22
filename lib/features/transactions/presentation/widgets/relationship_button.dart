import 'package:flutter/material.dart';

/// Data holder for one item inside a [RelationshipButtonGroup].
class RelationshipButtonData {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Gradient gradient;
  final Color color;

  /// Foreground colour for icons/text when the button is selected.
  /// Defaults to [Colors.white].
  final Color? foreColor;

  const RelationshipButtonData({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.gradient,
    required this.color,
    this.foreColor,
  });
}

/// Renders three relationship options as a single grouped card:
/// - [top] item gets rounded top corners only
/// - [middle] item gets no rounded corners
/// - [bottom] item gets rounded bottom corners only
///
/// Horizontal dividers sit between rows; each row draws only the border
/// sides needed for a continuous outline (top: T+L+R, middle: L+R, bottom: L+R+B).
class RelationshipButtonGroup extends StatelessWidget {
  final RelationshipButtonData top;
  final RelationshipButtonData middle;
  final RelationshipButtonData bottom;

  const RelationshipButtonGroup({
    super.key,
    required this.top,
    required this.middle,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const double r = 16;
    const outerRadius = BorderRadius.all(Radius.circular(r));
    const double borderWidth = .5;

    final selectedColor = top.isSelected
        ? top.color
        : middle.isSelected
            ? middle.color
            : bottom.isSelected
                ? bottom.color
                : null;
    final borderColor = selectedColor ?? theme.dividerColor;

    return ClipRRect(
      borderRadius: outerRadius,
      child: Column(
        children: [
          RelationshipButton(
            label: top.label,
            subtitle: top.subtitle,
            icon: top.icon,
            isSelected: top.isSelected,
            onTap: top.onTap,
            gradient: top.gradient,
            color: top.color,
            foreColor: top.foreColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(r), topRight: Radius.circular(r)),
            border: Border(
              top: BorderSide(color: borderColor, width: borderWidth),
              left: BorderSide(color: borderColor, width: borderWidth),
              right: BorderSide(color: borderColor, width: borderWidth),
            ),
            showShadow: false,
          ),
          Container(height: 1, color: theme.dividerColor),
          RelationshipButton(
            label: middle.label,
            subtitle: middle.subtitle,
            icon: middle.icon,
            isSelected: middle.isSelected,
            onTap: middle.onTap,
            gradient: middle.gradient,
            color: middle.color,
            foreColor: middle.foreColor,
            borderRadius: BorderRadius.zero,
            border: Border(
              left: BorderSide(color: borderColor, width: borderWidth),
              right: BorderSide(color: borderColor, width: borderWidth),
            ),
            showShadow: false,
          ),
          Container(height: 1, color: theme.dividerColor),
          RelationshipButton(
            label: bottom.label,
            subtitle: bottom.subtitle,
            icon: bottom.icon,
            isSelected: bottom.isSelected,
            onTap: bottom.onTap,
            gradient: bottom.gradient,
            color: bottom.color,
            foreColor: bottom.foreColor,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(r),
                bottomRight: Radius.circular(r)),
            border: Border(
              left: BorderSide(color: borderColor, width: borderWidth),
              right: BorderSide(color: borderColor, width: borderWidth),
              bottom: BorderSide(color: borderColor, width: borderWidth),
            ),
            showShadow: false,
          ),
        ],
      ),
    );
  }
}

/// A selectable card representing a transaction relationship.
/// Use [RelationshipButtonGroup] to render three of these as a combined card.
class RelationshipButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Gradient gradient;
  final Color color;
  final Color? foreColor;
  final BorderRadius borderRadius;

  /// Per-side outline. In a [RelationshipButtonGroup], only the sides needed
  /// for the segment are set; for a standalone button use [Border.all].
  final Border border;
  final bool showShadow;

  const RelationshipButton({
    super.key,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.gradient,
    required this.color,
    this.foreColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    required this.border,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fore = foreColor ?? Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: borderRadius,
          border: border,
          boxShadow: (showShadow && isSelected)
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? fore.withValues(alpha: 0.2)
                    : color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: isSelected ? fore : color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isSelected ? fore : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? fore.withValues(alpha: 0.85)
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: fore, size: 18),
          ],
        ),
      ),
    );
  }
}
