import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/main.dart';
import 'dart:math';
import 'dart:io';
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
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:fl_chart/fl_chart.dart';
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
import 'package:flowpaisa/features/categories/domain/category_budget_models.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_slider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/widgets/cashbook_slider.dart';
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
                stats.totalBalance, currency!),
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
                currency!),
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
                stats.payable(filter),
                currency!),
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
      case DashboardWidgetKind.financialSummary:
        return wrapRemove(
          _buildFinancialSummaryWidget(
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
      case DashboardWidgetKind.accountsSlider:
        return wrapRemove(
          _buildAccountsSlider(
            context,
            ref,
            theme,
            l10n,
            onRemove: () => _removeAt(ref, layoutIndex),
          ),
          () => _removeAt(ref, layoutIndex),
        );
      case DashboardWidgetKind.cashbooksSlider:
        return wrapRemove(
          _buildCashbooksSlider(
            context,
            ref,
            theme,
            l10n,
            onRemove: () => _removeAt(ref, layoutIndex),
          ),
          () => _removeAt(ref, layoutIndex),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAccountsSlider(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n, {
    required VoidCallback onRemove,
  }) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccountSlider(showHeader: true),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCashbooksSlider(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n, {
    required VoidCallback onRemove,
  }) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CashbookSlider(),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFinancialSummaryWidget(
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

    // Cache stats for loading state
    async.whenData((s) {
      Future.microtask(() {
        if (context.mounted) {
          ref.read(lastDashboardStatsProvider.notifier).setLast(s);
        }
      });
    });

    return async.when(
      skipLoadingOnRefresh: true,
      data: (s) {
        final income = s.income(filter);
        final expense = s.expense(filter);
        final receivable = s.receivable(filter);
        final payable = s.payable(filter);

        return _wrapCard(
          reorderKey: reorderKey,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              key: ValueKey('fin-summary-material-${filter.name}'),
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TransactionsListScreen()),
                  );
                },
                onLongPress: () => _showSummaryActionsSheet(
                  context,
                  ref,
                  onRemove,
                  l10n,
                ),
                child: Container(
                  key: ValueKey('fin-summary-container-${filter.name}'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                        width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    key: ValueKey('fin-summary-column-${filter.name}'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        key: ValueKey('fin-summary-row1-${filter.name}'),
                        children: [
                          Expanded(
                            child: _buildSmallStatItem(
                              key: ValueKey(
                                  'fin-summary-payable-${filter.name}'),
                              theme: theme,
                              color: AppColors.payableColor,
                              icon: Symbols.trending_down,
                              label: l10n.payableTag,
                              amount: payable,
                              currency: currency!,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSmallStatItem(
                              key: ValueKey(
                                  'fin-summary-receivable-${filter.name}'),
                              theme: theme,
                              color: AppColors.receivableColor,
                              icon: Symbols.trending_up,
                              label: l10n.receivableTag,
                              amount: receivable,
                              currency: currency,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        key: ValueKey('fin-summary-row2-${filter.name}'),
                        children: [
                          Expanded(
                            child: _buildSmallStatItem(
                              key: ValueKey(
                                  'fin-summary-expense-${filter.name}'),
                              theme: theme,
                              color: AppColors.expenseColor,
                              icon: Symbols.trending_down,
                              label: l10n.expenses,
                              amount: expense,
                              currency: currency,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSmallStatItem(
                              key:
                                  ValueKey('fin-summary-income-${filter.name}'),
                              theme: theme,
                              color: AppColors.incomeColor,
                              icon: Symbols.trending_up,
                              label: l10n.income,
                              amount: income,
                              currency: currency,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildBalanceRow(
                        key: ValueKey('fin-summary-bal1-${filter.name}'),
                        theme: theme,
                        currency: currency!,
                        isReceivableHigher: receivable >= payable,
                        amount: (receivable - payable).abs(),
                        labelWhenHigher: l10n.netReceivable,
                        labelWhenLower: l10n.netPayable,
                        gradientWhenHigher: AppColors.receivableGradient,
                        gradientWhenLower: AppColors.payableGradient,
                      ),
                      const SizedBox(height: 8),
                      _buildBalanceRow(
                        key: ValueKey('fin-summary-bal2-${filter.name}'),
                        theme: theme,
                        currency: currency,
                        isReceivableHigher: income >= expense,
                        amount: (income - expense).abs(),
                        labelWhenHigher: l10n.netIncome,
                        labelWhenLower: l10n.netExpenses,
                        gradientWhenHigher: AppColors.incomeGradient,
                        gradientWhenLower: AppColors.expenseGradient,
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

  Widget _buildBalanceRow({
    required ThemeData theme,
    required AppCurrency currency,
    required bool isReceivableHigher,
    required double amount,
    required String labelWhenHigher,
    required String labelWhenLower,
    required LinearGradient gradientWhenHigher,
    required LinearGradient gradientWhenLower,
    Key? key,
  }) {
    final isHigher = isReceivableHigher;
    final label = isHigher ? labelWhenHigher : labelWhenLower;
    final gradient = isHigher ? gradientWhenHigher : gradientWhenLower;

    final transparentGradient = LinearGradient(
      colors: gradient.colors.map((c) => c.withValues(alpha: .8)).toList(),
      begin: gradient.begin,
      end: gradient.end,
      stops: gradient.stops,
    );

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: transparentGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gradient.colors.first.withValues(alpha: 0.1),
          width: .5,
        ),
      ),
      child: Row(
        key: key != null ? ValueKey('bal-row-content-${key.toString()}') : null,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
          Text(
            AmountFormatter.formatWithCurrency(amount, currency),
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final symbol = currency?.symbol ?? '';
    final decimals = currency?.decimalPlaces ?? 2;

    return transactionsAsync.when(
      skipLoadingOnRefresh: true,
      data: (transactions) {
        if (transactions.isEmpty) return const SizedBox.shrink();

        return RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              key: const ValueKey('recent-tx-list'),
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TransactionsListScreen()),
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
                        color: theme.dividerColor.withValues(alpha: 0.1),
                        width: 1),
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
                      ...transactions.take(5).map((tx) {
                        final isIncome = tx.type == 'INCOME';
                        return Padding(
                          key: ValueKey('recent-tx-row-${tx.uuid}'),
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            key: ValueKey('recent-tx-row-content-${tx.uuid}'),
                            children: [
                              Expanded(
                                child: Text(
                                  key: ValueKey('recent-tx-desc-${tx.uuid}'),
                                  tx.description ?? l10n.uncategorized,
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                key: ValueKey('recent-tx-amount-${tx.uuid}'),
                                AmountFormatter.formatWithCurrency(
                                    tx.amount, symbol, decimals),
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
          ),
        );
      },
      loading: () => _buildCardPlaceholder(theme,
          key: const ValueKey('recent-tx-loading')),
      error: (_, __) => const SizedBox.shrink(),
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
    final viewModeAsync = ref.watch(summaryViewModeProvider);
    final viewMode = viewModeAsync.value ?? 'list';
    final isPremium = PremiumGate.isPremium(ref);

    final symbol = currency?.symbol ?? '';
    final decimals = currency?.decimalPlaces ?? 2;
    final color = isIncome ? AppColors.incomeColor : AppColors.expenseColor;

    return categoriesAsync.when(
      skipLoadingOnRefresh: true,
      data: (categories) {
        return netsAsync.when(
          skipLoadingOnRefresh: true,
          data: (nets) {
            return includeAsync.when(
              skipLoadingOnRefresh: true,
              data: (includeUncategorized) {
                return uncategorizedAsync.when(
                  skipLoadingOnRefresh: true,
                  data: (uncategorizedAmt) {
                    double categorizedNet = 0;
                    double totalBudgetCap = 0;
                    for (final c in categories) {
                      categorizedNet += nets[c.uuid] ?? 0;
                      final isCatLocked = !PremiumGate.isPremium(ref) &&
                          !c.isDefault &&
                          (c.addSeq ?? 0) > PremiumGate.categoryTotalLimit;
                      final isBudgetLocked = !PremiumGate.isPremium(ref) &&
                          (c.budgetSeq ?? 0) >
                              PremiumGate.categoryBudgetTotalLimit;

                      if (!isCatLocked && !isBudgetLocked) {
                        final b = budgetAmountForPeriod(c, range);
                        if (b != null && b > 0) {
                          totalBudgetCap += b;
                        }
                      }
                    }

                    final totalNet = categorizedNet +
                        (includeUncategorized ? uncategorizedAmt : 0.0);

                    final hasBudget = totalBudgetCap > 0;
                    final pr = hasBudget ? totalNet / totalBudgetCap : 0.0;
                    final over = hasBudget && pr > 1.0;
                    final barFillColor = over ? AppColors.expenseColor : color;

                    final netStr = AmountFormatter.formatWithCurrency(
                      totalNet,
                      currency!,
                    );
                    final budgetStr = AmountFormatter.formatWithCurrency(
                      totalBudgetCap,
                      currency,
                    );
                    final uncategorizedStr = AmountFormatter.formatWithCurrency(
                      uncategorizedAmt,
                      currency,
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
                          key: ValueKey('inc-exp-$type-${filter.name}'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: gradientCardDecoration,
                              child: Column(
                                key: ValueKey(
                                    'inc-exp-content-$type-${filter.name}'),
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Material(
                                    key: ValueKey(
                                        'inc-exp-material-$type-${filter.name}'),
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: null,
                                      onLongPress: () =>
                                          _showSummaryActionsSheet(
                                        context,
                                        ref,
                                        onRemove,
                                        l10n,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 10, 12, 10),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Column(
                                              key: ValueKey(
                                                  'inc-exp-stack-column-$type-${filter.name}'),
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  key: ValueKey(
                                                      'inc-exp-label-$type-${filter.name}'),
                                                  isIncome
                                                      ? l10n.totalIncome
                                                      : l10n.totalExpenses,
                                                  style: theme
                                                      .textTheme.labelMedium
                                                      ?.copyWith(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.88),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(height: 1),
                                                Text(
                                                  key: ValueKey(
                                                      'inc-exp-period-$type-${filter.name}'),
                                                  _getPeriodLabel(
                                                      context, range, l10n),
                                                  style: theme
                                                      .textTheme.labelSmall
                                                      ?.copyWith(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.65),
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 9,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  key: ValueKey(
                                                      'inc-exp-amount-$type-${filter.name}'),
                                                  netStr,
                                                  style: theme
                                                      .textTheme.titleLarge
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                if (hasBudget &&
                                                    viewMode == 'list') ...[
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    key: ValueKey(
                                                        'inc-exp-budget-$type-${filter.name}'),
                                                    budgetStr,
                                                    style: theme
                                                        .textTheme.labelLarge
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.92),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            PositionedDirectional(
                                              end: 0,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (isPremium)
                                                    IconButton(
                                                      icon: Icon(
                                                        viewMode == 'list'
                                                            ? Icons.show_chart
                                                            : Icons.list,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      onPressed: () {
                                                        ref
                                                            .read(
                                                                summaryViewModeProvider
                                                                    .notifier)
                                                            .setMode(viewMode ==
                                                                    'list'
                                                                ? 'chart'
                                                                : 'list');
                                                      },
                                                      tooltip:
                                                          viewMode == 'list'
                                                              ? l10n.showChart
                                                              : l10n.showList,
                                                    )
                                                  else
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.show_chart,
                                                        color: Colors.white54,
                                                        size: 20,
                                                      ),
                                                      onPressed: () =>
                                                          PremiumGate
                                                              .showPremiumDialog(
                                                                  context),
                                                      tooltip:
                                                          l10n.unlockPremium,
                                                    ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              CategoriesListScreen(
                                                            initialIndex:
                                                                isIncome ? 1 : 0,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(20),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(7),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.2),
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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (viewMode == 'chart')
                                    _buildIncomeExpenseChart(
                                      context,
                                      ref,
                                      theme,
                                      l10n,
                                      type,
                                      range,
                                      totalBudgetCap,
                                      color,
                                      symbol,
                                      decimals,
                                    ),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Colors.white.withValues(alpha: 0.22),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        12, 8, 12, 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.uncategorized,
                                                style: theme
                                                    .textTheme.labelSmall
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
                                                style: theme
                                                    .textTheme.titleSmall
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
                                              ? Colors.white
                                                  .withValues(alpha: 0.28)
                                              : Colors.white
                                                  .withValues(alpha: 0.92),
                                          backgroundColor: isDarkForChip
                                              ? Colors.white
                                                  .withValues(alpha: 0.12)
                                              : Colors.white
                                                  .withValues(alpha: 0.55),
                                          disabledColor: isDarkForChip
                                              ? Colors.white
                                                  .withValues(alpha: 0.08)
                                              : Colors.white
                                                  .withValues(alpha: 0.35),
                                          checkmarkColor: isDarkForChip
                                              ? Colors.white
                                              : color,
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
                            if (hasBudget && viewMode == 'list') ...[
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
                                currency: currency,
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
          },
          loading: () => _buildCardPlaceholder(theme),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => _buildCardPlaceholder(theme),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildIncomeExpenseChart(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    String type,
    DateRangeState range,
    double budget,
    Color color,
    String symbol,
    int decimals,
  ) {
    final dailyNetsAsync = ref
        .watch(dailyCumulativeNetAmountsProvider((type: type, range: range)));

    final userProfile = ref.watch(userProfileProvider);
    final dateFormat = userProfile.dateFormat;

    return dailyNetsAsync.when(
      data: (data) {
        if (data.isEmpty) {
          return SizedBox(
            height: 180,
            child: Center(
              child: Text(
                l10n.noTransactionsFound,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
          );
        }

        return _IncomeExpenseTrendChart(
          data: data,
          theme: theme,
          l10n: l10n,
          budget: budget,
          color: color,
          symbol: symbol,
          decimals: decimals,
          dateFormat: dateFormat,
        );
      },
      loading: () => const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator(color: Colors.white))),
      error: (e, s) => SizedBox(
          height: 180,
          child: Center(
              child: Text(e.toString(),
                  style: const TextStyle(color: Colors.white)))),
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

    return accountsAsync.when(
      skipLoadingOnRefresh: true,
      data: (accounts) {
        final totalAssets = accounts
            .where((a) => !a.type.balanceIsLiability)
            .fold<double>(
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
              key: const ValueKey('net-worth-summary-material'),
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
                  key: const ValueKey('net-worth-summary-container'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.receivableColor.withValues(alpha: 0.4),
                        width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    key: const ValueKey('net-worth-summary-column'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Net Worth Item (Smaller version of _NetWorthItem)
                      Container(
                        key: const ValueKey('net-worth-summary-header'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              AppColors.receivableColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.receivableColor
                                  .withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          key: const ValueKey('net-worth-summary-header-col'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              key: const ValueKey(
                                  'net-worth-summary-header-row'),
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
                              key: const ValueKey('net-worth-summary-amount'),
                              AmountFormatter.formatWithCurrency(
                                  netWorth, currency!),
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
                        key: const ValueKey('net-worth-summary-stats-row'),
                        children: [
                          Expanded(
                            child: _buildSmallStatItem(
                              key: const ValueKey('net-worth-summary-assets'),
                              theme: theme,
                              color: AppColors.incomeColor,
                              icon: Symbols.trending_up,
                              label: l10n.totalAssets,
                              amount: totalAssets,
                              currency: currency!,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSmallStatItem(
                              key: const ValueKey(
                                  'net-worth-summary-liabilities'),
                              theme: theme,
                              color: AppColors.payableColor,
                              icon: Symbols.trending_down,
                              label: l10n.totalLiabilities,
                              amount: totalLiabilities,
                              currency: currency,
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
    required AppCurrency currency,
    Key? key,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        key: key != null ? ValueKey('small-stat-col-${key.toString()}') : null,
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
            AmountFormatter.formatWithCurrency(amount, currency),
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

    return async.when(
      skipLoadingOnRefresh: true,
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
                            amount, currency!),
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

    return async.when(
      skipLoadingOnRefresh: true,
      data: (stats) {
        final netCash = stats.netCash(filter);
        final isIncomeHigher = netCash >= 0;
        final amount = netCash.abs();
        final label = isIncomeHigher ? l10n.netIncome : l10n.netExpenses;
        final gradient = isIncomeHigher
            ? AppColors.incomeGradient
            : AppColors.expenseGradient;

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
                            amount, currency!),
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

    // Cache stats for loading state
    async.whenData((s) {
      Future.microtask(() {
        if (context.mounted) {
          ref.read(lastDashboardStatsProvider.notifier).setLast(s);
        }
      });
    });

    return async.when(
      skipLoadingOnRefresh: true,
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
        key: ValueKey('summary-card-$title-${filter.name}'),
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
    Key? key,
  }) {
    return RepaintBoundary(
      key: key,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          key: key != null
              ? ValueKey('summary-material-${key.toString()}')
              : null,
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
              key: key != null
                  ? ValueKey('summary-container-${key.toString()}')
                  : null,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border:
                    Border.all(color: color.withValues(alpha: 0.4), width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                key: key != null
                    ? ValueKey('summary-row-${key.toString()}')
                    : null,
                children: [
                  Container(
                    key: key != null
                        ? ValueKey('summary-icon-container-${key.toString()}')
                        : null,
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
                      key: key != null
                          ? ValueKey('summary-text-col-${key.toString()}')
                          : null,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key: key != null
                              ? ValueKey('summary-title-${key.toString()}')
                              : null,
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
                            key: key != null
                                ? ValueKey('summary-subtitle-${key.toString()}')
                                : null,
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
                    key: key != null
                        ? ValueKey('summary-amount-${key.toString()}')
                        : null,
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
        key: ValueKey('summary-count-$title'),
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
        key: const ValueKey('summary-categories-count'),
      ),
      loading: () => _buildCardPlaceholder(theme),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _wrapCard(
      {Key? reorderKey, required Widget child, VoidCallback? onRemove}) {
    final widget = reorderKey != null
        ? KeyedSubtree(key: reorderKey, child: child)
        : child;
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

  Widget _buildCardPlaceholder(ThemeData theme, {Key? key}) {
    return Padding(
      key: key,
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
      if (!Platform.isWindows) ('scan_receipt', l10n.scan, Icons.document_scanner_outlined),
      ('accounts', l10n.accounts, Platform.isWindows ? Icons.account_balance : Icons.account_balance),
      ('contacts', l10n.contacts, Icons.people_outline_rounded),
      ('receivables', l10n.receivableTag, Platform.isWindows ? Icons.account_balance_wallet : Icons.account_balance_wallet),
      ('payables', l10n.payables, Icons.payment_outlined),
      ('categories', l10n.categories, Icons.category_outlined),
      ('analytics', l10n.analytics, Icons.bar_chart_rounded),
      ('user_guide', l10n.userGuide, Icons.help_outline_rounded),
      ('app_tour', l10n.appTour, Icons.tour_outlined),
    ];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          // Re-watch the layout to get live updates if needed,
          // but we can also just use the local state for the modal.
          final currentLayout = ref.watch(dashboardWidgetLayoutProvider).value;
          if (currentLayout == null || layoutIndex >= currentLayout.length) {
            return const SizedBox.shrink();
          }
          final currentConfig = currentLayout[layoutIndex];
          final selectedCodes = currentConfig.quickActionCodes ?? [];

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    l10n.quickActions,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: actions.map((e) {
                          final isSelected = selectedCodes.contains(e.$1);
                          return FilterChip(
                            avatar: Icon(
                              e.$3,
                              size: 18,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            label: Text(e.$2),
                            selected: isSelected,
                            showCheckmark: false,
                            onSelected: (selected) {
                              final newList = List<String>.from(selectedCodes);
                              if (selected) {
                                if (!newList.contains(e.$1)) {
                                  newList.add(e.$1);
                                }
                              } else {
                                newList.remove(e.$1);
                              }

                              ref
                                  .read(dashboardWidgetLayoutProvider.notifier)
                                  .setQuickActionsOnDashboard(
                                      layoutIndex, newList);
                            },
                            selectedColor: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.dividerColor,
                              width: isSelected ? 2 : 1,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(l10n.done),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openTransactionsFiltered(
      WidgetRef ref, BuildContext context, DashboardFilter filter) {
    final isMonthly = filter == DashboardFilter.monthly;
    final now = DateTime.now();
    final startDate = isMonthly ? DateTime(now.year, now.month, 1) : null;
    final endDate = isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
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
    final startDate = isMonthly ? DateTime(now.year, now.month, 1) : null;
    final endDate = isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
    ref.read(receivablesPaginatedProvider('PENDING').notifier).applyFilters(
        ReceivableFilters(startDate: startDate, endDate: endDate));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReceivablesListScreen()),
    );
  }

  void _openPayables(
      WidgetRef ref, BuildContext context, DashboardFilter filter) {
    final isMonthly = filter == DashboardFilter.monthly;
    final now = DateTime.now();
    final startDate = isMonthly ? DateTime(now.year, now.month, 1) : null;
    final endDate = isMonthly ? DateTime(now.year, now.month + 1, 0) : null;
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: reorderMode
                ? BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  )
                : null,
            padding:
                reorderMode ? const EdgeInsets.symmetric(vertical: 16) : null,
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.grid_view_rounded, size: 20),
                              onPressed: () =>
                                  _showQuickActionSelectionSheetForWidget(
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
                      int crossAxisCount =
                          (availableWidth / minItemWidth).floor();
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
                              config.quickActionCodes!
                                  .contains('add_transaction'))
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
                          if (!Platform.isWindows &&
                              (config.quickActionCodes == null ||
                                  config.quickActionCodes!
                                      .contains('scan_receipt')))
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
                                    builder: (context) =>
                                        const AccountsScreen(),
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
                                    builder: (context) =>
                                        const ContactsListScreen(),
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
                                pendingNotifier
                                    .applyFilters(ReceivableFilters());

                                final overdueNotifier = ref.read(
                                    receivablesPaginatedProvider('OVERDUE')
                                        .notifier);
                                overdueNotifier.updateSearchQuery('');
                                overdueNotifier
                                    .applyFilters(ReceivableFilters());

                                final receivedNotifier = ref.read(
                                    receivablesPaginatedProvider('RECEIVED')
                                        .notifier);
                                receivedNotifier.updateSearchQuery('');
                                receivedNotifier
                                    .applyFilters(ReceivableFilters());

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
                                    payablesPaginatedProvider('PENDING')
                                        .notifier);
                                pendingNotifier.updateSearchQuery('');
                                pendingNotifier.applyFilters(PayableFilters());

                                final overdueNotifier = ref.read(
                                    payablesPaginatedProvider('OVERDUE')
                                        .notifier);
                                overdueNotifier.updateSearchQuery('');
                                overdueNotifier.applyFilters(PayableFilters());

                                final paidNotifier = ref.read(
                                    payablesPaginatedProvider('PAID').notifier);
                                paidNotifier.updateSearchQuery('');
                                paidNotifier.applyFilters(PayableFilters());

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PayablesListScreen(),
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
                                    builder: (context) =>
                                        const AnalyticsScreen(),
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
                                    builder: (context) =>
                                        const UserGuideScreen(),
                                  ),
                                );
                              },
                            ),
                          if (config.quickActionCodes == null ||
                              config.quickActionCodes!.contains('app_tour'))
                            _QuickActionButton(
                              icon: Icons.tour_outlined,
                              label: l10n.appTour,
                              gradient:
                                  AppColors.getPrimaryGradient(activeColor),
                              onTap: () {
                                // Start the onboarding screen again
                                ref
                                    .read(onboardingCompletedProvider.notifier)
                                    .setCompleted(false);
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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

class _IncomeExpenseTrendChart extends StatefulWidget {
  final List<DailyNetAmount> data;
  final ThemeData theme;
  final AppLocalizations l10n;
  final double budget;
  final Color color;
  final String symbol;
  final int decimals;
  final String? dateFormat;

  const _IncomeExpenseTrendChart({
    required this.data,
    required this.theme,
    required this.l10n,
    required this.budget,
    required this.color,
    required this.symbol,
    required this.decimals,
    this.dateFormat,
  });

  @override
  State<_IncomeExpenseTrendChart> createState() =>
      _IncomeExpenseTrendChartState();
}

class _IncomeExpenseTrendChartState extends State<_IncomeExpenseTrendChart> {
  int? _touchedIndex;

  void _moveSelection(int direction) {
    // direction: -1 for left (previous), 1 for right (next)
    final dataIndices = <int>[];
    for (int i = 0; i < widget.data.length; i++) {
      if (widget.data[i].hasData) {
        dataIndices.add(i);
      }
    }

    if (dataIndices.isEmpty) return;

    int newIndex;
    if (_touchedIndex == null) {
      // If nothing selected, select first or last based on direction
      newIndex = direction > 0 ? dataIndices.first : dataIndices.last;
    } else {
      int currentPos = dataIndices.indexOf(_touchedIndex!);
      if (currentPos == -1) {
        // Fallback if current index somehow not in dataIndices
        newIndex = direction > 0 ? dataIndices.first : dataIndices.last;
      } else {
        // Move to next/previous and wrap around
        int nextPos = currentPos + direction;
        if (nextPos < 0) {
          nextPos = dataIndices.length - 1;
        } else if (nextPos >= dataIndices.length) {
          nextPos = 0;
        }
        newIndex = dataIndices[nextPos];
      }
    }

    setState(() {
      _touchedIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spots = widget.data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.netAmount);
    }).toList();

    double minY = spots.map((s) => s.y).reduce(min);
    double maxY = spots.map((s) => s.y).reduce(max);

    if (widget.budget > 0) {
      minY = min(minY, widget.budget);
      maxY = max(maxY, widget.budget);
    }

    final yRange = maxY - minY;
    final yPadding = yRange == 0 ? 10.0 : yRange * 0.15;
    minY -= yPadding;
    maxY += yPadding;

    final barData = LineChartBarData(
      spots: spots,
      isCurved: false,
      color: Colors.white,
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final isSelected = index == _touchedIndex;
          final hasData = widget.data[index].hasData;
          return FlDotCirclePainter(
            radius: isSelected ? 4.5 : (hasData ? 1.5 : 0),
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
            strokeWidth: isSelected ? 2 : 0,
            strokeColor: widget.color,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return TapRegion(
      onTapOutside: (event) {
        if (_touchedIndex != null) {
          setState(() {
            _touchedIndex = null;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            return Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(12, 24, 24, 12),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: yRange > 0 ? yRange / 4 : 1,
                    verticalInterval: spots.length > 1 ? (spots.length - 1) / 4 : 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.white.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: spots.length > 1 ? (spots.length - 1) / 3 : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= widget.data.length) {
                            return const SizedBox.shrink();
                          }
                          final date = widget.data[index].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              AppDateFormatter.formatDate(date, pattern: 'dd/MM'),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: yRange > 0 ? yRange / 3 : 1,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            AmountFormatter.formatCompactAmount(value),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  showingTooltipIndicators: _touchedIndex != null
                      ? [
                          ShowingTooltipIndicators([
                            LineBarSpot(
                              barData,
                              0,
                              spots[_touchedIndex!],
                            ),
                          ])
                        ]
                      : [],
                  lineBarsData: [barData],
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      if (widget.budget > 0)
                        HorizontalLine(
                          y: widget.budget,
                          color: Colors.white.withValues(alpha: 0.6),
                          strokeWidth: 2,
                          dashArray: [5, 5],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 8, bottom: 4),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                            labelResolver: (line) =>
                                '${widget.l10n.budget}: ${AmountFormatter.formatWithCurrency(widget.budget, widget.symbol, widget.decimals)}',
                          ),
                        ),
                    ],
                  ),
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: false,
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      if (event is FlTapDownEvent ||
                          event is FlPanStartEvent ||
                          event is FlPanUpdateEvent) {
                        if (touchResponse != null &&
                            touchResponse.lineBarSpots != null &&
                            touchResponse.lineBarSpots!.isNotEmpty) {
                          final index =
                              touchResponse.lineBarSpots!.first.x.toInt();
                          if (widget.data[index].hasData &&
                              _touchedIndex != index) {
                            setState(() => _touchedIndex = index);
                          }
                        }
                        return;
                      }

                      if (event is FlTapUpEvent) {
                        if (touchResponse != null &&
                            touchResponse.lineBarSpots != null &&
                            touchResponse.lineBarSpots!.isNotEmpty) {
                          final index =
                              touchResponse.lineBarSpots!.first.x.toInt();
                          if (widget.data[index].hasData) {
                            setState(() => _touchedIndex = index);
                          }
                        }
                      }
                    },
                    getTouchedSpotIndicator:
                        (LineChartBarData barData, List<int> spotIndexes) {
                      return spotIndexes.map((index) {
                        if (!widget.data[index].hasData) {
                          return TouchedSpotIndicatorData(
                            const FlLine(
                                color: Colors.transparent, strokeWidth: 0),
                            const FlDotData(show: false),
                          );
                        }
                        return TouchedSpotIndicatorData(
                          FlLine(
                              color: Colors.white.withValues(alpha: 0.3),
                              strokeWidth: 2),
                          FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: widget.color,
                              );
                            },
                          ),
                        );
                      }).toList();
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => Colors.white,
                      tooltipBorderRadius: BorderRadius.circular(12),
                      maxContentWidth: 300,
                      fitInsideHorizontally: true,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final dayData = widget.data[spot.x.toInt()];
                          if (!dayData.hasData) return null;

                          final dateStr = AppDateFormatter.formatDate(
                              dayData.date,
                              pattern: widget.dateFormat ?? 'dd MMM yyyy');
                          final incrementalStr =
                              AmountFormatter.formatWithCurrency(
                                  spot.y, widget.symbol, widget.decimals);
                          final netStr = AmountFormatter.formatWithCurrency(
                              dayData.dailyNet, widget.symbol, widget.decimals);
                          final count = dayData.transactionCount;

                          return LineTooltipItem(
                            '',
                            const TextStyle(),
                            textAlign: TextAlign.center,
                            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                            children: [
                              TextSpan(
                                text: '$dateStr\n',
                                style: widget.theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: '${widget.l10n.transactions}: ',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                              TextSpan(
                                text: '$count\n',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                              TextSpan(
                                text: '${widget.l10n.netBalance}: ',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                              TextSpan(
                                text: '$netStr\n',
                                style: TextStyle(
                                  color: widget.color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: '${widget.l10n.totalBalance}: ',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                              TextSpan(
                                text: '$incrementalStr',
                                style: TextStyle(
                                  color: widget.color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filled(
                  onPressed: () {
                    if (_touchedIndex == null) return;
                    final dayData = widget.data[_touchedIndex!];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionsListScreen(
                          initialDate: dayData.date,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: _touchedIndex == null
                        ? Colors.white.withValues(alpha: 0.15)
                        : widget.color,
                    foregroundColor: Colors.white.withValues(
                        alpha: _touchedIndex == null ? 0.3 : 1.0),
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(36, 36),
                  ),
                  tooltip: widget.l10n.showDetails,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _moveSelection(isRtl ? 1 : -1);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        _moveSelection(isRtl ? -1 : 1);
                      },
                      icon: const Icon(Icons.arrow_forward_ios, size: 18),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



