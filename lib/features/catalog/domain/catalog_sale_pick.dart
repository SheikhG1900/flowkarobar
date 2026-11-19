import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_discounts.dart';

/// A catalog line chosen on a sale order (price snapshot + discount inputs).
class CatalogSalePick {
  final CatalogItem item;
  final String displayName;
  final String unit;
  final String? categoryUuid;
  final bool isService;
  final Product? product;
  final SellingProduct? sellingProduct;
  final double unitCost;
  final String? catalogName;
  final List<({double minQuantity, String type, double value})> discountTiers;

  const CatalogSalePick({
    required this.item,
    required this.displayName,
    required this.unit,
    required this.unitCost,
    this.categoryUuid,
    this.isService = false,
    this.product,
    this.sellingProduct,
    this.catalogName,
    this.discountTiers = const [],
  });

  String? get productUuid => item.productUuid;
  String? get sellingProductUuid => item.sellingProductUuid;
  String get catalogUuid => item.catalogUuid;
  double get sellPrice => item.sellPrice;

  CatalogSalePick withCatalogName(String? name) {
    if (name == null || name.trim().isEmpty) return this;
    if (catalogName != null && catalogName!.trim().isNotEmpty) return this;
    return CatalogSalePick(
      item: item,
      displayName: displayName,
      unit: unit,
      unitCost: unitCost,
      categoryUuid: categoryUuid,
      isService: isService,
      product: product,
      sellingProduct: sellingProduct,
      catalogName: name.trim(),
      discountTiers: discountTiers,
    );
  }

  double discountedUnitForQty(double quantity) {
    return CatalogDiscounts.unitPriceAfterDiscounts(
      sellPrice: sellPrice,
      defaultType: item.defaultDiscountType,
      defaultValue: item.defaultDiscountValue,
      quantity: quantity,
      tiers: discountTiers,
    );
  }

  double lineDiscountForQty(double quantity) {
    return CatalogDiscounts.lineDiscountAmount(
      sellPrice: sellPrice,
      defaultType: item.defaultDiscountType,
      defaultValue: item.defaultDiscountValue,
      quantity: quantity,
      tiers: discountTiers,
    );
  }
}
