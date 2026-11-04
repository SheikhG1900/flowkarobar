import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/features/businesses/domain/models/business.dart';
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

class BusinessNotifier extends Notifier<List<Business>> {
  static const String _storageKey = 'businesses_list';

  late SharedPreferences _prefs;

  @override
  List<Business> build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadBusinesses();
  }

  List<Business> _loadBusinesses() {
    var jsonList = _prefs.getStringList(_storageKey);
    if (jsonList == null || jsonList.isEmpty) {
      jsonList = _prefs.getStringList('cashbooks_list');
    }
    if (jsonList == null || jsonList.isEmpty) {
      // Initialize with default business if none exists
      final defaultBusiness = Business(
        id: 'default',
        name: 'Main Business',
        colorCode: '#05DCF0',
        iconCodePoint: Symbols.business_center.codePoint.toString(),
        dbPath: 'flowkarobar',
        createdAt: DateTime.now(),
        addSeq: 0,
      );
      _saveBusinesses([defaultBusiness]);
      return [defaultBusiness];
    }

    final businesses = jsonList.map((json) => Business.fromJson(json)).toList();
    bool needsSave = false;

    // Check if backfill is already done
    final backfillDone = _prefs.getBool('business_sequence_backfill_done') ?? false;

    // Smart migration for addSeq
    final migrated = businesses.map((c) {
      bool modified = false;
      String? newIconCodePoint = c.iconCodePoint;
      int? newAddSeq = c.addSeq;

      if (c.iconCodePoint == 'business_center' || c.iconCodePoint == 'water_drop') {
        newIconCodePoint = Symbols.business_center.codePoint.toString();
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
            final usedSeqs = businesses
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
      _saveBusinesses(migrated);
      if (!backfillDone) {
        _prefs.setBool('business_sequence_backfill_done', true);
      }
    }

    return migrated;
  }

  Future<void> _saveBusinesses(List<Business> list) async {
    final jsonList = list.map((c) => c.toJson()).toList();
    await _prefs.setStringList(_storageKey, jsonList);
  }

  Future<void> addBusiness({
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

    final newBusiness = Business(
      id: id,
      name: name,
      colorCode: colorCode,
      iconCodePoint: iconCodePoint,
      dbPath: 'business_$id',
      createdAt: DateTime.now(),
      addSeq: nextSeq,
    );

    final newList = [...state, newBusiness];
    await _saveBusinesses(newList);
    state = newList;

    // Copy profile data from default business to new business
    final defaultDb = AppDatabase(fileName: 'flowkarobar.db');
    try {
      final defaultRepo = UserPreferencesRepository(defaultDb);
      final profileName = await defaultRepo.getUserName();
      final profileEmail = await defaultRepo.getUserEmail();
      final profilePhone = await defaultRepo.getUserPhone();
      final profileAddress = await defaultRepo.getUserAddress();

      // Only copy if default business has profile data
      if (profileName != null ||
          profileEmail != null ||
          profilePhone != null ||
          profileAddress != null) {
        final newDb = AppDatabase(fileName: '${newBusiness.dbPath}.db');
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

  Future<void> updateBusiness(Business updated) async {
    final newList = state.map((c) => c.id == updated.id ? updated : c).toList();
    await _saveBusinesses(newList);
    state = newList;
  }

  Future<void> addBusinessFromCloud(Business business) async {
    final newList = [...state, business];
    await _saveBusinesses(newList);
    state = newList;
  }

  Future<void> deleteBusiness(String id) async {
    if (id == 'default') return; // Cannot delete default

    final businessToDelete = state.firstWhere((c) => c.id == id);

    // If active, switch to default first
    if (ref.read(activeBusinessIdProvider) == id) {
      await ref
          .read(activeBusinessIdProvider.notifier)
          .setActive(state.first.id);
    }

    final newList = state.where((c) => c.id != id).toList();
    await _saveBusinesses(newList);
    state = newList;

    // Clean up preferences for deleted business
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove('document_sync_required_$id');
    await prefs.remove('last_document_export_$id');

    // Delete the database file and sync metadata
    try {
      if (kIsWeb) {
        final db = AppDatabase(fileName: '${businessToDelete.dbPath}.db');
        try {
          await db.clearAllData();
        } finally {
          await db.close();
        }
      } else {
        final dbFolder = await getApplicationDocumentsDirectory();
        final logicalName =
            businessToDelete.dbPath.replaceAll(RegExp(r'\.(db|sqlite)$'), '');
        final file = File(p.join(dbFolder.path, '$logicalName.sqlite'));
        if (await file.exists()) {
          await file.delete();
        }

        final db = AppDatabase(fileName: '${businessToDelete.dbPath}.db');
        try {
          await (db.delete(db.syncMetadata)).go();
        } catch (e) {
          // Ignore
        } finally {
          await db.close();
        }
      }
    } catch (e) {
      print('Error deleting database file: $e');
    }
  }

  Future<void> clearBusinessData(String id,
      {BuildContext? context, bool shouldClearCloud = false}) async {
    try {
      final business = state.firstWhere((c) => c.id == id);
      final isActive = ref.read(activeBusinessIdProvider) == id;

      // Reset Cloud Sync Version for this business ID ONLY if requested
      if (shouldClearCloud) {
        try {
          final driveService = ref.read(googleDriveServiceProvider);
          if (driveService.isSignedIn) {
            final repository = ref.read(backupRepositoryProvider);
            await repository.resetSyncToVersion(id, 0);
          }
        } catch (e) {
          // Ignore
        }
      }

      // Generate a new unique filename for this business (Blue-Green Switch)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newDbPath = id == 'default'
          ? 'flowkarobar_$timestamp'
          : 'business_${id}_$timestamp';
      final oldDbPath = business.dbPath;

      final updatedBusiness = business.copyWith(dbPath: newDbPath);

      state = state.map((c) => c.id == id ? updatedBusiness : c).toList();

      final jsonList = state.map((c) => c.toJson()).toList();
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setStringList('businesses_list', jsonList);

      await prefs.remove('document_sync_required_$id');
      await prefs.remove('last_document_export_$id');

      if (isActive && context != null && context.mounted) {
        clearDatabaseCache();
        Phoenix.rebirth(context);
      }

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
            // Ignore
          }
        }));
      }
    } catch (e) {
      print('Error in clearBusinessData: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to clear data: $e")),
        );
      }
    }
  }

  Future<void> restoreBusinessFromFile(String id, File backupFile,
      {AppLocalizations? l10n}) async {
    final business = state.firstWhere((c) => c.id == id);
    final isActive = ref.read(activeBusinessIdProvider) == id;

    final dbFolder = await getApplicationDocumentsDirectory();
    final logicalName =
        business.dbPath.replaceAll(RegExp(r'\.(db|sqlite)$'), '');
    final targetPath = p.join(dbFolder.path, '$logicalName.sqlite');

    if (isActive) {
      try {
        final db = ref.read(databaseProvider);
        await db.close();
      } catch (e) {
        // Ignore
      }
      clearDatabaseCache();
    }

    final targetFile = File(targetPath);
    final walFile = File('$targetPath-wal');
    final shmFile = File('$targetPath-shm');

    try {
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      if (await walFile.exists()) {
        await walFile.delete();
      }
      if (await shmFile.exists()) {
        await shmFile.delete();
      }
    } catch (e) {
      // Ignore
    }

    await backupFile.copy(targetPath);

    if (isActive) {
      ref.invalidate(databaseProvider);
      ref.invalidate(activeBusinessProvider);
    }
  }
}

final businessesProvider =
    NotifierProvider<BusinessNotifier, List<Business>>(() {
  return BusinessNotifier();
});

class ActiveBusinessIdNotifier extends Notifier<String> {
  static const String _activeIdKey = 'active_business_id';
  late SharedPreferences _prefs;

  @override
  String build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _prefs.getString(_activeIdKey) ??
        _prefs.getString('active_cashbook_id') ??
        'default';
  }

  Future<void> setActive(String id) async {
    await _prefs.setString(_activeIdKey, id);
    state = id;
    ref.read(lastDashboardStatsProvider.notifier).setLast(null);
  }
}

final activeBusinessIdProvider =
    NotifierProvider<ActiveBusinessIdNotifier, String>(() {
  return ActiveBusinessIdNotifier();
});

final activeBusinessProvider = Provider<Business>((ref) {
  final id = ref.watch(activeBusinessIdProvider);
  final list = ref.watch(businessesProvider);
  return list.firstWhere((c) => c.id == id, orElse: () => list.first);
});
