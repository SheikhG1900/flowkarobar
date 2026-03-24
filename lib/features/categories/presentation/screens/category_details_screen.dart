import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/shared/widgets/dual_amount_progress_bar.dart';
import 'package:flowpaisa/features/categories/presentation/widgets/category_budget_date_range_selector.dart';
import 'package:flowpaisa/features/categories/presentation/widgets/set_category_budget_sheet.dart';
import 'package:flowpaisa/features/categories/presentation/screens/edit_category_screen.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flutter/services.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/whatsapp/domain/deep_link_service.dart';
import 'package:flowpaisa/features/dashboard/domain/dashboard_widget_models.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_widget_provider.dart';
import 'package:flowpaisa/shared/models/date_range_state.dart';
import 'package:flowpaisa/features/categories/domain/category_budget_models.dart';

class CategoryDetailsScreen extends ConsumerWidget {
  final String categoryUuid;

  const CategoryDetailsScreen({super.key, required this.categoryUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final budgetAsync = ref.watch(categoryDetailBudgetProvider(categoryUuid));
    final currencySymbol = ref.watch(currencySymbolProvider);
    final decimalPlaces = ref.watch(currencyDecimalPlacesProvider);
    final selectedDateRange = ref.watch(categoryBudgetDateRangeProvider);

    return budgetAsync.when(
      skipLoadingOnReload: true,
      data: (snapshot) {
        final category = snapshot.category;
        final isExpense = category.type == 'EXPENSE';
        final color = category.color != null
            ? Color(int.parse(category.color!.replaceAll('#', '0xFF')))
            : (isExpense ? AppColors.expenseColor : AppColors.incomeColor);

        return Scaffold(
            appBar: AppBar(
              title: Text(l10n.categoryDetails),
              actions: [
                IconButton(
                  icon: const Icon(Icons.link),
                  tooltip: l10n.copyLink,
                  onPressed: () {
                    final link = DeepLinkService()
                        .generateEntityOpenLinkHttps('category', category.uuid);
                    Clipboard.setData(ClipboardData(text: link));
                    ToastUtils.showSuccessToast(context, ref, l10n.linkCopied);
                  },
                ),
                Builder(
                  builder: (context) {
                    ref.watch(dashboardWidgetLayoutProvider);
                    final notifier =
                        ref.read(dashboardWidgetLayoutProvider.notifier);
                    final isPinned = notifier.isPinned(
                        DashboardWidgetKind.category, category.uuid);
                    return IconButton(
                      icon: Icon(
                        isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: isPinned
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      tooltip: isPinned
                          ? l10n.unpinFromDashboard
                          : l10n.pinToDashboard,
                      onPressed: () async {
                        if (isPinned) {
                          final layout = ref
                                  .read(dashboardWidgetLayoutProvider)
                                  .value ??
                              [];
                          final idx = layout.indexWhere((c) =>
                              c.kind == DashboardWidgetKind.category &&
                              c.categoryUuid == category.uuid);
                          if (idx >= 0) {
                            await ref
                                .read(dashboardWidgetLayoutProvider.notifier)
                                .removeAt(idx);
                            if (context.mounted) {
                              ToastUtils.showSuccessToast(context, ref,
                                  l10n.unpinnedFromDashboard);
                            }
                          }
                        } else {
                          await ref
                              .read(dashboardWidgetLayoutProvider.notifier)
                              .addWidget(DashboardWidgetConfig(
                                  kind: DashboardWidgetKind.category,
                                  categoryUuid: category.uuid));
                          if (context.mounted) {
                            ToastUtils.showSuccessToast(
                                context, ref, l10n.pinnedToDashboard);
                          }
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditCategoryScreen(category: category),
                      ),
                    );
                    if (updated == true) {
                      ref.invalidate(categoryDetailBudgetProvider(categoryUuid));
                      ref.invalidate(categoriesByTypeProvider);
                    }
                  },
                ),
              ],
            ),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.1),
                          theme.scaffoldBackgroundColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'category_icon_${category.uuid}',
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: CategoryHelper.buildCategoryIcon(
                                category.icon, color, isExpense,
                                size: 40),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          LocalizationHelper.getLocalizedCategoryName(
                              context, category.name),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isExpense ? l10n.expense : l10n.income,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CategoryBudgetDateRangeSelector(
                          selectedDateRange: selectedDateRange,
                          onDateRangeChanged: (dateRange) {
                            ref
                                .read(categoryBudgetDateRangeProvider.notifier)
                                .updateRange(dateRange);
                          },
                          onNextPeriod: () {
                            ref
                                .read(categoryBudgetDateRangeProvider.notifier)
                                .nextPeriod();
                          },
                          onPreviousPeriod: () {
                            ref
                                .read(categoryBudgetDateRangeProvider.notifier)
                                .previousPeriod();
                          },
                        ),
                        const SizedBox(height: 24),

                        // Summary / budget card
                        _CategoryBudgetSummarySection(
                          snapshot: snapshot,
                          categoryUuid: categoryUuid,
                          selectedDateRange: selectedDateRange,
                          color: color,
                          isExpense: isExpense,
                          currencySymbol: currencySymbol,
                          decimalPlaces: decimalPlaces,
                          l10n: l10n,
                          onOpenTransactions: () async {
                            ref
                                .read(transactionsPaginatedProvider.notifier)
                                .applyFilters(
                                  TransactionFilters(
                                    categoryUuids: [categoryUuid],
                                    startDate: selectedDateRange.startDate,
                                    endDate: selectedDateRange.endDate,
                                  ),
                                );
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TransactionsListScreen(),
                              ),
                            );
                            ref.invalidate(
                                categoryDetailBudgetProvider(categoryUuid));
                          },
                          onSetBudget: () {
                            showSetCategoryBudgetSheet(
                              context,
                              category: category,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Transaction Count Card - same tap as summary: open filtered transactions list
                        InkWell(
                          onTap: () async {
                            ref
                                .read(transactionsPaginatedProvider.notifier)
                                .applyFilters(
                                  TransactionFilters(
                                    categoryUuids: [categoryUuid],
                                    startDate: selectedDateRange.startDate,
                                    endDate: selectedDateRange.endDate,
                                  ),
                                );
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TransactionsListScreen(),
                              ),
                            );
                            ref.invalidate(
                                categoryDetailBudgetProvider(categoryUuid));
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.dividerColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.receipt_long_outlined,
                                      color: color, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.transactions,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color:
                                              theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        '${snapshot.transactionCount} ${l10n.transactions.toLowerCase()}',
                                        style:
                                            theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.categoryDetails)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(l10n.categoryDetails)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.errorOccurred(error.toString()),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBudgetSummarySection extends StatelessWidget {
  final CategoryBudgetSnapshot snapshot;
  final String categoryUuid;
  final DateRangeState selectedDateRange;
  final Color color;
  final bool isExpense;
  final String currencySymbol;
  final int decimalPlaces;
  final AppLocalizations l10n;
  final Future<void> Function() onOpenTransactions;
  final VoidCallback onSetBudget;

  const _CategoryBudgetSummarySection({
    required this.snapshot,
    required this.categoryUuid,
    required this.selectedDateRange,
    required this.color,
    required this.isExpense,
    required this.currencySymbol,
    required this.decimalPlaces,
    required this.l10n,
    required this.onOpenTransactions,
    required this.onSetBudget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netStr = AmountFormatter.formatWithCurrency(
      snapshot.netAmount,
      currencySymbol,
      decimalPlaces,
    );
    final budgetStr = snapshot.budgetAmount != null
        ? AmountFormatter.formatWithCurrency(
            snapshot.budgetAmount!,
            currencySymbol,
            decimalPlaces,
          )
        : '';

    final gradientCardDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [color, color.withValues(alpha: 0.82)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );

    final hasBudget = snapshot.hasBudget;
    final pr = hasBudget ? snapshot.progressRatio : 0.0;
    final over = hasBudget && pr > 1.0;
    final barFillColor = over ? AppColors.expenseColor : color;

    final net = snapshot.netAmount;
    final barRightAmount = hasBudget && snapshot.remainingOrGap > 0
        ? snapshot.remainingOrGap
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: gradientCardDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: onOpenTransactions,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    hasBudget ? 16 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 44),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    isExpense
                                        ? l10n.netExpenses
                                        : l10n.netIncome,
                                    textAlign: TextAlign.center,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white
                                          .withValues(alpha: 0.85),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    netStr,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineLarge
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                      height: 1.1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PositionedDirectional(
                              end: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasBudget) ...[
                        const SizedBox(height: 16),
                        Text(
                          isExpense
                              ? l10n.spendingBudget
                              : l10n.savingsTarget,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          budgetStr,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Center(
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      foregroundColor: color,
                      backgroundColor: Colors.white.withValues(alpha: 0.94),
                    ),
                    onPressed: onSetBudget,
                    icon: Icon(
                      isExpense
                          ? Icons.account_balance_wallet_outlined
                          : Icons.savings_outlined,
                      size: 20,
                    ),
                    label: Text(
                      hasBudget ? l10n.editBudget : l10n.setBudget,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasBudget) ...[
          const SizedBox(height: 12),
          DualAmountProgressBar(
            leftLabel:
                isExpense ? l10n.budgetBarUsed : l10n.budgetBarProgress,
            leftAmount: net > 0 ? net : 0.0,
            rightLabel: l10n.remaining,
            rightAmount: barRightAmount,
            symbol: currencySymbol,
            decimals: decimalPlaces,
            filledColor: barFillColor,
          ),
        ],
      ],
    );
  }
}
