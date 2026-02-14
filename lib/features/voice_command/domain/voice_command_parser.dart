import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';

class VoiceCommandParser {
  ParsedTransactionInput parse(String text) {
    final lowerText = text.toLowerCase();
    
    // 1. Extract Amount
    final amountRegex = RegExp(r'(\d+)\s*(?:rs|rupees|bucks|rupee)?');
    final amountMatch = amountRegex.firstMatch(lowerText);
    double? amount;
    if (amountMatch != null) {
      amount = double.tryParse(amountMatch.group(1)!);
    }

    // 2. Extract Type
    String type = 'EXPENSE';
    if (lowerText.contains('income') || lowerText.contains('received') || lowerText.contains('salary')) {
      type = 'INCOME';
    }

    // 3. Extract Relationship (Linked Transactions)
    String? relationship;
    String? contactName;
    
    // "I gave 100 to Usman" -> PAID_FOR
    if (lowerText.contains('gave') || lowerText.contains('paid for')) {
      relationship = 'PAID_FOR';
    } else if (lowerText.contains('paid by')) {
      relationship = 'PAID_BY';
    } else if (lowerText.contains('received from')) {
      relationship = 'RECEIVED_FROM';
    } else if (lowerText.contains('will give')) {
      relationship = 'WILL_RECEIVE';
    }

    // 4. Extract Contact Name (Simple heuristic: word after 'to', 'from', 'for')
    final contactRegex = RegExp(r'(?:to|from|for|by)\s+([a-zA-Z]+)');
    final contactMatch = contactRegex.firstMatch(lowerText);
    if (contactMatch != null) {
      contactName = contactMatch.group(1);
    }

    // 5. Extract Category/Description (Remaining words)
    // This is a very basic fallback. AI will handle this much better.
    String? description = text;

    return ParsedTransactionInput(
      amount: amount,
      type: type,
      date: DateTime.now(),
      description: description,
      contactName: contactName,
      paidRelationship: relationship,
      usedFallback: true,
    );
  }
}
