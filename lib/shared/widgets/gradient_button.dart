import 'package:flutter/material.dart';

/// Gradient Button Widget
/// Modern button with gradient background and shadow
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.gradient,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    this.textStyle,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = theme.textTheme.labelLarge?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: textStyle ?? defaultTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Outlined Gradient Button
/// Button with gradient border and transparent background
class OutlinedGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final IconData? icon;
  final double borderWidth;

  const OutlinedGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.gradient,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    this.textStyle,
    this.icon,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = gradient.colors.first;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color, width: borderWidth),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: textStyle ??
                      theme.textTheme.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

