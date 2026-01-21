import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/cashbooks/presentation/providers/cashbook_provider.dart';

class ToastUtils {
  static void showSuccessToast(
      BuildContext context, WidgetRef ref, String message) {
    final activeCashbook = ref.read(activeCashbookProvider);
    final activeColor = activeCashbook.color;

    _showToast(
      context,
      message,
      icon: Icons.check_circle_outline_rounded,
      activeColor: activeColor,
    );
  }

  static void showErrorToast(
      BuildContext context, WidgetRef ref, String message) {
    final activeCashbook = ref.read(activeCashbookProvider);
    final activeColor = activeCashbook.color;

    _showToast(
      context,
      message,
      icon: Icons.error_outline_rounded,
      activeColor: activeColor,
    );
  }

  static void showInfoToast(
      BuildContext context, WidgetRef ref, String message) {
    final activeCashbook = ref.read(activeCashbookProvider);
    final activeColor = activeCashbook.color;

    _showToast(
      context,
      message,
      icon: Icons.info_outline_rounded,
      activeColor: activeColor,
    );
  }

  static void showWarningToast(
      BuildContext context, WidgetRef ref, String message) {
    final activeCashbook = ref.read(activeCashbookProvider);
    final activeColor = activeCashbook.color;

    _showToast(
      context,
      message,
      icon: Icons.warning_amber_rounded,
      activeColor: activeColor,
    );
  }

  static void _showToast(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color activeColor,
  }) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final backgroundColor = theme.scaffoldBackgroundColor;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TweenAnimationBuilder<Offset>(
          tween: Tween(begin: const Offset(0.2, 0), end: Offset.zero),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, offset, child) {
            return FractionalTranslation(
              translation: offset,
              child: Opacity(
                opacity: (1.0 - (offset.dx * 5)).clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Container(
            // margin gives the shadow space and positions the toast at the bottom
            margin:
                const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.zero,
              boxShadow: [
                // Tightened primary shadow to prevent edge clipping
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                  spreadRadius: -4, // Pulls the shadow in from the edges
                ),
                // Tightened colored glow
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: activeColor.withValues(alpha: 1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                // Square corners
                borderRadius: BorderRadius.zero,
                child: Stack(
                  children: [
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              activeColor.withValues(alpha: 0.4),
                              activeColor.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    // Content with padding
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Icon(icon, color: textColor, size: 24),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              message,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.fixed,
        padding:
            EdgeInsets.zero, // Remove default padding to use container margin
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
