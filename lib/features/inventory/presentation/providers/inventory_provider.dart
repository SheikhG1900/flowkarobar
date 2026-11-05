import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/inventory/data/inventory_repository.dart';
import 'package:flowpaisa/features/inventory/domain/batch_models.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return InventoryRepository(db);
});

final productCategoriesStreamProvider =
    StreamProvider<List<ProductCategory>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchAllCategories();
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchAllProducts();
});

final productStreamProvider =
    StreamProvider.family<Product?, String>((ref, productUuid) {
  return ref.watch(inventoryRepositoryProvider).watchProduct(productUuid);
});

final lowStockProductsStreamProvider =
    StreamProvider<List<Product>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchLowStockProducts();
});

final expiringBatchesStreamProvider =
    StreamProvider.family<List<ProductBatche>, int>((ref, days) {
  return ref
      .watch(inventoryRepositoryProvider)
      .watchExpiringSoonBatches(daysThreshold: days);
});

final productBatchesStreamProvider =
    StreamProvider.family<List<ProductBatche>, String>((ref, productUuid) {
  return ref
      .watch(inventoryRepositoryProvider)
      .watchBatchesForProduct(productUuid);
});

/// PO / receipt context keyed by lot uuid for a product's purchase lots.
final productLotSourcesProvider = FutureProvider.autoDispose
    .family<Map<String, LotPurchaseContext>, String>((ref, productUuid) async {
  final batchesAsync = ref.watch(productBatchesStreamProvider(productUuid));
  final batches = batchesAsync.value;
  if (batches == null || batches.isEmpty) return const {};
  return ref
      .read(inventoryRepositoryProvider)
      .getLotPurchaseContexts(batches);
});
