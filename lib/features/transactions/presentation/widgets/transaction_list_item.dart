import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_details_dialog.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/schedule_icon_badge.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/split_icon_badge.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_account_icon_badge.dart';

class TransactionListItem extends ConsumerWidget {
  final TransactionWithDetails item;
  final Widget? leadingOverride;
  final String? titleOverride;
  final VoidCallback? onTap;
  final bool isCompact;
  final bool isHighlighted;

  const TransactionListItem({
    super.key,
    required this.item,
    this.leadingOverride,
    this.titleOverride,
    this.onTap,
    this.isCompact = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;
    final isDark = theme.brightness == Brightness.dark;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final transaction = item.transaction;
    final category = item.category;
    final contact = item.contact;
    final l10n = AppLocalizations.of(context)!;
    final isExpense = transaction.type == 'EXPENSE';

    // Dull display for any transaction not yet processed (processedDate == null)
    final isInactive = transaction.processedDate == null;

    // Resolve category color
    Color categoryColor;
    if (category?.color != null) {
      try {
        categoryColor = Color(int.parse(category!.color!.replaceAll('#', '0xFF')));
      } catch (_) {
        categoryColor = isExpense ? AppColors.expenseColor : AppColors.incomeColor;
      }
    } else {
      categoryColor = isExpense ? AppColors.expenseColor : AppColors.incomeColor;
    }

    // Apply dull effect if inactive
    final displayColor = isInactive ? categoryColor.withValues(alpha: 0.5) : categoryColor;
    final textColor = isInactive
        ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
        : theme.colorScheme.onSurface;

    // Dynamic font size based on amount
    double amountFontSize = AmountFormatter.getFontSize(transaction.amount);
    if (isCompact) {
      amountFontSize = (amountFontSize * 0.85).clamp(12.0, 24.0);
    }

    final linkedGroupId = transaction.linkedGroupId;
    final showSplitBadge = linkedGroupId != null && linkedGroupId.isNotEmpty;
    final account = item.account;

    return Stack(
      key: ValueKey('tx-card-stack-${transaction.uuid}'),
      clipBehavior: Clip.none,
      children: [
        Container(
          key: ValueKey('tx-card-container-${transaction.uuid}'),
          decoration: BoxDecoration(
            color: isHighlighted 
                ? displayColor.withValues(alpha: isDark ? 0.15 : 0.05)
                : theme.cardColor.withValues(alpha: isInactive ? 0.6 : 1.0),
            borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
            border: Border.all(
              color: isHighlighted 
                  ? displayColor 
                  : displayColor.withValues(alpha: isDark ? 0.2 : 0.1),
              width: isHighlighted ? 2 : 1,
            ),
            boxShadow: (isCompact || isHighlighted) ? null : [
              BoxShadow(
                color: displayColor.withValues(alpha: isDark ? 0.05 : 0.08),
                blurRadius: isInactive ? 4 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: ListTile(
              key: ValueKey('tx-card-listtile-${transaction.uuid}'),
              contentPadding: EdgeInsets.all(isCompact ? 12 : 16),
              leading: leadingOverride ??
                  Container(
                    key: ValueKey('tx-card-icon-${transaction.uuid}'),
                    width: isCompact ? 40 : 50,
                    height: isCompact ? 40 : 50,
                    decoration: BoxDecoration(
                      color: displayColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isCompact ? 10 : 14),
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
                key: ValueKey('tx-card-title-${transaction.uuid}'),
                titleOverride ??
                    (category != null
                        ? LocalizationHelper.getLocalizedCategoryName(
                            context, category.name)
                        : l10n.uncategorized),
                style: (isCompact ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                key: ValueKey('tx-card-subtitle-col-${transaction.uuid}'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    key: ValueKey('tx-card-desc-${transaction.uuid}'),
                    transaction.description ??
                        (isExpense ? l10n.expense : l10n.income),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: isInactive ? 0.5 : 1.0),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Contact tag
                  if (contact != null) ...[
                    SizedBox(height: isCompact ? 4 : 6),
                    Container(
                      key: ValueKey('tx-card-contact-${transaction.uuid}'),
                      padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 4 : 6, 
                          vertical: isCompact ? 2 : 3),
                      decoration: BoxDecoration(
                        color: AppColors.getContactColor(contact.name).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.getContactColor(contact.name).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        key: ValueKey('tx-card-contact-row-${transaction.uuid}'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            key: ValueKey('tx-card-contact-avatar-${transaction.uuid}'),
                            width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            gradient: AppColors.getContactGradient(contact.name),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            key: ValueKey('tx-card-contact-initial-${transaction.uuid}'),
                            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            key: ValueKey('tx-card-contact-name-${transaction.uuid}'),
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
              key: ValueKey('tx-card-trailing-${transaction.uuid}'),
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  key: ValueKey('tx-card-amount-${transaction.uuid}'),
                  '${isExpense ? '\u200E-' : '\u200E+'} ${AmountFormatter.formatWithCurrency(transaction.amount, currency!)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isExpense
                        ? (isInactive ? AppColors.expenseColor.withValues(alpha: 0.5) : AppColors.expenseColor)
                        : (isInactive ? AppColors.incomeColor.withValues(alpha: 0.5) : AppColors.incomeColor),
                    fontWeight: FontWeight.bold,
                    fontSize: amountFontSize,
                  ),
                ),
                // Show status badge
                if (transaction.paidRelationship != null) ...[
                  SizedBox(height: isCompact ? 2 : 4),
                  Container(
                    key: ValueKey('tx-card-status-${transaction.uuid}'),
                    padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 4 : 6, 
                        vertical: isCompact ? 1 : 2),
                    decoration: BoxDecoration(
                      color: AppColors.getRelationshipColor(transaction.paidRelationship!)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.getRelationshipColor(transaction.paidRelationship!)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      key: ValueKey('tx-card-status-row-${transaction.uuid}'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.isLinkedEntryMarked) ...[
                          Icon(
                            key: ValueKey('tx-card-status-icon-${transaction.uuid}'),
                            Icons.check_circle,
                            size: isCompact ? 8 : 10,
                            color: AppColors.getRelationshipColor(transaction.paidRelationship!),
                          ),
                          SizedBox(width: isCompact ? 2 : 3),
                        ],
                        Text(
                          key: ValueKey('tx-card-status-text-${transaction.uuid}'),
                          _getStatusLabel(
                            l10n,
                            transaction.paidRelationship!,
                            item.isLinkedEntryMarked,
                            isExpense: transaction.type == 'EXPENSE',
                          ),
                          style: TextStyle(
                            fontSize: isCompact ? 8 : 10,
                            color: AppColors.getRelationshipColor(transaction.paidRelationship!),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Show "Auto" badge
                if (transaction.isAutoGenerated == true) ...[
                  SizedBox(height: isCompact ? 2 : 4),
                  Container(
                    key: ValueKey('tx-card-auto-${transaction.uuid}'),
                    padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 4 : 6, 
                        vertical: isCompact ? 1 : 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      key: ValueKey('tx-card-auto-row-${transaction.uuid}'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          key: ValueKey('tx-card-auto-icon-${transaction.uuid}'),
                          Icons.auto_awesome,
                          size: isCompact ? 8 : 10,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: isCompact ? 2 : 3),
                        Flexible(
                          child: Text(
                            key: ValueKey('tx-card-auto-text-${transaction.uuid}'),
                            l10n.autoBadge,
                            style: TextStyle(
                              fontSize: isCompact ? 8 : 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
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
            onTap: onTap ?? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetailsDialog(transactionUuid: transaction.uuid),
                ),
              );
            },
          ),
        ),),
        // Schedule icon badge
        if (transaction.isScheduled == true)
          ScheduleIconBadge(key: ValueKey('tx-card-sched-badge-${transaction.uuid}')),
        // Split icon badge
        if (showSplitBadge)
          SplitIconBadge(key: ValueKey('tx-card-split-badge-${transaction.uuid}'), groupId: linkedGroupId!),
        // Account icon badge
        if (account != null)
          TransactionAccountIconBadge(
            key: ValueKey('tx-card-acc-badge-${transaction.uuid}'),
            account: account,
            theme: theme,
            isInactive: isInactive,
          ),
      ],
    );
  }

  String _getStatusLabel(
    AppLocalizations l10n,
    String relationship,
    bool isMarked, {
    required bool isExpense,
  }) {
    if (isMarked) {
      switch (relationship.toUpperCase()) {
        case 'PAID_FOR':
        case 'WILL_RECEIVE':
          return l10n.receivedTag;
        case 'PAID_BY':
        case 'RECEIVED_FROM':
          return l10n.paidTag;
      }
    }
    return LocalizationHelper.localizeRelationshipShort(
      l10n,
      relationship,
      isExpense: isExpense,
    );
  }
}
