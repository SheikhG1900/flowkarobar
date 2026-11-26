/// Cost-weight allocation of a bundle/package sell price onto components.
///
/// [individualUnitCost] is only a **weight** (e.g. product.purchasePrice), not
/// authoritative COGS. Real COGS is stamped on delivery lines at dispatch.
class BundleComponentAllocation {
  final String productUuid;
  final String productName;
  final String unit;
  final bool isService;

  /// Qty of this product in one package (BOM).
  final double bundleComponentQty;

  /// Weight unit cost used for allocation.
  final double individualUnitCost;

  /// Allocated list unit sell price for this product.
  final double unitPrice;

  /// Allocated discounted unit sell price (null if no discount on package).
  final double? discountedUnitPrice;

  /// Absolute discount for the expanded line (all packages).
  final double discountAmount;

  /// Expanded physical qty = [bundleComponentQty] × packageQty.
  final double quantity;

  /// Consume hint copied from BOM (AUTO | BATCH).
  final String consumeMode;
  final String? batchNumber;

  const BundleComponentAllocation({
    required this.productUuid,
    required this.productName,
    required this.unit,
    required this.isService,
    required this.bundleComponentQty,
    required this.individualUnitCost,
    required this.unitPrice,
    required this.discountedUnitPrice,
    required this.discountAmount,
    required this.quantity,
    this.consumeMode = 'AUTO',
    this.batchNumber,
  });
}

class BundleComponentInput {
  final String productUuid;
  final String productName;
  final String unit;
  final bool isService;
  final double bundleComponentQty;
  final double individualUnitCost;
  final String consumeMode;
  final String? batchNumber;

  const BundleComponentInput({
    required this.productUuid,
    required this.productName,
    required this.unit,
    required this.isService,
    required this.bundleComponentQty,
    required this.individualUnitCost,
    this.consumeMode = 'AUTO',
    this.batchNumber,
  });
}

/// Allocates package list/discounted prices onto components.
///
/// Formula: `allocatedUnitPrice = (bundleUnitPrice / bundleUnitCost) * individualUnitCost`
/// where [bundleUnitCost] = Σ(individualUnitCost × bundleComponentQty).
///
/// Last component absorbs rounding so extended list prices sum to
/// `bundleUnitPrice * packageQty` (and discounted similarly).
List<BundleComponentAllocation> allocateBundlePrices({
  required List<BundleComponentInput> components,
  required double packageQty,
  required double bundleUnitPrice,
  double? bundleDiscountedUnitPrice,
  double bundleDiscountAmount = 0,
}) {
  if (components.isEmpty || packageQty <= 0) return const [];

  final weights = <double>[];
  var bundleUnitCost = 0.0;
  for (final c in components) {
    final qty = c.bundleComponentQty;
    final cost = c.individualUnitCost.isFinite && c.individualUnitCost > 0
        ? c.individualUnitCost
        : 0.0;
    final w = cost * qty;
    weights.add(w);
    bundleUnitCost += w;
  }

  // Equal weights when all costs are zero.
  final useEqual = bundleUnitCost <= 1e-12;
  if (useEqual) {
    bundleUnitCost = components.length.toDouble();
    for (var i = 0; i < weights.length; i++) {
      weights[i] = 1.0;
    }
  }

  final discounted = bundleDiscountedUnitPrice;
  final hasDiscount = discounted != null &&
      (bundleDiscountAmount > 1e-12 ||
          (discounted - bundleUnitPrice).abs() > 1e-12);

  final targetListExtended = bundleUnitPrice * packageQty;
  final targetDiscExtended = hasDiscount
      ? (discounted * packageQty)
      : targetListExtended;

  final result = <BundleComponentAllocation>[];
  var allocatedList = 0.0;
  var allocatedDisc = 0.0;

  for (var i = 0; i < components.length; i++) {
    final c = components[i];
    final isLast = i == components.length - 1;
    final physicalQty = c.bundleComponentQty * packageQty;
    if (physicalQty <= 1e-12) {
      result.add(
        BundleComponentAllocation(
          productUuid: c.productUuid,
          productName: c.productName,
          unit: c.unit,
          isService: c.isService,
          bundleComponentQty: c.bundleComponentQty,
          individualUnitCost: c.individualUnitCost,
          unitPrice: 0,
          discountedUnitPrice: hasDiscount ? 0 : null,
          discountAmount: 0,
          quantity: 0,
          consumeMode: c.consumeMode,
          batchNumber: c.batchNumber,
        ),
      );
      continue;
    }

    final share = weights[i] / bundleUnitCost;
    double listExtended;
    double discExtended;
    if (isLast) {
      listExtended = targetListExtended - allocatedList;
      discExtended = targetDiscExtended - allocatedDisc;
    } else {
      listExtended = targetListExtended * share;
      discExtended = targetDiscExtended * share;
      allocatedList += listExtended;
      allocatedDisc += discExtended;
    }

    final unitPrice = listExtended / physicalQty;
    final discUnit = hasDiscount ? discExtended / physicalQty : null;
    final lineDiscount = hasDiscount
        ? (listExtended - discExtended).clamp(0.0, double.infinity)
        : 0.0;

    result.add(
      BundleComponentAllocation(
        productUuid: c.productUuid,
        productName: c.productName,
        unit: c.unit,
        isService: c.isService,
        bundleComponentQty: c.bundleComponentQty,
        individualUnitCost: c.individualUnitCost,
        unitPrice: unitPrice,
        discountedUnitPrice: discUnit,
        discountAmount: lineDiscount,
        quantity: physicalQty,
        consumeMode: c.consumeMode,
        batchNumber: c.batchNumber,
      ),
    );
  }

  return result;
}

/// Package unit cost used as allocation denominator.
double bundleUnitCostOf(List<BundleComponentInput> components) {
  var total = 0.0;
  var anyPositive = false;
  for (final c in components) {
    final cost = c.individualUnitCost.isFinite && c.individualUnitCost > 0
        ? c.individualUnitCost
        : 0.0;
    if (cost > 0) anyPositive = true;
    total += cost * c.bundleComponentQty;
  }
  if (!anyPositive && components.isNotEmpty) {
    return components.length.toDouble();
  }
  return total;
}
