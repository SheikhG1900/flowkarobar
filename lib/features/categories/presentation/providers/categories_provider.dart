import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/categories/data/categories_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

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
  return repository.watchCategoriesByType(type);
});

final categoriesWithUsageProvider = StreamProvider.family<List<CategoryWithUsage>, String>((ref, type) {
  final repository = ref.watch(categoriesRepositoryProvider);
  return repository.watchCategoriesWithUsage(type);
});

// Helper for icon data (mapping string <-> IconData)
// We'll use a simple map for now, or store code points
// The database stores icon as int (code point) or string.
// Let's assume int codePoint for now as per Drift schema usually,
// but let's check the schema.

