import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';
import 'package:flowpaisa/core/extensions/list_extensions.dart';
import 'package:flowpaisa/core/extensions/string_extensions.dart';

class VoiceCommandParser {
  ParsedTransactionInput parse(String text) {
    final lowerText = text.toLowerCase().trim();
    final tokens = lowerText.split(RegExp(r'[\s,.]+'));
    final commonCategories = [
      'fuel',
      'food',
      'dinner',
      'lunch',
      'rent',
      'salary',
      'bonus',
      'gift',
      'bill',
      'shopping',
      'travel'
    ];

    // 1. Extract Amount
    final amountRegex = RegExp(
        r'(\d+(?:\.\d{1,2})?)\s*(?:rs|rupees|bucks|rupee)?',
        caseSensitive: false);
    final amountMatch = amountRegex.firstMatch(lowerText);
    double? amount;
    if (amountMatch != null) {
      amount = double.tryParse(amountMatch.group(1)!);
    }

    // 2. Extract Type
    String type = 'EXPENSE';
    if (tokens.containsAny(
            ['income', 'received', 'receved', 'salary', 'bonus']) ||
        lowerText.contains('will receive')) {
      type = 'INCOME';
    }

    // 3. Extract Relationship (Linked Transactions)
    String? relationship;
    String? contactName;
    if (lowerText.containsAny(['paid by', 'will give']) ||
        lowerText.startsWith('i will give')) {
      relationship = 'PAID_BY';
    } else if (lowerText.startsWithAny(['gave', 'give', 'i gave', 'i give']) ||
        lowerText.contains('paid for')) {
      relationship = 'PAID_FOR';
    } else if (lowerText.containsAny(['give', 'gave'])) {
      relationship = 'PAID_BY';
    } else if (lowerText.containsAny(
        ['received from', 'receive from', 'receve from', 'receved from'])) {
      relationship = 'RECEIVED_FROM';
    } else if (lowerText.contains('will receive')) {
      relationship = 'WILL_RECEIVE';
    }

    // 4. Extract Contact Name (Simple heuristic: word before 'ko' or 'ne', or after 'to', 'from', etc.)
    // Pattern A: Name before 'ko' or 'ne'
    final trailingContactRegex =
        RegExp(r'([a-zA-Z]+)\s+(?:gave|give|received|receive|receve)\b');
    final trailingMatch = trailingContactRegex.firstMatch(lowerText);
    if (trailingMatch != null) {
      final candidate = trailingMatch.group(1)!;
      if (!commonCategories.contains(candidate.toLowerCase()) &&
          candidate.trim() != "i" &&
          candidate.trim() != "will") {
        contactName = candidate;
      }
    }

    // Pattern B: word after 'to', 'from', 'for', 'form'
    if (contactName == null) {
      final contactRegex = RegExp(r'\b(?:to|from|for|by|form)\s+([a-zA-Z]+)\b');
      final contactMatch = contactRegex.firstMatch(lowerText);
      if (contactMatch != null) {
        final candidate = contactMatch.group(1)!;
        // Priority to commonCategories: if it's a category, it's not a contact
        if (!commonCategories.contains(candidate.toLowerCase())) {
          contactName = candidate;
        }
      }
    }

    // 5. Extract Category (Simple heuristic for basic mode)
    String? category;

    // Pattern B: Look for word after 'for', 'on', 'per', 'par'
    final categoryRegex = RegExp(r'\b(?:for|on)\s+([a-zA-Z]+)\b');
    final categoryMatch = categoryRegex.firstMatch(lowerText);
    if (categoryMatch != null) {
      final candidate = categoryMatch.group(1);
      if (candidate != contactName) {
        category = candidate;
      }
    }

    // If no category found via keywords, check common categories directly
    if (category == null) {
      for (final cat in commonCategories) {
        if (lowerText.contains(cat)) {
          category = cat;
          break;
        }
      }
    }

    return ParsedTransactionInput(
      amount: amount,
      type: type,
      date: DateTime.now(),
      description: text,
      categoryName: category,
      contactName: contactName,
      paidRelationship: relationship,
      usedFallback: true,
    );
  }
}
