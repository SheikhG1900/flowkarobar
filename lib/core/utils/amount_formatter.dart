/// Utility class for formatting amounts with dynamic font sizes
class AmountFormatter {
  /// Get the appropriate font size based on the amount's digit count
  /// Scales down for larger amounts to prevent layout overflow
  static double getFontSize(double amount,
      {double baseSize = 18.0, int decimalPlaces = 2}) {
    final amountString = amount.toStringAsFixed(decimalPlaces);
    // Count digits before decimal point
    final digitCount = amountString.split('.')[0].length;

    if (digitCount <= 3) {
      return baseSize; // 1-3 digits: normal size
    } else if (digitCount <= 5) {
      return baseSize * 0.89; // 4-5 digits: slightly smaller
    } else {
      return baseSize * 0.78; // 6+ digits: smallest
    }
  }

  /// Format amount with proper comma separation and specified decimal places
  static String formatAmount(double amount, int decimalPlaces, {double scaleFactor = 1.0}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs() / scaleFactor;
    final formatter = absAmount.toStringAsFixed(decimalPlaces);
    final parts = formatter.split('.');
    final intPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Add commas to integer part
    String result = '';
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result = ',$result';
      }
      result = intPart[i] + result;
      count++;
    }

    // Add decimal part if needed
    final formatted = decimalPlaces > 0 ? '$result.$decimalPart' : result;
    return isNegative ? '-$formatted' : formatted;
  }

  /// Format amount in compact form (e.g., 1K, 2M, 1.5B)
  static String formatCompactAmount(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    if (absAmount >= 1000000000) {
      final value = absAmount / 1000000000;
      return '${isNegative ? '-' : ''}${_formatCompactValue(value)}B';
    } else if (absAmount >= 1000000) {
      final value = absAmount / 1000000;
      return '${isNegative ? '-' : ''}${_formatCompactValue(value)}M';
    } else if (absAmount >= 1000) {
      final value = absAmount / 1000;
      return '${isNegative ? '-' : ''}${_formatCompactValue(value)}K';
    } else {
      return formatAmount(amount, 0);
    }
  }

  static String _formatCompactValue(double value) {
    if (value >= 10) {
      return value.toStringAsFixed(0);
    } else {
      final s = value.toStringAsFixed(1);
      if (s.endsWith('.0')) {
        return s.substring(0, s.length - 2);
      }
      return s;
    }
  }

  /// Get formatted text with currency symbol
  static String formatWithCurrency(
      double amount, String currency, int decimalPlaces,
      {bool isRtl = false, double scaleFactor = 1.0}) {
    final isNegative = amount < 0;
    final formattedAmount = formatAmount(amount.abs(), decimalPlaces, scaleFactor: scaleFactor);
    if (isRtl) {
      return isNegative
          ? '($formattedAmount $currency)'
          : '$formattedAmount $currency';
    }
    return isNegative
        ? '($currency$formattedAmount)'
        : '$currency$formattedAmount';
  }

  /// Units / quantity: no decimals when the value is a whole number; otherwise
  /// minimal decimal digits (trailing zeros stripped).
  static String formatQuantity(double quantity, {int maxDecimals = 8}) {
    if (quantity.isNaN || quantity.isInfinite) return '0';
    final isNegative = quantity < 0;
    final q = quantity.abs();
    final String body;
    if ((q - q.roundToDouble()).abs() < 1e-9) {
      body = q.round().toString();
    } else {
      var s = q.toStringAsFixed(maxDecimals);
      if (s.contains('.')) {
        s = s.replaceFirst(RegExp(r'0+$'), '');
        s = s.replaceFirst(RegExp(r'\.$'), '');
      }
      body = s;
    }
    return isNegative ? '-$body' : body;
  }
}
