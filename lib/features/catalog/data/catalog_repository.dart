import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_availability.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_discounts.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_pricing.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_sale_pick.dart';
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

/// Qty tier discount copied onto a catalog item.
class CatalogDiscountTierInput {
  final String? uuid;
  final double minQuantity;
  final String discountType;
  final double discountValue;

  const CatalogDiscountTierInput({
    this.uuid,
    required this.minQuantity,
    required this.discountType,
    required this.discountValue,
  });
}

/// Default + tiers applied/copied with pricing on add/edit.
class CatalogItemDiscountInput {
  final String? defaultDiscountType;
  final double defaultDiscountValue;
  final List<CatalogDiscountTierInput> tiers;

  const CatalogItemDiscountInput({
    this.defaultDiscountType,
    this.defaultDiscountValue = 0,
    this.tiers = const [],
  });

  static const none = CatalogItemDiscountInput();
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

  /// All active assignments (for refreshing sale catalog eligibility).
  Stream<List<CatalogAssignment>> watchAllAssignments() {
    return (_db.select(_db.catalogAssignments)
          ..where((a) => a.isDeleted.equals(false)))
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
    String defaultPricingApproach = CatalogPricingApproach.markup,
    double defaultMarkupOrMarginPercent = 0,
    double defaultFixedAmount = 0,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Catalog name is required');
    final approach = CatalogPricingApproach.all.contains(defaultPricingApproach)
        ? defaultPricingApproach
        : CatalogPricingApproach.markup;

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
              defaultPricingApproach: Value(approach),
              defaultMarkupOrMarginPercent: Value(
                defaultMarkupOrMarginPercent.isFinite
                    ? defaultMarkupOrMarginPercent
                    : 0,
              ),
              defaultFixedAmount: Value(
                defaultFixedAmount.isFinite ? defaultFixedAmount : 0,
              ),
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
    String? defaultPricingApproach,
    double? defaultMarkupOrMarginPercent,
    double? defaultFixedAmount,
  }) async {
    final existing = await getCatalog(uuid);
    if (existing == null) throw StateError('Catalog not found');
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Catalog name is required');
    final approach = defaultPricingApproach == null
        ? null
        : (CatalogPricingApproach.all.contains(defaultPricingApproach)
            ? defaultPricingApproach
            : CatalogPricingApproach.markup);

    await _db.transaction(() async {
      if (isDefault == true) await _clearDefaultFlags();
      await (_db.update(_db.catalogs)..where((c) => c.uuid.equals(uuid))).write(
        CatalogsCompanion(
          name: Value(trimmed),
          description: Value(_nullIfEmpty(description)),
          validUntil: Value(validUntil),
          isDefault: isDefault == null ? const Value.absent() : Value(isDefault),
          defaultPricingApproach:
              approach == null ? const Value.absent() : Value(approach),
          defaultMarkupOrMarginPercent: defaultMarkupOrMarginPercent == null
              ? const Value.absent()
              : Value(
                  defaultMarkupOrMarginPercent.isFinite
                      ? defaultMarkupOrMarginPercent
                      : 0,
                ),
          defaultFixedAmount: defaultFixedAmount == null
              ? const Value.absent()
              : Value(defaultFixedAmount.isFinite ? defaultFixedAmount : 0),
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
    // Clear on all active catalogs (not only WHERE isDefault) so a stuck
    // dual-default state cannot leave the old star in the list.
    await (_db.update(_db.catalogs)..where((c) => c.isDeleted.equals(false)))
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

  /// Resolve a catalog item into a sale pick (display + discount snapshot).
  Future<CatalogSalePick?> resolveSalePick(String catalogItemUuid) async {
    final item = await getItem(catalogItemUuid);
    if (item == null) return null;
    return buildSalePick(item);
  }

  Future<CatalogSalePick?> buildSalePick(CatalogItem item) async {
    final catalog = await getCatalog(item.catalogUuid);
    final tiers = await getItemTiers(item.uuid);
    final tierInputs = [
      for (final t in tiers)
        (
          minQuantity: t.minQuantity,
          type: CatalogDiscountType.isValid(t.discountType)
              ? t.discountType
              : CatalogDiscountType.percent,
          value: t.discountType == CatalogDiscountType.fixed
              ? t.discountAmount
              : t.discountPercentage,
        ),
    ];
    final catalogName = catalog?.name;

    if (item.productUuid != null && item.productUuid!.trim().isNotEmpty) {
      final product = await _inventory.getProduct(item.productUuid!);
      if (product == null) return null;
      final unitCost = await unitCostForProduct(product.uuid);
      return CatalogSalePick(
        item: item,
        displayName: product.name,
        unit: product.unit,
        categoryUuid: product.categoryUuid,
        isService: product.isService,
        product: product,
        unitCost: unitCost,
        catalogName: catalogName,
        discountTiers: tierInputs,
      );
    }

    final spUuid = item.sellingProductUuid?.trim();
    if (spUuid == null || spUuid.isEmpty) return null;
    final sp = await (_db.select(_db.sellingProducts)
          ..where((s) => s.uuid.equals(spUuid) & s.isDeleted.equals(false)))
        .getSingleOrNull();
    if (sp == null) return null;
    final unitCost = await unitCostForSellingProduct(sp.uuid);
    return CatalogSalePick(
      item: item,
      displayName: sp.name,
      unit: (sp.unit?.trim().isNotEmpty == true) ? sp.unit!.trim() : 'Pcs',
      categoryUuid: sp.categoryUuid,
      sellingProduct: sp,
      unitCost: unitCost,
      catalogName: catalogName,
      discountTiers: tierInputs,
    );
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

  Stream<List<CatalogTieredDiscount>> watchItemTiers(String catalogItemUuid) {
    return (_db.select(_db.catalogTieredDiscounts)
          ..where((t) =>
              t.catalogItemUuid.equals(catalogItemUuid) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.minQuantity)]))
        .watch();
  }

  Future<List<CatalogTieredDiscount>> getItemTiers(String catalogItemUuid) {
    return (_db.select(_db.catalogTieredDiscounts)
          ..where((t) =>
              t.catalogItemUuid.equals(catalogItemUuid) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.minQuantity)]))
        .get();
  }

  void _validateDiscounts(CatalogItemDiscountInput discounts) {
    final defaultType = _nullIfEmpty(discounts.defaultDiscountType);
    if (defaultType != null && !CatalogDiscountType.isValid(defaultType)) {
      throw ArgumentError('Invalid default discount type');
    }
    if (defaultType != null &&
        CatalogDiscountType.isValid(defaultType) &&
        discounts.defaultDiscountValue < 0) {
      throw ArgumentError('Default discount must be ≥ 0');
    }
    if (defaultType == CatalogDiscountType.percent &&
        discounts.defaultDiscountValue >= 100) {
      throw ArgumentError('Default percent discount must be < 100');
    }
    for (final t in discounts.tiers) {
      if (t.minQuantity <= 0) {
        throw ArgumentError('Tier min quantity must be positive');
      }
      if (!CatalogDiscountType.isValid(t.discountType)) {
        throw ArgumentError('Invalid tier discount type');
      }
      if (t.discountValue < 0) {
        throw ArgumentError('Tier discount must be ≥ 0');
      }
      if (t.discountType == CatalogDiscountType.percent &&
          t.discountValue >= 100) {
        throw ArgumentError('Tier percent discount must be < 100');
      }
    }
  }

  Future<void> _replaceItemTiers({
    required String catalogItemUuid,
    required List<CatalogDiscountTierInput> tiers,
  }) async {
    final now = DateTime.now();
    final existing = await getItemTiers(catalogItemUuid);
    final keepIds = <String>{
      for (final t in tiers)
        if (t.uuid != null && t.uuid!.trim().isNotEmpty) t.uuid!,
    };

    for (final row in existing) {
      if (keepIds.contains(row.uuid)) continue;
      await (_db.update(_db.catalogTieredDiscounts)
            ..where((t) => t.uuid.equals(row.uuid)))
          .write(
        CatalogTieredDiscountsCompanion(
          isDeleted: const Value(true),
          isNotSynced: const Value(true),
          updatedAt: Value(now),
        ),
      );
    }

    for (final t in tiers) {
      final percent = t.discountType == CatalogDiscountType.percent
          ? t.discountValue
          : 0.0;
      final amount =
          t.discountType == CatalogDiscountType.fixed ? t.discountValue : 0.0;
      final existingUuid = _nullIfEmpty(t.uuid);
      if (existingUuid != null &&
          existing.any((e) => e.uuid == existingUuid)) {
        await (_db.update(_db.catalogTieredDiscounts)
              ..where((r) => r.uuid.equals(existingUuid)))
            .write(
          CatalogTieredDiscountsCompanion(
            minQuantity: Value(t.minQuantity),
            discountType: Value(t.discountType),
            discountPercentage: Value(percent),
            discountAmount: Value(amount),
            isDeleted: const Value(false),
            isNotSynced: const Value(true),
            updatedAt: Value(now),
          ),
        );
      } else {
        await _db.into(_db.catalogTieredDiscounts).insert(
              CatalogTieredDiscountsCompanion.insert(
                uuid: const Uuid().v4(),
                catalogItemUuid: catalogItemUuid,
                minQuantity: t.minQuantity,
                discountPercentage: percent,
                discountType: Value(t.discountType),
                discountAmount: Value(amount),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
      }
    }
  }

  Future<void> _copyItemTiers({
    required String sourceItemUuid,
    required String targetItemUuid,
  }) async {
    final tiers = await getItemTiers(sourceItemUuid);
    if (tiers.isEmpty) return;
    final now = DateTime.now();
    for (final t in tiers) {
      await _db.into(_db.catalogTieredDiscounts).insert(
            CatalogTieredDiscountsCompanion.insert(
              uuid: const Uuid().v4(),
              catalogItemUuid: targetItemUuid,
              minQuantity: t.minQuantity,
              discountPercentage: t.discountPercentage,
              discountType: Value(t.discountType),
              discountAmount: Value(t.discountAmount),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
    }
  }

  Future<String> addItem({
    required String catalogUuid,
    required CatalogItemPricingInput pricing,
    CatalogItemDiscountInput discounts = CatalogItemDiscountInput.none,
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
    _validateDiscounts(discounts);

    final computed = await computePricing(pricing);
    final uuid = const Uuid().v4();
    final now = DateTime.now();
    final defaultType = _nullIfEmpty(discounts.defaultDiscountType);
    await _db.transaction(() async {
      await _db.into(_db.catalogItems).insert(
            CatalogItemsCompanion.insert(
              uuid: uuid,
              catalogUuid: catalogUuid,
              productUuid: Value(_nullIfEmpty(pricing.productUuid)),
              sellingProductUuid:
                  Value(_nullIfEmpty(pricing.sellingProductUuid)),
              pricingApproach: Value(pricing.pricingApproach),
              markupOrMarginPercent: Value(pricing.markupOrMarginPercent),
              fixedAmount: Value(pricing.fixedAmount),
              sellPrice: Value(computed.sellPrice),
              unitCostSnapshot: Value(computed.unitCost),
              priceComputedAt: Value(now),
              customPrice: Value(computed.sellPrice),
              defaultDiscountType: Value(defaultType),
              defaultDiscountValue: Value(
                defaultType == null ? 0 : discounts.defaultDiscountValue,
              ),
              validUntil: Value(validUntil),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      if (discounts.tiers.isNotEmpty) {
        await _replaceItemTiers(
          catalogItemUuid: uuid,
          tiers: discounts.tiers,
        );
      }
    });
    return uuid;
  }

  /// Bulk-add lines that share the same formula + discount inputs (copied per line).
  Future<int> addItemsBulk({
    required String catalogUuid,
    required List<CatalogItemPricingInput> targets,
    required String pricingApproach,
    required double markupOrMarginPercent,
    required double fixedAmount,
    CatalogItemDiscountInput discounts = CatalogItemDiscountInput.none,
  }) async {
    var added = 0;
    for (final target in targets) {
      final dup = await findDuplicate(
        catalogUuid: catalogUuid,
        productUuid: target.productUuid,
        sellingProductUuid: target.sellingProductUuid,
      );
      if (dup != null) continue;
      await addItem(
        catalogUuid: catalogUuid,
        pricing: CatalogItemPricingInput(
          productUuid: target.productUuid,
          sellingProductUuid: target.sellingProductUuid,
          pricingApproach: pricingApproach,
          markupOrMarginPercent: markupOrMarginPercent,
          fixedAmount: fixedAmount,
        ),
        discounts: CatalogItemDiscountInput(
          defaultDiscountType: discounts.defaultDiscountType,
          defaultDiscountValue: discounts.defaultDiscountValue,
          tiers: [
            for (final t in discounts.tiers)
              CatalogDiscountTierInput(
                minQuantity: t.minQuantity,
                discountType: t.discountType,
                discountValue: t.discountValue,
              ),
          ],
        ),
      );
      added++;
    }
    return added;
  }

  /// Copy / recalculate items from [sourceCatalogUuid] into [targetCatalogUuid].
  /// [conflictAction] should be [CatalogImportConflictAction.skipAll] or
  /// [CatalogImportConflictAction.replaceAll] for bulk import.
  Future<({int added, int replaced, int skipped})> addFromCatalog({
    required String targetCatalogUuid,
    required String sourceCatalogUuid,
    required CatalogImportPriceMode priceMode,
    required CatalogImportConflictAction conflictAction,
  }) async {
    if (targetCatalogUuid == sourceCatalogUuid) {
      throw ArgumentError('Source and target catalog must differ');
    }
    final replace = conflictAction == CatalogImportConflictAction.replace ||
        conflictAction == CatalogImportConflictAction.replaceAll;
    final sourceItems = await getItems(sourceCatalogUuid);
    var added = 0;
    var replaced = 0;
    var skipped = 0;

    for (final source in sourceItems) {
      final dup = await findDuplicate(
        catalogUuid: targetCatalogUuid,
        productUuid: source.productUuid,
        sellingProductUuid: source.sellingProductUuid,
      );

      if (dup != null) {
        if (!replace) {
          skipped++;
          continue;
        }
        await softDeleteItem(dup.uuid);
        replaced++;
      }

      if (priceMode == CatalogImportPriceMode.copy) {
        final uuid = const Uuid().v4();
        final now = DateTime.now();
        await _db.into(_db.catalogItems).insert(
              CatalogItemsCompanion.insert(
                uuid: uuid,
                catalogUuid: targetCatalogUuid,
                productUuid: Value(source.productUuid),
                sellingProductUuid: Value(source.sellingProductUuid),
                pricingApproach: Value(source.pricingApproach),
                markupOrMarginPercent: Value(source.markupOrMarginPercent),
                fixedAmount: Value(source.fixedAmount),
                sellPrice: Value(source.sellPrice),
                unitCostSnapshot: Value(source.unitCostSnapshot),
                priceComputedAt: Value(source.priceComputedAt ?? now),
                customPrice: Value(source.sellPrice),
                priceOverride: Value(source.priceOverride),
                defaultDiscountType: Value(source.defaultDiscountType),
                defaultDiscountValue: Value(source.defaultDiscountValue),
                validUntil: Value(source.validUntil),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );
        await _copyItemTiers(
          sourceItemUuid: source.uuid,
          targetItemUuid: uuid,
        );
      } else {
        final sourceTiers = await getItemTiers(source.uuid);
        await addItem(
          catalogUuid: targetCatalogUuid,
          pricing: CatalogItemPricingInput(
            productUuid: source.productUuid,
            sellingProductUuid: source.sellingProductUuid,
            pricingApproach: source.pricingApproach,
            markupOrMarginPercent: source.markupOrMarginPercent,
            fixedAmount: source.fixedAmount,
          ),
          discounts: CatalogItemDiscountInput(
            defaultDiscountType: source.defaultDiscountType,
            defaultDiscountValue: source.defaultDiscountValue,
            tiers: [
              for (final t in sourceTiers)
                CatalogDiscountTierInput(
                  minQuantity: t.minQuantity,
                  discountType: t.discountType,
                  discountValue: t.discountType == CatalogDiscountType.fixed
                      ? t.discountAmount
                      : t.discountPercentage,
                ),
            ],
          ),
          validUntil: source.validUntil,
        );
      }
      added++;
    }
    return (added: added, replaced: replaced, skipped: skipped);
  }

  Future<void> updateItemPricing({
    required String itemUuid,
    required String pricingApproach,
    required double markupOrMarginPercent,
    required double fixedAmount,
    double? sellPriceOverride,
    CatalogItemDiscountInput? discounts,
  }) async {
    final item = await getItem(itemUuid);
    if (item == null) throw StateError('Catalog item not found');
    if (!CatalogPricingApproach.all.contains(pricingApproach)) {
      throw ArgumentError('Invalid pricing approach');
    }
    if (discounts != null) _validateDiscounts(discounts);

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
    final isOverride = sellPriceOverride != null;
    await _db.transaction(() async {
      final companion = CatalogItemsCompanion(
        pricingApproach: Value(pricingApproach),
        markupOrMarginPercent: Value(markupOrMarginPercent),
        fixedAmount: Value(fixedAmount),
        sellPrice: Value(computed.sellPrice),
        unitCostSnapshot: Value(computed.unitCost),
        priceComputedAt: Value(now),
        customPrice: Value(computed.sellPrice),
        priceOverride: Value(isOverride),
        isNotSynced: const Value(true),
        updatedAt: Value(now),
        defaultDiscountType: discounts == null
            ? const Value.absent()
            : Value(_nullIfEmpty(discounts.defaultDiscountType)),
        defaultDiscountValue: discounts == null
            ? const Value.absent()
            : Value(
                _nullIfEmpty(discounts.defaultDiscountType) == null
                    ? 0
                    : discounts.defaultDiscountValue,
              ),
      );
      await (_db.update(_db.catalogItems)..where((i) => i.uuid.equals(itemUuid)))
          .write(companion);
      if (discounts != null) {
        await _replaceItemTiers(
          catalogItemUuid: itemUuid,
          tiers: discounts.tiers,
        );
      }
    });
  }

  /// Recompute sellPrice from current unit cost using stored formula fields.
  /// Clears [CatalogItem.priceOverride] when applied.
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

  /// Refresh formula-driven items only; skips manual price overrides.
  Future<({int updated, int skipped})> recalculateCatalog(
    String catalogUuid,
  ) async {
    final items = await getItems(catalogUuid);
    var updated = 0;
    var skipped = 0;
    for (final item in items) {
      if (item.priceOverride) {
        skipped++;
        continue;
      }
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
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.catalogItems)..where((i) => i.uuid.equals(itemUuid)))
          .write(
        CatalogItemsCompanion(
          isDeleted: const Value(true),
          isNotSynced: const Value(true),
          updatedAt: Value(now),
        ),
      );
      final tiers = await getItemTiers(itemUuid);
      for (final t in tiers) {
        await (_db.update(_db.catalogTieredDiscounts)
              ..where((r) => r.uuid.equals(t.uuid)))
            .write(
          CatalogTieredDiscountsCompanion(
            isDeleted: const Value(true),
            isNotSynced: const Value(true),
            updatedAt: Value(now),
          ),
        );
      }
    });
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

  // --- Resolve for sales ---

  /// Active (non-expired) catalog marked as the business default, if any.
  Future<Catalog?> getDefaultCatalog() async {
    final catalog = await (_db.select(_db.catalogs)
          ..where((c) => c.isDefault.equals(true) & c.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();
    if (catalog == null || !CatalogAvailability.isActive(catalog)) return null;
    return catalog;
  }

  /// Stable sale/list order: default first, then name A–Z (case-insensitive).
  static int compareCatalogsForSale(Catalog a, Catalog b) {
    if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  /// All non-deleted catalogs that are still within [Catalog.validUntil].
  Future<List<Catalog>> listActiveCatalogs() async {
    final rows = await (_db.select(_db.catalogs)
          ..where((c) => c.isDeleted.equals(false)))
        .get();
    final active = [
      for (final c in rows)
        if (CatalogAvailability.isActive(c)) c,
    ];
    active.sort(compareCatalogsForSale);
    return active;
  }

  /// Catalog uuids that have at least one active contact assignment.
  /// Those are restricted; catalogs with none are open to all / walk-in.
  Future<Set<String>> catalogUuidsWithAssignments() async {
    final rows = await (_db.select(_db.catalogAssignments)
          ..where((a) => a.isDeleted.equals(false)))
        .get();
    return {for (final a in rows) a.catalogUuid};
  }

  /// Active catalogs visible for a sale contact.
  ///
  /// - Catalog with **no** assignments → everyone (incl. walk-in)
  /// - Catalog with assignments → only those contacts
  ///
  /// Order is always [compareCatalogsForSale] (default first, then A–Z).
  Future<List<Catalog>> listActiveCatalogsForContact(String? contactUuid) async {
    final all = await listActiveCatalogs();
    if (all.isEmpty) return const [];

    final restrictedIds = await catalogUuidsWithAssignments();
    final contact = contactUuid?.trim();

    // Walk-in: only open (unassigned) catalogs.
    if (contact == null || contact.isEmpty) {
      return [
        for (final c in all)
          if (!restrictedIds.contains(c.uuid)) c,
      ];
    }

    final assignedToContact = await (_db.select(_db.catalogAssignments)
          ..where((a) =>
              a.contactUuid.equals(contact) & a.isDeleted.equals(false)))
        .get();
    final assignedIds = {for (final a in assignedToContact) a.catalogUuid};

    return [
      for (final c in all)
        if (!restrictedIds.contains(c.uuid) || assignedIds.contains(c.uuid)) c,
    ];
  }

  /// Best catalog for a sale among [listActiveCatalogsForContact].
  ///
  /// Prefer a catalog assigned to the contact (default first, then A–Z),
  /// else first eligible (already default-first / A–Z).
  Future<Catalog?> resolveCatalogForContact(String? contactUuid) async {
    final eligible = await listActiveCatalogsForContact(contactUuid);
    if (eligible.isEmpty) return null;

    final contact = contactUuid?.trim();
    if (contact != null && contact.isNotEmpty) {
      final restrictedIds = await catalogUuidsWithAssignments();
      final assigned = [
        for (final c in eligible)
          if (restrictedIds.contains(c.uuid)) c,
      ];
      if (assigned.isNotEmpty) return assigned.first;
    }

    return eligible.first;
  }

  /// Row by uuid including soft-deleted (for historical sale line checks).
  Future<CatalogItem?> getItemAny(String uuid) {
    return (_db.select(_db.catalogItems)..where((i) => i.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  /// Catalog by uuid including soft-deleted.
  Future<Catalog?> getCatalogAny(String uuid) {
    return (_db.select(_db.catalogs)..where((c) => c.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  /// Validate a sale order line against its catalog snapshot refs.
  Future<SaleCatalogLineIssue> saleLineCatalogIssue(OrderItem line) async {
    final itemUuid = line.catalogItemUuid?.trim();
    if (itemUuid == null || itemUuid.isEmpty) {
      // Legacy / non-catalog lines: no catalog integrity issue to flag.
      return SaleCatalogLineIssue.none;
    }

    final item = await getItemAny(itemUuid);
    if (item == null || item.isDeleted) {
      return SaleCatalogLineIssue.catalogItemUnavailable;
    }

    final catalog = await getCatalogAny(item.catalogUuid);
    if (catalog == null || catalog.isDeleted) {
      return SaleCatalogLineIssue.catalogDeleted;
    }
    if (CatalogAvailability.isExpired(catalog)) {
      return SaleCatalogLineIssue.catalogExpired;
    }
    return SaleCatalogLineIssue.none;
  }

  /// Map order-item uuid → issue for all lines on an order.
  Future<Map<String, SaleCatalogLineIssue>> saleLineCatalogIssuesForOrder(
    String orderUuid,
  ) async {
    final items = await (_db.select(_db.orderItems)
          ..where((oi) =>
              oi.orderUuid.equals(orderUuid) & oi.isDeleted.equals(false)))
        .get();
    final out = <String, SaleCatalogLineIssue>{};
    for (final item in items) {
      out[item.uuid] = await saleLineCatalogIssue(item);
    }
    return out;
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
