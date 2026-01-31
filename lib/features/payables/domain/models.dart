import 'package:flowpaisa/core/database/database.dart';

/// Enhanced payable model with pre-fetched related data
/// Includes linked transaction and its category to avoid N+1 query problems
class PayableWithLinkedData {
  final Payable payable;
  final Contact? contact;
  final Transaction? linkedTransaction;
  final Category? linkedCategory;

  PayableWithLinkedData({
    required this.payable,
    this.contact,
    this.linkedTransaction,
    this.linkedCategory,
  });

  @override
  String toString() {
    return 'PayableWithLinkedData(payable: ${payable.uuid}, contact: ${contact?.name}, linkedCategory: ${linkedCategory?.name})';
  }
}

class PayableFilters {
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? contactUuids;
  final double? minAmount;
  final double? maxAmount;
  final bool filterByDueDate;

  PayableFilters({
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

  PayableFilters copyWith({
    String? searchQuery,
    bool clearSearchQuery = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    List<String>? contactUuids,
    double? minAmount,
    bool clearMinAmount = false,
    double? maxAmount,
    bool clearMaxAmount = false,
    bool? filterByDueDate,
  }) {
    return PayableFilters(
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      contactUuids: contactUuids ?? this.contactUuids,
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      filterByDueDate: filterByDueDate ?? this.filterByDueDate,
    );
  }
}