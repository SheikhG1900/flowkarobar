/// One line shown in an order delivery / receipt history tile.
class OrderShipmentLineView {
  final String productName;
  final double quantity;
  final String unit;

  const OrderShipmentLineView({
    required this.productName,
    required this.quantity,
    required this.unit,
  });
}

/// One outbound delivery or inbound receipt against an order.
class OrderShipmentView {
  final String uuid;
  final DateTime at;
  final String? notes;
  final List<OrderShipmentLineView> lines;
  final double freightAmount;
  final double dutyAmount;

  const OrderShipmentView({
    required this.uuid,
    required this.at,
    required this.lines,
    this.notes,
    this.freightAmount = 0,
    this.dutyAmount = 0,
  });

  double get totalQuantity =>
      lines.fold<double>(0, (sum, l) => sum + l.quantity);
}
