import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/shared/widgets/faded_bottom_logo.dart';
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
import 'package:flowpaisa/features/analytics/presentation/widgets/account_analytics_widgets.dart';
import 'package:file_selector/file_selector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  void _showCustomiseSheet(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AnalyticsSectionsSheet(),
    );
  }

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
      final currency = ref.read(currentCurrencyProvider).value;

      // Generate PDF bytes once
      final pdfBytes = await exportService.exportAnalyticsToPDF(
        startDate: selectedDateRange.startDate,
        endDate: selectedDateRange.endDate,
        currencySymbol: currencySymbol,
        decimalPlaces: decimalPlaces,
        l10n: l10n,
        currency: currency,
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
                    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                      final FileSaveLocation? result = await getSaveLocation(
                        suggestedName: fileName,
                        acceptedTypeGroups: [
                          const XTypeGroup(
                            label: 'PDF',
                            extensions: ['pdf'],
                          ),
                        ],
                      );
                      if (result != null) {
                        await file.copy(result.path);
                        if (context.mounted) {
                          ToastUtils.showSuccessToast(
                              context, ref, l10n.exportSavedTo(result.path));
                        }
                      }
                    } else {
                      await exportService.saveToDownloads(filePath);
                      if (context.mounted) {
                        ToastUtils.showSuccessToast(
                            context, ref, l10n.savedToDownloads);
                      }
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
                    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                      // On desktop, "Share" is best handled by opening the file directly in the default viewer
                      final fileUri = Uri.file(filePath);
                      if (await canLaunchUrl(fileUri)) {
                        await launchUrl(fileUri);
                      } else {
                        throw Exception('Could not open the PDF file.');
                      }
                    } else {
                      await exportService.sharePDFFile(filePath);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ToastUtils.showErrorToast(
                          context, ref, l10n.errorSharing(e.toString()));
                    }
                  }
                },
                child: Text(Platform.isWindows || Platform.isMacOS || Platform.isLinux ? l10n.openFile : l10n.share),
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
    final hiddenSections = ref.watch(analyticsSectionsProvider);
    bool visible(AnalyticsSection s) => !hiddenSections.contains(s);

    return Scaffold(
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
                      ref.invalidate(accountSpendingProvider);
                      ref.invalidate(transferFlowProvider);

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
                            IconButton(
                              icon: const Icon(Symbols.picture_as_pdf),
                              onPressed: _exportAnalyticsToPDF,
                              tooltip: l10n.exportAnalyticsPDF,
                            ),
                            IconButton(
                              icon: const Icon(Symbols.tune),
                              onPressed: () =>
                                  _showCustomiseSheet(context, ref, l10n),
                              tooltip: l10n.customiseSections,
                            ),
                          ],
                          bottom: PreferredSize(
                            preferredSize: const Size.fromHeight(107),
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

                        // Content
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Financial Summary (Combined)
                                if (visible(AnalyticsSection.financialSummary))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.financialSummary,
                                      sectionIndex: 0,
                                      child: const _FinancialSummaryCard(),
                                    ),
                                  ),

                                // Contact Summaries
                                if (visible(AnalyticsSection.contactSummaries))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.contactSummaries,
                                      sectionIndex: 1,
                                      child: const _ContactSummariesSection(),
                                    ),
                                  ),

                                // Pie Chart Section
                                if (visible(AnalyticsSection.expensesByCategory))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.expensesByCategory,
                                      sectionIndex: 2,
                                      child: const _ExpensesPieChart(),
                                    ),
                                  ),

                                // Trend Chart Section
                                if (visible(AnalyticsSection.incomeVsExpenseTrend))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.incomeVsExpenseTrend,
                                      sectionIndex: 3,
                                      child: const _TrendsBarChart(),
                                    ),
                                  ),

                                // Payables vs Receivables Trend
                                if (visible(AnalyticsSection.payablesVsReceivablesTrend))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.payablesVsReceivablesTrend,
                                      sectionIndex: 4,
                                      child:
                                          const _PayableReceivableTrendsChart(),
                                    ),
                                  ),

                                // Top Contacts by Balance
                                if (visible(AnalyticsSection.topContacts))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.topContactsByBalance,
                                      sectionIndex: 5,
                                      child: const _TopContactsChart(),
                                    ),
                                  ),

                                // Payment Status Distribution
                                if (visible(AnalyticsSection.paymentStatus))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.paymentStatusDistribution,
                                      sectionIndex: 6,
                                      child:
                                          const _PaymentStatusDistributionChart(),
                                    ),
                                  ),

                                // Income by Category
                                if (visible(AnalyticsSection.incomeByCategory))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.incomeByCategory,
                                      sectionIndex: 7,
                                      child: const _IncomePieChart(),
                                    ),
                                  ),

                                // ── Account Analytics ─────────────────────
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: theme.colorScheme.outlineVariant,
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          l10n.accountsOverview,
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: theme.colorScheme.outlineVariant,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Net Worth
                                if (visible(AnalyticsSection.netWorth))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.netWorth,
                                      sectionIndex: 8,
                                      showAllTimeBadge: true,
                                      child: const AccountNetWorthCard(),
                                    ),
                                  ),

                                // Balance Distribution
                                if (visible(AnalyticsSection.balanceDistribution))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.balanceDistribution,
                                      sectionIndex: 9,
                                      showAllTimeBadge: true,
                                      child: const BalanceDistributionChart(),
                                    ),
                                  ),

                                // Spending by Account
                                if (visible(AnalyticsSection.spendingByAccount))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.spendingByAccount,
                                      sectionIndex: 10,
                                      child: const AccountSpendingChart(),
                                    ),
                                  ),

                                // Credit Card Utilisation
                                if (visible(AnalyticsSection.creditUtilisation))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.creditUtilisation,
                                      sectionIndex: 11,
                                      showAllTimeBadge: true,
                                      child: const CreditUtilisationChart(),
                                    ),
                                  ),

                                // Transfer Flow
                                if (visible(AnalyticsSection.transferFlow))
                                  RepaintBoundary(
                                    child: _CollapsibleSection(
                                      title: l10n.transferFlow,
                                      sectionIndex: 12,
                                      child: const TransferFlowChart(),
                                    ),
                                  ),

                                const FadedBottomLogo(bottomPadding: 100),
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
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

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
                                  currency),
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
                              '${l10n.allTime} ${AmountFormatter.formatWithCurrency(allTimeSummary.netBalance.abs(), currency)}',
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
                                  currency),
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
                              '${l10n.allTime} ${AmountFormatter.formatWithCurrency((allTimeSummary.totalIncome - allTimeSummary.totalExpense).abs(), currency)}',
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
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

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
                  selectedAmount, currency),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${l10n.allTime} ${AmountFormatter.formatWithCurrency(allTimeAmount, currency)}',
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
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final currencySymbol = currency.symbol;

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
                                            currency),
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
                                            currency),
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
                                    summary.balance.abs(), currency),
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
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final currencySymbol = currency.symbol;
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
                                e.totalAmount, currency),
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
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final currencySymbol = currency.symbol;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final selectedIndex = ref.watch(selectedTrendIndexProvider);

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

        const double barGroupWidth = 64;
        const double chartHeight = 220;

        final selectedData =
            selectedIndex != null ? trends[selectedIndex] : null;

        return Column(
          children: [
            if (selectedData != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.incomeColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(l10n.income,
                                    style: theme.textTheme.labelSmall),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AmountFormatter.formatWithCurrency(
                                  selectedData.income, currency),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.incomeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.expenseColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(l10n.expenses,
                                    style: theme.textTheme.labelSmall),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AmountFormatter.formatWithCurrency(
                                  selectedData.expense, currency),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.expenseColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: trends.length <= 6
                    ? MediaQuery.of(context).size.width - 32
                    : trends.length * barGroupWidth,
                height: chartHeight,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      handleBuiltInTouches: true,
                      touchCallback:
                          (FlTouchEvent event, BarTouchResponse? response) {
                        if (event is FlTapUpEvent && response?.spot != null) {
                          final index = response!.spot!.touchedBarGroupIndex;
                          ref
                              .read(selectedTrendIndexProvider.notifier)
                              .setIndex(selectedIndex == index ? null : index);
                        }
                      },
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.transparent,
                        getTooltipItem: (_, __, ___, ____) => null,
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
                            final isSelected = selectedIndex == index;
                            return SideTitleWidget(
                              meta: meta,
                              space: 8,
                              child: GestureDetector(
                                onTap: () {
                                  ref
                                      .read(selectedTrendIndexProvider.notifier)
                                      .setIndex(isSelected ? null : index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.primaryContainer
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    AppDateFormatter.formatMonth(
                                        trends[index].month,
                                        context: context),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: trends.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final isSelected = selectedIndex == index;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data.income,
                            color: isSelected
                                ? AppColors.incomeColor
                                : AppColors.incomeColor.withValues(alpha: 0.4),
                            width: 14,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                          BarChartRodData(
                            toY: data.expense,
                            color: isSelected
                                ? AppColors.expenseColor
                                : AppColors.expenseColor.withValues(alpha: 0.4),
                            width: 14,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
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
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final currencySymbol = currency.symbol;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final selectedIndex = ref.watch(selectedPayableReceivableTrendIndexProvider);

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

        const double barGroupWidth = 64;
        const double chartHeight = 220;

        final selectedData =
            selectedIndex != null ? trends[selectedIndex] : null;

        // Calculate combined totals for all months if nothing is selected
        final combinedTotalP = trends.fold(0.0, (sum, t) => sum + (t.totalPayable ?? 0));
        final combinedPaidP = trends.fold(0.0, (sum, t) => sum + (t.paidPayable ?? 0));
        final combinedPendingP = trends.fold(0.0, (sum, t) => sum + (t.pendingPayable ?? 0));
        
        final combinedTotalR = trends.fold(0.0, (sum, t) => sum + (t.totalReceivable ?? 0));
        final combinedReceivedR = trends.fold(0.0, (sum, t) => sum + (t.receivedReceivable ?? 0));
        final combinedPendingR = trends.fold(0.0, (sum, t) => sum + (t.pendingReceivable ?? 0));

        final displayTotalP = selectedData?.totalPayable ?? combinedTotalP;
        final displayPaidP = selectedData?.paidPayable ?? combinedPaidP;
        final displayPendingP = selectedData?.pendingPayable ?? combinedPendingP;

        final displayTotalR = selectedData?.totalReceivable ?? combinedTotalR;
        final displayReceivedR = selectedData?.receivedReceivable ?? combinedReceivedR;
        final displayPendingR = selectedData?.pendingReceivable ?? combinedPendingR;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    if (selectedData == null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          l10n.all,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.payableColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(l10n.payableTag,
                                      style: theme.textTheme.labelSmall),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AmountFormatter.formatWithCurrency(
                                    displayTotalP, currency),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.payableColor,
                                ),
                              ),
                              Text(
                                '${l10n.paid}: ${AmountFormatter.formatWithCurrency(displayPaidP, currency)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${l10n.pending}: ${AmountFormatter.formatWithCurrency(displayPendingP, currency)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: displayPendingP > 0
                                      ? AppColors.payableColor
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: displayPendingP > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.receivableColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(l10n.receivableTag,
                                      style: theme.textTheme.labelSmall),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AmountFormatter.formatWithCurrency(
                                    displayTotalR,
                                    currency),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.receivableColor,
                                ),
                              ),
                              Text(
                                '${l10n.receivedLabel}: ${AmountFormatter.formatWithCurrency(displayReceivedR, currency)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${l10n.pending}: ${AmountFormatter.formatWithCurrency(displayPendingR, currency)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: displayPendingR > 0
                                      ? AppColors.receivableColor
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: displayPendingR > 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: trends.length <= 6
                    ? MediaQuery.of(context).size.width - 32
                    : trends.length * barGroupWidth,
                height: chartHeight,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      enabled: true,
                      handleBuiltInTouches: true,
                      touchCallback:
                          (FlTouchEvent event, BarTouchResponse? response) {
                        if (event is FlTapUpEvent && response?.spot != null) {
                          final index = response!.spot!.touchedBarGroupIndex;
                          ref
                              .read(
                                  selectedPayableReceivableTrendIndexProvider.notifier)
                              .setIndex(selectedIndex == index ? null : index);
                        }
                      },
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.transparent,
                        getTooltipItem: (_, __, ___, ____) => null,
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
                            final isSelected = selectedIndex == index;
                            return SideTitleWidget(
                              meta: meta,
                              space: 8,
                              child: GestureDetector(
                                onTap: () {
                                  ref
                                      .read(
                                          selectedPayableReceivableTrendIndexProvider
                                              .notifier)
                                      .setIndex(isSelected ? null : index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.primaryContainer
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    AppDateFormatter.formatMonth(
                                        trends[index].month,
                                        context: context),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.textTheme.bodySmall?.color,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: trends.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final isSelected = selectedIndex == index;
                      final totalP = (data.totalPayable ?? 0).toDouble();
                      final pendingP = (data.pendingPayable ?? 0).toDouble();
                      final paidP = (data.paidPayable ?? 0).toDouble();
                      final totalR = (data.totalReceivable ?? 0).toDouble();
                      final pendingR = (data.pendingReceivable ?? 0).toDouble();
                      final receivedR =
                          (data.receivedReceivable ?? 0).toDouble();

                      // Payable bar: paid (dark) at bottom, payable/pending (dull) at top
                      List<BarChartRodStackItem> payableStack = [
                        if (paidP > 0)
                          BarChartRodStackItem(0, paidP, (AppColors.payableColor)),
                        if (pendingP > 0)
                          BarChartRodStackItem(
                            paidP,
                            totalP,
                            (Color.lerp(AppColors.payableColor, theme.brightness == Brightness.dark ? Colors.black : Colors.white, 0.6)!),
                          ),
                      ];
                      if (payableStack.isEmpty && totalP >= 0) {
                        payableStack = [
                          BarChartRodStackItem(0, totalP, (Color.lerp(AppColors.payableColor, theme.brightness == Brightness.dark ? Colors.black : Colors.white, 0.6)!)),
                        ];
                      }

                      // Receivable bar: received (dark) at bottom, pending (dull) at top
                      List<BarChartRodStackItem> receivableStack = [
                        if (receivedR > 0)
                          BarChartRodStackItem(
                            0,
                            receivedR,
                            (AppColors.receivableColor),
                          ),
                        if (pendingR > 0)
                          BarChartRodStackItem(
                            receivedR,
                            totalR,
                            (Color.lerp(AppColors.receivableColor, theme.brightness == Brightness.dark ? Colors.black : Colors.white, 0.6)!),
                          ),
                      ];
                      if (receivableStack.isEmpty && totalR >= 0) {
                        receivableStack = [
                          BarChartRodStackItem(0, totalR, (Color.lerp(AppColors.receivableColor, theme.brightness == Brightness.dark ? Colors.black : Colors.white, 0.6)!)),
                        ];
                      }

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: totalP,
                            width: 14,
                            color: isSelected
                                ? null
                                : AppColors.payableColor.withValues(alpha: 0.4),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                            rodStackItems: payableStack.map((item) {
                              if (!isSelected) {
                                return BarChartRodStackItem(
                                  item.fromY,
                                  item.toY,
                                  (item.color ?? Colors.transparent)
                                      .withValues(alpha: 0.4),
                                );
                              }
                              return item;
                            }).toList(),
                          ),
                          BarChartRodData(
                            toY: totalR,
                            width: 14,
                            color: isSelected
                                ? null
                                : AppColors.receivableColor
                                    .withValues(alpha: 0.4),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                            rodStackItems: receivableStack.map((item) {
                              if (!isSelected) {
                                return BarChartRodStackItem(
                                  item.fromY,
                                  item.toY,
                                  (item.color ?? Colors.transparent)
                                      .withValues(alpha: 0.4),
                                );
                              }
                              return item;
                            }).toList(),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Chart Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _LegendItem(label: l10n.paid, color: AppColors.payableColor),
                  _LegendItem(
                      label: l10n.receivedLabel,
                      color: AppColors.receivableColor),
                  _LegendItem(label: l10n.pending, color: Colors.grey.shade400),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: `$e')),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _TopContactsChart extends ConsumerWidget {
  const _TopContactsChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(topContactsByBalanceProvider);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final currencySymbol = currency.symbol;
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

        final maxAmount = contacts.fold(
            0.0, (m, c) => c.balance.abs() > m ? c.balance.abs() : m);

        return Column(
          children: contacts.take(10).map((contact) {
            final isPositive = contact.balance >= 0;
            final barColor = isPositive
                ? AppColors.receivableColor
                : AppColors.payableColor;
            final avatarColor =
                AppColors.getContactColor(contact.contact.name);
            final fillFactor = maxAmount > 0
                ? (contact.balance.abs() / maxAmount).clamp(0.0, 1.0)
                : 0.0;
            final initials = contact.contact.name.trim().isNotEmpty
                ? contact.contact.name.trim()[0].toUpperCase()
                : '?';

            Widget content(Color textColor) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      // Avatar circle
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: avatarColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          contact.contact.name,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        AmountFormatter.formatWithCurrency(
                            contact.balance.abs(), currency),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContactDetailsScreen(
                        contactUuid: contact.contact.uuid),
                  ),
                ),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: barColor.withValues(alpha: 0.25), width: 0.5),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: content(barColor),
                      ),
                      ClipRect(
                        child: Align(
                          alignment: Directionality.of(context) ==
                                  TextDirection.rtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          widthFactor: fillFactor,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: barColor.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: content(Colors.white),
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
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final currencySymbol = currency.symbol;

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
                        payableDullColor, currency),
                    _buildStatusLegend(l10n.paid, status.paidPayables,
                        payableDarkColor, currency),
                    _buildStatusLegend(l10n.statusCancelled,
                        status.cancelledPayables, Colors.grey, currency),
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
                        receivableDullColor, currency),
                    _buildStatusLegend(
                        l10n.receivedLabel,
                        status.receivedReceivables,
                        receivableDarkColor,
                        currency),
                    _buildStatusLegend(
                        l10n.statusCancelled,
                        status.cancelledReceivables,
                        Colors.grey,
                        currency),
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
      String label, double amount, Color color, AppCurrency currency) {
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
          Text(AmountFormatter.formatWithCurrency(amount, currency),
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
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final currencySymbol = currency.symbol;
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
                                e.totalAmount, currency),
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
// ─────────────────────────────────────────────────────────────────────────────
// Analytics Sections Customise Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyticsSectionsSheet extends ConsumerWidget {
  const _AnalyticsSectionsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hidden = ref.watch(analyticsSectionsProvider);
    final notifier = ref.read(analyticsSectionsProvider.notifier);
    final allVisible = hidden.isEmpty;

    final sections = [
      (AnalyticsSection.financialSummary, l10n.financialSummary,
          Symbols.account_balance),
      (AnalyticsSection.contactSummaries, l10n.contactSummaries,
          Symbols.people),
      (AnalyticsSection.expensesByCategory, l10n.expensesByCategory,
          Symbols.pie_chart),
      (AnalyticsSection.incomeVsExpenseTrend, l10n.incomeVsExpenseTrend,
          Symbols.bar_chart),
      (AnalyticsSection.payablesVsReceivablesTrend,
          l10n.payablesVsReceivablesTrend, Symbols.swap_horiz),
      (AnalyticsSection.topContacts, l10n.topContactsByBalance,
          Symbols.leaderboard),
      (AnalyticsSection.paymentStatus, l10n.paymentStatusDistribution,
          Symbols.donut_large),
      (AnalyticsSection.incomeByCategory, l10n.incomeByCategory,
          Symbols.pie_chart),
      (AnalyticsSection.netWorth, l10n.netWorth, Symbols.account_balance_wallet),
      (AnalyticsSection.balanceDistribution, l10n.balanceDistribution,
          Symbols.pie_chart),
      (AnalyticsSection.spendingByAccount, l10n.spendingByAccount,
          Symbols.bar_chart),
      (AnalyticsSection.creditUtilisation, l10n.creditUtilisation,
          Symbols.credit_card),
      (AnalyticsSection.transferFlow, l10n.transferFlow, Symbols.swap_horiz),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Icon(Symbols.tune,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.customiseSections,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: allVisible ? l10n.deselectAll : l10n.selectAll,
                  icon: Icon(
                    allVisible
                        ? Icons.deselect_rounded
                        : Icons.select_all_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: allVisible
                      ? notifier.deselectAll
                      : notifier.selectAll,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Section list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sections.length,
              itemBuilder: (context, i) {
                final (section, title, icon) = sections[i];
                final isVisible = !hidden.contains(section);
                return SwitchListTile(
                  secondary: Icon(icon,
                      size: 20,
                      color: isVisible
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.4)),
                  title: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isVisible
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                    ),
                  ),
                  value: isVisible,
                  onChanged: (_) => notifier.toggle(section),
                  activeColor: theme.colorScheme.primary,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final Widget child;
  final int sectionIndex;
  final bool showAllTimeBadge;

  const _CollapsibleSection({
    required this.title,
    required this.child,
    required this.sectionIndex,
    this.showAllTimeBadge = false,
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
                      if (widget.showAllTimeBadge) ...[
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.all_inclusive,
                                size: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.allTime,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
