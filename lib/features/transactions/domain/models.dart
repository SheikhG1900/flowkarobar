import 'package:flowpaisa/core/database/database.dart';

/// Enhanced transaction model with pre-fetched related data
/// Used to avoid N+1 query problems when displaying transaction lists
class TransactionWithDetails {
  final Transaction transaction;
  final Category? category;
  final Contact? contact;
  final Account? account;
  final Payable? linkedPayable;
  final Receivable? linkedReceivable;

  TransactionWithDetails({
    required this.transaction,
    this.category,
    this.contact,
    this.account,
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

/// Enhanced schedule model with pre-fetched related data
class ScheduleWithDetails {
  final TransactionSchedule schedule;
  final Category? category;
  final Contact? contact;
  final Account? account;

  ScheduleWithDetails({
    required this.schedule,
    this.category,
    this.contact,
    this.account,
  });

  @override
  String toString() {
    return 'ScheduleWithDetails(schedule: ${schedule.uuid}, category: ${category?.name}, contact: ${contact?.name}, account: ${account?.name})';
  }
}

class TransactionFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? type; // 'INCOME', 'EXPENSE', or null for All
  final List<String>? categoryUuids;
  final List<String>? contactUuids;
  /// Filter by transaction [accountUuid] (cashbook account).
  final List<String>? accountUuids;
  final double? minAmount;
  final double? maxAmount;

  /// Optional transaction status filters:
  /// 'PAID', 'RECEIVED', 'PAYABLE', 'RECEIVABLE', 'AUTO'
  final List<String>? statusCodes;

  TransactionFilters({
    this.startDate,
    this.endDate,
    this.type,
    this.categoryUuids,
    this.contactUuids,
    this.accountUuids,
    this.minAmount,
    this.maxAmount,
    this.statusCodes,
  });

  bool get isEmpty =>
      startDate == null &&
      endDate == null &&
      type == null &&
      (categoryUuids == null || categoryUuids!.isEmpty) &&
      (contactUuids == null || contactUuids!.isEmpty) &&
      (accountUuids == null || accountUuids!.isEmpty) &&
      minAmount == null &&
      maxAmount == null &&
      (statusCodes == null || statusCodes!.isEmpty);

  TransactionFilters copyWith({
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    String? type,
    bool clearType = false,
    List<String>? categoryUuids,
    List<String>? contactUuids,
    List<String>? accountUuids,
    double? minAmount,
    bool clearMinAmount = false,
    double? maxAmount,
    bool clearMaxAmount = false,
    List<String>? statusCodes,
  }) {
    return TransactionFilters(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      type: clearType ? null : (type ?? this.type),
      categoryUuids: categoryUuids ?? this.categoryUuids,
      contactUuids: contactUuids ?? this.contactUuids,
      accountUuids: accountUuids ?? this.accountUuids,
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      statusCodes: statusCodes ?? this.statusCodes,
    );
  }
}
