import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:uuid/uuid.dart';

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

    // Open source and target databases (physical files use '.db' extension)
    final sourceDb = AppDatabase(fileName: '${sourceCashbook.dbPath}.db');
    final targetDb = AppDatabase(fileName: '${targetCashbook.dbPath}.db');

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

  /// Copy all non-deleted contacts from source to target (with new UUIDs).
  static Future<void> copyContacts(
    AppDatabase sourceDb,
    AppDatabase targetDb,
  ) async {
    final sourceContacts = await (sourceDb.select(sourceDb.contacts)
          ..where((c) => c.isDeleted.equals(false)))
        .get();

    for (final c in sourceContacts) {
      await targetDb.into(targetDb.contacts).insert(
            ContactsCompanion.insert(
              uuid: const Uuid().v4(),
              name: c.name,
              phone: Value(c.phone),
              email: Value(c.email),
              notes: Value(c.notes),
              createdAt: Value(c.createdAt),
              updatedAt: Value(c.updatedAt),
              isDeleted: const Value(false),
              isNotSynced: const Value(true),
            ),
          );
    }
  }

  /// Copy all non-deleted categories from source to target.
  /// Default categories keep the same UUID and use insertOrIgnore to avoid duplicates.
  /// Non-default categories get new UUIDs.
  static Future<void> copyCategories(
    AppDatabase sourceDb,
    AppDatabase targetDb,
  ) async {
    final sourceCategories = await (sourceDb.select(sourceDb.categories)
          ..where((c) => c.isDeleted.equals(false)))
        .get();

    for (final c in sourceCategories) {
      final useSameUuid = c.isDefault;
      final uuid = useSameUuid ? c.uuid : const Uuid().v4();
      await targetDb.into(targetDb.categories).insert(
            CategoriesCompanion.insert(
              uuid: uuid,
              name: c.name,
              icon: Value(c.icon),
              color: Value(c.color),
              type: c.type,
              isDefault: Value(c.isDefault),
              isDeleted: const Value(false),
              createdAt: Value(c.createdAt),
              updatedAt: Value(c.updatedAt),
              isNotSynced: const Value(true),
            ),
          mode: useSameUuid ? InsertMode.insertOrIgnore : InsertMode.insert,
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
