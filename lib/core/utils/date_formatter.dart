import 'package:intl/intl.dart';

/// Utility class for centralized date formatting
class AppDateFormatter {
  /// Default date format pattern used in the app if not specified
  static const String defaultPattern = 'MMM dd, yyyy';

  /// Format a DateTime object to a string using the specified pattern
  /// If [pattern] is null, it uses [defaultPattern]
  static String formatDate(DateTime date, {String? pattern}) {
    if (pattern == null) {
      return formatMediumDate(date);
    }
    return DateFormat(pattern).format(date);
  }

  /// Format a DateTime object to a medium date string (e.g., Jan 18, 2026)
  static String formatMediumDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Format a DateTime object to include time (e.g., Jan 18, 2026, 10:30 AM)
  static String formatDateTime(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  /// Format a DateTime object for file names (e.g., 20260118_103000)
  static String formatForFileName(DateTime date) {
    return DateFormat('yyyyMMdd_HHmmss').format(date);
  }

  /// Format a DateTime object to just the month name (e.g., Jan)
  static String formatMonth(DateTime date) {
    return DateFormat.MMM().format(date);
  }

  /// Format a DateTime object to month and year (e.g., Jan 2026)
  static String formatMonthYear(DateTime date) {
    return DateFormat.yMMMM().format(date);
  }

  /// Get a DateFormat instance for custom needs
  static DateFormat getFormatter(String pattern) {
    return DateFormat(pattern);
  }
}
