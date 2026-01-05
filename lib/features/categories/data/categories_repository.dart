import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';

class CategoriesRepository {
  final AppDatabase _database;

  CategoriesRepository(this._database);

  /// Watch all categories
  Stream<List<Category>> watchAllCategories() {
    return (_database.select(_database.categories)
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Watch categories by type (EXPENSE or INCOME)
  Stream<List<Category>> watchCategoriesByType(String type) {
    return (_database.select(_database.categories)
          ..where((c) => c.type.equals(type))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Watch categories with usage stats (most used first)
  Stream<List<CategoryWithUsage>> watchCategoriesWithUsage(String type) {
    final query = _database.select(_database.categories).join([
      leftOuterJoin(
        _database.categoryUsageStats,
        _database.categoryUsageStats.categoryId
            .equalsExp(_database.categories.id),
      ),
    ])
      ..where(_database.categories.type.equals(type))
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
  Future<bool> updateCategory(Category category) {
    return _database.update(_database.categories).replace(category);
  }

  /// Delete category (only if not default)
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

  /// Get most used categories
  Future<List<CategoryWithUsage>> getMostUsedCategories(String type, int limit) async {
    final query = _database.select(_database.categories).join([
      leftOuterJoin(
        _database.categoryUsageStats,
        _database.categoryUsageStats.categoryId
            .equalsExp(_database.categories.id),
      ),
    ])
      ..where(_database.categories.type.equals(type))
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

  /// Get recently used categories
  Future<List<CategoryWithUsage>> getRecentlyUsedCategories(String type, int limit) async {
    final query = _database.select(_database.categories).join([
      innerJoin(
        _database.categoryUsageStats,
        _database.categoryUsageStats.categoryId
            .equalsExp(_database.categories.id),
      ),
    ])
      ..where(_database.categories.type.equals(type))
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

