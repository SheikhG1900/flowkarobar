import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';

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
    final en = await _repository.getFontForLanguage('en');
    final hi = await _repository.getFontForLanguage('hi');
    final ur = await _repository.getFontForLanguage('ur');
    state = {'en': en, 'hi': hi, 'ur': ur};
  }

  Future<void> setFont(String languageCode, String fontName) async {
    await _repository.setFontForLanguage(languageCode, fontName);
    state = {...state, languageCode: fontName};
  }
}

final fontProvider = NotifierProvider<FontNotifier, Map<String, String>>(() {
  return FontNotifier();
});

// Helper provider to get the font for the CURRENT language
final currentFontProvider = Provider<String>((ref) {
  final fonts = ref.watch(fontProvider);
  final currentLocale = ref.watch(languageProvider);
  return fonts[currentLocale.languageCode] ?? 'Inter';
});
