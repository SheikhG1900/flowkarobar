import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flowpaisa/core/database/database.dart';

class ReceiptData {
  final String? merchantName;
  final double? amount;
  final DateTime? date;
  final String? categoryName;
  
  // Candidates for ambiguity handling
  final List<double> amountCandidates;
  final List<DateTime> dateCandidates;

  ReceiptData({
    this.merchantName,
    this.amount,
    this.date,
    this.categoryName,
    this.amountCandidates = const [],
    this.dateCandidates = const [],
  });
}

class ReceiptParser {
  /// Parse recognized text to extract receipt details
  ReceiptData parse(RecognizedText recognizedText) {
    final merchant = _extractMerchant(recognizedText);
    final amounts = _extractAmounts(recognizedText);
    final dates = _extractDates(recognizedText);
    final category = _predictCategory(recognizedText);

    // Sort amounts: usually the Total is the largest number
    amounts.sort((a, b) => b.compareTo(a));
    
    // Sort dates: usually the receipt date is recent
    dates.sort((a, b) => b.compareTo(a));

    return ReceiptData(
      merchantName: merchant,
      amount: amounts.isNotEmpty ? amounts.first : null,
      date: dates.isNotEmpty ? dates.first : null,
      categoryName: category,
      amountCandidates: amounts,
      dateCandidates: dates,
    );
  }

  /// Extract Merchant Name (Heuristic: Largest text in top 20%)
  String? _extractMerchant(RecognizedText text) {
    final height = text.text.length; // Approximate check, real check needs image dimensions which we don't have easily here
    // Instead, we assume the receipt is vertical. We look at blocks with low Y coordinates.
    
    // Filter blocks that are likely headers
    final validBlocks = text.blocks.where((block) {
      final text = block.text.toUpperCase();
      return !text.contains('RECEIPT') && 
             !text.contains('INVOICE') && 
             !text.contains('TOTAL') &&
             !text.contains('TAX') &&
             block.text.length > 3; // Skip noise
    }).toList();

    if (validBlocks.isEmpty) return null;

    // Sort by vertical position (Y) first to find top items
    validBlocks.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    // Take top 3 blocks and find the one with largest font height
    final topBlocks = validBlocks.take(3).toList();
    if (topBlocks.isEmpty) return null;

    topBlocks.sort((a, b) => b.boundingBox.height.compareTo(a.boundingBox.height));

    // Return the largest one
    return topBlocks.first.text.split('\n').first.trim(); // Take first line of block
  }

  /// Extract all possible amounts
  List<double> _extractAmounts(RecognizedText text) {
    final List<double> amounts = [];
    // Regex for currency formats: 10.00, 1,200.50, .99
    final regex = RegExp(r'[0-9]+[.,][0-9]{2}'); 

    for (var line in text.blocks.expand((b) => b.lines)) {
      final match = regex.firstMatch(line.text);
      if (match != null) {
        String cleanAmount = match.group(0)!.replaceAll(',', '');
        final val = double.tryParse(cleanAmount);
        if (val != null && val > 0 && val < 1000000) { // Sanity check
          amounts.add(val);
        }
      }
    }
    return amounts.toSet().toList(); // Remove duplicates
  }

  /// Extract all possible dates
  List<DateTime> _extractDates(RecognizedText text) {
    final List<DateTime> dates = [];
    // Regex for dd/mm/yyyy, dd-mm-yyyy, yyyy-mm-dd
    // Simplified regex
    final regex = RegExp(r'\b(\d{1,2})[-/](\d{1,2})[-/](\d{2,4})\b');

    for (var line in text.blocks.expand((b) => b.lines)) {
      final match = regex.firstMatch(line.text);
      if (match != null) {
        try {
          int p1 = int.parse(match.group(1)!);
          int p2 = int.parse(match.group(2)!);
          int p3 = int.parse(match.group(3)!);
          
          // Heuristic to determine d/m/y order
          // Assume dd/mm/yyyy if p1 > 12
          int day, month, year;
          if (p3 > 100) { // Year is last
             year = p3;
             if (p1 > 12) { day = p1; month = p2; }
             else { day = p2; month = p1; } // Ambiguous, assume mm/dd defaults
          } else {
             // Year is first? Or 2 digit year
             year = 2000 + p3; // Assume 20xx
             if (p1 > 12) { day = p1; month = p2; }
             else { day = p2; month = p1; }
          }

          final date = DateTime(year, month, day);
          if (date.isBefore(DateTime.now().add(const Duration(days: 1))) && 
              date.isAfter(DateTime(2020))) {
            dates.add(date);
          }
        } catch (_) {}
      }
    }
    return dates;
  }

  /// Predict category based on keywords
  String? _predictCategory(RecognizedText text) {
    final fullText = text.text.toUpperCase();

    final Map<String, List<String>> keywords = {
      'Food': ['COFFEE', 'CAFE', 'BURGER', 'PIZZA', 'RESTAURANT', 'DINER', 'KITCHEN', 'FOOD'],
      'Transport': ['FUEL', 'PETROL', 'DIESEL', 'PUMP', 'PARKING', 'UBER', 'OLA', 'TAXI'],
      'Groceries': ['MARKET', 'MART', 'SUPERCENTER', 'GROCERY', 'MILK', 'BREAD', 'FRESH'],
      'Health': ['PHARMACY', 'MEDICINE', 'HOSPITAL', 'CLINIC', 'DR.'],
      'Bills': ['ELECTRICITY', 'POWER', 'WATER', 'BILL', 'TEL', 'PHONE', 'INTERNET'],
      'Shopping': ['CLOTH', 'FASHION', 'MALL', 'STORE'],
    };

    for (var entry in keywords.entries) {
      for (var word in entry.value) {
        if (fullText.contains(word)) {
          return entry.key;
        }
      }
    }
    return null;
  }
}

