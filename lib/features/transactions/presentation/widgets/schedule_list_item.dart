import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/schedule_details_dialog.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class ScheduleListItem extends ConsumerWidget {
  final ScheduleWithDetails item;

  const ScheduleListItem({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = item.schedule;
    final category = item.category;
    final contact = item.contact;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currency = ref.watch(currentCurrencyProvider).value;
    final isDark = theme.brightness == Brightness.dark;
    final isExpense = schedule.type == 'EXPENSE';

    if (currency == null) return const SizedBox.shrink();

    final isInactive = schedule.isPaused;

    // Resolve category color
    Color categoryColor;
    if (category?.color != null) {
      try {
        categoryColor =
            Color(int.parse(category!.color!.replaceAll('#', '0xFF')));
      } catch (_) {
        categoryColor =
            isExpense ? AppColors.expenseColor : AppColors.incomeColor;
      }
    } else {
      categoryColor =
          isExpense ? AppColors.expenseColor : AppColors.incomeColor;
    }

    // Apply dull effect if inactive
    final displayColor =
        isInactive ? categoryColor.withValues(alpha: 0.5) : categoryColor;
    final textColor = isInactive
        ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
        : theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isInactive ? 0.6 : 1.0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: displayColor.withValues(alpha: isDark ? 0.2 : 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: displayColor.withValues(alpha: isDark ? 0.05 : 0.08),
            blurRadius: isInactive ? 4 : 12,
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
            color: displayColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: displayColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: CategoryHelper.buildCategoryIcon(
              category?.icon, displayColor, isExpense),
        ),
        title: Text(
          category != null
              ? LocalizationHelper.getLocalizedCategoryName(
                  context, category.name)
              : l10n.uncategorized,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.description ?? (isExpense ? l10n.expense : l10n.income),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: isInactive ? 0.5 : 1.0),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Frequency Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.repeat,
                    size: 10,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getFrequencyLabel(l10n, schedule.scheduleType),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (contact != null) ...[
              const SizedBox(height: 4),
              // Contact tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.getContactColor(contact.name)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.getContactColor(contact.name)
                        .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: AppColors.getContactGradient(contact.name),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        contact.name.isNotEmpty
                            ? contact.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        contact.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isExpense ? '\u200E-' : '\u200E+'} ${AmountFormatter.formatWithCurrency(schedule.amount, currency.symbol, currency.decimalPlaces)}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isExpense
                    ? (isInactive
                        ? AppColors.expenseColor.withValues(alpha: 0.5)
                        : AppColors.expenseColor)
                    : (isInactive
                        ? AppColors.incomeColor.withValues(alpha: 0.5)
                        : AppColors.incomeColor),
                fontWeight: FontWeight.bold,
                fontSize: AmountFormatter.getFontSize(schedule.amount),
              ),
            ),
            if (isInactive) ...[
              const SizedBox(height: 4),
              Text(
                l10n.inactive,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.error.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleDetailsDialog(
                scheduleUuid: schedule.uuid,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getFrequencyLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case 'DAILY':
        return l10n.daily;
      case 'WEEKLY':
        return l10n.weekly;
      case 'MONTHLY':
        return l10n.monthly;
      default:
        return type;
    }
  }
}
