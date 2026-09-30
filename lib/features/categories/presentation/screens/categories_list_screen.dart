import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/categories/presentation/screens/add_category_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/edit_category_screen.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/categories/presentation/screens/category_details_screen.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';
import 'package:flowpaisa/core/utils/category_budget_utils.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/categories/presentation/widgets/category_budget_date_range_selector.dart';
import 'package:flowpaisa/features/categories/presentation/widgets/category_budget_progress_bar.dart';
import 'package:flowpaisa/shared/models/date_range_state.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/dual_amount_progress_bar.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';

class CategoriesListScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const CategoriesListScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<CategoriesListScreen> createState() =>
      _CategoriesListScreenState();
}

class _CategoriesListScreenState extends ConsumerState<CategoriesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _tabController.index == 0
              ? AppColors.expenseColor
              : AppColors.incomeColor,
          tabs: [
            Tab(text: l10n.expense),
            Tab(text: l10n.income),
          ],
          onTap: (index) {
            setState(() {}); // Rebuild to update indicator color
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CategoryList(type: 'EXPENSE'),
          _CategoryList(type: 'INCOME'),
        ],
      ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCategoryScreen(),
            ),
          );
        },
        backgroundColor: _tabController.index == 0
            ? AppColors.expenseColor
            : AppColors.incomeColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  final String type;

  const _CategoryList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider(type));
    final l10n = AppLocalizations.of(context)!;

    return categoriesAsync.when(
      skipLoadingOnRefresh: true,
      data: (categories) {
        return _CategoryListBody(
          key: ValueKey('category-list-body-$type'),
          type: type,
          categories: categories,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text(l10n.errorOccurred(error.toString()))),
    );
  }
}

class _CategoryListBody extends ConsumerWidget {
  final String type;
  final List<Category> categories;

  const _CategoryListBody({
    super.key,
    required this.type,
    required this.categories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final range = ref.watch(categoryBudgetDateRangeProvider);
    final netsAsync = ref.watch(categoryNetAmountsForListProvider(type));
    final overallNetsAsync = ref.watch(overallCategoryNetAmountsForListProvider(type));

    final dateHeader = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: CategoryBudgetDateRangeSelector(
        selectedDateRange: range,
        onDateRangeChanged: (dateRange) {
          ref.read(categoryBudgetDateRangeProvider.notifier).updateRange(dateRange);
        },
        onNextPeriod: () {
          ref.read(categoryBudgetDateRangeProvider.notifier).nextPeriod();
        },
        onPreviousPeriod: () {
          ref.read(categoryBudgetDateRangeProvider.notifier).previousPeriod();
        },
      ),
    );

    return netsAsync.when(
      skipLoadingOnRefresh: true,
      data: (nets) {
        return overallNetsAsync.when(
          skipLoadingOnRefresh: true,
          data: (overallNets) {
            if (categories.isEmpty) {
              final typeLabel = type == 'EXPENSE' ? l10n.expense : l10n.income;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: dateHeader),
                  const SliverToBoxAdapter(child: SizedBox(height: 4)),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.category,
                            size: 80,
                            color: theme.colorScheme.outline.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noTypeCategories(typeLabel),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: dateHeader),
                const SliverToBoxAdapter(child: SizedBox(height: 4)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _CategoriesAggregateSummary(
                      type: type,
                      categories: categories,
                      nets: nets,
                      overallNets: overallNets,
                      range: range,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                      16, 0, 16, 80 + MediaQuery.of(context).padding.bottom),
                  sliver: SliverList(
                    key: ValueKey('category-list-$type'),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = categories[index];
                        final net = nets[category.uuid] ?? 0.0;
                        final overallNet = overallNets[category.uuid] ?? 0.0;
                        final isPremium = ref.watch(premiumProvider).isPremium;
                        final isLocked = !isPremium &&
                            !category.isDefault &&
                            (category.addSeq ?? 0) > PremiumGate.categoryTotalLimit;
                        final isBudgetLocked = !isPremium &&
                            (category.budgetSeq ?? 0) >
                                PremiumGate.categoryBudgetTotalLimit;

                        return _CategoryCard(
                          key: ValueKey('category-card-${category.uuid}'),
                          category: category,
                          netAmount: net,
                          overallNetAmount: overallNet,
                          dateRange: range,
                          isLocked: isLocked,
                          isBudgetLocked: isBudgetLocked,
                        );
                      },
                      childCount: categories.length,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: dateHeader),
              const SliverToBoxAdapter(child: SizedBox(height: 4)),
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          error: (e, _) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: dateHeader),
              const SliverToBoxAdapter(child: SizedBox(height: 4)),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.errorOccurred(e.toString()),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: dateHeader),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (e, _) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: dateHeader),
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.errorOccurred(e.toString()),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sum of net amounts and combined budgets for every category in this tab for [range].
class _CategoriesAggregateSummary extends ConsumerWidget {
  final String type;
  final List<Category> categories;
  final Map<String, double> nets;
  final Map<String, double> overallNets;
  final DateRangeState range;

  const _CategoriesAggregateSummary({
    required this.type,
    required this.categories,
    required this.nets,
    required this.overallNets,
    required this.range,
  });

  String _getPeriodText(BuildContext context) {
    switch (range.type) {
      case DateRangeType.month:
        return AppDateFormatter.formatMonthYear(range.startDate,
            context: context);
      case DateRangeType.quarter:
        final quarter = ((range.startDate.month - 1) ~/ 3) + 1;
        return 'Q$quarter ${AppDateFormatter.getFormatter('y').format(range.startDate)}';
      case DateRangeType.year:
        return AppDateFormatter.getFormatter('y')
            .format(range.startDate);
      case DateRangeType.custom:
        return '${AppDateFormatter.formatDate(range.startDate)} - ${AppDateFormatter.formatDate(range.endDate)}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isExpense = type == 'EXPENSE';
    final color =
        isExpense ? AppColors.expenseColor : AppColors.incomeColor;
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) return const SizedBox.shrink();

    double categorizedNet = 0;
    double totalBudgetCap = 0;
    double overallCategorizedNet = 0;
    double overallTotalBudgetCap = 0;
    final isPremium = ref.watch(premiumProvider).isPremium;

    for (final c in categories) {
      categorizedNet += nets[c.uuid] ?? 0;
      overallCategorizedNet += overallNets[c.uuid] ?? 0;

      final isCatLocked = !isPremium &&
          !c.isDefault &&
          (c.addSeq ?? 0) > PremiumGate.categoryTotalLimit;
      final isBudgetLocked = !isPremium &&
          (c.budgetSeq ?? 0) > PremiumGate.categoryBudgetTotalLimit;

      if (!isCatLocked && !isBudgetLocked) {
        final b = budgetAmountForPeriod(c, range);
        if (b != null && b > 0) {
          totalBudgetCap += b;
        }
        final ob = c.overallBudget;
        if (ob != null && ob > 0) {
          overallTotalBudgetCap += ob;
        }
      }
    }

    final uncategorizedAsync =
        ref.watch(uncategorizedAmountByTypeProvider(type));
    final uncategorizedAmt = uncategorizedAsync.maybeWhen(
      data: (v) => v,
      orElse: () => 0.0,
    );

    final overallUncategorizedAsync =
        ref.watch(overallUncategorizedAmountByTypeProvider(type));
    final overallUncategorizedAmt = overallUncategorizedAsync.maybeWhen(
      data: (v) => v,
      orElse: () => 0.0,
    );

    final includeAsync =
        ref.watch(includeUncategorizedInCategorySummaryProvider);
    final includeUncategorized = includeAsync.maybeWhen(
      data: (v) => v,
      orElse: () => false,
    );

    final totalNet = categorizedNet +
        (includeUncategorized ? uncategorizedAmt : 0.0);
    final overallTotalNet = overallCategorizedNet +
        (includeUncategorized ? overallUncategorizedAmt : 0.0);

    final hasBudget = totalBudgetCap > 0;
    final pr = hasBudget ? totalNet / totalBudgetCap : 0.0;
    final over = hasBudget && isExpense && pr > 1.0;
    final barFillColor = over ? AppColors.expenseColor : color;
    final remaining = hasBudget ? totalBudgetCap - totalNet : 0.0;

    final hasOverallBudget = overallTotalBudgetCap > 0;
    final overallPr = hasOverallBudget ? overallTotalNet / overallTotalBudgetCap : 0.0;
    final overallOver = hasOverallBudget && isExpense && overallPr > 1.0;
    final overallBarFillColor = overallOver ? AppColors.expenseColor : color;
    final overallRemaining = hasOverallBudget ? overallTotalBudgetCap - overallTotalNet : 0.0;

    final netStr = AmountFormatter.formatWithCurrency(
      totalNet,
      currency,
    );
    final overallNetStr = AmountFormatter.formatWithCurrency(
      overallTotalNet,
      currency,
    );
    final uncategorizedStr = AmountFormatter.formatWithCurrency(
      uncategorizedAmt,
      currency,
    );
    final overallUncategorizedStr = AmountFormatter.formatWithCurrency(
      overallUncategorizedAmt,
      currency,
    );
    final budgetStr = AmountFormatter.formatWithCurrency(
      totalBudgetCap,
      currency,
    );
    final overallBudgetStr = AmountFormatter.formatWithCurrency(
      overallTotalBudgetCap,
      currency,
    );

    final leftStr = AmountFormatter.formatWithCurrency(
      remaining > 0 ? remaining : 0.0,
      currency,
    );
    final overallLeftStr = AmountFormatter.formatWithCurrency(
      overallRemaining > 0 ? overallRemaining : 0.0,
      currency,
    );

    final leftPr = hasBudget ? (remaining > 0 ? remaining : 0.0) / totalBudgetCap : 1.0;
    final overallLeftPr = hasOverallBudget ? (overallRemaining > 0 ? overallRemaining : 0.0) / overallTotalBudgetCap : 1.0;

    // Labels and metrics based on category type (Expense vs Income Target)
    final targetLabel = isExpense ? '${l10n.limitLabel}: ' : '${l10n.targetLabel}: ';

    // Period Budget Label & Value
    final String leftLabel;
    final String leftAmountStr;
    final Color leftColor;
    final double leftPercentage;

    if (isExpense) {
      leftLabel = '${l10n.leftLabel}: ';
      final amt = remaining > 0 ? remaining : 0.0;
      leftAmountStr = AmountFormatter.formatWithCurrency(amt, currency);
      leftColor = remaining > 0 ? AppColors.incomeColor : AppColors.expenseColor;
      leftPercentage = leftPr;
    } else {
      // For Income
      if (remaining > 0) {
        // Under target (Shortfall)
        leftLabel = '${l10n.needed}: ';
        leftAmountStr = AmountFormatter.formatWithCurrency(remaining, currency);
        leftColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8);
        leftPercentage = leftPr;
      } else {
        // Achieved / Surplus
        leftLabel = '${l10n.surplus}: ';
        final surplusAmt = totalNet - totalBudgetCap;
        leftAmountStr = AmountFormatter.formatWithCurrency(surplusAmt, currency);
        leftColor = AppColors.incomeColor;
        leftPercentage = totalBudgetCap > 0 ? surplusAmt / totalBudgetCap : 0.0;
      }
    }

    // Overall Budget Label & Value
    final String overallLeftLabel;
    final String overallLeftAmountStr;
    final Color overallLeftColor;
    final double overallLeftPercentage;

    if (isExpense) {
      overallLeftLabel = '${l10n.leftLabel}: ';
      final amt = overallRemaining > 0 ? overallRemaining : 0.0;
      overallLeftAmountStr = AmountFormatter.formatWithCurrency(amt, currency);
      overallLeftColor = overallRemaining > 0 ? AppColors.incomeColor : AppColors.expenseColor;
      overallLeftPercentage = overallLeftPr;
    } else {
      // For Income
      if (overallRemaining > 0) {
        // Under target (Shortfall)
        overallLeftLabel = '${l10n.needed}: ';
        overallLeftAmountStr = AmountFormatter.formatWithCurrency(overallRemaining, currency);
        overallLeftColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8);
        overallLeftPercentage = overallLeftPr;
      } else {
        // Achieved / Surplus
        overallLeftLabel = '${l10n.surplus}: ';
        final surplusAmt = overallTotalNet - overallTotalBudgetCap;
        overallLeftAmountStr = AmountFormatter.formatWithCurrency(surplusAmt, currency);
        overallLeftColor = AppColors.incomeColor;
        overallLeftPercentage = overallTotalBudgetCap > 0 ? surplusAmt / overallTotalBudgetCap : 0.0;
      }
    }

    final isDarkMode = theme.brightness == Brightness.dark;
    final cardDecoration = BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.dividerColor.withValues(alpha: 0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkMode ? 0.08 : 0.03),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );

    final prefsReady = includeAsync.hasValue;

    final hasAnyBudget = hasBudget || hasOverallBudget;

    return Column(
      key: ValueKey('categories-aggregate-summary-$type'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: ValueKey('categories-aggregate-container-$type'),
          clipBehavior: Clip.antiAlias,
          decoration: cardDecoration,
          child: Stack(
            children: [
              if (hasBudget)
                Positioned.fill(
                  key: ValueKey('categories-aggregate-progress-bg-$type'),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: pr.isFinite ? pr.clamp(0.0, 1.0) : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: barFillColor.withValues(
                            alpha: isDarkMode ? 0.12 : 0.08,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Column(
                key: ValueKey('categories-aggregate-content-$type'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    key: ValueKey('categories-aggregate-inkwell-$type'),
                    onTap: () async {
                      ref.read(transactionsPaginatedProvider.notifier).applyFilters(
                            TransactionFilters(
                              startDate: range.startDate,
                              endDate: range.endDate,
                              type: type,
                            ),
                          );
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionsListScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _getPeriodText(context),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (hasBudget) ...[
                                        const SizedBox(height: 6),
                                        // Total Limit / Target
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              targetLabel,
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              budgetStr,
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        // Large consumed number
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              netStr,
                                              style: theme.textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: color,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: barFillColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: barFillColor.withValues(alpha: 0.2),
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: Text(
                                                '${(pr * 100).round()}%',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: barFillColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        // Left/Needed/Surplus beside %
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              leftLabel,
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              leftAmountStr,
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: leftColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: leftColor.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(5),
                                                border: Border.all(
                                                  color: leftColor.withValues(alpha: 0.15),
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: Text(
                                                '${(leftPercentage * 100).round()}%',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: leftColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 8,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else ...[
                                        // Standard simple number representation when no budget set
                                        const SizedBox(height: 6),
                                        Text(
                                          netStr,
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: color,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: hasAnyBudget ? 74 : 36,
                                  color: theme.dividerColor.withValues(alpha: 0.3),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        l10n.overall,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (hasOverallBudget) ...[
                                        const SizedBox(height: 6),
                                        // Overall Total Limit / Target
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              targetLabel,
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              overallBudgetStr,
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        // Large overall consumed number
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              overallNetStr,
                                              style: theme.textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: color.withValues(alpha: 0.85),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: overallBarFillColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: overallBarFillColor.withValues(alpha: 0.2),
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: Text(
                                                '${(overallPr * 100).round()}%',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: overallBarFillColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        // Overall Left/Needed/Surplus beside %
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              overallLeftLabel,
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              overallLeftAmountStr,
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: overallLeftColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: overallLeftColor.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(5),
                                                border: Border.all(
                                                  color: overallLeftColor.withValues(alpha: 0.15),
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: Text(
                                                '${(overallLeftPercentage * 100).round()}%',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: overallLeftColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 8,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ] else ...[
                                        // Standard simple number representation when no overall budget set
                                        const SizedBox(height: 6),
                                        Text(
                                          overallNetStr,
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: color.withValues(alpha: 0.85),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            PositionedDirectional(
                              end: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.06),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 10,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    key: ValueKey('categories-aggregate-divider-$type'),
                    height: 1,
                    thickness: 1,
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Row(
                      key: ValueKey('categories-aggregate-uncategorized-row-$type'),
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            key: ValueKey('categories-aggregate-uncategorized-col-$type'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                key: ValueKey('categories-aggregate-uncategorized-label-$type'),
                                l10n.uncategorized,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.78),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    uncategorizedStr,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '|',
                                    style: TextStyle(
                                      color: theme.dividerColor.withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    overallUncategorizedStr,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          key: ValueKey('categories-aggregate-uncategorized-chip-$type'),
                          showCheckmark: true,
                          selected: includeUncategorized,
                          label: Text(
                            l10n.categoriesSummaryIncludeInTotal,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: includeUncategorized
                                  ? color
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          selectedColor: color.withValues(alpha: 0.12),
                          backgroundColor: Colors.transparent,
                          checkmarkColor: color,
                          side: BorderSide(
                            color: includeUncategorized
                                ? color.withValues(alpha: 0.3)
                                : theme.dividerColor.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          onSelected: prefsReady
                              ? (selected) {
                                  ref
                                      .read(
                                        includeUncategorizedInCategorySummaryProvider
                                            .notifier,
                                      )
                                      .setInclude(selected);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hasOverallBudget)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: overallPr.isFinite ? overallPr.clamp(0.0, 1.0) : 0.0,
                    child: Container(
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: overallBarFillColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _CategoryCard extends ConsumerStatefulWidget {
  final Category category;
  final double netAmount;
  final double overallNetAmount;
  final DateRangeState dateRange;
  final bool isLocked;
  final bool isBudgetLocked;

  const _CategoryCard({
    super.key,
    required this.category,
    required this.netAmount,
    required this.overallNetAmount,
    required this.dateRange,
    this.isLocked = false,
    this.isBudgetLocked = false,
  });

  @override
  ConsumerState<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends ConsumerState<_CategoryCard> {
  bool _isHovered = false;

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(categoriesRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    // Check if category has transactions
    final hasTransactions =
        await repository.categoryHasTransactions(widget.category.uuid);

    if (!context.mounted) return;

    try {
      await repository.softDeleteCategory(widget.category.uuid);
      if (context.mounted) {
        ToastUtils.showSuccessToast(
          context,
          ref,
          hasTransactions
              ? l10n.categoryHiddenSuccessfully
              : l10n.categoryDeletedSuccessfully,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final netAmount = widget.netAmount;
    final overallNetAmount = widget.overallNetAmount;
    final dateRange = widget.dateRange;
    final isLocked = widget.isLocked;
    final isBudgetLocked = widget.isBudgetLocked;

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isExpense = category.type == 'EXPENSE';
    final color = category.color != null
        ? Color(int.parse(category.color!.replaceAll('#', '0xFF')))
        : (isExpense ? AppColors.expenseColor : AppColors.incomeColor);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;
    if (currency == null) return const SizedBox.shrink();
    final budget = (isLocked || isBudgetLocked) ? null : budgetAmountForPeriod(category, dateRange);
    final hasBudget = budget != null && budget > 0;
    
    final overallBudget = (isLocked || isBudgetLocked) ? null : category.overallBudget;
    final hasOverallBudget = overallBudget != null && overallBudget > 0;

    // For Income categories, progress is (Income - Expense) / Budget
    // For Expense categories, progress is (Expense - Income) / Budget
    // netAmount is already calculated relative to category type in repository
    final pr = hasBudget ? netAmount / budget : 0.0;
    final overallPr = hasOverallBudget ? overallNetAmount / overallBudget : 0.0;
    
    // For income, we don't usually show "over budget" in red unless it's an expense-like behavior.
    // But keeping it consistent with the repository's netAmount logic.
    final fillColor = hasBudget && isExpense && pr > 1.0 ? AppColors.expenseColor : color;
    final overallFillColor = hasOverallBudget && isExpense && overallPr > 1.0 ? AppColors.expenseColor : color;

    return Padding(
      key: ValueKey('category-card-padding-${category.uuid}'),
      padding: const EdgeInsets.only(bottom: 12),
      child: SwipeableListItem(
        key: ValueKey('category-swipeable-${category.uuid}'),
        enableEdit: true,
        enableDelete: !category.isDefault,
        editBackgroundColor: color,
        deleteBackgroundColor: AppColors.error,
        borderRadius: 16,
        backgroundMargin: const EdgeInsets.only(bottom: 12),
        onEdit: () async {
          final updated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => EditCategoryScreen(category: category),
            ),
          );
          if (updated == true) {
            ref.invalidate(categoriesByTypeProvider);
          }
        },
        onDelete: category.isDefault || isLocked
            ? null
            : () async {
                await _deleteCategory(context, ref);
              },
        child: InkWell(
          key: ValueKey('category-inkwell-${category.uuid}'),
          onTap: isLocked
              ? () => PremiumGate.showPremiumDialog(context)
              : () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CategoryDetailsScreen(categoryUuid: category.uuid),
                    ),
                  );
                },
          onHover: (hovering) {
            setState(() {
              _isHovered = hovering;
            });
          },
          hoverColor: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            key: ValueKey('category-stack-${category.uuid}'),
            clipBehavior: Clip.none,
            children: [
              Opacity(
                key: ValueKey('category-opacity-${category.uuid}'),
                opacity: isLocked ? 0.5 : 1.0,
                child: Container(
                  key: ValueKey('category-container-${category.uuid}'),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isHovered
                          ? color
                          : theme.dividerColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    key: ValueKey('category-stack-layers-${category.uuid}'),
                    children: [
                      if (hasBudget)
                        Positioned.fill(
                          key: ValueKey('category-progress-bg-${category.uuid}'),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: FractionallySizedBox(
                              widthFactor: pr.isFinite ? pr.clamp(0.0, 1.0) : 0.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: fillColor.withValues(
                                    alpha: theme.brightness == Brightness.dark ? 0.12 : 0.08,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Column(
                        key: ValueKey('category-column-${category.uuid}'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            key: ValueKey('category-inner-padding-${category.uuid}'),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              key: ValueKey('category-row-${category.uuid}'),
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Hero(
                                  tag: 'category_icon_${category.uuid}',
                                  child: Container(
                                    key: ValueKey('category-icon-container-${category.uuid}'),
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color.withValues(
                                          alpha: theme.brightness == Brightness.dark
                                              ? 0.1
                                              : 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: color.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: CategoryHelper.buildCategoryIcon(
                                        category.icon, color, isExpense),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    key: ValueKey('category-name-${category.uuid}'),
                                    LocalizationHelper.getLocalizedCategoryName(
                                        context, category.name),
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Column(
                                  key: ValueKey('category-amount-col-${category.uuid}'),
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          AmountFormatter.formatWithCurrency(
                                            netAmount,
                                            currency,
                                          ),
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        if (hasBudget) ...[
                                          Text(
                                            ' / ',
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                          Text(
                                            AmountFormatter.formatWithCurrency(
                                              budget,
                                              currency,
                                            ),
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: fillColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: fillColor.withValues(alpha: 0.2),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              '${(pr * 100).round()}%',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: fillColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '${l10n.overall}: ',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          AmountFormatter.formatWithCurrency(
                                            overallNetAmount,
                                            currency,
                                          ),
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                            fontSize: 11,
                                          ),
                                        ),
                                        if (hasOverallBudget) ...[
                                          Text(
                                            ' / ',
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                                              fontWeight: FontWeight.w300,
                                              fontSize: 10,
                                            ),
                                          ),
                                          Text(
                                            AmountFormatter.formatWithCurrency(
                                              overallBudget,
                                              currency,
                                            ),
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  key: ValueKey('category-arrow-${category.uuid}'),
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (hasOverallBudget)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: FractionallySizedBox(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: overallPr.isFinite ? overallPr.clamp(0.0, 1.0) : 0.0,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: overallFillColor,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (isLocked)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              if (!category.isDefault && !isLocked)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Semantics(
                    label: l10n.customCategoryBadge,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
