import 'dart:convert';

/// Kind of dashboard widget: summary (no entity) or entity (pinned item).
enum DashboardWidgetKind {
  // Summary widgets
  balance,
  cashFlow,
  receivablesSummary,
  payablesSummary,
  recentTransactions,
  contactsSummary,
  categoriesSummary,
  // Entity widgets
  transaction,
  category,
  contact,
  payable,
  receivable,
}

extension DashboardWidgetKindX on DashboardWidgetKind {
  bool get isEntity =>
      this == DashboardWidgetKind.transaction ||
      this == DashboardWidgetKind.category ||
      this == DashboardWidgetKind.contact ||
      this == DashboardWidgetKind.payable ||
      this == DashboardWidgetKind.receivable;
}

/// Single widget slot on the dashboard.
class DashboardWidgetConfig {
  final DashboardWidgetKind kind;
  final String? transactionUuid;
  final String? categoryUuid;
  final String? contactUuid;
  final String? payableUuid;
  final String? receivableUuid;

  const DashboardWidgetConfig({
    required this.kind,
    this.transactionUuid,
    this.categoryUuid,
    this.contactUuid,
    this.payableUuid,
    this.receivableUuid,
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
      default:
        return null;
    }
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
          receivableUuid == other.receivableUuid;

  @override
  int get hashCode =>
      Object.hash(kind, transactionUuid, categoryUuid, contactUuid,
          payableUuid, receivableUuid);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'kind': kind.name};
    if (transactionUuid != null) map['transactionUuid'] = transactionUuid;
    if (categoryUuid != null) map['categoryUuid'] = categoryUuid;
    if (contactUuid != null) map['contactUuid'] = contactUuid;
    if (payableUuid != null) map['payableUuid'] = payableUuid;
    if (receivableUuid != null) map['receivableUuid'] = receivableUuid;
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
