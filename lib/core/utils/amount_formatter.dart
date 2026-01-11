/// Utility class for formatting amounts with dynamic font sizes
class AmountFormatter {
  /// Get the appropriate font size based on the amount's digit count
  /// Scales down for larger amounts to prevent layout overflow
  static double getFontSize(double amount, {double baseSize = 18.0}) {
    final amountString = amount.toStringAsFixed(2);
    // Count digits before decimal point
    final digitCount = amountString.split('.')[0].length;

    if (digitCount <= 3) {
      return baseSize; // 1-3 digits: normal size (e.g., ₹999.00)
    } else if (digitCount <= 5) {
      return baseSize * 0.89; // 4-5 digits: slightly smaller (e.g., ₹99,999.00)
    } else {
      return baseSize * 0.78; // 6+ digits: smallest (e.g., ₹999,999.00)
    }
  }

  /// Format amount with proper comma separation
  static String formatAmount(double amount) {
    final formatter = amount.toStringAsFixed(2);
    final parts = formatter.split('.');
    final intPart = parts[0];
    final decimalPart = parts[1];

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

    return '$result.$decimalPart';
  }

  /// Get formatted text with currency symbol
  static String formatWithCurrency(double amount, String currency) {
    return '$currency${formatAmount(amount)}';
  }
}
