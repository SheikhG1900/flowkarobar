import 'dart:ui';
import 'package:flutter/material.dart';

/// Glassmorphism Card Widget
/// Card with frosted glass effect using BackdropFilter
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? color;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final double borderWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 10,
    this.color,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.border,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.7);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? defaultColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
                    width: borderWidth,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glass Morph Container with Gradient
/// Advanced glassmorphism with gradient overlay
class GlassMorphContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Gradient? gradient;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? boxShadow;

  const GlassMorphContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.gradient,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.04),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.8),
                            Colors.white.withValues(alpha: 0.4),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.25),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

