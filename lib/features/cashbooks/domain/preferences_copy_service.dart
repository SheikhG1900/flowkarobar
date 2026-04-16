import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';

/// Service for copying preferences between cashbooks
class PreferencesCopyService {
  /// Copy all preferences from source cashbook to target cashbook
  /// This includes: user profile, dashboard widget prefs, language, date format,
  /// fonts, currency catalog, selected currency, and message templates
  static Future<void> copyPreferences(
    String sourceCashbookId,
    String targetCashbookId,
    List<Cashbook> cashbooks,
  ) async {
    final sourceCashbook = cashbooks.firstWhere((c) => c.id == sourceCashbookId);
    final targetCashbook = cashbooks.firstWhere((c) => c.id == targetCashbookId);

    // Open source and target databases (physical files use '.db' extension)
    final sourceDb = AppDatabase(fileName: '${sourceCashbook.dbPath}.db');
    final targetDb = AppDatabase(fileName: '${targetCashbook.dbPath}.db');

    try {
      final sourceRepo = UserPreferencesRepository(sourceDb);
      final targetRepo = UserPreferencesRepository(targetDb);

      // Copy user profile
      await copyUserProfile(sourceRepo, targetRepo);

      await _copyDateAndFontsData(sourceRepo, targetRepo);
      await _copyAllAppCurrencyRows(sourceDb, targetDb);
      await _copySelectedCurrencyPrefs(sourceRepo, targetRepo);

      // Copy message templates
      await copyMessageTemplates(sourceDb, targetDb);

      await _copyDashboardWidgetPreferences(sourceRepo, targetRepo);
    } finally {
      await sourceDb.close();
      await targetDb.close();
    }
  }

  /// Dashboard layout, visibility toggles, bottom-bar quick action, and related keys.
  static Future<void> _copyDashboardWidgetPreferences(
    UserPreferencesRepository sourceRepo,
    UserPreferencesRepository targetRepo,
  ) async {
    final layout = await sourceRepo
        .getPreference(UserPreferencesRepository.keyDashboardWidgetLayout);
    if (layout != null && layout.isNotEmpty) {
      await targetRepo.setPreference(
        UserPreferencesRepository.keyDashboardWidgetLayout,
        layout,
      );
    }
    await _copyPreferenceKeyIfPresent(
      sourceRepo,
      targetRepo,
      UserPreferencesRepository.keyShowDashboardWidgetArea,
    );
    await _copyPreferenceKeyIfPresent(
      sourceRepo,
      targetRepo,
      UserPreferencesRepository.keyShowDashboardPrivacyHighlight,
    );
    await _copyPreferenceKeyIfPresent(
      sourceRepo,
      targetRepo,
      UserPreferencesRepository.keyShowDashboardFinancialSummary,
    );
    await _copyPreferenceKeyIfPresent(
      sourceRepo,
      targetRepo,
      UserPreferencesRepository.keyBottomBarQuickAction,
    );
    await _copyPreferenceKeyIfPresent(
      sourceRepo,
      targetRepo,
      UserPreferencesRepository.keyShowBottomBarQuickButton,
    );
  }

  static Future<void> _copyPreferenceKeyIfPresent(
    UserPreferencesRepository sourceRepo,
    UserPreferencesRepository targetRepo,
    String key,
  ) async {
    final value = await sourceRepo.getPreference(key);
    if (value != null) {
      await targetRepo.setPreference(key, value);
    }
  }

  /// Copy dashboard-related preferences from Drift per-cashbook DB only (layout, toggles, quick action).
  /// Does not copy SharedPreferences hero-combine selection.
  static Future<void> copyDashboardWidgetsOnly(
    String sourceCashbookId,
    String targetCashbookId,
    List<Cashbook> cashbooks,
  ) async {
    final sourceCashbook = cashbooks.firstWhere((c) => c.id == sourceCashbookId);
    final targetCashbook = cashbooks.firstWhere((c) => c.id == targetCashbookId);

    final sourceDb = AppDatabase(fileName: '${sourceCashbook.dbPath}.db');
    final targetDb = AppDatabase(fileName: '${targetCashbook.dbPath}.db');

    try {
      final sourceRepo = UserPreferencesRepository(sourceDb);
      final targetRepo = UserPreferencesRepository(targetDb);
      await _copyDashboardWidgetPreferences(sourceRepo, targetRepo);
    } finally {
      await sourceDb.close();
      await targetDb.close();
    }
  }

  /// Copy only user profile (name, email, phone, address)
  static Future<void> copyUserProfile(
    UserPreferencesRepository sourceRepo,
    UserPreferencesRepository targetRepo,
  ) async {
    final name = await sourceRepo.getUserName();
    final email = await sourceRepo.getUserEmail();
    final phone = await sourceRepo.getUserPhone();
    final address = await sourceRepo.getUserAddress();

    if (name != null) await targetRepo.setUserName(name);
    if (email != null) await targetRepo.setUserEmail(email);
    if (phone != null) await targetRepo.setUserPhone(phone);
    if (address != null) await targetRepo.setUserAddress(address);
  }

  /// Date format, app language, and per-language fonts.
  static Future<void> _copyDateAndFontsData(
    UserPreferencesRepository sourceRepo,
    UserPreferencesRepository targetRepo,
  ) async {
    final language = await sourceRepo.getLanguage();
    final dateFormat = await sourceRepo.getDateFormat();
    final fontEn = await sourceRepo.getFontForLanguage('en');
    final fontHi = await sourceRepo.getFontForLanguage('hi');
    final fontUr = await sourceRepo.getFontForLanguage('ur');

    await targetRepo.setLanguage(language);
    await targetRepo.setDateFormat(dateFormat);
    await targetRepo.setFontForLanguage('en', fontEn);
    await targetRepo.setFontForLanguage('hi', fontHi);
    await targetRepo.setFontForLanguage('ur', fontUr);
  }

  /// Replaces all rows in [targetDb] `app_currencies` with those from [sourceDb]
  /// (same UUIDs; insert or replace).
  static Future<void> _copyAllAppCurrencyRows(
    AppDatabase sourceDb,
    AppDatabase targetDb,
  ) async {
    final rows = await sourceDb.select(sourceDb.appCurrencies).get();
    for (final row in rows) {
      await targetDb.into(targetDb.appCurrencies).insert(
            row,
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  /// Selected currency UUID (for summaries / formatting) and legacy code string.
  static Future<void> _copySelectedCurrencyPrefs(
    UserPreferencesRepository sourceRepo,
    UserPreferencesRepository targetRepo,
  ) async {
    final uuid =
        await sourceRepo.getPreference(UserPreferencesRepository.keySelectedCurrencyId);
    if (uuid != null && uuid.isNotEmpty) {
      await targetRepo.setPreference(
        UserPreferencesRepository.keySelectedCurrencyId,
        uuid,
      );
    }
    final currency = await sourceRepo.getCurrency();
    await targetRepo.setCurrency(currency);
  }

  /// Copy date format and fonts from source cashbook to target (no currency).
  static Future<void> copyDateAndFontsOnly(
    String sourceCashbookId,
    String targetCashbookId,
    List<Cashbook> cashbooks,
  ) async {
    final sourceCashbook = cashbooks.firstWhere((c) => c.id == sourceCashbookId);
    final targetCashbook = cashbooks.firstWhere((c) => c.id == targetCashbookId);

    final sourceDb = AppDatabase(fileName: '${sourceCashbook.dbPath}.db');
    final targetDb = AppDatabase(fileName: '${targetCashbook.dbPath}.db');

    try {
      final sourceRepo = UserPreferencesRepository(sourceDb);
      final targetRepo = UserPreferencesRepository(targetDb);
      await _copyDateAndFontsData(sourceRepo, targetRepo);
    } finally {
      await sourceDb.close();
      await targetDb.close();
    }
  }

  /// Copy every [AppCurrency] row from source DB to target (catalog).
  static Future<void> copyAllCurrenciesOnly(
    String sourceCashbookId,
    String targetCashbookId,
    List<Cashbook> cashbooks,
  ) async {
    final sourceCashbook = cashbooks.firstWhere((c) => c.id == sourceCashbookId);
    final targetCashbook = cashbooks.firstWhere((c) => c.id == targetCashbookId);

    final sourceDb = AppDatabase(fileName: '${sourceCashbook.dbPath}.db');
    final targetDb = AppDatabase(fileName: '${targetCashbook.dbPath}.db');

    try {
      await _copyAllAppCurrencyRows(sourceDb, targetDb);
    } finally {
      await sourceDb.close();
      await targetDb.close();
    }
  }

  /// Copy which currency is selected (UUID + legacy code) from source to target.
  static Future<void> copySelectedCurrencyOnly(
    String sourceCashbookId,
    String targetCashbookId,
    List<Cashbook> cashbooks,
  ) async {
    final sourceCashbook = cashbooks.firstWhere((c) => c.id == sourceCashbookId);
    final targetCashbook = cashbooks.firstWhere((c) => c.id == targetCashbookId);

    final sourceDb = AppDatabase(fileName: '${sourceCashbook.dbPath}.db');
    final targetDb = AppDatabase(fileName: '${targetCashbook.dbPath}.db');

    try {
      final sourceRepo = UserPreferencesRepository(sourceDb);
      final targetRepo = UserPreferencesRepository(targetDb);
      await _copySelectedCurrencyPrefs(sourceRepo, targetRepo);
    } finally {
      await sourceDb.close();
      await targetDb.close();
    }
  }

  /// Copy all message templates
  static Future<void> copyMessageTemplates(
    AppDatabase sourceDb,
    AppDatabase targetDb,
  ) async {
    final sourceRepo = UserPreferencesRepository(sourceDb);
    final targetRepo = UserPreferencesRepository(targetDb);

    // Get all preferences from source
    final allPrefs = await sourceRepo.getAllPreferences();

    // Filter for message templates
    final templates = allPrefs.entries
        .where((entry) => entry.key.startsWith('message_template_'))
        .toList();

    // Copy each template to target
    for (final template in templates) {
      await targetRepo.setPreference(template.key, template.value);
    }
  }

  /// Copy only message templates
  static Future<void> copyMessageTemplatesOnly(
    String sourceCashbookId,
    String targetCashbookId,
    List<Cashbook> cashbooks,
  ) async {
    final sourceCashbook = cashbooks.firstWhere((c) => c.id == sourceCashbookId);
    final targetCashbook = cashbooks.firstWhere((c) => c.id == targetCashbookId);

    final sourceDb = AppDatabase(fileName: '${sourceCashbook.dbPath}.db');
    final targetDb = AppDatabase(fileName: '${targetCashbook.dbPath}.db');

    try {
      await copyMessageTemplates(sourceDb, targetDb);
    } finally {
      await sourceDb.close();
      await targetDb.close();
    }
  }

  /// Copy only user profile
  static Future<void> copyUserProfileOnly(
    String sourceCashbookId,
    String targetCashbookId,
    List<Cashbook> cashbooks,
  ) async {
    final sourceCashbook = cashbooks.firstWhere((c) => c.id == sourceCashbookId);
    final targetCashbook = cashbooks.firstWhere((c) => c.id == targetCashbookId);

    final sourceDb = AppDatabase(fileName: '${sourceCashbook.dbPath}.db');
    final targetDb = AppDatabase(fileName: '${targetCashbook.dbPath}.db');

    try {
      final sourceRepo = UserPreferencesRepository(sourceDb);
      final targetRepo = UserPreferencesRepository(targetDb);
      await copyUserProfile(sourceRepo, targetRepo);
    } finally {
      await sourceDb.close();
      await targetDb.close();
    }
  }

  /// Copy all non-deleted contacts from source to target.
  /// Upserts by [Contact.uuid]; preserves [Contact.addSeq] and other fields.
  static Future<void> copyContacts(
    AppDatabase sourceDb,
    AppDatabase targetDb,
  ) async {
    final sourceContacts = await (sourceDb.select(sourceDb.contacts)
          ..where((c) => c.isDeleted.equals(false)))
        .get();

    for (final c in sourceContacts) {
      await targetDb.into(targetDb.contacts).insert(
            c.copyWith(isDeleted: false, isNotSynced: true),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  /// Copy all non-deleted categories from source to target.
  /// Upserts by [Category.uuid]; preserves budgets and [addSeq] / [budgetSeq].
  static Future<void> copyCategories(
    AppDatabase sourceDb,
    AppDatabase targetDb,
  ) async {
    final sourceCategories = await (sourceDb.select(sourceDb.categories)
          ..where((c) => c.isDeleted.equals(false)))
        .get();

    for (final c in sourceCategories) {
      await targetDb.into(targetDb.categories).insert(
            c.copyWith(isDeleted: false, isNotSynced: true),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  /// Copy only contacts from source cashbook to target cashbook.
  static Future<void> copyContactsOnly(
    String sourceCashbookId,
    String targetCashbookId,
    List<Cashbook> cashbooks,
  ) async {
    final sourceCashbook = cashbooks.firstWhere((c) => c.id == sourceCashbookId);
    final targetCashbook = cashbooks.firstWhere((c) => c.id == targetCashbookId);

    final sourceDb = AppDatabase(fileName: '${sourceCashbook.dbPath}.db');
    final targetDb = AppDatabase(fileName: '${targetCashbook.dbPath}.db');

    try {
      await copyContacts(sourceDb, targetDb);
    } finally {
      await sourceDb.close();
      await targetDb.close();
    }
  }

  /// Copy only categories from source cashbook to target cashbook.
  static Future<void> copyCategoriesOnly(
    String sourceCashbookId,
    String targetCashbookId,
    List<Cashbook> cashbooks,
  ) async {
    final sourceCashbook = cashbooks.firstWhere((c) => c.id == sourceCashbookId);
    final targetCashbook = cashbooks.firstWhere((c) => c.id == targetCashbookId);

    final sourceDb = AppDatabase(fileName: '${sourceCashbook.dbPath}.db');
    final targetDb = AppDatabase(fileName: '${targetCashbook.dbPath}.db');

    try {
      await copyCategories(sourceDb, targetDb);
    } finally {
      await sourceDb.close();
      await targetDb.close();
    }
  }
}
