import 'package:flutter/foundation.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';
import 'package:flowpaisa/core/extensions/list_extensions.dart';
import 'package:flowpaisa/core/extensions/string_extensions.dart';

abstract class TransactionTextParser {
  Future<ParsedTransactionInput?> parse(String text,
      {required bool isReceipt, List<String>? customSymbols});
}

class TransactionAiParser implements TransactionTextParser {
  // Use English as the primary language for entity extraction
  final EntityExtractor _extractor =
      EntityExtractor(language: EntityExtractorLanguage.english);

  static final List<String> _willReceiveKeywords = [
    'will receive',
    'will take',
    'will get',
    ...('lene'.makeCombinations(['ha', 'hain', 'he'], ['', ' '])),
    ...(['milay', 'mili', 'milen', 'milan', 'mile', 'mila']
        .makeCombinations(['ga', 'gi', 'gay', 'ge'], ['', ' '])),
    ...(['loon', 'lun', 'loo', 'lu', 'le', 'lain']
        .makeCombinations(['ga', 'gi', 'gay', 'ge'], ['', ' ']))
  ];

  TransactionAiParser();

  Future<void> close() async {
    await _extractor.close();
  }

  @override
  Future<ParsedTransactionInput?> parse(String text,
      {required bool isReceipt, List<String>? customSymbols}) async {
    try {
      if (kDebugMode) {
        debugPrint('AI Parser (ML Kit): Starting extraction for text: $text');
        debugPrint('AI Parser (ML Kit): Raw Input Text:\n$text');
      }

      final List<EntityAnnotation> annotations =
          await _extractor.annotateText(text);

      final Map<String, dynamic> extractedData = {
        'amount': <double>[],
        'date': <DateTime>[],
        'phone': <String>[],
      };

      for (final annotation in annotations) {
        bool amountFoundInAnnotation = false;
        for (final entity in annotation.entities) {
          if (entity.type == EntityType.money) {
            amountFoundInAnnotation = true;
            final moneyEntity = entity as MoneyEntity;
            double val = (moneyEntity.integerPart).toDouble() +
                ((moneyEntity.fractionPart) / 100.0);
            if (val > 0) {
              (extractedData['amount'] as List<double>).add(val);
            }
          }
        }

        // Check for plain numbers if no money entity was found, or if it's a voice command
        // ML Kit often misses 'money' type for plain numbers in natural speech
        if (!amountFoundInAnnotation || !isReceipt) {
          // Handle commas in numbers (e.g., "3,170" -> "3170")
          final cleanText = annotation.text.replaceAll(',', '');
          // Use a more precise regex that doesn't truncate long numbers
          final numericMatch =
              RegExp(r'(\d+(?:\.\d+)?)').firstMatch(cleanText);
          if (numericMatch != null) {
            final val = double.tryParse(numericMatch.group(1)!);
            // Ignore numbers > 1,000,000 as garbage/invoice IDs
            if (val != null && val > 0 && val <= 1000000) {
              if (!amountFoundInAnnotation) {
                (extractedData['amount'] as List<double>).add(val);
              } else if (!extractedData['amount'].contains(val)) {
                // Add as candidate if not already there
                (extractedData['amount'] as List<double>).add(val);
              }
            }
          }
        }

        for (final entity in annotation.entities) {
          if (kDebugMode) {
            debugPrint(
                'ML Kit Found Entity: ${entity.type} -> ${annotation.text}');
          }

          switch (entity.type) {
            case EntityType.money:
              // Already handled above
              break;
            case EntityType.dateTime:
              final dateEntity = entity as DateTimeEntity;
              (extractedData['date'] as List<DateTime>).add(
                  DateTime.fromMillisecondsSinceEpoch(dateEntity.timestamp));
              break;
            case EntityType.phone:
              (extractedData['phone'] as List<String>).add(annotation.text);
              break;
            default:
              break;
          }
        }
      }

      final result = _mapEntitiesToInput(extractedData, text,
          isReceipt: isReceipt, customSymbols: customSymbols);

      if (kDebugMode) {
        debugPrint(
            'AI Parser: Final Result: amount=${result.amount}, type=${result.type}, category=${result.categoryName}, contact=${result.contactName}, relationship=${result.paidRelationship}');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AI Parser Error: $e');
      }
      return null;
    }
  }

  ParsedTransactionInput _mapEntitiesToInput(
      Map<String, dynamic> extracted, String originalText,
      {required bool isReceipt, List<String>? customSymbols}) {
    double? amount;
    String? type;
    String? category;
    String? contact;
    String? relationship;

    final List<double> mlKitAmounts = extracted['amount'] as List<double>;
    final List<DateTime> mlKitDates = extracted['date'] as List<DateTime>;
    List<double> amountCandidates = List.from(mlKitAmounts);

    final lowerText = originalText.toLowerCase();
    final tokens = lowerText.split(RegExp(r'[\s,.]+'));
    final categoryKeywords = [
      'salary',
      'bonus',
      'rent',
      'fuel',
      'dinner',
      'lunch',
      'breakfast',
      'travel',
      'gift',
      'profit',
      'shopping',
      'bills'
    ];

    // 1. Amount Refinement (Combine ML Kit with Regex for robustness)
    final symbols = [
      'rs',
      '₹',
      'pkr',
      r'\$',
      '€',
      '£',
      '¥',
      'total',
      'amount',
      'net',
      'sum',
      'due',
      'paid'
    ];
    if (customSymbols != null) {
      for (var s in customSymbols) {
        if (!symbols.contains(s.toLowerCase())) {
          symbols.add(RegExp.escape(s.toLowerCase()));
        }
      }
    }

    final symbolsPattern = symbols.join('|');
    // Improved regex:
    // For receipts: require a symbol/keyword prefix
    // For voice: make symbol/keyword prefix optional
    final amountRegex = isReceipt
        ? RegExp(
            '(?:$symbolsPattern)[\\s\\(\\)\\.:\\-]*(\\d{1,3}(?:,\\d{3})*(?:\\.\\d+)?|\\d+(?:\\.\\d+)?)',
            caseSensitive: false)
        : RegExp(
            '(?:(?:$symbolsPattern)[\\s\\(\\)\\.:\\-]*|\\b)(\\d+(?:\\.\\d+)?)',
            caseSensitive: false);
    final matches = amountRegex.allMatches(originalText);

    for (var m in matches) {
      final val = double.tryParse(m.group(1)!.replaceAll(',', ''));
      // Ignore numbers > 1,000,000 as garbage/invoice IDs
      if (val != null && val <= 1000000 && !amountCandidates.contains(val)) {
        amountCandidates.add(val);
      }
    }

    if (amountCandidates.isNotEmpty) {
      if (isReceipt) {
        // Priority logic for receipts:
        // 1. Prefer numbers <= 100,000 (likely real transactions)
        // 2. If all numbers are > 100,000, take the largest one under 1,000,000
        final reasonableAmounts =
            amountCandidates.where((a) => a <= 100000).toList();
        if (reasonableAmounts.isNotEmpty) {
          reasonableAmounts.sort((a, b) => b.compareTo(a));
          amount = reasonableAmounts.first;
        } else {
          amountCandidates.sort((a, b) => b.compareTo(a));
          amount = amountCandidates.first;
        }
      } else {
        amount = amountCandidates.first;
      }
    }

    // 2. Type Detection (Existing logic)
    if (lowerText.containsAny(['for me', 'mere liye']) ||
        (lowerText.contains('mere') &&
            categoryKeywords.any((kw) => lowerText.contains(kw)))) {
      type = "EXPENSE";
    } else if (tokens.containsAny([
          'receive',
          'income',
          'salary',
          'got',
          'mila',
          'mile',
          'mili',
          'milay',
          'mil',
          'aaye',
          'masool',
          'vasul',
          'vasool',
          'deceived',
          'hasil',
          'haasil',
          'borrow',
          'borrowed'
        ]) ||
        lowerText
            .containsAny(['taraf se', 'has given', 'se liye', 'se liya']) ||
        (tokens.contains('ne') && tokens.containsAny(['diye', 'diya'])) ||
        (tokens.contains('se') && tokens.containsAny(['liye', 'liya'])) ||
        (tokens.contains('maine') && tokens.contains('liye')) ||
        (tokens.contains('i') && tokens.contains('took'))) {
      type = "INCOME";
    } else if (tokens.containsAny([
      'spent',
      'gave',
      'paid',
      'kharch',
      'diye',
      'diya',
      'pay',
      'cost',
      'pada',
      'ada',
      'kiya',
      'give',
      'bought',
      'spend',
      'purchased'
    ])) {
      type = "EXPENSE";
    }

    // 3. Contact Extraction (Existing Regex)
    final subjectContactRegex = RegExp(
        r'^([A-Z][a-z]+)\s+(?:has|ne|ko|took|borrowed|gave|is|was|purchased|paid|spent)\b',
        caseSensitive: false);
    final subjectMatch = subjectContactRegex.firstMatch(originalText);
    if (subjectMatch != null) {
      contact = subjectMatch.group(1);
    }

    if (contact == null) {
      final objectContactRegex = RegExp(
          r'\b(?:to|from|by|with|ko|se|ne|gave|given)\s+([A-Z][a-z]+)\b',
          caseSensitive: false);
      final objectMatch = objectContactRegex.firstMatch(originalText);
      if (objectMatch != null) {
        contact = objectMatch.group(1);
      }
    }

    if (contact == null) {
      final trailingContactRegex = RegExp(
          r'([A-Z][a-z]+)\s+(?:ko|ne|se|ke|ki taraf)\b',
          caseSensitive: false);
      final trailingMatch = trailingContactRegex.firstMatch(originalText);
      if (trailingMatch != null) {
        contact = trailingMatch.group(1);
      }
    }

    final stopWords = [
      "I",
      "The",
      "A",
      "An",
      "Maine",
      "Ko",
      "Ne",
      "Se",
      "Diye",
      "Liye",
      "Per",
      "Par",
      "Ka",
      "Ki",
      "Ke",
      "Mila",
      "Diya",
      "Kharch",
      "Spent",
      "Gave",
      "Received",
      "Kiye",
      "Hua",
      "Kharcha",
      "Pada",
      "Ada",
      "Kiya",
      "Purchased"
    ];
    if (contact != null && stopWords.contains(contact)) {
      contact = null;
    }

    // 4. Category Extraction (Moved up for relationship detection)
    for (var kw in categoryKeywords) {
      if (lowerText.contains(kw)) {
        if (kw != contact?.toLowerCase()) {
          category = kw;
          break;
        }
      }
    }

    if (category == null) {
      final categoryRegex = RegExp(
          r'\b(?:for|per|liye|on)\s+([a-z]{3,})|([a-z]{3,})\s+(?:ke liye|per|par|ka kharcha|kharch|ka|ki|ke)\b');
      final categoryMatch = categoryRegex.firstMatch(lowerText);
      if (categoryMatch != null) {
        final found = categoryMatch.group(1) ?? categoryMatch.group(2);
        if (found != 'me' &&
            found != 'the' &&
            found != contact?.toLowerCase()) {
          category = found;
        }
      }
    }

    // 5. Relationship Detection (Existing logic)
    if ((tokens.contains('ne') &&
            tokens.containsAny(['diye', 'diya']) &&
            tokens.containsAny(['ka', 'ki', "ke"])) ||
        (tokens.contains('se') &&
            tokens.containsAny(['liye', 'liya']) &&
            tokens.containsAny(['ka', 'ki', "ke", "kar", "ker"])) ||
        lowerText.startsWithAny(['will give', 'i will give'])) {
      relationship = 'PAID_BY';
      type = "EXPENSE";
    } else if ((tokens.contains('ko') &&
            tokens.containsAny(['diye', 'diya'])) ||
        (tokens.contains('ne') && tokens.containsAny(['liye', 'liya'])) ||
        lowerText.startsWithAny(['give', 'gave', 'i give', 'i gave'])) {
      relationship = 'PAID_FOR';
    } else if (lowerText
            .containsAny(['paid by', 'someone paid', 'for me', 'mere liye']) ||
        (lowerText.contains('mere') && category != null) ||
        (contact != null &&
            lowerText.contains('gave') &&
            lowerText.contains('for'))) {
      relationship = 'PAID_BY';
    } else if (type == "INCOME" &&
        (contact != null ||
            lowerText.containsAny(['from', 'se', 'by']) ||
            tokens.contains('ne'))) {
      relationship = 'RECEIVED_FROM';
    } else if (lowerText.containsAny([
          'gave',
          'paid for',
          'bought for',
          'udhar diya',
          'udhaar diya',
          'udhar liye',
          'udhaar liye',
          'has taken',
          'took'
        ]) ||
        (tokens.contains('ne') && lowerText.endsWith('liye'))) {
      relationship = 'PAID_FOR';
    } else if (lowerText.containsAny(['usne diye', 'owe', 'dene hain'])) {
      relationship = 'PAID_BY';
    } else if (lowerText.containsAny(_willReceiveKeywords)) {
      relationship = 'WILL_RECEIVE';
    }

    if (contact == null || contact.isEmpty) {
      relationship = null;
    }

    final uniqueCandidates = amountCandidates.toSet().toList();
    if (isReceipt) {
      uniqueCandidates.sort((a, b) => b.compareTo(a));
    }

    List<String> descriptionCandidates = [];
    if (isReceipt && originalText.isNotEmpty) {
      descriptionCandidates = _descriptionCandidatesFromText(originalText);
    }

    return ParsedTransactionInput(
      amount: amount,
      type: type ?? "EXPENSE",
      categoryName: category,
      contactName: contact,
      paidRelationship: relationship,
      description: originalText,
      date: mlKitDates.isNotEmpty ? mlKitDates.first : DateTime.now(),
      usedFallback: false,
      amountCandidates: uniqueCandidates,
      descriptionCandidates: descriptionCandidates,
    );
  }

  static const int _maxDescLen = 60;
  static const int _maxDescCandidates = 8;

  static List<String> _descriptionCandidatesFromText(String text) {
    final List<String> candidates = [];
    final seen = <String>{};
    void add(String s) {
      final t = s.trim();
      if (t.isEmpty) return;
      final key = t.length > _maxDescLen
          ? t.substring(0, _maxDescLen).toLowerCase()
          : t.toLowerCase();
      if (seen.contains(key)) return;
      seen.add(key);
      candidates.add(
          t.length > _maxDescLen ? '${t.substring(0, _maxDescLen)}...' : t);
    }

    final noise = RegExp(
        r'^(RECEIPT|INVOICE|TAX|TOTAL|SUBTOTAL|DATE|TIME|QTY|ITEM|AMOUNT|CASH|CARD|THANK|VISIT|#|\d+\s*[xX]\s*|\d+\.\d{2})\s*$',
        caseSensitive: false);
    final mostlyNumber = RegExp(r'^[\d\s.,₹\$€£¥]+$');
    for (var line in text.split(RegExp(r'[\n\r]+'))) {
      final t = line.trim();
      if (t.length < 2) continue;
      if (noise.hasMatch(t) || mostlyNumber.hasMatch(t)) continue;
      add(t);
      if (candidates.length >= _maxDescCandidates) break;
    }
    return candidates;
  }
}
