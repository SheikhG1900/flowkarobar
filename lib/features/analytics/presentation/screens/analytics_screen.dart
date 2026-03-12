import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/widgets/premium_badge.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contact_details_screen.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/payables/presentation/screens/payables_list_screen.dart';
import 'package:flowpaisa/features/receivables/domain/models.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/screens/receivables_list_screen.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/core/utils/export_service.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:flowpaisa/features/tour/domain/tour_service.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  final db = ref.watch(databaseProvider);
  final userProfile = ref.watch(userProfileProvider);
  final transactionsRepository = TransactionsRepository(db);
  return ExportService(transactionsRepository, db,
      dateFormat: userProfile.dateFormat);
});

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  Future<void> _exportAnalyticsToPDF() async {
    final l10n = AppLocalizations.of(context)!;
    if (!PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }
    final theme = Theme.of(context);
    final selectedDateRange = ref.read(selectedDateRangeProvider);
    final currencySymbol = ref.read(currencySymbolProvider);
    final decimalPlaces = ref.read(currencyDecimalPlacesProvider);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final exportService = ref.read(exportServiceProvider);

      // Generate PDF bytes once
      final pdfBytes = await exportService.exportAnalyticsToPDF(
        startDate: selectedDateRange.startDate,
        endDate: selectedDateRange.endDate,
        currencySymbol: currencySymbol,
        decimalPlaces: decimalPlaces,
        l10n: l10n,
      );

      // Save PDF to temporary file for save/share actions
      final directory = await getTemporaryDirectory();
      final fileName =
          'flowpaisa_analytics_${AppDateFormatter.formatForFileName(DateTime.now())}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        Navigator.pop(context); // Close loading

        // Show action dialog with options
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.pdfReady),
            content: Text(l10n.analyticsPDFReadyMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await exportService.saveToDownloads(filePath);
                    if (context.mounted) {
                      ToastUtils.showSuccessToast(
                          context, ref, l10n.savedToDownloads);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ToastUtils.showErrorToast(
                          context, ref, l10n.errorSaving(e.toString()));
                    }
                  }
                },
                child: Text(l10n.saveCopy),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await exportService.sharePDFFile(filePath);
                  } catch (e) {
                    if (context.mounted) {
                      ToastUtils.showErrorToast(
                          context, ref, l10n.errorSharing(e.toString()));
                    }
                  }
                },
                child: Text(l10n.share),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                    foregroundColor: theme.colorScheme.onPrimary),
                onPressed: () async {
                  Navigator.pop(context);
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdfBytes,
                  );
                },
                child: Text(l10n.preview),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading if still open
        ToastUtils.showErrorToast(
            context, ref, l10n.errorExporting(e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedDateRange = ref.watch(selectedDateRangeProvider);
    final theme = Theme.of(context);
    final isPremium = PremiumGate.isPremium(ref);

    return ShowCaseWidget(
        builder: (context) => Scaffold(
              body: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      // Invalidate all analytics providers to refresh data
                      ref.invalidate(financialSummaryProvider);
                      ref.invalidate(allTimeFinancialSummaryProvider);
                      ref.invalidate(contactSummariesProvider);
                      ref.invalidate(expensesByCategoryProvider);
                      ref.invalidate(monthlyTrendsProvider);
                      ref.invalidate(payableReceivableTrendsProvider);
                      ref.invalidate(topContactsByBalanceProvider);
                      ref.invalidate(paymentStatusDistributionProvider);
                      ref.invalidate(incomeByCategoryProvider);

                      // Wait for the main summary to load
                      await ref.read(financialSummaryProvider.future);
                    },
                    child: CustomScrollView(
                      cacheExtent: 400,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        // App Bar with Date Range Selector
                        SliverAppBar(
                          floating: true,
                          pinned: true,
                          backgroundColor: theme.scaffoldBackgroundColor,
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.analytics,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (!isPremium)
                                const PremiumBadge(
                                    isSmall: true, showLock: true),
                            ],
                          ),
                          centerTitle: true,
                          actions: [
                            Showcase(
                              key: TourService.analyticsExportPdfKey,
                              title: l10n.tourAnalyticsExportPdfTitle,
                              description: l10n.tourAnalyticsExportPdfDesc,
                              targetShapeBorder: const CircleBorder(),
                              tooltipBackgroundColor: theme.colorScheme.primary,
                              textColor: theme.colorScheme.onPrimary,
                              tooltipPosition: TooltipPosition.bottom,
                              child: IconButton(
                                icon: const Icon(Symbols.picture_as_pdf),
                                onPressed: _exportAnalyticsToPDF,
                                tooltip: l10n.exportAnalyticsPDF,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Symbols.refresh),
                              onPressed: () {
                                // Invalidate all analytics providers to refresh data
                                ref.invalidate(financialSummaryProvider);
                                ref.invalidate(allTimeFinancialSummaryProvider);
                                ref.invalidate(contactSummariesProvider);
                                ref.invalidate(expensesByCategoryProvider);
                                ref.invalidate(monthlyTrendsProvider);
                                ref.invalidate(payableReceivableTrendsProvider);
                                ref.invalidate(topContactsByBalanceProvider);
                                ref.invalidate(
                                    paymentStatusDistributionProvider);
                                ref.invalidate(incomeByCategoryProvider);
                              },
                              tooltip: l10n.refreshAnalytics,
                            ),
                          ],
                          bottom: PreferredSize(
                            preferredSize: const Size.fromHeight(107),
                            child: Showcase(
                              key: TourService.analyticsDateRangeKey,
                              title: l10n.tourAnalyticsDateRangeTitle,
                              description: l10n.tourAnalyticsDateRangeDesc,
                              targetShapeBorder: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              tooltipBackgroundColor: theme.colorScheme.primary,
                              textColor: theme.colorScheme.onPrimary,
                              tooltipPosition: TooltipPosition.bottom,
                              child: _DateRangeSelector(
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
                            ),
                          ),
                        ),

                        // Content
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Financial Summary (Combined)
                                RepaintBoundary(
                                  child: Showcase(
                                    key: TourService.analyticsFinancialSummaryKey,
                                    title:
                                        l10n.tourAnalyticsFinancialSummaryTitle,
                                    description:
                                        l10n.tourAnalyticsFinancialSummaryDesc,
                                    targetShapeBorder:
                                        const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                    ),
                                    tooltipBackgroundColor:
                                        theme.colorScheme.primary,
                                    textColor: theme.colorScheme.onPrimary,
                                    tooltipPosition: TooltipPosition.bottom,
                                    child: _CollapsibleSection(
                                      title: l10n.financialSummary,
                                      sectionIndex: 0,
                                      child: const _FinancialSummaryCard(),
                                    ),
                                  ),
                                ),

                                // Contact Summaries
                                RepaintBoundary(
                                  child: _CollapsibleSection(
                                    title: l10n.contactSummaries,
                                    sectionIndex: 1,
                                    child: const _ContactSummariesSection(),
                                  ),
                                ),

                                // Pie Chart Section
                                RepaintBoundary(
                                  child: Showcase(
                                    key: TourService.analyticsChartsKey,
                                    title: l10n.tourAnalyticsChartsTitle,
                                    description: l10n.tourAnalyticsChartsDesc,
                                    targetShapeBorder:
                                        const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                    ),
                                    tooltipBackgroundColor:
                                        theme.colorScheme.primary,
                                    textColor: theme.colorScheme.onPrimary,
                                    tooltipPosition: TooltipPosition.bottom,
                                    child: _CollapsibleSection(
                                      title: l10n.expensesByCategory,
                                      sectionIndex: 2,
                                      child: const _ExpensesPieChart(),
                                    ),
                                  ),
                                ),

                                // Trend Chart Section
                                RepaintBoundary(
                                  child: _CollapsibleSection(
                                    title: l10n.incomeVsExpenseTrend,
                                    sectionIndex: 3,
                                    child: const _TrendsBarChart(),
                                  ),
                                ),

                                // Payables vs Receivables Trend
                                RepaintBoundary(
                                  child: _CollapsibleSection(
                                    title: l10n.payablesVsReceivablesTrend,
                                    sectionIndex: 4,
                                    child: const _PayableReceivableTrendsChart(),
                                  ),
                                ),

                                // Top Contacts by Balance
                                RepaintBoundary(
                                  child: _CollapsibleSection(
                                    title: l10n.topContactsByBalance,
                                    sectionIndex: 5,
                                    child: const _TopContactsChart(),
                                  ),
                                ),

                                // Payment Status Distribution
                                RepaintBoundary(
                                  child: _CollapsibleSection(
                                    title: l10n.paymentStatusDistribution,
                                    sectionIndex: 6,
                                    child:
                                        const _PaymentStatusDistributionChart(),
                                  ),
                                ),

                                // Income by Category
                                RepaintBoundary(
                                  child: _CollapsibleSection(
                                    title: l10n.incomeByCategory,
                                    sectionIndex: 7,
                                    child: const _IncomePieChart(),
                                  ),
                                ),

                                const SizedBox(height: 40),
                                Center(
                                  child: Opacity(
                                    opacity: 0.1,
                                    child: SvgPicture.asset(
                                      'assets/images/logo_square.svg',
                                      height: 60,
                                      colorFilter: ColorFilter.mode(
                                        theme.colorScheme.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 100), // Bottom padding
                              ],
                            ),
                          ),
                        ),
                        // Add an empty sliver to ensure the scroll view is always scrollable
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),

                  // Premium Lock Overlay
                  if (!isPremium)
                    Positioned.fill(
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.5),
                            child: Center(
                              child: Container(
                                margin: const EdgeInsets.all(32),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFD700),
                                            Color(0xFFFFA500)
                                          ],
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.lock_outline,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.premiumFeature,
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.unlockAdvancedAnalytics,
                                      textAlign: TextAlign.center,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    FilledButton(
                                      onPressed: () =>
                                          PremiumGate.showPremiumDialog(
                                              context),
                                      child: Text(l10n.unlockPremium),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ));
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
        return ' - ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Range type selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RangeTypeChip(
                label: l10n.month,
                isSelected: selectedDateRange.type == DateRangeType.month,
                onTap: () {
                  onDateRangeChanged(DateRangeState.currentMonth());
                },
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
                onTap: () {
                  onDateRangeChanged(DateRangeState.year(DateTime.now().year));
                },
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
          const SizedBox(height: 8),
          // Date navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: selectedDateRange.type != DateRangeType.custom
                    ? onPreviousPeriod
                    : null,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getDisplayText(context),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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
      ),
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

class _FinancialSummaryCard extends ConsumerWidget {
  const _FinancialSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAsync = ref.watch(financialSummaryProvider);
    final allTimeAsync = ref.watch(allTimeFinancialSummaryProvider);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencySymbolProvider);
    final decimalPlaces = ref.watch(currencyDecimalPlacesProvider);

    return selectedAsync.when(
      data: (selectedSummary) {
        return allTimeAsync.when(
          data: (allTimeSummary) {
            return Column(
              children: [
                // Payable vs Receivable
                Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        title: l10n.payableTag,
                        selectedAmount: selectedSummary.totalPayable,
                        allTimeAmount: allTimeSummary.totalPayable,
                        color: AppColors.payableColor,
                        icon: Icons.arrow_upward,
                        onTap: () {
                          final dateRange = ref.read(selectedDateRangeProvider);
                          ref
                              .read(
                                  payablesPaginatedProvider('PENDING').notifier)
                              .applyFilters(
                                PayableFilters(
                                  startDate: dateRange.startDate,
                                  endDate: dateRange.endDate,
                                ),
                              );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PayablesListScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryItem(
                        title: l10n.receivableTag,
                        selectedAmount: selectedSummary.totalReceivable,
                        allTimeAmount: allTimeSummary.totalReceivable,
                        color: AppColors.receivableColor,
                        icon: Icons.arrow_downward,
                        onTap: () {
                          final dateRange = ref.read(selectedDateRangeProvider);
                          ref
                              .read(receivablesPaginatedProvider('PENDING')
                                  .notifier)
                              .applyFilters(
                                ReceivableFilters(
                                  startDate: dateRange.startDate,
                                  endDate: dateRange.endDate,
                                ),
                              );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ReceivablesListScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Expense vs Income
                Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(
                        title: l10n.expenses,
                        selectedAmount: selectedSummary.totalExpense,
                        allTimeAmount: allTimeSummary.totalExpense,
                        color: AppColors.expenseColor,
                        icon: Icons.shopping_cart,
                        onTap: () {
                          final dateRange = ref.read(selectedDateRangeProvider);
                          ref
                              .read(transactionsPaginatedProvider.notifier)
                              .applyFilters(
                                TransactionFilters(
                                  type: 'EXPENSE',
                                  startDate: dateRange.startDate,
                                  endDate: dateRange.endDate,
                                ),
                              );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TransactionsListScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryItem(
                        title: l10n.income,
                        selectedAmount: selectedSummary.totalIncome,
                        allTimeAmount: allTimeSummary.totalIncome,
                        color: AppColors.incomeColor,
                        icon: Icons.account_balance_wallet,
                        onTap: () {
                          final dateRange = ref.read(selectedDateRangeProvider);
                          ref
                              .read(transactionsPaginatedProvider.notifier)
                              .applyFilters(
                                TransactionFilters(
                                  type: 'INCOME',
                                  startDate: dateRange.startDate,
                                  endDate: dateRange.endDate,
                                ),
                              );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TransactionsListScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Net Balance (receivable - payable)
                InkWell(
                  onTap: () {
                    final dateRange = ref.read(selectedDateRangeProvider);
                    ref
                        .read(transactionsPaginatedProvider.notifier)
                        .applyFilters(
                          TransactionFilters(
                            startDate: dateRange.startDate,
                            endDate: dateRange.endDate,
                          ),
                        );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsListScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: selectedSummary.netBalance >= 0
                          ? AppColors.receivableGradient
                          : AppColors.payableGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.netBalance,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              AmountFormatter.formatWithCurrency(
                                  selectedSummary.netBalance.abs(),
                                  currencySymbol,
                                  decimalPlaces),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${l10n.allTime} ${AmountFormatter.formatWithCurrency(allTimeSummary.netBalance.abs(), currencySymbol, decimalPlaces)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Income / Expense balance (same as transaction list summary)
                InkWell(
                  onTap: () {
                    final dateRange = ref.read(selectedDateRangeProvider);
                    ref
                        .read(transactionsPaginatedProvider.notifier)
                        .applyFilters(
                          TransactionFilters(
                            startDate: dateRange.startDate,
                            endDate: dateRange.endDate,
                          ),
                        );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsListScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: selectedSummary.totalIncome >=
                              selectedSummary.totalExpense
                          ? AppColors.incomeGradient
                          : AppColors.expenseGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedSummary.totalIncome >=
                                      selectedSummary.totalExpense
                                  ? l10n.netIncome
                                  : l10n.netExpenses,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              AmountFormatter.formatWithCurrency(
                                  (selectedSummary.totalIncome -
                                          selectedSummary.totalExpense)
                                      .abs(),
                                  currencySymbol,
                                  decimalPlaces),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${l10n.allTime} ${AmountFormatter.formatWithCurrency((allTimeSummary.totalIncome - allTimeSummary.totalExpense).abs(), currencySymbol, decimalPlaces)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) =>
              Center(child: Text(l10n.errorOccurred(e.toString()))),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text(l10n.errorOccurred(e.toString()))),
    );
  }
}

class _SummaryItem extends ConsumerWidget {
  final String title;
  final double selectedAmount;
  final double allTimeAmount;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _SummaryItem({
    required this.title,
    required this.selectedAmount,
    required this.allTimeAmount,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencySymbolProvider);
    final decimalPlaces = ref.watch(currencyDecimalPlacesProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AmountFormatter.formatWithCurrency(
                  selectedAmount, currencySymbol, decimalPlaces),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.allTime} ${AmountFormatter.formatWithCurrency(allTimeAmount, currencySymbol, 0)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSummariesSection extends ConsumerWidget {
  const _ContactSummariesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(contactSummariesProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencySymbolProvider);

    return summariesAsync.when(
      data: (summaries) {
        if (summaries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.people_outline,
                      size: 48, color: theme.disabledColor),
                  const SizedBox(height: 8),
                  Text(l10n.noContactActivity,
                      style: TextStyle(color: theme.disabledColor)),
                ],
              ),
            ),
          );
        }

        return Column(
          children: summaries.map((summary) {
            final isPositive = summary.balance >= 0;
            final isZero = summary.balance == 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactDetailsScreen(
                          contactUuid: summary.contact.uuid),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.getContactGradient(
                              summary.contact.name),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          summary.contact.name.isNotEmpty
                              ? summary.contact.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              summary.contact.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Payable and receivable stacked to save horizontal space for balance
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    final dateRange =
                                        ref.read(selectedDateRangeProvider);
                                    ref
                                        .read(
                                            payablesPaginatedProvider('PENDING')
                                                .notifier)
                                        .applyFilters(
                                          PayableFilters(
                                            contactUuids: [
                                              summary.contact.uuid
                                            ],
                                            startDate: dateRange.startDate,
                                            endDate: dateRange.endDate,
                                          ),
                                        );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PayablesListScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Symbols.call_made,
                                        size: 14,
                                        color: AppColors.payableColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        AmountFormatter.formatWithCurrency(
                                            summary.totalPayable,
                                            currencySymbol,
                                            0),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.payableColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                InkWell(
                                  onTap: () {
                                    final dateRange =
                                        ref.read(selectedDateRangeProvider);
                                    ref
                                        .read(receivablesPaginatedProvider(
                                                'PENDING')
                                            .notifier)
                                        .applyFilters(
                                          ReceivableFilters(
                                            contactUuids: [
                                              summary.contact.uuid
                                            ],
                                            startDate: dateRange.startDate,
                                            endDate: dateRange.endDate,
                                          ),
                                        );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ReceivablesListScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Symbols.call_received,
                                        size: 14,
                                        color: AppColors.receivableColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        AmountFormatter.formatWithCurrency(
                                            summary.totalReceivable,
                                            currencySymbol,
                                            0),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.receivableColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Balance
                      InkWell(
                        onTap: () {
                          final dateRange = ref.read(selectedDateRangeProvider);
                          if (isPositive) {
                            ref
                                .read(receivablesPaginatedProvider('PENDING')
                                    .notifier)
                                .applyFilters(
                                  ReceivableFilters(
                                    contactUuids: [summary.contact.uuid],
                                    startDate: dateRange.startDate,
                                    endDate: dateRange.endDate,
                                  ),
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ReceivablesListScreen(),
                              ),
                            );
                          } else {
                            ref
                                .read(payablesPaginatedProvider('PENDING')
                                    .notifier)
                                .applyFilters(
                                  PayableFilters(
                                    contactUuids: [summary.contact.uuid],
                                    startDate: dateRange.startDate,
                                    endDate: dateRange.endDate,
                                  ),
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PayablesListScreen(),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isZero
                                ? theme.colorScheme.surfaceContainerHighest
                                : (isPositive
                                        ? AppColors.receivableColor
                                        : AppColors.payableColor)
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isZero
                                  ? theme.dividerColor
                                  : (isPositive
                                          ? AppColors.receivableColor
                                          : AppColors.payableColor)
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            isZero
                                ? l10n.settled
                                : AmountFormatter.formatWithCurrency(
                                    summary.balance.abs(), currencySymbol, 0),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isZero
                                  ? theme.colorScheme.onSurfaceVariant
                                  : (isPositive
                                      ? AppColors.receivableColor
                                      : AppColors.payableColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text(l10n.errorOccurred(e.toString()))),
    );
  }
}

class _ExpensesPieChart extends ConsumerWidget {
  const _ExpensesPieChart();

  static const double _centerSpaceRadius = 35;
  static const double _baseSectionRadius = 28;
  static const double _radiusRangeByPercent = 45;
  static const double _chartHeight = 280;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesByCategoryProvider);
    final selectedIndex = ref.watch(selectedExpenseCategoryIndexProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return expensesAsync.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.pie_chart_outline,
                      size: 48, color: theme.disabledColor),
                  const SizedBox(height: 8),
                  Text(l10n.noExpenses,
                      style: TextStyle(color: theme.disabledColor)),
                ],
              ),
            ),
          );
        }

        final total = expenses.fold(0.0, (sum, e) => sum + e.totalAmount);
        double maxExpensePct = 0.0;
        if (total > 0) {
          for (final e in expenses) {
            final p = (e.totalAmount / total) * 100;
            if (p > maxExpensePct) maxExpensePct = p;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _chartHeight,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: _centerSpaceRadius,
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback:
                        (FlTouchEvent event, PieTouchResponse? response) {
                      final section = response?.touchedSection;
                      final index = section?.touchedSectionIndex;
                      if (event is FlTapUpEvent) {
                        ref
                            .read(selectedExpenseCategoryIndexProvider.notifier)
                            .setIndex(index != null
                                ? (selectedIndex == index ? null : index)
                                : null);
                      }
                    },
                  ),
                  sections: List.generate(expenses.length, (index) {
                    final e = expenses[index];
                    final percentage =
                        total > 0 ? (e.totalAmount / total) * 100 : 0.0;
                    final color = e.category.color != null
                        ? Color(int.parse(
                            e.category.color!.replaceAll('#', '0xFF')))
                        : AppColors.expenseColor;
                    final isSelected = selectedIndex == index;
                    // Radius by share: scale relative to max category %
                    final radius = _centerSpaceRadius +
                        _baseSectionRadius +
                        (maxExpensePct > 0
                            ? (percentage / maxExpensePct) *
                                _radiusRangeByPercent
                            : 0.0);

                    // Always show percent; scale font size by share
                    final bool showPercent = true;
                    final String title = percentage >= 5
                        ? '${percentage.toStringAsFixed(0)}%'
                        : percentage >= 1
                            ? '${percentage.toStringAsFixed(0)}%'
                            : percentage > 0
                                ? '<1%'
                                : '';
                    final double fontSize = percentage >= 10
                        ? 12
                        : percentage >= 5
                            ? 10
                            : percentage >= 1
                                ? 8
                                : 7;
                    final TextStyle titleStyle = TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    );
                    Widget? badgeWidget;
                    if (percentage >= 10) {
                      final iconData = IconHelper.getIconData(e.category.icon);
                      badgeWidget = iconData != null
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child:
                                  Icon(iconData, size: 18, color: Colors.white),
                            )
                          : null;
                    }

                    return PieChartSectionData(
                      color: isSelected ? color.withValues(alpha: 0.85) : color,
                      value: e.totalAmount,
                      title: title,
                      showTitle: showPercent && title.isNotEmpty,
                      titleStyle: titleStyle,
                      radius: radius,
                      badgeWidget: badgeWidget,
                      badgePositionPercentageOffset: 0.98,
                      titlePositionPercentageOffset:
                          badgeWidget != null ? 0.55 : 0.98,
                      borderSide: isSelected
                          ? BorderSide(
                              color: theme.colorScheme.surface,
                              width: 3,
                            )
                          : BorderSide(
                              color: color.withValues(alpha: 0.3), width: 1),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Category list as cards (same style as contacts above)
            ...List.generate(expenses.length, (index) {
              final e = expenses[index];
              final percentage =
                  total > 0 ? (e.totalAmount / total) * 100 : 0.0;
              final color = e.category.color != null
                  ? Color(int.parse(e.category.color!.replaceAll('#', '0xFF')))
                  : AppColors.expenseColor;
              final isSelected = selectedIndex == index;
              final iconData = IconHelper.getIconData(e.category.icon);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : theme.dividerColor.withValues(alpha: 0.5),
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: GestureDetector(
                  onDoubleTap: () {
                    final dateRange = ref.read(selectedDateRangeProvider);
                    ref
                        .read(transactionsPaginatedProvider.notifier)
                        .applyFilters(TransactionFilters(
                          type: 'EXPENSE',
                          categoryUuids: [e.category.uuid],
                          startDate: dateRange.startDate,
                          endDate: dateRange.endDate,
                        ));
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TransactionsListScreen(),
                        ),
                      );
                    }
                  },
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(selectedExpenseCategoryIndexProvider.notifier)
                          .setIndex(selectedIndex == index ? null : index);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color.withValues(alpha: 0.4),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: iconData != null
                                ? Icon(iconData, size: 26, color: color)
                                : Text(
                                    e.category.name.isNotEmpty
                                        ? e.category.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocalizationHelper.getLocalizedCategoryName(
                                      context, e.category.name),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AmountFormatter.formatWithCurrency(
                                e.totalAmount, currencySymbol, 2),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _TrendsBarChart extends ConsumerWidget {
  const _TrendsBarChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(monthlyTrendsProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return trendsAsync.when(
      data: (trends) {
        if (trends.every((t) => t.income == 0 && t.expense == 0)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.bar_chart, size: 48, color: theme.disabledColor),
                  const SizedBox(height: 8),
                  Text(l10n.noDataForTrends,
                      style: TextStyle(color: theme.disabledColor)),
                ],
              ),
            ),
          );
        }

        // Calculate max Y for scaling
        double maxY = 0;
        for (var t in trends) {
          if (t.income > maxY) maxY = t.income;
          if (t.expense > maxY) maxY = t.expense;
        }
        maxY = maxY * 1.2; // Add 20% buffer
        if (maxY == 0) maxY = 100;

        return AspectRatio(
          aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => theme.cardColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final type = rodIndex == 0 ? l10n.income : l10n.expense;
                    return BarTooltipItem(
                      '$type\n',
                      TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: AmountFormatter.formatWithCurrency(
                              rod.toY, currencySymbol, 0),
                          style: TextStyle(
                            color: rodIndex == 0
                                ? AppColors.incomeColor
                                : AppColors.expenseColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= trends.length)
                        return const Text('');
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          AppDateFormatter.formatMonth(trends[index].month,
                              context: context),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: trends.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data.income,
                      color: AppColors.incomeColor,
                      width: 12,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY: data.expense,
                      color: AppColors.expenseColor,
                      width: 12,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _PayableReceivableTrendsChart extends ConsumerWidget {
  const _PayableReceivableTrendsChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(payableReceivableTrendsProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return trendsAsync.when(
      data: (trends) {
        if (trends
            .every((t) => t.totalPayable == 0 && t.totalReceivable == 0)) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.bar_chart, size: 48, color: theme.disabledColor),
                  const SizedBox(height: 8),
                  Text(l10n.noPayableReceivableData,
                      style: TextStyle(color: theme.disabledColor)),
                ],
              ),
            ),
          );
        }

        double maxY = 0;
        for (var t in trends) {
          final tp = (t.totalPayable ?? 0).toDouble();
          final tr = (t.totalReceivable ?? 0).toDouble();
          if (tp > maxY) maxY = tp;
          if (tr > maxY) maxY = tr;
        }
        maxY = maxY * 1.2; // Add 20% buffer
        if (maxY == 0) maxY = 100;

        // Dull colors depend on brightness: light mode = lerp with white, dark mode = lerp with black
        final isDark = theme.brightness == Brightness.dark;
        final dullBlend = isDark ? Colors.black : Colors.white;
        const dullAmount = 0.6;
        final payableDullColor =
            Color.lerp(AppColors.payableColor, dullBlend, dullAmount)!;
        final payableDarkColor = AppColors.payableColor;
        final receivableDullColor =
            Color.lerp(AppColors.receivableColor, dullBlend, dullAmount)!;
        final receivableReceivedColor = AppColors.receivableColor;

        return AspectRatio(
          aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => theme.cardColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final data = trends[group.x.toInt()];
                    final type =
                        rodIndex == 0 ? l10n.payableTag : l10n.receivableTag;
                    final pending = (rodIndex == 0
                            ? (data.pendingPayable ?? 0)
                            : (data.pendingReceivable ?? 0))
                        .toDouble();
                    final settled = (rodIndex == 0
                            ? (data.paidPayable ?? 0)
                            : (data.receivedReceivable ?? 0))
                        .toDouble();
                    return BarTooltipItem(
                      '$type\n',
                      TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold),
                      children: [
                        if (pending > 0)
                          TextSpan(
                            text:
                                '${l10n.pending ?? 'Pending'}: ${AmountFormatter.formatWithCurrency(pending, currencySymbol, 0)}\n',
                            style: TextStyle(
                              color: rodIndex == 0
                                  ? payableDullColor
                                  : receivableDullColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (settled > 0)
                          TextSpan(
                            text:
                                '${rodIndex == 0 ? (l10n.paid ?? 'Paid') : (l10n.received ?? 'Received')}: ${AmountFormatter.formatWithCurrency(settled, currencySymbol, 0)}',
                            style: TextStyle(
                              color: rodIndex == 0
                                  ? payableDarkColor
                                  : receivableReceivedColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= trends.length)
                        return const Text('');
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                            AppDateFormatter.formatMonth(trends[index].month,
                                context: context),
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: trends.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final totalP = (data.totalPayable ?? 0).toDouble();
                final pendingP = (data.pendingPayable ?? 0).toDouble();
                final paidP = (data.paidPayable ?? 0).toDouble();
                final totalR = (data.totalReceivable ?? 0).toDouble();
                final pendingR = (data.pendingReceivable ?? 0).toDouble();
                final receivedR = (data.receivedReceivable ?? 0).toDouble();

                // Payable bar: paid (dark) at bottom, payable/pending (dull) at top
                List<BarChartRodStackItem> payableStack = [
                  if (paidP > 0)
                    BarChartRodStackItem(0, paidP, payableDarkColor),
                  if (pendingP > 0)
                    BarChartRodStackItem(
                      paidP,
                      totalP,
                      payableDullColor,
                    ),
                ];
                if (payableStack.isEmpty && totalP >= 0) {
                  payableStack = [
                    BarChartRodStackItem(0, totalP, payableDullColor),
                  ];
                }

                // Receivable bar: received (dark) at bottom, pending (dull) at top
                List<BarChartRodStackItem> receivableStack = [
                  if (receivedR > 0)
                    BarChartRodStackItem(
                      0,
                      receivedR,
                      receivableReceivedColor,
                    ),
                  if (pendingR > 0)
                    BarChartRodStackItem(
                      receivedR,
                      totalR,
                      receivableDullColor,
                    ),
                ];
                if (receivableStack.isEmpty && totalR >= 0) {
                  receivableStack = [
                    BarChartRodStackItem(0, totalR, receivableDullColor),
                  ];
                }

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: totalP,
                      width: 12,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                      rodStackItems: payableStack,
                    ),
                    BarChartRodData(
                      toY: totalR,
                      width: 12,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                      rodStackItems: receivableStack,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: `$e')),
    );
  }
}

class _TopContactsChart extends ConsumerWidget {
  const _TopContactsChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(topContactsByBalanceProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return contactsAsync.when(
      data: (contacts) {
        if (contacts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.people_outline,
                      size: 48, color: theme.disabledColor),
                  const SizedBox(height: 8),
                  Text(l10n.noContactData,
                      style: TextStyle(color: theme.disabledColor)),
                ],
              ),
            ),
          );
        }

        return Column(
          children: contacts.take(5).map((contact) {
            final isPositive = contact.balance >= 0;
            final color =
                isPositive ? AppColors.receivableColor : AppColors.payableColor;
            final maxAmount = contacts.first.balance.abs();
            final percentage =
                maxAmount > 0 ? (contact.balance.abs() / maxAmount) : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          contact.contact.name,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        AmountFormatter.formatWithCurrency(
                            contact.balance.abs(), currencySymbol, 0),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: `$e')),
    );
  }
}

class _PaymentStatusDistributionChart extends ConsumerWidget {
  const _PaymentStatusDistributionChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(paymentStatusDistributionProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = ref.watch(currencySymbolProvider);

    return statusAsync.when(
      data: (status) {
        final payableTotal = status.pendingPayables +
            status.paidPayables +
            status.cancelledPayables;
        final receivableTotal = status.pendingReceivables +
            status.receivedReceivables +
            status.cancelledReceivables;

        // Same colors as Payable vs Receivable trends: dull (pending) and dark (paid/received)
        final isDark = theme.brightness == Brightness.dark;
        final dullBlend = isDark ? Colors.black : Colors.white;
        const dullAmount = 0.5;
        final payableDullColor =
            Color.lerp(AppColors.payableColor, dullBlend, dullAmount)!;
        final payableDarkColor = AppColors.payableColor;
        final receivableDullColor =
            Color.lerp(AppColors.receivableColor, dullBlend, dullAmount)!;
        final receivableDarkColor = AppColors.receivableColor;

        if (payableTotal == 0 && receivableTotal == 0) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.donut_large, size: 48, color: theme.disabledColor),
                  const SizedBox(height: 8),
                  Text(l10n.noPaymentStatusData,
                      style: TextStyle(color: theme.disabledColor)),
                ],
              ),
            ),
          );
        }

        return Row(
          children: [
            if (payableTotal > 0)
              Expanded(
                child: Column(
                  children: [
                    Text(l10n.payables,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            if (status.pendingPayables > 0)
                              PieChartSectionData(
                                color: payableDullColor,
                                value: status.pendingPayables,
                                title:
                                    '${((status.pendingPayables / payableTotal) * 100).toStringAsFixed(0)}%',
                                radius: 45,
                                titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            if (status.paidPayables > 0)
                              PieChartSectionData(
                                color: payableDarkColor,
                                value: status.paidPayables,
                                title:
                                    '${((status.paidPayables / payableTotal) * 100).toStringAsFixed(0)}%',
                                radius: 45,
                                titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            if (status.cancelledPayables > 0)
                              PieChartSectionData(
                                color: Colors.grey,
                                value: status.cancelledPayables,
                                title:
                                    '${((status.cancelledPayables / payableTotal) * 100).toStringAsFixed(0)}%',
                                radius: 45,
                                titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusLegend(l10n.pending, status.pendingPayables,
                        payableDullColor, currencySymbol),
                    _buildStatusLegend(l10n.paid, status.paidPayables,
                        payableDarkColor, currencySymbol),
                    _buildStatusLegend(l10n.statusCancelled,
                        status.cancelledPayables, Colors.grey, currencySymbol),
                  ],
                ),
              ),
            if (payableTotal > 0 && receivableTotal > 0)
              const SizedBox(width: 16),
            if (receivableTotal > 0)
              Expanded(
                child: Column(
                  children: [
                    Text(l10n.receivables,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            if (status.pendingReceivables > 0)
                              PieChartSectionData(
                                color: receivableDullColor,
                                value: status.pendingReceivables,
                                title:
                                    '${((status.pendingReceivables / receivableTotal) * 100).toStringAsFixed(0)}%',
                                radius: 45,
                                titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            if (status.receivedReceivables > 0)
                              PieChartSectionData(
                                color: receivableDarkColor,
                                value: status.receivedReceivables,
                                title:
                                    '${((status.receivedReceivables / receivableTotal) * 100).toStringAsFixed(0)}%',
                                radius: 45,
                                titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            if (status.cancelledReceivables > 0)
                              PieChartSectionData(
                                color: Colors.grey,
                                value: status.cancelledReceivables,
                                title:
                                    '${((status.cancelledReceivables / receivableTotal) * 100).toStringAsFixed(0)}%',
                                radius: 45,
                                titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusLegend(l10n.pending, status.pendingReceivables,
                        receivableDullColor, currencySymbol),
                    _buildStatusLegend(
                        l10n.receivedLabel,
                        status.receivedReceivables,
                        receivableDarkColor,
                        currencySymbol),
                    _buildStatusLegend(
                        l10n.statusCancelled,
                        status.cancelledReceivables,
                        Colors.grey,
                        currencySymbol),
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text(l10n.errorOccurred(e.toString()))),
    );
  }

  Widget _buildStatusLegend(
      String label, double amount, Color color, String currencySymbol) {
    if (amount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(AmountFormatter.formatWithCurrency(amount, currencySymbol, 0),
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _IncomePieChart extends ConsumerWidget {
  const _IncomePieChart();

  static const double _centerSpaceRadius = 35;
  static const double _baseSectionRadius = 30;
  static const double _radiusRangeByPercent = 45;
  static const double _chartHeight = 280;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomesAsync = ref.watch(incomeByCategoryProvider);
    final selectedIndex = ref.watch(selectedIncomeCategoryIndexProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return incomesAsync.when(
      data: (incomes) {
        if (incomes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.pie_chart_outline,
                      size: 48, color: theme.disabledColor),
                  const SizedBox(height: 8),
                  Text(l10n.noIncome,
                      style: TextStyle(color: theme.disabledColor)),
                ],
              ),
            ),
          );
        }

        final total = incomes.fold(0.0, (sum, e) => sum + e.totalAmount);
        double maxIncomePct = 0.0;
        if (total > 0) {
          for (final e in incomes) {
            final p = (e.totalAmount / total) * 100;
            if (p > maxIncomePct) maxIncomePct = p;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _chartHeight,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: _centerSpaceRadius,
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback:
                        (FlTouchEvent event, PieTouchResponse? response) {
                      final section = response?.touchedSection;
                      final index = section?.touchedSectionIndex;
                      if (event is FlTapUpEvent) {
                        ref
                            .read(selectedIncomeCategoryIndexProvider.notifier)
                            .setIndex(index != null
                                ? (selectedIndex == index ? null : index)
                                : null);
                      }
                    },
                  ),
                  sections: List.generate(incomes.length, (index) {
                    final e = incomes[index];
                    final percentage =
                        total > 0 ? (e.totalAmount / total) * 100 : 0.0;
                    final color = e.category.color != null
                        ? Color(int.parse(
                            e.category.color!.replaceAll('#', '0xFF')))
                        : AppColors.incomeColor;
                    final isSelected = selectedIndex == index;
                    // Radius by share: scale relative to max category %
                    final radius = _centerSpaceRadius +
                        _baseSectionRadius +
                        (maxIncomePct > 0
                            ? (percentage / maxIncomePct) *
                                _radiusRangeByPercent
                            : 0.0);

                    final String title = percentage >= 5
                        ? '${percentage.toStringAsFixed(0)}%'
                        : percentage >= 1
                            ? '${percentage.toStringAsFixed(0)}%'
                            : percentage > 0
                                ? '<1%'
                                : '';
                    final double fontSize = percentage >= 10
                        ? 12
                        : percentage >= 5
                            ? 10
                            : percentage >= 1
                                ? 8
                                : 7;
                    final TextStyle titleStyle = TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    );
                    Widget? badgeWidget;
                    if (percentage >= 10) {
                      final iconData = IconHelper.getIconData(e.category.icon);
                      badgeWidget = iconData != null
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child:
                                  Icon(iconData, size: 18, color: Colors.white),
                            )
                          : null;
                    }

                    return PieChartSectionData(
                      color: isSelected ? color.withValues(alpha: 0.85) : color,
                      value: e.totalAmount,
                      title: title,
                      showTitle: title.isNotEmpty,
                      titleStyle: titleStyle,
                      radius: radius,
                      badgeWidget: badgeWidget,
                      badgePositionPercentageOffset: 0.98,
                      titlePositionPercentageOffset:
                          badgeWidget != null ? 0.55 : 0.98,
                      borderSide: isSelected
                          ? BorderSide(
                              color: theme.colorScheme.surface,
                              width: 3,
                            )
                          : BorderSide(
                              color: color.withValues(alpha: 0.3), width: 1),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(incomes.length, (index) {
              final e = incomes[index];
              final percentage =
                  total > 0 ? (e.totalAmount / total) * 100 : 0.0;
              final color = e.category.color != null
                  ? Color(int.parse(e.category.color!.replaceAll('#', '0xFF')))
                  : AppColors.incomeColor;
              final isSelected = selectedIndex == index;
              final iconData = IconHelper.getIconData(e.category.icon);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : theme.dividerColor.withValues(alpha: 0.5),
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: GestureDetector(
                  onDoubleTap: () {
                    final dateRange = ref.read(selectedDateRangeProvider);
                    ref
                        .read(transactionsPaginatedProvider.notifier)
                        .applyFilters(TransactionFilters(
                          type: 'INCOME',
                          categoryUuids: [e.category.uuid],
                          startDate: dateRange.startDate,
                          endDate: dateRange.endDate,
                        ));
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TransactionsListScreen(),
                        ),
                      );
                    }
                  },
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(selectedIncomeCategoryIndexProvider.notifier)
                          .setIndex(selectedIndex == index ? null : index);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color.withValues(alpha: 0.4),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: iconData != null
                                ? Icon(iconData, size: 26, color: color)
                                : Text(
                                    e.category.name.isNotEmpty
                                        ? e.category.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocalizationHelper.getLocalizedCategoryName(
                                      context, e.category.name),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AmountFormatter.formatWithCurrency(
                                e.totalAmount, currencySymbol, 2),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text(l10n.errorOccurred(e.toString()))),
    );
  }
}

// Collapsible Section Widget with Alternating Background Colors
class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final int sectionIndex;

  const _CollapsibleSection({
    required this.title,
    required this.child,
    required this.sectionIndex,
  });

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _isExpanded = true;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Alternating background colors
    final backgroundColor = widget.sectionIndex % 2 == 0
        ? theme.colorScheme.surface
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: Semantics(
              button: true,
              label:
                  '${widget.title} section, ${_isExpanded ? l10n.expanded : l10n.collapsed}',
              onTap: _toggleExpanded,
              child: InkWell(
                onTap: _toggleExpanded,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns: _iconTurns,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: widget.child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
