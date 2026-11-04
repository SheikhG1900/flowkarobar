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
  /// UUID of selected row in [AppCurrencies] (same key as [currency_provider]).
  static const String keySelectedCurrencyId = 'selected_currency_id';
  static const String keyDateFormat = 'date_format';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyUserPhone = 'user_phone';
  static const String keyUserAddress = 'user_address';
  static const String keyBusinessTaxId = 'business_tax_id';
  static const String keyDefaultInvoiceNotes = 'default_invoice_notes';
  static const String keyFontEn = 'font_en';
  static const String keyFontHi = 'font_hi';
  static const String keyFontUr = 'font_ur';
  static const String keyDashboardWidgetLayout = 'dashboard_widget_layout';
  static const String keyAutoSuggestTransactionScenario =
      'auto_suggest_transaction_scenario';
  static const String keyIncludeUncategorizedInCategorySummary =
      'include_uncategorized_in_category_summary';
  static const String keyBottomBarQuickAction = 'bottom_bar_quick_action';
  static const String keyShowBottomBarQuickButton =
      'show_bottom_bar_quick_button';
  static const String keyShowDashboardWidgetArea = 'show_dashboard_widget_area';
  static const String keyShowDashboardPrivacyHighlight =
      'show_dashboard_privacy_highlight';
  static const String keyShowDashboardFinancialSummary =
      'show_dashboard_financial_summary';
  static const String keySummaryViewMode = 'summary_view_mode';
  static const String keySequenceBackfillDone = 'sequence_backfill_done';

  // Get a preference value by key (excludes soft-deleted rows so they sync correctly)
  Future<String?> getPreference(String key) async {
    final result = await (_db.select(_db.userPreferences)
          ..where((tbl) =>
              tbl.key.equals(key) & tbl.isDeleted.equals(false)))
        .getSingleOrNull();
    return result?.value;
  }

  /// [markUnsynced] when true (default), the row is marked for sync (dirty).
  /// Pass false for initial/default data (e.g. first-install defaults) so it stays clean.
  Future<void> setPreference(String key, String value,
      {bool markUnsynced = true}) async {
    // Check if preference exists (including soft-deleted, so we can resurrect)
    final row = await (_db.select(_db.userPreferences)
          ..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();

    final isDirty = Value(markUnsynced);

    if (row != null) {
      // Update existing row (resurrect if soft-deleted)
      await (_db.update(_db.userPreferences)
            ..where((tbl) => tbl.key.equals(key)))
          .write(
        UserPreferencesCompanion(
          value: Value(value),
          updatedAt: Value(DateTime.now()),
          isDeleted: const Value(false),
          isNotSynced: isDirty,
        ),
      );
    } else {
      // Insert new preference
      await _db.into(_db.userPreferences).insert(
            UserPreferencesCompanion(
              key: Value(key),
              value: Value(value),
              updatedAt: Value(DateTime.now()),
              isNotSynced: isDirty,
            ),
          );
    }
  }

  // Delete a preference (soft delete so sync can propagate to other devices)
  Future<void> deletePreference(String key) async {
    await (_db.update(_db.userPreferences)
          ..where((tbl) => tbl.key.equals(key)))
        .write(
      UserPreferencesCompanion(
        isDeleted: const Value(true),
        isNotSynced: const Value(true),
      ),
    );
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
    return value ?? 'MMM dd, yyyy'; // Default to MMM dd, yyyy format
  }

  Future<void> setDateFormat(String format) async {
    await setPreference(keyDateFormat, format);
  }

  /// Auto-show transaction scenario picker when user opens Add Transaction
  /// manually. Default true for new users.
  Future<bool> getAutoSuggestTransactionScenario() async {
    final value =
        await getPreference(keyAutoSuggestTransactionScenario);
    return value != 'false';
  }

  Future<void> setAutoSuggestTransactionScenario(bool value) async {
    await setPreference(
        keyAutoSuggestTransactionScenario, value ? 'true' : 'false');
  }

  /// When true, category list aggregate total includes uncategorized net.
  Future<bool> getIncludeUncategorizedInCategorySummary() async {
    final value =
        await getPreference(keyIncludeUncategorizedInCategorySummary);
    return value == 'true';
  }

  Future<void> setIncludeUncategorizedInCategorySummary(bool value) async {
    await setPreference(
      keyIncludeUncategorizedInCategorySummary,
      value ? 'true' : 'false',
    );
  }

  /// 'list' or 'chart'
  Future<String> getSummaryViewMode() async {
    final value = await getPreference(keySummaryViewMode);
    return value ?? 'list';
  }

  Future<void> setSummaryViewMode(String mode) async {
    await setPreference(keySummaryViewMode, mode);
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

  Future<String?> getUserAddress() async {
    return await getPreference(keyUserAddress);
  }

  Future<void> setUserAddress(String address) async {
    await setPreference(keyUserAddress, address);
  }

  Future<String?> getBusinessTaxId() async {
    return await getPreference(keyBusinessTaxId);
  }

  Future<void> setBusinessTaxId(String taxId) async {
    await setPreference(keyBusinessTaxId, taxId);
  }

  Future<String?> getDefaultInvoiceNotes() async {
    return await getPreference(keyDefaultInvoiceNotes);
  }

  Future<void> setDefaultInvoiceNotes(String notes) async {
    await setPreference(keyDefaultInvoiceNotes, notes);
  }

  // Font Preferences
  Future<String> getFontForLanguage(String languageCode) async {
    final key = _getFontKeyForLanguage(languageCode);
    final value = await getPreference(key);
    if (value != null) return value;

    // Defaults
    switch (languageCode) {
      case 'hi':
        return 'Noto Sans Devanagari';
      case 'ur':
        return 'Marhey';
      default:
        return 'Inter';
    }
  }

  Future<void> setFontForLanguage(String languageCode, String fontName) async {
    final key = _getFontKeyForLanguage(languageCode);
    await setPreference(key, fontName);
  }

  String _getFontKeyForLanguage(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return keyFontHi;
      case 'ur':
        return keyFontUr;
      default:
        return keyFontEn;
    }
  }

  // Dashboard widget layout (JSON list of DashboardWidgetConfig)
  Future<String?> getDashboardWidgetLayout() async {
    return getPreference(keyDashboardWidgetLayout);
  }

  Future<void> setDashboardWidgetLayout(String jsonValue) async {
    await setPreference(keyDashboardWidgetLayout, jsonValue);
  }

  // Get all preferences as a map (excludes soft-deleted)
  Future<Map<String, String>> getAllPreferences() async {
    final allPrefs = await (_db.select(_db.userPreferences)
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
    return {for (var pref in allPrefs) pref.key: pref.value};
  }

  // Clear all preferences
  Future<void> clearAllPreferences() async {
    await _db.delete(_db.userPreferences).go();
  }

  // Bottom Bar Quick Action
  Future<String> getBottomBarQuickAction() async {
    final value = await getPreference(keyBottomBarQuickAction);
    return value ?? 'add_transaction'; // Default to Add Transaction
  }

  Future<void> setBottomBarQuickAction(String actionCode) async {
    await setPreference(keyBottomBarQuickAction, actionCode);
  }

  // Show Bottom Bar Quick Button
  Future<bool> getShowBottomBarQuickButton() async {
    final value = await getPreference(keyShowBottomBarQuickButton);
    return value != 'false'; // Default to true
  }

  Future<void> setShowBottomBarQuickButton(bool show) async {
    await setPreference(keyShowBottomBarQuickButton, show ? 'true' : 'false');
  }

  // Show Dashboard Widget Area
  Future<bool> getShowDashboardWidgetArea() async {
    final value = await getPreference(keyShowDashboardWidgetArea);
    return value != 'false'; // Default to true
  }

  Future<void> setShowDashboardWidgetArea(bool show) async {
    await setPreference(keyShowDashboardWidgetArea, show ? 'true' : 'false');
  }

  // Show Dashboard Privacy Highlight
  Future<bool> getShowDashboardPrivacyHighlight() async {
    final value = await getPreference(keyShowDashboardPrivacyHighlight);
    return value != 'false'; // Default to true
  }

  Future<void> setShowDashboardPrivacyHighlight(bool show) async {
    await setPreference(
        keyShowDashboardPrivacyHighlight, show ? 'true' : 'false');
  }

  // Show Dashboard Financial Summary
  Future<bool> getShowDashboardFinancialSummary() async {
    final value = await getPreference(keyShowDashboardFinancialSummary);
    return value != 'false'; // Default to true
  }

  Future<void> setShowDashboardFinancialSummary(bool show) async {
    await setPreference(
        keyShowDashboardFinancialSummary, show ? 'true' : 'false');
  }
}
