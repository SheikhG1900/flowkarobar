import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';

import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';

// User Preferences Repository Provider
final userPreferencesRepositoryProvider =
    Provider<UserPreferencesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return UserPreferencesRepository(db);
});

// Language State Provider
class LanguageNotifier extends Notifier<Locale> {
  late UserPreferencesRepository _repository;

  @override
  Locale build() {
    _repository = ref.watch(userPreferencesRepositoryProvider);
    _loadLanguage();
    return const Locale('en', 'US');
  }

  Future<void> _loadLanguage() async {
    final languageCode = await _repository.getLanguage();
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('startup_language', languageCode);
    } catch (_) {}
    state = _getLocaleFromCode(languageCode);
  }

  Locale _getLocaleFromCode(String code) {
    switch (code) {
      case 'hi':
        return const Locale('hi', 'IN');
      case 'ur':
        return const Locale('ur', 'PK');
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    await _repository.setLanguage(languageCode);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('startup_language', languageCode);
    } catch (_) {}
    state = _getLocaleFromCode(languageCode);
  }

  String getCurrentLanguageCode() {
    return state.languageCode;
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, Locale>(() {
  return LanguageNotifier();
});

// Theme Mode State Provider
class ThemeModeNotifier extends Notifier<ThemeMode> {
  late UserPreferencesRepository _repository;

  @override
  ThemeMode build() {
    _repository = ref.watch(userPreferencesRepositoryProvider);
    _loadThemeMode();
    return ThemeMode.system;
  }

  Future<void> _loadThemeMode() async {
    final mode = await _repository.getThemeMode();
    state = _getThemeModeFromString(mode);
  }

  ThemeMode _getThemeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _repository.setThemeMode(_getStringFromThemeMode(mode));
    state = mode;
  }

  String getCurrentThemeModeString() {
    return _getStringFromThemeMode(state);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

// User Profile State Provider
class UserProfileState {
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String currency;
  final String dateFormat;

  UserProfileState({
    this.name,
    this.email,
    this.phone,
    this.address,
    this.currency = 'INR',
    this.dateFormat = 'MMM dd, yyyy',
  });

  UserProfileState copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? currency,
    String? dateFormat,
  }) {
    return UserProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
    );
  }
}

// User Profile Notifier
class UserProfileNotifier extends Notifier<UserProfileState> {
  late UserPreferencesRepository _repository;

  @override
  UserProfileState build() {
    _repository = ref.watch(userPreferencesRepositoryProvider);
    _loadProfile();
    return UserProfileState();
  }

  Future<void> _loadProfile() async {
    final name = await _repository.getUserName();
    final email = await _repository.getUserEmail();
    final phone = await _repository.getUserPhone();
    final address = await _repository.getUserAddress();
    final currency = await _repository.getCurrency();
    final dateFormat = await _repository.getDateFormat();

    state = UserProfileState(
      name: name,
      email: email,
      phone: phone,
      address: address,
      currency: currency,
      dateFormat: dateFormat,
    );
  }

  Future<void> updateName(String name) async {
    await _repository.setUserName(name);
    state = state.copyWith(name: name);
  }

  Future<void> updateEmail(String email) async {
    await _repository.setUserEmail(email);
    state = state.copyWith(email: email);
  }

  Future<void> updatePhone(String phone) async {
    await _repository.setUserPhone(phone);
    state = state.copyWith(phone: phone);
  }

  Future<void> updateAddress(String address) async {
    await _repository.setUserAddress(address);
    state = state.copyWith(address: address);
  }

  Future<void> updateCurrency(String currency) async {
    await _repository.setCurrency(currency);
    state = state.copyWith(currency: currency);
  }

  Future<void> updateDateFormat(String dateFormat) async {
    await _repository.setDateFormat(dateFormat);
    state = state.copyWith(dateFormat: dateFormat);
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileState>(() {
  return UserProfileNotifier();
});

// Font State Notifier
class FontNotifier extends Notifier<Map<String, String>> {
  late UserPreferencesRepository _repository;

  @override
  Map<String, String> build() {
    _repository = ref.watch(userPreferencesRepositoryProvider);
    _loadFonts();
    return {
      'en': 'Inter',
      'hi': 'Noto Sans Devanagari',
      'ur': 'Marhey',
    }; // Initial default state
  }

  Future<void> _loadFonts() async {
    try {
      final en = await _repository.getFontForLanguage('en');
      final hi = await _repository.getFontForLanguage('hi');
      final ur = await _repository.getFontForLanguage('ur');
      try {
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.setString('startup_font_en', en);
        await prefs.setString('startup_font_hi', hi);
        await prefs.setString('startup_font_ur', ur);
      } catch (_) {}
      state = {
        'en': en.isEmpty ? 'Inter' : en,
        'hi': hi.isEmpty ? 'Noto Sans Devanagari' : hi,
        'ur': ur.isEmpty ? 'Marhey' : ur,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in _loadFonts: $e');
      }
    }
  }

  Future<void> setFont(String languageCode, String fontName) async {
    await _repository.setFontForLanguage(languageCode, fontName);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('startup_font_$languageCode', fontName);
    } catch (_) {}
    state = {...state, languageCode: fontName};
    
    // Smooth preloading of the selected font upon actual selection
    try {
      await GoogleFonts.pendingFonts([
        GoogleFonts.getFont(fontName),
      ]);
    } catch (_) {}
  }
}

final fontProvider = NotifierProvider<FontNotifier, Map<String, String>>(() {
  return FontNotifier();
});

// Bottom Bar Quick Action Notifier
class BottomBarQuickActionNotifier extends Notifier<String> {
  late UserPreferencesRepository _repository;

  @override
  String build() {
    _repository = ref.watch(userPreferencesRepositoryProvider);
    _loadAction();
    return 'add_transaction'; // Default initial state
  }

  Future<void> _loadAction() async {
    state = await _repository.getBottomBarQuickAction();
  }

  Future<void> setAction(String actionCode) async {
    await _repository.setBottomBarQuickAction(actionCode);
    state = actionCode;
  }
}

final bottomBarQuickActionProvider =
    NotifierProvider<BottomBarQuickActionNotifier, String>(() {
  return BottomBarQuickActionNotifier();
});

// Show Bottom Bar Quick Button Notifier
class ShowBottomBarQuickButtonNotifier extends Notifier<bool> {
  late UserPreferencesRepository _repository;

  @override
  bool build() {
    _repository = ref.watch(userPreferencesRepositoryProvider);
    _loadVisibility();
    return true; // Default initial state
  }

  Future<void> _loadVisibility() async {
    state = await _repository.getShowBottomBarQuickButton();
  }

  Future<void> setVisibility(bool show) async {
    await _repository.setShowBottomBarQuickButton(show);
    state = show;
  }
}

final showBottomBarQuickButtonProvider =
    NotifierProvider<ShowBottomBarQuickButtonNotifier, bool>(() {
  return ShowBottomBarQuickButtonNotifier();
});

// Show Dashboard Widget Area Notifier
class ShowDashboardWidgetAreaNotifier extends Notifier<bool> {
  late UserPreferencesRepository _repository;

  @override
  bool build() {
    _repository = ref.watch(userPreferencesRepositoryProvider);
    _loadVisibility();
    return false; // Default to hidden while loading
  }

  Future<void> _loadVisibility() async {
    final value = await _repository.getPreference(UserPreferencesRepository.keyShowDashboardWidgetArea);
    if (value != null) {
      state = value != 'false';
    } else {
      state = true; // Default to true if no preference is set
    }
  }

  Future<void> setVisibility(bool show) async {
    await _repository.setShowDashboardWidgetArea(show);
    state = show;
  }
}

final showDashboardWidgetAreaProvider =
    NotifierProvider<ShowDashboardWidgetAreaNotifier, bool>(() {
  return ShowDashboardWidgetAreaNotifier();
});

// Show Dashboard Privacy Highlight Notifier
class ShowDashboardPrivacyHighlightNotifier extends Notifier<bool> {
  late UserPreferencesRepository _repository;

  @override
  bool build() {
    _repository = ref.watch(userPreferencesRepositoryProvider);
    _loadVisibility();
    return false; // Default to hidden while loading
  }

  Future<void> _loadVisibility() async {
    final value = await _repository.getPreference(UserPreferencesRepository.keyShowDashboardPrivacyHighlight);
    if (value != null) {
      state = value != 'false';
    } else {
      state = true; // Default to true if no preference is set
    }
  }

  Future<void> setVisibility(bool show) async {
    await _repository.setShowDashboardPrivacyHighlight(show);
    state = show;
  }
}

final showDashboardPrivacyHighlightProvider =
    NotifierProvider<ShowDashboardPrivacyHighlightNotifier, bool>(() {
  return ShowDashboardPrivacyHighlightNotifier();
});

// Show Dashboard Financial Summary Notifier
class ShowDashboardFinancialSummaryNotifier extends Notifier<bool> {
  late UserPreferencesRepository _repository;

  @override
  bool build() {
    _repository = ref.watch(userPreferencesRepositoryProvider);
    _loadVisibility();
    return false; // Default to hidden while loading
  }

  Future<void> _loadVisibility() async {
    final value = await _repository.getPreference(UserPreferencesRepository.keyShowDashboardFinancialSummary);
    if (value != null) {
      state = value != 'false';
    } else {
      state = true; // Default to true if no preference is set
    }
  }

  Future<void> setVisibility(bool show) async {
    await _repository.setShowDashboardFinancialSummary(show);
    state = show;
  }
}

final showDashboardFinancialSummaryProvider =
    NotifierProvider<ShowDashboardFinancialSummaryNotifier, bool>(() {
  return ShowDashboardFinancialSummaryNotifier();
});

// Show Dashboard Sync Status State Provider
class ShowDashboardSyncStatusNotifier extends Notifier<bool> {
  static const String _key = 'show_dashboard_sync_status';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false; // Default to false (hidden)
  }

  Future<void> setVisibility(bool show) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, show);
    state = show;
  }

  void toggle() {
    setVisibility(!state);
  }
}

final showDashboardSyncStatusProvider =
    NotifierProvider<ShowDashboardSyncStatusNotifier, bool>(() {
  return ShowDashboardSyncStatusNotifier();
});

// Auto Sync on Startup Notifier
class AutoSyncOnStartupNotifier extends Notifier<bool> {
  static const String _key = 'auto_sync_on_startup';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? true; // Default to true
  }

  Future<void> setAutoSync(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, value);
    state = value;
  }
}

final autoSyncOnStartupProvider =
    NotifierProvider<AutoSyncOnStartupNotifier, bool>(() {
  return AutoSyncOnStartupNotifier();
});

// Helper provider to get the font for the CURRENT language
final currentFontProvider = Provider<String>((ref) {
  Map<String, String>? fonts;
  try {
    fonts = ref.watch(fontProvider);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Error watching fontProvider in currentFontProvider: $e');
    }
  }

  final currentLocale = ref.watch(languageProvider);
  final isPremium = ref.watch(premiumProvider).isPremiumActive;
  
  final font = fonts?[currentLocale.languageCode];
  if (currentLocale.languageCode == 'ur' && font == 'Marhey' && isPremium) {
    return 'Kufam';
  }
  return font ?? 'Inter';
});

// Text Scale Factor Notifier (Device-specific, saved to SharedPreferences)
class TextScaleNotifier extends Notifier<double> {
  static const String _key = 'device_text_scale_factor';

  @override
  double build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getDouble(_key) ?? 1.0; // Default to 1.0 (100%)
    // Clamp inside safe limits to prevent visual breakages if legacy value exists
    return value.clamp(0.5, 2.0);
  }

  Future<void> setTextScale(double value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(_key, value);
    state = value;
  }
}

final textScaleProvider = NotifierProvider<TextScaleNotifier, double>(() {
  return TextScaleNotifier();
});

// Letter Spacing Notifier (Device-specific, saved to SharedPreferences)
class LetterSpacingNotifier extends Notifier<double> {
  static const String _key = 'device_letter_spacing';

  @override
  double build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getDouble(_key) ?? 0.0; // Default to 0.0
    return value.clamp(-2.0, 5.0);
  }

  Future<void> setLetterSpacing(double value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(_key, value);
    state = value;
  }
}

final letterSpacingProvider = NotifierProvider<LetterSpacingNotifier, double>(() {
  return LetterSpacingNotifier();
});

// Line Spacing (Height) Notifier (Device-specific, saved to SharedPreferences)
class LineSpacingNotifier extends Notifier<double> {
  static const String _key = 'device_line_spacing';

  @override
  double build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getDouble(_key) ?? 1.2; // Default to 1.2
    return value.clamp(0.8, 3.0);
  }

  Future<void> setLineSpacing(double value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setDouble(_key, value);
    state = value;
  }
}

final lineSpacingProvider = NotifierProvider<LineSpacingNotifier, double>(() {
  return LineSpacingNotifier();
});
