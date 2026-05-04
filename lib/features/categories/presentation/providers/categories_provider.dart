import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/categories/data/categories_repository.dart';
import 'package:flowpaisa/features/categories/domain/category_budget_models.dart';
import 'package:flowpaisa/features/categories/domain/category_monthly_hint_key.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/shared/models/date_range_state.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

// Repository provider
final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return CategoriesRepository(database);
});

// Stream providers
final categoriesListProvider = StreamProvider<List<Category>>((ref) {
  final repository = ref.watch(categoriesRepositoryProvider);
  return repository.watchAllCategories();
});

final categoriesByTypeProvider = StreamProvider.family<List<Category>, String>((ref, type) {
  final repository = ref.watch(categoriesRepositoryProvider);
  return repository.watchCategoriesByType(type).distinct((prev, next) => const ListEquality().equals(prev, next));
});

final categoriesWithUsageProvider = StreamProvider.family<List<CategoryWithUsage>, String>((ref, type) {
  final repository = ref.watch(categoriesRepositoryProvider);
  return repository.watchCategoriesWithUsage(type).distinct((prev, next) => const ListEquality().equals(prev, next));
});

// Smart categories provider (alias for categoriesWithUsageProvider for clarity)
final smartCategoriesProvider = StreamProvider.family<List<CategoryWithUsage>, String>((ref, type) {
  final repository = ref.watch(categoriesRepositoryProvider);
  return repository.watchCategoriesWithUsage(type);
});

// ── Category budget period (list + detail; independent from analytics range) ──

class CategoryBudgetDateRangeNotifier extends Notifier<DateRangeState> {
  @override
  DateRangeState build() => DateRangeState.currentMonth();

  void updateRange(DateRangeState newRange) {
    state = newRange;
  }

  /// Snap to current calendar month / quarter / year (e.g. from list chips).
  void setPeriodType(DateRangeType type) {
    final now = DateTime.now();
    switch (type) {
      case DateRangeType.month:
        state = DateRangeState.month(now);
        break;
      case DateRangeType.quarter:
        final q = ((now.month - 1) ~/ 3) + 1;
        state = DateRangeState.quarter(now.year, q);
        break;
      case DateRangeType.year:
        state = DateRangeState.year(now.year);
        break;
      case DateRangeType.custom:
        state = DateRangeState.month(now);
        break;
    }
  }

  void nextPeriod() {
    switch (state.type) {
      case DateRangeType.month:
        final nextMonth =
            DateTime(state.startDate.year, state.startDate.month + 1, 1);
        state = DateRangeState.month(nextMonth);
        break;
      case DateRangeType.quarter:
        final currentQuarter = ((state.startDate.month - 1) ~/ 3) + 1;
        final nextQuarter = currentQuarter == 4 ? 1 : currentQuarter + 1;
        final nextYear = currentQuarter == 4
            ? state.startDate.year + 1
            : state.startDate.year;
        state = DateRangeState.quarter(nextYear, nextQuarter);
        break;
      case DateRangeType.year:
        state = DateRangeState.year(state.startDate.year + 1);
        break;
      case DateRangeType.custom:
        break;
    }
  }

  void previousPeriod() {
    switch (state.type) {
      case DateRangeType.month:
        final prevMonth =
            DateTime(state.startDate.year, state.startDate.month - 1, 1);
        state = DateRangeState.month(prevMonth);
        break;
      case DateRangeType.quarter:
        final currentQuarter = ((state.startDate.month - 1) ~/ 3) + 1;
        final prevQuarter = currentQuarter == 1 ? 4 : currentQuarter - 1;
        final prevYear = currentQuarter == 1
            ? state.startDate.year - 1
            : state.startDate.year;
        state = DateRangeState.quarter(prevYear, prevQuarter);
        break;
      case DateRangeType.year:
        state = DateRangeState.year(state.startDate.year - 1);
        break;
      case DateRangeType.custom:
        break;
    }
  }
}

final categoryBudgetDateRangeProvider =
    NotifierProvider<CategoryBudgetDateRangeNotifier, DateRangeState>(
        CategoryBudgetDateRangeNotifier.new);

/// Detail + list: budget snapshot for [categoryUuid] and current [categoryBudgetDateRangeProvider].
final categoryDetailBudgetProvider = FutureProvider.autoDispose
    .family<CategoryBudgetSnapshot, String>((ref, categoryUuid) async {
  final range = ref.watch(categoryBudgetDateRangeProvider);
  final repo = ref.watch(categoriesRepositoryProvider);
  return repo.getCategoryBudgetSnapshot(categoryUuid, range);
});

/// Net amounts for all categories of [type] in the current category budget period.
final categoryNetAmountsForListProvider =
    StreamProvider.family<Map<String, double>, String>((ref, type) {
  final range = ref.watch(categoryBudgetDateRangeProvider);
  final repo = ref.watch(categoriesRepositoryProvider);
  final categoriesAsync = ref.watch(categoriesByTypeProvider(type));

  return categoriesAsync.when(
    data: (categories) {
      if (categories.isEmpty) return Stream.value(<String, double>{});
      return repo
          .watchCategoryNetAmountsForCategories(
            categories.map((c) => c.uuid).toList(),
            range.startDate,
            range.endDate,
          )
          .distinct((prev, next) => const MapEquality().equals(prev, next))
          .debounceTime(const Duration(milliseconds: 100));
    },
    loading: () => Stream.value(<String, double>{}),
    error: (_, __) => Stream.value(<String, double>{}),
  );
});

/// Uncategorized total for transactions of [type] for the current category budget period.
final uncategorizedAmountByTypeProvider =
    StreamProvider.family<double, String>((ref, type) {
  final range = ref.watch(categoryBudgetDateRangeProvider);
  final repo = ref.watch(categoriesRepositoryProvider);
  return repo
      .watchUncategorizedAmountByType(type, range.startDate, range.endDate)
      .distinct()
      .debounceTime(const Duration(milliseconds: 100));
});

class IncludeUncategorizedInCategorySummaryNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    ref.watch(databaseProvider);
    final repo = ref.read(userPreferencesRepositoryProvider);
    return repo.getIncludeUncategorizedInCategorySummary();
  }

  Future<void> setInclude(bool value) async {
    final repo = ref.read(userPreferencesRepositoryProvider);
    await repo.setIncludeUncategorizedInCategorySummary(value);
    state = AsyncData(value);
  }
}

final includeUncategorizedInCategorySummaryProvider =
    AsyncNotifierProvider<IncludeUncategorizedInCategorySummaryNotifier, bool>(
        IncludeUncategorizedInCategorySummaryNotifier.new);

/// Refresh category nets + uncategorized for the list after transactions/budget change.
void invalidateCategoryPeriodNets(WidgetRef ref, String type) {
  // No longer needed for StreamProviders as they react to DB changes
}

/// Monthly budget hint for add/edit transaction (lazy: category + reference date).
final categoryMonthlyBudgetHintProvider = FutureProvider.autoDispose
    .family<CategoryBudgetSnapshot?, CategoryMonthlyHintKey>((ref, key) async {
  if (key.categoryUuid == null) return null;
  final month = DateRangeState.month(key.referenceDate);
  final repo = ref.watch(categoriesRepositoryProvider);
  return repo.getCategoryBudgetSnapshot(key.categoryUuid!, month);
});
