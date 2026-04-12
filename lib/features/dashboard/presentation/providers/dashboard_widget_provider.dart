import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/dashboard/domain/dashboard_widget_models.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/settings/data/user_preferences_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

/// Default widget layout when none is saved.
List<DashboardWidgetConfig> get defaultDashboardWidgetLayout => [
      const DashboardWidgetConfig(kind: DashboardWidgetKind.quickActions),
      const DashboardWidgetConfig(kind: DashboardWidgetKind.balance),
      const DashboardWidgetConfig(kind: DashboardWidgetKind.cashFlow),
      const DashboardWidgetConfig(kind: DashboardWidgetKind.receivablesSummary),
      const DashboardWidgetConfig(kind: DashboardWidgetKind.payablesSummary),
    ];

class DashboardWidgetLayoutNotifier
    extends AsyncNotifier<List<DashboardWidgetConfig>> {
  // Keep track of last known configs for each kind to restore them when toggled back on
  static final Map<DashboardWidgetKind, DashboardWidgetConfig> _lastKnownConfigs = {};

  @override
  Future<List<DashboardWidgetConfig>> build() async {
    // Depend on active cashbook so layout is reloaded when switching cashbooks.
    // Without this, the notifier would keep in-memory state and overwrite
    // the other cashbook's layout when adding/removing widgets.
    ref.watch(databaseProvider);

    final repo = ref.read(userPreferencesRepositoryProvider);
    final json = await repo.getDashboardWidgetLayout();
    final list = DashboardWidgetConfig.listFromJson(json);

    // Populate last known configs from the loaded list
    for (final config in list) {
      if (!config.kind.isEntity) {
        _lastKnownConfigs[config.kind] = config;
      }
    }

    if (list.isEmpty) return defaultDashboardWidgetLayout;
    return list;
  }

  Future<void> setLayout(List<DashboardWidgetConfig> configs) async {
    state = AsyncData(configs);

    // Update last known configs
    for (final config in configs) {
      if (!config.kind.isEntity) {
        _lastKnownConfigs[config.kind] = config;
      }
    }

    await AsyncValue.guard(() async {
      final repo = ref.read(userPreferencesRepositoryProvider);
      await repo.setDashboardWidgetLayout(
          DashboardWidgetConfig.listToJson(configs));
      return configs;
    });
    // Keep optimistic state on persist failure so the list does not flash
  }

  Future<void> addWidget(DashboardWidgetConfig config) async {
    final current = state.value ?? defaultDashboardWidgetLayout;
    await setLayout([...current, config]);
  }

  Future<void> removeAt(int index) async {
    final current = state.value ?? defaultDashboardWidgetLayout;
    if (index < 0 || index >= current.length) return;
    final next = List<DashboardWidgetConfig>.from(current)..removeAt(index);
    await setLayout(next);
  }

  Future<void> updateWidget(int index, DashboardWidgetConfig config) async {
    final current = state.value ?? defaultDashboardWidgetLayout;
    if (index < 0 || index >= current.length) return;
    final next = List<DashboardWidgetConfig>.from(current);
    next[index] = config;
    await setLayout(next);
  }

  Future<void> removeConfigs(Iterable<DashboardWidgetConfig> configs) async {
    final current = state.value ?? defaultDashboardWidgetLayout;
    final toRemove = configs.toSet();
    final next = current.where((c) => !toRemove.contains(c)).toList();
    if (next.length == current.length) return;
    await setLayout(next);
  }

  /// Show or hide a summary widget kind. At most one slot when adding; removing
  /// clears all duplicate entries of that kind. Entity pins are unchanged.
  Future<void> setSummaryKindOnDashboard(
      DashboardWidgetKind kind, bool on) async {
    if (kind.isEntity) return;
    final current = state.value ?? defaultDashboardWidgetLayout;
    if (on) {
      if (current.any((c) => c.kind == kind)) return;

      // Restore previous config if it exists in the "last known" history
      // or use a default one.
      DashboardWidgetConfig newConfig =
          _lastKnownConfigs[kind] ?? DashboardWidgetConfig(kind: kind);

      // If it's quickActions and we don't have a last known, default to some actions
      if (kind == DashboardWidgetKind.quickActions &&
          newConfig.quickActionCodes == null) {
        newConfig = newConfig.copyWith(quickActionCodes: [
          'voice_add',
          'add_transaction',
          'scan_receipt',
          'accounts'
        ]);
      }

      await setLayout([...current, newConfig]);
    } else {
      final next = current.where((c) => c.kind != kind).toList();
      if (next.length == current.length) return;
      await setLayout(next);
    }
  }

  Future<void> reorder(int from, int to) async {
    final current = state.value ?? defaultDashboardWidgetLayout;
    if (from < 0 || from >= current.length || to < 0 || to >= current.length) {
      return;
    }
    final next = List<DashboardWidgetConfig>.from(current);
    final item = next.removeAt(from);
    next.insert(to, item);
    await setLayout(next);
  }

  Future<void> setQuickActionsOnDashboard(int index, List<String> codes) async {
    final current = state.value ?? defaultDashboardWidgetLayout;
    if (index < 0 || index >= current.length) return;
    final next = List<DashboardWidgetConfig>.from(current);
    next[index] = next[index].copyWith(quickActionCodes: codes);
    await setLayout(next);
  }

  /// Whether the given entity is already pinned (for entity kinds).
  bool isPinned(DashboardWidgetKind kind, String? entityUuid) {
    if (entityUuid == null) return false;
    final current = state.value ?? [];
    return current.any((c) {
      if (c.kind != kind) return false;
      return c.entityUuid == entityUuid;
    });
  }
}

final dashboardWidgetLayoutProvider =
    AsyncNotifierProvider<DashboardWidgetLayoutNotifier, List<DashboardWidgetConfig>>(
        DashboardWidgetLayoutNotifier.new);

/// Whether reorder mode is enabled for dashboard widgets. Default is false.
class DashboardReorderModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void set(bool value) => state = value;
}

final dashboardReorderModeProvider =
    NotifierProvider<DashboardReorderModeNotifier, bool>(
        DashboardReorderModeNotifier.new);

/// Dashboard visibility states: visible, edit, hidden.
enum DashboardVisibility { visible, edit, hidden }

class DashboardVisibilityNotifier extends Notifier<DashboardVisibility> {
  @override
  DashboardVisibility build() {
    // Initialize from existing providers to maintain backward compatibility
    final showWidgetArea = ref.read(showDashboardWidgetAreaProvider);
    final reorderMode = ref.read(dashboardReorderModeProvider);

    if (!showWidgetArea) return DashboardVisibility.hidden;
    if (reorderMode) return DashboardVisibility.edit;
    return DashboardVisibility.visible;
  }

  void next() {
    switch (state) {
      case DashboardVisibility.visible:
        state = DashboardVisibility.edit;
        ref.read(dashboardReorderModeProvider.notifier).set(true);
        break;
      case DashboardVisibility.edit:
        state = DashboardVisibility.hidden;
        ref.read(dashboardReorderModeProvider.notifier).set(false);
        ref.read(showDashboardWidgetAreaProvider.notifier).setVisibility(false);
        break;
      case DashboardVisibility.hidden:
        state = DashboardVisibility.visible;
        ref.read(dashboardReorderModeProvider.notifier).set(false);
        ref.read(showDashboardWidgetAreaProvider.notifier).setVisibility(true);
        break;
    }
  }

  void setVisibility(DashboardVisibility visibility) {
    if (state == visibility) return;
    
    final oldState = state;
    state = visibility;
    
    switch (visibility) {
      case DashboardVisibility.visible:
        ref.read(dashboardReorderModeProvider.notifier).set(false);
        // Only update persistent storage if we are coming from hidden
        if (oldState == DashboardVisibility.hidden) {
          ref.read(showDashboardWidgetAreaProvider.notifier).setVisibility(true);
        }
        break;
      case DashboardVisibility.edit:
        ref.read(dashboardReorderModeProvider.notifier).set(true);
        // Only update persistent storage if we are coming from hidden
        if (oldState == DashboardVisibility.hidden) {
          ref.read(showDashboardWidgetAreaProvider.notifier).setVisibility(true);
        }
        break;
      case DashboardVisibility.hidden:
        ref.read(dashboardReorderModeProvider.notifier).set(false);
        ref.read(showDashboardWidgetAreaProvider.notifier).setVisibility(false);
        break;
    }
  }
}

final dashboardVisibilityProvider =
    NotifierProvider<DashboardVisibilityNotifier, DashboardVisibility>(
        DashboardVisibilityNotifier.new);

/// Effective layout: same as saved but with entity widgets whose entity is deleted
/// removed. Automatically persists the cleaned list when stale configs are found.
final effectiveDashboardWidgetLayoutProvider =
    FutureProvider<List<DashboardWidgetConfig>>((ref) async {
  ref.watch(dashboardWidgetLayoutProvider); // depend on layout so we recompute when it changes
  final layoutAsync = ref.read(dashboardWidgetLayoutProvider);
  final rawList = layoutAsync.value ?? defaultDashboardWidgetLayout;

  final txRepo = ref.read(transactionsRepositoryProvider);
  final catRepo = ref.read(categoriesRepositoryProvider);
  final contactRepo = ref.read(contactsRepositoryProvider);
  final payRepo = ref.read(payablesRepositoryProvider);
  final recRepo = ref.read(receivablesRepositoryProvider);
  final accRepo = ref.read(accountsRepositoryProvider);
  final notifier = ref.read(dashboardWidgetLayoutProvider.notifier);

  final List<DashboardWidgetConfig> toRemove = [];
  for (final config in rawList) {
    if (config.kind == DashboardWidgetKind.recentTransactions) {
      toRemove.add(config);
      continue;
    }
    if (!config.kind.isEntity) continue;
    final uuid = config.entityUuid;
    if (uuid == null) {
      toRemove.add(config);
      continue;
    }
    bool exists = false;
    switch (config.kind) {
      case DashboardWidgetKind.transaction:
        exists = await txRepo.getTransactionByUuid(uuid) != null;
        break;
      case DashboardWidgetKind.category:
        exists = await catRepo.getCategoryByUuid(uuid) != null;
        break;
      case DashboardWidgetKind.contact:
        exists = await contactRepo.getContactByUuid(uuid) != null;
        break;
      case DashboardWidgetKind.payable:
        exists = await payRepo.getPayableByUuid(uuid) != null;
        break;
      case DashboardWidgetKind.receivable:
        exists = await recRepo.getReceivableByUuid(uuid) != null;
        break;
      case DashboardWidgetKind.account:
        exists = await accRepo.getAccountByUuid(uuid) != null;
        break;
      default:
        break;
    }
    if (!exists) toRemove.add(config);
  }

  if (toRemove.isNotEmpty) {
    await notifier.removeConfigs(toRemove);
    return rawList.where((c) => !toRemove.contains(c)).toList();
  }
  return rawList;
});
