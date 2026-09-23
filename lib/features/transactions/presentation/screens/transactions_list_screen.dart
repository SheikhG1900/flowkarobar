import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_undraw/flutter_undraw.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/edit_transaction_screen.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:flowpaisa/shared/models/paginated_state.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/core/utils/category_helper.dart';
import 'package:flowpaisa/core/utils/localization_helper.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/schedule_list_item.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/schedule_service_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/bulk_import_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/export_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flowpaisa/core/services/in_app_review_service.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/presentation/screens/premium_screen.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/edit_schedule_screen.dart';
import 'package:flowpaisa/shared/widgets/filter_bottom_sheet.dart';
import 'package:flowpaisa/shared/widgets/app_loading_indicator.dart';
import 'package:flowpaisa/shared/widgets/collapsible_list_summary.dart';
import 'package:flowpaisa/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/transaction_speed_dial.dart';
import 'package:flowpaisa/shared/widgets/faded_bottom_logo.dart';
import 'package:flowpaisa/features/receipt_scan/presentation/screens/scan_receipt_screen.dart';
import 'package:flowpaisa/features/voice_command/presentation/screens/voice_add_screen.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:collection/collection.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:flowpaisa/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flowpaisa/shared/widgets/contextual_guide.dart';

class TransactionsListScreen extends ConsumerStatefulWidget {
  final bool startTour;
  final DateTime? initialDate;
  const TransactionsListScreen(
      {super.key, this.startTour = false, this.initialDate});

  @override
  ConsumerState<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState extends ConsumerState<TransactionsListScreen>
    with SingleTickerProviderStateMixin {
  /// Lets the bottom sheet (and loading dialog) finish closing before the next step.
  static const Duration _bulkImportSheetCloseDelay =
      Duration(milliseconds: 320);

  late ScrollController _scrollController;
  late TabController _tabController;
  late TextEditingController _searchController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    final initialSearchQuery = ref.read(transactionsPaginatedProvider).searchQuery;
    _searchController = TextEditingController(text: initialSearchQuery);
    _isSearching = initialSearchQuery != null && initialSearchQuery.isNotEmpty;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowGuide();
      if (widget.initialDate != null) {
        final startOfDay = DateTime(
          widget.initialDate!.year,
          widget.initialDate!.month,
          widget.initialDate!.day,
          0,
          0,
          0,
        );
        final endOfDay = DateTime(
          widget.initialDate!.year,
          widget.initialDate!.month,
          widget.initialDate!.day,
          23,
          59,
          59,
        );
        ref.read(transactionsPaginatedProvider.notifier).applyFilters(
              ref
                  .read(transactionsPaginatedProvider.notifier)
                  .currentFilters
                  .copyWith(
                    startDate: startOfDay,
                    endDate: endOfDay,
                  ),
            );
      }

      // Automatically save the incoming search/filter if it's not empty
      final currentFilters = ref.read(transactionsPaginatedProvider.notifier).currentFilters;
      final searchQuery = ref.read(transactionsPaginatedProvider).searchQuery ?? '';
      ref.read(recentSearchesProvider.notifier).saveSearch(
        searchQuery: searchQuery,
        filters: currentFilters,
      );
    });
  }

  void _checkAndShowGuide() {
    final hasSeen = ref.read(transactionsGuideSeenProvider);
    if (!hasSeen) {
      final l10n = AppLocalizations.of(context)!;
      ContextualGuide.show(
        context,
        title: l10n.transactions,
        items: [
          GuideItem(
            illustration: UndrawIllustration.fileBundle,
            title: l10n.guideBulkImportTitle,
            description: l10n.guideBulkImportBody,
          ),
          GuideItem(
            illustration: UndrawIllustration.cloudSync,
            title: l10n.guideAutoSettleTitle,
            description: l10n.guideAutoSettleBody,
          ),
          GuideItem(
            illustration: UndrawIllustration.teamCollaboration,
            title: l10n.guideSplitSettleTitle,
            description: l10n.guideSplitSettleBody,
          ),
          GuideItem(
            illustration: UndrawIllustration.activeOptions,
            title: l10n.guideBudgetsTitle,
            description: l10n.guideBudgetsBody,
          ),
        ],
        onDismiss: () {
          ref.read(transactionsGuideSeenProvider.notifier).setSeen();
        },
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      ref.read(transactionsPaginatedProvider.notifier).loadMore();
    }
  }

  void _showFilterBottomSheet() {
    final notifier = ref.read(transactionsPaginatedProvider.notifier);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => FilterBottomSheet(
          type: FilterType.transactions,
          initialFilters: notifier.currentFilters,
          scrollController: scrollController,
          onApply: (filters) {
            notifier.applyFilters(filters);
            ref.read(recentSearchesProvider.notifier).saveSearch(
              searchQuery: ref.read(transactionsPaginatedProvider).searchQuery ?? '',
              filters: filters,
            );
            setState(() {}); // Force rebuild to update badge
          },
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext parentContext) {
    final l10n = AppLocalizations.of(parentContext)!;
    final isPremium = ref.read(premiumProvider).isPremium;
    bool includePayablesAndReceivables = true;

    showModalBottomSheet(
      context: parentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      l10n.exportData,
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    if (!isPremium)
                      const Icon(Icons.lock, color: Colors.orange, size: 20),
                    if (isPremium)
                      const Icon(Icons.verified, color: Colors.blue, size: 20),
                  ],
                ),
              ),
              SwitchListTile(
                title: Text(l10n.includePayablesReceivables),
                subtitle: Text(l10n.includePayablesReceivablesSubtitle),
                value: includePayablesAndReceivables,
                activeThumbColor: Theme.of(sheetContext).colorScheme.primary,
                onChanged: (val) {
                  setSheetState(() {
                    includePayablesAndReceivables = val;
                  });
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: Text(l10n.exportAsCSV),
                subtitle: Text(l10n.exportAsCSVSubtitle),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _exportFilteredCSV(includePayablesAndReceivables: includePayablesAndReceivables);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(l10n.exportAsPDF),
                subtitle: Text(l10n.exportAsPDFSubtitle),
                trailing: !isPremium
                    ? const Icon(Icons.lock, color: Colors.orange)
                    : const Icon(Icons.verified, color: Colors.blue),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  if (!isPremium) {
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  } else {
                    await _exportFilteredPDF(includePayablesAndReceivables: includePayablesAndReceivables);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.deepPurple),
                title: Text(l10n.exportPdfWithAttachments),
                subtitle: Text(l10n.exportPdfWithAttachmentsSubtitle),
                trailing: !isPremium
                    ? const Icon(Icons.lock, color: Colors.orange)
                    : const Icon(Icons.verified, color: Colors.blue),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  if (!isPremium) {
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  } else {
                    await _exportFilteredPdfWithAttachments();
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportFilteredCSV({bool includePayablesAndReceivables = true}) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final notifier = ref.read(transactionsPaginatedProvider.notifier);
    final filters = notifier.currentFilters;
    final searchQuery = ref.read(transactionsPaginatedProvider).searchQuery;

    final startDate = filters.startDate ?? DateTime(1970, 1, 1);
    final endDate = filters.endDate ?? DateTime(2100, 12, 31);

    bool isLoadingDialogOpen = true;

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

      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final csvContent = await exportService.generateCSVContent(
          startDate: startDate,
          endDate: endDate,
          l10n: l10n,
          filters: filters,
          searchQuery: searchQuery,
          currency: currency,
          includePayablesAndReceivables: includePayablesAndReceivables,
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          isLoadingDialogOpen = false;

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
        final filePath = await exportService.exportTransactionsToCSV(
          startDate: startDate,
          endDate: endDate,
          useCache: true,
          filters: filters,
          searchQuery: searchQuery,
          currency: currency,
          includePayablesAndReceivables: includePayablesAndReceivables,
        );

        if (mounted) {
          Navigator.pop(context); // Close loading
          isLoadingDialogOpen = false;
          ref.read(inAppReviewServiceProvider).maybeRequestReview();

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

  Future<void> _exportFilteredPDF({bool includePayablesAndReceivables = true}) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currencySymbol = ref.read(currencySymbolProvider);
    final decimalPlaces = ref.read(currencyDecimalPlacesProvider);

    if (!PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }

    final notifier = ref.read(transactionsPaginatedProvider.notifier);
    final filters = notifier.currentFilters;
    final searchQuery = ref.read(transactionsPaginatedProvider).searchQuery;

    final startDate = filters.startDate ?? DateTime(1970, 1, 1);
    final endDate = filters.endDate ?? DateTime(2100, 12, 31);

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

      final pdfBytes = await exportService.exportTransactionsToPDF(
        startDate: startDate,
        endDate: endDate,
        currencySymbol: currencySymbol,
        decimalPlaces: decimalPlaces,
        l10n: l10n,
        filters: filters,
        searchQuery: searchQuery,
        currency: currency,
        includePayablesAndReceivables: includePayablesAndReceivables,
      );

      final directory = await getTemporaryDirectory();
      final fileName =
          'flowpaisa_export_${AppDateFormatter.formatForFileName(DateTime.now())}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        Navigator.pop(context); // Close loading
        ref.read(inAppReviewServiceProvider).maybeRequestReview();

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

  Future<void> _exportFilteredPdfWithAttachments() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currencySymbol = ref.read(currencySymbolProvider);
    final decimalPlaces = ref.read(currencyDecimalPlacesProvider);

    if (!PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }

    final notifier = ref.read(transactionsPaginatedProvider.notifier);
    final filters = notifier.currentFilters;

    final startDate = filters.startDate;
    final endDate = filters.endDate;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.generatingPdfReport,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.generatingPdfReportSubtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final exportService = ref.read(exportServiceProvider);
      final currency = ref.read(currentCurrencyProvider).value;

      final pdfBytes = await exportService.exportTransactionsWithAttachmentsToPDF(
        currencySymbol: currencySymbol,
        decimalPlaces: decimalPlaces,
        l10n: l10n,
        currencyObj: currency,
        startDate: startDate,
        endDate: endDate,
      );

      final directory = await getTemporaryDirectory();
      final fileName =
          'flowpaisa_attachments_export_${AppDateFormatter.formatForFileName(DateTime.now())}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        Navigator.pop(context); // Close loading
        ref.read(inAppReviewServiceProvider).maybeRequestReview();

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
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  void _showImportOptions(BuildContext parentContext) {
    final l10n = AppLocalizations.of(parentContext)!;
    final isPremium = ref.read(premiumProvider).isPremium;
    final theme = Theme.of(parentContext);
    final loadingBarrierColor = theme.brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.26)
        : Colors.black.withValues(alpha: 0.06);

    showModalBottomSheet(
      context: parentContext,
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
                    l10n.bulkImport,
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  if (!isPremium)
                    const Icon(Icons.lock, color: Colors.orange, size: 20),
                  if (isPremium)
                    const Icon(Icons.verified, color: Colors.blue, size: 20),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.content_paste),
              title: Text(l10n.pasteFromClipboard),
              onTap: () async {
                Navigator.pop(sheetContext);
                await Future<void>.delayed(_bulkImportSheetCloseDelay);
                if (!parentContext.mounted) {
                  return;
                }
                if (!isPremium) {
                  Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                          builder: (context) => const PremiumScreen()));
                  return;
                }
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null) {
                  final text = data!.text!;
                  if (text.length > 4000 && parentContext.mounted) {
                    showDialog<void>(
                      context: parentContext,
                      barrierDismissible: false,
                      barrierColor: loadingBarrierColor,
                      builder: (dialogContext) =>
                          const _BulkImportLoadingDialog(),
                    );
                    await Future<void>.delayed(Duration.zero);
                    if (!parentContext.mounted) {
                      return;
                    }
                    Navigator.of(parentContext).pop();
                    await Future<void>.delayed(_bulkImportSheetCloseDelay);
                    if (!parentContext.mounted) {
                      return;
                    }
                  }
                  if (!parentContext.mounted) {
                    return;
                  }
                  Navigator.push(
                    parentContext,
                    MaterialPageRoute(
                      builder: (context) =>
                          BulkImportScreen(initialContent: text),
                    ),
                  );
                } else {
                  ToastUtils.showInfoToast(
                      parentContext, ref, 'Clipboard is empty');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_open),
              title: Text(l10n.pickCsvFile),
              onTap: () async {
                Navigator.pop(sheetContext);
                await Future<void>.delayed(_bulkImportSheetCloseDelay);
                if (!parentContext.mounted) {
                  return;
                }
                if (!isPremium) {
                  Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                          builder: (context) => const PremiumScreen()));
                  return;
                }
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['csv', 'txt'],
                );

                if (result != null && result.files.single.path != null) {
                  if (!parentContext.mounted) {
                    return;
                  }
                  showDialog<void>(
                    context: parentContext,
                    barrierDismissible: false,
                    barrierColor: loadingBarrierColor,
                    builder: (dialogContext) =>
                        const _BulkImportLoadingDialog(),
                  );
                  try {
                    final file = File(result.files.single.path!);
                    final content = await file.readAsString();
                    if (!parentContext.mounted) {
                      return;
                    }
                    Navigator.of(parentContext).pop();
                    await Future<void>.delayed(_bulkImportSheetCloseDelay);
                    if (!parentContext.mounted) {
                      return;
                    }
                    Navigator.push(
                      parentContext,
                      MaterialPageRoute(
                        builder: (context) =>
                            BulkImportScreen(initialContent: content),
                      ),
                    );
                  } catch (e) {
                    if (parentContext.mounted) {
                      Navigator.of(parentContext).pop();
                      ToastUtils.showErrorToast(
                          parentContext, ref, e.toString());
                    }
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final l10n = AppLocalizations.of(context)!;
    // Use the paginated provider
    final paginatedState = ref.watch(transactionsPaginatedProvider);
    final theme = Theme.of(context);
    final schedulesAsync = ref.watch(allSchedulesWithDetailsProvider);
    final hasSchedules = schedulesAsync.value?.isNotEmpty ?? false;
    final currentFilters =
        ref.watch(transactionsPaginatedProvider.notifier).currentFilters;
    final hasActiveFilters = !currentFilters.isEmpty;

    return Scaffold(
      key: const ValueKey('transactions-list-scaffold'),
      appBar: AppBar(
            key: const ValueKey('transactions-list-appbar'),
            title: _isSearching
                ? TextField(
                    key: const ValueKey('tx-search-field'),
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.searchTransactions,
                      border: InputBorder.none,
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    style: theme.textTheme.bodyLarge,
                    onChanged: (value) {
                      ref
                          .read(transactionsPaginatedProvider.notifier)
                          .search(value);
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        ref.read(recentSearchesProvider.notifier).saveSearch(
                          searchQuery: value,
                          filters: ref.read(transactionsPaginatedProvider.notifier).currentFilters,
                        );
                      }
                    },
                  )
                : Text(key: const ValueKey('tx-title'), l10n.transactions),
            bottom: hasSchedules && !_isSearching
                ? TabBar(
                    key: const ValueKey('tx-tab-bar'),
                    controller: _tabController,
                    tabs: [
                      Tab(key: const ValueKey('tx-tab-tx'), text: l10n.transactions),
                      Tab(key: const ValueKey('tx-tab-sched'), text: l10n.schedules),
                    ],
                  )
                : null,
            actions: [
              IconButton(
                key: const ValueKey('tx-filter-btn'),
                icon: Stack(
                  children: [
                    const Icon(Icons.filter_list),
                    if (hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          key: const ValueKey('tx-filter-badge'),
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: _showFilterBottomSheet,
              ),
              IconButton(
                key: const ValueKey('tx-search-btn'),
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchController.clear();
                      ref
                          .read(transactionsPaginatedProvider.notifier)
                          .search('');
                    } else {
                      _isSearching = true;
                    }
                  });
                },
              ),
              IconButton(
                key: const ValueKey('tx-recent-searches-btn'),
                icon: const Icon(Icons.history),
                tooltip: l10n.recentSearches,
                onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    final theme = Theme.of(context);
                    return Consumer(
                      builder: (context, ref, child) {
                        final recentSearches = ref.watch(recentSearchesProvider);
                        return Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                          ),
                          child: _buildRecentSearchesList(recentSearches, theme),
                        );
                      },
                    );
                  },
                );
              },
              ),
              if (!_isSearching)
                IconButton(
                  key: const ValueKey('tx-export-btn'),
                  icon: const Icon(Icons.file_download),
                  tooltip: l10n.exportData,
                  onPressed: () => _showExportOptions(context),
                ),
              if (!_isSearching && kDebugMode)
                PopupMenuButton<String>(
                  key: const ValueKey('tx-more-btn'),
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'generate_dummy') {
                      final service = ref.read(transactionServiceProvider);
                      try {
                        await service.generateDummyTransactions(count: 100);
                        if (context.mounted) {
                          ToastUtils.showSuccessToast(
                              context, ref, l10n.generated100DummyTransactions);
                          // Refresh the paginated list
                          ref
                              .read(transactionsPaginatedProvider.notifier)
                              .refresh();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ToastUtils.showErrorToast(
                              context, ref, l10n.errorOccurred(e.toString()));
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'generate_dummy',
                      child: Row(
                        children: [
                          const Icon(Icons.add_circle_outline),
                          const SizedBox(width: 8),
                          Text(l10n.generate100DummyTransactions),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: Stack(
            key: const ValueKey('tx-body-stack'),
            children: [
              hasSchedules
                  ? TabBarView(
                      key: const ValueKey('tx-tab-view'),
                      controller: _tabController,
                      children: [
                        _buildBody(paginatedState, theme),
                        _buildSchedulesTab(schedulesAsync.value ?? []),
                      ],
                    )
                  : _buildBody(paginatedState, theme),
              Positioned.fill(
                child: TransactionSpeedDial(
                  key: const ValueKey('tx-speed-dial'),
                  activeColor: AppColors.transactionsSectionColor,
                  onAddTransaction: () {
                    final filters = ref.read(transactionsPaginatedProvider.notifier).currentFilters;
                    String? initialType = filters.type;
                    String? initialCategoryUuid;
                    if (filters.categoryUuids != null && filters.categoryUuids!.length == 1) {
                      initialCategoryUuid = filters.categoryUuids!.first;
                    }
                    String? initialContactUuid;
                    if (filters.contactUuids != null && filters.contactUuids!.length == 1) {
                      initialContactUuid = filters.contactUuids!.first;
                    }
                    String? initialAccountUuid;
                    if (filters.accountUuids != null && filters.accountUuids!.length == 1) {
                      initialAccountUuid = filters.accountUuids!.first;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTransactionScreen(
                          initialType: initialType,
                          initialCategoryUuid: initialCategoryUuid,
                          initialContactUuid: initialContactUuid,
                          initialAccountUuid: initialAccountUuid,
                        ),
                      ),
                    );
                  },
                  onVoiceAdd: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VoiceAddScreen(),
                      ),
                    );
                  },
                  onScanReceipt: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScanReceiptScreen(),
                      ),
                    );
                  },
                  onBulkImport: () => _showImportOptions(context),
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildRecentSearchesList(List<RecentSearch> recentSearches, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    if (recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.search,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.searchTransactions,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final categories = ref.watch(categoriesListProvider).value ?? [];
    final contacts = ref.watch(contactsListProvider).value ?? [];
    final accounts = ref.watch(accountsStreamProvider).value ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentSearches,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(recentSearchesProvider.notifier).clearHistory();
                Navigator.pop(context);
              },
              child: Text(
                l10n.clearAll,
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentSearches.map((search) {
          Widget leadingWidget = const Icon(Icons.history);

          // 1. If category filter is active, show category icon
          if (search.categoryUuids != null && search.categoryUuids!.isNotEmpty) {
            final firstCatUuid = search.categoryUuids!.first;
            final category = categories.firstWhereOrNull((c) => c.uuid == firstCatUuid);
            if (category != null) {
              Color categoryColor;
              try {
                categoryColor = Color(int.parse(category.color!.replaceAll('#', '0xFF')));
              } catch (_) {
                categoryColor = theme.colorScheme.primary;
              }
              leadingWidget = Container(
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
          }
          // 2. Else if contact filter is active, show contact initials avatar
          else if (search.contactUuids != null && search.contactUuids!.isNotEmpty) {
            final firstContactUuid = search.contactUuids!.first;
            final contact = contacts.firstWhereOrNull((c) => c.uuid == firstContactUuid);
            if (contact != null) {
              leadingWidget = Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.getContactGradient(contact.name),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  contact.name.trim().isNotEmpty ? contact.name.trim().substring(0, 1).toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
          }
          // 3. Else if status code is active, show status-specific icon
          else if (search.statusCodes != null && search.statusCodes!.isNotEmpty) {
            final firstStatus = search.statusCodes!.first;
            IconData statusIcon = Icons.info_outline;
            Color statusColor = theme.colorScheme.primary;

            if (firstStatus == 'PAID' || firstStatus == 'RECEIVED' || firstStatus == 'PROCESSED') {
              statusIcon = Icons.check_circle_outline;
              statusColor = Colors.green;
            } else if (firstStatus == 'PAYABLE') {
              statusIcon = Icons.payment_outlined;
              statusColor = AppColors.payableColor;
            } else if (firstStatus == 'RECEIVABLE') {
              statusIcon = Icons.account_balance_wallet_outlined;
              statusColor = AppColors.receivableColor;
            } else if (firstStatus == 'SCHEDULED') {
              statusIcon = Icons.schedule_outlined;
              statusColor = Colors.orange;
            }

            leadingWidget = Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 20,
              ),
            );
          }
          // 4. Else if type filter is active, show transaction type icon
          else if (search.type != null) {
            final isExpense = search.type == 'EXPENSE';
            final typeColor = isExpense ? AppColors.expenseColor : AppColors.incomeColor;
            leadingWidget = Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                color: typeColor,
                size: 20,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SwipeableListItem(
              key: ValueKey('search-swipe-${search.id}'),
              enableEdit: true,
              enableDelete: true,
              borderRadius: 12,
              onEdit: () => _showRenameDialog(search),
              onDelete: () {
                ref.read(recentSearchesProvider.notifier).deleteSearch(search.id);
              },
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
                ),
                child: ListTile(
                  leading: leadingWidget,
                  title: Text(
                    search.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: _buildSearchTags(search, theme, categories, contacts, accounts),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          search.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          size: 20,
                          color: search.isPinned ? theme.colorScheme.primary : null,
                        ),
                        onPressed: () {
                          ref.read(recentSearchesProvider.notifier).togglePinSearch(search.id);
                        },
                        tooltip: search.isPinned ? 'Unpin search' : 'Pin search',
                      ),
                      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) ...[
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _showRenameDialog(search),
                          tooltip: l10n.renameSearch,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () {
                            ref.read(recentSearchesProvider.notifier).deleteSearch(search.id);
                          },
                          tooltip: l10n.delete,
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    _applyRecentSearch(search);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSearchTags(RecentSearch search, ThemeData theme, List<Category> categories, List<Contact> contacts, List<Account> accounts) {
    final tags = <Widget>[];

    // 1. Text query tag
    if (search.searchQuery.trim().isNotEmpty) {
      tags.add(_buildTagChip('"${search.searchQuery.trim()}"', Icons.search, theme));
    }

    // 2. Transaction Type tag
    if (search.type != null) {
      final isExpense = search.type == 'EXPENSE';
      tags.add(_buildTagChip(
        isExpense ? 'Expense' : 'Income',
        isExpense ? Icons.arrow_downward : Icons.arrow_upward,
        theme,
        color: isExpense ? AppColors.expenseColor : AppColors.incomeColor,
      ));
    }

    // 3. Account tags (Limit to 1)
    if (search.accountUuids != null && search.accountUuids!.isNotEmpty) {
      final accountList = search.accountUuids!
          .map((uuid) => accounts.firstWhereOrNull((a) => a.uuid == uuid))
          .whereNotNull()
          .toList();
      
      for (var i = 0; i < accountList.length && i < 1; i++) {
        tags.add(_buildTagChip(accountList[i].name, Icons.account_balance_wallet_outlined, theme));
      }
      if (accountList.length > 1) {
        tags.add(_buildTagChip('+${accountList.length - 1} more', Icons.add, theme));
      }
    }

    // 4. Category tags (Limit to 1)
    if (search.categoryUuids != null && search.categoryUuids!.isNotEmpty) {
      final catList = search.categoryUuids!
          .map((uuid) => categories.firstWhereOrNull((c) => c.uuid == uuid))
          .whereNotNull()
          .toList();
      
      for (var i = 0; i < catList.length && i < 1; i++) {
        final cat = catList[i];
        Color categoryColor;
        if (cat.color != null) {
          try {
            categoryColor = Color(int.parse(cat.color!.replaceAll('#', '0xFF')));
          } catch (_) {
            categoryColor = theme.colorScheme.primary;
          }
        } else {
          categoryColor = theme.colorScheme.primary;
        }
        tags.add(_buildTagChip(
          LocalizationHelper.getLocalizedCategoryName(context, cat.name),
          IconHelper.getIconData(cat.icon) ?? Icons.category,
          theme,
          color: categoryColor,
        ));
      }
      if (catList.length > 1) {
        tags.add(_buildTagChip('+${catList.length - 1} more', Icons.add, theme));
      }
    }

    // 5. Contact tags (Limit to 1)
    if (search.contactUuids != null && search.contactUuids!.isNotEmpty) {
      final contactList = search.contactUuids!
          .map((uuid) => contacts.firstWhereOrNull((c) => c.uuid == uuid))
          .whereNotNull()
          .toList();
      
      for (var i = 0; i < contactList.length && i < 1; i++) {
        tags.add(_buildTagChip(contactList[i].name, Icons.person_outline, theme));
      }
      if (contactList.length > 1) {
        tags.add(_buildTagChip('+${contactList.length - 1} more', Icons.add, theme));
      }
    }

    // 6. Amount range tag
    if (search.minAmount != null || search.maxAmount != null) {
      String amountLabel = '';
      if (search.minAmount != null && search.maxAmount != null) {
        amountLabel = '${search.minAmount} - ${search.maxAmount}';
      } else if (search.minAmount != null) {
        amountLabel = '>= ${search.minAmount}';
      } else if (search.maxAmount != null) {
        amountLabel = '<= ${search.maxAmount}';
      }
      tags.add(_buildTagChip(amountLabel, Icons.payments_outlined, theme));
    }

    // 7. Status tags (Limit to 1)
    if (search.statusCodes != null && search.statusCodes!.isNotEmpty) {
      final status = search.statusCodes!.first;
      String statusLabel = status;
      IconData statusIcon = Icons.info_outline;
      Color statusColor = theme.colorScheme.primary;

      if (status == 'PAID' || status == 'RECEIVED' || status == 'PROCESSED') {
        statusLabel = 'Cleared';
        statusIcon = Icons.check_circle_outline;
        statusColor = Colors.green;
      } else if (status == 'PAYABLE') {
        statusLabel = 'Payable';
        statusIcon = Icons.payment_outlined;
        statusColor = AppColors.payableColor;
      } else if (status == 'RECEIVABLE') {
        statusLabel = 'Receivable';
        statusIcon = Icons.account_balance_wallet_outlined;
        statusColor = AppColors.receivableColor;
      } else if (status == 'SCHEDULED') {
        statusLabel = 'Scheduled';
        statusIcon = Icons.schedule_outlined;
        statusColor = Colors.orange;
      }

      tags.add(_buildTagChip(statusLabel, statusIcon, theme, color: statusColor));
      if (search.statusCodes!.length > 1) {
        tags.add(_buildTagChip('+${search.statusCodes!.length - 1} more', Icons.add, theme));
      }
    }

    if (tags.isEmpty) return const SizedBox.shrink();

    // Limit to maximum of 5 tags total
    final displayTags = tags.length > 5 ? tags.sublist(0, 5) : tags;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: displayTags,
      ),
    );
  }

  Widget _buildTagChip(String label, IconData icon, ThemeData theme, {Color? color}) {
    final chipColor = color ?? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: chipColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _applyRecentSearch(RecentSearch search) {
    final currentFilters = ref.read(transactionsPaginatedProvider.notifier).currentFilters;
    final searchFilters = TransactionFilters(
      startDate: currentFilters.startDate, // Keep current period's dates!
      endDate: currentFilters.endDate,
      type: search.type,
      categoryUuids: search.categoryUuids,
      contactUuids: search.contactUuids,
      accountUuids: search.accountUuids,
      minAmount: search.minAmount,
      maxAmount: search.maxAmount,
      statusCodes: search.statusCodes,
    );

    _searchController.text = search.searchQuery;
    setState(() {
      _isSearching = true;
    });
    ref.read(transactionsPaginatedProvider.notifier).search(search.searchQuery);
    ref.read(transactionsPaginatedProvider.notifier).applyFilters(searchFilters);
    
    // Also move this search to the top of recent searches
    ref.read(recentSearchesProvider.notifier).saveSearch(
      searchQuery: search.searchQuery,
      filters: searchFilters,
    );
  }

  void _showRenameDialog(RecentSearch search) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: search.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.renameSearch),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.enterNewName,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref.read(recentSearchesProvider.notifier).renameSearch(search.id, controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.rename),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
      PaginatedState<TransactionWithDetails> paginatedState, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    if (paginatedState.isLoading && paginatedState.items.isEmpty) {
      return const AppLoadingIndicator(key: ValueKey('tx-loading-indicator'), size: 60);
    }

    if (paginatedState.error != null && paginatedState.items.isEmpty) {
      return Center(
        key: const ValueKey('tx-error-view'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingTransactions,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              paginatedState.error!,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(transactionsPaginatedProvider.notifier).refresh();
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (paginatedState.items.isEmpty) {
      return Center(
        key: const ValueKey('tx-empty-view'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSearching ? Icons.search_off : Icons.receipt_long_outlined,
              size: 120,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              _isSearching ? l10n.noTransactions : l10n.noTransactionsYet,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isSearching
                  ? l10n.trySearchingDifferentName
                  : l10n.tapToAddFirst,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Group transactions by date and calculate daily stats
    final groupedTransactions = <String, List<TransactionWithDetails>>{};
    final dailyStats = <String, ({int count, double netAmount})>{};
    final userProfile = ref.watch(userProfileProvider);

    for (final item in paginatedState.items) {
      if (item == null ||
          item.transaction == null ||
          item.transaction.date == null) continue;

      try {
        final dateKey = AppDateFormatter.formatDate(item.transaction.date,
            pattern: userProfile.dateFormat);

        // Grouping
        groupedTransactions.putIfAbsent(dateKey, () => []);
        groupedTransactions[dateKey]!.add(item);

        // Stats calculation
        final current = dailyStats[dateKey] ?? (count: 0, netAmount: 0.0);
        final isExpense = item.transaction.type == 'EXPENSE';
        dailyStats[dateKey] = (
          count: current.count + 1,
          netAmount: current.netAmount +
              (isExpense ? -item.transaction.amount : item.transaction.amount),
        );
      } catch (e) {
        const fallbackKey = 'Other';
        groupedTransactions.putIfAbsent(fallbackKey, () => []);
        groupedTransactions[fallbackKey]!.add(item);

        final current = dailyStats[fallbackKey] ?? (count: 0, netAmount: 0.0);
        final isExpense = item.transaction.type == 'EXPENSE';
        dailyStats[fallbackKey] = (
          count: current.count + 1,
          netAmount: current.netAmount +
              (isExpense ? -item.transaction.amount : item.transaction.amount),
        );
      }
    }

    final service = ref.read(transactionServiceProvider);
    final keys = groupedTransactions.keys.toList();

    return CustomScrollView(
      key: const ValueKey('tx-list-scrollview'),
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          key: const ValueKey('tx-list-summary-adapter'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: CollapsibleListSummary(
              key: const ValueKey('tx-list-summary-collapsible'),
              title: l10n.financialSummary,
              child: _TransactionListSummaryContent(
                  key: const ValueKey('tx-list-summary-content-inner')),
            ),
          ),
        ),
        // Date sections with sticky headers
        for (int i = 0; i < keys.length; i++)
          SliverStickyHeader(
            key: ValueKey('tx-sticky-header-${keys[i]}'),
            header: _buildDateHeader(
              theme,
              keys[i],
              _monthForDateGroup(groupedTransactions[keys[i]]!),
              count: dailyStats[keys[i]]?.count ?? 0,
              netAmount: dailyStats[keys[i]]?.netAmount ?? 0.0,
              isConfirmed: i < keys.length - 1 || !paginatedState.hasMore,
            ),
            sliver: SliverList(
              key: ValueKey('tx-sliver-list-${keys[i]}'),
              delegate: SliverChildBuilderDelegate(
                (context, itemIndex) {
                  final dateKey = keys[i];
                  final dateTransactions = groupedTransactions[dateKey]!;
                  if (itemIndex >= dateTransactions.length) return null;

                  final item = dateTransactions[itemIndex];
                  final isExpense = item.transaction.type == 'EXPENSE';

                  // Determine if transaction is restricted from editing/deleting
                  final isRestricted =
                      item.transaction.isAutoGenerated == true ||
                          item.isLinkedEntryMarked;

                  final onEditAction = isRestricted
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTransactionScreen(
                                transaction: item.transaction,
                                category: item.category,
                                contact: item.contact,
                                account: item.account,
                              ),
                            ),
                          );
                        };

                  final onDeleteAction = isRestricted
                      ? null
                      : () async {
                          final l10n = AppLocalizations.of(context)!;
                          
                          // Show confirmation dialog before deleting
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(l10n.deleteTransactionTitle),
                              content: Text(l10n.deleteTransactionMessage),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                  child: Text(l10n.cancel),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.expenseColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(l10n.delete),
                                ),
                              ],
                            ),
                          );

                          if (confirmed != true) return;

                          try {
                            await service
                                .deleteTransaction(item.transaction.uuid);
                            if (context.mounted) {
                              ToastUtils.showSuccessToast(
                                  context, ref, l10n.transactionDeleted);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ToastUtils.showErrorToast(
                                  context,
                                  ref,
                                  l10n.errorDeletingTransaction(
                                      e.toString()));
                            }
                          }
                        };

                  return Padding(
                    key: ValueKey('tx-row-${item.transaction.uuid}'),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: SwipeableListItem(
                      key: ValueKey('tx-swipe-${item.transaction.uuid}'),
                      enableEdit: !isRestricted,
                      enableDelete: !isRestricted,
                      borderRadius: 20,
                      onEdit: onEditAction,
                      onDelete: onDeleteAction,
                      showHoverActions: false,
                      child: _buildTransactionCard(
                        context,
                        ref,
                        item,
                        onEdit: onEditAction,
                        onDelete: onDeleteAction,
                      ),
                    ),
                  );
                },
                childCount: groupedTransactions[keys[i]]!.length,
              ),
            ),
          ),
        // Loading indicator or "No more items"
        if (paginatedState.isLoadingMore)
          SliverToBoxAdapter(
            key: const ValueKey('tx-loading-more-adapter'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          )
        else if (!paginatedState.hasMore && paginatedState.items.isNotEmpty)
          SliverToBoxAdapter(
            key: const ValueKey('tx-no-more-adapter'),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  l10n.noMoreTransactions,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          key: const ValueKey('tx-bottom-logo-adapter'),
          child: FadedBottomLogo(
            key: const ValueKey('tx-bottom-logo'),
            bottomPadding: 100 + MediaQuery.of(context).padding.bottom,
          ),
        ),
      ],
    );
  }

  /// Calendar month for the group (from first row) to tint the date chip.
  int? _monthForDateGroup(List<dynamic> items) {
    if (items.isEmpty) return null;
    final tx = items.first.transaction;
    if (tx == null || tx.date == null) return null;
    return tx.date.month;
  }

  Widget _buildDateHeader(
    ThemeData theme,
    String dateKey,
    int? month, {
    required int count,
    required double netAmount,
    required bool isConfirmed,
  }) {
    final chipBg = AppColors.transactionDateChipBackground(theme, month);
    final chipFg = AppColors.transactionDateChipForeground(theme, month);
    final chipShadow = AppColors.transactionDateChipShadow(theme, month);
    final currency = ref.watch(currentCurrencyProvider).value;

    return Container(
      key: ValueKey('tx-date-header-$dateKey'),
      height: 50,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Container(
        key: ValueKey('tx-date-header-inner-$dateKey'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: chipShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              key: ValueKey('tx-date-header-text-$dateKey'),
              dateKey,
              style: theme.textTheme.titleSmall?.copyWith(
                color: chipFg,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 12,
                color: chipFg.withValues(alpha: 0.2),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: isConfirmed ? 1.0 : 0.6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AmountFormatter.formatWithCurrency(
                        netAmount,
                        currency!,
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: netAmount >= 0
                            ? AppColors.incomeColor
                            : AppColors.expenseColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '|',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: chipFg.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$count',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: chipFg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, WidgetRef ref, TransactionWithDetails item, {VoidCallback? onEdit, VoidCallback? onDelete}) {
    return TransactionListItem(
      item: item,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }

  Widget _buildSchedulesTab(List<ScheduleWithDetails> schedules) {
    final l10n = AppLocalizations.of(context)!;
    if (schedules.isEmpty) {
      return Center(
        key: const ValueKey('tx-schedules-empty'),
        child: Text(l10n.noSchedulesFound),
      );
    }

    return ListView.builder(
      key: const ValueKey('tx-schedules-list'),
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: schedules.length + 1,
      itemBuilder: (context, index) {
        if (index == schedules.length) {
          return const FadedBottomLogo(key: ValueKey('tx-schedules-bottom-logo'), bottomPadding: 40);
        }
        final item = schedules[index];
        final schedule = item.schedule;
        final isPremium = ref.watch(premiumProvider).isPremium;
        final isLocked = !isPremium &&
            (schedule.addSeq ?? 0) > PremiumGate.scheduleTotalLimit;

        return Padding(
          key: ValueKey('tx-schedule-row-${schedule.uuid}'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SwipeableListItem(
            key: ValueKey('tx-schedule-swipe-${schedule.uuid}'),
            enableEdit: !isLocked,
            enableDelete: !isLocked,
            borderRadius: 20,
            onEdit: isLocked
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditScheduleScreen(
                          schedule: schedule,
                        ),
                      ),
                    );
                  },
            onDelete: isLocked
                ? null
                : () async {
                    final service = ref.read(scheduleServiceProvider);
                    await service.deleteSchedule(schedule.uuid);
                    if (context.mounted) {
                      ToastUtils.showSuccessToast(
                          context, ref, l10n.scheduleDeleted);
                    }
                  },
            child: Stack(
              key: ValueKey('tx-schedule-stack-${schedule.uuid}'),
              children: [
                Opacity(
                  key: ValueKey('tx-schedule-opacity-${schedule.uuid}'),
                  opacity: isLocked ? 0.5 : 1.0,
                  child: ScheduleListItem(
                    key: ValueKey('tx-schedule-item-${schedule.uuid}'),
                    item: item,
                  ),
                ),
                if (isLocked)
                  Positioned(
                    key: ValueKey('tx-schedule-lock-pos-${schedule.uuid}'),
                    top: 12,
                    right: 12,
                    child: Container(
                      key: ValueKey('tx-schedule-lock-container-${schedule.uuid}'),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        key: ValueKey('tx-schedule-lock-icon'),
                        Icons.lock,
                        size: 16,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TransactionListSummaryContent extends ConsumerWidget {
  const _TransactionListSummaryContent({super.key});

  static Widget _buildBalanceRow({
    Key? key,
    required ThemeData theme,
    required AppCurrency currency,
    required bool isReceivableHigher,
    required double amount,
    required String labelWhenHigher,
    required String labelWhenLower,
    required LinearGradient gradientWhenHigher,
    required LinearGradient gradientWhenLower,
  }) {
    final isHigher = isReceivableHigher;
    final label = isHigher ? labelWhenHigher : labelWhenLower;
    final gradient = isHigher ? gradientWhenHigher : gradientWhenLower;

    final transparentGradient = LinearGradient(
      colors: gradient.colors.map((c) => c.withValues(alpha: .8)).toList(),
      begin: gradient.begin,
      end: gradient.end,
      stops: gradient.stops,
    );

    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: transparentGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gradient.colors.first.withValues(alpha: 9),
          width: .5,
        ),
      ),
      child: Row(
        key: key != null ? ValueKey('${(key as ValueKey).value}-row') : null,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key: key != null ? ValueKey('${(key as ValueKey).value}-label') : null,
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            key: key != null ? ValueKey('${(key as ValueKey).value}-amount') : null,
            AmountFormatter.formatWithCurrency(
                amount, currency),
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(transactionListSummaryProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currency = ref.watch(currentCurrencyProvider).value;
    final filters = ref.watch(transactionsPaginatedProvider.select((s) => s.filters));
    final isAccountFilterActive = filters?.accountUuids != null && filters!.accountUuids!.isNotEmpty;

    if (currency == null) return const SizedBox.shrink();

    return summaryAsync.when(
      skipLoadingOnRefresh: true,
      data: (s) => Column(
        key: const ValueKey('tx-list-summary-content-column'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isAccountFilterActive) ...[
            Row(
              key: const ValueKey('tx-list-summary-row-1'),
              children: [
                Expanded(
                  child: _SummaryTile(
                    key: const ValueKey('tx-summary-payable'),
                    label: l10n.payableTag,
                    amount: s.totalPayable,
                    color: AppColors.payableColor,
                    currency: currency,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryTile(
                    key: const ValueKey('tx-summary-receivable'),
                    label: l10n.receivableTag,
                    amount: s.totalReceivable,
                    color: AppColors.receivableColor,
                    currency: currency,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            key: const ValueKey('tx-list-summary-row-2'),
            children: [
              Expanded(
                child: _SummaryTile(
                  key: const ValueKey('tx-summary-expense'),
                  label: l10n.expenses,
                  amount: s.totalExpense,
                  color: AppColors.expenseColor,
                  currency: currency,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryTile(
                  key: const ValueKey('tx-summary-income'),
                  label: l10n.income,
                  amount: s.totalIncome,
                  color: AppColors.incomeColor,
                  currency: currency,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!isAccountFilterActive) ...[
            _buildBalanceRow(
              key: const ValueKey('tx-summary-net-receivable-payable'),
              theme: theme,
              currency: currency,
              isReceivableHigher: s.totalReceivable >= s.totalPayable,
              amount: (s.totalReceivable - s.totalPayable).abs(),
              labelWhenHigher: l10n.netReceivable,
              labelWhenLower: l10n.netPayable,
              gradientWhenHigher: AppColors.receivableGradient,
              gradientWhenLower: AppColors.payableGradient,
            ),
            const SizedBox(height: 8),
          ],
          _buildBalanceRow(
            key: const ValueKey('tx-summary-net-income-expense'),
            theme: theme,
            currency: currency,
            isReceivableHigher: s.totalIncome >= s.totalExpense,
            amount: (s.totalIncome - s.totalExpense).abs(),
            labelWhenHigher: l10n.netIncome,
            labelWhenLower: l10n.netExpenses,
            gradientWhenHigher: AppColors.incomeGradient,
            gradientWhenLower: AppColors.expenseGradient,
          ),
        ],
      ),
      loading: () => SizedBox(
        key: const ValueKey('tx-list-summary-loading'),
        height: 4,
        child: LinearProgressIndicator(
          minHeight: 4,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Lightweight dim + floating panel (avoids default dark [Colors.black54] dialog barrier).
class _BulkImportLoadingDialog extends StatelessWidget {
  const _BulkImportLoadingDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Material(
          elevation: 6,
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.18),
          surfaceTintColor: theme.colorScheme.surfaceTint,
          borderRadius: BorderRadius.circular(20),
          color: theme.colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppLoadingIndicator(
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.bulkImportLoadingContent,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final AppCurrency currency;

  const _SummaryTile({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        key: ValueKey('summary-tile-col-$label'),
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            key: ValueKey('summary-tile-label-$label'),
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            key: ValueKey('summary-tile-amount-$label'),
            AmountFormatter.formatWithCurrency(
                amount, currency),
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
