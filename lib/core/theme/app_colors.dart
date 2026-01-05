import 'package:flutter/material.dart';

/// FlowPaisa Color System
/// Inspired by Wortek Agency branding - Vibrant gradients for modern finance
class AppColors {
  // Primary Brand Gradients (GermGuard-inspired - Professional Cyan/Blue)
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0088CC)], // Bright Cyan to Deep Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const secondaryGradient = LinearGradient(
    colors: [Color(0xFF00B8FF), Color(0xFF0066FF)], // Electric Blue gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Transaction Type Gradients
  static const incomeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)], // Green shades
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const expenseGradient = LinearGradient(
    colors: [Color(0xFFFF9A76), Color(0xFFFF7043)], // Warm Orange (softer, less shocking)
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const receivableGradient = LinearGradient(
    colors: [Color(0xFF22D3EE), Color(0xFF0EA5E9)], // Cyan to Sky Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const payableGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)], // Yellow to Amber
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Solid Brand Colors (extracted from GermGuard palette)
  static const brightCyan = Color(0xFF00D4FF);
  static const deepBlue = Color(0xFF0088CC);
  static const electricBlue = Color(0xFF00B8FF);
  static const teal = Color(0xFF00B8A3);
  static const successGreen = Color(0xFF10B981);
  static const warningOrange = Color(0xFFFF9A76);
  
  // Light Mode Colors
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightCard = Colors.white;
  static const lightCardElevated = Color(0xFFFCFCFC); // Slightly elevated
  static const lightSurface = Color(0xFFF1F5F9); // Tinted surface
  static const lightText = Color(0xFF1E293B);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightDivider = Color(0xFFF1F5F9);
  
  // Dark Mode Colors (Navy-based from Wortek)
  static const darkBackground = Color(0xFF0A0E27); // Deep navy
  static const darkCard = Color(0xFF1A1F3A); // Lighter navy
  static const darkCardElevated = Color(0xFF242B47); // More elevated
  static const darkSurface = Color(0xFF151933);
  static const darkText = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF334155);
  static const darkDivider = Color(0xFF1E293B);
  
  // Semantic Colors
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFF6EE7B7);
  static const error = Color(0xFFFF6B6B);
  static const errorLight = Color(0xFFFCA5A5);
  static const warning = Color(0xFFFBBF24);
  static const warningLight = Color(0xFFFDE68A);
  static const info = Color(0xFF22D3EE);
  static const infoLight = Color(0xFF7DD3FC);
  
  // Transaction Type Colors (for icons and indicators)
  static const incomeColor = Color(0xFF10B981);
  static const expenseColor = Color(0xFFFF7043); // Warm orange instead of shocking pink
  static const receivableColor = Color(0xFF00D4FF); // Bright cyan
  static const payableColor = Color(0xFFFBBF24);
  
  // Gradient overlays for glassmorphism
  static LinearGradient glassGradient(bool isDark) {
    return LinearGradient(
      colors: isDark
          ? [
              Colors.white.withValues(alpha: 0.05 / 1.0),
              Colors.white.withValues(alpha: 0.02 / 1.0),
            ]
          : [
              Colors.white.withValues(alpha: 0.7 / 1.0),
              Colors.white.withValues(alpha: 0.3 / 1.0),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
  
  // Shimmer gradient for loading states
  static const shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFE2E8F0),
      Color(0xFFF1F5F9),
      Color(0xFFE2E8F0),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
  );
  
  // Shadow Configuration
  static const double shadowBlurMultiplier = 1.0; // Adjustable multiplier
  
  // Text Shadow Colors (Theme-aware)
  static Color textShadowLight(double opacity) => Colors.black.withValues(alpha: opacity / 1.0);
  static Color textShadowDark(double opacity) => Colors.black.withValues(alpha: opacity / 1.0);
  
  // Default shadow configurations
  static Shadow textShadowSubtle(bool isDark) => Shadow(
    color: isDark ? textShadowDark(0.15) : textShadowLight(0.1),
    offset: const Offset(0, 1),
    blurRadius: 2 * shadowBlurMultiplier,
  );
  
  static Shadow textShadowMedium(bool isDark) => Shadow(
    color: isDark ? textShadowDark(0.25) : textShadowLight(0.2),
    offset: const Offset(0, 2),
    blurRadius: 4 * shadowBlurMultiplier,
  );
  
  static Shadow textShadowStrong(bool isDark) => Shadow(
    color: isDark ? textShadowDark(0.35) : textShadowLight(0.3),
    offset: const Offset(0, 3),
    blurRadius: 8 * shadowBlurMultiplier,
  );
  
  // Container/Box Shadow Colors
  static BoxShadow containerShadow(Color baseColor, {double opacity = 0.2, double blur = 8, double offsetY = 4}) => BoxShadow(
    color: baseColor.withValues(alpha: opacity / 1.0),
    blurRadius: blur * shadowBlurMultiplier,
    offset: Offset(0, offsetY),
  );
}

