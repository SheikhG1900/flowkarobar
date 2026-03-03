import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/dashboard/domain/dashboard_widget_models.dart';
import 'package:flowpaisa/features/dashboard/domain/models.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_widget_provider.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contacts_list_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/categories_list_screen.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/receivables_list_screen.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/receivables/domain/models.dart';
import 'package:flowpaisa/features/payables/presentation/screens/payables_list_screen.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A summary-type widget card on the dashboard (balance, cash flow, receivables, etc.).
class DashboardSummaryWidgetCard extends ConsumerWidget {
  final DashboardWidgetConfig config;
  final int layoutIndex;
  final Key? reorderKey;

  const DashboardSummaryWidgetCard({
    super.key,
    required this.config,
    required this.layoutIndex,
    this.reorderKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (config.kind.isEntity) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;
    final filter = ref.watch(dashboardFilterProvider);

    switch (config.kind) {
      case DashboardWidgetKind.balance:
        return _buildFromStats(
          context,
          ref,
          theme,
          l10n,
          currency,
          filter,
          title: l10n.availableCash,
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.dashboardSectionColor,
          builder: (stats) => AmountFormatter.formatWithCurrency(
              stats.totalBalance, currency!.symbol, currency.decimalPlaces),
          onTap: () {},
          onRemove: () => _removeAt(ref, layoutIndex),
          reorderKey: reorderKey,
        );
      case DashboardWidgetKind.cashFlow:
        return _buildFromStats(
          context,
          ref,
          theme,
          l10n,
          currency,
          filter,
          title: l10n.cashFlow,
          icon: Icons.trending_up,
          color: AppColors.incomeColor,
          builder: (stats) => AmountFormatter.formatWithCurrency(
              stats.netCash(filter), currency!.symbol, currency.decimalPlaces),
          onTap: () => _openTransactionsFiltered(ref, context, filter),
          onRemove: () => _removeAt(ref, layoutIndex),
          reorderKey: reorderKey,
        );
      case DashboardWidgetKind.receivablesSummary:
        return _buildFromStats(
          context,
          ref,
          theme,
          l10n,
          currency,
          filter,
          title: l10n.receivableTag,
          icon: Icons.call_received,
          color: AppColors.receivableColor,
          builder: (stats) => AmountFormatter.formatWithCurrency(
              stats.receivable(filter), currency!.symbol, currency.decimalPlaces),
          onTap: () => _openReceivables(ref, context, filter),
          onRemove: () => _removeAt(ref, layoutIndex),
          reorderKey: reorderKey,
        );
      case DashboardWidgetKind.payablesSummary:
        return _buildFromStats(
          context,
          ref,
          theme,
          l10n,
          currency,
          filter,
          title: l10n.payableTag,
          icon: Icons.call_made,
          color: AppColors.payableColor,
          builder: (stats) => AmountFormatter.formatWithCurrency(
              stats.payable(filter), currency!.symbol, currency.decimalPlaces),
          onTap: () => _openPayables(ref, context, filter),
          onRemove: () => _removeAt(ref, layoutIndex),
          reorderKey: reorderKey,
        );
      case DashboardWidgetKind.contactsSummary:
        return _buildCountCard(
          context,
          ref,
          theme,
          l10n,
          title: l10n.contacts,
          icon: Icons.people_outline,
          color: theme.colorScheme.primary,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactsListScreen())),
          onRemove: () => _removeAt(ref, layoutIndex),
          reorderKey: reorderKey,
        );
      case DashboardWidgetKind.categoriesSummary:
        return _buildCategoriesCountCard(
          context,
          ref,
          theme,
          l10n,
          onRemove: () => _removeAt(ref, layoutIndex),
          reorderKey: reorderKey,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFromStats(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    dynamic currency,
    DashboardFilter filter, {
    required String title,
    required IconData icon,
    required Color color,
    required String Function(DashboardStats stats) builder,
    String Function(DashboardStats stats)? subtitle,
    required VoidCallback onTap,
    required VoidCallback onRemove,
    Key? reorderKey,
  }) {
    final async = ref.watch(dashboardStatsProvider);
    return async.when(
      data: (stats) => _buildSummaryCard(
        context,
        ref,
        theme,
        l10n,
        title: title,
        subtitle: subtitle != null ? subtitle(stats) : null,
        amountLabel: builder(stats),
        icon: icon,
        color: color,
        onTap: onTap,
        onRemove: onRemove,
        reorderKey: reorderKey,
      ),
      loading: () => _buildCardPlaceholder(theme, reorderKey),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n, {
    required String title,
    String? subtitle,
    required String amountLabel,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required VoidCallback onRemove,
    Key? reorderKey,
  }) {
    return _wrapCard(
      reorderKey: reorderKey,
      child: Padding(
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
                border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: color, size: 22),
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
                        if (subtitle != null) ...[
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
                      ],
                    ),
                  ),
                  Text(
                    amountLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required VoidCallback onRemove,
    Key? reorderKey,
  }) {
    final async = ref.watch(contactsListProvider);
    return async.when(
      data: (list) => _buildSummaryCard(
        context,
        ref,
        theme,
        l10n,
        title: title,
        amountLabel: '${list.length}',
        icon: icon,
        color: color,
        onTap: onTap,
        onRemove: onRemove,
        reorderKey: reorderKey,
      ),
      loading: () => _buildCardPlaceholder(theme, reorderKey),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCategoriesCountCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n, {
    required VoidCallback onRemove,
    Key? reorderKey,
  }) {
    final async = ref.watch(categoriesListProvider);
    return async.when(
      data: (list) => _buildSummaryCard(
        context,
        ref,
        theme,
        l10n,
        title: l10n.categories,
        amountLabel: '${list.length}',
        icon: Icons.category_outlined,
        color: theme.colorScheme.secondary,
        onTap: () {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CategoriesListScreen(),
              ),
            );
          }
        },
        onRemove: onRemove,
        reorderKey: reorderKey,
      ),
      loading: () => _buildCardPlaceholder(theme, reorderKey),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _wrapCard({Key? reorderKey, required Widget child}) {
    if (reorderKey != null) return KeyedSubtree(key: reorderKey, child: child);
    return child;
  }

  Widget _buildCardPlaceholder(ThemeData theme, Key? reorderKey) {
    return _wrapCard(
      reorderKey: reorderKey,
      child: Padding(
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
      ),
    );
  }

  void _showRemoveSheet(BuildContext context, WidgetRef ref, VoidCallback onRemove,
      AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.push_pin),
          title: Text(l10n.unpinFromDashboard),
          onTap: () {
            Navigator.pop(ctx);
            onRemove();
          },
        ),
      ),
    );
  }

  Future<void> _removeAt(WidgetRef ref, int index) async {
    await ref.read(dashboardWidgetLayoutProvider.notifier).removeAt(index);
  }

  void _openTransactionsFiltered(
      WidgetRef ref, BuildContext context, DashboardFilter filter) {
    final isMonthly = filter == DashboardFilter.monthly;
    final now = DateTime.now();
    final startDate =
        isMonthly ? DateTime(now.year, now.month, 1) : null;
    final endDate =
        isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
    ref.read(transactionsPaginatedProvider.notifier).applyFilters(
          TransactionFilters(
            startDate: startDate,
            endDate: endDate,
          ),
        );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionsListScreen()),
    );
  }

  void _openReceivables(
      WidgetRef ref, BuildContext context, DashboardFilter filter) {
    final isMonthly = filter == DashboardFilter.monthly;
    final now = DateTime.now();
    final startDate =
        isMonthly ? DateTime(now.year, now.month, 1) : null;
    final endDate =
        isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
    ref
        .read(receivablesPaginatedProvider('PENDING').notifier)
        .applyFilters(ReceivableFilters(startDate: startDate, endDate: endDate));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReceivablesListScreen()),
    );
  }

  void _openPayables(
      WidgetRef ref, BuildContext context, DashboardFilter filter) {
    final isMonthly = filter == DashboardFilter.monthly;
    final now = DateTime.now();
    final startDate =
        isMonthly ? DateTime(now.year, now.month, 1) : null;
    final endDate =
        isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
    ref
        .read(payablesPaginatedProvider('PENDING').notifier)
        .applyFilters(PayableFilters(startDate: startDate, endDate: endDate));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PayablesListScreen()),
    );
  }
}
