import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ToastUtils {
  static void showSuccessToast(BuildContext context, String message) {
    _showToast(
      context,
      message,
      icon: Icons.check_circle_outline_rounded,
      gradient: AppColors.successGradient,
      textColor: Colors.white,
    );
  }

  static void showErrorToast(BuildContext context, String message) {
    _showToast(
      context,
      message,
      icon: Icons.error_outline_rounded,
      gradient: const LinearGradient(
        colors: [
          Color.fromARGB(255, 113, 0, 0),
          Color.fromARGB(255, 228, 66, 66)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      textColor: Colors.white,
    );
  }

  static void showInfoToast(BuildContext context, String message) {
    _showToast(
      context,
      message,
      icon: Icons.info_outline_rounded,
      gradient: AppColors.primaryGradient,
      textColor: Colors.white,
    );
  }

  static void showWarningToast(BuildContext context, String message) {
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
                duration: const Duration(milliseconds: 5000),
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
