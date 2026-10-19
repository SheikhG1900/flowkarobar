import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/shared/widgets/dual_amount_progress_bar.dart';
import 'package:flowpaisa/features/categories/presentation/widgets/category_budget_date_range_selector.dart';
import 'package:flowpaisa/features/categories/presentation/widgets/category_tag_filter_row.dart';
import 'package:flowpaisa/features/categories/presentation/widgets/set_category_budget_sheet.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/categories/presentation/screens/edit_category_screen.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
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
    final isPremium = ref.watch(premiumProvider).isPremium;
    final budgetAsync = ref.watch(categoryDetailBudgetProvider(categoryUuid));
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;
    final selectedDateRange = ref.watch(categoryBudgetDateRangeProvider);

    if (currency == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return budgetAsync.when(
      skipLoadingOnReload: true,
      data: (snapshot) {
        final category = snapshot.category;
        final isLocked = !isPremium &&
            !category.isDefault &&
            (category.addSeq ?? 0) > PremiumGate.categoryTotalLimit;
        final isBudgetLocked = !isPremium &&
            (category.budgetSeq ?? 0) > PremiumGate.categoryBudgetTotalLimit;

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
                    onPressed: isLocked
                        ? () => PremiumGate.showPremiumDialog(context)
                        : () async {
                            if (isPinned) {
                              final layout =
                                  ref.read(dashboardWidgetLayoutProvider).value ??
                                      [];
                              final idx = layout.indexWhere((c) =>
                                  c.kind == DashboardWidgetKind.category &&
                                  c.categoryUuid == category.uuid);
                              if (idx >= 0) {
                                await ref
                                    .read(dashboardWidgetLayoutProvider.notifier)
                                    .removeAt(idx);
                                if (context.mounted) {
                                  ToastUtils.showSuccessToast(
                                      context, ref, l10n.unpinnedFromDashboard);
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
                onPressed: isLocked
                    ? () => PremiumGate.showPremiumDialog(context)
                    : () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditCategoryScreen(category: category),
                          ),
                        );
                        if (updated == true) {
                          ref.invalidate(
                              categoryDetailBudgetProvider(categoryUuid));
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
                      const SizedBox(height: 8),
                      const CategoryTagFilterRow(),
                      const SizedBox(height: 24),

                      // Summary / budget card
                      _CategoryBudgetSummarySection(
                        snapshot: snapshot,
                        categoryUuid: categoryUuid,
                        selectedDateRange: selectedDateRange,
                        color: color,
                        isExpense: isExpense,
                        currency: currency,
                        l10n: l10n,
                        isLocked: isLocked,
                        isBudgetLocked: isBudgetLocked,
                        onOpenTransactions: () async {
                          final tags = ref.read(categoryFilterTagsProvider);
                          ref
                              .read(transactionsPaginatedProvider.notifier)
                              .applyFilters(
                                TransactionFilters(
                                  categoryUuids: [categoryUuid],
                                  tagUuids: tags.isNotEmpty ? tags : null,
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
                        onSetBudget: () async {
                          if (isBudgetLocked) {
                            PremiumGate.showPremiumDialog(context);
                            return;
                          }
                          // Check limits before showing the sheet
                          final wasBudgetSet =
                              snapshot.category.monthlyBudget != null ||
                                  snapshot.category.quarterlyBudget != null ||
                                  snapshot.category.yearlyBudget != null;

                          if (!wasBudgetSet) {
                            final limits =
                                await PremiumGate.getCategoryBudgetLimits(ref);
                            if (!limits.canAdd) {
                              if (context.mounted) {
                                PremiumGate.showPremiumDialog(context);
                              }
                              return;
                            }
                          }

                          if (context.mounted) {
                            showSetCategoryBudgetSheet(
                              context,
                              category: snapshot.category,
                            );
                          }
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
  final AppCurrency currency;
  final AppLocalizations l10n;
  final bool isLocked;
  final bool isBudgetLocked;
  final Future<void> Function() onOpenTransactions;
  final VoidCallback onSetBudget;

  const _CategoryBudgetSummarySection({
    required this.snapshot,
    required this.categoryUuid,
    required this.selectedDateRange,
    required this.color,
    required this.isExpense,
    required this.currency,
    required this.l10n,
    required this.isLocked,
    required this.isBudgetLocked,
    required this.onOpenTransactions,
    required this.onSetBudget,
  });

  String _getPeriodText(BuildContext context) {
    switch (selectedDateRange.type) {
      case DateRangeType.month:
        return AppDateFormatter.formatMonthYear(selectedDateRange.startDate,
            context: context);
      case DateRangeType.quarter:
        final quarter = ((selectedDateRange.startDate.month - 1) ~/ 3) + 1;
        return 'Q$quarter ${AppDateFormatter.getFormatter('y').format(selectedDateRange.startDate)}';
      case DateRangeType.year:
        return AppDateFormatter.getFormatter('y')
            .format(selectedDateRange.startDate);
      case DateRangeType.custom:
        return '${AppDateFormatter.formatDate(selectedDateRange.startDate)} - ${AppDateFormatter.formatDate(selectedDateRange.endDate)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final netStr = AmountFormatter.formatWithCurrency(
      snapshot.netAmount,
      currency,
    );
    final budgetStr = !isBudgetLocked && snapshot.budgetAmount != null
        ? AmountFormatter.formatWithCurrency(
            snapshot.budgetAmount!,
            currency,
          )
        : '';

    final overallNetStr = AmountFormatter.formatWithCurrency(
      snapshot.overallNetAmount,
      currency,
    );
    final overallBudgetStr = !isBudgetLocked && snapshot.overallBudgetAmount != null
        ? AmountFormatter.formatWithCurrency(
            snapshot.overallBudgetAmount!,
            currency,
          )
        : '';

    final hasBudget = !isBudgetLocked && snapshot.hasBudget;
    final pr = hasBudget ? snapshot.progressRatio : 0.0;
    final over = hasBudget && isExpense && pr > 1.0;
    final barFillColor = over ? AppColors.expenseColor : color;

    final net = snapshot.netAmount;
    final remaining = snapshot.remainingOrGap;
    final leftPr = hasBudget && snapshot.budgetAmount != null && snapshot.budgetAmount! > 0
        ? (remaining > 0 ? remaining : 0.0) / snapshot.budgetAmount!
        : 1.0;

    // Period Budget Label & Value
    final String leftLabel;
    final String leftAmountStr;
    final Color leftColor;
    final double leftPercentage;

    if (!hasBudget) {
      leftLabel = '';
      leftAmountStr = '';
      leftColor = Colors.transparent;
      leftPercentage = 0.0;
    } else if (isExpense) {
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
        final surplusAmt = net - (snapshot.budgetAmount ?? 0.0);
        leftAmountStr = AmountFormatter.formatWithCurrency(surplusAmt, currency);
        leftColor = AppColors.incomeColor;
        leftPercentage = snapshot.budgetAmount! > 0 ? surplusAmt / snapshot.budgetAmount! : 0.0;
      }
    }

    final hasOverallBudget = !isBudgetLocked && snapshot.hasOverallBudget;
    final overallPr = hasOverallBudget ? snapshot.overallProgressRatio : 0.0;
    final overallOver = hasOverallBudget && isExpense && overallPr > 1.0;
    final overallBarFillColor = overallOver ? AppColors.expenseColor : color;

    final overallNet = snapshot.overallNetAmount;
    final overallRemaining = snapshot.overallRemainingOrGap;
    final overallLeftPr = hasOverallBudget && snapshot.overallBudgetAmount != null && snapshot.overallBudgetAmount! > 0
        ? (overallRemaining > 0 ? overallRemaining : 0.0) / snapshot.overallBudgetAmount!
        : 1.0;

    // Overall Budget Label & Value
    final String overallLeftLabel;
    final String overallLeftAmountStr;
    final Color overallLeftColor;
    final double overallLeftPercentage;

    if (!hasOverallBudget) {
      overallLeftLabel = '';
      overallLeftAmountStr = '';
      overallLeftColor = Colors.transparent;
      overallLeftPercentage = 0.0;
    } else if (isExpense) {
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
        final surplusAmt = overallNet - (snapshot.overallBudgetAmount ?? 0.0);
        overallLeftAmountStr = AmountFormatter.formatWithCurrency(surplusAmt, currency);
        overallLeftColor = AppColors.incomeColor;
        overallLeftPercentage = snapshot.overallBudgetAmount! > 0 ? surplusAmt / snapshot.overallBudgetAmount! : 0.0;
      }
    }

    // Labels and metrics based on category type (Expense vs Income Target)
    final targetLabel = isExpense ? '${l10n.limitLabel}: ' : '${l10n.targetLabel}: ';

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

    final hasAnyBudget = hasBudget || hasOverallBudget;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: cardDecoration,
      child: Stack(
        children: [
          if (hasBudget)
            Positioned.fill(
              key: ValueKey('category-details-progress-bg-$categoryUuid'),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onOpenTransactions,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(hasAnyBudget ? 0 : 16),
                  bottomRight: Radius.circular(hasAnyBudget ? 0 : 16),
                ),
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
                                        if (isExpense && pr > 1.0) ...[
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            size: 18,
                                            color: barFillColor,
                                          ),
                                          const SizedBox(width: 6),
                                        ] else if (!isExpense && pr >= 1.0) ...[
                                          Icon(
                                            Icons.check_circle_rounded,
                                            size: 18,
                                            color: barFillColor,
                                          ),
                                          const SizedBox(width: 6),
                                        ],
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
                                        if (isExpense && overallPr > 1.0) ...[
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            size: 18,
                                            color: overallBarFillColor,
                                          ),
                                          const SizedBox(width: 6),
                                        ] else if (!isExpense && overallPr >= 1.0) ...[
                                          Icon(
                                            Icons.check_circle_rounded,
                                            size: 18,
                                            color: overallBarFillColor,
                                          ),
                                          const SizedBox(width: 6),
                                        ],
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
                height: 1,
                thickness: 1,
                color: theme.dividerColor.withValues(alpha: 0.3),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Center(
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      foregroundColor: color,
                      backgroundColor: color.withValues(alpha: 0.1),
                    ),
                    onPressed: onSetBudget,
                    icon: Icon(
                      isExpense
                          ? Icons.account_balance_wallet_outlined
                          : Icons.savings_outlined,
                      size: 20,
                    ),
                    label: Text(
                      hasAnyBudget
                          ? (isExpense ? l10n.editBudget : l10n.editTarget)
                          : (isExpense ? l10n.setBudget : l10n.setTarget),
                    ),
                  ),
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
    );
  }
}
