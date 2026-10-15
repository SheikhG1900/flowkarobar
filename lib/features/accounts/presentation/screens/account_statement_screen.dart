import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_details_dialog.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_transfer_sheet.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/shared/models/date_range_state.dart';
import 'package:flowpaisa/shared/widgets/collapsible_list_summary.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

class AccountStatementScreen extends ConsumerStatefulWidget {
  final Account account;

  const AccountStatementScreen({super.key, required this.account});

  @override
  ConsumerState<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends ConsumerState<AccountStatementScreen> {
  late DateRangeState _dateRangeState;

  @override
  void initState() {
    super.initState();
    _dateRangeState = DateRangeState.currentMonth();
  }

  void _updateRange(DateRangeState newRange) {
    setState(() {
      _dateRangeState = newRange;
    });
  }

  void _nextPeriod() {
    setState(() {
      switch (_dateRangeState.type) {
        case DateRangeType.month:
          final nextMonth = DateTime(_dateRangeState.startDate.year, _dateRangeState.startDate.month + 1, 1);
          _dateRangeState = DateRangeState.month(nextMonth);
          break;
        case DateRangeType.quarter:
          final currentQuarter = ((_dateRangeState.startDate.month - 1) ~/ 3) + 1;
          final nextQuarter = currentQuarter == 4 ? 1 : currentQuarter + 1;
          final nextYear = currentQuarter == 4 ? _dateRangeState.startDate.year + 1 : _dateRangeState.startDate.year;
          _dateRangeState = DateRangeState.quarter(nextYear, nextQuarter);
          break;
        case DateRangeType.year:
          _dateRangeState = DateRangeState.year(_dateRangeState.startDate.year + 1);
          break;
        case DateRangeType.custom:
          break;
      }
    });
  }

  void _previousPeriod() {
    setState(() {
      switch (_dateRangeState.type) {
        case DateRangeType.month:
          final prevMonth = DateTime(_dateRangeState.startDate.year, _dateRangeState.startDate.month - 1, 1);
          _dateRangeState = DateRangeState.month(prevMonth);
          break;
        case DateRangeType.quarter:
          final currentQuarter = ((_dateRangeState.startDate.month - 1) ~/ 3) + 1;
          final prevQuarter = currentQuarter == 1 ? 4 : currentQuarter - 1;
          final prevYear = currentQuarter == 1 ? _dateRangeState.startDate.year - 1 : _dateRangeState.startDate.year;
          _dateRangeState = DateRangeState.quarter(prevYear, prevQuarter);
          break;
        case DateRangeType.year:
          _dateRangeState = DateRangeState.year(_dateRangeState.startDate.year - 1);
          break;
        case DateRangeType.custom:
          break;
      }
    });
  }

  Future<void> _exportCSV(List<StatementEntry> entries, AppCurrency currency) async {
    final l10n = AppLocalizations.of(context)!;
    final exportService = ref.read(exportServiceProvider);

    try {
      final csvContent = _generateCSVContent(entries, currency, l10n);
      final fileName = 'Statement_${widget.account.name}_${AppDateFormatter.formatDate(_dateRangeState.startDate, pattern: "yyyyMMdd")}_${AppDateFormatter.formatDate(_dateRangeState.endDate, pattern: "yyyyMMdd")}.csv';

      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final FileSaveLocation? result = await getSaveLocation(
          suggestedName: fileName,
          acceptedTypeGroups: [
            const XTypeGroup(label: 'CSV', extensions: ['csv']),
          ],
        );

        if (result != null) {
          final file = File(result.path);
          await file.writeAsString(csvContent);
          if (mounted) {
            ToastUtils.showSuccessToast(context, ref, 'Statement saved successfully!');
          }
        }
      } else {
        // Mobile sharing
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(csvContent);
        await exportService.shareCSVFile(file.path);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, 'Failed to export CSV: $e');
      }
    }
  }

  Future<void> _exportPDF(List<StatementEntry> entries, AppCurrency currency) async {
    final l10n = AppLocalizations.of(context)!;
    final exportService = ref.read(exportServiceProvider);

    // Show loading indicator dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: AppLoadingIndicator(),
      ),
    );

    try {
      final pdfDoc = await exportService.generateAccountStatementPDF(
        accountName: widget.account.name,
        startDate: _dateRangeState.startDate,
        endDate: _dateRangeState.endDate,
        entries: entries,
        currency: currency,
        l10n: l10n,
      );
      final pdfBytes = await pdfDoc.save();
      final fileName = 'Statement_${widget.account.name}_${AppDateFormatter.formatDate(_dateRangeState.startDate, pattern: "yyyyMMdd")}_${AppDateFormatter.formatDate(_dateRangeState.endDate, pattern: "yyyyMMdd")}.pdf';

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        Navigator.pop(context); // Close loading indicator

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
                    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
                      final FileSaveLocation? result = await getSaveLocation(
                        suggestedName: fileName,
                        acceptedTypeGroups: [
                          const XTypeGroup(label: 'PDF', extensions: ['pdf']),
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
                    foregroundColor: Theme.of(context).colorScheme.onPrimary),
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
        Navigator.pop(context); // Close loading indicator if open
        ToastUtils.showErrorToast(context, ref, 'Failed to export PDF: $e');
      }
    }
  }

  void _showExportOptions(BuildContext context, List<StatementEntry> entries, AppCurrency currency) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isPremium = ref.read(premiumProvider).isPremium;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    l10n.exportData,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: Text(l10n.exportAsCSV),
              subtitle: Text(l10n.exportAsCSVSubtitle),
              onTap: () {
                Navigator.pop(sheetContext);
                _exportCSV(entries, currency);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(l10n.exportAsPDF),
              subtitle: Text(l10n.exportAsPDFSubtitle),
              trailing: !isPremium
                  ? const Icon(Icons.lock, color: Colors.orange)
                  : const Icon(Icons.verified, color: Colors.blue),
              onTap: () {
                Navigator.pop(sheetContext);
                if (!isPremium) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PremiumScreen(),
                    ),
                  );
                } else {
                  _exportPDF(entries, currency);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _generateCSVContent(List<StatementEntry> entries, AppCurrency currency, AppLocalizations l10n) {
    final csvRows = <List<String>>[];
    
    // Header Info
    csvRows.add(['Account Statement', widget.account.name]);
    csvRows.add(['Period', '${AppDateFormatter.formatDate(_dateRangeState.startDate)} - ${AppDateFormatter.formatDate(_dateRangeState.endDate)}']);
    csvRows.add([]);
    
    // Table Headers
    csvRows.add(['Date', 'Title', 'Description', 'Debit', 'Credit', 'Balance (${currency.code})']);

    for (final entry in entries.reversed) {
      final isDebit = entry.entryType == StatementEntryType.debit;
      final debitVal = isDebit ? AmountFormatter.formatAmount(entry.amount, currency.decimalPlaces, scaleFactor: currency.scaleFactor) : '';
      final creditVal = !isDebit ? AmountFormatter.formatAmount(entry.amount, currency.decimalPlaces, scaleFactor: currency.scaleFactor) : '';
      final balVal = AmountFormatter.formatAmount(entry.runningBalance, currency.decimalPlaces, scaleFactor: currency.scaleFactor);

      csvRows.add([
        AppDateFormatter.formatDate(entry.date),
        entry.title,
        entry.description ?? '',
        debitVal,
        creditVal,
        balVal,
      ]);
    }

    // Convert to CSV string
    return csvRows.map((row) => row.map((val) => '"${val.replaceAll('"', '""')}"').join(',')).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;
    final accounts = ref.watch(accountsStreamProvider).value ?? [];

    if (currency == null) {
      return const Scaffold(body: AppLoadingIndicator());
    }

    final params = AccountStatementParams(
      accountUuid: widget.account.uuid,
      startDate: _dateRangeState.startDate,
      endDate: _dateRangeState.endDate,
    );

    final statementAsync = ref.watch(accountStatementProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountStatement),
        actions: [
          if (statementAsync.hasValue && statementAsync.value!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: l10n.exportData,
              onPressed: () => _showExportOptions(context, statementAsync.value!, currency),
            ),
        ],
      ),
      body: Column(
        children: [
          _DateRangeSelector(
            selectedDateRange: _dateRangeState,
            onDateRangeChanged: _updateRange,
            onNextPeriod: _nextPeriod,
            onPreviousPeriod: _previousPeriod,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: statementAsync.when(
              data: (entries) {
                double totalCredits = 0.0;
                double totalDebits = 0.0;
                double startingBalance = 0.0;
                double endingBalance = 0.0;

                if (entries.isNotEmpty) {
                  final lastEntry = entries.first;
                  final firstEntry = entries.last;

                  for (final entry in entries) {
                    if (entry.entryType == StatementEntryType.credit) {
                      totalCredits += entry.amount;
                    } else {
                      totalDebits += entry.amount;
                    }
                  }

                  endingBalance = lastEntry.runningBalance;
                  final firstIsExpense = firstEntry.entryType == StatementEntryType.debit;
                  startingBalance = firstEntry.runningBalance - (firstIsExpense ? -firstEntry.amount : firstEntry.amount);
                }

                return CollapsibleListSummary(
                  title: l10n.financialSummary,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryTile(
                              label: l10n.startingBalance,
                              amount: startingBalance,
                              color: theme.colorScheme.primary,
                              currency: currency,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SummaryTile(
                              label: l10n.endingBalance,
                              amount: endingBalance,
                              color: theme.colorScheme.primary,
                              currency: currency,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryTile(
                              label: l10n.totalCredits,
                              amount: totalCredits,
                              color: AppColors.incomeColor,
                              currency: currency,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SummaryTile(
                              label: l10n.totalDebits,
                              amount: totalDebits,
                              color: AppColors.expenseColor,
                              currency: currency,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryTile(
                              label: l10n.netFlow,
                              amount: totalCredits - totalDebits,
                              color: (totalCredits - totalDebits) >= 0 ? AppColors.incomeColor : AppColors.expenseColor,
                              currency: currency,
                              showSign: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text('Error: $err'),
            ),
          ),

          // Entries List
          Expanded(
            child: statementAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noStatementEntries,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isCredit = entry.entryType == StatementEntryType.credit;
                    final amountColor = isCredit ? AppColors.incomeColor : AppColors.expenseColor;
                    final prefix = isCredit ? '+' : '-';
                    final isTransfer = entry.originalObject is AccountTransfer;

                    Account? otherAccount;
                    if (isTransfer) {
                      final tf = entry.originalObject as AccountTransfer;
                      final otherAccountUuid = tf.fromAccountUuid == widget.account.uuid
                          ? tf.toAccountUuid
                          : tf.fromAccountUuid;
                      otherAccount = accounts.firstWhereOrNull((a) => a.uuid == otherAccountUuid);
                    }

                    Widget leadingWidget;
                    if (isTransfer) {
                      // Custom distinct appearance for transfers (blue double arrow)
                      leadingWidget = Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.swap_horiz_outlined,
                          color: Colors.blue,
                          size: 20,
                        ),
                      );
                    } else if (entry.originalObject is Transaction) {
                      final tx = entry.originalObject as Transaction;
                      // Fetch category details for icon and color
                      final categoryUuid = tx.categoryUuid;
                      leadingWidget = Consumer(
                        builder: (context, ref, child) {
                          final categories = ref.watch(categoriesListProvider).value ?? [];
                          final category = categories.firstWhereOrNull((c) => c.uuid == categoryUuid);
                          if (category != null) {
                            Color categoryColor;
                            try {
                              categoryColor = Color(int.parse(category.color!.replaceAll('#', '0xFF')));
                            } catch (_) {
                              categoryColor = amountColor;
                            }
                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: CategoryHelper.buildCategoryIcon(
                                category.icon,
                                categoryColor,
                                category.type == 'EXPENSE',
                                size: 20,
                              ),
                            );
                          }
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: amountColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                              color: amountColor,
                              size: 20,
                            ),
                          );
                        },
                      );
                    } else {
                      leadingWidget = Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: amountColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                          color: amountColor,
                          size: 20,
                        ),
                      );
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (isTransfer) {
                            // Open transfer sheet for editing
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => AccountTransferSheet(
                                existingTransfer: entry.originalObject as AccountTransfer,
                              ),
                            );
                          } else if (entry.originalObject is Transaction) {
                            // Open transaction details dialog
                            showDialog(
                              context: context,
                              builder: (context) => TransactionDetailsDialog(
                                transactionUuid: entry.id,
                              ),
                            );
                          }
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: leadingWidget,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  entry.title,
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isTransfer && otherAccount != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: (otherAccount.color != null
                                            ? Color(int.parse(otherAccount.color!.replaceAll('#', '0xFF')))
                                            : theme.colorScheme.primary).withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        IconHelper.getIconData(otherAccount.icon) ?? Icons.account_balance_wallet,
                                        size: 12,
                                        color: otherAccount.color != null
                                            ? Color(int.parse(otherAccount.color!.replaceAll('#', '0xFF')))
                                            : theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    '$prefix${AmountFormatter.formatWithCurrency(entry.amount, currency)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: amountColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (entry.description != null && entry.description!.isNotEmpty) ...[
                                        Text(
                                          entry.description!,
                                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                      ],
                                      Text(
                                        AppDateFormatter.formatDate(entry.date),
                                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  AmountFormatter.formatWithCurrency(entry.runningBalance, currency),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const AppLoadingIndicator(),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final AppCurrency currency;
  final bool showSign;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.currency,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    String formattedAmount = AmountFormatter.formatWithCurrency(amount.abs(), currency);
    if (showSign) {
      if (amount > 0) {
        formattedAmount = '+$formattedAmount';
      } else if (amount < 0) {
        formattedAmount = '-$formattedAmount';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedAmount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
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
        return '${AppDateFormatter.formatDate(selectedDateRange.startDate)} - ${AppDateFormatter.formatDate(selectedDateRange.endDate)}';
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
