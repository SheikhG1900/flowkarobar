import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/categories/data/categories_repository.dart';
import 'package:flowpaisa/features/categories/domain/category_budget_models.dart';
import 'package:flowpaisa/features/categories/domain/category_monthly_hint_key.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
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

/// Same data as [categoryDetailBudgetProvider], but updates when transactions or the category row change.
final categoryDetailBudgetSnapshotStreamProvider = StreamProvider.autoDispose
    .family<CategoryBudgetSnapshot, String>((ref, categoryUuid) {
  final range = ref.watch(categoryBudgetDateRangeProvider);
  final repo = ref.watch(categoriesRepositoryProvider);
  return repo.watchCategoryBudgetSnapshot(categoryUuid, range);
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
            type,
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

class SummaryViewModeNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    ref.watch(databaseProvider);
    final repo = ref.read(userPreferencesRepositoryProvider);
    return repo.getSummaryViewMode();
  }

  Future<void> setMode(String mode) async {
    final repo = ref.read(userPreferencesRepositoryProvider);
    await repo.setSummaryViewMode(mode);
    state = AsyncData(mode);
  }
}

final summaryViewModeProvider =
    AsyncNotifierProvider<SummaryViewModeNotifier, String>(
        SummaryViewModeNotifier.new);

/// Provides daily cumulative net amounts for a category group trend chart.
final dailyCumulativeNetAmountsProvider = StreamProvider.family<
    List<DailyNetAmount>,
    ({String type, DateRangeState range})>((ref, arg) {
  final type = arg.type;
  final range = arg.range;
  final txRepo = ref.watch(transactionsRepositoryProvider);
  final categoriesAsync = ref.watch(categoriesByTypeProvider(type));
  final includeUncategorizedAsync =
      ref.watch(includeUncategorizedInCategorySummaryProvider);

  return Rx.combineLatest3(
    txRepo.watchTransactionsByDateRange(range.startDate, range.endDate),
    categoriesAsync.when(
        data: (c) => Stream.value(c),
        loading: () => const Stream.empty(),
        error: (_, __) => Stream.value(<Category>[])),
    includeUncategorizedAsync.when(
        data: (i) => Stream.value(i),
        loading: () => const Stream.empty(),
        error: (_, __) => Stream.value(false)),
    (transactions, categories, includeUncategorized) {
      final categoryUuids = categories.map((c) => c.uuid).toSet();

      // Filter processed transactions
      final processedTxs =
          transactions.where((t) => t.processedDate != null).toList();

      // Group by date
      final dailyNets = <DateTime, double>{};
      final dailyCounts = <DateTime, int>{};
      final dailyHasData = <DateTime, bool>{};

      // Initialize dailyNets with 0 for all days in range
      var current = DateTime(
          range.startDate.year, range.startDate.month, range.startDate.day);
      final end =
          DateTime(range.endDate.year, range.endDate.month, range.endDate.day);
      while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
        dailyNets[current] = 0.0;
        dailyCounts[current] = 0;
        dailyHasData[current] = false;
        current = current.add(const Duration(days: 1));
      }

      for (final t in processedTxs) {
        final date = DateTime(t.date.year, t.date.month, t.date.day);
        if (!dailyNets.containsKey(date)) continue;

        double amount = 0;
        bool relevant = false;
        if (t.categoryUuid != null && categoryUuids.contains(t.categoryUuid)) {
          relevant = true;
          // Transaction belongs to a category of the requested type
          if (type == 'INCOME') {
            // Net = income - expense
            amount = t.type == 'INCOME' ? t.amount : -t.amount;
          } else {
            // Net = expense - income
            amount = t.type == 'EXPENSE' ? t.amount : -t.amount;
          }
        } else if (t.categoryUuid == null &&
            includeUncategorized &&
            t.type == type) {
          relevant = true;
          // Uncategorized transaction of the requested type
          amount = t.amount;
        }

        if (relevant) {
          dailyNets[date] = (dailyNets[date] ?? 0.0) + amount;
          dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
          dailyHasData[date] = true;
        }
      }

      // Calculate cumulative
      final sortedDates = dailyNets.keys.toList()..sort();
      final result = <DailyNetAmount>[];
      double cumulative = 0;
      for (final date in sortedDates) {
        final dailyNet = dailyNets[date]!;
        cumulative += dailyNet;
        result.add(DailyNetAmount(
          date: date,
          netAmount: cumulative,
          dailyNet: dailyNet,
          transactionCount: dailyCounts[date] ?? 0,
          hasData: dailyHasData[date] ?? false,
        ));
      }

      return result;
    },
  ).debounceTime(const Duration(milliseconds: 100));
});

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
