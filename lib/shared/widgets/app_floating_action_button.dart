import 'package:flutter/material.dart';

/// A custom [FloatingActionButton] that automatically adjusts its shadow color
/// to match its background color in dark mode, creating a "glow" effect.
class AppFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final Object? heroTag;
  final double? elevation;
  final double? highlightElevation;
  final ShapeBorder? shape;
  final bool mini;
  final Widget? icon;
  final Widget? label;

  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.heroTag,
    this.elevation,
    this.highlightElevation,
    this.shape,
    this.mini = false,
    this.icon,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Resolve the background color to use for the shadow
    final Color resolvedBgColor = backgroundColor ??
        theme.floatingActionButtonTheme.backgroundColor ??
        theme.colorScheme.primary;

    // Use the FAB's background color as the shadow color in dark mode
    // with a slight transparency for a better glow effect.
    final shadowColor = isDark
        ? Color.lerp(Colors.white, resolvedBgColor, 0.3)
        : resolvedBgColor;

    return Theme(
      data: theme.copyWith(shadowColor: shadowColor),
      child: label != null
          ? FloatingActionButton.extended(
              onPressed: onPressed,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              tooltip: tooltip,
              heroTag: heroTag,
              elevation: elevation,
              highlightElevation: highlightElevation,
              shape: shape,
              icon: icon,
              label: label!,
            )
          : FloatingActionButton(
              onPressed: onPressed,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              tooltip: tooltip,
              heroTag: heroTag,
              elevation: elevation,
              highlightElevation: highlightElevation,
              shape: shape,
              mini: mini,
              child: child,
            ),
    );
  }
}
