/// Catalog sell-price calculation (stored on items; not re-run at order time).
/// See docs/catalogs-selling-products.md.
abstract final class CatalogPricingApproach {
  /// sellPrice = unitCost × (1 + percent/100) + fixedAmount
  static const markup = 'MARKUP';

  /// sellPrice = (unitCost + fixedAmount) / (1 − percent/100)
  static const margin = 'MARGIN';

  static const all = [markup, margin];
}

/// Consume mode on selling-product components (same values as production).
abstract final class SellingConsumeMode {
  static const auto = 'AUTO';
  static const batch = 'BATCH';

  static const all = [auto, batch];
}

/// Pure pricing helpers for catalog items.
abstract final class CatalogPricing {
  /// Compute sell price from unit cost + approach/%/fixed.
  /// Throws [ArgumentError] for unknown approach or invalid margin percent.
  static double computeSellPrice({
    required String approach,
    required double unitCost,
    required double percent,
    required double fixedAmount,
  }) {
    final cost = unitCost.isFinite ? unitCost : 0.0;
    final p = percent.isFinite ? percent : 0.0;
    final fixed = fixedAmount.isFinite ? fixedAmount : 0.0;

    switch (approach) {
      case CatalogPricingApproach.markup:
        return cost * (1 + p / 100) + fixed;
      case CatalogPricingApproach.margin:
        if (p >= 100) {
          throw ArgumentError('Margin percent must be less than 100');
        }
        final denom = 1 - p / 100;
        if (denom.abs() < 1e-12) {
          throw ArgumentError('Margin percent must be less than 100');
        }
        return (cost + fixed) / denom;
      default:
        throw ArgumentError('Unknown pricing approach: $approach');
    }
  }

  /// True when catalog item link is valid XOR (exactly one of product / selling).
  static bool isValidLink({
    String? productUuid,
    String? sellingProductUuid,
  }) {
    final hasProduct = productUuid != null && productUuid.trim().isNotEmpty;
    final hasSelling =
        sellingProductUuid != null && sellingProductUuid.trim().isNotEmpty;
    return hasProduct != hasSelling;
  }
}
