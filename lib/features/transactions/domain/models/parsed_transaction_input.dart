class AmountCandidate {
  final double value;
  final String? label;

  AmountCandidate({required this.value, this.label});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmountCandidate &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class ParsedTransactionInput {
  final double? amount;
  final String? type; // 'EXPENSE' or 'INCOME'
  final DateTime? date;
  final String? description;
  final String? categoryName;
  final String? contactName;
  final String? paidRelationship; // 'PAID_FOR', 'PAID_BY', 'RECEIVED_FROM', 'WILL_RECEIVE'
  final bool usedFallback;
  final List<AmountCandidate> amountCandidates;
  final List<String> descriptionCandidates;

  ParsedTransactionInput({
    this.amount,
    this.type,
    this.date,
    this.description,
    this.categoryName,
    this.contactName,
    this.paidRelationship,
    this.usedFallback = false,
    this.amountCandidates = const [],
    this.descriptionCandidates = const [],
  });

  bool get isEmpty =>
      amount == null &&
      type == null &&
      description == null &&
      categoryName == null &&
      contactName == null;
}
