/// Utility class for formatting amounts with dynamic font sizes
class AmountFormatter {
  /// Get the appropriate font size based on the amount's digit count
  /// Scales down for larger amounts to prevent layout overflow
  static double getFontSize(double amount, {double baseSize = 18.0, int decimalPlaces = 2}) {
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
  static String formatAmount(double amount, int decimalPlaces) {
    final formatter = amount.toStringAsFixed(decimalPlaces);
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
    if (decimalPlaces > 0) {
      return '$result.$decimalPart';
    } else {
      return result;
    }
  }

  /// Get formatted text with currency symbol
  static String formatWithCurrency(double amount, String currency, int decimalPlaces) {
    return '$currency${formatAmount(amount, decimalPlaces)}';
  }
}
