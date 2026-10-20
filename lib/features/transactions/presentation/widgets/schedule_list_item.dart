import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_account_icon_badge.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/contact_solid_pill.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
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

class ScheduleListItem extends ConsumerStatefulWidget {
  final ScheduleWithDetails item;

  const ScheduleListItem({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<ScheduleListItem> createState() => _ScheduleListItemState();
}

class _ScheduleListItemState extends ConsumerState<ScheduleListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final schedule = item.schedule;
    final category = item.category;
    final contact = item.contact;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currency = ref.watch(currentCurrencyProvider).value;
    final isDark = theme.brightness == Brightness.dark;
    final isExpense = schedule.type == 'EXPENSE';

    final isPremium = ref.watch(premiumProvider).isPremium;
    final isLocked = !isPremium && (schedule.addSeq ?? 0) > PremiumGate.scheduleTotalLimit;

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

    final key = widget.key;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            key: widget.key,
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: isInactive ? 0.6 : 1.0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? displayColor
                  : displayColor.withValues(alpha: isDark ? 0.2 : 0.1),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Material(
              key: widget.key != null
                  ? ValueKey('${(widget.key as ValueKey).value}-material')
                  : null,
              color: Colors.transparent,
              child: InkWell(
                key: widget.key != null
                    ? ValueKey('${(widget.key as ValueKey).value}-inkwell')
                    : null,
                onHover: (hovering) {
                  setState(() {
                    _isHovered = hovering;
                  });
                },
                hoverColor: Colors.transparent,
                onTap: () {
                  if (isLocked) {
                    PremiumGate.showPremiumDialog(context);
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScheduleDetailsDialog(
                        scheduleUuid: schedule.uuid,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(19),
                child: Padding(
                  key: widget.key != null
                      ? ValueKey('${(widget.key as ValueKey).value}-padding')
                      : null,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    key: widget.key != null
                        ? ValueKey('${(widget.key as ValueKey).value}-row')
                        : null,
                    children: [
                      // Leading
                      Container(
                        key: widget.key != null
                            ? ValueKey('${(widget.key as ValueKey).value}-leading')
                            : null,
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
                      const SizedBox(width: 16),
                      // Title & Subtitle
                      Expanded(
                        key: widget.key != null
                            ? ValueKey(
                                '${(widget.key as ValueKey).value}-content-expanded')
                            : null,
                        child: Column(
                          key: widget.key != null
                              ? ValueKey('${(widget.key as ValueKey).value}-content-col')
                              : null,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            key: key != null
                                ? ValueKey('${(key as ValueKey).value}-title')
                                : null,
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
                          const SizedBox(height: 4),
                          Text(
                            key: key != null
                                ? ValueKey('${(key as ValueKey).value}-desc')
                                : null,
                            schedule.description ??
                                (isExpense ? l10n.expense : l10n.income),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: isInactive ? 0.5 : 1.0),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (contact != null) ...[
                            const SizedBox(height: 8),
                            ContactSolidPill(
                              key: key != null
                                  ? ValueKey('${(key as ValueKey).value}-contact-tag')
                                  : null,
                              contactName: contact.name,
                              textKey: key != null
                                  ? ValueKey('${(key as ValueKey).value}-contact-name')
                                  : null,
                              isCompact: false,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Trailing
                    Column(
                      key: key != null
                          ? ValueKey('${(key as ValueKey).value}-trailing-col')
                          : null,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Frequency badge above amount
                        Container(
                          key: key != null
                              ? ValueKey(
                                  '${(key as ValueKey).value}-freq-badge')
                              : null,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            key: key != null
                                ? ValueKey(
                                    '${(key as ValueKey).value}-freq-row')
                                : null,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                key: key != null
                                    ? ValueKey(
                                        '${(key as ValueKey).value}-freq-icon')
                                    : null,
                                _getFrequencyIcon(schedule.scheduleType),
                                size: 10,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                key: key != null
                                    ? ValueKey(
                                        '${(key as ValueKey).value}-freq-label')
                                    : null,
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
                        const SizedBox(height: 4),
                        FittedBox(
                          key: key != null
                              ? ValueKey(
                                  '${(key as ValueKey).value}-amount-fitted')
                              : null,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            key: key != null
                                ? ValueKey(
                                    '${(key as ValueKey).value}-amount-text')
                                : null,
                            '${isExpense ? '\u200E-' : '\u200E+'} ${AmountFormatter.formatWithCurrency(schedule.amount, currency.symbol, currency.decimalPlaces)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isExpense
                                  ? (isInactive
                                      ? AppColors.expenseColor
                                          .withValues(alpha: 0.5)
                                      : AppColors.expenseColor)
                                  : (isInactive
                                      ? AppColors.incomeColor
                                          .withValues(alpha: 0.5)
                                      : AppColors.incomeColor),
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  AmountFormatter.getFontSize(schedule.amount),
                            ),
                          ),
                        ),
                        if (schedule.paidRelationship != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            key: key != null
                                ? ValueKey('${(key as ValueKey).value}-rel-badge')
                                : null,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.getRelationshipColor(
                                      schedule.paidRelationship)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.getRelationshipColor(
                                        schedule.paidRelationship)
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              key: key != null
                                  ? ValueKey(
                                      '${(key as ValueKey).value}-rel-text')
                                  : null,
                              LocalizationHelper.localizeRelationshipShort(
                                l10n,
                                schedule.paidRelationship,
                                isExpense: isExpense,
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.getRelationshipColor(
                                    schedule.paidRelationship),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (isInactive) ...[
                          const SizedBox(height: 4),
                          Text(
                            key: key != null
                                ? ValueKey(
                                    '${(key as ValueKey).value}-inactive-text')
                                : null,
                            l10n.inactive,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color:
                                  theme.colorScheme.error.withValues(alpha: 0.7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
        if (item.account != null)
          TransactionAccountIconBadge(
            key: key != null
                ? ValueKey('${(key as ValueKey).value}-acc-badge')
                : null,
            account: item.account!,
            theme: theme,
            isInactive: isInactive,
          ),
      ],
    ),
    );
  }

  static IconData _getFrequencyIcon(String type) {
    switch (type) {
      case 'DAILY':
        return Icons.today;
      case 'WEEKLY':
        return Icons.date_range;
      case 'MONTHLY':
        return Icons.calendar_month;
      default:
        return Icons.repeat;
    }
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
