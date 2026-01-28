import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';

/// FlowPaisa Theme System
/// Modern Material Design 3 with Wortek-inspired gradients
class AppTheme {
  // Get text theme based on locale and selected font
  static TextTheme getTextTheme(String languageCode, String fontName) {
    // Helper to get GoogleFont method by name
    TextStyle getFont(TextStyle baseStyle) {
      switch (fontName) {
        case 'Lalezar':
          return GoogleFonts.lalezar(textStyle: baseStyle);
        case 'Kufam':
          return GoogleFonts.kufam(textStyle: baseStyle);
        case 'Marhey':
          return GoogleFonts.marhey(textStyle: baseStyle);
        case 'Noto Sans Devanagari':
          return GoogleFonts.notoSansDevanagari(textStyle: baseStyle);
        case 'Inter':
        default:
          return GoogleFonts.inter(textStyle: baseStyle);
      }
    }

    // Map the selected font to the appropriate TextTheme
    TextTheme baseTextTheme;
    switch (fontName) {
      case 'Lalezar':
        baseTextTheme = GoogleFonts.lalezarTextTheme();
        break;
      case 'Kufam':
        baseTextTheme = GoogleFonts.kufamTextTheme();
        break;
      case 'Marhey':
        baseTextTheme = GoogleFonts.marheyTextTheme();
        break;
      case 'Noto Sans Devanagari':
        baseTextTheme = GoogleFonts.notoSansDevanagariTextTheme();
        break;
      case 'Inter':
      default:
        baseTextTheme = GoogleFonts.interTextTheme();
    }

    // Apply custom sizes/weights
    return baseTextTheme.copyWith(
      displayLarge:
          getFont(const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      displayMedium:
          getFont(const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      displaySmall:
          getFont(const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      headlineLarge:
          getFont(const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      headlineMedium:
          getFont(const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      headlineSmall:
          getFont(const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      titleLarge:
          getFont(const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      titleMedium:
          getFont(const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      titleSmall:
          getFont(const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      bodyLarge:
          getFont(const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
      bodyMedium:
          getFont(const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
      bodySmall:
          getFont(const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
      labelLarge:
          getFont(const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      labelMedium:
          getFont(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      labelSmall:
          getFont(const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
    );
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
  static ThemeData lightTheme(String languageCode, String fontName,
      {Color? primaryColor}) {
    final textTheme = getTextTheme(languageCode, fontName);
    final primary = primaryColor ?? AppColors.brightCyan;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme (GermGuard-inspired Cyan/Blue)
      colorScheme: ColorScheme.light(
        primary: primary, // Dynamic Primary
        onPrimary: Colors.white,
        primaryContainer: primary.withValues(alpha: 0.1),
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

      // Cards with diagonal beveled border (top-left + bottom-right)
      cardTheme: CardThemeData(
        elevation: 2,
        color: AppColors.lightCard,
        shadowColor: AppColors.lightBorder,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // FAB with gradient colors
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: const CircleBorder(),
      ),

      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.lightCard,
        indicatorColor: primary.withValues(alpha: 0.1 / 1.0),
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
          borderSide: BorderSide(color: primary, width: 2),
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
        selectedColor: primary.withValues(alpha: 0.15 / 1.0),
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
  static ThemeData darkTheme(String languageCode, String fontName,
      {Color? primaryColor}) {
    final textTheme = getTextTheme(languageCode, fontName);
    final primary = primaryColor ?? AppColors.brightCyan;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme (GermGuard Dark - Professional Cyan)
      colorScheme: ColorScheme.dark(
        primary: primary, // Dynamic Primary
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

        surface:
            Color.lerp(AppColors.darkCard, primary, .2) ?? AppColors.darkCard,
        onSurface: AppColors.darkText,
        surfaceContainerHighest: Color.lerp(AppColors.darkSurface, primary, .2),
        onSurfaceVariant: AppColors.darkTextSecondary,

        outline: Color.lerp(AppColors.darkBorder, primary, .2),
        outlineVariant: Color.lerp(AppColors.darkDivider, primary, .2),

        shadow: const Color(0x4D000000), // black with 30% opacity
        scrim: const Color(0xB3000000), // black with 70% opacity

        inverseSurface: AppColors.lightCard,
        onInverseSurface: Color.lerp(AppColors.lightText, primary, .2),
        inversePrimary: primary,
      ),

      // Scaffold
      scaffoldBackgroundColor:
          Color.lerp(AppColors.darkBackground, primary, .2),

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

      // Cards with diagonal beveled border (top-left + bottom-right)
      cardTheme: CardThemeData(
        elevation: 4,
        color:
            Color.lerp(AppColors.darkCard, primary, .2) ?? AppColors.darkCard,
        shadowColor: Colors.black.withValues(alpha: 0.3 / 1.0),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Color.lerp(const Color(0xFF003D57), primary, .2),
        elevation: 4,
        highlightElevation: 8,
        shape: const CircleBorder(),
      ),

      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor:
            Color.lerp(AppColors.darkCard, primary, .2) ?? AppColors.darkCard,
        indicatorColor: primary.withValues(alpha: 0.15 / 1.0),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: primary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelMedium?.copyWith(
            color: AppColors.darkTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(
              color: AppColors.darkTextSecondary, size: 24);
        }),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color.lerp(AppColors.darkSurface, primary, .2) ??
            AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: (Color.lerp(AppColors.darkBorder, primary, .2) ??
                  AppColors.darkBorder)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF8A8A)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: Color.lerp(AppColors.darkDivider, primary, .2),
        thickness: 1,
        space: 1,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: Color.lerp(AppColors.darkSurface, primary, .2) ??
            AppColors.darkSurface,
        selectedColor: primary.withValues(alpha: 0.2 / 1.0),
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
