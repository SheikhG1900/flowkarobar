import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/utils/category_budget_utils.dart';
import 'package:flowpaisa/features/categories/domain/category_budget_models.dart';
import 'package:flowpaisa/shared/models/date_range_state.dart';
import 'package:uuid/uuid.dart';

class CategoriesRepository {
  final AppDatabase _database;

  CategoriesRepository(this._database);

  /// Watch all categories (excluding soft-deleted)
  Stream<List<Category>> watchAllCategories() {
    return (_database.select(_database.categories)
          ..where((c) => c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Watch categories by type (EXPENSE or INCOME, excluding soft-deleted)
  Stream<List<Category>> watchCategoriesByType(String type) {
    return (_database.select(_database.categories)
          ..where((c) => c.type.equals(type))
          ..where((c) => c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Watch categories with usage stats (most used first, excluding soft-deleted)
  Stream<List<CategoryWithUsage>> watchCategoriesWithUsage(String type) {
    final query = _database.select(_database.categories).join([
      leftOuterJoin(
        _database.categoryUsageStats,
        _database.categoryUsageStats.categoryUuid
            .equalsExp(_database.categories.uuid),
      ),
    ])
      ..where(_database.categories.type.equals(type))
      ..where(_database.categories.isDeleted.equals(false))
      ..orderBy([
        OrderingTerm.desc(
          _database.categoryUsageStats.usageCount,
        ),
        OrderingTerm.asc(_database.categories.name),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return CategoryWithUsage(
          category: row.readTable(_database.categories),
          usageCount:
              row.readTableOrNull(_database.categoryUsageStats)?.usageCount ??
                  0,
          lastUsed: row.readTableOrNull(_database.categoryUsageStats)?.lastUsed,
        );
      }).toList();
    });
  }

  /// Get category by UUID
  Future<Category?> getCategoryByUuid(String uuid) {
    return (_database.select(_database.categories)
          ..where((c) => c.uuid.equals(uuid) & c.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Create category
  Future<String> createCategory(CategoriesCompanion category) async {
    final uuid = category.uuid.present ? category.uuid.value : Uuid().v4();
    await _database.into(_database.categories).insert(
          category.copyWith(
            uuid: Value(uuid),
            isNotSynced: const Value(true),
          ),
        );
    return uuid;
  }

  /// Update category
  Future<bool> updateCategory(Category category) async {
    final result = await _database
        .update(_database.categories)
        .replace(category.copyWith(isNotSynced: true));
    return result;
  }

  /// Check if category has associated transactions
  Future<bool> categoryHasTransactions(String categoryUuid) async {
    final count = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.uuid.count()])
          ..where(_database.transactions.categoryUuid.equals(categoryUuid) &
              _database.transactions.isDeleted.equals(false)))
        .getSingle();

    final transactionCount =
        count.read(_database.transactions.uuid.count()) ?? 0;
    return transactionCount > 0;
  }

  /// Smart delete: soft-delete if transactions exist, hard-delete otherwise
  Future<void> softDeleteCategory(String uuid) async {
    final category = await getCategoryByUuid(uuid);
    if (category == null) {
      throw Exception('Category not found');
    }

    if (category.isDefault) {
      throw Exception('Cannot delete default category');
    }

    // Check if category has transactions
    final hasTransactions = await categoryHasTransactions(uuid);

    if (hasTransactions) {
      // Soft delete: mark as deleted
      await (_database.update(_database.categories)
            ..where((c) => c.uuid.equals(uuid)))
          .write(const CategoriesCompanion(
        isDeleted: Value(true),
        isNotSynced: Value(true),
      ));
    } else {
      // Even for hard delete, we should mark as deleted and sync first
      // so other devices know to remove it.
      await (_database.update(_database.categories)
            ..where((c) => c.uuid.equals(uuid)))
          .write(const CategoriesCompanion(
        isDeleted: Value(true),
        isNotSynced: Value(true),
      ));
    }
  }

  /// Increment category usage count
  Future<void> incrementUsageCount(String categoryUuid) async {
    await _database.transaction(() async {
      // Check if usage stat exists
      final existingStat = await (_database.select(_database.categoryUsageStats)
            ..where((s) => s.categoryUuid.equals(categoryUuid)))
          .getSingleOrNull();

      if (existingStat != null) {
        // Update existing
        await _database.update(_database.categoryUsageStats).replace(
              existingStat.copyWith(
                usageCount: existingStat.usageCount + 1,
                lastUsed: Value(DateTime.now()),
              ),
            );
      } else {
        // Create new
        await _database.into(_database.categoryUsageStats).insert(
              CategoryUsageStatsCompanion(
                categoryUuid: Value(categoryUuid),
                usageCount: const Value(1),
                lastUsed: Value(DateTime.now()),
              ),
            );
      }
    });
  }

  /// Decrement category usage count
  Future<void> decrementUsageCount(String categoryUuid) async {
    await _database.transaction(() async {
      // Check if usage stat exists
      final existingStat = await (_database.select(_database.categoryUsageStats)
            ..where((s) => s.categoryUuid.equals(categoryUuid)))
          .getSingleOrNull();

      if (existingStat != null && existingStat.usageCount > 0) {
        // Update existing (don't go below 0)
        await _database.update(_database.categoryUsageStats).replace(
              existingStat.copyWith(
                usageCount: existingStat.usageCount - 1,
              ),
            );
      }
    });
  }

  /// Get most used categories (excluding soft-deleted)
  Future<List<CategoryWithUsage>> getMostUsedCategories(
      String type, int limit) async {
    final query = _database.select(_database.categories).join([
      leftOuterJoin(
        _database.categoryUsageStats,
        _database.categoryUsageStats.categoryUuid
            .equalsExp(_database.categories.uuid),
      ),
    ])
      ..where(_database.categories.type.equals(type))
      ..where(_database.categories.isDeleted.equals(false))
      ..orderBy([
        OrderingTerm.desc(
          _database.categoryUsageStats.usageCount,
        ),
      ])
      ..limit(limit);

    final rows = await query.get();
    return rows.map((row) {
      return CategoryWithUsage(
        category: row.readTable(_database.categories),
        usageCount:
            row.readTableOrNull(_database.categoryUsageStats)?.usageCount ?? 0,
        lastUsed: row.readTableOrNull(_database.categoryUsageStats)?.lastUsed,
      );
    }).toList();
  }

  /// Get recently used categories (excluding soft-deleted)
  Future<List<CategoryWithUsage>> getRecentlyUsedCategories(
      String type, int limit) async {
    final query = _database.select(_database.categories).join([
      innerJoin(
        _database.categoryUsageStats,
        _database.categoryUsageStats.categoryUuid
            .equalsExp(_database.categories.uuid),
      ),
    ])
      ..where(_database.categories.type.equals(type))
      ..where(_database.categories.isDeleted.equals(false))
      ..orderBy([
        OrderingTerm.desc(
          _database.categoryUsageStats.lastUsed,
        ),
      ])
      ..limit(limit);

    final rows = await query.get();
    return rows.map((row) {
      return CategoryWithUsage(
        category: row.readTable(_database.categories),
        usageCount: row.readTable(_database.categoryUsageStats).usageCount,
        lastUsed: row.readTable(_database.categoryUsageStats).lastUsed,
      );
    }).toList();
  }

  // ── Category budgets & period net (active = not deleted + processed) ─────

  Future<double> getCategoryNetAmount(
      String categoryUuid, DateTime start, DateTime end) async {
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    final expenseSum = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..where(_database.transactions.categoryUuid.equals(categoryUuid))
          ..where(_database.transactions.type.equals('EXPENSE'))
          ..where(_database.transactions.date.isBetweenValues(startDate, endDate))
          ..where(_database.transactions.isDeleted.equals(false))
          ..where(_database.transactions.processedDate.isNotNull()))
        .getSingle()
        .then((r) => r.read(_database.transactions.amount.sum()) ?? 0.0);
    final incomeSum = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..where(_database.transactions.categoryUuid.equals(categoryUuid))
          ..where(_database.transactions.type.equals('INCOME'))
          ..where(_database.transactions.date.isBetweenValues(startDate, endDate))
          ..where(_database.transactions.isDeleted.equals(false))
          ..where(_database.transactions.processedDate.isNotNull()))
        .getSingle()
        .then((r) => r.read(_database.transactions.amount.sum()) ?? 0.0);
    return expenseSum - incomeSum;
  }

  /// Net for transactions with no category: sum(EXPENSE) − sum(INCOME) in range.
  /// Same sign convention as [getCategoryNetAmount].
  Future<double> getUncategorizedNetAmount(
      DateTime start, DateTime end) async {
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    final expenseSum = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..where(_database.transactions.categoryUuid.isNull())
          ..where(_database.transactions.type.equals('EXPENSE'))
          ..where(_database.transactions.date.isBetweenValues(startDate, endDate))
          ..where(_database.transactions.isDeleted.equals(false))
          ..where(_database.transactions.processedDate.isNotNull()))
        .getSingle()
        .then((r) => r.read(_database.transactions.amount.sum()) ?? 0.0);
    final incomeSum = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..where(_database.transactions.categoryUuid.isNull())
          ..where(_database.transactions.type.equals('INCOME'))
          ..where(_database.transactions.date.isBetweenValues(startDate, endDate))
          ..where(_database.transactions.isDeleted.equals(false))
          ..where(_database.transactions.processedDate.isNotNull()))
        .getSingle()
        .then((r) => r.read(_database.transactions.amount.sum()) ?? 0.0);
    return expenseSum - incomeSum;
  }

  /// Total for transactions with no category by type (EXPENSE or INCOME) in range.
  Future<double> getUncategorizedAmountByType(
      String type, DateTime start, DateTime end) async {
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    final sum = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.amount.sum()])
          ..where(_database.transactions.categoryUuid.isNull())
          ..where(_database.transactions.type.equals(type))
          ..where(
              _database.transactions.date.isBetweenValues(startDate, endDate))
          ..where(_database.transactions.isDeleted.equals(false))
          ..where(_database.transactions.processedDate.isNotNull()))
        .getSingle()
        .then((r) => r.read(_database.transactions.amount.sum()) ?? 0.0);
    return sum;
  }

  Future<int> getCategoryTransactionCount(
      String categoryUuid, DateTime start, DateTime end) async {
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.uuid.count()])
          ..where(_database.transactions.categoryUuid.equals(categoryUuid))
          ..where(_database.transactions.date.isBetweenValues(startDate, endDate))
          ..where(_database.transactions.isDeleted.equals(false))
          ..where(_database.transactions.processedDate.isNotNull()))
        .getSingle()
        .then((r) => r.read(_database.transactions.uuid.count()) ?? 0);
  }

  Future<CategoryPeriodStats> getCategoryPeriodStats(
      String categoryUuid, DateTime start, DateTime end) async {
    final net = await getCategoryNetAmount(categoryUuid, start, end);
    final count = await getCategoryTransactionCount(categoryUuid, start, end);
    return CategoryPeriodStats(netAmount: net, transactionCount: count);
  }

  Future<CategoryBudgetSnapshot> getCategoryBudgetSnapshot(
      String categoryUuid, DateRangeState range) async {
    final category = await getCategoryByUuid(categoryUuid);
    if (category == null) {
      throw Exception('Category not found');
    }
    final stats = await getCategoryPeriodStats(
        categoryUuid, range.startDate, range.endDate);
    return CategoryBudgetSnapshot(
      category: category,
      period: range,
      netAmount: stats.netAmount,
      budgetAmount: budgetAmountForPeriod(category, range),
      transactionCount: stats.transactionCount,
    );
  }

  /// Batch net amounts for list rows (same period for all).
  Future<Map<String, double>> getCategoryNetAmountsForCategories(
    List<String> categoryUuids,
    DateTime start,
    DateTime end,
  ) async {
    if (categoryUuids.isEmpty) return {};
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    final query = _database.selectOnly(_database.transactions)
      ..addColumns([
        _database.transactions.categoryUuid,
        _database.transactions.type,
        _database.transactions.amount.sum(),
      ])
      ..where(_database.transactions.categoryUuid.isIn(categoryUuids))
      ..where(_database.transactions.date.isBetweenValues(startDate, endDate))
      ..where(_database.transactions.isDeleted.equals(false))
      ..where(_database.transactions.processedDate.isNotNull())
      ..groupBy(
          [_database.transactions.categoryUuid, _database.transactions.type]);

    final rows = await query.get();
    final expenseBy = <String, double>{};
    final incomeBy = <String, double>{};
    for (final row in rows) {
      final catUuid = row.read(_database.transactions.categoryUuid);
      final type = row.read(_database.transactions.type);
      final sum = row.read(_database.transactions.amount.sum()) ?? 0.0;
      if (catUuid == null) continue;
      if (type == 'EXPENSE') {
        expenseBy[catUuid] = sum;
      } else if (type == 'INCOME') {
        incomeBy[catUuid] = sum;
      }
    }
    final result = <String, double>{};
    for (final id in categoryUuids) {
      final e = expenseBy[id] ?? 0.0;
      final i = incomeBy[id] ?? 0.0;
      result[id] = e - i;
    }
    return result;
  }

  /// Updates only budget fields (use [Value.absent] to leave unchanged).
  Future<bool> updateCategoryBudgetFields(
    Category category, {
    Value<double?> monthlyBudget = const Value.absent(),
    Value<double?> quarterlyBudget = const Value.absent(),
    Value<double?> yearlyBudget = const Value.absent(),
  }) async {
    return updateCategory(
      category.copyWith(
        monthlyBudget: monthlyBudget,
        quarterlyBudget: quarterlyBudget,
        yearlyBudget: yearlyBudget,
        updatedAt: DateTime.now(),
      ),
    );
  }
}

/// Data class for category with usage statistics
class CategoryWithUsage {
  final Category category;
  final int usageCount;
  final DateTime? lastUsed;

  CategoryWithUsage({
    required this.category,
    required this.usageCount,
    this.lastUsed,
  });
}
