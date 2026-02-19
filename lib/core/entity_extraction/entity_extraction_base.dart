import 'package:flutter/foundation.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';

/// Base contract for text-to-transaction parsers.
abstract class TransactionTextParser {
  Future<ParsedTransactionInput?> parse(
    String text, {
    List<String>? customSymbols,
  });
}

/// Result of entity extraction: raw annotations plus processed data.
class ExtractResult {
  final List<EntityAnnotation> annotations;
  final Map<String, dynamic> data;

  const ExtractResult({required this.annotations, required this.data});
}

/// Shared ML Kit based entity extraction. Receipt- and voice-agnostic.
abstract class BaseTransactionAiParser implements TransactionTextParser {
  final EntityExtractor _extractor =
      EntityExtractor(language: EntityExtractorLanguage.english);

  Future<void> close() async {
    await _extractor.close();
  }

  /// Extracts a numeric amount from an entity when it's a number type or rawValue parses as number.
  /// Use when MoneyEntity is not found; supports NumberEntity when API provides it, else rawValue.
  static double? _numberFromEntity(dynamic entity) {
    // When google_mlkit_entity_extraction adds EntityType.number and NumberEntity, add:
    // if (entity.type == EntityType.number) return (entity as NumberEntity).value.toDouble();
    final raw = entity.rawValue?.replaceAll(',', '') ?? '';
    final val = double.tryParse(raw);
    if (val != null && val > 0 && val <= 1000000) return val;
    return null;
  }

  /// Runs annotateText once and returns both annotations and processed data.
  @protected
  Future<ExtractResult> extractEntitiesWithAnnotations(String text) async {
    final List<EntityAnnotation> annotations =
        await _extractor.annotateText(text);

    final Map<String, dynamic> extractedData = {
      'amount': <double>[],
      'date': <DateTime>[],
      'phone': <String>[],
    };

    for (final annotation in annotations) {
      bool amountFoundInAnnotation = false;
      bool hasNoiseEntity = false;

      // 1. Identify all entities in this span and handle non-amount ones.
      for (final entity in annotation.entities) {
        switch (entity.type) {
          case EntityType.dateTime:
            final dateEntity = entity as DateTimeEntity;
            (extractedData['date'] as List<DateTime>).add(
                DateTime.fromMillisecondsSinceEpoch(dateEntity.timestamp));
            hasNoiseEntity = true;
            break;
          case EntityType.phone:
            (extractedData['phone'] as List<String>).add(annotation.text);
            hasNoiseEntity = true;
            break;
          case EntityType.address:
          case EntityType.email:
          case EntityType.url:
          case EntityType.trackingNumber:
          case EntityType.isbn:
          case EntityType.iban:
          case EntityType.flightNumber:
          case EntityType.paymentCard:
            hasNoiseEntity = true;
            break;
          case EntityType.money:
            amountFoundInAnnotation = true;
            final moneyEntity = entity as MoneyEntity;
            double val = (moneyEntity.integerPart).toDouble() +
                ((moneyEntity.fractionPart) / 100.0);
            if (val > 0) {
              (extractedData['amount'] as List<double>).add(val);
            }
            break;
          default:
            // Could be unknown or a future type.
            break;
        }
      }

      // 2. Fallback to numeric extraction ONLY if no noise entities were found
      // and no MoneyEntity was already processed for this span.
      if (!hasNoiseEntity && !amountFoundInAnnotation) {
        // Check for plain numbers in annotation text. This helps both receipts and voice.
        final cleanText = annotation.text.replaceAll(',', '');
        final numericMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(cleanText);
        if (numericMatch != null) {
          final val = double.tryParse(numericMatch.group(1)!);
          if (val != null && val > 0 && val <= 1000000) {
            if (!(extractedData['amount'] as List<double>).contains(val)) {
              (extractedData['amount'] as List<double>).add(val);
            }
          }
        }

        // Also check entities that didn't match the switch (e.g. unknown or future types)
        for (final entity in annotation.entities) {
          if (entity.type != EntityType.money &&
              entity.type != EntityType.dateTime &&
              entity.type != EntityType.phone) {
            final numberVal = _numberFromEntity(entity);
            if (numberVal != null) {
              if (!(extractedData['amount'] as List<double>).contains(numberVal)) {
                (extractedData['amount'] as List<double>).add(numberVal);
              }
            }
          }
        }
      }

      if (kDebugMode) {
        for (final entity in annotation.entities) {
          debugPrint(
              'ML Kit Found Entity: ${entity.type} -> ${annotation.text}');
        }
      }
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
