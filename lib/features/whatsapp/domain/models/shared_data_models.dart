/// Base class for all shareable data types
abstract class SharedData {
  final String type;
  final String externalLinkId;
  final String? senderName;
  final String? senderPhone;
  final String? status; // 'PENDING', 'PAID', 'RECEIVED', etc.

  SharedData({
    required this.type,
    required this.externalLinkId,
    this.senderName,
    this.senderPhone,
    this.status,
  });

  Map<String, dynamic> toJson();

  static SharedData fromJson(Map<String, dynamic> json) {
    // Check for both long and short keys for backward compatibility
    final type = (json['t'] ?? json['type']) as String;
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
    String? status,
    required String externalLinkId,
  }) : super(
          type: 'transaction',
          externalLinkId: externalLinkId,
          senderName: senderName,
          senderPhone: senderPhone,
          status: status,
        );

  @override
  Map<String, dynamic> toJson() => {
        't': type,
        'eid': externalLinkId,
        'a': amount,
        'tt': transactionType,
        'd': description,
        'dt': date.toIso8601String(),
        'cn': categoryName,
        'cc': categoryColor,
        'ci': categoryIcon,
        'ctn': contactName,
        'ctp': contactPhone,
        'r': relationship,
        'sn': senderName,
        'sp': senderPhone,
        's': status,
      };

  factory TransactionShareData.fromJson(Map<String, dynamic> json) {
    return TransactionShareData(
      amount: ((json['a'] ?? json['amount']) as num).toDouble(),
      transactionType: (json['tt'] ?? json['transactionType']) as String,
      description: (json['d'] ?? json['description']) as String?,
      date: DateTime.parse((json['dt'] ?? json['date']) as String),
      categoryName: (json['cn'] ?? json['categoryName']) as String?,
      categoryColor: (json['cc'] ?? json['categoryColor']) as String?,
      categoryIcon: (json['ci'] ?? json['categoryIcon']) as String?,
      contactName: (json['ctn'] ?? json['contactName']) as String?,
      contactPhone: (json['ctp'] ?? json['contactPhone']) as String?,
      relationship: (json['r'] ?? json['relationship']) as String?,
      senderName: (json['sn'] ?? json['senderName']) as String?,
      senderPhone: (json['sp'] ?? json['senderPhone']) as String?,
      status: (json['s'] ?? json['status']) as String?,
      externalLinkId: (json['eid'] ?? json['externalLinkId']) as String,
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
    String? status,
    required String externalLinkId,
  }) : super(
          type: 'receivable',
          externalLinkId: externalLinkId,
          senderName: senderName,
          senderPhone: senderPhone,
          status: status,
        );

  @override
  Map<String, dynamic> toJson() => {
        't': type,
        'eid': externalLinkId,
        'a': amount,
        'd': description,
        'dt': date.toIso8601String(),
        'dd': dueDate?.toIso8601String(),
        'ctn': contactName,
        'ctp': contactPhone,
        'sn': senderName,
        'sp': senderPhone,
        's': status,
      };

  factory ReceivableShareData.fromJson(Map<String, dynamic> json) {
    return ReceivableShareData(
      amount: ((json['a'] ?? json['amount']) as num).toDouble(),
      description: (json['d'] ?? json['description']) as String?,
      date: DateTime.parse((json['dt'] ?? json['date']) as String),
      dueDate: (json['dd'] ?? json['dueDate']) != null
          ? DateTime.parse((json['dd'] ?? json['dueDate']) as String)
          : null,
      contactName: (json['ctn'] ?? json['contactName']) as String?,
      contactPhone: (json['ctp'] ?? json['contactPhone']) as String?,
      senderName: (json['sn'] ?? json['senderName']) as String?,
      senderPhone: (json['sp'] ?? json['senderPhone']) as String?,
      status: (json['s'] ?? json['status']) as String?,
      externalLinkId: (json['eid'] ?? json['externalLinkId']) as String,
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
    String? status,
    required String externalLinkId,
  }) : super(
          type: 'payable',
          externalLinkId: externalLinkId,
          senderName: senderName,
          senderPhone: senderPhone,
          status: status,
        );

  @override
  Map<String, dynamic> toJson() => {
        't': type,
        'eid': externalLinkId,
        'a': amount,
        'd': description,
        'dt': date.toIso8601String(),
        'dd': dueDate?.toIso8601String(),
        'ctn': contactName,
        'ctp': contactPhone,
        'sn': senderName,
        'sp': senderPhone,
        's': status,
      };

  factory PayableShareData.fromJson(Map<String, dynamic> json) {
    return PayableShareData(
      amount: ((json['a'] ?? json['amount']) as num).toDouble(),
      description: (json['d'] ?? json['description']) as String?,
      date: DateTime.parse((json['dt'] ?? json['date']) as String),
      dueDate: (json['dd'] ?? json['dueDate']) != null
          ? DateTime.parse((json['dd'] ?? json['dueDate']) as String)
          : null,
      contactName: (json['ctn'] ?? json['contactName']) as String?,
      contactPhone: (json['ctp'] ?? json['contactPhone']) as String?,
      senderName: (json['sn'] ?? json['senderName']) as String?,
      senderPhone: (json['sp'] ?? json['senderPhone']) as String?,
      status: (json['s'] ?? json['status']) as String?,
      externalLinkId: (json['eid'] ?? json['externalLinkId']) as String,
    );
  }
}
