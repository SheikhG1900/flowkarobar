import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
        colorCode: '#2196F3',
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

    // Delete the database file
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, cashbookToDelete.dbPath));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Log error but continue
      print('Error deleting database file: $e');
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
