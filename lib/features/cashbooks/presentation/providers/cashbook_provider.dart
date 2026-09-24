import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

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
        colorCode: '#05DCF0',
        iconCodePoint: Symbols.water_drop.codePoint.toString(),
        dbPath: 'flowpaisa',
        createdAt: DateTime.now(),
        addSeq: 0,
      );
      _saveCashbooks([defaultCashbook]);
      return [defaultCashbook];
    }

    // Load and migrate legacy icon names if any
    final cashbooks = jsonList.map((json) => Cashbook.fromJson(json)).toList();
    bool needsSave = false;

    // Check if backfill is already done
    final backfillDone = _prefs.getBool('cashbook_sequence_backfill_done') ?? false;

    // Smart migration for addSeq
    final migrated = cashbooks.map((c) {
      bool modified = false;
      String? newIconCodePoint = c.iconCodePoint;
      int? newAddSeq = c.addSeq;

      if (c.iconCodePoint == 'water_drop') {
        newIconCodePoint = Symbols.water_drop.codePoint.toString();
        modified = true;
      }

      // Assign or fix addSeq (Only if not already backfilled or if seq is missing)
      if (!backfillDone || newAddSeq == null) {
        if (c.id == 'default') {
          if (newAddSeq != 0) {
            newAddSeq = 0;
            modified = true;
          }
        } else {
          if (newAddSeq == null || newAddSeq == 0) {
            int nextSeq = 1;
            final usedSeqs = cashbooks
                .map((cb) => cb.addSeq)
                .whereType<int>()
                .where((s) => s > 0)
                .toSet();
            while (usedSeqs.contains(nextSeq)) {
              nextSeq++;
            }
            newAddSeq = nextSeq;
            modified = true;
          }
        }
      }

      if (modified) {
        needsSave = true;
        return c.copyWith(
          iconCodePoint: newIconCodePoint,
          addSeq: newAddSeq,
        );
      }
      return c;
    }).toList();

    if (needsSave || !backfillDone) {
      _saveCashbooks(migrated);
      if (!backfillDone) {
        _prefs.setBool('cashbook_sequence_backfill_done', true);
      }
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

    // Get next sequence
    int nextSeq = 1;
    final usedSeqs = state.map((c) => c.addSeq).whereType<int>().toSet();
    while (usedSeqs.contains(nextSeq)) {
      nextSeq++;
    }

    final newCashbook = Cashbook(
      id: id,
      name: name,
      colorCode: colorCode,
      iconCodePoint: iconCodePoint,
      dbPath: 'cashbook_$id',
      createdAt: DateTime.now(),
      addSeq: nextSeq,
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
        final newDb = AppDatabase(fileName: '${newCashbook.dbPath}.db');
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
    } catch (e) {
      print('Error copying profile data: $e');
    } finally {
      await defaultDb.close();
    }
  }

  Future<void> updateCashbook(Cashbook updated) async {
    final newList = state.map((c) => c.id == updated.id ? updated : c).toList();
    await _saveCashbooks(newList);
    state = newList;
  }

  Future<void> addCashbookFromCloud(Cashbook cashbook) async {
    final newList = [...state, cashbook];
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

    // Clean up preferences for deleted cashbook
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove('document_sync_required_$id');
    await prefs.remove('last_document_export_$id');

    // Delete the database file and sync metadata
    try {
      if (kIsWeb) {
        // On web, we just need to clear the data from the DB as we can't easily delete "files"
        final db = AppDatabase(fileName: '${cashbookToDelete.dbPath}.db');
        try {
          await db.clearAllData();
        } finally {
          await db.close();
        }
      } else {
        // Physical database file is stored under the application documents directory.
        final dbFolder = await getApplicationDocumentsDirectory();
        final logicalName =
            cashbookToDelete.dbPath.replaceAll(RegExp(r'\.(db|sqlite)$'), '');
        final file = File(p.join(dbFolder.path, '$logicalName.sqlite'));
        if (await file.exists()) {
          await file.delete();
        }

        // Also clear sync metadata for this cashbook
        final db = AppDatabase(fileName: '${cashbookToDelete.dbPath}.db');
        try {
          await (db.delete(db.syncMetadata)).go();
        } catch (e) {
          // Ignore if table doesn't exist yet
        } finally {
          await db.close();
        }
      }
    } catch (e) {
      // Log error but continue
      print('Error deleting database file: $e');
    }
  }

  Future<void> clearCashbookData(String id,
      {BuildContext? context, bool shouldClearCloud = false}) async {
    try {
      final cashbook = state.firstWhere((c) => c.id == id);
      final isActive = ref.read(activeCashbookIdProvider) == id;

      // 1. Reset Cloud Sync Version for this cashbook ID ONLY if explicitly requested
      if (shouldClearCloud) {
        try {
          final driveService = ref.read(googleDriveServiceProvider);
          if (driveService.isSignedIn) {
            final repository = ref.read(backupRepositoryProvider);
            // This resets ONLY the specific cashbook ID in the cloud (manifest + delta files)
            await repository.resetSyncToVersion(id, 0);
          }
        } catch (e) {
          // Ignore cloud reset errors
        }
      }

      // 2. Generate a new unique filename for this cashbook (Blue-Green Switch)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newDbPath = id == 'default'
          ? 'flowpaisa_$timestamp'
          : 'cashbook_${id}_$timestamp';
      final oldDbPath = cashbook.dbPath;

      // 3. Update the cashbook model with the new path
      final updatedCashbook = cashbook.copyWith(dbPath: newDbPath);

      // Update local state
      state = state.map((c) => c.id == id ? updatedCashbook : c).toList();

      // CRITICAL: Ensure the updated list is saved to SharedPreferences immediately
      final jsonList = state.map((c) => c.toJson()).toList();
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setStringList('cashbooks_list', jsonList);

      // Reset the document backup required flag for this cashbook
      await prefs.remove('document_sync_required_$id');
      await prefs.remove('last_document_export_$id');

      // 4. If active, clear the database cache and restart
      if (isActive && context != null && context.mounted) {
        clearDatabaseCache();

        Phoenix.rebirth(context);
      }

      // 5. Attempt to delete the old file in the background
      if (!kIsWeb) {
        unawaited(Future.delayed(const Duration(seconds: 5), () async {
          try {
            final dbFolder = await getApplicationDocumentsDirectory();
            final logicalName =
                oldDbPath.replaceAll(RegExp(r'\.(db|sqlite)$'), '');
            final oldFile =
                File(p.join(dbFolder.path, '$logicalName.sqlite'));

            final walFile = File('${oldFile.path}-wal');
            final shmFile = File('${oldFile.path}-shm');

            if (await oldFile.exists()) {
              await oldFile.delete();
            }
            if (await walFile.exists()) await walFile.delete();
            if (await shmFile.exists()) await shmFile.delete();
          } catch (e) {
            // Ignore cleanup errors
          }
        }));
      }
    } catch (e) {
      print('Error in clearCashbookData: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to clear data: $e")),
        );
      }
    }
  }

  Future<void> restoreCashbookFromFile(String id, File backupFile,
      {AppLocalizations? l10n}) async {
    final cashbook = state.firstWhere((c) => c.id == id);
    final isActive = ref.read(activeCashbookIdProvider) == id;

    if (kDebugMode) {
      print('[CashbookNotifier] Starting restore for cashbook: ${cashbook.name} (ID: $id)');
      print('[CashbookNotifier] Is active cashbook: $isActive');
      print('[CashbookNotifier] Source backup file: ${backupFile.path}');
    }

    // Get the target path in the application documents directory
    final dbFolder = await getApplicationDocumentsDirectory();
    final logicalName =
        cashbook.dbPath.replaceAll(RegExp(r'\.(db|sqlite)$'), '');
    final targetPath = p.join(dbFolder.path, '$logicalName.sqlite');

    if (kDebugMode) print('[CashbookNotifier] Target path: $targetPath');

    // If active, we must ensure the database is closed before overwriting
    if (isActive) {
      if (kDebugMode) print('[CashbookNotifier] Closing active database connection...');
      try {
        final db = ref.read(databaseProvider);
        await db.close();
        if (kDebugMode) print('[CashbookNotifier] Active database closed');
      } catch (e) {
        if (kDebugMode) print('[CashbookNotifier] Error closing database: $e');
      }
      clearDatabaseCache();
    }

    // Before restoring, remove any existing DB + WAL/SHM files for this cashbook
    final targetFile = File(targetPath);
    final walFile = File('$targetPath-wal');
    final shmFile = File('$targetPath-shm');

    try {
      if (await targetFile.exists()) {
        if (kDebugMode) print('[CashbookNotifier] Deleting existing DB file...');
        await targetFile.delete();
      }
      if (await walFile.exists()) {
        if (kDebugMode) print('[CashbookNotifier] Deleting existing WAL file...');
        await walFile.delete();
      }
      if (await shmFile.exists()) {
        if (kDebugMode) print('[CashbookNotifier] Deleting existing SHM file...');
        await shmFile.delete();
      }
    } catch (e) {
      if (kDebugMode) print('[CashbookNotifier] Error deleting old files: $e');
    }

    // Copy the backup file to the target location
    if (kDebugMode) print('[CashbookNotifier] Copying backup file to target...');
    await backupFile.copy(targetPath);
    if (kDebugMode) print('[CashbookNotifier] File copy successful');

    // If it was active, invalidate providers to refresh UI
    if (isActive) {
      if (kDebugMode) print('[CashbookNotifier] Invalidating providers for active cashbook...');
      ref.invalidate(databaseProvider);
      ref.invalidate(activeCashbookProvider);
    }
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
    // Clear last dashboard stats cache so dashboard widgets don't show old cashbook's stats while loading
    ref.read(lastDashboardStatsProvider.notifier).setLast(null);
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
