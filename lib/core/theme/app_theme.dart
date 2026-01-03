import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF2196F3); // Blue
  static const Color secondaryColor = Color(0xFF4CAF50); // Green
  static const Color accentColor = Color(0xFFFF9800); // Orange
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color warningColor = Color(0xFFFFC107); // Yellow
  
  static const Color incomeColor = Color(0xFF4CAF50); // Green
  static const Color expenseColor = Color(0xFFF44336); // Red
  static const Color receivableColor = Color(0xFF2196F3); // Blue
  static const Color payableColor = Color(0xFFFF9800); // Orange
  
  // Get text theme based on locale
  static TextTheme getTextTheme(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return GoogleFonts.notoSansDevanagariTextTheme().copyWith(
          bodyLarge: GoogleFonts.notoSansDevanagari(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: GoogleFonts.notoSansDevanagari(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          titleLarge: GoogleFonts.notoSansDevanagari(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          titleMedium: GoogleFonts.notoSansDevanagari(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        );
      
      case 'ur':
        return GoogleFonts.notoNastaliqUrduTextTheme().copyWith(
          bodyLarge: GoogleFonts.notoNastaliqUrdu(
            fontSize: 18, // Slightly larger for Nastaliq
            fontWeight: FontWeight.w400,
            height: 1.8, // More line height
          ),
          bodyMedium: GoogleFonts.notoNastaliqUrdu(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.8,
          ),
          titleLarge: GoogleFonts.notoNastaliqUrdu(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            height: 1.8,
          ),
          titleMedium: GoogleFonts.notoNastaliqUrdu(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            height: 1.8,
          ),
        );
      
      default: // English
        return GoogleFonts.interTextTheme().copyWith(
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }
  
  // Light Theme
  static ThemeData lightTheme(String languageCode) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: getTextTheme(languageCode),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: getTextTheme(languageCode).titleLarge?.copyWith(
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
  
  // Dark Theme
  static ThemeData darkTheme(String languageCode) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: getTextTheme(languageCode),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        titleTextStyle: getTextTheme(languageCode).titleLarge?.copyWith(
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }
}

