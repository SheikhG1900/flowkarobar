import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/categories/presentation/screens/add_category_screen.dart';
import 'package:flowpaisa/features/categories/presentation/screens/edit_category_screen.dart';
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
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';

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
  }
}

/// Sum of net amounts and combined budgets for every category in this tab for [range].
class _CategoriesAggregateSummary extends ConsumerWidget {
  final String type;
  final List<Category> categories;
  final Map<String, double> nets;
  final DateRangeState range;

  const _CategoriesAggregateSummary({
    required this.type,
    required this.categories,
    required this.nets,
    required this.range,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isExpense = type == 'EXPENSE';
    final color =
        isExpense ? AppColors.expenseColor : AppColors.incomeColor;
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);

    double categorizedNet = 0;
    double totalBudgetCap = 0;
    final isPremium = ref.watch(premiumProvider).isPremium;
    for (final c in categories) {
      categorizedNet += nets[c.uuid] ?? 0;
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
      }
    }

    final uncategorizedAsync =
        ref.watch(uncategorizedAmountByTypeProvider(type));
    final uncategorizedAmt = uncategorizedAsync.maybeWhen(
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

    final hasBudget = totalBudgetCap > 0;
    final pr = hasBudget ? totalNet / totalBudgetCap : 0.0;
    final over = hasBudget && pr > 1.0;
    final barFillColor = over ? AppColors.expenseColor : color;
    final remaining = hasBudget ? totalBudgetCap - totalNet : 0.0;

    final netStr = AmountFormatter.formatWithCurrency(
      totalNet,
      symbol,
      decimals,
    );
    final uncategorizedStr = AmountFormatter.formatWithCurrency(
      uncategorizedAmt,
      symbol,
      decimals,
    );
    final budgetStr = AmountFormatter.formatWithCurrency(
      totalBudgetCap,
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

    final barRightAmount =
        hasBudget && remaining > 0 ? remaining : 0.0;
    final prefsReady = includeAsync.hasValue;
    final isDarkForChip = theme.brightness == Brightness.dark;
    const chipLabelLight = Color(0xFF0F172A);

    return Column(
      key: ValueKey('categories-aggregate-summary-$type'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: ValueKey('categories-aggregate-container-$type'),
          clipBehavior: Clip.antiAlias,
          decoration: gradientCardDecoration,
          child: Column(
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            key: ValueKey('categories-aggregate-text-col-$type'),
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                key: ValueKey('categories-aggregate-label-$type'),
                                isExpense ? l10n.totalExpenses : l10n.totalIncome,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                key: ValueKey('categories-aggregate-amount-$type'),
                                netStr,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  height: 1.15,
                                  color: Colors.white,
                                ),
                              ),
                              if (hasBudget) ...[
                                const SizedBox(height: 6),
                                Text(
                                  key: ValueKey('categories-aggregate-budget-$type'),
                                  budgetStr,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.92),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        PositionedDirectional(
                          end: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
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
                key: ValueKey('categories-aggregate-divider-$type'),
                height: 1,
                thickness: 1,
                color: Colors.white.withValues(alpha: 0.22),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
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
                              color: Colors.white.withValues(alpha: 0.78),
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            key: ValueKey('categories-aggregate-uncategorized-amount-$type'),
                            uncategorizedStr,
                            style: theme.textTheme.titleSmall?.copyWith(
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
                      key: ValueKey('categories-aggregate-uncategorized-chip-$type'),
                      showCheckmark: true,
                      selected: includeUncategorized,
                      label: Text(
                        l10n.categoriesSummaryIncludeInTotal,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDarkForChip
                              ? Colors.white.withValues(
                                  alpha: includeUncategorized ? 1.0 : 0.92,
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
                      checkmarkColor: isDarkForChip ? Colors.white : color,
                      side: BorderSide(
                        color: isDarkForChip
                            ? Colors.white.withValues(
                                alpha: includeUncategorized ? 0.5 : 0.32,
                              )
                            : Colors.white.withValues(
                                alpha: includeUncategorized ? 0.75 : 0.5,
                              ),
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
        ),
        if (hasBudget) ...[
          const SizedBox(height: 8),
          DualAmountProgressBar(
            key: ValueKey('categories-aggregate-budget-bar-$type'),
            leftLabel:
                isExpense ? l10n.budgetBarUsed : l10n.budgetBarProgress,
            leftAmount: totalNet > 0 ? totalNet : 0.0,
            rightLabel: l10n.remaining,
            rightAmount: barRightAmount,
            symbol: symbol,
            decimals: decimals,
            filledColor: barFillColor,
            compact: true,
          ),
        ],
      ],
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final Category category;
  final double netAmount;
  final DateRangeState dateRange;
  final bool isLocked;
  final bool isBudgetLocked;

  const _CategoryCard({
    super.key,
    required this.category,
    required this.netAmount,
    required this.dateRange,
    this.isLocked = false,
    this.isBudgetLocked = false,
  });

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(categoriesRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;

    // Check if category has transactions
    final hasTransactions =
        await repository.categoryHasTransactions(category.uuid);

    if (!context.mounted) return;

    try {
      await repository.softDeleteCategory(category.uuid);
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isExpense = category.type == 'EXPENSE';
    final color = category.color != null
        ? Color(int.parse(category.color!.replaceAll('#', '0xFF')))
        : (isExpense ? AppColors.expenseColor : AppColors.incomeColor);
    final symbol = ref.watch(currencySymbolProvider);
    final decimals = ref.watch(currencyDecimalPlacesProvider);
    final budget = (isLocked || isBudgetLocked) ? null : budgetAmountForPeriod(category, dateRange);
    final hasBudget = budget != null && budget > 0;
    final pr = hasBudget ? netAmount / budget : 0.0;
    final fillColor =
        hasBudget && pr > 1.0 ? AppColors.expenseColor : color;

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
                      color: theme.dividerColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
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
                                Text(
                                  key: ValueKey('category-amount-text-${category.uuid}'),
                                  AmountFormatter.formatWithCurrency(
                                    netAmount,
                                    symbol,
                                    decimals,
                                  ),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                if (hasBudget) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    key: ValueKey('category-budget-text-${category.uuid}'),
                                    AmountFormatter.formatWithCurrency(
                                      budget!,
                                      symbol,
                                      decimals,
                                    ),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 10,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ],
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
                      if (hasBudget)
                        CategoryBudgetProgressBar(
                          key: ValueKey('category-budget-bar-${category.uuid}'),
                          progress: pr,
                          fillColor: fillColor,
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
