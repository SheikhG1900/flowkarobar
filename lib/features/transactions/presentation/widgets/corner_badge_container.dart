import 'package:flutter/material.dart';

/// A centralized container that handles the decorative border, background, shapes,
/// and soft elevation shadows of corner badges consistently across card components.
class CornerBadgeContainer extends StatelessWidget {
  final Color accentColor;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? borderRadius; // If null, renders circular shape
  final Key? containerKey;
  final bool hasDoubleShadow;

  const CornerBadgeContainer({
    super.key,
    required this.accentColor,
    required this.child,
    required this.padding,
    this.borderRadius,
    this.containerKey,
    this.hasDoubleShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      key: containerKey,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius == null ? null : BorderRadius.circular(borderRadius!),
        boxShadow: hasDoubleShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
        border: Border.all(
          color: accentColor.withValues(alpha: borderRadius == null ? 0.2 : 0.35),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
