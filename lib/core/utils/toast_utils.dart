import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ToastUtils {
  static void showSuccessToast(BuildContext context, String message) {
    _showToast(
      context,
      message,
      icon: Icons.check_circle_outline_rounded,
      gradient: AppColors.incomeGradient,
      textColor: Colors.white,
    );
  }

  static void showErrorToast(BuildContext context, String message) {
    _showToast(
      context,
      message,
      icon: Icons.error_outline_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFEF4444)],
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
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
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
              Icon(icon, color: textColor, size: 24),
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
