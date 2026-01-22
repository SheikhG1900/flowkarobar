import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';

/// Service for copying preferences between cashbooks
class PreferencesCopyService {
  /// Copy all preferences from source cashbook to target cashbook
  /// This includes: user profile, date format, currency, and all message templates
  static Future<void> copyPreferences(
    String sourceCashbookId,
    String targetCashbookId,
    List<Cashbook> cashbooks,
  ) async {
    final sourceCashbook = cashbooks.firstWhere((c) => c.id == sourceCashbookId);
    final targetCashbook = cashbooks.firstWhere((c) => c.id == targetCashbookId);

    // Open source and target databases
    final sourceDb = AppDatabase(fileName: sourceCashbook.dbPath);
    final targetDb = AppDatabase(fileName: targetCashbook.dbPath);

    try {
      final sourceRepo = UserPreferencesRepository(sourceDb);
      final targetRepo = UserPreferencesRepository(targetDb);

      // Copy user profile
      await copyUserProfile(sourceRepo, targetRepo);

      // Copy preferences (date format, currency, fonts)
      await _copyPreferencesData(sourceRepo, targetRepo);

      // Copy message templates
      await copyMessageTemplates(sourceDb, targetDb);
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

  /// Copy preferences (date format, currency, fonts)
  static Future<void> _copyPreferencesData(
    UserPreferencesRepository sourceRepo,
    UserPreferencesRepository targetRepo,
  ) async {
    final dateFormat = await sourceRepo.getDateFormat();
    final currency = await sourceRepo.getCurrency();
    final fontEn = await sourceRepo.getFontForLanguage('en');
    final fontHi = await sourceRepo.getFontForLanguage('hi');
    final fontUr = await sourceRepo.getFontForLanguage('ur');

    await targetRepo.setDateFormat(dateFormat);
    await targetRepo.setCurrency(currency);
    await targetRepo.setFontForLanguage('en', fontEn);
    await targetRepo.setFontForLanguage('hi', fontHi);
    await targetRepo.setFontForLanguage('ur', fontUr);
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

    final sourceDb = AppDatabase(fileName: sourceCashbook.dbPath);
    final targetDb = AppDatabase(fileName: targetCashbook.dbPath);

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

    final sourceDb = AppDatabase(fileName: sourceCashbook.dbPath);
    final targetDb = AppDatabase(fileName: targetCashbook.dbPath);

    try {
      final sourceRepo = UserPreferencesRepository(sourceDb);
      final targetRepo = UserPreferencesRepository(targetDb);
      await copyUserProfile(sourceRepo, targetRepo);
    } finally {
      await sourceDb.close();
      await targetDb.close();
    }
  }
}
