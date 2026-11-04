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
}
