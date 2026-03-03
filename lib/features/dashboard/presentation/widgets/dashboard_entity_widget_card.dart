import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/features/dashboard/domain/dashboard_widget_models.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_widget_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_details_dialog.dart';
import 'package:flowpaisa/features/payables/presentation/widgets/payable_details_dialog.dart';
import 'package:flowpaisa/features/receivables/presentation/widgets/receivable_details_dialog.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contact_details_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/category_details_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';

/// A single entity widget card on the dashboard. Shows key info and opens detail on tap.
/// Long-press to remove from dashboard.
class DashboardEntityWidgetCard extends ConsumerWidget {
  final DashboardWidgetConfig config;
  final int layoutIndex;

  const DashboardEntityWidgetCard({
    super.key,
    required this.config,
    required this.layoutIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (!config.kind.isEntity || config.entityUuid == null) {
      return const SizedBox.shrink();
    }
    final uuid = config.entityUuid!;

    switch (config.kind) {
      case DashboardWidgetKind.transaction:
        final async = ref.watch(transactionWithDetailsProvider(uuid));
        return async.when(
          data: (item) {
            if (item == null) return const SizedBox.shrink();
            final isExpense = item.transaction.type == 'EXPENSE';
            final cat = item.category;
            final txColor = cat != null && cat.color != null
                ? Color(int.parse(
                    cat.color!.replaceAll('#', '0xFF')))
                : (isExpense
                    ? AppColors.expenseColor
                    : AppColors.incomeColor);
            Widget? leadingChild;
            if (cat != null) {
              leadingChild = Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: txColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: CategoryHelper.buildCategoryIcon(
                    cat.icon, txColor, isExpense, size: 20),
              );
            }
            return _buildCard(
              context,
              ref,
              theme,
              l10n,
              currency,
              kind: config.kind,
              leadingChild: leadingChild,
              title: item.transaction.description?.isNotEmpty == true
                  ? item.transaction.description!
                  : (cat?.name ?? l10n.transactionDetails),
              subtitle: AppDateFormatter.formatDate(item.transaction.date),
              amount: item.transaction.amount,
              isExpense: isExpense,
              color: AppColors.transactionsSectionColor,
              onTap: () => _openTransaction(context, uuid),
              onRemove: () => _removeAt(ref, layoutIndex),
            );
          },
          loading: () => _buildCardPlaceholder(theme),
          error: (_, __) => const SizedBox.shrink(),
        );
      case DashboardWidgetKind.category:
        final async = ref.watch(categoryStatisticsProvider(uuid));
        return async.when(
          data: (stats) {
            final cat = stats.category;
            final isExpense = cat.type == 'EXPENSE';
            final color = cat.color != null
                ? Color(int.parse(
                    cat.color!.replaceAll('#', '0xFF')))
                : (isExpense ? AppColors.expenseColor : AppColors.incomeColor);
            return _buildCard(
              context,
              ref,
              theme,
              l10n,
              currency,
              kind: config.kind,
              leadingChild: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: CategoryHelper.buildCategoryIcon(
                    cat.icon, color, isExpense, size: 22),
              ),
              title: LocalizationHelper.getLocalizedCategoryName(
                  context, cat.name),
              subtitle: '${stats.transactionCount} ${l10n.transactions}',
              amount: stats.totalAmount,
              isExpense: isExpense,
              color: color,
              onTap: () => _openCategory(context, uuid),
              onRemove: () => _removeAt(ref, layoutIndex),
            );
          },
          loading: () => _buildCardPlaceholder(theme),
          error: (_, __) => const SizedBox.shrink(),
        );
      case DashboardWidgetKind.contact:
        final async = ref.watch(contactStatisticsProvider(uuid));
        return async.when(
          data: (stats) {
            final net = stats.netBalance;
            return _buildCard(
              context,
              ref,
              theme,
              l10n,
              currency,
              kind: config.kind,
              leadingChild: _buildContactAvatar(stats.contact.name),
              title: stats.contact.name,
              subtitle: net >= 0 ? l10n.receivableTag : l10n.payableTag,
              amount: net.abs(),
              isExpense: net < 0,
              color: net >= 0
                  ? AppColors.receivableColor
                  : AppColors.payableColor,
              amountColor: net >= 0
                  ? AppColors.receivableColor
                  : AppColors.payableColor,
              onTap: () => _openContact(context, uuid),
              onRemove: () => _removeAt(ref, layoutIndex),
            );
          },
          loading: () => _buildCardPlaceholder(theme),
          error: (_, __) => const SizedBox.shrink(),
        );
      case DashboardWidgetKind.payable:
        final async = ref.watch(payableWithLinkedDataProvider(uuid));
        return async.when(
          data: (item) {
            if (item == null) return const SizedBox.shrink();
            final contactName = item.contact?.name ?? '';
            return _buildCard(
              context,
              ref,
              theme,
              l10n,
              currency,
              kind: config.kind,
              leadingChild: contactName.isNotEmpty
                  ? _buildContactAvatar(contactName)
                  : null,
              title: item.contact?.name ?? l10n.payable,
              subtitle: item.payable.dueDate != null
                  ? AppDateFormatter.formatDate(
                      item.payable.dueDate!)
                  : item.payable.status,
              amount: item.payable.amount,
              isExpense: true,
              color: AppColors.payableColor,
              amountColor: AppColors.payableColor,
              onTap: () => _openPayable(context, uuid),
              onRemove: () => _removeAt(ref, layoutIndex),
            );
          },
          loading: () => _buildCardPlaceholder(theme),
          error: (_, __) => const SizedBox.shrink(),
        );
      case DashboardWidgetKind.receivable:
        final async = ref.watch(receivableWithLinkedDataProvider(uuid));
        return async.when(
          data: (item) {
            if (item == null) return const SizedBox.shrink();
            final contactName = item.contact?.name ?? '';
            return _buildCard(
              context,
              ref,
              theme,
              l10n,
              currency,
              kind: config.kind,
              leadingChild: contactName.isNotEmpty
                  ? _buildContactAvatar(contactName)
                  : null,
              title: item.contact?.name ?? l10n.receivableTag,
              subtitle: item.receivable.dueDate != null
                  ? AppDateFormatter.formatDate(
                      item.receivable.dueDate!)
                  : item.receivable.status,
              amount: item.receivable.amount,
              isExpense: false,
              color: AppColors.receivableColor,
              amountColor: AppColors.receivableColor,
              onTap: () => _openReceivable(context, uuid),
              onRemove: () => _removeAt(ref, layoutIndex),
            );
          },
          loading: () => _buildCardPlaceholder(theme),
          error: (_, __) => const SizedBox.shrink(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  static Widget _buildContactAvatar(String name) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: AppColors.getContactGradient(name),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    dynamic currency, {
    required DashboardWidgetKind kind,
    Widget? leadingChild,
    required String title,
    required String subtitle,
    required double amount,
    required bool isExpense,
    required Color color,
    Color? amountColor,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final effectiveAmountColor = amountColor ??
        (isExpense ? AppColors.expenseColor : AppColors.incomeColor);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showRemoveSheet(context, ref, onRemove, l10n),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                  color: color.withValues(alpha: 0.4), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                leadingChild ??
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _iconForKind(kind),
                        color: color,
                        size: 22,
                      ),
                    ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (currency != null)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${isExpense ? '\u200E−' : '\u200E+'} ${AmountFormatter.formatWithCurrency(amount, currency.symbol, currency.decimalPlaces)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: effectiveAmountColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForKind(DashboardWidgetKind kind) {
    switch (kind) {
      case DashboardWidgetKind.transaction:
        return Icons.receipt_long;
      case DashboardWidgetKind.category:
        return Icons.category_outlined;
      case DashboardWidgetKind.contact:
        return Icons.person_outline;
      case DashboardWidgetKind.payable:
        return Icons.call_made;
      case DashboardWidgetKind.receivable:
        return Icons.call_received;
      default:
        return Icons.widgets_outlined;
    }
  }

  Widget _buildCardPlaceholder(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  void _showRemoveSheet(
      BuildContext context, WidgetRef ref, VoidCallback onRemove,
      AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.push_pin),
          title: Text(l10n.unpinFromDashboard),
          onTap: () {
            Navigator.pop(context);
            onRemove();
          },
        ),
      ),
    );
  }

  Future<void> _removeAt(WidgetRef ref, int index) async {
    await ref.read(dashboardWidgetLayoutProvider.notifier).removeAt(index);
  }

  void _openTransaction(BuildContext context, String uuid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailsDialog(transactionUuid: uuid),
      ),
    );
  }

  void _openCategory(BuildContext context, String uuid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailsScreen(categoryUuid: uuid),
      ),
    );
  }

  void _openContact(BuildContext context, String uuid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailsScreen(contactUuid: uuid),
      ),
    );
  }

  void _openPayable(BuildContext context, String uuid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayableDetailsDialog(payableUuid: uuid),
      ),
    );
  }

  void _openReceivable(BuildContext context, String uuid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceivableDetailsDialog(receivableUuid: uuid),
      ),
    );
  }
}
