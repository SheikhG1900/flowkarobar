import 'dart:io';
import 'package:flowpaisa/core/database/database.dart';
import 'package:collection/collection.dart';

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionWithDetails &&
          runtimeType == other.runtimeType &&
          transaction == other.transaction &&
          category == other.category &&
          contact == other.contact &&
          account == other.account &&
          linkedPayable == other.linkedPayable &&
          linkedReceivable == other.linkedReceivable;

  @override
  int get hashCode =>
      transaction.hashCode ^
      category.hashCode ^
      contact.hashCode ^
      account.hashCode ^
      linkedPayable.hashCode ^
      linkedReceivable.hashCode;

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
  final List<String>? tagUuids;
  final double? minAmount;
  final double? maxAmount;

  /// Optional transaction status filters:
  /// 'PAID', 'RECEIVED', 'PAYABLE', 'RECEIVABLE', 'AUTO', 'SCHEDULED',
  /// 'PROCESSED' (processedDate set), 'NOT_PROCESSED' (processedDate null)
  final List<String>? statusCodes;

  TransactionFilters({
    this.startDate,
    this.endDate,
    this.type,
    this.categoryUuids,
    this.contactUuids,
    this.accountUuids,
    this.tagUuids,
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
      (tagUuids == null || tagUuids!.isEmpty) &&
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
    List<String>? tagUuids,
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
      tagUuids: tagUuids ?? this.tagUuids,
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      statusCodes: statusCodes ?? this.statusCodes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TransactionFilters) return false;

    final listEquals = const DeepCollectionEquality().equals;

    return other.startDate == startDate &&
        other.endDate == endDate &&
        other.type == type &&
        listEquals(other.categoryUuids, categoryUuids) &&
        listEquals(other.contactUuids, contactUuids) &&
        listEquals(other.accountUuids, accountUuids) &&
        listEquals(other.tagUuids, tagUuids) &&
        other.minAmount == minAmount &&
        other.maxAmount == maxAmount &&
        listEquals(other.statusCodes, statusCodes);
  }

  @override
  int get hashCode {
    final listHash = const DeepCollectionEquality().hash;

    return startDate.hashCode ^
        endDate.hashCode ^
        type.hashCode ^
        listHash(categoryUuids) ^
        listHash(contactUuids) ^
        listHash(accountUuids) ^
        listHash(tagUuids) ^
        minAmount.hashCode ^
        maxAmount.hashCode ^
        listHash(statusCodes);
  }
}

class DisplayDocument {
  final String uuid;
  final String fileName;
  final String originalName;
  final int fileSize;
  final String? mimeType;
  final DateTime createdAt;
  final bool isOrphan;
  final File file;
  final TransactionDocument? dbDoc;
  final bool isMissingPhysicalFile;

  DisplayDocument({
    required this.uuid,
    required this.fileName,
    required this.originalName,
    required this.fileSize,
    this.mimeType,
    required this.createdAt,
    required this.isOrphan,
    required this.file,
    this.dbDoc,
    required this.isMissingPhysicalFile,
  });
}

