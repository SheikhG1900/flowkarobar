import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';

class CashbookNotifier extends Notifier<List<Cashbook>> {
  static const String _storageKey = 'cashbooks_list';

  late SharedPreferences _prefs;

  @override
  List<Cashbook> build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadCashbooks();
  }

  List<Cashbook> _loadCashbooks() {
    final jsonList = _prefs.getStringList(_storageKey);
    if (jsonList == null || jsonList.isEmpty) {
      // Initialize with default cashbook if none exists
      final defaultCashbook = Cashbook(
        id: 'default',
        name: 'Main Cashbook',
        colorCode: '#00D4FF',
        iconCodePoint: Symbols.water_drop.codePoint.toString(),
        dbPath: 'flowpaisa.db',
        createdAt: DateTime.now(),
      );
      _saveCashbooks([defaultCashbook]);
      return [defaultCashbook];
    }

    // Load and migrate legacy icon names if any
    final cashbooks = jsonList.map((json) => Cashbook.fromJson(json)).toList();
    bool needsSave = false;
    final migrated = cashbooks.map((c) {
      if (c.iconCodePoint == 'water_drop') {
        needsSave = true;
        return c.copyWith(
            iconCodePoint: Symbols.water_drop.codePoint.toString());
      }
      return c;
    }).toList();

    if (needsSave) {
      _saveCashbooks(migrated);
    }

    return migrated;
  }

  Future<void> _saveCashbooks(List<Cashbook> cashbooks) async {
    final jsonList = cashbooks.map((c) => c.toJson()).toList();
    await _prefs.setStringList(_storageKey, jsonList);
  }

  Future<void> addCashbook({
    required String name,
    required String colorCode,
    required String iconCodePoint,
  }) async {
    final id = const Uuid().v4();
    final newCashbook = Cashbook(
      id: id,
      name: name,
      colorCode: colorCode,
      iconCodePoint: iconCodePoint,
      dbPath: 'cashbook_$id.db',
      createdAt: DateTime.now(),
    );

    final newList = [...state, newCashbook];
    await _saveCashbooks(newList);
    state = newList;

    // Copy profile data from default cashbook to new cashbook
    final defaultDb = AppDatabase(fileName: 'flowpaisa.db');
    try {
      final defaultRepo = UserPreferencesRepository(defaultDb);
      final profileName = await defaultRepo.getUserName();
      final profileEmail = await defaultRepo.getUserEmail();
      final profilePhone = await defaultRepo.getUserPhone();
      final profileAddress = await defaultRepo.getUserAddress();

      // Only copy if default cashbook has profile data
      if (profileName != null ||
          profileEmail != null ||
          profilePhone != null ||
          profileAddress != null) {
        final newDb = AppDatabase(fileName: newCashbook.dbPath);
        try {
          final newRepo = UserPreferencesRepository(newDb);
          if (profileName != null) await newRepo.setUserName(profileName);
          if (profileEmail != null) await newRepo.setUserEmail(profileEmail);
          if (profilePhone != null) await newRepo.setUserPhone(profilePhone);
          if (profileAddress != null) {
            await newRepo.setUserAddress(profileAddress);
          }
        } finally {
          await newDb.close();
        }
      }
    } finally {
      await defaultDb.close();
    }
  }

  Future<void> updateCashbook(Cashbook updated) async {
    final newList = state.map((c) => c.id == updated.id ? updated : c).toList();
    await _saveCashbooks(newList);
    state = newList;
  }

  Future<void> deleteCashbook(String id) async {
    if (id == 'default') return; // Cannot delete default

    final cashbookToDelete = state.firstWhere((c) => c.id == id);

    // If active, switch to default first
    if (ref.read(activeCashbookIdProvider) == id) {
      await ref
          .read(activeCashbookIdProvider.notifier)
          .setActive(state.first.id);
    }

    final newList = state.where((c) => c.id != id).toList();
    await _saveCashbooks(newList);
    state = newList;

    // Delete the database file and sync metadata
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, cashbookToDelete.dbPath));
      if (await file.exists()) {
        await file.delete();
      }

      // Also clear sync metadata for this cashbook
      final db = AppDatabase(fileName: cashbookToDelete.dbPath);
      try {
        await (db.delete(db.syncMetadata)).go();
      } catch (e) {
        // Ignore if table doesn't exist yet
      } finally {
        await db.close();
      }
    } catch (e) {
      // Log error but continue
      print('Error deleting database file: $e');
    }
  }

  Future<void> clearCashbookData(String id) async {
    final cashbook = state.firstWhere((c) => c.id == id);
    final db = AppDatabase(fileName: cashbook.dbPath);
    try {
      await db.clearAllData();
    } finally {
      await db.close();
    }
  }

  Future<void> restoreCashbookFromFile(String id, File backupFile) async {
    final cashbook = state.firstWhere((c) => c.id == id);
    final isActive = ref.read(activeCashbookIdProvider) == id;

    // Get the target path
    final dbFolder = await getApplicationDocumentsDirectory();
    final targetPath = p.join(dbFolder.path, cashbook.dbPath);

    // If active, we must ensure the database is closed before overwriting
    // In Riverpod, invalidating the provider will trigger its onDispose
    if (isActive) {
      // Importing databaseProvider here would cause circular dependency if not careful
      // But we can use ref.invalidate by name if we have access to it.
      // Instead of direct import, let's assume we can handle it in the UI or use a callback
    }

    // Copy the backup file to the target location
    await backupFile.copy(targetPath);

    // If it was active, the UI should probably refresh or the provider should be invalidated
  }
}

final cashbooksProvider =
    NotifierProvider<CashbookNotifier, List<Cashbook>>(() {
  return CashbookNotifier();
});

class ActiveCashbookIdNotifier extends Notifier<String> {
  static const String _activeIdKey = 'active_cashbook_id';
  late SharedPreferences _prefs;

  @override
  String build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _prefs.getString(_activeIdKey) ?? 'default';
  }

  Future<void> setActive(String id) async {
    await _prefs.setString(_activeIdKey, id);
    state = id;
  }
}

final activeCashbookIdProvider =
    NotifierProvider<ActiveCashbookIdNotifier, String>(() {
  return ActiveCashbookIdNotifier();
});

final activeCashbookProvider = Provider<Cashbook>((ref) {
  final id = ref.watch(activeCashbookIdProvider);
  final list = ref.watch(cashbooksProvider);
  return list.firstWhere((c) => c.id == id, orElse: () => list.first);
});
