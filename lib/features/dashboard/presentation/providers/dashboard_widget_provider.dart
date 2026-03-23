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
      const DashboardWidgetConfig(kind: DashboardWidgetKind.balance),
      const DashboardWidgetConfig(kind: DashboardWidgetKind.cashFlow),
      const DashboardWidgetConfig(kind: DashboardWidgetKind.receivablesSummary),
      const DashboardWidgetConfig(kind: DashboardWidgetKind.payablesSummary),
    ];

class DashboardWidgetLayoutNotifier
    extends AsyncNotifier<List<DashboardWidgetConfig>> {
  @override
  Future<List<DashboardWidgetConfig>> build() async {
    // Depend on active cashbook so layout is reloaded when switching cashbooks.
    // Without this, the notifier would keep in-memory state and overwrite
    // the other cashbook's layout when adding/removing widgets.
    ref.watch(databaseProvider);

    final repo = ref.read(userPreferencesRepositoryProvider);
    final json = await repo.getDashboardWidgetLayout();
    final list = DashboardWidgetConfig.listFromJson(json);
    if (list.isEmpty) return defaultDashboardWidgetLayout;
    return list;
  }

  Future<void> setLayout(List<DashboardWidgetConfig> configs) async {
    state = AsyncData(configs);
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

  Future<void> removeConfigs(Iterable<DashboardWidgetConfig> configs) async {
    final current = state.value ?? defaultDashboardWidgetLayout;
    final toRemove = configs.toSet();
    final next = current.where((c) => !toRemove.contains(c)).toList();
    if (next.length == current.length) return;
    await setLayout(next);
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
}

final dashboardReorderModeProvider =
    NotifierProvider<DashboardReorderModeNotifier, bool>(
        DashboardReorderModeNotifier.new);

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
