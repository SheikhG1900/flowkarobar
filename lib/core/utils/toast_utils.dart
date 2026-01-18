import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../../features/cashbooks/presentation/providers/cashbook_provider.dart';

class ToastUtils {
  static void showSuccessToast(
      BuildContext context, WidgetRef ref, String message) {
    final activeCashbook = ref.read(activeCashbookProvider);
    final color = activeCashbook.color;

    _showToast(
      context,
      message,
      icon: Icons.check_circle_outline_rounded,
      gradient: LinearGradient(
        colors: [
          color,
          color.withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      textColor: Colors.white,
    );
  }

  static void showErrorToast(
      BuildContext context, WidgetRef ref, String message) {
    _showToast(
      context,
      message,
      icon: Icons.error_outline_rounded,
      gradient: AppColors.errorGradient,
      textColor: Colors.white,
    );
  }

  static void showInfoToast(
      BuildContext context, WidgetRef ref, String message) {
    _showToast(
      context,
      message,
      icon: Icons.info_outline_rounded,
      gradient: AppColors.primaryGradient,
      textColor: Colors.white,
    );
  }

  static void showWarningToast(
      BuildContext context, WidgetRef ref, String message) {
    _showToast(
      context,
      message,
      icon: Icons.warning_amber_rounded,
      gradient: AppColors.payableGradient,
      textColor: Colors.white,
    );
  }

  static void _showToast(
    BuildContext context,
    String message, {
    required IconData icon,
    required LinearGradient gradient,
    required Color textColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  gradient.colors.map((c) => c.withValues(alpha: 0.9)).toList(),
              begin: gradient.begin,
              end: gradient.end,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
