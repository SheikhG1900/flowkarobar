import 'package:flowpaisa/l10n/app_localizations.dart';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/export_service.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/core/services/in_app_review_service.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  final db = ref.watch(databaseProvider);
  final userProfile = ref.watch(userProfileProvider);
  final transactionsRepository = TransactionsRepository(db);
  return ExportService(transactionsRepository, db,
      dateFormat: userProfile.dateFormat);
});

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;
  String get currencySymbol => ref.watch(currencySymbolProvider);
  int get decimalPlaces => ref.watch(currencyDecimalPlacesProvider);
  DateTime? _startDate;
  DateTime? _endDate;
  ExportSummary? _summary;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default to current month
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    if (_startDate == null || _endDate == null) return;

    setState(() => _isLoading = true);

    try {
      final exportService = ref.read(exportServiceProvider);
      final summary = await exportService.getExportSummary(
        startDate: _startDate!,
        endDate: _endDate!,
      );
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  Future<void> _exportToCSV() async {
    final theme = Theme.of(context);
    if (_startDate == null || _endDate == null) {
      ToastUtils.showWarningToast(context, ref, l10n.selectDateRange);
      return;
    }

    // Flag to track if loading dialog is open
    bool isLoadingDialogOpen = true;

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

      // Check for Desktop platforms
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // Generate content
        final csvContent = await exportService.generateCSVContent(
          startDate: _startDate!,
          endDate: _endDate!,
          l10n: l10n,
          currency: currency,
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          isLoadingDialogOpen = false;

          // Ask for save location
          final fileName =
              'flowpaisa_export_${AppDateFormatter.formatForFileName(DateTime.now())}.csv';
          final FileSaveLocation? result = await getSaveLocation(
            suggestedName: fileName,
            acceptedTypeGroups: [
              const XTypeGroup(
                label: 'CSV',
                extensions: ['csv'],
              ),
            ],
          );

          if (result != null) {
            final file = File(result.path);
            await file.writeAsString(csvContent);

            if (mounted) {
              ToastUtils.showSuccessToast(
                  context, ref, l10n.exportSavedTo(result.path));
              ref.read(inAppReviewServiceProvider).maybeRequestReview();
            }
          }
        }
      } else {
        // Mobile behavior - Use cache directory (share_plus FileProvider supports cache)
        final filePath = await exportService.exportTransactionsToCSV(
          startDate: _startDate!,
          endDate: _endDate!,
          useCache:
              true, // Use cache - share_plus FileProvider exposes this directory
          currency: currency,
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          isLoadingDialogOpen = false;
          ref.read(inAppReviewServiceProvider).maybeRequestReview();

          // Ask to share
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.exportSuccessful),
              content: Text(l10n.transactionHistoryReady),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.done),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await exportService.saveToDownloads(filePath);
                      if (context.mounted) {
                        ToastUtils.showSuccessToast(
                            context, ref, l10n.savedToDownloads);
                        Navigator.pop(context);
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
                FilledButton(
                  style: FilledButton.styleFrom(
                      foregroundColor: theme.colorScheme.onPrimary),
                  onPressed: () async {
                    Navigator.pop(context);
                    await exportService.shareCSVFile(filePath);
                  },
                  child: Text(l10n.share),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (isLoadingDialogOpen) {
          Navigator.pop(context);
        }
        ToastUtils.showErrorToast(
            context, ref, l10n.errorExporting(e.toString()));
      }
    }
  }

  Future<void> _exportToPDF() async {
    final theme = Theme.of(context);
    if (!PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }

    if (_startDate == null || _endDate == null) {
      ToastUtils.showWarningToast(context, ref, l10n.selectDateRange);
      return;
    }

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
      final pdfBytes = await exportService.exportTransactionsToPDF(
        startDate: _startDate!,
        endDate: _endDate!,
        currencySymbol: currencySymbol,
        decimalPlaces: decimalPlaces,
        l10n: l10n,
        currency: currency,
      );

      // Save PDF to temporary file for save/share actions
      final directory = await getTemporaryDirectory();
      final fileName =
          'flowpaisa_export_${AppDateFormatter.formatForFileName(DateTime.now())}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        Navigator.pop(context); // Close loading
        ref.read(inAppReviewServiceProvider).maybeRequestReview();

        // Show action dialog with three options
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.pdfReady),
            content: Text(l10n.pdfReportReady),
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

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
      _loadSummary();
    }
  }

  Future<void> _exportTestCategoriesPDF() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    final theme = Theme.of(context);
    try {
      final exportService = ref.read(exportServiceProvider);

      // Generate test PDF bytes
      final pdfBytes = await exportService.generateTestCategoriesPDF();

      // Save PDF to temporary file for save/share actions
      final directory = await getTemporaryDirectory();
      final fileName =
          'flowpaisa_test_categories_${AppDateFormatter.formatForFileName(DateTime.now())}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        Navigator.pop(context); // Close loading

        // Show action dialog with three options
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.testPdfReady),
            content: Text(l10n.testPdfCategoriesReady),
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
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  Future<void> _selectEndDate() async {
    final now = DateTime.now();
    // Ensure firstDate is never after lastDate
    // Use startDate if available and not after now, otherwise use a safe default
    final firstDate = _startDate != null && !_startDate!.isAfter(now)
        ? _startDate!
        : DateTime(2000);

    // Ensure initialDate is within the valid range [firstDate, lastDate]
    DateTime initialDate;
    if (_endDate != null) {
      if (_endDate!.isAfter(now)) {
        initialDate = now; // Clamp to lastDate if endDate is in the future
      } else if (_endDate!.isBefore(firstDate)) {
        initialDate = firstDate; // Clamp to firstDate if endDate is too early
      } else {
        initialDate = _endDate!;
      }
    } else {
      initialDate = now;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _endDate = picked);
      _loadSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exportData),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient:
                    AppColors.getPrimaryGradient(theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.file_download,
                    color: theme.colorScheme.onPrimary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.exportYourData,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.downloadHistoryCsvPdf,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date Range Section
            Text(
              l10n.selectDateRange,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Start Date
            _buildDateCard(
              context,
              label: l10n.startDate,
              date: _startDate,
              onTap: _selectStartDate,
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 12),

            // End Date
            _buildDateCard(
              context,
              label: l10n.endDate,
              date: _endDate,
              onTap: _selectEndDate,
              icon: Icons.event,
            ),
            const SizedBox(height: 32),

            // Summary Section
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_summary != null)
              _buildSummarySection(context, _summary!),
            const SizedBox(height: 32),

            // Export Buttons
            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    label: 'CSV',
                    icon: Icons.table_chart,
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.teal],
                    ),
                    onPressed: _exportToCSV,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      GradientButton(
                        label: 'PDF',
                        icon: Icons.picture_as_pdf,
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.orange],
                        ),
                        onPressed: _exportToPDF,
                      ),
                      if (!PremiumGate.isPremium(ref))
                        const Padding(
                          padding: EdgeInsets.only(top: 8, right: 8),
                          child:
                              Icon(Icons.lock, size: 16, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Test Categories Button (for testing icons) - only in debug mode
            if (kDebugMode) ...[
              OutlinedButton.icon(
                onPressed: _exportTestCategoriesPDF,
                icon: const Icon(Icons.bug_report),
                label: Text(l10n.testCategoriesPdf),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Info Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.csvInfoNote,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date != null
                            ? AppDateFormatter.formatDate(date,
                                pattern:
                                    ref.watch(userProfileProvider).dateFormat)
                            : 'Select date',
                        style: theme.textTheme.titleMedium?.copyWith(
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
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, ExportSummary summary) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.exportSummary,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                context,
                l10n.totalTransactions,
                summary.totalTransactions.toString(),
                Icons.receipt_long,
                theme.colorScheme.primary,
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                context,
                l10n.income,
                AmountFormatter.formatWithCurrency(
                    summary.totalIncome, currencySymbol, decimalPlaces),
                Icons.arrow_downward,
                AppColors.incomeColor,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                context,
                l10n.expense,
                AmountFormatter.formatWithCurrency(
                    summary.totalExpense, currencySymbol, decimalPlaces),
                Icons.arrow_upward,
                AppColors.expenseColor,
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                context,
                l10n.netBalance,
                AmountFormatter.formatWithCurrency(
                    summary.netBalance, currencySymbol, decimalPlaces),
                Icons.account_balance_wallet,
                summary.netBalance >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
