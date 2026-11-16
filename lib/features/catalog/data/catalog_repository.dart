import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_pricing.dart';
import 'package:flowpaisa/features/inventory/data/inventory_repository.dart';
import 'package:uuid/uuid.dart';

/// How to resolve unit cost / sell price for a catalog line target.
class CatalogItemPricingInput {
  final String? productUuid;
  final String? sellingProductUuid;
  final String pricingApproach;
  final double markupOrMarginPercent;
  final double fixedAmount;

  /// When set, used as sellPrice instead of computing from cost.
  final double? sellPriceOverride;

  const CatalogItemPricingInput({
    this.productUuid,
    this.sellingProductUuid,
    this.pricingApproach = CatalogPricingApproach.markup,
    this.markupOrMarginPercent = 0,
    this.fixedAmount = 0,
    this.sellPriceOverride,
  });
}

class CatalogRepository {
  final AppDatabase _db;
  final InventoryRepository _inventory;

  CatalogRepository(this._db, this._inventory);

  // --- Catalogs ---

  Stream<List<Catalog>> watchAllCatalogs() {
    return (_db.select(_db.catalogs)
          ..where((c) => c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  Stream<Catalog?> watchCatalog(String uuid) {
    return (_db.select(_db.catalogs)
          ..where((c) => c.uuid.equals(uuid) & c.isDeleted.equals(false)))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<Catalog?> getCatalog(String uuid) {
    return (_db.select(_db.catalogs)
          ..where((c) => c.uuid.equals(uuid) & c.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  Future<String> createCatalog({
    required String name,
    String? description,
    DateTime? validUntil,
    bool isDefault = false,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Catalog name is required');

    return _db.transaction(() async {
      if (isDefault) await _clearDefaultFlags();
      final uuid = const Uuid().v4();
      await _db.into(_db.catalogs).insert(
            CatalogsCompanion.insert(
              uuid: uuid,
              name: trimmed,
              description: Value(_nullIfEmpty(description)),
              validUntil: Value(validUntil),
              isDefault: Value(isDefault),
            ),
          );
      return uuid;
    });
  }

  Future<void> updateCatalog({
    required String uuid,
    required String name,
    String? description,
    DateTime? validUntil,
    bool? isDefault,
  }) async {
    final existing = await getCatalog(uuid);
    if (existing == null) throw StateError('Catalog not found');
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Catalog name is required');

    await _db.transaction(() async {
      if (isDefault == true) await _clearDefaultFlags();
      await (_db.update(_db.catalogs)..where((c) => c.uuid.equals(uuid))).write(
        CatalogsCompanion(
          name: Value(trimmed),
          description: Value(_nullIfEmpty(description)),
          validUntil: Value(validUntil),
          isDefault: isDefault == null ? const Value.absent() : Value(isDefault),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> softDeleteCatalog(String uuid) async {
    final existing = await getCatalog(uuid);
    if (existing == null) return;

    await _db.transaction(() async {
      await (_db.update(_db.catalogs)..where((c) => c.uuid.equals(uuid))).write(
        CatalogsCompanion(
          isDeleted: const Value(true),
          isNotSynced: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
      final items = await (_db.select(_db.catalogItems)
            ..where(
                (i) => i.catalogUuid.equals(uuid) & i.isDeleted.equals(false)))
          .get();
      for (final item in items) {
        await (_db.update(_db.catalogItems)
              ..where((i) => i.uuid.equals(item.uuid)))
            .write(
          CatalogItemsCompanion(
            isDeleted: const Value(true),
            isNotSynced: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  Future<void> _clearDefaultFlags() async {
    await (_db.update(_db.catalogs)..where((c) => c.isDefault.equals(true)))
        .write(
      CatalogsCompanion(
        isDefault: const Value(false),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // --- Items ---

  Stream<List<CatalogItem>> watchItems(String catalogUuid) {
    return (_db.select(_db.catalogItems)
          ..where((i) =>
              i.catalogUuid.equals(catalogUuid) & i.isDeleted.equals(false))
          ..orderBy([(i) => OrderingTerm.asc(i.createdAt)]))
        .watch();
  }

  Future<List<CatalogItem>> getItems(String catalogUuid) {
    return (_db.select(_db.catalogItems)
          ..where((i) =>
              i.catalogUuid.equals(catalogUuid) & i.isDeleted.equals(false)))
        .get();
  }

  Future<CatalogItem?> getItem(String uuid) {
    return (_db.select(_db.catalogItems)
          ..where((i) => i.uuid.equals(uuid) & i.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Unit cost for a direct product link (service or stock).
  Future<double> unitCostForProduct(
    String productUuid, {
    String? batchNumber,
  }) async {
    final product = await (_db.select(_db.products)
          ..where(
              (p) => p.uuid.equals(productUuid) & p.isDeleted.equals(false)))
        .getSingleOrNull();
    if (product == null) return 0;

    if (product.isService) {
      return product.purchasePrice;
    }

    final avg = await _inventory.averageUnitCost(
      productUuid: productUuid,
      batchNumber: batchNumber,
    );
    if (avg > 1e-9) return avg;
    return product.purchasePrice;
  }

  /// Unit cost for a selling product (sum of component costs × qty).
  Future<double> unitCostForSellingProduct(String sellingProductUuid) async {
    final components = await (_db.select(_db.sellingProductComponents)
          ..where((c) =>
              c.sellingProductUuid.equals(sellingProductUuid) &
              c.isDeleted.equals(false)))
        .get();
    var total = 0.0;
    for (final c in components) {
      final batch = c.consumeMode == SellingConsumeMode.batch
          ? c.batchNumber
          : null;
      final unit = await unitCostForProduct(
        c.productUuid,
        batchNumber: batch,
      );
      total += unit * c.quantity;
    }
    return total;
  }

  Future<double> resolveUnitCost({
    String? productUuid,
    String? sellingProductUuid,
  }) async {
    if (!CatalogPricing.isValidLink(
      productUuid: productUuid,
      sellingProductUuid: sellingProductUuid,
    )) {
      throw ArgumentError(
        'Catalog item requires exactly one of productUuid or sellingProductUuid',
      );
    }
    if (productUuid != null && productUuid.trim().isNotEmpty) {
      return unitCostForProduct(productUuid);
    }
    return unitCostForSellingProduct(sellingProductUuid!);
  }

  Future<({double unitCost, double sellPrice})> computePricing(
    CatalogItemPricingInput input,
  ) async {
    final unitCost = await resolveUnitCost(
      productUuid: input.productUuid,
      sellingProductUuid: input.sellingProductUuid,
    );
    if (input.sellPriceOverride != null) {
      return (unitCost: unitCost, sellPrice: input.sellPriceOverride!);
    }
    final sellPrice = CatalogPricing.computeSellPrice(
      approach: input.pricingApproach,
      unitCost: unitCost,
      percent: input.markupOrMarginPercent,
      fixedAmount: input.fixedAmount,
    );
    return (unitCost: unitCost, sellPrice: sellPrice);
  }

  Future<String> addItem({
    required String catalogUuid,
    required CatalogItemPricingInput pricing,
    DateTime? validUntil,
  }) async {
    final catalog = await getCatalog(catalogUuid);
    if (catalog == null) throw StateError('Catalog not found');
    if (!CatalogPricingApproach.all.contains(pricing.pricingApproach)) {
      throw ArgumentError('Invalid pricing approach');
    }
    if (!CatalogPricing.isValidLink(
      productUuid: pricing.productUuid,
      sellingProductUuid: pricing.sellingProductUuid,
    )) {
      throw ArgumentError(
        'Catalog item requires exactly one of productUuid or sellingProductUuid',
      );
    }

    final computed = await computePricing(pricing);
    final uuid = const Uuid().v4();
    final now = DateTime.now();
    await _db.into(_db.catalogItems).insert(
          CatalogItemsCompanion.insert(
            uuid: uuid,
            catalogUuid: catalogUuid,
            productUuid: Value(_nullIfEmpty(pricing.productUuid)),
            sellingProductUuid: Value(_nullIfEmpty(pricing.sellingProductUuid)),
            pricingApproach: Value(pricing.pricingApproach),
            markupOrMarginPercent: Value(pricing.markupOrMarginPercent),
            fixedAmount: Value(pricing.fixedAmount),
            sellPrice: Value(computed.sellPrice),
            unitCostSnapshot: Value(computed.unitCost),
            priceComputedAt: Value(now),
            customPrice: Value(computed.sellPrice),
            validUntil: Value(validUntil),
          ),
        );
    return uuid;
  }

  Future<void> updateItemPricing({
    required String itemUuid,
    required String pricingApproach,
    required double markupOrMarginPercent,
    required double fixedAmount,
    double? sellPriceOverride,
  }) async {
    final item = await getItem(itemUuid);
    if (item == null) throw StateError('Catalog item not found');
    if (!CatalogPricingApproach.all.contains(pricingApproach)) {
      throw ArgumentError('Invalid pricing approach');
    }

    final computed = await computePricing(
      CatalogItemPricingInput(
        productUuid: item.productUuid,
        sellingProductUuid: item.sellingProductUuid,
        pricingApproach: pricingApproach,
        markupOrMarginPercent: markupOrMarginPercent,
        fixedAmount: fixedAmount,
        sellPriceOverride: sellPriceOverride,
      ),
    );
    final now = DateTime.now();
    await (_db.update(_db.catalogItems)..where((i) => i.uuid.equals(itemUuid)))
        .write(
      CatalogItemsCompanion(
        pricingApproach: Value(pricingApproach),
        markupOrMarginPercent: Value(markupOrMarginPercent),
        fixedAmount: Value(fixedAmount),
        sellPrice: Value(computed.sellPrice),
        unitCostSnapshot: Value(computed.unitCost),
        priceComputedAt: Value(now),
        customPrice: Value(computed.sellPrice),
        isNotSynced: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  /// Recompute sellPrice from current unit cost using stored formula fields.
  Future<bool> refreshItemPrice(String itemUuid) async {
    final item = await getItem(itemUuid);
    if (item == null) return false;
    await updateItemPricing(
      itemUuid: itemUuid,
      pricingApproach: item.pricingApproach,
      markupOrMarginPercent: item.markupOrMarginPercent,
      fixedAmount: item.fixedAmount,
    );
    return true;
  }

  /// Refresh all active items in a catalog. Returns counts.
  Future<({int updated, int skipped})> recalculateCatalog(
    String catalogUuid,
  ) async {
    final items = await getItems(catalogUuid);
    var updated = 0;
    var skipped = 0;
    for (final item in items) {
      try {
        final ok = await refreshItemPrice(item.uuid);
        if (ok) {
          updated++;
        } else {
          skipped++;
        }
      } catch (_) {
        skipped++;
      }
    }
    return (updated: updated, skipped: skipped);
  }

  Future<void> softDeleteItem(String itemUuid) async {
    final item = await getItem(itemUuid);
    if (item == null) return;
    await (_db.update(_db.catalogItems)..where((i) => i.uuid.equals(itemUuid)))
        .write(
      CatalogItemsCompanion(
        isDeleted: const Value(true),
        isNotSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Find active item in catalog with same product or selling-product link.
  Future<CatalogItem?> findDuplicate({
    required String catalogUuid,
    String? productUuid,
    String? sellingProductUuid,
  }) async {
    final items = await getItems(catalogUuid);
    final p = _nullIfEmpty(productUuid);
    final s = _nullIfEmpty(sellingProductUuid);
    for (final item in items) {
      if (p != null && item.productUuid == p) return item;
      if (s != null && item.sellingProductUuid == s) return item;
    }
    return null;
  }

  // --- Assignments ---

  Stream<List<CatalogAssignment>> watchAssignments(String catalogUuid) {
    return (_db.select(_db.catalogAssignments)
          ..where((a) =>
              a.catalogUuid.equals(catalogUuid) & a.isDeleted.equals(false)))
        .watch();
  }

  Future<String> assignCatalog({
    required String catalogUuid,
    required String contactUuid,
  }) async {
    final existing = await (_db.select(_db.catalogAssignments)
          ..where((a) =>
              a.catalogUuid.equals(catalogUuid) &
              a.contactUuid.equals(contactUuid) &
              a.isDeleted.equals(false)))
        .getSingleOrNull();
    if (existing != null) return existing.uuid;

    final uuid = const Uuid().v4();
    await _db.into(_db.catalogAssignments).insert(
          CatalogAssignmentsCompanion.insert(
            uuid: uuid,
            catalogUuid: catalogUuid,
            contactUuid: contactUuid,
          ),
        );
    return uuid;
  }

  Future<void> unassignCatalog(String assignmentUuid) async {
    await (_db.update(_db.catalogAssignments)
          ..where((a) => a.uuid.equals(assignmentUuid)))
        .write(
      CatalogAssignmentsCompanion(
        isDeleted: const Value(true),
        isNotSynced: const Value(true),
      ),
    );
  }

  String? _nullIfEmpty(String? value) {
    final t = value?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }
}
