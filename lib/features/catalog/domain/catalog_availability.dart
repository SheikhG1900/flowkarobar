import 'package:flowpaisa/core/database/database.dart';

/// Whether a catalog may be used for new sales.
abstract final class CatalogAvailability {
  /// Calendar date only (local), ignoring time-of-day / UTC offset noise.
  static DateTime calendarDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Not deleted and [Catalog.validUntil] is null or today-or-later
  /// (same day-boundary rule as the catalogs list UI).
  static bool isActive(Catalog catalog, {DateTime? now}) {
    if (catalog.isDeleted) return false;
    final until = catalog.validUntil;
    if (until == null) return true;
    final n = now ?? DateTime.now();
    final today = calendarDay(n);
    final untilDay = calendarDay(until);
    return !untilDay.isBefore(today);
  }

  static bool isExpired(Catalog catalog, {DateTime? now}) {
    if (catalog.isDeleted) return false;
    final until = catalog.validUntil;
    if (until == null) return false;
    final n = now ?? DateTime.now();
    return calendarDay(until).isBefore(calendarDay(n));
  }
}

/// Status of a sale order line vs its catalog snapshot refs.
enum SaleCatalogLineIssue {
  /// No catalog ref, or catalog item + catalog still valid.
  none,

  /// Line pointed at a catalog item that is missing or soft-deleted.
  catalogItemUnavailable,

  /// Parent catalog missing or soft-deleted.
  catalogDeleted,

  /// Parent catalog past [Catalog.validUntil].
  catalogExpired,
}

extension SaleCatalogLineIssueX on SaleCatalogLineIssue {
  bool get isProblem => this != SaleCatalogLineIssue.none;
}
