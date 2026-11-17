import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/catalog/data/catalog_repository.dart';
import 'package:flowpaisa/features/catalog/data/selling_product_repository.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

final sellingProductRepositoryProvider =
    Provider<SellingProductRepository>((ref) {
  return SellingProductRepository(ref.watch(databaseProvider));
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(
    ref.watch(databaseProvider),
    ref.watch(inventoryRepositoryProvider),
  );
});

final sellingProductsStreamProvider =
    StreamProvider<List<SellingProduct>>((ref) {
  return ref.watch(sellingProductRepositoryProvider).watchAll();
});

final sellingProductStreamProvider =
    StreamProvider.family<SellingProduct?, String>((ref, uuid) {
  return ref.watch(sellingProductRepositoryProvider).watchOne(uuid);
});

final sellingProductComponentsStreamProvider = StreamProvider.family<
    List<SellingProductComponent>, String>((ref, sellingProductUuid) {
  return ref
      .watch(sellingProductRepositoryProvider)
      .watchComponents(sellingProductUuid);
});

final catalogsStreamProvider = StreamProvider<List<Catalog>>((ref) {
  return ref.watch(catalogRepositoryProvider).watchAllCatalogs();
});

final catalogStreamProvider =
    StreamProvider.family<Catalog?, String>((ref, uuid) {
  return ref.watch(catalogRepositoryProvider).watchCatalog(uuid);
});

final catalogItemsStreamProvider =
    StreamProvider.family<List<CatalogItem>, String>((ref, catalogUuid) {
  return ref.watch(catalogRepositoryProvider).watchItems(catalogUuid);
});

final catalogAssignmentsStreamProvider =
    StreamProvider.family<List<CatalogAssignment>, String>((ref, catalogUuid) {
  return ref.watch(catalogRepositoryProvider).watchAssignments(catalogUuid);
});
