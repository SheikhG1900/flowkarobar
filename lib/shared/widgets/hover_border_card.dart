import 'package:flutter/material.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';

/// List card with transaction-style hover: border opacity/width only
/// (no background fill change on hover).
class HoverBorderCard extends StatefulWidget {
  final Color accent;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  /// When set, uses a flat fill instead of the standard card decoration.
  final Color? fillColor;
  final Clip clipBehavior;

  const HoverBorderCard({
    super.key,
    required this.accent,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius = 20,
    this.fillColor,
    this.clipBehavior = Clip.none,
  });

  @override
  State<HoverBorderCard> createState() => _HoverBorderCardState();
}

class _HoverBorderCardState extends State<HoverBorderCard> {
  bool _hovered = false;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(widget.borderRadius);

    final BoxDecoration decoration;
    if (widget.fillColor != null) {
      decoration = BoxDecoration(
        color: widget.fillColor,
        borderRadius: radius,
        border: Border.all(
          color: _hovered
              ? widget.accent
              : widget.accent.withValues(alpha: isDark ? 0.28 : 0.18),
          width: 1,
        ),
      );
    } else {
      decoration = AppColors.transactionListItemDecoration(
        theme,
        widget.accent,
        hovered: _hovered,
        borderRadius: widget.borderRadius,
      );
    }

    final content = widget.padding == null
        ? widget.child
        : Padding(padding: widget.padding!, child: widget.child);

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      clipBehavior: widget.clipBehavior,
      decoration: decoration,
      child: content,
    );

    // Hover-only cards (e.g. recipe with inner buttons) must not swallow taps.
    if (widget.onTap == null) {
      return MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: card,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      clipBehavior: widget.clipBehavior,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: widget.accent.withValues(alpha: 0.06),
          onHover: _setHovered,
          onTap: widget.onTap,
          child: content,
        ),
      ),
    );
  }
}
