import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
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
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:flowpaisa/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/voice_command/presentation/screens/voice_add_screen.dart';
import 'package:flowpaisa/features/receipt_scan/presentation/screens/scan_receipt_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/features/settings/presentation/screens/user_guide_screen.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/features/categories/presentation/widgets/category_budget_progress_bar.dart';
import 'package:flowpaisa/core/utils/category_budget_utils.dart';
import 'package:flowpaisa/shared/widgets/dual_amount_progress_bar.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:flowpaisa/features/tour/domain/tour_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/models/date_range_state.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:material_symbols_icons/symbols.dart' show Symbols;

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
    final isPremium = PremiumGate.isPremium(ref);
    final reorderMode = ref.watch(dashboardReorderModeProvider);

    final wrapRemove = reorderMode
        ? (Widget child, VoidCallback? onRemove) =>
            _wrapCard(reorderKey: reorderKey, child: child, onRemove: onRemove)
        : (Widget child, VoidCallback? onRemove) =>
            _wrapCard(reorderKey: reorderKey, child: child);

    switch (config.kind) {
      case DashboardWidgetKind.balance:
        return wrapRemove(
          _buildFromStats(
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
          ),
          () => _removeAt(ref, layoutIndex),
        );
      case DashboardWidgetKind.cashFlow:
        return wrapRemove(
          _buildCashFlowWidget(
            context,
            ref,
            theme,
            l10n,
            currency,
            filter,
            onRemove: () => _removeAt(ref, layoutIndex),
          ),
          () => _removeAt(ref, layoutIndex),
        );
      case DashboardWidgetKind.receivablesSummary:
        return wrapRemove(
          _buildFromStats(
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
                stats.receivable(filter),
                currency!.symbol,
                currency.decimalPlaces),
            onTap: () => _openReceivables(ref, context, filter),
            onRemove: () => _removeAt(ref, layoutIndex),
          ),
          () => _removeAt(ref, layoutIndex),
        );
      case DashboardWidgetKind.payablesSummary:
        return wrapRemove(
          _buildFromStats(
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
          ),
          () => _removeAt(ref, layoutIndex),
        );
      case DashboardWidgetKind.contactsSummary:
        return wrapRemove(
          _buildCountCard(
            context,
            ref,
            theme,
            l10n,
            title: l10n.contacts,
            icon: Icons.people_outline,
            color: theme.colorScheme.primary,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ContactsListScreen())),
            onRemove: () => _removeAt(ref, layoutIndex),
          ),
          () => _removeAt(ref, layoutIndex),
        );
      case DashboardWidgetKind.categoriesSummary:
        return wrapRemove(
          _buildCategoriesCountCard(
            context,
            ref,
            theme,
            l10n,
            onRemove: () => _removeAt(ref, layoutIndex),
          ),
          () => _removeAt(ref, layoutIndex),
        );
      case DashboardWidgetKind.netWorth:
        return wrapRemove(
          _buildNetWorthWidget(
            context,
            ref,
            theme,
            l10n,
            currency,
            onRemove: () => _removeAt(ref, layoutIndex),
          ),
          () => _removeAt(ref, layoutIndex),
        );
      case DashboardWidgetKind.quickActions:
        return wrapRemove(
          _buildQuickActions(
              context, ref, l10n, isPremium, reorderMode, config, layoutIndex),
          () => _removeAt(ref, layoutIndex),
        );
      case DashboardWidgetKind.netCredit:
        return wrapRemove(
          _buildNetCreditWidget(
            context,
            ref,
            theme,
            l10n,
            currency,
            filter,
            onRemove: () => _removeAt(ref, layoutIndex),
          ),
          () => _removeAt(ref, layoutIndex),
        );
      case DashboardWidgetKind.incomeSummary:
        return wrapRemove(
          _buildIncomeExpenseSummary(
            context,
            ref,
            theme,
            l10n,
            currency,
            filter,
            isIncome: true,
            onRemove: () => _removeAt(ref, layoutIndex),
          ),
          () => _removeAt(ref, layoutIndex),
        );
      case DashboardWidgetKind.expenseSummary:
        return wrapRemove(
          _buildIncomeExpenseSummary(
            context,
            ref,
            theme,
            l10n,
            currency,
            filter,
            isIncome: false,
            onRemove: () => _removeAt(ref, layoutIndex),
          ),
          () => _removeAt(ref, layoutIndex),
        );
      case DashboardWidgetKind.recentTransactions:
        return wrapRemove(
          _buildRecentTransactions(
            context,
            ref,
            theme,
            l10n,
            currency,
            onRemove: () => _removeAt(ref, layoutIndex),
          ),
          () => _removeAt(ref, layoutIndex),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    dynamic currency, {
    required VoidCallback onRemove,
    Key? reorderKey,
  }) {
    final transactionsAsync = ref.watch(transactionsPaginatedProvider);
    final symbol = currency?.symbol ?? '';
    final decimals = currency?.decimalPlaces ?? 2;

    final transactions = transactionsAsync.items.take(5).toList();
    if (transactions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionsListScreen()),
            );
          },
          onLongPress: () => _showSummaryActionsSheet(
            context,
            ref,
            onRemove,
            l10n,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1), width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.history,
                        color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.recentTransactions,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios,
                        size: 12, color: theme.hintColor),
                  ],
                ),
                const SizedBox(height: 12),
                ...transactions.map((tx) {
                  final isIncome = tx.transaction.type == 'INCOME';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tx.transaction.description ??
                                tx.category?.name ??
                                l10n.uncategorized,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          AmountFormatter.formatWithCurrency(
                              tx.transaction.amount, symbol, decimals),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isIncome
                                ? AppColors.incomeColor
                                : AppColors.expenseColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseSummary(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    dynamic currency,
    DashboardFilter filter, {
    required bool isIncome,
    required VoidCallback onRemove,
    Key? reorderKey,
  }) {
    final type = isIncome ? 'INCOME' : 'EXPENSE';
    final categoriesAsync = ref.watch(categoriesByTypeProvider(type));
    final range = ref.watch(categoryBudgetDateRangeProvider);
    final netsAsync = ref.watch(categoryNetAmountsForListProvider(type));
    final includeAsync =
        ref.watch(includeUncategorizedInCategorySummaryProvider);
    final uncategorizedAsync =
        ref.watch(uncategorizedAmountByTypeProvider(type));

    final symbol = currency?.symbol ?? '';
    final decimals = currency?.decimalPlaces ?? 2;
    final color = isIncome ? AppColors.incomeColor : AppColors.expenseColor;

    return categoriesAsync.when(
      data: (categories) {
        return netsAsync.when(
          data: (nets) {
            final includeUncategorized = includeAsync.value ?? false;
            final uncategorizedAmt = uncategorizedAsync.value ?? 0.0;

            double categorizedNet = 0;
            double totalBudgetCap = 0;
            for (final c in categories) {
              categorizedNet += nets[c.uuid] ?? 0;
              final isCatLocked = !PremiumGate.isPremium(ref) &&
                  !c.isDefault &&
                  (c.addSeq ?? 0) > PremiumGate.categoryTotalLimit;
              final isBudgetLocked = !PremiumGate.isPremium(ref) &&
                  (c.budgetSeq ?? 0) > PremiumGate.categoryBudgetTotalLimit;

              if (!isCatLocked && !isBudgetLocked) {
                final b = budgetAmountForPeriod(c, range);
                if (b != null && b > 0) {
                  totalBudgetCap += b;
                }
              }
            }

            final totalNet =
                categorizedNet + (includeUncategorized ? uncategorizedAmt : 0.0);

            final hasBudget = totalBudgetCap > 0;
            final pr = hasBudget ? totalNet / totalBudgetCap : 0.0;
            final over = hasBudget && pr > 1.0;
            final barFillColor = over ? AppColors.expenseColor : color;

            final netStr = AmountFormatter.formatWithCurrency(
              totalNet,
              symbol,
              decimals,
            );
            final budgetStr = AmountFormatter.formatWithCurrency(
              totalBudgetCap,
              symbol,
              decimals,
            );
            final uncategorizedStr = AmountFormatter.formatWithCurrency(
              uncategorizedAmt,
              symbol,
              decimals,
            );

            final gradientCardDecoration = BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.82)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            );

            final isDarkForChip = theme.brightness == Brightness.dark;
            const chipLabelLight = Color(0xFF0F172A);

            return _wrapCard(
              reorderKey: reorderKey,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: gradientCardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CategoriesListScreen(
                                      initialIndex: isIncome ? 1 : 0,
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () => _showSummaryActionsSheet(
                                context,
                                ref,
                                onRemove,
                                l10n,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          isIncome
                                              ? l10n.totalIncome
                                              : l10n.totalExpenses,
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: Colors.white
                                                .withValues(alpha: 0.88),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          _getPeriodLabel(context, range, l10n),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: Colors.white
                                                .withValues(alpha: 0.65),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 9,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          netStr,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (hasBudget) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            budgetStr,
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: Colors.white
                                                  .withValues(alpha: 0.92),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    PositionedDirectional(
                                      end: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.uncategorized,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.78),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        uncategorizedStr,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  showCheckmark: true,
                                  selected: includeUncategorized,
                                  label: Text(
                                    l10n.categoriesSummaryIncludeInTotal,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkForChip
                                          ? Colors.white.withValues(
                                              alpha: includeUncategorized
                                                  ? 1.0
                                                  : 0.92,
                                            )
                                          : (includeUncategorized
                                              ? color
                                              : chipLabelLight),
                                    ),
                                  ),
                                  selectedColor: isDarkForChip
                                      ? Colors.white.withValues(alpha: 0.28)
                                      : Colors.white.withValues(alpha: 0.92),
                                  backgroundColor: isDarkForChip
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.white.withValues(alpha: 0.55),
                                  disabledColor: isDarkForChip
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.white.withValues(alpha: 0.35),
                                  checkmarkColor:
                                      isDarkForChip ? Colors.white : color,
                                  side: BorderSide(
                                    color: isDarkForChip
                                        ? Colors.white.withValues(
                                            alpha: includeUncategorized
                                                ? 0.5
                                                : 0.32,
                                          )
                                        : Colors.white.withValues(
                                            alpha: includeUncategorized
                                                ? 0.75
                                                : 0.5,
                                          ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 0,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  onSelected: (selected) {
                                    ref
                                        .read(
                                          includeUncategorizedInCategorySummaryProvider
                                              .notifier,
                                        )
                                        .setInclude(selected);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasBudget) ...[
                      const SizedBox(height: 8),
                      DualAmountProgressBar(
                        leftLabel: isIncome
                            ? l10n.budgetBarProgress
                            : l10n.budgetBarUsed,
                        leftAmount: totalNet > 0 ? totalNet : 0.0,
                        rightLabel: l10n.remaining,
                        rightAmount: (totalBudgetCap - totalNet) > 0
                            ? (totalBudgetCap - totalNet)
                            : 0.0,
                        symbol: symbol,
                        decimals: decimals,
                        filledColor: barFillColor,
                        compact: true,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => _buildCardPlaceholder(theme),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => _buildCardPlaceholder(theme),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildNetWorthWidget(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    dynamic currency, {
    required VoidCallback onRemove,
    Key? reorderKey,
  }) {
    final accountsAsync = ref.watch(accountsWithBalanceProvider);
    final symbol = currency?.symbol ?? '';
    final decimals = currency?.decimalPlaces ?? 2;

    return accountsAsync.when(
      data: (accounts) {
        final totalAssets = accounts.where((a) => !a.type.balanceIsLiability).fold<double>(
            0, (sum, a) => sum + a.balance.clamp(0, double.infinity));
        final totalLiabilities = accounts
            .where((a) => a.type.balanceIsLiability)
            .fold<double>(0, (sum, a) => sum + a.balance.abs());
        final netWorth = totalAssets - totalLiabilities;

        return _wrapCard(
          reorderKey: reorderKey,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountsScreen()),
                  );
                },
                onLongPress: () => _showSummaryActionsSheet(
                  context,
                  ref,
                  onRemove,
                  l10n,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.receivableColor.withValues(alpha: 0.4),
                        width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Net Worth Item (Smaller version of _NetWorthItem)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.receivableColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.receivableColor
                                  .withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Symbols.account_balance,
                                  color: AppColors.receivableColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.netWorth,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AmountFormatter.formatWithCurrency(
                                  netWorth, symbol, decimals),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.receivableColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Assets & Liabilities Row (Smaller version of _StatItem)
                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallStatItem(
                              theme: theme,
                              color: AppColors.incomeColor,
                              icon: Symbols.trending_up,
                              label: l10n.totalAssets,
                              amount: totalAssets,
                              symbol: symbol,
                              decimals: decimals,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSmallStatItem(
                              theme: theme,
                              color: AppColors.payableColor,
                              icon: Symbols.trending_down,
                              label: l10n.totalLiabilities,
                              amount: totalLiabilities,
                              symbol: symbol,
                              decimals: decimals,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => _buildCardPlaceholder(theme),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSmallStatItem({
    required ThemeData theme,
    required Color color,
    required IconData icon,
    required String label,
    required double amount,
    required String symbol,
    required int decimals,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AmountFormatter.formatWithCurrency(amount, symbol, decimals),
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNetCreditWidget(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    dynamic currency,
    DashboardFilter filter, {
    required VoidCallback onRemove,
    Key? reorderKey,
  }) {
    final async = ref.watch(dashboardStatsProvider);
    final symbol = currency?.symbol ?? '';
    final decimals = currency?.decimalPlaces ?? 2;

    return async.when(
      data: (stats) {
        final netCredit = stats.netCredit(filter);
        final isReceivableHigher = netCredit >= 0;
        final amount = netCredit.abs();
        final label = isReceivableHigher ? l10n.netReceivable : l10n.netPayable;
        final gradient = isReceivableHigher
            ? AppColors.receivablesSectionGradient
            : AppColors.payablesSectionGradient;

        final transparentGradient = LinearGradient(
          colors: gradient.colors.map((c) => c.withValues(alpha: .85)).toList(),
          begin: gradient.begin,
          end: gradient.end,
          stops: gradient.stops,
        );

        return _wrapCard(
          reorderKey: reorderKey,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openReceivables(ref, context, filter),
                onLongPress: () => _showSummaryActionsSheet(
                  context,
                  ref,
                  onRemove,
                  l10n,
                ),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: transparentGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              filter == DashboardFilter.monthly
                                  ? AppDateFormatter.formatMonthYear(
                                      DateTime.now(),
                                      context: context)
                                  : l10n.allTime,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AmountFormatter.formatWithCurrency(
                            amount, symbol, decimals),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => _buildCardPlaceholder(theme),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCashFlowWidget(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    dynamic currency,
    DashboardFilter filter, {
    required VoidCallback onRemove,
    Key? reorderKey,
  }) {
    final async = ref.watch(dashboardStatsProvider);
    final symbol = currency?.symbol ?? '';
    final decimals = currency?.decimalPlaces ?? 2;

    return async.when(
      data: (stats) {
        final netCash = stats.netCash(filter);
        final isIncomeHigher = netCash >= 0;
        final amount = netCash.abs();
        final label = isIncomeHigher ? l10n.netIncome : l10n.netExpenses;
        final gradient =
            isIncomeHigher ? AppColors.incomeGradient : AppColors.expenseGradient;

        final transparentGradient = LinearGradient(
          colors: gradient.colors.map((c) => c.withValues(alpha: .85)).toList(),
          begin: gradient.begin,
          end: gradient.end,
          stops: gradient.stops,
        );

        return _wrapCard(
          reorderKey: reorderKey,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openTransactionsFiltered(ref, context, filter),
                onLongPress: () => _showSummaryActionsSheet(
                  context,
                  ref,
                  onRemove,
                  l10n,
                ),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: transparentGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              filter == DashboardFilter.monthly
                                  ? AppDateFormatter.formatMonthYear(
                                      DateTime.now(),
                                      context: context)
                                  : l10n.allTime,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AmountFormatter.formatWithCurrency(
                            amount, symbol, decimals),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => _buildCardPlaceholder(theme),
      error: (_, __) => const SizedBox.shrink(),
    );
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
      loading: () => _buildCardPlaceholder(theme),
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
    String? copyOpenLinkEntityType,
    String? copyOpenLinkUuid,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showSummaryActionsSheet(
            context,
            ref,
            onRemove,
            l10n,
            copyOpenLinkEntityType: copyOpenLinkEntityType,
            copyOpenLinkUuid: copyOpenLinkUuid,
          ),
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
      loading: () => _buildCardPlaceholder(theme),
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
      loading: () => _buildCardPlaceholder(theme),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _wrapCard(
      {Key? reorderKey, required Widget child, VoidCallback? onRemove}) {
    final widget =
        reorderKey != null ? KeyedSubtree(key: reorderKey, child: child) : child;
    if (onRemove == null) return widget;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget,
        PositionedDirectional(
          top: -10,
          end: -10,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
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

  void _showSummaryActionsSheet(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onRemove,
    AppLocalizations l10n, {
    String? copyOpenLinkEntityType,
    String? copyOpenLinkUuid,
  }) {
    final copyType = copyOpenLinkEntityType;
    final copyUuid = copyOpenLinkUuid;
    final hasCopy = copyType != null &&
        copyType.isNotEmpty &&
        copyUuid != null &&
        copyUuid.isNotEmpty;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasCopy)
              ListTile(
                leading: const Icon(Icons.link),
                title: Text(l10n.copyLink),
                onTap: () {
                  final link = DeepLinkService().generateEntityOpenLinkHttps(
                    copyType,
                    copyUuid,
                  );
                  Clipboard.setData(ClipboardData(text: link));
                  Navigator.pop(ctx);
                  ToastUtils.showSuccessToast(context, ref, l10n.linkCopied);
                },
              ),
            ListTile(
              leading: const Icon(Icons.push_pin),
              title: Text(l10n.unpinFromDashboard),
              onTap: () {
                Navigator.pop(ctx);
                onRemove();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removeAt(WidgetRef ref, int index) async {
    await ref.read(dashboardWidgetLayoutProvider.notifier).removeAt(index);
  }

  Future<void> _showQuickActionSelectionSheetForWidget(
      BuildContext context,
      WidgetRef ref,
      AppLocalizations l10n,
      ThemeData theme,
      DashboardWidgetConfig config,
      int layoutIndex) async {
    final actions = [
      ('voice_add', l10n.voiceAdd, Icons.mic_none_rounded),
      ('add_transaction', l10n.add, Icons.add),
      ('scan_receipt', l10n.scan, Icons.document_scanner_outlined),
      ('accounts', l10n.accounts, Symbols.account_balance),
      ('contacts', l10n.contacts, Icons.people_outline_rounded),
      ('receivables', l10n.receivableTag, Symbols.account_balance_wallet),
      ('payables', l10n.payables, Icons.payment_outlined),
      ('categories', l10n.categories, Icons.category_outlined),
      ('analytics', l10n.analytics, Icons.bar_chart_rounded),
      ('user_guide', l10n.userGuide, Icons.help_outline_rounded),
      ('app_tour', l10n.appTour, Icons.tour_outlined),
    ];

    final layoutAsync = ref.read(dashboardWidgetLayoutProvider);
    final allConfigs = layoutAsync.value ?? [];

    // Summary widgets that are already on dashboard (excluding THIS widget)
    final existingSummaryKinds = allConfigs
        .where((c) => !c.kind.isEntity && c != config)
        .map((c) => c.kind)
        .toSet();

    final actionToKind = {
      'accounts': DashboardWidgetKind.netWorth,
      'contacts': DashboardWidgetKind.contactsSummary,
      'receivables': DashboardWidgetKind.receivablesSummary,
      'payables': DashboardWidgetKind.payablesSummary,
      'categories': DashboardWidgetKind.categoriesSummary,
    };

    // Filter out actions that are already used as individual summary widgets elsewhere
    final availableActions = actions.where((a) {
      final kind = actionToKind[a.$1];
      if (kind != null && existingSummaryKinds.contains(kind)) return false;
      return true;
    }).toList();

    final currentActions = config.quickActionCodes?.toSet() ??
        actions.map((e) => e.$1).toSet(); // Default to all if null

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.quickActions,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: availableActions.map((e) {
                      final isSelected = currentActions.contains(e.$1);
                      return CheckboxListTile(
                        secondary: Icon(e.$3),
                        title: Text(e.$2),
                        value: isSelected,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              currentActions.add(e.$1);
                            } else {
                              currentActions.remove(e.$1);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    await ref
                        .read(dashboardWidgetLayoutProvider.notifier)
                        .updateWidget(
                          layoutIndex,
                          config.copyWith(
                              quickActionCodes: currentActions.toList()),
                        );
                    if (context.mounted) Navigator.pop(ctx);
                  },
                  child: Text(l10n.save),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
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

  String _getPeriodLabel(
      BuildContext context, DateRangeState range, AppLocalizations l10n) {
    switch (range.type) {
      case DateRangeType.month:
        return AppDateFormatter.formatMonthYear(range.startDate,
            context: context);
      case DateRangeType.quarter:
        final quarter = ((range.startDate.month - 1) ~/ 3) + 1;
        return 'Q$quarter ${range.startDate.year}';
      case DateRangeType.year:
        return '${range.startDate.year}';
      case DateRangeType.custom:
        return '${AppDateFormatter.formatDate(range.startDate, pattern: 'MMM dd')} - ${AppDateFormatter.formatDate(range.endDate, pattern: 'MMM dd')}';
    }
  }

  Widget _buildQuickActions(
      BuildContext context,
      WidgetRef ref,
      AppLocalizations l10n,
      bool isPremium,
      bool reorderMode,
      DashboardWidgetConfig config,
      int layoutIndex) {
    final theme = Theme.of(context);
    final activeCashbook = ref.watch(activeCashbookProvider);
    final activeColor = activeCashbook.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reorderMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.quickActions,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    onPressed: () => _showQuickActionSelectionSheetForWidget(
                      context,
                      ref,
                      l10n,
                      theme,
                      config,
                      layoutIndex,
                    ),
                  ),
                ],
              ),
            ),
          if (reorderMode) const SizedBox(height: 12),
          // Grid layout for quick actions (responsive)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate optimal item width based on available space
                const double minItemWidth = 100; // Minimum width per item
                final double availableWidth = constraints.maxWidth;

                // Calculate how many items can fit
                int crossAxisCount = (availableWidth / minItemWidth).floor();
                crossAxisCount =
                    crossAxisCount.clamp(2, 6); // Min 2, Max 6 columns

                // Calculate actual item width
                final double itemWidth = availableWidth / crossAxisCount;
                final double childAspectRatio =
                    itemWidth / 110; // Height is fixed at ~110px

                return GridView.count(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: childAspectRatio,
                  children: [
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('voice_add'))
                      _QuickActionButton(
                        icon: Icons.mic_none_rounded,
                        label: l10n.voiceAdd,
                        gradient: AppColors.transactionsSectionGradient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoiceAddScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('add_transaction'))
                      _QuickActionButton(
                        icon: Icons.add,
                        label: l10n.add,
                        gradient: AppColors.transactionsSectionGradient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddTransactionScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('scan_receipt'))
                      _QuickActionButton(
                        icon: Icons.document_scanner_outlined,
                        label: l10n.scan,
                        gradient: AppColors.transactionsSectionGradient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScanReceiptScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('accounts'))
                      _QuickActionButton(
                        icon: Symbols.account_balance,
                        label: l10n.accounts,
                        gradient: AppColors.dashboardSectionGradient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AccountsScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('contacts'))
                      _QuickActionButton(
                        icon: Icons.people_outline_rounded,
                        label: l10n.contacts,
                        gradient: AppColors.getPrimaryGradient(
                            theme.colorScheme.primary),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContactsListScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('receivables'))
                      _QuickActionButton(
                        icon: Symbols.account_balance_wallet,
                        label: l10n.receivableTag,
                        gradient: AppColors.receivablesSectionGradient,
                        onTap: () {
                          // Clear filters and search before navigating
                          final pendingNotifier = ref.read(
                              receivablesPaginatedProvider('PENDING')
                                  .notifier);
                          pendingNotifier.updateSearchQuery('');
                          pendingNotifier.applyFilters(ReceivableFilters());

                          final overdueNotifier = ref.read(
                              receivablesPaginatedProvider('OVERDUE')
                                  .notifier);
                          overdueNotifier.updateSearchQuery('');
                          overdueNotifier.applyFilters(ReceivableFilters());

                          final receivedNotifier = ref.read(
                              receivablesPaginatedProvider('RECEIVED')
                                  .notifier);
                          receivedNotifier.updateSearchQuery('');
                          receivedNotifier.applyFilters(ReceivableFilters());

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ReceivablesListScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('payables'))
                      _QuickActionButton(
                        icon: Icons.payment_outlined,
                        label: l10n.payables,
                        gradient: AppColors.payablesSectionGradient,
                        onTap: () {
                          // Clear filters and search before navigating
                          final pendingNotifier = ref.read(
                              payablesPaginatedProvider('PENDING').notifier);
                          pendingNotifier.updateSearchQuery('');
                          pendingNotifier.applyFilters(PayableFilters());

                          final overdueNotifier = ref.read(
                              payablesPaginatedProvider('OVERDUE').notifier);
                          overdueNotifier.updateSearchQuery('');
                          overdueNotifier.applyFilters(PayableFilters());

                          final paidNotifier = ref.read(
                              payablesPaginatedProvider('PAID').notifier);
                          paidNotifier.updateSearchQuery('');
                          paidNotifier.applyFilters(PayableFilters());

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PayablesListScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('categories'))
                      _QuickActionButton(
                        icon: Icons.category_outlined,
                        label: l10n.categories,
                        gradient: AppColors.getSecondaryGradient(
                            theme.colorScheme.primary),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CategoriesListScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('analytics'))
                      _QuickActionButton(
                        icon: Icons.bar_chart_rounded,
                        label: l10n.analytics,
                        gradient: AppColors.analyticsSectionGradient,
                        showLock: !isPremium,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AnalyticsScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('user_guide'))
                      _QuickActionButton(
                        icon: Icons.help_outline_rounded,
                        label: l10n.userGuide,
                        gradient: AppColors.getSecondaryGradient(
                            theme.colorScheme.secondary),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserGuideScreen(),
                            ),
                          );
                        },
                      ),
                    if (config.quickActionCodes == null ||
                        config.quickActionCodes!.contains('app_tour'))
                      _QuickActionButton(
                        icon: Icons.tour_outlined,
                        label: l10n.appTour,
                        gradient: AppColors.getPrimaryGradient(activeColor),
                        onTap: () {
                          // Start the dashboard tour
                          try {
                            final showcaseState = ShowCaseWidget.of(context);
                            showcaseState.startShowCase(
                                TourService.dashboardTourKeys);
                          } catch (e) {
                            debugPrint('Error starting tour: $e');
                          }
                        },
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;
  final bool showLock;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.showLock = false,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedPressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
        decoration: BoxDecoration(
          gradient: gradient.withOpacity(0.2),
          border: Border.all(
              color: gradient.colors.first.withValues(alpha: 0.5), width: 1),
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(20),
            bottomEnd: Radius.circular(20),
          ),
          // Diagonal beveled
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: gradient.colors.first.withValues(alpha: 0.8),
                        width: 1),
                    color: gradient.colors.first.withValues(alpha: 0.2 / 1.0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24),
                ),
                if (showLock)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(Icons.lock, size: 12, color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget for press & scale micro-animation
class _AnimatedPressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedPressScale({required this.child, required this.onTap});

  @override
  State<_AnimatedPressScale> createState() => _AnimatedPressScaleState();
}

class _AnimatedPressScaleState extends State<_AnimatedPressScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
