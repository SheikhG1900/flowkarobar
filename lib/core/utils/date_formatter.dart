import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

/// Utility class for centralized date formatting
class AppDateFormatter {
  /// Default date format pattern used in the app if not specified
  static const String defaultPattern = 'MMM dd, yyyy';

  /// Format a DateTime object to a string using the specified pattern
  /// If [pattern] is null, it uses the user's preferred date format from profile
  static String formatDate(DateTime date, {String? pattern}) {
    return DateFormat(pattern ?? defaultPattern).format(date);
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
  static String formatMonth(DateTime date, {BuildContext? context}) {
    if (context != null) {
      final locale = Localizations.localeOf(context).toString();
      return DateFormat.MMM(locale).format(date);
    }
    return DateFormat.MMM().format(date);
  }

  /// Format a DateTime object to month and year (e.g., Jan 2026)
  static String formatMonthYear(DateTime date, {BuildContext? context}) {
    if (context != null) {
      final locale = Localizations.localeOf(context).toString();
      return DateFormat.yMMMM(locale).format(date);
    }
    return DateFormat.yMMMM().format(date);
  }

  /// Get a DateFormat instance for custom needs
  static DateFormat getFormatter(String pattern) {
    return DateFormat(pattern);
  }

  /// Format a DateTime object to a relative time string (e.g., 2h ago)
  static String formatRelativeTime(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final l10n = AppLocalizations.of(context)!;

    if (difference.inSeconds < 60) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return formatMediumDate(date);
    }
  }
}
