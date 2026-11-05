/// Inputs for allocating discounts / landed costs onto order lines.
class OrderLineCostInput {
  final String id;
  final double quantity;
  final double unitPrice;
  final double lineDiscount;

  const OrderLineCostInput({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    this.lineDiscount = 0,
  });

  double get lineGross => quantity * unitPrice;

  double get afterLineDiscount {
    final net = lineGross - lineDiscount;
    return net < 0 ? 0.0 : net;
  }
}

/// Planned / landed per-unit costs keyed by [OrderLineCostInput.id].
///
/// Allocation order:
/// 1. Subtract line discounts
/// 2. Allocate [orderDiscount] by post-line-discount value weight
/// 3. Allocate [freightAmount] + [dutyAmount] by the same weights
/// 4. `unitCost = lineNet / quantity`
///
/// Recoverable tax must NOT be passed in as freight/duty (see docs).
Map<String, double> computePlannedUnitCosts({
  required List<OrderLineCostInput> lines,
  double orderDiscount = 0,
  double freightAmount = 0,
  double dutyAmount = 0,
}) {
  if (lines.isEmpty) return const {};

  final afterLine = <String, double>{
    for (final l in lines) l.id: l.afterLineDiscount,
  };
  final weightSum = afterLine.values.fold<double>(0, (s, v) => s + v);

  final headerDiscount = orderDiscount < 0 ? 0.0 : orderDiscount;
  final landed = (freightAmount < 0 ? 0.0 : freightAmount) +
      (dutyAmount < 0 ? 0.0 : dutyAmount);

  final result = <String, double>{};
  for (final line in lines) {
    if (line.quantity <= 0) {
      result[line.id] = 0;
      continue;
    }
    final base = afterLine[line.id]!;
    final share = weightSum > 0 ? base / weightSum : (1.0 / lines.length);
    final allocatedDiscount = headerDiscount * share;
    final allocatedLanded = landed * share;
    var lineNet = base - allocatedDiscount + allocatedLanded;
    if (lineNet < 0) lineNet = 0;
    result[line.id] = lineNet / line.quantity;
  }
  return result;
}
