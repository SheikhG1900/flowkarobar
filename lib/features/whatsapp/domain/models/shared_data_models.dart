/// Base class for all shareable data types
abstract class SharedData {
  final String type;
  final String externalLinkId;
  final String? senderName;
  final String? senderPhone;

  SharedData({
    required this.type,
    required this.externalLinkId,
    this.senderName,
    this.senderPhone,
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
  final String? categoryColor;
  final String? categoryIcon;
  final String? contactName;
  final String? contactPhone;
  final String? relationship; // 'PAID_FOR', 'PAID_BY', etc.

  TransactionShareData({
    required this.amount,
    required this.transactionType,
    this.description,
    required this.date,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    this.contactName,
    this.contactPhone,
    this.relationship,
    String? senderName,
    String? senderPhone,
    required String externalLinkId,
  }) : super(
          type: 'transaction',
          externalLinkId: externalLinkId,
          senderName: senderName,
          senderPhone: senderPhone,
        );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'externalLinkId': externalLinkId,
        'amount': amount,
        'transactionType': transactionType,
        'description': description,
        'date': date.toIso8601String(),
        'categoryName': categoryName,
        'categoryColor': categoryColor,
        'categoryIcon': categoryIcon,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'relationship': relationship,
        'senderName': senderName,
        'senderPhone': senderPhone,
      };

  factory TransactionShareData.fromJson(Map<String, dynamic> json) {
    return TransactionShareData(
      amount: (json['amount'] as num).toDouble(),
      transactionType: json['transactionType'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      categoryName: json['categoryName'] as String?,
      categoryColor: json['categoryColor'] as String?,
      categoryIcon: json['categoryIcon'] as String?,
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
      relationship: json['relationship'] as String?,
      senderName: json['senderName'] as String?,
      senderPhone: json['senderPhone'] as String?,
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

  ReceivableShareData({
    required this.amount,
    this.description,
    required this.date,
    this.dueDate,
    this.contactName,
    this.contactPhone,
    String? senderName,
    String? senderPhone,
    required String externalLinkId,
  }) : super(
          type: 'receivable',
          externalLinkId: externalLinkId,
          senderName: senderName,
          senderPhone: senderPhone,
        );

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
        'senderName': senderName,
        'senderPhone': senderPhone,
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
      senderName: json['senderName'] as String?,
      senderPhone: json['senderPhone'] as String?,
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

  PayableShareData({
    required this.amount,
    this.description,
    required this.date,
    this.dueDate,
    this.contactName,
    this.contactPhone,
    String? senderName,
    String? senderPhone,
    required String externalLinkId,
  }) : super(
          type: 'payable',
          externalLinkId: externalLinkId,
          senderName: senderName,
          senderPhone: senderPhone,
        );

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
        'senderName': senderName,
        'senderPhone': senderPhone,
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
      senderName: json['senderName'] as String?,
      senderPhone: json['senderPhone'] as String?,
      externalLinkId: json['externalLinkId'] as String,
    );
  }
}
