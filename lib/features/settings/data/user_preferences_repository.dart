import 'package:flowpaisa/core/database/database.dart';
import 'package:drift/drift.dart';

// Repository for user preferences
class UserPreferencesRepository {
  final AppDatabase _db;

  UserPreferencesRepository(this._db);

  // Preference Keys
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyCurrency = 'currency';
  static const String keyDateFormat = 'date_format';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserPhone = 'user_phone';

  // Get a preference value by key
  Future<String?> getPreference(String key) async {
    final result = await (_db.select(_db.userPreferences)
          ..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();
    return result?.value;
  }

  // Set a preference value
  Future<void> setPreference(String key, String value) async {
    // Check if preference exists
    final existing = await getPreference(key);

    if (existing != null) {
      // Update existing preference
      await (_db.update(_db.userPreferences)
            ..where((tbl) => tbl.key.equals(key)))
          .write(
        UserPreferencesCompanion(
          value: Value(value),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      // Insert new preference
      await _db.into(_db.userPreferences).insert(
            UserPreferencesCompanion(
              key: Value(key),
              value: Value(value),
              updatedAt: Value(DateTime.now()),
            ),
          );
    }
  }

  // Delete a preference
  Future<void> deletePreference(String key) async {
    await (_db.delete(_db.userPreferences)..where((tbl) => tbl.key.equals(key)))
        .go();
  }

  // Language Preference
  Future<String> getLanguage() async {
    final value = await getPreference(keyLanguage);
    return value ?? 'en'; // Default to English
  }

  Future<void> setLanguage(String languageCode) async {
    await setPreference(keyLanguage, languageCode);
  }

  // Theme Mode Preference
  Future<String> getThemeMode() async {
    final value = await getPreference(keyThemeMode);
    return value ?? 'system'; // Default to system
  }

  Future<void> setThemeMode(String mode) async {
    // mode can be 'light', 'dark', or 'system'
    await setPreference(keyThemeMode, mode);
  }

  // Currency Preference
  Future<String> getCurrency() async {
    final value = await getPreference(keyCurrency);
    return value ?? 'INR'; // Default to Indian Rupee
  }

  Future<void> setCurrency(String currency) async {
    await setPreference(keyCurrency, currency);
  }

  // Date Format Preference
  Future<String> getDateFormat() async {
    final value = await getPreference(keyDateFormat);
    return value ?? 'dd/MM/yyyy'; // Default to Indian format
  }

  Future<void> setDateFormat(String format) async {
    await setPreference(keyDateFormat, format);
  }

  // User Profile Information
  Future<String?> getUserName() async {
    return await getPreference(keyUserName);
  }

  Future<void> setUserName(String name) async {
    await setPreference(keyUserName, name);
  }

  Future<String?> getUserEmail() async {
    return await getPreference(keyUserEmail);
  }

  Future<void> setUserEmail(String email) async {
    await setPreference(keyUserEmail, email);
  }

  Future<String?> getUserPhone() async {
    return await getPreference(keyUserPhone);
  }

  Future<void> setUserPhone(String phone) async {
    await setPreference(keyUserPhone, phone);
  }

  // Get all preferences as a map
  Future<Map<String, String>> getAllPreferences() async {
    final allPrefs = await _db.select(_db.userPreferences).get();
    return {for (var pref in allPrefs) pref.key: pref.value};
  }

  // Clear all preferences
  Future<void> clearAllPreferences() async {
    await _db.delete(_db.userPreferences).go();
  }
}
