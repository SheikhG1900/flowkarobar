import 'package:flutter/foundation.dart';
import 'package:flowpaisa/core/entity_extraction/entity_extraction_base.dart';
import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';
import 'package:flowpaisa/core/extensions/list_extensions.dart';
import 'package:flowpaisa/core/extensions/string_extensions.dart';

/// Voice-command specific AI parser using ML Kit entities + rule based logic.
class VoiceAiParser extends BaseTransactionAiParser {
  static final List<String> _willReceiveKeywords = [
    'will receive',
    'will take',
    'will get',
    ...('lene'.makeCombinations(['ha', 'hain', 'he'], ['', ' '])),
    ...(['milay', 'mili', 'milen', 'milan', 'mile', 'mila']
        .makeCombinations(['ga', 'gi', 'gay', 'ge'], ['', ' '])),
    ...(['loon', 'lun', 'loo', 'lu', 'le', 'lain']
        .makeCombinations(['ga', 'gi', 'gay', 'ge'], ['', ' '])),
  ];

  @override
  Future<ParsedTransactionInput?> parse(
    String text, {
    List<String>? customSymbols,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
            'Voice AI Parser (ML Kit): Starting extraction for text: $text');
        debugPrint('Voice AI Parser (ML Kit): Raw Input Text:\n$text');
      }

      final extracted = await extractEntities(text);
      final result = _mapEntitiesToInput(
        extracted,
        text,
        customSymbols: customSymbols,
      );

      if (kDebugMode) {
        debugPrint(
            'Voice AI Parser: Final Result: amount=${result.amount}, type=${result.type}, category=${result.categoryName}, contact=${result.contactName}, relationship=${result.paidRelationship}');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Voice AI Parser Error: $e');
      }
      return null;
    }
  }

  ParsedTransactionInput _mapEntitiesToInput(
    Map<String, dynamic> extracted,
    String originalText, {
    List<String>? customSymbols,
  }) {
    double? amount;
    String? type;
    String? category;
    String? contact;
    String? relationship;

    final List<double> mlKitAmounts = extracted['amount'] as List<double>;
    final List<DateTime> mlKitDates = extracted['date'] as List<DateTime>;
    List<AmountCandidate> amountCandidates =
        mlKitAmounts.map((v) => AmountCandidate(value: v)).toList();

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

    // Amount refinement tuned for natural language voice input.
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
    final amountRegex = RegExp(
      '(?:(?:$symbolsPattern)[\\s\\(\\)\\.:\\-]*|\\b)(\\d+(?:\\.\\d+)?)',
      caseSensitive: false,
    );
    final matches = amountRegex.allMatches(originalText);

    for (var m in matches) {
      final val = double.tryParse(m.group(1)!.replaceAll(',', ''));
      if (val != null &&
          val <= 1000000 &&
          !amountCandidates.any((c) => c.value == val)) {
        amountCandidates.add(AmountCandidate(value: val));
      }
    }

    if (amountCandidates.isNotEmpty) {
      amount = amountCandidates.first.value;
    }

    // Type detection.
    if (lowerText.containsAny(['for me', 'mere liye']) ||
        (lowerText.contains('mere') &&
            categoryKeywords.any((kw) => lowerText.contains(kw)))) {
      type = "EXPENSE";
    } else if (tokens.containsAny([
          'receive',
          'received',
          'income',
          'salary',
          'got',
          'get',
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

    // Contact extraction.
    final subjectContactRegex = RegExp(
      r'^([A-Z][a-z]+)\s+(?:has|ne|ko|took|borrowed|gave|is|was|purchased|paid|spent)\b',
      caseSensitive: false,
    );
    final subjectMatch = subjectContactRegex.firstMatch(originalText);
    if (subjectMatch != null) {
      contact = subjectMatch.group(1);
    }

    if (contact == null) {
      final objectContactRegex = RegExp(
        r'\b(?:to|from|by|with|ko|se|ne|gave|given)\s+([A-Z][a-z]+)\b',
        caseSensitive: false,
      );
      final objectMatch = objectContactRegex.firstMatch(originalText);
      if (objectMatch != null) {
        contact = objectMatch.group(1);
      }
    }

    if (contact == null) {
      final trailingContactRegex = RegExp(
        r'([A-Z][a-z]+)\s+(?:ko|ne|se|ke|ki taraf)\b',
        caseSensitive: false,
      );
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

    // Category extraction.
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
        r'\b(?:for|per|liye|on)\s+([a-z]{3,})|([a-z]{3,})\s+(?:ke liye|per|par|ka kharcha|kharch|ka|ki|ke)\b',
      );
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

    // Relationship detection.
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
        lowerText.startsWithAny(
            ['give', 'gave', 'i give', 'i gave', 'i paid', 'i pay'])) {
      relationship = 'PAID_FOR';
    } else if (lowerText
            .containsAny(['paid by', 'someone paid', 'for me', 'mere liye']) ||
        (lowerText.contains('mere') && category != null) ||
        (contact != null &&
            lowerText.containsAny(['gave', 'give', 'paid', 'pay']) &&
            lowerText.contains('for'))) {
      relationship = 'PAID_BY';
    } else if (type == "INCOME" &&
        !lowerText.containsAny(_willReceiveKeywords) &&
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
      type = "INCOME";
    }

    if (contact == null || contact.isEmpty) {
      relationship = null;
    }

    final seen = <double>{};
    final uniqueCandidates =
        amountCandidates.where((c) => seen.add(c.value)).toList();

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
      descriptionCandidates: const [],
    );
  }
}
