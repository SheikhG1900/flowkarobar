import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';

/// FlowPaisa Theme System
/// Modern Material Design 3 with Wortek-inspired gradients
class AppTheme {
  // Get text theme based on locale
  static TextTheme getTextTheme(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return GoogleFonts.notoSansDevanagariTextTheme().copyWith(
          displayLarge: GoogleFonts.notoSansDevanagari(
              fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.notoSansDevanagari(
              fontSize: 28, fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.notoSansDevanagari(
              fontSize: 24, fontWeight: FontWeight.bold),
          headlineLarge: GoogleFonts.notoSansDevanagari(
              fontSize: 22, fontWeight: FontWeight.w600),
          headlineMedium: GoogleFonts.notoSansDevanagari(
              fontSize: 20, fontWeight: FontWeight.w600),
          headlineSmall: GoogleFonts.notoSansDevanagari(
              fontSize: 18, fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.notoSansDevanagari(
              fontSize: 20, fontWeight: FontWeight.w500),
          titleMedium: GoogleFonts.notoSansDevanagari(
              fontSize: 18, fontWeight: FontWeight.w500),
          titleSmall: GoogleFonts.notoSansDevanagari(
              fontSize: 16, fontWeight: FontWeight.w500),
          bodyLarge: GoogleFonts.notoSansDevanagari(
              fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: GoogleFonts.notoSansDevanagari(
              fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall: GoogleFonts.notoSansDevanagari(
              fontSize: 12, fontWeight: FontWeight.w400),
          labelLarge: GoogleFonts.notoSansDevanagari(
              fontSize: 14, fontWeight: FontWeight.w600),
          labelMedium: GoogleFonts.notoSansDevanagari(
              fontSize: 12, fontWeight: FontWeight.w600),
          labelSmall: GoogleFonts.notoSansDevanagari(
              fontSize: 10, fontWeight: FontWeight.w600),
        );

      case 'ur':
        return GoogleFonts.notoNastaliqUrduTextTheme().copyWith(
          displayLarge: GoogleFonts.notoNastaliqUrdu(
              fontSize: 36, fontWeight: FontWeight.w400, height: 1.8),
          displayMedium: GoogleFonts.notoNastaliqUrdu(
              fontSize: 32, fontWeight: FontWeight.w400, height: 1.8),
          displaySmall: GoogleFonts.notoNastaliqUrdu(
              fontSize: 28, fontWeight: FontWeight.w400, height: 1.8),
          headlineLarge: GoogleFonts.notoNastaliqUrdu(
              fontSize: 26, fontWeight: FontWeight.w400, height: 1.8),
          headlineMedium: GoogleFonts.notoNastaliqUrdu(
              fontSize: 24, fontWeight: FontWeight.w400, height: 1.8),
          headlineSmall: GoogleFonts.notoNastaliqUrdu(
              fontSize: 22, fontWeight: FontWeight.w400, height: 1.8),
          titleLarge: GoogleFonts.notoNastaliqUrdu(
              fontSize: 22, fontWeight: FontWeight.w400, height: 1.8),
          titleMedium: GoogleFonts.notoNastaliqUrdu(
              fontSize: 20, fontWeight: FontWeight.w400, height: 1.8),
          titleSmall: GoogleFonts.notoNastaliqUrdu(
              fontSize: 18, fontWeight: FontWeight.w400, height: 1.8),
          bodyLarge: GoogleFonts.notoNastaliqUrdu(
              fontSize: 18, fontWeight: FontWeight.w400, height: 1.8),
          bodyMedium: GoogleFonts.notoNastaliqUrdu(
              fontSize: 16, fontWeight: FontWeight.w400, height: 1.8),
          bodySmall: GoogleFonts.notoNastaliqUrdu(
              fontSize: 14, fontWeight: FontWeight.w400, height: 1.8),
          labelLarge: GoogleFonts.notoNastaliqUrdu(
              fontSize: 16, fontWeight: FontWeight.w400, height: 1.8),
          labelMedium: GoogleFonts.notoNastaliqUrdu(
              fontSize: 14, fontWeight: FontWeight.w400, height: 1.8),
          labelSmall: GoogleFonts.notoNastaliqUrdu(
              fontSize: 12, fontWeight: FontWeight.w400, height: 1.8),
        );

      default: // English
        return GoogleFonts.interTextTheme().copyWith(
          displayLarge:
              GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium:
              GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold),
          displaySmall:
              GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
          headlineLarge:
              GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700),
          headlineMedium:
              GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
          headlineSmall:
              GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
          titleLarge:
              GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
          titleMedium:
              GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          titleSmall:
              GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge:
              GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
          labelLarge:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          labelMedium:
              GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
          labelSmall:
              GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
        );
    }
  }

  // Helper for consistent text shadows
  static List<Shadow> textShadow({double blurMultiplier = 1.0, Color? color}) {
    return [
      Shadow(
        color: (color ?? const Color.fromARGB(255, 135, 0, 123))
            .withValues(alpha: 0.4 / 1.0),
        offset: Offset(0, 1 * blurMultiplier),
        blurRadius: 1 * blurMultiplier,
      ),
    ];
  }

  // Light Theme with Wortek colors
  static ThemeData lightTheme(String languageCode) {
    final textTheme = getTextTheme(languageCode);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme (GermGuard-inspired Cyan/Blue)
      colorScheme: ColorScheme.light(
        primary: AppColors.brightCyan, // Bright Cyan
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE0F7FF),
        onPrimaryContainer: const Color(0xFF003D57),

        secondary: AppColors.electricBlue, // Electric Blue
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFD1E9FF),
        onSecondaryContainer: const Color(0xFF002C5A),

        tertiary: AppColors.teal, // Teal
        onTertiary: Colors.white,
        tertiaryContainer: const Color(0xFFD0FFF5),
        onTertiaryContainer: const Color(0xFF003D3D),

        error: AppColors.error,
        onError: Colors.white,
        errorContainer: const Color(0xFFFFDAD6),
        onErrorContainer: const Color(0xFF93000A),

        surface: AppColors.lightCard,
        onSurface: AppColors.lightText,
        surfaceContainerHighest: AppColors.lightSurface,
        onSurfaceVariant: AppColors.lightTextSecondary,

        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightDivider,

        shadow: const Color(0x1A000000), // black with 10% opacity
        scrim: const Color(0x80000000), // black with 50% opacity

        inverseSurface: AppColors.darkCard,
        onInverseSurface: AppColors.darkText,
        inversePrimary: const Color(0xFFFFB3C1),
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.lightBackground,

      // AppBar (transparent for gradient backgrounds)
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightText,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: AppColors.lightText,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.lightText,
          size: 24,
        ),
      ),

      // Cards with modern rounded style and elevation
      cardTheme: CardThemeData(
        elevation: 2,
        color: AppColors.lightCard,
        shadowColor: AppColors.lightBorder,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // FAB with gradient colors
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brightCyan,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: CircleBorder(),
      ),

      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.lightCard,
        indicatorColor: AppColors.brightCyan.withValues(alpha: 0.1 / 1.0),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: AppColors.deepBlue,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelMedium?.copyWith(
            color: AppColors.lightTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.deepBlue, size: 24);
          }
          return const IconThemeData(
              color: AppColors.lightTextSecondary, size: 24);
        }),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brightCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedColor: AppColors.brightCyan.withValues(alpha: 0.15 / 1.0),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Text Theme
      textTheme: textTheme.apply(
        bodyColor: AppColors.lightText,
        displayColor: AppColors.lightText,
      ),
    );
  }

  // Dark Theme with Wortek colors
  static ThemeData darkTheme(String languageCode) {
    final textTheme = getTextTheme(languageCode);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme (GermGuard Dark - Professional Cyan)
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF33E0FF), // Lighter bright cyan
        onPrimary: const Color(0xFF003D57),
        primaryContainer: const Color(0xFF005580),
        onPrimaryContainer: const Color(0xFFB8F0FF),

        secondary: const Color(0xFF4DD4FF), // Lighter electric blue
        onSecondary: const Color(0xFF002C5A),
        secondaryContainer: const Color(0xFF004A80),
        onSecondaryContainer: const Color(0xFFD1E9FF),

        tertiary: const Color(0xFF40E0D0), // Turquoise
        onTertiary: const Color(0xFF003D3D),
        tertiaryContainer: const Color(0xFF005555),
        onTertiaryContainer: const Color(0xFFB3FFF0),

        error: const Color(0xFFFF8A8A),
        onError: const Color(0xFF1A1F3A),
        errorContainer: const Color(0xFF93000A),
        onErrorContainer: const Color(0xFFFFDAD6),

        surface: AppColors.darkCard,
        onSurface: AppColors.darkText,
        surfaceContainerHighest: AppColors.darkSurface,
        onSurfaceVariant: AppColors.darkTextSecondary,

        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkDivider,

        shadow: const Color(0x4D000000), // black with 30% opacity
        scrim: const Color(0xB3000000), // black with 70% opacity

        inverseSurface: AppColors.lightCard,
        onInverseSurface: AppColors.lightText,
        inversePrimary: AppColors.brightCyan,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.darkBackground,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkText,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkText,
          size: 24,
        ),
      ),

      // Cards with elevation
      cardTheme: CardThemeData(
        elevation: 4,
        color: AppColors.darkCard,
        shadowColor: Colors.black.withValues(alpha: 0.3 / 1.0),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF33E0FF),
        foregroundColor: Color(0xFF003D57),
        elevation: 4,
        highlightElevation: 8,
        shape: CircleBorder(),
      ),

      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.darkCard,
        indicatorColor: const Color(0xFF33E0FF).withValues(alpha: 0.15 / 1.0),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: const Color(0xFF33E0FF),
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelMedium?.copyWith(
            color: AppColors.darkTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF33E0FF), size: 24);
          }
          return const IconThemeData(
              color: AppColors.darkTextSecondary, size: 24);
        }),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF33E0FF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8A8A)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedColor: const Color(0xFF33E0FF).withValues(alpha: 0.2 / 1.0),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Text Theme
      textTheme: textTheme.apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
      ),
    );
  }
}
