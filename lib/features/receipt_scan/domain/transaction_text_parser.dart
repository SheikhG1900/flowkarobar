import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';
import 'package:flowpaisa/core/ml/model_download_service.dart';

abstract class TransactionTextParser {
  Future<ParsedTransactionInput?> parse(String text, {required bool isReceipt});
}

class TransactionAiParser implements TransactionTextParser {
  final ModelDownloadService _downloadService;
  Interpreter? _interpreter;
  List<String>? _vocab;
  
  static const int _maxSeqLen = 384;

  TransactionAiParser(this._downloadService);

  Future<void> _initialize() async {
    if (_interpreter != null && _vocab != null) return;

    final modelPath = await _downloadService.getModelPath(ModelDownloadService.transactionParserModel);
    final vocabPath = await _downloadService.getVocabPath(ModelDownloadService.transactionParserModel);

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
  Future<ParsedTransactionInput?> parse(String text, {required bool isReceipt}) async {
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

      final result = _mapAnswersToInput(answers, text, isReceipt: isReceipt);
      if (kDebugMode) {
        debugPrint('AI Parser: Final Result: amount=${result.amount}, type=${result.type}, category=${result.categoryName}, contact=${result.contactName}, relationship=${result.paidRelationship}');
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

    var outputStart = List<double>.filled(_maxSeqLen, 0.0).reshape([1, _maxSeqLen]);
    var outputEnd = List<double>.filled(_maxSeqLen, 0.0).reshape([1, _maxSeqLen]);
    
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
    int start = _getMaxIndexInRange(startLogits, sepIndex + 1, tokens.length - 2);
    int end = _getMaxIndexInRange(endLogits, start, tokens.length - 2);

    if (start > sepIndex && end >= start && end < tokens.length - 1) {
      final answerTokens = tokens.sublist(start, end + 1);
      final answer = _decodeTokens(answerTokens);
      // If the AI just returns a separator or special token, ignore it
      if (answer == "[SEP]" || answer == "[CLS]" || answer == "[PAD]") return "";
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
    return tokens
        .join(" ")
        .replaceAll(" ##", "")
        .replaceAll("##", "")
        .trim();
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

  ParsedTransactionInput _mapAnswersToInput(Map<String, String> answers, String originalText, {required bool isReceipt}) {
    double? amount;
    String? type;
    String? category;
    String? contact;
    String? relationship;
    List<double> amountCandidates = [];

    final lowerText = originalText.toLowerCase();
    final categoryKeywords = ['salary', 'bonus', 'rent', 'fuel', 'dinner', 'lunch', 'breakfast', 'travel', 'gift', 'profit', 'shopping', 'bills'];

    // 1. Amount Extraction (Prioritize Regex over confused AI)
    // Look for patterns like "Total: 500" or "Amount 1200.50"
    final amountRegex = RegExp(r'(?:total|amount|net|sum|due|paid|rs|₹|pkr)\s*[:\-\s]*(\d+(?:\.\d{1,2})?)', caseSensitive: false);
    final matches = amountRegex.allMatches(originalText);
    
    if (matches.isNotEmpty) {
      // Usually the last "Total" mention in a receipt is the final amount
      amount = double.tryParse(matches.last.group(1)!);
      for (var m in matches) {
        double? val = double.tryParse(m.group(1)!);
        if (val != null) amountCandidates.add(val);
      }
    }

    final simpleAmountRegex = RegExp(r'(\d+(?:\.\d{1,2})?)');
    final allNumbers = simpleAmountRegex.allMatches(originalText);
    if (allNumbers.isNotEmpty) {
      for (var m in allNumbers) {
        double? val = double.tryParse(m.group(1)!);
        if (val != null && !amountCandidates.contains(val)) {
          amountCandidates.add(val);
        }
      }
      
      if (isReceipt) {
        amountCandidates.sort((a, b) => b.compareTo(a));
      }

      if (amount == null) {
        if (isReceipt) {
          // In receipts, the largest number is almost always the total amount
          double maxAmount = 0;
          for (var m in allNumbers) {
            double? val = double.tryParse(m.group(1)!);
            if (val != null && val > maxAmount) maxAmount = val;
          }
          if (maxAmount > 0) amount = maxAmount;
        } else {
          // For voice commands, the first number is usually the amount
          amount = double.tryParse(allNumbers.first.group(1)!);
        }
      }
    }

    if (amount == null) {
      // Handle word-based numbers for native languages
      if (lowerText.contains('hazar') || lowerText.contains('hazaar') || lowerText.contains('thousand')) amount = 1000;
      else if (lowerText.contains('panch sau') || lowerText.contains('five hundred')) amount = 500;
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
    if (lowerText.contains('for me') || lowerText.contains('mere liye') || 
        (lowerText.contains('mere') && categoryKeywords.any((kw) => lowerText.contains(kw)))) {
      type = "EXPENSE";
    }
    // INCOME triggers
    else if (lowerText.contains('receive') || lowerText.contains('income') || lowerText.contains('salary') || 
        lowerText.contains('got') || lowerText.contains('mila') || lowerText.contains('mile') || 
        lowerText.contains('aaye') || lowerText.contains('masool') || lowerText.contains('taraf se') ||
        lowerText.contains('vasul') || lowerText.contains('vasool') || lowerText.contains('deceived') ||
        lowerText.contains('hasil') || lowerText.contains('haasil') || lowerText.contains('has given') ||
        lowerText.contains('borrow') || lowerText.contains('borrowed') ||
        (lowerText.contains('ne') && lowerText.contains('diye') && lowerText.contains('udhar')) || // Someone gave me loan
        (lowerText.contains('maine') && lowerText.contains('liye')) || // I took from someone
        (lowerText.contains('i') && lowerText.contains('took')) || // I took from someone
        lowerText.contains('se liye')) {
      type = "INCOME";
    } 
    // EXPENSE triggers (only if not already detected as income)
    else if (lowerText.contains('spent') || lowerText.contains('gave') || lowerText.contains('paid') || 
               lowerText.contains('kharch') || lowerText.contains('diye') || lowerText.contains('diya') || 
               lowerText.contains('pay') || lowerText.contains('cost') || lowerText.contains('pada') ||
               lowerText.contains('ada') || lowerText.contains('kiya') || lowerText.contains('give') ||
               lowerText.contains('bought') || lowerText.contains('spend') || lowerText.contains('purchased')) {
      type = "EXPENSE";
    }

    // 3. Contact Extraction (Moved up for better relationship detection)
    // Pattern A: Name as Subject (e.g., "Ashfaq has taken", "Ashfaq ne")
    final subjectContactRegex = RegExp(r'^([A-Z][a-z]+)\s+(?:has|ne|ko|took|borrowed|gave|is|was|purchased|paid|spent)', caseSensitive: false);
    final subjectMatch = subjectContactRegex.firstMatch(originalText);
    if (subjectMatch != null) {
      contact = subjectMatch.group(1);
    }

    // Pattern B: Name as Object (e.g., "to Ashfaq", "from Ashfaq")
    if (contact == null) {
      final objectContactRegex = RegExp(r'(?:to|from|by|with|ko|se|ne|gave|given)\s+([A-Z][a-z]+)', caseSensitive: false);
      final objectMatch = objectContactRegex.firstMatch(originalText);
      if (objectMatch != null) {
        contact = objectMatch.group(1);
      }
    }

    // Pattern C: Hindi/Urdu trailing name (e.g., "Ashfaq ko")
    if (contact == null) {
      final trailingContactRegex = RegExp(r'([A-Z][a-z]+)\s+(?:ko|ne|se|ke|ki taraf)', caseSensitive: false);
      final trailingMatch = trailingContactRegex.firstMatch(originalText);
      if (trailingMatch != null) {
        contact = trailingMatch.group(1);
      }
    }

    // Stop words for names to avoid picking up pronouns or verbs as contacts
    final stopWords = ["I", "The", "A", "An", "Maine", "Ko", "Ne", "Se", "Diye", "Liye", "Per", "Par", "Ka", "Ki", "Ke", "Mila", "Diya", "Kharch", "Spent", "Gave", "Received", "Kiye", "Hua", "Kharcha", "Pada", "Ada", "Kiya", "Purchased"];
    if (contact != null && stopWords.contains(contact)) {
      contact = null;
    }

    // 4. Relationship Detection (Enhanced with Hindi/Urdu)
    // Check PAID_BY first (someone paying for my expense)
    if (lowerText.contains('paid by') || lowerText.contains('someone paid') || 
        lowerText.contains('for me') || lowerText.contains('mere liye') ||
        (lowerText.contains('mere') && category != null) ||
        (contact != null && lowerText.contains('gave') && lowerText.contains('for')) || // "Ashfaq gave 500 for dinner"
        (contact != null && lowerText.contains('diye') && !lowerText.contains('udhar') && !lowerText.contains('se'))) { 
      relationship = 'PAID_BY';
    } 
    // Check RECEIVED_FROM for income
    else if (type == "INCOME" && (contact != null || lowerText.contains('from') || lowerText.contains('se') || lowerText.contains('by') || lowerText.contains('ne'))) {
      relationship = 'RECEIVED_FROM';
    } else if (lowerText.contains('gave') || lowerText.contains('paid for') || lowerText.contains('diye') || 
        lowerText.contains('diya') || lowerText.contains('give') || lowerText.contains('bought for') ||
        lowerText.contains('udhar diya') || lowerText.contains('udhaar diya') ||
        lowerText.contains('udhar liye') || lowerText.contains('udhaar liye') ||
        lowerText.contains('has taken') || lowerText.contains('took') ||
        (lowerText.contains('ne') && lowerText.endsWith('liye')) ||
        (lowerText.contains('ko') && lowerText.contains('diye'))) {
      relationship = 'PAID_FOR';
    } else if (lowerText.contains('usne diye') || lowerText.contains('owe') || lowerText.contains('dene hain')) {
      relationship = 'PAID_BY';
    } else if (lowerText.contains('will receive') || lowerText.contains('udhaar') || lowerText.contains('lene hain')) {
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
      final categoryRegex = RegExp(r'(?:for|per|liye|on)\s+([a-z]{3,})|([a-z]{3,})\s+(?:ke liye|per|par|ka kharcha|kharch)');
      final categoryMatch = categoryRegex.firstMatch(lowerText);
      if (categoryMatch != null) {
        final found = categoryMatch.group(1) ?? categoryMatch.group(2);
        // Ensure category is not 'me', 'the', or the contact name
        if (found != 'me' && found != 'the' && found != contact?.toLowerCase()) {
          category = found;
        }
      }
    }

    // Relationship only exists if there is a contact
    if (contact == null || contact.isEmpty) {
      relationship = null;
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
      amountCandidates: amountCandidates,
    );
  }
}
