import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:flowpaisa/features/categories/presentation/screens/edit_category_screen.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';

class CategoryDetailsScreen extends ConsumerWidget {
  final String categoryUuid;

  const CategoryDetailsScreen({super.key, required this.categoryUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(categoryStatisticsProvider(categoryUuid));
    final currencySymbol = ref.watch(currencySymbolProvider);
    final decimalPlaces = ref.watch(currencyDecimalPlacesProvider);
    final selectedDateRange = ref.watch(selectedDateRangeProvider);

    return Scaffold(
      body: statsAsync.when(
        data: (stats) {
          final category = stats.category;
          final isExpense = category.type == 'EXPENSE';
          final color = category.color != null
              ? Color(int.parse(category.color!.replaceAll('#', '0xFF')))
              : (isExpense ? AppColors.expenseColor : AppColors.incomeColor);

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.categoryDetails),
              actions: [
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
                      ref.invalidate(categoryStatisticsProvider(categoryUuid));
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
                        // Date Range Selector (Same as Analytics)
                        _DateRangeSelector(
                          selectedDateRange: selectedDateRange,
                          onDateRangeChanged: (dateRange) {
                            ref
                                .read(selectedDateRangeProvider.notifier)
                                .updateRange(dateRange);
                          },
                          onNextPeriod: () {
                            ref
                                .read(selectedDateRangeProvider.notifier)
                                .nextPeriod();
                          },
                          onPreviousPeriod: () {
                            ref
                                .read(selectedDateRangeProvider.notifier)
                                .previousPeriod();
                          },
                        ),
                        const SizedBox(height: 24),

                        // Summary Card
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
                            // Refresh summary when returning (e.g. after editing a transaction)
                            ref.invalidate(categoryStatisticsProvider(categoryUuid));
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isExpense
                                          ? l10n.netExpenses
                                          : l10n.netIncome,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AmountFormatter.formatWithCurrency(
                                          stats.totalAmount,
                                          currencySymbol,
                                          decimalPlaces),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                            ref.invalidate(categoryStatisticsProvider(categoryUuid));
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
                                        '${stats.transactionCount} ${l10n.transactions.toLowerCase()}',
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final DateRangeState selectedDateRange;
  final Function(DateRangeState) onDateRangeChanged;
  final VoidCallback onNextPeriod;
  final VoidCallback onPreviousPeriod;

  const _DateRangeSelector({
    required this.selectedDateRange,
    required this.onDateRangeChanged,
    required this.onNextPeriod,
    required this.onPreviousPeriod,
  });

  String _getDisplayText(BuildContext context) {
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RangeTypeChip(
                label: l10n.month,
                isSelected: selectedDateRange.type == DateRangeType.month,
                onTap: () => onDateRangeChanged(DateRangeState.currentMonth()),
              ),
              const SizedBox(width: 8),
              _RangeTypeChip(
                label: l10n.quarter,
                isSelected: selectedDateRange.type == DateRangeType.quarter,
                onTap: () {
                  final now = DateTime.now();
                  final currentQuarter = ((now.month - 1) ~/ 3) + 1;
                  onDateRangeChanged(
                      DateRangeState.quarter(now.year, currentQuarter));
                },
              ),
              const SizedBox(width: 8),
              _RangeTypeChip(
                label: l10n.year,
                isSelected: selectedDateRange.type == DateRangeType.year,
                onTap: () => onDateRangeChanged(
                    DateRangeState.year(DateTime.now().year)),
              ),
              const SizedBox(width: 8),
              _RangeTypeChip(
                label: l10n.custom,
                isSelected: selectedDateRange.type == DateRangeType.custom,
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDateRange: DateTimeRange(
                      start: selectedDateRange.startDate,
                      end: selectedDateRange.endDate,
                    ),
                  );
                  if (picked != null) {
                    onDateRangeChanged(
                        DateRangeState.custom(picked.start, picked.end));
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: selectedDateRange.type != DateRangeType.custom
                  ? onPreviousPeriod
                  : null,
            ),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getDisplayText(context),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: selectedDateRange.type != DateRangeType.custom
                  ? onNextPeriod
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _RangeTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RangeTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
