import 'dart:convert';
import 'package:collection/collection.dart';

/// Kind of dashboard widget: summary (no entity) or entity (pinned item).
enum DashboardWidgetKind {
  // Summary widgets
  balance,
  cashFlow,
  netCredit,
  receivablesSummary,
  payablesSummary,
  recentTransactions,
  contactsSummary,
  categoriesSummary,
  netWorth,
  quickActions,
  incomeSummary,
  expenseSummary,
  financialSummary,
  // Entity widgets
  transaction,
  category,
  contact,
  payable,
  receivable,
  account,
}

extension DashboardWidgetKindX on DashboardWidgetKind {
  bool get isEntity =>
      this == DashboardWidgetKind.transaction ||
      this == DashboardWidgetKind.category ||
      this == DashboardWidgetKind.contact ||
      this == DashboardWidgetKind.payable ||
      this == DashboardWidgetKind.receivable ||
      this == DashboardWidgetKind.account;
}

/// Single widget slot on the dashboard.
class DashboardWidgetConfig {
  final DashboardWidgetKind kind;
  final String? transactionUuid;
  final String? categoryUuid;
  final String? contactUuid;
  final String? payableUuid;
  final String? receivableUuid;
  final String? accountUuid;
  final List<String>? quickActionCodes;

  const DashboardWidgetConfig({
    required this.kind,
    this.transactionUuid,
    this.categoryUuid,
    this.contactUuid,
    this.payableUuid,
    this.receivableUuid,
    this.accountUuid,
    this.quickActionCodes,
  });

  String? get entityUuid {
    switch (kind) {
      case DashboardWidgetKind.transaction:
        return transactionUuid;
      case DashboardWidgetKind.category:
        return categoryUuid;
      case DashboardWidgetKind.contact:
        return contactUuid;
      case DashboardWidgetKind.payable:
        return payableUuid;
      case DashboardWidgetKind.receivable:
        return receivableUuid;
      case DashboardWidgetKind.account:
        return accountUuid;
      default:
        return null;
    }
  }

  DashboardWidgetConfig copyWith({
    DashboardWidgetKind? kind,
    String? transactionUuid,
    String? categoryUuid,
    String? contactUuid,
    String? payableUuid,
    String? receivableUuid,
    String? accountUuid,
    List<String>? quickActionCodes,
  }) {
    return DashboardWidgetConfig(
      kind: kind ?? this.kind,
      transactionUuid: transactionUuid ?? this.transactionUuid,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      contactUuid: contactUuid ?? this.contactUuid,
      payableUuid: payableUuid ?? this.payableUuid,
      receivableUuid: receivableUuid ?? this.receivableUuid,
      accountUuid: accountUuid ?? this.accountUuid,
      quickActionCodes: quickActionCodes ?? this.quickActionCodes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardWidgetConfig &&
          kind == other.kind &&
          transactionUuid == other.transactionUuid &&
          categoryUuid == other.categoryUuid &&
          contactUuid == other.contactUuid &&
          payableUuid == other.payableUuid &&
          receivableUuid == other.receivableUuid &&
          accountUuid == other.accountUuid &&
          const ListEquality().equals(quickActionCodes, other.quickActionCodes);

  @override
  int get hashCode =>
      Object.hash(
          kind,
          transactionUuid,
          categoryUuid,
          contactUuid,
          payableUuid,
          receivableUuid,
          accountUuid,
          Object.hashAll(quickActionCodes ?? []));

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'kind': kind.name};
    if (transactionUuid != null) map['transactionUuid'] = transactionUuid;
    if (categoryUuid != null) map['categoryUuid'] = categoryUuid;
    if (contactUuid != null) map['contactUuid'] = contactUuid;
    if (payableUuid != null) map['payableUuid'] = payableUuid;
    if (receivableUuid != null) map['receivableUuid'] = receivableUuid;
    if (accountUuid != null) map['accountUuid'] = accountUuid;
    if (quickActionCodes != null) map['quickActionCodes'] = quickActionCodes;
    return map;
  }

  factory DashboardWidgetConfig.fromJson(Map<String, dynamic> json) {
    final kindStr = json['kind'] as String?;
    DashboardWidgetKind kind;
    try {
      kind = DashboardWidgetKind.values.firstWhere(
        (e) => e.name == kindStr,
        orElse: () => DashboardWidgetKind.balance,
      );
    } catch (_) {
      kind = DashboardWidgetKind.balance;
    }
    return DashboardWidgetConfig(
      kind: kind,
      transactionUuid: json['transactionUuid'] as String?,
      categoryUuid: json['categoryUuid'] as String?,
      contactUuid: json['contactUuid'] as String?,
      payableUuid: json['payableUuid'] as String?,
      receivableUuid: json['receivableUuid'] as String?,
      accountUuid: (json['accountUuid'] as String?)?.trim(),
      quickActionCodes: (json['quickActionCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  static List<DashboardWidgetConfig> listFromJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final list = json.decode(jsonString) as List<dynamic>?;
      if (list == null) return [];
      return list
          .map((e) => DashboardWidgetConfig.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String listToJson(List<DashboardWidgetConfig> configs) {
    return json.encode(configs.map((e) => e.toJson()).toList());
  }
}
