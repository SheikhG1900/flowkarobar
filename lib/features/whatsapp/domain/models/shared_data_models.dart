import 'dart:convert';

/// Base class for all shareable data types
abstract class SharedData {
  final String type;
  final String externalLinkId;

  SharedData({
    required this.type,
    required this.externalLinkId,
  });

  Map<String, dynamic> toJson();
  
  static SharedData fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'transaction':
        return TransactionShareData.fromJson(json);
      case 'receivable':
        return ReceivableShareData.fromJson(json);
      case 'payable':
        return PayableShareData.fromJson(json);
      default:
        throw Exception('Unknown shared data type: $type');
    }
  }
}

/// Shareable transaction data
class TransactionShareData extends SharedData {
  final double amount;
  final String transactionType; // 'EXPENSE' or 'INCOME'
  final String? description;
  final DateTime date;
  final String? categoryName;
  final String? contactName;
  final String? contactPhone;
  final String? sharedBy;

  TransactionShareData({
    required this.amount,
    required this.transactionType,
    this.description,
    required this.date,
    this.categoryName,
    this.contactName,
    this.contactPhone,
    this.sharedBy,
    required String externalLinkId,
  }) : super(type: 'transaction', externalLinkId: externalLinkId);

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'externalLinkId': externalLinkId,
        'amount': amount,
        'transactionType': transactionType,
        'description': description,
        'date': date.toIso8601String(),
        'categoryName': categoryName,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'sharedBy': sharedBy,
      };

  factory TransactionShareData.fromJson(Map<String, dynamic> json) {
    return TransactionShareData(
      amount: (json['amount'] as num).toDouble(),
      transactionType: json['transactionType'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      categoryName: json['categoryName'] as String?,
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
      sharedBy: json['sharedBy'] as String?,
      externalLinkId: json['externalLinkId'] as String,
    );
  }
}

/// Shareable receivable data
class ReceivableShareData extends SharedData {
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime? dueDate;
  final String? contactName;
  final String? contactPhone;
  final String? sharedBy;

  ReceivableShareData({
    required this.amount,
    this.description,
    required this.date,
    this.dueDate,
    this.contactName,
    this.contactPhone,
    this.sharedBy,
    required String externalLinkId,
  }) : super(type: 'receivable', externalLinkId: externalLinkId);

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'externalLinkId': externalLinkId,
        'amount': amount,
        'description': description,
        'date': date.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'contactName': contactName,
        'contactPhone': contactPhone,
        'sharedBy': sharedBy,
      };

  factory ReceivableShareData.fromJson(Map<String, dynamic> json) {
    return ReceivableShareData(
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
      sharedBy: json['sharedBy'] as String?,
      externalLinkId: json['externalLinkId'] as String,
    );
  }
}

/// Shareable payable data
class PayableShareData extends SharedData {
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime? dueDate;
  final String? contactName;
  final String? contactPhone;
  final String? sharedBy;

  PayableShareData({
    required this.amount,
    this.description,
    required this.date,
    this.dueDate,
    this.contactName,
    this.contactPhone,
    this.sharedBy,
    required String externalLinkId,
  }) : super(type: 'payable', externalLinkId: externalLinkId);

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'externalLinkId': externalLinkId,
        'amount': amount,
        'description': description,
        'date': date.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'contactName': contactName,
        'contactPhone': contactPhone,
        'sharedBy': sharedBy,
      };

  factory PayableShareData.fromJson(Map<String, dynamic> json) {
    return PayableShareData(
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
      sharedBy: json['sharedBy'] as String?,
      externalLinkId: json['externalLinkId'] as String,
    );
  }
}
