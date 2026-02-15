import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';
import 'package:flowpaisa/core/ml/model_download_service.dart';

abstract class TransactionTextParser {
  Future<ParsedTransactionInput?> parse(String text,
      {required bool isReceipt, List<String>? customSymbols});
}

class TransactionAiParser implements TransactionTextParser {
  final ModelDownloadService _downloadService;
  Interpreter? _interpreter;
  List<String>? _vocab;

  static const int _maxSeqLen = 384;

  TransactionAiParser(this._downloadService);

  Future<void> _initialize() async {
    if (_interpreter != null && _vocab != null) return;

    final modelPath = await _downloadService
        .getModelPath(ModelDownloadService.transactionParserModel);
    final vocabPath = await _downloadService
        .getVocabPath(ModelDownloadService.transactionParserModel);

    if (kDebugMode) {
      debugPrint('AI Parser: Model Path: $modelPath');
      debugPrint('AI Parser: Vocab Path: $vocabPath');
    }

    if (modelPath != null && vocabPath != null) {
      try {
        _interpreter = await Interpreter.fromFile(File(modelPath));
        if (kDebugMode) {
          debugPrint('AI Parser: Interpreter initialized successfully');
        }
        final vocabFile = File(vocabPath);
        _vocab = await vocabFile.readAsLines();
        if (kDebugMode) {
          debugPrint('AI Parser: Vocab loaded: ${_vocab?.length} lines');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AI Parser Initialization Error: $e');
        }
      }
    }
  }

  @override
  Future<ParsedTransactionInput?> parse(String text,
      {required bool isReceipt, List<String>? customSymbols}) async {
    await _initialize();
    if (_interpreter == null || _vocab == null) {
      if (kDebugMode) {
        debugPrint('AI Parser: Interpreter or Vocab is null');
      }
      return null;
    }

    try {
      if (kDebugMode) {
        debugPrint('AI Parser: Starting inference for text: $text');
      }
      final questions = [
        "How much was the amount?",
        "What is the category?",
        "Who is the contact?",
        "Is it income or expense?",
        "What is the relationship?",
      ];

      final Map<String, String> answers = {};

      for (var question in questions) {
        final answer = _getAnswer(question, text);
        if (kDebugMode) {
          debugPrint('AI Parser: Question: $question -> Answer: $answer');
        }
        if (answer.isNotEmpty) {
          answers[question] = answer;
        }
      }

      final result = _mapAnswersToInput(answers, text,
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

  String _getAnswer(String question, String context) {
    if (_interpreter == null || _vocab == null) return "";

    final tokens = _tokenize(question, context);
    if (tokens.isEmpty) return "";

    final inputIds = List<int>.filled(_maxSeqLen, 0);
    final segmentIds = List<int>.filled(_maxSeqLen, 0);
    final attentionMask = List<int>.filled(_maxSeqLen, 0);

    bool inContext = false;
    for (int i = 0; i < min(tokens.length, _maxSeqLen); i++) {
      final token = tokens[i];
      int vocabIdx = _vocab!.indexOf(token);
      if (vocabIdx == -1) {
        vocabIdx = _vocab!.indexOf("[UNK]");
      }

      inputIds[i] = vocabIdx;
      attentionMask[i] = 1;
      if (token == "[SEP]") inContext = true;
      if (inContext) segmentIds[i] = 1;
    }

    var outputStart =
        List<double>.filled(_maxSeqLen, 0.0).reshape([1, _maxSeqLen]);
    var outputEnd =
        List<double>.filled(_maxSeqLen, 0.0).reshape([1, _maxSeqLen]);

    var inputs = [
      Int32List.fromList(inputIds),
      Int32List.fromList(segmentIds),
      Int32List.fromList(attentionMask)
    ];
    var outputs = {0: outputStart, 1: outputEnd};

    _interpreter!.runForMultipleInputs(inputs, outputs);

    List<double> startLogits = (outputStart as List).first.cast<double>();
    List<double> endLogits = (outputEnd as List).first.cast<double>();

    int sepIndex = tokens.indexOf("[SEP]");
    // Exclude [SEP] from the search range
    int start =
        _getMaxIndexInRange(startLogits, sepIndex + 1, tokens.length - 2);
    int end = _getMaxIndexInRange(endLogits, start, tokens.length - 2);

    if (start > sepIndex && end >= start && end < tokens.length - 1) {
      final answerTokens = tokens.sublist(start, end + 1);
      final answer = _decodeTokens(answerTokens);
      // If the AI just returns a separator or special token, ignore it
      if (answer == "[SEP]" || answer == "[CLS]" || answer == "[PAD]")
        return "";
      return answer;
    }

    return "";
  }

  int _getMaxIndexInRange(List<double> list, int start, int end) {
    if (start < 0 || start >= list.length) return 0;
    double maxVal = -double.infinity;
    int maxIdx = start;
    for (int i = start; i <= min(end, list.length - 1); i++) {
      if (list[i] > maxVal) {
        maxVal = list[i];
        maxIdx = i;
      }
    }
    return maxIdx;
  }

  List<String> _tokenize(String query, String context) {
    final List<String> tokens = ["[CLS]"];
    tokens.addAll(query.toLowerCase().split(RegExp(r'\s+')));
    tokens.add("[SEP]");
    tokens.addAll(context.toLowerCase().split(RegExp(r'\s+')));
    tokens.add("[SEP]");
    return tokens;
  }

  String _decodeTokens(List<String> tokens) {
    return tokens.join(" ").replaceAll(" ##", "").replaceAll("##", "").trim();
  }

  int _getMaxIndex(List<double> list) {
    double maxVal = -double.infinity;
    int maxIdx = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i] > maxVal) {
        maxVal = list[i];
        maxIdx = i;
      }
    }
    return maxIdx;
  }

  ParsedTransactionInput _mapAnswersToInput(
      Map<String, String> answers, String originalText,
      {required bool isReceipt, List<String>? customSymbols}) {
    double? amount;
    String? type;
    String? category;
    String? contact;
    String? relationship;
    List<double> amountCandidates = [];

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

    // 1. Amount Extraction (Prioritize Regex over confused AI)
    // Predefined symbols + custom ones from DB
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
        if (!symbols.contains(s.toLowerCase()))
          symbols.add(RegExp.escape(s.toLowerCase()));
      }
    }

    final symbolsPattern = symbols.join('|');
    final amountRegex = RegExp(
        '(?:$symbolsPattern)\\s*[:\\-\\s]*(\\d+(?:\\.\\d{1,2})?)',
        caseSensitive: false);
    final matches = amountRegex.allMatches(originalText);

    // Helper to check if a number is likely a phone number or date
    bool isNoiseNumber(String numStr, double value, int startPos) {
      // 1. Phone numbers: usually 10+ digits
      if (numStr.length >= 10 && !numStr.contains('.')) return true;

      // 2. Years: 2020-2030 (common in receipts)
      if (value >= 2020 && value <= 2030 && !numStr.contains('.')) return true;

      // 3. Time check: Check if there's a colon immediately before or after
      if (startPos > 0 && originalText[startPos - 1] == ':') return true;
      if (startPos + numStr.length < originalText.length &&
          originalText[startPos + numStr.length] == ':') return true;

      // 4. Date check: Check for common date separators / or -
      if (startPos > 0 &&
          (originalText[startPos - 1] == '/' ||
              originalText[startPos - 1] == '-')) return true;
      if (startPos + numStr.length < originalText.length &&
          (originalText[startPos + numStr.length] == '/' ||
              originalText[startPos + numStr.length] == '-')) return true;

      // 5. Common receipt noise: check for patterns like "24/05/2024" or "12:30:45"
      // If the number is part of a date or time string, ignore it
      final surrounding = originalText.substring(max(0, startPos - 5),
          min(originalText.length, startPos + numStr.length + 5));
      if (surrounding.contains(RegExp(r'\d{1,2}/\d{1,2}/\d{2,4}')) ||
          surrounding.contains(RegExp(r'\d{1,2}-\d{1,2}-\d{2,4}')) ||
          surrounding.contains(RegExp(r'\d{1,2}:\d{2}'))) {
        return true;
      }

      // 6. User request: ignore numbers separated by space or brackets like "1234 123", "(456) 1245 124"
      // Check if there are digits immediately before or after with a space or bracket
      if (startPos > 1) {
        final before = originalText.substring(max(0, startPos - 2), startPos);
        if (before.contains(RegExp(r'[\d\(\)]\s'))) return true;
      }
      if (startPos + numStr.length < originalText.length - 1) {
        final after = originalText.substring(startPos + numStr.length,
            min(originalText.length, startPos + numStr.length + 2));
        if (after.contains(RegExp(r'\s[\d\(\)]'))) return true;
      }

      return false;
    }

    if (matches.isNotEmpty) {
      // Filter out noise from keyword matches; skip duplicates
      for (var m in matches) {
        final numStr = m.group(1)!;
        final val = double.tryParse(numStr);
        if (val != null &&
            !amountCandidates.contains(val) &&
            !isNoiseNumber(
                numStr, val, m.start + m.group(0)!.indexOf(numStr))) {
          amountCandidates.add(val);
        }
      }
      if (amountCandidates.isNotEmpty) {
        // Usually the last "Total" mention in a receipt is the final amount
        amount = amountCandidates.last;
      }
    }

    final simpleAmountRegex = RegExp(r'\b\d+(?:\.\d{1,2})?\b');
    final allNumbers = simpleAmountRegex.allMatches(originalText);
    if (allNumbers.isNotEmpty) {
      for (var m in allNumbers) {
        final numStr = m.group(0)!;
        final val = double.tryParse(numStr);
        if (val != null &&
            !amountCandidates.contains(val) &&
            !isNoiseNumber(numStr, val, m.start)) {
          // Additional check for receipts: ignore very small numbers like 1, 2, 3 which are often quantities
          if (isReceipt && val < 5 && !numStr.contains('.')) continue;

          amountCandidates.add(val);
        }
      }

      if (isReceipt) {
        amountCandidates.sort((a, b) => b.compareTo(a));
      }

      if (amount == null && amountCandidates.isNotEmpty) {
        if (isReceipt) {
          // In receipts, the largest remaining number is likely the total amount
          amount = amountCandidates.first;
        } else {
          // For voice commands, the first number is usually the amount
          amount = amountCandidates.first;
        }
      }
    }

    if (amount == null) {
      // Handle word-based numbers for native languages
      if (lowerText.contains('hazar') ||
          lowerText.contains('hazaar') ||
          lowerText.contains('thousand'))
        amount = 1000;
      else if (lowerText.contains('panch sau') ||
          lowerText.contains('five hundred'))
        amount = 500;
      else {
        final amountStr = answers["How much was the amount?"];
        if (amountStr != null && amountStr.isNotEmpty) {
          final cleanAmount = amountStr.replaceAll(RegExp(r'[^0-9.]'), '');
          amount = double.tryParse(cleanAmount);
        }
      }
    }

    // 2. Type Detection (Enhanced logic with Hindi/Urdu)
    // Check for PAID_BY indicators first (someone paying for my expense)
    if (lowerText.contains('for me') ||
        lowerText.contains('mere liye') ||
        (lowerText.contains('mere') &&
            categoryKeywords.any((kw) => lowerText.contains(kw)))) {
      type = "EXPENSE";
    }
    // INCOME triggers
    else if (tokens.contains('receive') ||
        tokens.contains('income') ||
        tokens.contains('salary') ||
        tokens.contains('got') ||
        tokens.contains('mila') ||
        tokens.contains('mile') ||
        tokens.contains('aaye') ||
        tokens.contains('masool') ||
        lowerText.contains('taraf se') ||
        tokens.contains('vasul') ||
        tokens.contains('vasool') ||
        tokens.contains('deceived') ||
        tokens.contains('hasil') ||
        tokens.contains('haasil') ||
        lowerText.contains('has given') ||
        tokens.contains('borrow') ||
        tokens.contains('borrowed') ||
        (tokens.contains('ne') &&
            tokens.contains('diye') &&
            tokens.contains('udhar')) || // Someone gave me loan
        (tokens.contains('maine') &&
            tokens.contains('liye')) || // I took from someone
        (tokens.contains('i') &&
            tokens.contains('took')) || // I took from someone
        lowerText.contains('se liye')) {
      type = "INCOME";
    }
    // EXPENSE triggers (only if not already detected as income)
    else if (tokens.contains('spent') ||
        tokens.contains('gave') ||
        tokens.contains('paid') ||
        tokens.contains('kharch') ||
        tokens.contains('diye') ||
        tokens.contains('diya') ||
        tokens.contains('pay') ||
        tokens.contains('cost') ||
        tokens.contains('pada') ||
        tokens.contains('ada') ||
        tokens.contains('kiya') ||
        tokens.contains('give') ||
        tokens.contains('bought') ||
        tokens.contains('spend') ||
        tokens.contains('purchased')) {
      type = "EXPENSE";
    }

    // 3. Contact Extraction (Moved up for better relationship detection)
    // Pattern A: Name as Subject (e.g., "Ashfaq has taken", "Ashfaq ne")
    final subjectContactRegex = RegExp(
        r'^([A-Z][a-z]+)\s+(?:has|ne|ko|took|borrowed|gave|is|was|purchased|paid|spent)\b',
        caseSensitive: false);
    final subjectMatch = subjectContactRegex.firstMatch(originalText);
    if (subjectMatch != null) {
      contact = subjectMatch.group(1);
    }

    // Pattern B: Name as Object (e.g., "to Ashfaq", "from Ashfaq")
    if (contact == null) {
      final objectContactRegex = RegExp(
          r'\b(?:to|from|by|with|ko|se|ne|gave|given)\s+([A-Z][a-z]+)\b',
          caseSensitive: false);
      final objectMatch = objectContactRegex.firstMatch(originalText);
      if (objectMatch != null) {
        contact = objectMatch.group(1);
      }
    }

    // Pattern C: Hindi/Urdu trailing name (e.g., "Ashfaq ko")
    if (contact == null) {
      final trailingContactRegex = RegExp(
          r'([A-Z][a-z]+)\s+(?:ko|ne|se|ke|ki taraf)\b',
          caseSensitive: false);
      final trailingMatch = trailingContactRegex.firstMatch(originalText);
      if (trailingMatch != null) {
        contact = trailingMatch.group(1);
      }
    }

    // Stop words for names to avoid picking up pronouns or verbs as contacts
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

    // 4. Relationship Detection (Enhanced with Hindi/Urdu)
    // Check PAID_BY first (someone paying for my expense or borrowing from them)
    if ((tokens.contains('ne') &&
            (tokens.contains('diye') || tokens.contains('diya'))) ||
        (tokens.contains('se') &&
            (tokens.contains('liye') || tokens.contains('liya'))) ||
        lowerText.startsWith('will give') ||
        lowerText.startsWith('i will give')) {
      relationship = 'PAID_BY';
    } else if ((tokens.contains('ko') &&
            (tokens.contains('diye') || tokens.contains('diya'))) ||
        tokens.contains('ne') &&
            (tokens.contains('liye') || tokens.contains('liya')) ||
        lowerText.startsWith('give') ||
        lowerText.startsWith('gave') ||
        lowerText.startsWith('i give') ||
        lowerText.startsWith('i gave')) {
      relationship = 'PAID_FOR';
    } else if (lowerText.contains('paid by') ||
        lowerText.contains('someone paid') ||
        lowerText.contains('for me') ||
        lowerText.contains('mere liye') ||
        (lowerText.contains('mere') && category != null) ||
        (contact != null &&
            lowerText.contains('gave') &&
            lowerText.contains('for'))) {
      relationship = 'PAID_BY';
    }
    // Check RECEIVED_FROM for income
    else if (type == "INCOME" &&
        (contact != null ||
            lowerText.contains('from') ||
            lowerText.contains('se') ||
            lowerText.contains('by') ||
            tokens.contains('ne'))) {
      relationship = 'RECEIVED_FROM';
    } else if (lowerText.contains('gave') ||
        lowerText.contains('paid for') ||
        lowerText.contains('bought for') ||
        lowerText.contains('udhar diya') ||
        lowerText.contains('udhaar diya') ||
        lowerText.contains('udhar liye') ||
        lowerText.contains('udhaar liye') ||
        lowerText.contains('has taken') ||
        lowerText.contains('took') ||
        (tokens.contains('ne') && lowerText.endsWith('liye'))) {
      relationship = 'PAID_FOR';
    } else if (lowerText.contains('usne diye') ||
        lowerText.contains('owe') ||
        lowerText.contains('dene hain')) {
      relationship = 'PAID_BY';
    } else if (lowerText.contains('will receive') ||
        lowerText.contains('udhaar') ||
        lowerText.contains('lene hain')) {
      relationship = 'WILL_RECEIVE';
    }

    // 5. Category Extraction (Look for words after 'for' or 'per' or before 'ke liye')
    // Also look for common category words: salary, bonus, rent, fuel, dinner, etc.
    for (var kw in categoryKeywords) {
      if (lowerText.contains(kw)) {
        // Ensure category is not also the contact name (case insensitive check)
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
        // Ensure category is not 'me', 'the', or the contact name
        if (found != 'me' &&
            found != 'the' &&
            found != contact?.toLowerCase()) {
          category = found;
        }
      }
    }

    // Relationship only exists if there is a contact
    if (contact == null || contact.isEmpty) {
      relationship = null;
    }

    // Ensure no duplicate amounts in suggestions
    final uniqueCandidates = amountCandidates.toSet().toList();
    if (isReceipt) {
      uniqueCandidates.sort((a, b) => b.compareTo(a));
    }

    // Description suggestions from full text (for receipts)
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
      date: DateTime.now(),
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
