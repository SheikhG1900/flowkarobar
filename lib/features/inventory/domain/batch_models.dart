import 'package:flowpaisa/core/database/database.dart';

/// Manual lot reason when [ProductBatche.isManual] is true.
abstract final class ManualBatchType {
  static const opening = 'OPENING';
  static const production = 'PRODUCTION';
  static const adjustment = 'ADJUSTMENT';

  static const all = [opening, production, adjustment];
}

extension ProductBatchQtyX on ProductBatche {
  double get remainingQuantity {
    final rem = totalQuantity - consumedQuantity;
    return rem < 0 ? 0.0 : rem;
  }

  bool get isOpen => remainingQuantity > 1e-9;
}

/// Purchase-order / receipt context for a received lot.
class LotPurchaseContext {
  final String orderUuid;
  final String orderNumber;
  final DateTime orderDate;
  final String? supplierName;
  final DateTime? receivedAt;

  const LotPurchaseContext({
    required this.orderUuid,
    required this.orderNumber,
    required this.orderDate,
    this.supplierName,
    this.receivedAt,
  });
}
