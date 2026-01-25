import 'package:flowpaisa/core/database/database.dart';

/// Enhanced transaction model with pre-fetched related data
/// Used to avoid N+1 query problems when displaying transaction lists
class TransactionWithDetails {
  final Transaction transaction;
  final Category? category;
  final Contact? contact;
  final Payable? linkedPayable;
  final Receivable? linkedReceivable;

  TransactionWithDetails({
    required this.transaction,
    this.category,
    this.contact,
    this.linkedPayable,
    this.linkedReceivable,
  });
  
  /// Returns true if the linked payable/receivable is marked/settled
  bool get isLinkedEntryMarked {
    if (linkedPayable != null) {
      return linkedPayable!.status == 'PAID';
    }
    if (linkedReceivable != null) {
      return linkedReceivable!.status == 'RECEIVED';
    }
    return false;
  }

  @override
  String toString() {
    return 'TransactionWithDetails(transaction: ${transaction.uuid}, category: ${category?.name}, contact: ${contact?.name})';
  }
}

class TransactionFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? type; // 'INCOME', 'EXPENSE', or null for All
  final List<String>? categoryUuids;
  final List<String>? contactUuids;
  final double? minAmount;
  final double? maxAmount;

  TransactionFilters({
    this.startDate,
    this.endDate,
    this.type,
    this.categoryUuids,
    this.contactUuids,
    this.minAmount,
    this.maxAmount,
  });

  bool get isEmpty =>
      startDate == null &&
      endDate == null &&
      type == null &&
      (categoryUuids == null || categoryUuids!.isEmpty) &&
      (contactUuids == null || contactUuids!.isEmpty) &&
      minAmount == null &&
      maxAmount == null;

  TransactionFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    List<String>? categoryUuids,
    List<String>? contactUuids,
    double? minAmount,
    double? maxAmount,
  }) {
    return TransactionFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      categoryUuids: categoryUuids ?? this.categoryUuids,
      contactUuids: contactUuids ?? this.contactUuids,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
    );
  }
}