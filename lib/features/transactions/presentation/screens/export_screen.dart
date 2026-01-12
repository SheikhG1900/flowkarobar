import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/export_service.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:intl/intl.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  final db = ref.watch(databaseProvider);
  final transactionsRepository = TransactionsRepository(db);
  return ExportService(transactionsRepository);
});

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String get currencySymbol => ref.watch(currencySymbolProvider);
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
        ToastUtils.showErrorToast(context, 'Error loading summary: $e');
      }
    }
  }

  Future<void> _exportToCSV() async {
    if (_startDate == null || _endDate == null) {
      ToastUtils.showWarningToast(context, 'Please select date range');
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

      // Check for Desktop platforms
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // Generate content
        final csvContent = await exportService.generateCSVContent(
          startDate: _startDate!,
          endDate: _endDate!,
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          isLoadingDialogOpen = false;

          // Ask for save location
          final fileName =
              'flowpaisa_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
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
                  context, 'Export saved to ${result.path}');
            }
          }
        }
      } else {
        // Mobile behavior - Save to Cache by default
        final filePath = await exportService.exportTransactionsToCSV(
          startDate: _startDate!,
          endDate: _endDate!,
          useCache: true, // Use temporary storage
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          isLoadingDialogOpen = false;

          // Ask to share
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Export Successful'),
              content:
                  const Text('Your transaction history is ready to share.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await exportService.saveToDownloads(filePath);
                      if (context.mounted) {
                        ToastUtils.showSuccessToast(
                            context, 'Saved to Downloads');
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ToastUtils.showErrorToast(context, 'Error saving: $e');
                      }
                    }
                  },
                  child: const Text('Save Copy'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await exportService.shareCSVFile(filePath);
                  },
                  child: const Text('Share'),
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
        ToastUtils.showErrorToast(context, 'Error exporting: $e');
      }
    }
  }

  Future<void> _exportToPDF() async {
    if (!PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }

    if (_startDate == null || _endDate == null) {
      ToastUtils.showWarningToast(context, 'Please select date range');
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
      // Simulate PDF generation for now as we haven't implemented it fully
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pop(context); // Close loading
        ToastUtils.showInfoToast(context, 'PDF Export coming soon!');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ToastUtils.showErrorToast(context, 'Error exporting: $e');
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

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
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
        title: const Text('Export Data'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.secondaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brightCyan.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.file_download,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Export Your Data',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Download your transaction history as CSV or PDF',
                    style: TextStyle(
                      color: Colors.white,
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
              'Select Date Range',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Start Date
            _buildDateCard(
              context,
              label: 'Start Date',
              date: _startDate,
              onTap: _selectStartDate,
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 12),

            // End Date
            _buildDateCard(
              context,
              label: 'End Date',
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
                    color: AppColors.brightCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'CSV files can be opened in Excel or Google Sheets. PDF reports are great for sharing.',
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
                    color: AppColors.brightCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.brightCyan),
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
                            ? DateFormat.yMMMd().format(date)
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
          'Export Summary',
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
                'Total Transactions',
                summary.totalTransactions.toString(),
                Icons.receipt_long,
                theme.colorScheme.primary,
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                context,
                'Income',
                '$currencySymbol${summary.totalIncome.toStringAsFixed(2)}',
                Icons.arrow_downward,
                AppColors.incomeColor,
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                context,
                'Expense',
                '$currencySymbol${summary.totalExpense.toStringAsFixed(2)}',
                Icons.arrow_upward,
                AppColors.expenseColor,
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                context,
                'Net Balance',
                '$currencySymbol${summary.netBalance.toStringAsFixed(2)}',
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
