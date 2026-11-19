/// Discount types for catalog item default + qty tiers.
/// Applied at order/quotation time on top of stored [sellPrice].
abstract final class CatalogDiscountType {
  static const percent = 'PERCENT';
  static const fixed = 'FIXED';

  static const all = [percent, fixed];

  static bool isValid(String? type) =>
      type != null && all.contains(type);
}

/// Pure helpers for catalog discounts (not baked into sellPrice).
abstract final class CatalogDiscounts {
  /// Apply one discount to a unit sell price.
  static double applyDiscount({
    required double sellPrice,
    required String type,
    required double value,
  }) {
    final price = sellPrice.isFinite ? sellPrice : 0.0;
    final v = value.isFinite ? value : 0.0;
    if (v <= 0) return price;
    switch (type) {
      case CatalogDiscountType.percent:
        if (v >= 100) return 0;
        return price * (1 - v / 100);
      case CatalogDiscountType.fixed:
        final next = price - v;
        return next < 0 ? 0 : next;
      default:
        throw ArgumentError('Unknown discount type: $type');
    }
  }

  /// Highest [minQuantity] tier that is ≤ [quantity], or null.
  static T? bestTier<T>({
    required double quantity,
    required List<T> tiers,
    required double Function(T) minQuantityOf,
  }) {
    T? best;
    var bestMin = double.negativeInfinity;
    for (final t in tiers) {
      final minQ = minQuantityOf(t);
      if (minQ <= quantity && minQ >= bestMin) {
        best = t;
        bestMin = minQ;
      }
    }
    return best;
  }

  /// Unit price after default + optional qty tier.
  /// When a tier matches, it **replaces** the default (no stacking).
  static double unitPriceAfterDiscounts({
    required double sellPrice,
    String? defaultType,
    double defaultValue = 0,
    required double quantity,
    required List<({double minQuantity, String type, double value})> tiers,
  }) {
    final tier = bestTier(
      quantity: quantity,
      tiers: tiers,
      minQuantityOf: (t) => t.minQuantity,
    );
    if (tier != null) {
      return applyDiscount(
        sellPrice: sellPrice,
        type: tier.type,
        value: tier.value,
      );
    }
    if (CatalogDiscountType.isValid(defaultType) && defaultValue > 0) {
      return applyDiscount(
        sellPrice: sellPrice,
        type: defaultType!,
        value: defaultValue,
      );
    }
    return sellPrice.isFinite ? sellPrice : 0.0;
  }

  /// Absolute line discount so list [sellPrice] × qty stays on the unit field.
  static double lineDiscountAmount({
    required double sellPrice,
    String? defaultType,
    double defaultValue = 0,
    required double quantity,
    required List<({double minQuantity, String type, double value})> tiers,
  }) {
    final qty = quantity.isFinite && quantity > 0 ? quantity : 0.0;
    final unitAfter = unitPriceAfterDiscounts(
      sellPrice: sellPrice,
      defaultType: defaultType,
      defaultValue: defaultValue,
      quantity: qty,
      tiers: tiers,
    );
    return SaleLinePricing.lineDiscountFixed(
      listUnitPrice: sellPrice,
      discountedUnitPrice: unitAfter,
      quantity: qty,
    );
  }
}

/// Sale line math from list unit price vs discounted unit price.
abstract final class SaleLinePricing {
  static double unitDiscountFixed({
    required double listUnitPrice,
    required double discountedUnitPrice,
  }) {
    final list = listUnitPrice.isFinite ? listUnitPrice : 0.0;
    final disc = discountedUnitPrice.isFinite ? discountedUnitPrice : 0.0;
    final diff = list - disc;
    return diff < 0 ? 0 : diff;
  }

  static double unitDiscountPercent({
    required double listUnitPrice,
    required double discountedUnitPrice,
  }) {
    final list = listUnitPrice.isFinite ? listUnitPrice : 0.0;
    if (list <= 1e-12) return 0;
    return (unitDiscountFixed(
              listUnitPrice: list,
              discountedUnitPrice: discountedUnitPrice,
            ) /
            list) *
        100;
  }

  static double lineDiscountFixed({
    required double listUnitPrice,
    required double discountedUnitPrice,
    required double quantity,
  }) {
    final qty = quantity.isFinite && quantity > 0 ? quantity : 0.0;
    return unitDiscountFixed(
          listUnitPrice: listUnitPrice,
          discountedUnitPrice: discountedUnitPrice,
        ) *
        qty;
  }

  /// Overall line discount % equals unit discount % (uniform per-unit).
  static double lineDiscountPercent({
    required double listUnitPrice,
    required double discountedUnitPrice,
  }) =>
      unitDiscountPercent(
        listUnitPrice: listUnitPrice,
        discountedUnitPrice: discountedUnitPrice,
      );

  static double lineGross({
    required double listUnitPrice,
    required double quantity,
  }) {
    final qty = quantity.isFinite && quantity > 0 ? quantity : 0.0;
    final list = listUnitPrice.isFinite ? listUnitPrice : 0.0;
    return list * qty;
  }

  static double lineTotal({
    required double discountedUnitPrice,
    required double quantity,
  }) {
    final qty = quantity.isFinite && quantity > 0 ? quantity : 0.0;
    final disc = discountedUnitPrice.isFinite ? discountedUnitPrice : 0.0;
    return disc * qty;
  }
}
