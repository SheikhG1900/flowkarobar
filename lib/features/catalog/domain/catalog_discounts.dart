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
}
