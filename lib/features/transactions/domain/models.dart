import 'dart:io';
import 'package:flowpaisa/core/database/database.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;

/// Enhanced transaction model with pre-fetched related data
/// Used to avoid N+1 query problems when displaying transaction lists
class TransactionWithDetails {
  final Transaction transaction;
  final Category? category;
  final Contact? contact;
  final Account? account;
  final Payable? linkedPayable;
  final Receivable? linkedReceivable;
  final List<String> tagUuids;

  TransactionWithDetails({
    required this.transaction,
    this.category,
    this.contact,
    this.account,
    this.linkedPayable,
    this.linkedReceivable,
    this.tagUuids = const <String>[],
  });

  TransactionWithDetails copyWith({
    Transaction? transaction,
    Category? category,
    Contact? contact,
    Account? account,
    Payable? linkedPayable,
    Receivable? linkedReceivable,
    List<String>? tagUuids,
  }) {
    return TransactionWithDetails(
      transaction: transaction ?? this.transaction,
      category: category ?? this.category,
      contact: contact ?? this.contact,
      account: account ?? this.account,
      linkedPayable: linkedPayable ?? this.linkedPayable,
      linkedReceivable: linkedReceivable ?? this.linkedReceivable,
      tagUuids: tagUuids ?? this.tagUuids,
    );
  }

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
          linkedReceivable == other.linkedReceivable &&
          const ListEquality<String>().equals(tagUuids, other.tagUuids);

  @override
  int get hashCode =>
      transaction.hashCode ^
      category.hashCode ^
      contact.hashCode ^
      account.hashCode ^
      linkedPayable.hashCode ^
      linkedReceivable.hashCode ^
      const ListEquality<String>().hash(tagUuids);

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

// ==========================================
// BACKWARD COMPATIBILITY BRIDGE MODELS
// ==========================================

class Category {
  final String uuid;
  final String name;
  final String icon;
  final String color;
  final String type;
  final bool isDefault;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isNotSynced;
  final double? monthlyBudget;
  final double? quarterlyBudget;
  final double? yearlyBudget;
  final double? overallBudget;
  final int addSeq;
  final int budgetSeq;

  Category({
    required this.uuid,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.isNotSynced = false,
    this.monthlyBudget,
    this.quarterlyBudget,
    this.yearlyBudget,
    this.overallBudget,
    this.addSeq = 1,
    this.budgetSeq = 1,
  });

  Category copyWith({
    String? uuid,
    String? name,
    String? icon,
    String? color,
    String? type,
    bool? isDefault,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isNotSynced,
    double? monthlyBudget,
    double? quarterlyBudget,
    double? yearlyBudget,
    double? overallBudget,
    int? addSeq,
    int? budgetSeq,
  }) {
    return Category(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isNotSynced: isNotSynced ?? this.isNotSynced,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      quarterlyBudget: quarterlyBudget ?? this.quarterlyBudget,
      yearlyBudget: yearlyBudget ?? this.yearlyBudget,
      overallBudget: overallBudget ?? this.overallBudget,
      addSeq: addSeq ?? this.addSeq,
      budgetSeq: budgetSeq ?? this.budgetSeq,
    );
  }
}

class Payable {
  final String uuid;
  final String contactUuid;
  final double amount;
  final DateTime date;
  final DateTime dueDate;
  final String status;
  final String? description;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isScheduled => false;
  String? get linkedIncomeUuid => null;
  String? get linkedExpenseUuid => null;
  DateTime? get paidDate => status == 'PAID' ? updatedAt : null;
  final bool autoCreateExpense;

  Payable({
    required this.uuid,
    required this.contactUuid,
    required this.amount,
    required this.date,
    required this.dueDate,
    required this.status,
    this.description,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.autoCreateExpense = false,
  });

  Payable copyWith({
    String? uuid,
    String? contactUuid,
    double? amount,
    DateTime? date,
    dynamic dueDate,
    String? status,
    dynamic description,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic autoCreateExpense,
  }) {
    return Payable(
      uuid: uuid ?? this.uuid,
      contactUuid: contactUuid ?? this.contactUuid,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      dueDate: dueDate is Value<DateTime> ? dueDate.value : (dueDate as DateTime? ?? this.dueDate),
      status: status ?? this.status,
      description: description is Value<String?> ? description.value : (description is Value<String>? (description as Value<String>).value : (description as String? ?? this.description)),
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      autoCreateExpense: autoCreateExpense is Value<bool> ? autoCreateExpense.value : (autoCreateExpense as bool? ?? this.autoCreateExpense),
    );
  }
}

class Receivable {
  final String uuid;
  final String contactUuid;
  final double amount;
  final DateTime date;
  final DateTime dueDate;
  final String status;
  final String? description;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isScheduled => false;
  String? get linkedIncomeUuid => null;
  String? get linkedExpenseUuid => null;
  DateTime? get receivedDate => status == 'PAID' ? updatedAt : null;
  final bool autoCreateIncome;

  Receivable({
    required this.uuid,
    required this.contactUuid,
    required this.amount,
    required this.date,
    required this.dueDate,
    required this.status,
    this.description,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.autoCreateIncome = false,
  });

  Receivable copyWith({
    String? uuid,
    String? contactUuid,
    double? amount,
    DateTime? date,
    dynamic dueDate,
    String? status,
    dynamic description,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic autoCreateIncome,
  }) {
    return Receivable(
      uuid: uuid ?? this.uuid,
      contactUuid: contactUuid ?? this.contactUuid,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      dueDate: dueDate is Value<DateTime> ? dueDate.value : (dueDate as DateTime? ?? this.dueDate),
      status: status ?? this.status,
      description: description is Value<String?> ? description.value : (description is Value<String>? (description as Value<String>).value : (description as String? ?? this.description)),
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      autoCreateIncome: autoCreateIncome is Value<bool> ? autoCreateIncome.value : (autoCreateIncome as bool? ?? this.autoCreateIncome),
    );
  }
}

class TransactionSchedule {
  final String uuid;
  final String? categoryUuid;
  final String? contactUuid;
  final String accountUuid;
  final double amount;
  final String type;
  final String frequency;
  final int interval;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int addSeq;
  final String? scheduleType;

  bool get isPaused => !isActive;
  String? get paidRelationship => null;
  DateTime? get lastGeneratedDate => null;
  int get dueDateOffset => 0;
  DateTime? get dueDate => null;
  String? get selectedDaysOfWeek => null;
  String? get selectedDaysOfMonth => null;

  TransactionSchedule({
    required this.uuid,
    this.categoryUuid,
    this.contactUuid,
    required this.accountUuid,
    required this.amount,
    required this.type,
    required this.frequency,
    this.interval = 1,
    required this.startDate,
    this.endDate,
    this.description,
    this.isActive = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.addSeq = 1,
    this.scheduleType,
  });
}

class TransactionSchedulesCompanion {
  const TransactionSchedulesCompanion();
}

class PayablesCompanion {
  final Value<String> contactUuid;
  final Value<double> amount;
  final Value<String?> description;
  final Value<DateTime> date;
  final Value<DateTime?> dueDate;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> autoCreateExpense;
  final Value<String?> externalLinkId;

  const PayablesCompanion({
    this.contactUuid = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.autoCreateExpense = const Value.absent(),
    this.externalLinkId = const Value.absent(),
  });
}

class ReceivablesCompanion {
  final Value<String> contactUuid;
  final Value<double> amount;
  final Value<String?> description;
  final Value<DateTime> date;
  final Value<DateTime?> dueDate;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> autoCreateIncome;
  final Value<String?> externalLinkId;

  const ReceivablesCompanion({
    this.contactUuid = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.autoCreateIncome = const Value.absent(),
    this.externalLinkId = const Value.absent(),
  });
}

extension TransactionLegacyCompat on Transaction {
  bool get isAutoGenerated => false;
  String? get paidRelationship => null;
  String? get linkedPayableUuid => null;
  String? get linkedReceivableUuid => null;
  String? get linkedGroupId => null;
  bool get isScheduled => false;
  String? get externalLinkId => null;
}

class TransactionDocument {
  final String uuid;
  final String transactionUuid;
  final String fileName;
  final String originalName;
  final int fileSize;
  final String? mimeType;
  final bool isDeleted;
  final DateTime createdAt;

  bool get isNotSynced => false;

  TransactionDocument({
    required this.uuid,
    required this.transactionUuid,
    required this.fileName,
    required this.originalName,
    required this.fileSize,
    this.mimeType,
    this.isDeleted = false,
    required this.createdAt,
  });
}

class Tag {
  final String uuid;
  final String name;
  final String color;
  final bool isDeleted;
  final DateTime createdAt;

  Tag({
    required this.uuid,
    required this.name,
    required this.color,
    this.isDeleted = false,
    required this.createdAt,
  });
}

class CategoryExpense {
  final Category category;
  final double totalAmount;

  CategoryExpense({required this.category, required this.totalAmount});
}

class MonthlyFinancials {
  final DateTime month;
  final double income;
  final double expense;

  MonthlyFinancials({required this.month, required this.income, required this.expense});
}

class ContactSummary {
  final Contact? contact;
  final double balance;
  final double totalPayable;
  final double totalReceivable;
  final String contactUuid;
  final double outstandingAmount;

  ContactSummary({
    this.contact,
    this.balance = 0.0,
    this.totalPayable = 0.0,
    this.totalReceivable = 0.0,
    required this.contactUuid,
    required this.outstandingAmount,
  });
}

class PayableReceivableTrend {
  final DateTime month;
  final double totalPayable;
  final double totalReceivable;
  final double paidPayable;
  final double pendingPayable;
  final double receivedReceivable;
  final double pendingReceivable;
  final double payables;
  final double receivables;

  PayableReceivableTrend({
    required this.month,
    this.totalPayable = 0.0,
    this.totalReceivable = 0.0,
    this.paidPayable = 0.0,
    this.pendingPayable = 0.0,
    this.receivedReceivable = 0.0,
    this.pendingReceivable = 0.0,
    this.payables = 0.0,
    this.receivables = 0.0,
  });
}

class WhatsAppQueueData {
  final String uuid;
  final String recipientPhone;
  final String message;
  final String status;
  final int retryCount;
  final String? error;
  final DateTime createdAt;

  WhatsAppQueueData({
    required this.uuid,
    required this.recipientPhone,
    required this.message,
    required this.status,
    this.retryCount = 0,
    this.error,
    required this.createdAt,
  });
}

class FinancialSummary {
  final double totalIncome;
  final double totalExpense;
  final double totalPayable;
  final double totalReceivable;
  final double netBalance;

  FinancialSummary({
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.totalPayable = 0.0,
    this.totalReceivable = 0.0,
    this.netBalance = 0.0,
  });

  double get income => totalIncome;
  double get expense => totalExpense;
  double get net => totalIncome - totalExpense;
  double get netWorth => netBalance;
}

class StatusDistribution {
  final double pendingPayables;
  final double paidPayables;
  final double cancelledPayables;
  final double pendingReceivables;
  final double receivedReceivables;
  final double cancelledReceivables;
  final Map<String, double> distribution;

  StatusDistribution({
    this.pendingPayables = 0.0,
    this.paidPayables = 0.0,
    this.cancelledPayables = 0.0,
    this.pendingReceivables = 0.0,
    this.receivedReceivables = 0.0,
    this.cancelledReceivables = 0.0,
    this.distribution = const {},
  });
}

class CategoryIncome {
  final Category category;
  final double totalAmount;

  CategoryIncome({required this.category, required this.totalAmount});
}

class CategoryStatistics {
  final double totalAmount;
  final int count;

  CategoryStatistics({this.totalAmount = 0.0, this.count = 0});
}

class SplitShare {
  bool isUser;
  Contact? contact;
  double percentage;
  double amount;
  bool isLocked;

  SplitShare({
    this.isUser = false,
    this.contact,
    this.percentage = 0.0,
    this.amount = 0.0,
    this.isLocked = false,
  });
}

extension ProductCategoryCompat on ProductCategory {
  Category toCategory() {
    return Category(
      uuid: uuid,
      name: name,
      icon: icon ?? '',
      color: color ?? '',
      type: 'EXPENSE',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
