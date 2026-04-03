import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';

/// Flowpaisa Theme System
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
          return GoogleFonts.kufam(
            textStyle: baseStyle,
          );
        case 'Marhey':
          return GoogleFonts.marhey(textStyle: baseStyle);
        case 'Noto Sans Devanagari':
          return GoogleFonts.notoSansDevanagari(textStyle: baseStyle);
        case 'Montserrat':
        default:
          return GoogleFonts.montserrat(textStyle: baseStyle);
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
    final primary = primaryColor ?? const Color.fromARGB(255, 0, 82, 98);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme (GermGuard-inspired Cyan/Blue)
      colorScheme: ColorScheme.light(
        primary: Color.lerp(Colors.black, primary, .8) ??
            AppColors.brightCyan, // Dynamic Primary
        onPrimary: Color.lerp(Colors.white, primary, .1) ?? Colors.white,
        primaryContainer: primary.withValues(alpha: 0.1),
        onPrimaryContainer: Color.lerp(const Color(0xFF003D57), primary, .1) ??
            const Color(0xFF003D57),

        secondary: Color.lerp(AppColors.electricBlue, primary, .1) ??
            AppColors.electricBlue, // Electric Blue
        onSecondary: Color.lerp(Colors.white, primary, .1) ?? Colors.white,
        secondaryContainer: Color.lerp(const Color(0xFFD1E9FF), primary, .1) ??
            const Color(0xFFD1E9FF),
        onSecondaryContainer:
            Color.lerp(const Color(0xFF002C5A), primary, .1) ??
                const Color(0xFF002C5A),

        tertiary:
            Color.lerp(AppColors.teal, primary, .1) ?? AppColors.teal, // Teal
        onTertiary: Color.lerp(Colors.white, primary, .1) ?? Colors.white,
        tertiaryContainer: Color.lerp(const Color(0xFFD0FFF5), primary, .1) ??
            const Color(0xFFD0FFF5),
        onTertiaryContainer: Color.lerp(const Color(0xFF003D3D), primary, .1) ??
            const Color(0xFF003D3D),

        error: AppColors.error,
        onError: Color.lerp(Colors.white, primary, .1) ?? Colors.white,
        errorContainer: const Color(0xFFFFDAD6),
        onErrorContainer: const Color(0xFF93000A),

        surface: Color.lerp(AppColors.lightCard, primary, .05) ??
            AppColors.lightCard,
        onSurface:
            Color.lerp(AppColors.lightText, primary, .1) ?? AppColors.lightText,
        surfaceContainerHighest:
            Color.lerp(AppColors.lightSurface, primary, .05),
        onSurfaceVariant:
            Color.lerp(AppColors.lightTextSecondary, primary, .1) ??
                AppColors.lightTextSecondary,

        outline: Color.lerp(AppColors.lightBorder, primary, .1),
        outlineVariant: Color.lerp(AppColors.lightDivider, primary, .1),

        shadow: const Color(0x1A000000), // black with 10% opacity
        scrim: const Color(0x80000000), // black with 50% opacity

        inverseSurface: AppColors.darkCard,
        onInverseSurface: AppColors.darkText,
        inversePrimary: const Color(0xFFFFB3C1),
      ),

      // Scaffold
      scaffoldBackgroundColor:
          Color.lerp(AppColors.lightBackground, primary, .07) ??
              AppColors.lightBackground,

      // AppBar (transparent for gradient backgrounds)
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        foregroundColor:
            Color.lerp(AppColors.lightText, primary, .1) ?? AppColors.lightText,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: Color.lerp(AppColors.lightText, primary, .1) ??
              AppColors.lightText,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: Color.lerp(AppColors.lightText, primary, .1) ??
              AppColors.lightText,
          size: 24,
        ),
      ),

      // Cards with diagonal beveled border (top-left + bottom-right)
      cardTheme: CardThemeData(
        elevation: 2,
        color: Color.lerp(AppColors.lightCard, primary, .05) ??
            AppColors.lightCard,
        shadowColor: Color.lerp(AppColors.lightBorder, primary, .1) ??
            AppColors.lightBorder,
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
        foregroundColor: Color.lerp(Colors.white, primary, .1) ?? Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: const CircleBorder(),
      ),

      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Color.lerp(AppColors.lightCard, primary, .05) ??
            AppColors.lightCard,
        indicatorColor: primary.withValues(alpha: 0.1 / 1.0),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: Color.lerp(AppColors.deepBlue, primary, .1) ??
                  AppColors.deepBlue,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelMedium?.copyWith(
            color: Color.lerp(AppColors.lightTextSecondary, primary, .1) ??
                AppColors.lightTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
                color: (Color.lerp(AppColors.deepBlue, primary, .1) ??
                    AppColors.deepBlue),
                size: 24);
          }
          return IconThemeData(
              color: Color.lerp(AppColors.lightTextSecondary, primary, .1) ??
                  AppColors.lightTextSecondary,
              size: 24);
        }),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color.lerp(AppColors.lightSurface, primary, .05) ??
            AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Color.lerp(AppColors.lightBorder, primary, .1) ??
                  AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Color.lerp(AppColors.lightBorder, primary, .1) ??
                  AppColors.lightBorder),
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
      dividerTheme: DividerThemeData(
        color: Color.lerp(AppColors.lightDivider, primary, .1),
        thickness: 1,
        space: 1,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: Color.lerp(AppColors.lightSurface, primary, .05) ??
            AppColors.lightSurface,
        selectedColor: primary.withValues(alpha: 0.15 / 1.0),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Text Theme
      textTheme: textTheme.apply(
        bodyColor:
            Color.lerp(AppColors.lightText, primary, .1) ?? AppColors.lightText,
        displayColor:
            Color.lerp(AppColors.lightText, primary, .1) ?? AppColors.lightText,
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
        primary: Color.lerp(Colors.white, primary, .35) ??
            AppColors.brightCyan, // Dynamic Primary
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
            Color.lerp(AppColors.darkCard, primary, .1) ?? AppColors.darkCard,
        onSurface: AppColors.darkText,
        surfaceContainerHighest: Color.lerp(AppColors.darkSurface, primary, .1),
        onSurfaceVariant: AppColors.darkTextSecondary,

        outline: Color.lerp(AppColors.darkBorder, primary, .1),
        outlineVariant: Color.lerp(AppColors.darkDivider, primary, .1),

        shadow: const Color(0x4D000000), // black with 30% opacity
        scrim: const Color(0xB3000000), // black with 70% opacity

        inverseSurface: AppColors.lightCard,
        onInverseSurface: Color.lerp(AppColors.lightText, primary, .1),
        inversePrimary: primary,
      ),

      // Scaffold
      scaffoldBackgroundColor:
          Color.lerp(AppColors.darkBackground, primary, .15),

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light, // For Android (light icons)
          statusBarBrightness: Brightness.dark, // For iOS (light icons)
          systemNavigationBarIconBrightness: Brightness.light,
        ),
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
            Color.lerp(AppColors.darkCard, primary, .1) ?? AppColors.darkCard,
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
        foregroundColor: Color.lerp(const Color(0xFF003D57), primary, .1),
        elevation: 4,
        highlightElevation: 8,
        shape: const CircleBorder(),
      ),

      // Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor:
            Color.lerp(AppColors.darkCard, primary, .1) ?? AppColors.darkCard,
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
        fillColor: Color.lerp(AppColors.darkSurface, primary, .1) ??
            AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: (Color.lerp(AppColors.darkBorder, primary, .1) ??
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
        color: Color.lerp(AppColors.darkDivider, primary, .1),
        thickness: 1,
        space: 1,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: Color.lerp(AppColors.darkSurface, primary, .1) ??
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
