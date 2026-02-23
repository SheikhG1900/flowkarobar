// Shared date range model used by analytics, filters, and category details.

enum DateRangeType {
  month,
  quarter,
  year,
  custom,
}

class DateRangeState {
  final DateTime startDate;
  final DateTime endDate;
  final DateRangeType type;

  DateRangeState({
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  DateRangeState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    DateRangeType? type,
  }) {
    return DateRangeState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
    );
  }

  factory DateRangeState.currentMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return DateRangeState(
        startDate: start, endDate: end, type: DateRangeType.month);
  }

  factory DateRangeState.month(DateTime date) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    return DateRangeState(
        startDate: start, endDate: end, type: DateRangeType.month);
  }

  factory DateRangeState.quarter(int year, int quarter) {
    final startMonth = (quarter - 1) * 3 + 1;
    final start = DateTime(year, startMonth, 1);
    final end = DateTime(year, startMonth + 3, 0, 23, 59, 59);
    return DateRangeState(
        startDate: start, endDate: end, type: DateRangeType.quarter);
  }

  factory DateRangeState.year(int year) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59);
    return DateRangeState(
        startDate: start, endDate: end, type: DateRangeType.year);
  }

  factory DateRangeState.custom(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return DateRangeState(
        startDate: startDate, endDate: endDate, type: DateRangeType.custom);
  }

  /// Infer a DateRangeState from nullable start/end (e.g. from filter model).
  /// Returns null when no date filter is applied.
  static DateRangeState? fromDates(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    final startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    final startMonth = DateTime(startDate.year, startDate.month, 1);
    final endOfMonth =
        DateTime(startDate.year, startDate.month + 1, 0, 23, 59, 59);
    if (startDate == startMonth && endDate == endOfMonth) {
      return DateRangeState.month(startDate);
    }
    final q = ((startDate.month - 1) ~/ 3) + 1;
    final quarterStart = DateTime(startDate.year, (q - 1) * 3 + 1, 1);
    final quarterEnd =
        DateTime(startDate.year, (q - 1) * 3 + 4, 0, 23, 59, 59);
    if (startDate == quarterStart && endDate == quarterEnd) {
      return DateRangeState.quarter(startDate.year, q);
    }
    final yearStart = DateTime(startDate.year, 1, 1);
    final yearEnd = DateTime(startDate.year, 12, 31, 23, 59, 59);
    if (startDate == yearStart && endDate == yearEnd) {
      return DateRangeState.year(startDate.year);
    }
    return DateRangeState.custom(startDate, endDate);
  }
}
