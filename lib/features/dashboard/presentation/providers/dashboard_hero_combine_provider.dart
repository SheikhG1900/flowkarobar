import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook_summary.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';

/// Legacy: one global list (replaced by per–active-cashbook keys below).
const _kLegacyGlobalCombineUuids = 'dashboard_hero_combine_uuids_v1';

/// Local SharedPreferences only — **not** synced via [UserPreferencesRepository].
/// Each active cashbook has its own list of *other* cashbook UUIDs to fold into dashboard header totals.
String _storageKeyForActiveCashbook(String activeCashbookId) =>
    'dashboard_combine_includes_v1_$activeCashbookId';

/// Cashbooks (other than active) whose **saved** summary amounts are added to dashboard header totals.
/// Selection is stored **per active cashbook** on this device only.
final dashboardHeroCombinedCashbookIdsProvider =
    NotifierProvider<DashboardHeroCombinedCashbookIdsNotifier, Set<String>>(
  DashboardHeroCombinedCashbookIdsNotifier.new,
);

class DashboardHeroCombinedCashbookIdsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final activeId = ref.watch(activeCashbookIdProvider);
    final allCashbooks = ref.watch(cashbooksProvider);
    _migrateLegacyToPerCashbookOnce(prefs, allCashbooks);
    return _loadForActive(prefs, activeId);
  }

  /// Old app versions stored one global UUID list. Expand it so each cashbook gets
  /// “include everyone in legacy except myself” — preserves Main+Trip+Construction behaviour.
  void _migrateLegacyToPerCashbookOnce(
    SharedPreferences prefs,
    List<Cashbook> allCashbooks,
  ) {
    final legacyRaw = prefs.getString(_kLegacyGlobalCombineUuids);
    if (legacyRaw == null || legacyRaw.isEmpty) return;

    Set<String> legacyIds;
    try {
      legacyIds = _decode(legacyRaw);
    } catch (_) {
      prefs.remove(_kLegacyGlobalCombineUuids);
      return;
    }

    for (final c in allCashbooks) {
      final forThis = legacyIds.where((id) => id != c.id).toSet();
      final key = _storageKeyForActiveCashbook(c.id);
      if (forThis.isEmpty) {
        prefs.remove(key);
      } else {
        prefs.setString(key, jsonEncode(forThis.toList()));
      }
    }
    prefs.remove(_kLegacyGlobalCombineUuids);
  }

  Set<String> _loadForActive(SharedPreferences prefs, String activeId) {
    final key = _storageKeyForActiveCashbook(activeId);
    final direct = prefs.getString(key);
    if (direct != null && direct.isNotEmpty) {
      return _decode(direct);
    }
    return {};
  }

  Set<String> _decode(String raw) {
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e as String).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> setIds(Set<String> ids) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final activeId = ref.read(activeCashbookIdProvider);
    final storageKey = _storageKeyForActiveCashbook(activeId);
    final others = ids.where((id) => id != activeId).toSet();
    if (others.isEmpty) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, jsonEncode(others.toList()));
    }
    state = others;
  }

  Future<void> toggle(String cashbookUuid, bool selected) async {
    final next = Set<String>.from(state);
    if (selected) {
      next.add(cashbookUuid);
    } else {
      next.remove(cashbookUuid);
    }
    await setIds(next);
  }
}

/// Extra [availableCash] and [netWorth] from saved summaries of selected **other** cashbooks.
final dashboardHeroCombinedAddendsProvider =
    Provider<DashboardHeroCombinedAddends>((ref) {
  final ids = ref.watch(dashboardHeroCombinedCashbookIdsProvider);
  final activeId = ref.watch(activeCashbookIdProvider);
  final cashbooks = ref.watch(cashbooksProvider);
  final prefs = ref.watch(sharedPreferencesProvider);

  final summaries = CashbookSummaryService.readAllSummariesSync(prefs);
  final otherIds =
      cashbooks.where((c) => c.id != activeId).map((c) => c.id).toSet();

  double available = 0;
  double netWorth = 0;
  for (final id in ids) {
    if (id == activeId) continue;
    if (!otherIds.contains(id)) continue;
    final s = summaries[id];
    if (s == null) continue;
    available += s.availableCash;
    netWorth += s.netWorth;
  }

  return DashboardHeroCombinedAddends(
    availableCash: available,
    netWorth: netWorth,
  );
});

class DashboardHeroCombinedAddends {
  const DashboardHeroCombinedAddends({
    required this.availableCash,
    required this.netWorth,
  });

  final double availableCash;
  final double netWorth;
}

/// Resolved cashbooks to show as chips (selected ids that still exist as others).
final dashboardHeroCombinedCashbooksForChipsProvider =
    Provider<List<Cashbook>>((ref) {
  final ids = ref.watch(dashboardHeroCombinedCashbookIdsProvider);
  final activeId = ref.watch(activeCashbookIdProvider);
  final cashbooks = ref.watch(cashbooksProvider);
  return cashbooks
      .where((c) => c.id != activeId && ids.contains(c.id))
      .toList();
});
