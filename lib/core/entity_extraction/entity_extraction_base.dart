import 'package:flutter/foundation.dart';
import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';

/// Base contract for text-to-transaction parsers.
abstract class TransactionTextParser {
  Future<ParsedTransactionInput?> parse(
    String text, {
    List<String>? customSymbols,
  });
}

/// Internal Entity Types to replace ML Kit types
enum InternalEntityType {
  dateTime,
  money,
  phone,
  email,
  url,
  unknown
}

/// Internal Entity Annotation to replace ML Kit's version
class InternalEntityAnnotation {
  final int start;
  final int end;
  final String text;
  final List<InternalEntity> entities;

  const InternalEntityAnnotation({
    required this.start,
    required this.end,
    required this.text,
    required this.entities,
  });
}

abstract class InternalEntity {
  InternalEntityType get type;
}

class InternalMoneyEntity extends InternalEntity {
  @override
  InternalEntityType get type => InternalEntityType.money;
  final int integerPart;
  final int fractionPart;
  InternalMoneyEntity({required this.integerPart, required this.fractionPart});
}

class InternalDateTimeEntity extends InternalEntity {
  @override
  InternalEntityType get type => InternalEntityType.dateTime;
  final int timestamp; // milliseconds
  InternalDateTimeEntity({required this.timestamp});
}

class InternalOtherEntity extends InternalEntity {
  final InternalEntityType _type;
  @override
  InternalEntityType get type => _type;
  InternalOtherEntity(this._type);
}

/// Result of entity extraction: raw annotations plus processed data.
class ExtractResult {
  final List<InternalEntityAnnotation> annotations;
  final Map<String, dynamic> data;

  const ExtractResult({required this.annotations, required this.data});
}

/// Shared Regex-based entity extraction. Receipt- and voice-agnostic.
/// Replaces google_mlkit_entity_extraction to maintain SDK 24 compatibility.
abstract class BaseTransactionAiParser implements TransactionTextParser {
  
  Future<void> close() async {
    // No-op now that ML Kit is removed
  }

  /// Runs regex-based extraction and returns both annotations and processed data.
  @protected
  Future<ExtractResult> extractEntitiesWithAnnotations(String text) async {
    final List<InternalEntityAnnotation> annotations = [];
    final Map<String, dynamic> extractedData = {
      'amount': <double>[],
      'date': <DateTime>[],
      'phone': <String>[],
    };

    // 1. Extract Dates
    final dateRegex = RegExp(r'\b(\d{1,2})[-/](\d{1,2})[-/](\d{2,4})\b');
    for (final match in dateRegex.allMatches(text)) {
      try {
        int p1 = int.parse(match.group(1)!);
        int p2 = int.parse(match.group(2)!);
        int p3 = int.parse(match.group(3)!);
        int year = p3 > 100 ? p3 : 2000 + p3;
        int month = p1 > 12 ? p2 : p1;
        int day = p1 > 12 ? p1 : p2;
        
        final date = DateTime(year, month, day);
        if (date.year > 2020 && date.year < 2100) {
          final annotation = InternalEntityAnnotation(
            start: match.start,
            end: match.end,
            text: match.group(0)!,
            entities: [InternalDateTimeEntity(timestamp: date.millisecondsSinceEpoch)],
          );
          annotations.add(annotation);
          (extractedData['date'] as List<DateTime>).add(date);
        }
      } catch (_) {}
    }

    // 2. Extract Money/Amounts
    // Look for currency symbols or keywords followed by numbers
    final moneyRegex = RegExp(r'(?:rs|₹|pkr|\$|€|£|total|amount|net|paid)[\s\.:]*(\d+(?:[.,]\d{2})?)', caseSensitive: false);
    for (final match in moneyRegex.allMatches(text)) {
      final amountStr = match.group(1)!.replaceAll(',', '');
      final val = double.tryParse(amountStr);
      if (val != null && val > 0 && val <= 1000000) {
        final parts = amountStr.split('.');
        final integerPart = int.parse(parts[0]);
        final fractionPart = parts.length > 1 ? int.parse(parts[1].padRight(2, '0').substring(0, 2)) : 0;

        annotations.add(InternalEntityAnnotation(
          start: match.start,
          end: match.end,
          text: match.group(0)!,
          entities: [InternalMoneyEntity(integerPart: integerPart, fractionPart: fractionPart)],
        ));
        (extractedData['amount'] as List<double>).add(val);
      }
    }

    // 3. Extract Phone Numbers (Simple 10+ digit check)
    final phoneRegex = RegExp(r'\b(?:\+?\d{1,3}[- ]?)?\d{10,12}\b');
    for (final match in phoneRegex.allMatches(text)) {
      annotations.add(InternalEntityAnnotation(
        start: match.start,
        end: match.end,
        text: match.group(0)!,
        entities: [InternalOtherEntity(InternalEntityType.phone)],
      ));
      (extractedData['phone'] as List<String>).add(match.group(0)!);
    }

    return ExtractResult(annotations: annotations, data: extractedData);
  }

  /// Extract entities and return only the data map (no annotations).
  @protected
  Future<Map<String, dynamic>> extractEntities(String text) async {
    final result = await extractEntitiesWithAnnotations(text);
    return result.data;
  }
}
