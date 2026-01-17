import 'package:flutter/material.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ScheduleListItem extends ConsumerWidget {
  final TransactionSchedule schedule;
  final VoidCallback onToggle;

  const ScheduleListItem({
    super.key,
    required this.schedule,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = ref.watch(currentCurrencyProvider).value;
    final isExpense = schedule.type == 'EXPENSE';

    if (currency == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isExpense ? AppColors.expenseColor : AppColors.incomeColor)
              .withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isExpense ? AppColors.expenseColor : AppColors.incomeColor)
                .withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: isExpense
                ? AppColors.expenseGradient
                : AppColors.incomeGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.schedule,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          schedule.description ?? (isExpense ? 'Expense' : 'Income'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildSchedulePatternDisplay(theme),
            if (schedule.startDate != null || schedule.endDate != null) ...[
              const SizedBox(height: 4),
              Text(
                _getDateRangeText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        trailing: SizedBox(
          height: 56,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    '${isExpense ? '-' : '+'} ${AmountFormatter.formatWithCurrency(schedule.amount, currency.symbol, currency.decimalPlaces)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isExpense
                          ? AppColors.expenseColor
                          : AppColors.incomeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // Chip-style toggle for active/inactive
                ActionChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        schedule.isPaused
                            ? Icons.pause_circle
                            : Icons.check_circle,
                        size: 14,
                        color: schedule.isPaused
                            ? theme.colorScheme.onSurfaceVariant
                            : AppColors.brightCyan,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.isPaused ? 'Inactive' : 'Active',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () => onToggle(),
                  backgroundColor: !schedule.isPaused
                      ? AppColors.brightCyan.withValues(alpha: 0.2)
                      : null,
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: -4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  labelStyle: TextStyle(
                    color: schedule.isPaused
                        ? theme.colorScheme.onSurfaceVariant
                        : AppColors.brightCyan,
                    fontWeight: FontWeight.normal,
                    fontSize: 10,
                  ),
                  side: BorderSide(
                    color: !schedule.isPaused
                        ? AppColors.brightCyan
                        : theme.dividerColor,
                    width: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSchedulePatternDisplay(ThemeData theme) {
    switch (schedule.scheduleType) {
      case 'DAILY':
        return Text(
          'Daily',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      case 'WEEKLY':
        if (schedule.selectedDaysOfWeek != null) {
          final days = _parseDaysOfWeek(schedule.selectedDaysOfWeek!);
          if (days.isEmpty) {
            return Text(
              'Weekly',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            );
          }
          return Row(
            children: [
              Text(
                '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              ...List.generate(7, (index) {
                final isSelected = days.contains(index);
                final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    dayLabels[index],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppColors.brightCyan
                          : theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ],
          );
        }
        return Text(
          'Weekly',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      case 'MONTHLY':
        if (schedule.selectedDaysOfMonth != null) {
          final days = _parseDaysOfMonth(schedule.selectedDaysOfMonth!);
          if (days.isEmpty) {
            return Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Monthly',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          }
          return Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                days.join(', '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Monthly',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      default:
        return Text(
          'Unknown',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
    }
  }

  String _getDateRangeText() {
    final parts = <String>[];
    if (schedule.startDate != null) {
      parts.add('From: ${DateFormat.yMMMd().format(schedule.startDate!)}');
    }
    if (schedule.endDate != null) {
      parts.add('To: ${DateFormat.yMMMd().format(schedule.endDate!)}');
    }
    return parts.join(' | ');
  }

  List<int> _parseDaysOfWeek(String jsonString) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => e as int).toList();
    } catch (e) {
      return [];
    }
  }

  List<int> _parseDaysOfMonth(String jsonString) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((e) => e as int).toList();
    } catch (e) {
      return [];
    }
  }
}
