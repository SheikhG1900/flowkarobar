import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';

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
        _database.categoryUsageStats.categoryId
            .equalsExp(_database.categories.id),
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

  /// Get category by ID
  Future<Category?> getCategoryById(int id) {
    return (_database.select(_database.categories)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Create category
  Future<int> createCategory(CategoriesCompanion category) {
    return _database.into(_database.categories).insert(category);
  }

  /// Update category
  Future<bool> updateCategory(Category category) async {
    final result = await _database.update(_database.categories).replace(category);
    return result;
  }

  /// Check if category has associated transactions
  Future<bool> categoryHasTransactions(int categoryId) async {
    final count = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.id.count()])
          ..where(_database.transactions.categoryId.equals(categoryId)))
        .getSingle();
    
    final transactionCount = count.read(_database.transactions.id.count()) ?? 0;
    return transactionCount > 0;
  }

  /// Smart delete: soft-delete if transactions exist, hard-delete otherwise
  Future<void> softDeleteCategory(int id) async {
    final category = await getCategoryById(id);
    if (category == null) {
      throw Exception('Category not found');
    }
    
    if (category.isDefault) {
      throw Exception('Cannot delete default category');
    }

    // Check if category has transactions
    final hasTransactions = await categoryHasTransactions(id);

    if (hasTransactions) {
      // Soft delete: mark as deleted
      await (_database.update(_database.categories)
            ..where((c) => c.id.equals(id)))
          .write(CategoriesCompanion(isDeleted: Value(true)));
    } else {
      // Hard delete: remove from database
      await (_database.delete(_database.categories)
            ..where((c) => c.id.equals(id)))
          .go();
    }
  }

  /// Delete category (only if not default) - DEPRECATED, use softDeleteCategory
  Future<int> deleteCategory(int id) async {
    final category = await getCategoryById(id);
    if (category == null || category.isDefault) {
      throw Exception('Cannot delete default category');
    }

    return (_database.delete(_database.categories)
          ..where((c) => c.id.equals(id)))
        .go();
  }

  /// Increment category usage count
  Future<void> incrementUsageCount(int categoryId) async {
    await _database.transaction(() async {
      // Check if usage stat exists
      final existingStat = await (_database.select(_database.categoryUsageStats)
            ..where((s) => s.categoryId.equals(categoryId)))
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
                categoryId: Value(categoryId),
                usageCount: const Value(1),
                lastUsed: Value(DateTime.now()),
              ),
            );
      }
    });
  }

  /// Decrement category usage count
  Future<void> decrementUsageCount(int categoryId) async {
    await _database.transaction(() async {
      // Check if usage stat exists
      final existingStat = await (_database.select(_database.categoryUsageStats)
            ..where((s) => s.categoryId.equals(categoryId)))
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
        _database.categoryUsageStats.categoryId
            .equalsExp(_database.categories.id),
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
        _database.categoryUsageStats.categoryId
            .equalsExp(_database.categories.id),
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

