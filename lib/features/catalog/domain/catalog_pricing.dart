/// Catalog sell-price calculation (stored on items; not re-run at order time).
/// See docs/catalogs-selling-products.md.
abstract final class CatalogPricingApproach {
  /// sellPrice = unitCost × (1 + percent/100) + fixedAmount
  /// Scenario: mark up cost, then add packing/delivery fee.
  static const markup = 'MARKUP';

  /// sellPrice = (unitCost + fixedAmount) × (1 + percent/100)
  /// Scenario: fold extras into cost, then mark up everything.
  static const markupOnBase = 'MARKUP_ON_BASE';

  /// sellPrice = (unitCost + fixedAmount) / (1 − percent/100)
  /// Scenario: target margin on sell while recovering a flat fee.
  static const margin = 'MARGIN';

  /// sellPrice = unitCost / (1 − percent/100) + fixedAmount
  /// Scenario: hit margin on cost, then add flat extra profit.
  static const marginThenFixed = 'MARGIN_THEN_FIXED';

  static const all = [markup, markupOnBase, margin, marginThenFixed];

  static bool isMarginBased(String approach) =>
      approach == margin || approach == marginThenFixed;
}

/// Consume mode on selling-product components (same values as production).
abstract final class SellingConsumeMode {
  static const auto = 'AUTO';
  static const batch = 'BATCH';

  static const all = [auto, batch];
}

/// Price mode when importing items from another catalog.
enum CatalogImportPriceMode {
  copy,
  recalculate,
}

/// Conflict handling when the target catalog already has the same link.
enum CatalogImportConflictAction {
  skip,
  replace,
  skipAll,
  replaceAll,
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
      case CatalogPricingApproach.markupOnBase:
        return (cost + fixed) * (1 + p / 100);
      case CatalogPricingApproach.margin:
        return _marginDivide(cost + fixed, p);
      case CatalogPricingApproach.marginThenFixed:
        return _marginDivide(cost, p) + fixed;
      default:
        throw ArgumentError('Unknown pricing approach: $approach');
    }
  }

  static double _marginDivide(double numerator, double percent) {
    if (percent >= 100) {
      throw ArgumentError('Margin percent must be less than 100');
    }
    final denom = 1 - percent / 100;
    if (denom.abs() < 1e-12) {
      throw ArgumentError('Margin percent must be less than 100');
    }
    return numerator / denom;
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
