import 'package:flutter/material.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/models/date_range_state.dart';

/// Standard date range selector (Month / Quarter / Year / Custom) with prev/next.
/// Used in analytics and in transaction/payable/receivable filters.
class DateRangeSelector extends StatelessWidget {
  /// Currently selected range. Null means \"no date filter\".
  final DateRangeState? selectedDateRange;

  /// Callback when range changes. Null means \"no date filter\".
  final Function(DateRangeState?) onDateRangeChanged;
  final VoidCallback onNextPeriod;
  final VoidCallback onPreviousPeriod;
  final Color? accentColor;

  const DateRangeSelector({
    super.key,
    required this.selectedDateRange,
    required this.onDateRangeChanged,
    required this.onNextPeriod,
    required this.onPreviousPeriod,
    this.accentColor,
  });

  String _getDisplayText(BuildContext context, AppLocalizations l10n) {
    if (selectedDateRange == null) {
      return l10n.allTime;
    }
    switch (selectedDateRange!.type) {
      case DateRangeType.month:
        return AppDateFormatter.formatMonthYear(selectedDateRange!.startDate,
            context: context);
      case DateRangeType.quarter:
        final quarter = ((selectedDateRange!.startDate.month - 1) ~/ 3) + 1;
        return 'Q$quarter ${AppDateFormatter.getFormatter('y').format(selectedDateRange!.startDate)}';
      case DateRangeType.year:
        return AppDateFormatter.getFormatter('y')
            .format(selectedDateRange!.startDate);
      case DateRangeType.custom:
        return '${AppDateFormatter.formatDate(selectedDateRange!.startDate)} - ${AppDateFormatter.formatDate(selectedDateRange!.endDate)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final color = accentColor ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RangeTypeChip(
                label: l10n.month,
                isSelected:
                    selectedDateRange?.type == DateRangeType.month,
                accentColor: color,
                onTap: () {
                  if (selectedDateRange?.type == DateRangeType.month) {
                    // Toggle off
                    onDateRangeChanged(null);
                  } else {
                    onDateRangeChanged(DateRangeState.currentMonth());
                  }
                },
              ),
              const SizedBox(width: 8),
              _RangeTypeChip(
                label: l10n.quarter,
                isSelected:
                    selectedDateRange?.type == DateRangeType.quarter,
                accentColor: color,
                onTap: () {
                  if (selectedDateRange?.type == DateRangeType.quarter) {
                    onDateRangeChanged(null);
                  } else {
                    final now = DateTime.now();
                    final currentQuarter = ((now.month - 1) ~/ 3) + 1;
                    onDateRangeChanged(
                        DateRangeState.quarter(now.year, currentQuarter));
                  }
                },
              ),
              const SizedBox(width: 8),
              _RangeTypeChip(
                label: l10n.year,
                isSelected:
                    selectedDateRange?.type == DateRangeType.year,
                accentColor: color,
                onTap: () {
                  if (selectedDateRange?.type == DateRangeType.year) {
                    onDateRangeChanged(null);
                  } else {
                    onDateRangeChanged(
                        DateRangeState.year(DateTime.now().year));
                  }
                },
              ),
              const SizedBox(width: 8),
              _RangeTypeChip(
                label: l10n.custom,
                isSelected:
                    selectedDateRange?.type == DateRangeType.custom,
                accentColor: color,
                onTap: () async {
                  if (selectedDateRange?.type == DateRangeType.custom) {
                    onDateRangeChanged(null);
                    return;
                  }
                  final now = DateTime.now();
                  final initialStart =
                      selectedDateRange?.startDate ??
                          DateTime(now.year, now.month, 1);
                  final initialEnd =
                      selectedDateRange?.endDate ??
                          DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDateRange: DateTimeRange(
                      start: initialStart,
                      end: initialEnd,
                    ),
                  );
                  if (picked != null) {
                    onDateRangeChanged(
                        DateRangeState.custom(picked.start, picked.end));
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: selectedDateRange != null &&
                        selectedDateRange!.type != DateRangeType.custom
                    ? onPreviousPeriod
                    : null,
              ),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getDisplayText(context, l10n),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: selectedDateRange != null &&
                        selectedDateRange!.type != DateRangeType.custom
                    ? onNextPeriod
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RangeTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  const _RangeTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
