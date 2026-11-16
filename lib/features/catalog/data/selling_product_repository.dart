import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_pricing.dart';
import 'package:uuid/uuid.dart';

/// Input line when creating/updating a selling product.
class SellingProductComponentInput {
  final String productUuid;
  final double quantity;
  final String consumeMode;
  final String? batchNumber;

  const SellingProductComponentInput({
    required this.productUuid,
    required this.quantity,
    this.consumeMode = SellingConsumeMode.auto,
    this.batchNumber,
  });
}

class SellingProductRepository {
  final AppDatabase _db;

  SellingProductRepository(this._db);

  Stream<List<SellingProduct>> watchAll() {
    return (_db.select(_db.sellingProducts)
          ..where((r) => r.isDeleted.equals(false))
          ..orderBy([(r) => OrderingTerm.asc(r.name)]))
        .watch();
  }

  Stream<SellingProduct?> watchOne(String uuid) {
    return (_db.select(_db.sellingProducts)
          ..where((r) => r.uuid.equals(uuid) & r.isDeleted.equals(false)))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<SellingProduct?> get(String uuid) {
    return (_db.select(_db.sellingProducts)
          ..where((r) => r.uuid.equals(uuid) & r.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<List<SellingProductComponent>> getComponents(String sellingProductUuid) {
    return (_db.select(_db.sellingProductComponents)
          ..where((c) =>
              c.sellingProductUuid.equals(sellingProductUuid) &
              c.isDeleted.equals(false)))
        .get();
  }

  Stream<List<SellingProductComponent>> watchComponents(
    String sellingProductUuid,
  ) {
    return (_db.select(_db.sellingProductComponents)
          ..where((c) =>
              c.sellingProductUuid.equals(sellingProductUuid) &
              c.isDeleted.equals(false)))
        .watch();
  }

  void _validateComponents(List<SellingProductComponentInput> components) {
    if (components.isEmpty) {
      throw ArgumentError('At least one component is required');
    }
    for (final c in components) {
      if (c.productUuid.trim().isEmpty) {
        throw ArgumentError('Component product is required');
      }
      if (c.quantity <= 0) {
        throw ArgumentError('Component quantity must be positive');
      }
      if (!SellingConsumeMode.all.contains(c.consumeMode)) {
        throw ArgumentError('Invalid consume mode: ${c.consumeMode}');
      }
      if (c.consumeMode == SellingConsumeMode.batch) {
        final batch = c.batchNumber?.trim() ?? '';
        if (batch.isEmpty) {
          throw ArgumentError('Batch number required when consume mode is BATCH');
        }
      }
    }
  }

  /// Resolves category: explicit [categoryUuid], else first component product's category.
  Future<String?> _resolveCategoryUuid({
    String? categoryUuid,
    required List<SellingProductComponentInput> components,
  }) async {
    final explicit = _nullIfEmpty(categoryUuid);
    if (explicit != null) return explicit;
    if (components.isEmpty) return null;
    final product = await (_db.select(_db.products)
          ..where((p) =>
              p.uuid.equals(components.first.productUuid) &
              p.isDeleted.equals(false)))
        .getSingleOrNull();
    return _nullIfEmpty(product?.categoryUuid);
  }

  Future<String> create({
    required String name,
    String? sku,
    String? description,
    String? categoryUuid,
    required List<SellingProductComponentInput> components,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Name is required');
    _validateComponents(components);
    final resolvedCategory = await _resolveCategoryUuid(
      categoryUuid: categoryUuid,
      components: components,
    );

    return _db.transaction(() async {
      final uuid = const Uuid().v4();
      await _db.into(_db.sellingProducts).insert(
            SellingProductsCompanion.insert(
              uuid: uuid,
              name: trimmed,
              sku: Value(_nullIfEmpty(sku)),
              description: Value(_nullIfEmpty(description)),
              categoryUuid: Value(resolvedCategory),
            ),
          );
      await _insertComponents(uuid, components);
      return uuid;
    });
  }

  Future<void> update({
    required String uuid,
    required String name,
    String? sku,
    String? description,
    String? categoryUuid,
    required List<SellingProductComponentInput> components,
  }) async {
    final existing = await get(uuid);
    if (existing == null) throw StateError('Selling product not found');
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Name is required');
    _validateComponents(components);
    final resolvedCategory = await _resolveCategoryUuid(
      categoryUuid: categoryUuid,
      components: components,
    );

    await _db.transaction(() async {
      await (_db.update(_db.sellingProducts)..where((r) => r.uuid.equals(uuid)))
          .write(
        SellingProductsCompanion(
          name: Value(trimmed),
          sku: Value(_nullIfEmpty(sku)),
          description: Value(_nullIfEmpty(description)),
          categoryUuid: Value(resolvedCategory),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final old = await (_db.select(_db.sellingProductComponents)
            ..where((c) => c.sellingProductUuid.equals(uuid)))
          .get();
      for (final row in old) {
        if (row.isDeleted) continue;
        await (_db.update(_db.sellingProductComponents)
              ..where((c) => c.uuid.equals(row.uuid)))
            .write(
          SellingProductComponentsCompanion(
            isDeleted: const Value(true),
            isNotSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
      await _insertComponents(uuid, components);
    });
  }

  Future<void> softDelete(String uuid) async {
    final existing = await get(uuid);
    if (existing == null) return;

    await _db.transaction(() async {
      await (_db.update(_db.sellingProducts)..where((r) => r.uuid.equals(uuid)))
          .write(
        SellingProductsCompanion(
          isDeleted: const Value(true),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final comps = await (_db.select(_db.sellingProductComponents)
            ..where((c) =>
                c.sellingProductUuid.equals(uuid) & c.isDeleted.equals(false)))
          .get();
      for (final c in comps) {
        await (_db.update(_db.sellingProductComponents)
              ..where((row) => row.uuid.equals(c.uuid)))
            .write(
          SellingProductComponentsCompanion(
            isDeleted: const Value(true),
            isNotSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  Future<void> _insertComponents(
    String sellingProductUuid,
    List<SellingProductComponentInput> components,
  ) async {
    for (final c in components) {
      final batch = c.consumeMode == SellingConsumeMode.batch
          ? c.batchNumber?.trim()
          : null;
      await _db.into(_db.sellingProductComponents).insert(
            SellingProductComponentsCompanion.insert(
              uuid: const Uuid().v4(),
              sellingProductUuid: sellingProductUuid,
              productUuid: c.productUuid,
              quantity: c.quantity,
              consumeMode: Value(c.consumeMode),
              batchNumber: Value(
                batch == null || batch.isEmpty ? null : batch,
              ),
            ),
          );
    }
  }

  String? _nullIfEmpty(String? value) {
    final t = value?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }
}
