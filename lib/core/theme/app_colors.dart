import 'package:flutter/material.dart';

/// Flowpaisa Color System
/// Inspired by Wortek Agency branding - Vibrant gradients for modern finance
class AppColors {
  // Primary Brand Gradients (GermGuard-inspired - Professional Cyan/Blue)
  static const primaryGradient = LinearGradient(
    colors: [
      Color(0xFF00B8E6),
      Color(0xFF006699)
    ], // Darker Cyan to Darker Deep Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const secondaryGradient = LinearGradient(
    colors: [
      Color(0xFF0099CC),
      Color(0xFF0044CC)
    ], // Darker Electric Blue gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Transaction Type Gradients
  static const incomeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)], // Green shades
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Transaction Type Gradients
  static const successGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 0, 123, 139),
      Color.fromARGB(255, 1, 65, 100)
    ], // Teal/Blue shades
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const errorGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 113, 0, 0),
      Color.fromARGB(255, 228, 66, 66)
    ], // Deep Red shades
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const errorGradientDark = LinearGradient(
    colors: [
      Color.fromARGB(255, 90, 0, 0),
      Color.fromARGB(255, 170, 40, 40)
    ], // Darker Red shades for better text readability
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const expenseGradient = LinearGradient(
    colors: [
      Color(0xFFFF9A76),
      Color(0xFFFF7043)
    ], // Warm Orange (softer, less shocking)
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const receivableGradient = LinearGradient(
    colors: [
      Color(0xFF00ACC1),
      Color(0xFF0288D1)
    ], // Darker Cyan to Darker Sky Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const payableGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)], // Yellow to Amber
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card border + shadow matching [TransactionsListScreen] list rows.
  static BoxDecoration transactionListItemDecoration(
    ThemeData theme,
    Color accentColor,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
        width: 0,
      ),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: isDark ? 0.05 : 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Solid Brand Colors (extracted from GermGuard palette)
  static const brightCyan = Color(0xFF00B8E6);
  static const deepBlue = Color(0xFF006699);
  static const electricBlue = Color(0xFF0099CC);
  static const secondaryColor = Color(0xFF0099CC); // Secondary brand color
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
  static const expenseColor =
      Color(0xFFFF7043); // Warm orange instead of shocking pink
  static const receivableColor = Color(0xFF00ACC1); // Darker Cyan
  static const payableColor = Color(0xFFFBBF24); // Amber

  /// [FilledButton] for marking a linked payable as paid (transaction details, split list, etc.).
  static ButtonStyle transactionMarkAsPaidFilledStyle() =>
      FilledButton.styleFrom(backgroundColor: payableColor);

  /// [FilledButton] for marking a linked receivable as received.
  static ButtonStyle transactionMarkAsReceivedFilledStyle() =>
      FilledButton.styleFrom(backgroundColor: receivableColor);

  // Section Colors (for FABs, tabs, and quick actions)
  static const dashboardSectionColor = Color(0xFF00B8E6); // Darker Cyan
  static const transactionsSectionColor =
      Color(0xFF0099CC); // Darker Electric Blue
  static const receivablesSectionColor = Color(0xFF00ACC1); // Darker Cyan
  static const payablesSectionColor = Color(0xFFFBBF24); // Amber
  static const analyticsSectionColor = Color(0xFF8B5CF6); // Purple
  static const settingsSectionColor = Color(0xFF64748B); // Slate Gray

  // Section Gradients
  static const dashboardSectionGradient = LinearGradient(
    colors: [Color(0xFF006699), Color(0xFF00B8E6)], // Primary gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const transactionsSectionGradient = LinearGradient(
    colors: [Color(0xFF006699), Color(0xFF00B8E6)], // Primary gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const receivablesSectionGradient = LinearGradient(
    colors: [Color(0xFF0288D1), Color(0xFF00ACC1)], // Cyan gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const payablesSectionGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)], // Amber gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const analyticsSectionGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)], // Purple gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const settingsSectionGradient = LinearGradient(
    colors: [Color(0xFF64748B), Color(0xFF475569)], // Gray gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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

  // Generate a gradient from a primary color
  static LinearGradient getPrimaryGradient(Color primaryColor) {
    return LinearGradient(
      colors: [
        primaryColor,
        primaryColor.withValues(alpha: 0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Generate a secondary gradient from a primary color
  static LinearGradient getSecondaryGradient(Color primaryColor) {
    return LinearGradient(
      colors: [
        primaryColor.withValues(alpha: 0.9),
        primaryColor.withValues(alpha: 0.5),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Shadow Configuration
  static const double shadowBlurMultiplier = 1.0; // Adjustable multiplier

  // Text Shadow Colors (Theme-aware)
  static Color textShadowLight(double opacity) =>
      Colors.black.withValues(alpha: opacity / 1.0);
  static Color textShadowDark(double opacity) =>
      Colors.black.withValues(alpha: opacity / 1.0);

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
  static BoxShadow containerShadow(Color baseColor,
          {double opacity = 0.2, double blur = 8, double offsetY = 4}) =>
      BoxShadow(
        color: baseColor.withValues(alpha: opacity / 1.0),
        blurRadius: blur * shadowBlurMultiplier,
        offset: Offset(0, offsetY),
      );

  // Generate a consistent color from a seed string (e.g. contact name)
  static Color getContactColor(String seed) {
    if (seed.isEmpty) return brightCyan;

    final int hash = seed.hashCode;
    final List<Color> colors = [
      const Color(0xFFF44336), // Red
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF673AB7), // Deep Purple
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFF2196F3), // Blue
      const Color(0xFF03A9F4), // Light Blue
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF009688), // Teal
      const Color(0xFF4CAF50), // Green
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFFFC107), // Amber
      const Color(0xFFFF9800), // Orange
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
    ];

    return colors[hash.abs() % colors.length];
  }

  // Generate a gradient from a seed string
  static LinearGradient getContactGradient(String seed) {
    final color = getContactColor(seed);
    return LinearGradient(
      colors: [
        color,
        color.withValues(alpha: 0.7), // Slightly lighter/transparent
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Get color for a relationship
  static Color getRelationshipColor(String? relationship) {
    if (relationship == null) return Colors.grey;
    switch (relationship.toUpperCase()) {
      case 'PAID_FOR':
      case 'WILL_RECEIVE':
        return receivableColor;
      case 'PAID_BY':
      case 'RECEIVED_FROM':
        return payableColor;
      default:
        return Colors.grey;
    }
  }

  /// Calendar month (1–12) accent for transaction list date chips.
  static Color monthChipAccent(int month) {
    final m = month.clamp(1, 12);
    return _monthChipAccents[m - 1];
  }

  /// Twelve readable hues (distinct from each other; work when alpha-blended).
  static const List<Color> _monthChipAccents = [
    Color(0xFF0369A1), // Jan — sky
    Color(0xFFC026D3), // Feb — fuchsia
    Color(0xFF047857), // Mar — emerald
    Color(0xFFCA8A04), // Apr — gold
    Color(0xFF15803D), // May — green
    Color(0xFFA16207), // Jun — amber
	Color(0xFFC2410C), // Jul — orange
	Color(0xFF0F766E), // Aug — teal
    Color(0xFF6D28D9), // Sep — violet
    Color(0xFF9A3412), // Oct — rust
    Color(0xFF4338CA), // Nov — indigo
    Color(0xFF0E7490), // Dec — cyan
  ];

  /// Background for sticky date chip; [month] null uses [transactionsSectionColor].
  static Color transactionDateChipBackground(ThemeData theme, int? month) {
    final isDark = theme.brightness == Brightness.dark;
    final base = theme.colorScheme.surfaceContainerHighest;
    final accent =
        month != null ? monthChipAccent(month) : transactionsSectionColor;
    return Color.alphaBlend(
      accent.withValues(alpha: isDark ? 0.44 : 0.26),
      base,
    );
  }

  /// Label on date chip: high contrast on both themes.
  static Color transactionDateChipForeground(ThemeData theme, int? month) {
    final bg = transactionDateChipBackground(theme, month);
    final accent =
        month != null ? monthChipAccent(month) : transactionsSectionColor;
    final lum = bg.computeLuminance();
    if (lum > 0.55) {
      return Color.lerp(theme.colorScheme.onSurface, accent, 0.12)!;
    }
    return Color.lerp(theme.colorScheme.onSurface, accent, 0.18)!;
  }

  static Color transactionDateChipShadow(ThemeData theme, int? month) {
    final isDark = theme.brightness == Brightness.dark;
    final accent =
        month != null ? monthChipAccent(month) : transactionsSectionColor;
    return accent.withValues(alpha: isDark ? 0.35 : 0.22);
  }
}
