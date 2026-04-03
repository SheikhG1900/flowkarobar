import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flowpaisa/core/entity_extraction/entity_extraction_base.dart';
import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';

/// Direction to search for the amount line relative to the label (below, above, or same line).
enum _SearchDirection { below, above, side }

// ---------------------------------------------------------------------------
// RECEIPT TOTAL AMOUNT EXTRACTION (OCR-based, no regex for amount discovery)
// ---------------------------------------------------------------------------
// We use the OCR structure (RecognizedText with blocks/lines and bounding boxes)
// to find a "total amount" label (e.g. Total, Dues, Payable) and then the
// numeric value on the same line, or on the line above/below.
// Amount value is parsed from the chosen line only (digits + decimal). No regex
// is used to search for amounts in the full text.
// ---------------------------------------------------------------------------

/// Labels that indicate a line contains (or is next to) the total amount.
/// Order matters: first match wins. We will consider more labels later.
const List<String> _totalAmountLabels = [
  'grand total',
  'total',
  'net amount',
  'amount due',
  'balance due',
  'due date',
  'dues',
  'payable',
  'subtotal',
  'net',
  'gross',
  'amount',
  'due',
];

/// Receipt-specific AI parser. Amount from OCR spatial extraction (label + same/above/below line)
/// or from ML Kit MoneyEntity only. No regex used to find or extract amount.
class ReceiptAiParser extends BaseTransactionAiParser {
  /// Stores all amounts discovered via OCR spatial logic to be used as candidates.
  final List<AmountCandidate> _ocrAmountCandidates = [];

  /// Parses receipt text. When [recognizedText] is provided, total amount is
  /// first tried via OCR spatial extraction (label above/below/same line), then
  /// fallback to ML Kit MoneyEntity.
  @override
  Future<ParsedTransactionInput?> parse(
    String text, {
    List<String>? customSymbols,
    RecognizedText? recognizedText,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('Receipt AI Parser: Starting extraction for text:\n $text');
      }

      _ocrAmountCandidates.clear();

      // Priority 1: If we have OCR structure, try to get total from label position (same/above/below line).
      double? amountFromOcr = recognizedText != null
          ? extractTotalFromReceipt(recognizedText)
          : null;
      if (kDebugMode) {
        debugPrint(
            '[ReceiptAmount] Amount from OCR (label+spatial): $amountFromOcr');
        debugPrint(
            '[ReceiptAmount] All OCR candidates: ${_ocrAmountCandidates.map((c) => "${c.label}: ${c.value}").toList()}');
      }

      final result = await extractEntitiesWithAnnotations(text);
      final mlKitAmounts = result.data['amount'] as List<double>;
      if (kDebugMode) {
        debugPrint(
            '[ReceiptAmount] ML Kit extracted amounts (all): $mlKitAmounts');
        _logMlKitAnnotations(result.annotations);
      }

      // Priority 2: ML Kit MoneyEntity (no regex for amount).
      final amountFromMl =
          _getBestAmountFromMoneyEntities(text, result.annotations);
      if (kDebugMode) {
        debugPrint(
            '[ReceiptAmount] Amount from ML (best MoneyEntity): $amountFromMl');
      }

      final bestAmount = amountFromOcr ?? amountFromMl;
      if (kDebugMode) {
        debugPrint(
            '[ReceiptAmount] Best amount chosen: $bestAmount (source: ${amountFromOcr != null ? "OCR" : "ML"})');
      }

      final parsed = _mapEntitiesToInput(
        result.data,
        text,
        customSymbols: customSymbols,
        preferredAmount: bestAmount,
        ocrCandidates: _ocrAmountCandidates,
      );

      if (kDebugMode) {
        debugPrint(
            '[ReceiptAmount] Final amountCandidates (for UI chips): ${parsed.amountCandidates.map((c) => "${c.label}: ${c.value}").toList()}');
        debugPrint(
            'Receipt AI Parser: Result amount=${parsed.amount}, category=${parsed.categoryName}');
      }
      return parsed;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Receipt AI Parser Error: $e');
      }
      return null;
    }
  }

  // =========================================================================
  // OCR-BASED TOTAL EXTRACTION (RecognizedText with bounding boxes)
  // =========================================================================
  // The total amount label can be:
  //   - On the same line as the amount (e.g. "Total    150.00")
  //   - Above the amount (e.g. "Total" on one line, "150.00" on the next)
  //   - Below the amount (e.g. "150.00" then "Total")
  // We search in that order: same line first, then below, then above.
  // =========================================================================

  /// Extracts the total amount from a scanned receipt using OCR structure.
  /// Finds lines containing [_totalAmountLabels], then the amount on
  /// the same line, or the nearest numeric line below or above. No regex is
  /// used to find amounts in the full text; only the chosen line is parsed.
  double? extractTotalFromReceipt(RecognizedText recognizedText) {
    if (kDebugMode) _logOcrResult(recognizedText);

    // -----------------------------------------------------------------------
    // Step 1: Find all lines that contain any total-amount label, prioritized
    // by the order of labels in [_totalAmountLabels].
    // -----------------------------------------------------------------------
    List<TextLine> labelLines = _findTotalLabelLines(recognizedText);
    if (kDebugMode) {
      debugPrint('[ReceiptOCR] Found ${labelLines.length} label lines');
    }
    if (labelLines.isEmpty) return null;

    double? firstBestAmount;

    const overlapMargin = 20.0;

    for (final labelLine in labelLines) {
      final labelRect = labelLine.boundingBox;
      final labelText = labelLine.text;

      // Per label occurrence: keep at most one nearest in each direction
      // (right, left, below, above) so max 4 values per occurrence.
      // Same label on multiple lines (e.g. split "Net" / "Amount") => 4 * N max.
      double? bestRight;
      double bestRightDist = double.infinity;
      double? bestLeft;
      double bestLeftDist = double.infinity;
      double? bestBelow;
      double? bestAbove;

      // ---- Right: same-line (distance 0) or side lines to the right of label ----
      if (_lineContainsDigit(labelText)) {
        final sameLineAmount = _parseAmountFromLine(labelText);
        if (kDebugMode) {
          debugPrint(
              '[ReceiptAmount] Same-line parse from "$labelText" -> $sameLineAmount');
        }
        if (sameLineAmount != null && sameLineAmount > 0) {
          bestRight = sameLineAmount;
          bestRightDist = 0.0;
        }
      }
      final sideCandidates = _findAllNumericLines(
        recognizedText,
        labelLine: labelLine,
        labelRect: labelRect,
        direction: _SearchDirection.side,
      );
      for (final line in sideCandidates) {
        final lineRect = line.boundingBox;
        final amount = _parseAmountFromLine(line.text);
        if (amount == null || amount <= 0) continue;
        // Right: line starts at or after label end
        if (lineRect.left >= labelRect.right - overlapMargin) {
          final dist = lineRect.left - labelRect.right;
          if (dist < bestRightDist) {
            bestRightDist = dist;
            bestRight = amount;
          }
        }
        // Left: line ends at or before label start
        if (lineRect.right <= labelRect.left + overlapMargin) {
          final dist = labelRect.left - lineRect.right;
          if (dist < bestLeftDist) {
            bestLeftDist = dist;
            bestLeft = amount;
          }
        }
      }

      // ---- Below: nearest one only ----
      final belowCandidates = _findAllNumericLines(
        recognizedText,
        labelLine: labelLine,
        labelRect: labelRect,
        direction: _SearchDirection.below,
      );
      if (belowCandidates.isNotEmpty) {
        belowCandidates.sort((a, b) => (a.boundingBox.top - labelRect.bottom)
            .compareTo(b.boundingBox.top - labelRect.bottom));
        final line = belowCandidates.first;
        bestBelow = _parseAmountFromLine(line.text);
        if (kDebugMode && bestBelow != null) {
          debugPrint(
              '[ReceiptAmount] Nearest below "$labelText": "${line.text}" -> $bestBelow');
        }
      }

      // ---- Above: nearest one only ----
      final aboveCandidates = _findAllNumericLines(
        recognizedText,
        labelLine: labelLine,
        labelRect: labelRect,
        direction: _SearchDirection.above,
      );
      if (aboveCandidates.isNotEmpty) {
        aboveCandidates.sort((a, b) => (labelRect.top - b.boundingBox.bottom)
            .compareTo(labelRect.top - a.boundingBox.bottom));
        final line = aboveCandidates.first;
        bestAbove = _parseAmountFromLine(line.text);
        if (kDebugMode && bestAbove != null) {
          debugPrint(
              '[ReceiptAmount] Nearest above "$labelText": "${line.text}" -> $bestAbove');
        }
      }

      // Add at most 4 candidates per label occurrence (dedupe by value)
      final valuesForThisLabel = <double>{};
      for (final value in [bestRight, bestLeft, bestBelow, bestAbove]) {
        if (value != null && value > 0 && valuesForThisLabel.add(value)) {
          if (!_ocrAmountCandidates.any((c) => c.value == value && c.label == labelText)) {
            _ocrAmountCandidates.add(AmountCandidate(value: value, label: labelText));
          }
          firstBestAmount ??= value;
        }
      }
    }

    return firstBestAmount;
  }

  /// Logs ML Kit entity annotations (text span and entity types/values) for review.
  void _logMlKitAnnotations(List<InternalEntityAnnotation> annotations) {
    debugPrint(
        '[ReceiptAmount] ML Kit annotations: ${annotations.length} span(s)');
    for (int i = 0; i < annotations.length; i++) {
      final a = annotations[i];
      final entitySummary = a.entities.map((e) {
        if (e.type == InternalEntityType.money) {
          final m = e as InternalMoneyEntity;
          final val = (m.integerPart).toDouble() + (m.fractionPart / 100.0);
          return 'Money($val)';
        }
        return '${e.type}';
      }).join(', ');
      debugPrint(
          '[ReceiptAmount]   [$i] "${a.text}" (start=${a.start} end=${a.end}) -> $entitySummary');
    }
  }

  /// Logs full OCR result (blocks, lines, text and bounding box per line) for review.
  void _logOcrResult(RecognizedText recognizedText) {
    debugPrint('[ReceiptOCR] ---------- OCR result ----------');
    debugPrint('[ReceiptOCR] Full text:\n${recognizedText.text}');
    debugPrint('[ReceiptOCR] Blocks: ${recognizedText.blocks.length}');
    for (int b = 0; b < recognizedText.blocks.length; b++) {
      final block = recognizedText.blocks[b];
      debugPrint(
          '[ReceiptOCR]   Block $b: "${block.text}" box=${block.boundingBox}');
      for (int l = 0; l < block.lines.length; l++) {
        final line = block.lines[l];
        final r = line.boundingBox;
        debugPrint(
            '[ReceiptOCR]     Line $l: "${line.text}" | box: L=${r.left.toStringAsFixed(0)} T=${r.top.toStringAsFixed(0)} R=${r.right.toStringAsFixed(0)} B=${r.bottom.toStringAsFixed(0)}');
      }
    }
    debugPrint('[ReceiptOCR] --------------------------------');
  }

  /// Finds all OCR lines whose text contains any of [_totalAmountLabels],
  /// prioritized by the order of labels in the list.
  List<TextLine> _findTotalLabelLines(RecognizedText recognizedText) {
    final List<TextLine> result = [];
    final lowerLabels = _totalAmountLabels;

    for (final label in lowerLabels) {
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final lineLower = line.text.toLowerCase().trim();
          if (lineLower.contains(label)) {
            if (!result.contains(line)) {
              result.add(line);
            }
          }
        }
      }
    }
    return result;
  }

  /// Finds all lines that contain a digit, in the given direction from the
  /// label, within vertical and horizontal margins.
  /// For BELOW/ABOVE search, it strictly enforces horizontal overlap (sharing
  /// the same X-coordinate space) with the label line.
  /// For SIDE search, it strictly enforces vertical overlap (sharing the same
  /// Y-coordinate space) with the label line.
  List<TextLine> _findAllNumericLines(
    RecognizedText recognizedText, {
    required TextLine labelLine,
    required Rect labelRect,
    required _SearchDirection direction,
  }) {
    final List<TextLine> candidates = [];
    const verticalMargin = 5.0;
    const maxVerticalDistance = 400.0;
    const maxHorizontalDistance = 600.0;

    // Error margins for overlap (to account for slight tilts)
    const overlapMargin = 20.0;

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        if (line == labelLine) continue;

        final text = line.text.trim();
        if (!_lineContainsDigit(text)) continue;

        // Skip lines that are only fraction/percentage (e.g. "3/100" or "2.5%"); 
        // keep lines that also have a clear amount (e.g. "3/100 Only. 2,239.63").
        if ((text.contains('/') || text.contains('%')) &&
            !RegExp(r'\d{1,3}(,\d{3})*\.\d{2}').hasMatch(text)) {
          continue;
        }

        // Additional check for pure percentage lines like "Adv./Tax 2.50%"
        if (text.endsWith('%') && !text.contains(RegExp(r'[a-zA-Z]'))) {
           continue;
        }

        final lineRect = line.boundingBox;

        if (direction == _SearchDirection.side) {
          // SIDE Search: Enforce vertical overlap (sharing Y-space)
          final bool hasVerticalOverlap =
              (lineRect.top < labelRect.bottom + overlapMargin) &&
                  (lineRect.bottom > labelRect.top - overlapMargin);

          if (hasVerticalOverlap) {
            // Also check if it's within a reasonable horizontal distance
            final double horizontalDist = (lineRect.left - labelRect.right).abs();
            if (horizontalDist <= maxHorizontalDistance) {
              candidates.add(line);
            }
          }
        } else {
          // BELOW/ABOVE Search: Enforce horizontal overlap (sharing X-space)
          bool isInDirection;
          if (direction == _SearchDirection.below) {
            final verticalDist = lineRect.top - labelRect.bottom;
            isInDirection = verticalDist >= -verticalMargin &&
                verticalDist <= maxVerticalDistance;
          } else {
            final verticalDist = labelRect.top - lineRect.bottom;
            isInDirection = verticalDist >= -verticalMargin &&
                verticalDist <= maxVerticalDistance;
          }

          if (!isInDirection) continue;

          final bool hasHorizontalOverlap =
              (lineRect.left < labelRect.right + overlapMargin) &&
                  (lineRect.right > labelRect.left - overlapMargin);

          if (hasHorizontalOverlap) {
            candidates.add(line);
          }
        }
      }
    }
    return candidates;
  }

  /// True if the string contains at least one digit (used to skip non-numeric lines).
  bool _lineContainsDigit(String text) {
    for (int i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) >= 0x30 && text.codeUnitAt(i) <= 0x39) return true;
    }
    return false;
  }

  /// Parses an amount from a single line. Keeps only digits and one decimal point.
  /// Handles "1,234.00", "Rs. 1234.00/-", and locales that use "1.200,00" (multiple dots).
  /// When the line has multiple number-like parts (e.g. "3/100 Only. 2,239.63"),
  /// tries the last amount-shaped segment so we pick 2,239.63 instead of mixing with 3/100.
  static double? _parseAmountFromLine(String text) {
    // 1. If the line contains a percentage (%), it's likely a tax rate or discount, not an amount.
    // We only ignore it if it doesn't also contain a clear amount-shaped pattern later.
    if (text.contains('%') &&
        !RegExp(r'\d{1,3}(,\d{3})*\.\d{2}').hasMatch(text.split('%').last)) {
      return null;
    }

    // 2. Try to find the most "amount-like" segment in the line first (Priority 1).
    // This handles lines like "115,00|" or "3/100 Only. 2,239.63" by isolating the numeric part.
    // Updated regex to match full numbers with separators without forcing 2-digit decimals.
    // This prevents partial matches like "1,17" from "1,170".
    final amountPattern = RegExp(r'\d+(?:[.,]\d+)*');
    final matches = amountPattern.allMatches(text);
    if (matches.isNotEmpty) {
      // Prioritize the last match as it's usually the total/result in a line.
      // Filter out matches that are too short to be a real amount (e.g. single digits)
      final validMatches = matches
          .map((m) => m.group(0)!)
          .where((s) => s.length >= 2 || RegExp(r'^\d$').hasMatch(s))
          .toList();

      if (validMatches.isNotEmpty) {
        final lastMatch = validMatches.last;
        final value = _normalizeAndParseAmount(lastMatch);
        if (value != null && value > 0 && value <= 1000000) return value;
      }
    }

    // 3. Fallback: Normalize the whole line if no specific amount pattern was found (Priority 2).
    return _normalizeAndParseAmount(text);
  }

  /// Normalizes digits/commas/dots and parses to double. Used by _parseAmountFromLine.
  static double? _normalizeAndParseAmount(String text) {
    // Reject strings containing % as they are likely rates, not amounts.
    if (text.contains('%')) return null;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final c = text[i];
      if (c == '.' ||
          c == ',' ||
          (c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39)) {
        buffer.write(c);
      }
    }
    String clean = buffer.toString();
    if (clean.isEmpty) return null;

    // 1. Identify the last separator (dot or comma)
    final lastDot = clean.lastIndexOf('.');
    final lastComma = clean.lastIndexOf(',');
    final lastSeparatorIndex = (lastDot > lastComma) ? lastDot : lastComma;

    if (lastSeparatorIndex != -1) {
      final remainingAfterSeparator = clean.substring(lastSeparatorIndex + 1);

      // 2. Check if the last separator looks like a decimal (followed by exactly 2 digits)
      if (remainingAfterSeparator.length == 2 &&
          RegExp(r'^\d{2}$').hasMatch(remainingAfterSeparator)) {
        // This is a decimal separator.
        // Remove all other separators before it.
        final prefix = clean.substring(0, lastSeparatorIndex);
        final cleanPrefix = prefix.replaceAll('.', '').replaceAll(',', '');
        clean = '$cleanPrefix.$remainingAfterSeparator';
      } else {
        // Not a decimal separator (likely a thousands separator like 2,300,00 or noise).
        // If there are multiple commas/dots, it's almost certainly thousands separators.
        // We remove all of them.
        clean = clean.replaceAll('.', '').replaceAll(',', '');
      }
    } else {
      // No separators at all.
      clean = clean.replaceAll('.', '').replaceAll(',', '');
    }

    final value = double.tryParse(clean);
    if (value == null || value <= 0 || value > 1000000) return null;
    return value;
  }

  // =========================================================================
  // ML KIT ENTITY EXTRACTION (MoneyEntity only — no regex for amount)
  // =========================================================================
  // Used when OCR spatial extraction returns null (e.g. no label found, or
  // no RecognizedText provided). We only use MoneyEntity from annotations;
  // we do not search the full text with regex for amount patterns.
  // =========================================================================

  /// Prefers MoneyEntity on the same logical line as "total" (by character offset),
  /// then the first MoneyEntity anywhere. Uses annotation.start to map to line index.
  double? _getBestAmountFromMoneyEntities(
      String rawText, List<InternalEntityAnnotation> annotations) {
    if (annotations.isEmpty) return null;

    final lines = rawText.split(RegExp(r'[\n\r]+'));
    if (lines.isEmpty) return null;

    final lineStarts = <int>[0];
    for (final line in lines) {
      lineStarts.add(lineStarts.last + line.length + 1);
    }

    int lineIndexFor(int pos) {
      for (int i = 0; i < lineStarts.length - 1; i++) {
        if (pos < lineStarts[i + 1]) return i;
      }
      return lines.length.clamp(0, lines.length - 1);
    }

    final labelPattern = RegExp(
      r'\b(total|net\s+amount|grand\s+total|amount\s+due|balance\s+due|dues|payable|subtotal)\b',
      caseSensitive: false,
    );
    int totalLineIndex = -1;
    for (int i = 0; i < lines.length; i++) {
      if (labelPattern.hasMatch(lines[i])) {
        totalLineIndex = i;
        break;
      }
    }

    bool isOnTotalLineOrNext(int lineIndex) {
      if (totalLineIndex < 0) return false;
      return lineIndex >= totalLineIndex && lineIndex <= totalLineIndex + 1;
    }

    double? fromMoney(InternalMoneyEntity e) {
      final val = (e.integerPart).toDouble() + (e.fractionPart / 100.0);
      if (val > 0 && val <= 1000000) return val;
      return null;
    }

    // 1) MoneyEntity on total label line or the line after it.
    for (final annotation in annotations) {
      final lineIndex = lineIndexFor(annotation.start);
      if (!isOnTotalLineOrNext(lineIndex)) continue;
      for (final entity in annotation.entities) {
        if (entity.type == InternalEntityType.money) {
          final amount = fromMoney(entity as InternalMoneyEntity);
          if (amount != null) return amount;
        }
      }
    }

    // 2) First MoneyEntity anywhere.
    for (final annotation in annotations) {
      for (final entity in annotation.entities) {
        if (entity.type == InternalEntityType.money) {
          final amount = fromMoney(entity as InternalMoneyEntity);
          if (amount != null) return amount;
        }
      }
    }

    return null;
  }

  // =========================================================================
  // MAPPING TO ParsedTransactionInput (receipt-specific)
  // =========================================================================
  // No regex is used to add amount candidates from the full text; candidates
  // come only from ML Kit extracted data (and preferredAmount if set).
  // =========================================================================

  ParsedTransactionInput _mapEntitiesToInput(
    Map<String, dynamic> extracted,
    String originalText, {
    List<String>? customSymbols,
    double? preferredAmount,
    List<AmountCandidate>? ocrCandidates,
  }) {
    double? amount;
    String? category;

    final List<double> mlKitAmounts = extracted['amount'] as List<double>;
    final List<DateTime> mlKitDates = extracted['date'] as List<DateTime>;
    final List<AmountCandidate> amountCandidates = [
      ...mlKitAmounts.map((v) => AmountCandidate(value: v)),
    ];

    if (ocrCandidates != null) {
      for (final c in ocrCandidates) {
        if (!amountCandidates.any((a) => a.value == c.value)) {
          amountCandidates.add(c);
        }
      }
    }

    if (preferredAmount != null) {
      amount = preferredAmount;
      if (!amountCandidates.any((c) => c.value == preferredAmount)) {
        amountCandidates.add(AmountCandidate(value: preferredAmount));
      }
    }
    if (amount == null && amountCandidates.isNotEmpty) {
      final reasonable = amountCandidates
          .where((c) => c.value <= 100000)
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (reasonable.isNotEmpty) {
        amount = reasonable.first.value;
      } else {
        amountCandidates.sort((a, b) => b.value.compareTo(a.value));
        amount = amountCandidates.first.value;
      }
    }

    final categoryKeywords = {
      'Food': ['COFFEE', 'CAFE', 'BURGER', 'PIZZA', 'RESTAURANT', 'DINER', 'KITCHEN', 'FOOD', 'DINNER', 'LUNCH', 'BREAKFAST'],
      'Transport': ['FUEL', 'PETROL', 'DIESEL', 'PUMP', 'PARKING', 'UBER', 'OLA', 'TAXI', 'TRAVEL'],
      'Groceries': ['MARKET', 'MART', 'SUPERCENTER', 'GROCERY', 'MILK', 'BREAD', 'FRESH'],
      'Health': ['PHARMACY', 'MEDICINE', 'HOSPITAL', 'CLINIC', 'DR.'],
      'Bills': ['ELECTRICITY', 'POWER', 'WATER', 'BILL', 'TEL', 'PHONE', 'INTERNET'],
      'Shopping': ['CLOTH', 'FASHION', 'MALL', 'STORE', 'SHOPPING'],
      'Salary': ['SALARY', 'BONUS', 'PROFIT'],
      'Rent': ['RENT'],
      'Gift': ['GIFT'],
    };

    for (var entry in categoryKeywords.entries) {
      for (var word in entry.value) {
        if (originalText.toUpperCase().contains(word)) {
          category = entry.key;
          break;
        }
      }
      if (category != null) break;
    }

    // Dedupe by value, keep first (OCR/labeled preferred when order preserved).
    final seen = <double>{};
    final uniqueCandidates = amountCandidates
        .where((c) => seen.add(c.value))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final descriptionCandidates = _descriptionCandidatesFromText(originalText);

    return ParsedTransactionInput(
      amount: amount,
      type: "EXPENSE",
      categoryName: category,
      contactName: null,
      paidRelationship: null,
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
        t.length > _maxDescLen ? '${t.substring(0, _maxDescLen)}...' : t,
      );
    }

    final noise = RegExp(
      r'^(RECEIPT|INVOICE|TAX|TOTAL|SUBTOTAL|DATE|TIME|QTY|ITEM|AMOUNT|CASH|CARD|THANK|VISIT|#|\d+\s*[xX]\s*|\d+\.\d{2})\s*$',
      caseSensitive: false,
    );
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
