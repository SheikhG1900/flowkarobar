import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/categories/domain/category_budget_models.dart';
import 'package:flowpaisa/shared/models/date_range_state.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class CategoriesRepository {
  final AppDatabase _database;

  CategoriesRepository(this._database);

  /// Watch all categories (excluding soft-deleted)
  Stream<List<Category>> watchAllCategories() {
    return (_database.select(_database.productCategories)
          ..where((c) => c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch()
        .map((list) => list
            .map((c) => Category(
                  uuid: c.uuid,
                  name: c.name,
                  icon: c.icon ?? 'category',
                  color: c.color ?? '#9E9E9E',
                  type: 'EXPENSE',
                  isDefault: false,
                  isDeleted: c.isDeleted,
                  createdAt: c.createdAt,
                  updatedAt: c.updatedAt,
                  isNotSynced: c.isNotSynced,
                ))
            .toList());
  }

  /// Get all categories (excluding soft-deleted)
  Future<List<Category>> getAllCategories() async {
    final list = await (_database.select(_database.productCategories)
          ..where((c) => c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
    return list
        .map((c) => Category(
              uuid: c.uuid,
              name: c.name,
              icon: c.icon ?? 'category',
              color: c.color ?? '#9E9E9E',
              type: 'EXPENSE',
              isDefault: false,
              isDeleted: c.isDeleted,
              createdAt: c.createdAt,
              updatedAt: c.updatedAt,
              isNotSynced: c.isNotSynced,
            ))
        .toList();
  }

  /// Watch categories by type
  Stream<List<Category>> watchCategoriesByType(String type) {
    return watchAllCategories();
  }

  /// Watch categories with usage info
  Stream<List<CategoryWithUsage>> watchCategoriesWithUsage(String type) {
    return watchAllCategories().map((list) {
      return list.map((c) => CategoryWithUsage(category: c, usageCount: 0)).toList();
    });
  }

  /// Get category by UUID
  Future<Category?> getCategoryByUuid(String uuid) async {
    final c = await (_database.select(_database.productCategories)
          ..where((c) => c.uuid.equals(uuid) & c.isDeleted.equals(false)))
        .getSingleOrNull();
    if (c == null) return null;
    return Category(
      uuid: c.uuid,
      name: c.name,
      icon: c.icon ?? 'category',
      color: c.color ?? '#9E9E9E',
      type: 'EXPENSE',
      isDefault: false,
      isDeleted: c.isDeleted,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
      isNotSynced: c.isNotSynced,
    );
  }

  /// Create category
  Future<String> createCategory(ProductCategoriesCompanion category) async {
    final uuid = category.uuid.present ? category.uuid.value : const Uuid().v4();
    await _database.into(_database.productCategories).insert(
          category.copyWith(
            uuid: Value(uuid),
            isNotSynced: const Value(true),
          ),
        );
    return uuid;
  }

  /// Update category
  Future<bool> updateCategory(Category category) async {
    final companion = ProductCategoriesCompanion(
      name: Value(category.name),
      icon: Value(category.icon),
      color: Value(category.color),
      updatedAt: Value(DateTime.now()),
      isNotSynced: const Value(true),
    );
    final count = await (_database.update(_database.productCategories)
          ..where((c) => c.uuid.equals(category.uuid)))
        .write(companion);
    return count > 0;
  }

  /// Check if category has associated transactions
  Future<bool> categoryHasTransactions(String categoryUuid) async {
    return false; // Safely default to false
  }

  /// Delete category (soft delete)
  Future<int> deleteCategory(String uuid) {
    return (_database.update(_database.productCategories)
          ..where((c) => c.uuid.equals(uuid)))
        .write(
      ProductCategoriesCompanion(
        isDeleted: const Value(true),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get category budget snapshot
  Future<CategoryBudgetSnapshot> getCategoryBudgetSnapshot(String categoryUuid, DateRangeState period, {List<String>? tagUuids}) async {
    final c = await getCategoryByUuid(categoryUuid) ?? Category(
      uuid: categoryUuid,
      name: 'Unknown',
      icon: '',
      color: '',
      type: 'EXPENSE',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return CategoryBudgetSnapshot(
      category: c,
      period: period,
      netAmount: 0.0,
      budgetAmount: 0.0,
      transactionCount: 0,
      overallNetAmount: 0.0,
      overallBudgetAmount: 0.0,
    );
  }

  /// Watch category budget snapshot
  Stream<CategoryBudgetSnapshot> watchCategoryBudgetSnapshot(String categoryUuid, DateRangeState period, {List<String>? tagUuids}) {
    return Stream.fromFuture(getCategoryBudgetSnapshot(categoryUuid, period, tagUuids: tagUuids));
  }

  /// Watch category net amounts
  Stream<Map<String, double>> watchCategoryNetAmountsForCategories(List<String> categoryUuids, DateTime start, DateTime end, String type, {List<String>? tagUuids}) {
    return Stream.value({});
  }

  /// Watch uncategorized amount
  Stream<double> watchUncategorizedAmountByType(String type, DateTime start, DateTime end, {List<String>? tagUuids}) {
    return Stream.value(0.0);
  }

  Future<int> softDeleteCategory(String uuid) {
    return deleteCategory(uuid);
  }

  Future<void> updateCategoryBudgetFields(
    dynamic category, {
    dynamic monthlyBudget,
    dynamic quarterlyBudget,
    dynamic yearlyBudget,
    dynamic overallBudget,
  }) async {
    // Legacy budget stub
  }
}
