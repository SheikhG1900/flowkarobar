/// Production order lifecycle.
abstract final class ProductionStatus {
  static const draft = 'DRAFT';
  static const completed = 'COMPLETED';
  static const cancelled = 'CANCELLED';

  static const all = [draft, completed, cancelled];
}

/// How an input line consumes stock.
abstract final class ProductionConsumeMode {
  /// FEFO across all open lots of the product.
  static const auto = 'AUTO';

  /// FEFO only within the chosen virtual [batchNumber] group.
  static const batch = 'BATCH';

  static const all = [auto, batch];
}
