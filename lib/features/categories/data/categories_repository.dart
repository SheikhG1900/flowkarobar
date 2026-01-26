import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
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
          usageCount: row.readTableOrNull(_database.categoryUsageStats)?.usageCount ?? 0,
          lastUsed: row.readTableOrNull(_database.categoryUsageStats)?.lastUsed,
        );
      }).toList();
    });
  }

  /// Get category by UUID
  Future<Category?> getCategoryByUuid(String uuid) {
    return (_database.select(_database.categories)
          ..where((c) => c.uuid.equals(uuid)))
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
          ..where(_database.transactions.categoryUuid.equals(categoryUuid)))
        .getSingle();
    
    final transactionCount = count.read(_database.transactions.uuid.count()) ?? 0;
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
  Future<List<CategoryWithUsage>> getMostUsedCategories(String type, int limit) async {
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
        usageCount: row.readTableOrNull(_database.categoryUsageStats)?.usageCount ?? 0,
        lastUsed: row.readTableOrNull(_database.categoryUsageStats)?.lastUsed,
      );
    }).toList();
  }

  /// Get recently used categories (excluding soft-deleted)
  Future<List<CategoryWithUsage>> getRecentlyUsedCategories(String type, int limit) async {
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

