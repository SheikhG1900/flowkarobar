import 'package:flowpaisa/core/database/database.dart';

/// Enhanced receivable model with pre-fetched related data
/// Includes linked transaction and its category to avoid N+1 query problems
class ReceivableWithLinkedData {
  final Receivable receivable;
  final Contact? contact;
  final Transaction? linkedTransaction;
  final Category? linkedCategory;

  ReceivableWithLinkedData({
    required this.receivable,
    this.contact,
    this.linkedTransaction,
    this.linkedCategory,
  });

  @override
  String toString() {
    return 'ReceivableWithLinkedData(receivable: ${receivable.uuid}, contact: ${contact?.name}, linkedCategory: ${linkedCategory?.name})';
  }
}

class ReceivableFilters {
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? contactUuids;
  final double? minAmount;
  final double? maxAmount;
  final bool filterByDueDate;

  ReceivableFilters({
    this.searchQuery,
    this.startDate,
    this.endDate,
    this.contactUuids,
    this.minAmount,
    this.maxAmount,
    this.filterByDueDate = false,
  });

  bool get isEmpty =>
      (searchQuery == null || searchQuery!.isEmpty) &&
      startDate == null &&
      endDate == null &&
      (contactUuids == null || contactUuids!.isEmpty) &&
      minAmount == null &&
      maxAmount == null;

  ReceivableFilters copyWith({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? contactUuids,
    double? minAmount,
    double? maxAmount,
    bool? filterByDueDate,
  }) {
    return ReceivableFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      contactUuids: contactUuids ?? this.contactUuids,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      filterByDueDate: filterByDueDate ?? this.filterByDueDate,
    );
  }
}