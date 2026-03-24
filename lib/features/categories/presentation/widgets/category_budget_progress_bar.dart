import 'package:flutter/material.dart';

/// Thin bottom-edge progress (0..1 fill); [progress] may exceed 1.0 (over budget).
///
/// Track (unfilled) is a muted blend of [fillColor] with the theme surface so it
/// reads as a dull version of the fill color.
class CategoryBudgetProgressBar extends StatelessWidget {
  final double progress;
  final Color fillColor;
  final double height;

  const CategoryBudgetProgressBar({
    super.key,
    required this.progress,
    required this.fillColor,
    this.height = 4,
  });

  static Color _mutedTrack(Color fill, ThemeData theme) {
    final neutral = theme.colorScheme.surfaceContainerHighest;
    return Color.lerp(fill, neutral, 0.62) ??
        fill.withValues(alpha: 0.35);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trackColor = _mutedTrack(fillColor, theme);
    final clamped = progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: trackColor),
            FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: clamped,
              child: ColoredBox(color: fillColor),
            ),
          ],
        ),
      ),
    );
  }
}
