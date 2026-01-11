import 'dart:ui';

/// Utility class to detect currency from system locale
/// This is independent of the app's language setting
class CurrencyDetector {
  /// Detect currency code from device's system locale
  /// Returns ISO 4217 currency code (USD, INR, PKR)
  static String detectCurrencyCodeFromLocale() {
    // Get system locale (not app language)
    final locale = PlatformDispatcher.instance.locale;
    final countryCode = locale.countryCode;

    print('🌍 CurrencyDetector: Detected locale: ${locale.toString()}');
    print('🌍 CurrencyDetector: Country code: $countryCode');

    // Map country codes to currency codes
    String currencyCode;
    switch (countryCode) {
      case 'US': // United States
      case 'CA': // Canada
        currencyCode = 'USD';
        break;
      case 'IN': // India
        currencyCode = 'INR';
        break;
      case 'PK': // Pakistan
        currencyCode = 'PKR';
        break;
      default:
        // Fallback to US Dollar for unmapped countries
        currencyCode = 'USD';
    }

    print('💰 CurrencyDetector: Selected currency code: $currencyCode');
    return currencyCode;
  }

  /// Get a human-readable description of the detected locale
  static String getLocaleDescription() {
    final locale = PlatformDispatcher.instance.locale;
    return '${locale.languageCode}_${locale.countryCode ?? 'UNKNOWN'}';
  }
}
