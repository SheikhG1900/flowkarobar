import 'dart:convert';
import 'package:flowpaisa/core/utils/date_formatter.dart';

class TabularRow {
  DateTime date;
  double quantity;
  double unitAmount;
  String description;

  TabularRow({
    required this.date,
    this.quantity = 1.0,
    this.unitAmount = 0.0,
    this.description = '',
  });

  double get totalAmount => quantity * unitAmount;

  List<dynamic> toArray() {
    return [
      AppDateFormatter.formatDate(date, pattern: 'yyyy-MM-dd'),
      quantity,
      unitAmount,
      description,
    ];
  }

  factory TabularRow.fromArray(List<dynamic> array) {
    return TabularRow(
      date: DateTime.tryParse(array[0].toString()) ?? DateTime.now(),
      quantity: double.tryParse(array[1].toString()) ?? 1.0,
      unitAmount: double.tryParse(array[2].toString()) ?? 0.0,
      description: array[3]?.toString() ?? '',
    );
  }
}

class TabularParser {
  static const String jsonStartTag = '\n[';

  static bool isTabular(String? description) {
    if (description == null || description.isEmpty) return false;
    return description.contains(jsonStartTag);
  }

  static (String summary, List<TabularRow> rows) parse(String? description) {
    if (description == null || description.isEmpty) {
      return ('', []);
    }

    if (!isTabular(description)) {
      return (description, []);
    }

    try {
      final index = description.indexOf(jsonStartTag);
      final summary = description.substring(0, index).trim();
      final jsonPart = description.substring(index).trim();
      
      final List<dynamic> decoded = jsonDecode(jsonPart);
      final rows = decoded.map((item) => TabularRow.fromArray(item as List<dynamic>)).toList();
      
      return (summary, rows);
    } catch (e) {
      // Fallback to plain text if parsing fails
      return (description, []);
    }
  }

  static String serialize(String summary, List<TabularRow> rows) {
    if (rows.isEmpty) return summary;
    
    final jsonPart = jsonEncode(rows.map((r) => r.toArray()).toList());
    return '${summary.trim()}\n$jsonPart';
  }
}
