import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flowpaisa/core/entity_extraction/entity_extraction_base.dart';
import 'package:flowpaisa/features/transactions/domain/models/parsed_transaction_input.dart';

/// Direction to search for the amount line relative to the label (below or above).
enum _SearchDirection { below, above }

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
  'total',
  'grand total',
  'net amount',
  'amount due',
  'balance due',
  'due date',
  'dues',
  'payable',
  'subtotal',
  'net',
  'amount',
  'due',
];

/// Receipt-specific AI parser. Amount from OCR spatial extraction (label + same/above/below line)
/// or from ML Kit MoneyEntity only. No regex used to find or extract amount.
class ReceiptAiParser extends BaseTransactionAiParser {
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
        debugPrint('Receipt AI Parser: Starting extraction for text: $text');
        debugPrint('Receipt AI Parser: Raw Input Text:\n$text');
      }

      // Priority 1: If we have OCR structure, try to get total from label position (same/above/below line).
      double? amountFromOcr = recognizedText != null
          ? extractTotalFromReceipt(recognizedText)
          : null;
      if (kDebugMode) {
        debugPrint('[ReceiptAmount] Amount from OCR (label+spatial): $amountFromOcr');
      }

      final result = await extractEntitiesWithAnnotations(text);
      final mlKitAmounts = result.data['amount'] as List<double>;
      if (kDebugMode) {
        debugPrint('[ReceiptAmount] ML Kit extracted amounts (all): $mlKitAmounts');
        _logMlKitAnnotations(result.annotations);
      }

      // Priority 2: ML Kit MoneyEntity (no regex for amount).
      final amountFromMl = _getBestAmountFromMoneyEntities(text, result.annotations);
      if (kDebugMode) {
        debugPrint('[ReceiptAmount] Amount from ML (best MoneyEntity): $amountFromMl');
      }

      final bestAmount = amountFromOcr ?? amountFromMl;
      if (kDebugMode) {
        debugPrint('[ReceiptAmount] Best amount chosen: $bestAmount (source: ${amountFromOcr != null ? "OCR" : "ML"})');
      }

      final parsed = _mapEntitiesToInput(
        result.data,
        text,
        customSymbols: customSymbols,
        preferredAmount: bestAmount,
      );

      if (kDebugMode) {
        debugPrint('[ReceiptAmount] Final amountCandidates (for UI chips): ${parsed.amountCandidates}');
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
  /// Finds a line containing one of [_totalAmountLabels], then the amount on
  /// the same line, or the nearest numeric line below or above. No regex is
  /// used to find amounts in the full text; only the chosen line is parsed.
  double? extractTotalFromReceipt(RecognizedText recognizedText) {
    if (kDebugMode) _logOcrResult(recognizedText);

    // -----------------------------------------------------------------------
    // Step 1: Find the first line that contains any total-amount label.
    // -----------------------------------------------------------------------
    TextLine? labelLine = _findTotalLabelLine(recognizedText);
    if (kDebugMode) {
      debugPrint('[ReceiptOCR] Label line: ${labelLine != null ? "\"${labelLine.text}\" (box: ${labelLine.boundingBox})" : "none"}');
    }
    if (labelLine == null) return null;

    // -----------------------------------------------------------------------
    // Step 2: Same line — if the label line already contains a digit, the
    // amount is likely on the same line (e.g. "Total: Rs 1,234.00").
    // -----------------------------------------------------------------------
    double? sameLineAmount;
    if (_lineContainsDigit(labelLine.text)) {
      sameLineAmount = _parseAmountFromLine(labelLine.text);
      if (kDebugMode) {
        debugPrint('[ReceiptAmount] Same-line parse from "${labelLine.text}" -> $sameLineAmount');
      }
      if (sameLineAmount != null && sameLineAmount > 0) return sameLineAmount;
    }

    final labelRect = labelLine.boundingBox;

    // -----------------------------------------------------------------------
    // Step 3: Look for the closest numeric line BELOW the label.
    // (Most receipts have "Total" above the amount.)
    // -----------------------------------------------------------------------
    final below = _findNearestNumericLine(
      recognizedText,
      labelLine: labelLine,
      labelRect: labelRect,
      direction: _SearchDirection.below,
    );
    double? belowAmount;
    if (below != null) {
      belowAmount = _parseAmountFromLine(below.text);
      if (kDebugMode) {
        debugPrint('[ReceiptAmount] Below line: "${below.text}" -> $belowAmount');
      }
      if (belowAmount != null && belowAmount > 0) return belowAmount;
    }

    // -----------------------------------------------------------------------
    // Step 4: Look for the closest numeric line ABOVE the label.
    // (Some receipts show the amount first, then "Total" below.)
    // -----------------------------------------------------------------------
    final above = _findNearestNumericLine(
      recognizedText,
      labelLine: labelLine,
      labelRect: labelRect,
      direction: _SearchDirection.above,
    );
    double? aboveAmount;
    if (above != null) {
      aboveAmount = _parseAmountFromLine(above.text);
      if (kDebugMode) {
        debugPrint('[ReceiptAmount] Above line: "${above.text}" -> $aboveAmount');
      }
      if (aboveAmount != null && aboveAmount > 0) return aboveAmount;
    }

    if (kDebugMode) {
      debugPrint('[ReceiptAmount] OCR extraction: no amount (same=$sameLineAmount, below=$belowAmount, above=$aboveAmount)');
    }
    return null;
  }

  /// Logs ML Kit entity annotations (text span and entity types/values) for review.
  void _logMlKitAnnotations(List<EntityAnnotation> annotations) {
    debugPrint('[ReceiptAmount] ML Kit annotations: ${annotations.length} span(s)');
    for (int i = 0; i < annotations.length; i++) {
      final a = annotations[i];
      final entitySummary = a.entities.map((e) {
        if (e.type == EntityType.money) {
          final m = e as MoneyEntity;
          final val = (m.integerPart).toDouble() + (m.fractionPart / 100.0);
          return 'Money($val)';
        }
        return '${e.type}';
      }).join(', ');
      debugPrint('[ReceiptAmount]   [$i] "${a.text}" (start=${a.start} end=${a.end}) -> $entitySummary');
    }
  }

  /// Logs full OCR result (blocks, lines, text and bounding box per line) for review.
  void _logOcrResult(RecognizedText recognizedText) {
    debugPrint('[ReceiptOCR] ---------- OCR result ----------');
    debugPrint('[ReceiptOCR] Full text:\n${recognizedText.text}');
    debugPrint('[ReceiptOCR] Blocks: ${recognizedText.blocks.length}');
    for (int b = 0; b < recognizedText.blocks.length; b++) {
      final block = recognizedText.blocks[b];
      debugPrint('[ReceiptOCR]   Block $b: "${block.text}" box=${block.boundingBox}');
      for (int l = 0; l < block.lines.length; l++) {
        final line = block.lines[l];
        final r = line.boundingBox;
        debugPrint('[ReceiptOCR]     Line $l: "${line.text}" | box: L=${r.left.toStringAsFixed(0)} T=${r.top.toStringAsFixed(0)} R=${r.right.toStringAsFixed(0)} B=${r.bottom.toStringAsFixed(0)}');
      }
    }
    debugPrint('[ReceiptOCR] --------------------------------');
  }

  /// Finds the first OCR line whose text contains any of [_totalAmountLabels].
  TextLine? _findTotalLabelLine(RecognizedText recognizedText) {
    final lowerLabels = _totalAmountLabels;
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final lineLower = line.text.toLowerCase().trim();
        for (final label in lowerLabels) {
          if (lineLower.contains(label)) return line;
        }
      }
    }
    return null;
  }

  /// Finds the nearest line that contains a digit, either below or above the
  /// label, and roughly horizontally aligned (same column). Uses bounding
  /// box distance; small overlap allowed for messy scans.
  TextLine? _findNearestNumericLine(
    RecognizedText recognizedText, {
    required TextLine labelLine,
    required Rect labelRect,
    required _SearchDirection direction,
  }) {
    TextLine? nearest;
    double minDistance = double.infinity;

    const verticalMargin = 5.0;
    const horizontalMarginRight = 100.0;
    const horizontalMarginLeft = 20.0;

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        if (line == labelLine) continue;
        if (!_lineContainsDigit(line.text)) continue;

        final lineRect = line.boundingBox;

        // Vertical check: line must be below (or above) the label.
        final bool isInDirection = direction == _SearchDirection.below
            ? lineRect.top >= labelRect.bottom - verticalMargin
            : lineRect.bottom <= labelRect.top + verticalMargin;

        // Horizontal check: roughly same column (allow some shift).
        final bool isHorizontallyNear = lineRect.left < labelRect.right + horizontalMarginRight &&
            lineRect.right > labelRect.left - horizontalMarginLeft;

        if (!isInDirection || !isHorizontallyNear) continue;

        final double dist = direction == _SearchDirection.below
            ? lineRect.top - labelRect.bottom
            : labelRect.top - lineRect.bottom;
        if (dist < minDistance && dist >= -verticalMargin) {
          minDistance = dist;
          nearest = line;
        }
      }
    }
    return nearest;
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
  static double? _parseAmountFromLine(String text) {
    // Keep only digits and decimal separators.
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final c = text[i];
      if (c == '.' || c == ',' || (c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39)) {
        buffer.write(c);
      }
    }
    String clean = buffer.toString();
    if (clean.isEmpty) return null;

    // Normalize: 
    // 1. If comma is followed by exactly 3 digits, it's a thousands separator (e.g., 1,280)
    final thousandsRegExp = RegExp(r',(\d{3})(?!\d)');
    if (thousandsRegExp.hasMatch(clean)) {
      clean = clean.replaceAll(',', '');
    }

    // 2. Handle remaining commas
    final dotCount = '.'.allMatches(clean).length;
    final commaCount = ','.allMatches(clean).length;
    if (dotCount == 0 && commaCount == 1) {
      // If exactly one comma and no dot, check if it looks like a decimal (e.g., 12,50)
      if (RegExp(r',\d{2}$').hasMatch(clean)) {
        clean = clean.replaceAll(',', '.');
      } else {
        clean = clean.replaceAll(',', '');
      }
    } else {
      clean = clean.replaceAll(',', '');
    }

    // Multiple dots (e.g. "1.200.00"): keep last dot as decimal, others as thousand separators.
    if ('.'.allMatches(clean).length > 1) {
      final lastDot = clean.lastIndexOf('.');
      clean = clean.substring(0, lastDot).replaceAll('.', '') + clean.substring(lastDot);
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
  double? _getBestAmountFromMoneyEntities(String rawText, List<EntityAnnotation> annotations) {
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

    double? fromMoney(MoneyEntity e) {
      final val = (e.integerPart).toDouble() + (e.fractionPart / 100.0);
      if (val > 0 && val <= 1000000) return val;
      return null;
    }

    // 1) MoneyEntity on total label line or the line after it.
    for (final annotation in annotations) {
      final lineIndex = lineIndexFor(annotation.start);
      if (!isOnTotalLineOrNext(lineIndex)) continue;
      for (final entity in annotation.entities) {
        if (entity.type == EntityType.money) {
          final amount = fromMoney(entity as MoneyEntity);
          if (amount != null) return amount;
        }
      }
    }

    // 2) First MoneyEntity anywhere.
    for (final annotation in annotations) {
      for (final entity in annotation.entities) {
        if (entity.type == EntityType.money) {
          final amount = fromMoney(entity as MoneyEntity);
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
  }) {
    double? amount;
    String? category;

    final List<double> mlKitAmounts = extracted['amount'] as List<double>;
    final List<DateTime> mlKitDates = extracted['date'] as List<DateTime>;
    List<double> amountCandidates = List.from(mlKitAmounts);

    final lowerText = originalText.toLowerCase();

    if (preferredAmount != null) {
      amount = preferredAmount;
      if (!amountCandidates.contains(preferredAmount)) {
        amountCandidates.add(preferredAmount);
      }
    }
    if (amount == null && amountCandidates.isNotEmpty) {
      final reasonableAmounts =
          amountCandidates.where((a) => a <= 100000).toList();
      if (reasonableAmounts.isNotEmpty) {
        reasonableAmounts.sort((a, b) => b.compareTo(a));
        amount = reasonableAmounts.first;
      } else {
        amountCandidates.sort((a, b) => b.compareTo(a));
        amount = amountCandidates.first;
      }
    }

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
    for (var kw in categoryKeywords) {
      if (lowerText.contains(kw)) {
        category = kw;
        break;
      }
    }

    final uniqueCandidates = amountCandidates.toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    final descriptionCandidates =
        _descriptionCandidatesFromText(originalText);

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
