import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flowpaisa/core/utils/native_share.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/features/analytics/data/analytics_repository.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';

class ExportService {
  final TransactionsRepository _transactionsRepository;
  final AppDatabase _database;
  final String _dateFormat;
  static pw.Font? _cachedFont;
  static pw.Font? _unicodeFont;
  final _reshaper = ArabicReshaper();

  ExportService(this._transactionsRepository, this._database,
      {String? dateFormat})
      : _dateFormat = dateFormat ?? AppDateFormatter.defaultPattern;

  // Helper to translate category names
  String _getLocalizedCategoryName(String? name, AppLocalizations? l10n) {
    if (name == null || l10n == null) return name ?? '-';

    switch (name.toLowerCase()) {
      case 'food':
        return l10n.categoryFood;
      case 'transport':
        return l10n.categoryTransport;
      case 'shopping':
        return l10n.categoryShopping;
      case 'bills':
        return l10n.categoryBills;
      case 'entertainment':
        return l10n.categoryEntertainment;
      case 'health':
        return l10n.categoryHealth;
      case 'salary':
        return l10n.categorySalary;
      case 'business':
        return l10n.categoryBusiness;
      case 'investment':
        return l10n.categoryInvestment;
      case 'rent':
        return l10n.categoryRent;
      case 'education':
        return l10n.categoryEducation;
      case 'gift':
        return l10n.categoryGift;
      case 'other':
        return l10n.categoryOther;
      default:
        return name;
    }
  }

  // Helper to translate transaction type abbreviations
  String _getLocalizedTypeShort(String type, AppLocalizations? l10n) {
    if (l10n == null) return type;
    if (type == 'I') return l10n.incomeShort.replaceAll(':', '').trim();
    if (type == 'E') return l10n.expenseShort.replaceAll(':', '').trim();
    if (type == 'P') return l10n.payableTag;
    if (type == 'R') return l10n.receivableTag;
    return type;
  }

  // Helper to translate statuses
  String _getLocalizedStatus(String status, AppLocalizations? l10n) {
    if (l10n == null) return status;
    switch (status.toUpperCase()) {
      case 'PENDING':
        return l10n.statusPending;
      case 'COMPLETED':
        return l10n.statusCompleted;
      case 'CANCELLED':
        return l10n.statusCancelled;
      case 'PAID':
        return l10n.statusPaid;
      case 'RECEIVED':
        return l10n.statusReceived;
      case 'SETTLED':
        return l10n.statusSettled;
      case 'OVERDUE':
        return l10n.statusOverdue;
      default:
        return status;
    }
  }

  // Helper to translate months
  String _getLocalizedMonth(DateTime date, AppLocalizations? l10n) {
    if (l10n == null) return DateFormat('MMM yyyy').format(date);
    // Use the built-in DateFormat which respects the current locale
    return DateFormat.yMMM(l10n.localeName).format(date);
  }

  // Get AnalyticsRepository instance
  AnalyticsRepository get _analyticsRepository =>
      AnalyticsRepository(_database);

  // Load Material Icons font for PDF generation
  // Using PdfGoogleFonts.materialIcons() to get the exact font Google expects for Material Icons codePoints
  Future<pw.Font?> loadMaterialIconsFont() async {
    if (_cachedFont != null) return _cachedFont;
    try {
      final data =
          await rootBundle.load('assets/fonts/MaterialSymbolsOutlined.ttf');
      _cachedFont = pw.Font.ttf(data);
      // _cachedFont = await PdfGoogleFonts.materialIcons();
      return _cachedFont;
    } catch (e) {
      // Return null if font file is not found
      // This allows graceful fallback to colored circles
      return null;
    }
  }

  // Load Unicode font for Hindi and Urdu support
  Future<pw.Font?> loadUnicodeFont() async {
    try {
      _unicodeFont = await PdfGoogleFonts.amiriRegular();
      return _unicodeFont;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading Arabic font: $e');
      }
      return null;
    }
  }

  // Load Hindi font for PDF generation
  static pw.Font? _hindiFont;
  Future<pw.Font?> loadHindiFont() async {
    if (_hindiFont != null) return _hindiFont;
    try {
      _hindiFont = await PdfGoogleFonts.notoSansDevanagariRegular();
      return _hindiFont;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading Hindi font: $e');
      }
      return null;
    }
  }

  // Load English font for PDF generation
  static pw.Font? _englishFont;
  Future<pw.Font?> loadEnglishFont() async {
    if (_englishFont != null) return _englishFont;
    try {
      _englishFont = await PdfGoogleFonts.montserratRegular();
      return _englishFont;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading English font: $e');
      }
      return null;
    }
  }

  // Generate CSV content
  Future<String> generateCSVContent({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get transactions in date range with details
      final transactionsWithDetails = await _transactionsRepository
          .getTransactionsWithDetailsByDateRange(startDate, endDate);

      // Create CSV data
      List<List<dynamic>> csvData = [
        // Header row
        ['Date', 'Type', 'Amount', 'Category', 'Contact', 'Description'],
      ];

      // Add transaction rows
      for (var item in transactionsWithDetails) {
        final t = item.transaction;

        // Filter out inactive transactions (unsettled linked entries)
        bool include = true;

        // Exclude "Paid By" expenses (linked Payable) that are 'PENDING'
        if (t.type == 'EXPENSE' && t.linkedPayableUuid != null) {
          if (item.linkedPayable?.status != 'PAID') {
            include = false;
          }
        }

        // Exclude "Will Receive" incomes (linked Receivable) that are 'PENDING'
        if (t.type == 'INCOME' && t.linkedReceivableUuid != null) {
          if (item.linkedReceivable?.status != 'RECEIVED') {
            include = false;
          }
        }

        if (!include) {
          continue;
        }
        csvData.add([
          AppDateFormatter.formatDate(t.date, pattern: _dateFormat),
          t.type,
          t.amount.toStringAsFixed(2),
          item.category?.name ?? '', // Use name instead of ID
          item.contact?.name ?? '', // Use name instead of ID
          t.description ?? '',
        ]);
      }

      // Convert to CSV string
      return const ListToCsvConverter().convert(csvData);
    } catch (e) {
      throw Exception('Error generating CSV: $e');
    }
  }

  // Export transactions to CSV
  Future<String> exportTransactionsToCSV({
    required DateTime startDate,
    required DateTime endDate,
    bool useCache = false,
  }) async {
    try {
      final csvString = await generateCSVContent(
        startDate: startDate,
        endDate: endDate,
      );

      // Save to file
      final directory = await (useCache
          ? getTemporaryDirectory()
          : getApplicationDocumentsDirectory());
      final fileName =
          'flowpaisa_export_${AppDateFormatter.formatForFileName(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');

      // Use UTF-8 with BOM for Excel compatibility with Unicode characters
      final List<int> bytes = [0xEF, 0xBB, 0xBF] + utf8.encode(csvString);
      await file.writeAsBytes(bytes);

      return file.path;
    } catch (e) {
      throw Exception('Error exporting to CSV: $e');
    }
  }

  // Save copy to Downloads
  Future<void> saveToDownloads(String sourceFilePath) async {
    try {
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file not found');
      }

      // Handle Android scoped storage
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        // Fallback if that path doesn't exist (unlikely on standard Android)
        if (!await downloadsDir.exists()) {
          downloadsDir = await getDownloadsDirectory();
        }
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null) {
        throw Exception('Downloads directory not available');
      }

      // Ensure directory exists
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = sourceFilePath.split(Platform.pathSeparator).last;
      String newPath = '${downloadsDir.path}/$fileName';

      // Handle duplicates - detect file extension
      final fileExtension = fileName.contains('.')
          ? fileName.substring(fileName.lastIndexOf('.'))
          : '';
      final nameWithoutExtension = fileExtension.isNotEmpty
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;

      int counter = 1;
      while (await File(newPath).exists()) {
        newPath =
            '${downloadsDir.path}/${nameWithoutExtension}_$counter$fileExtension';
        counter++;
      }

      await sourceFile.copy(newPath);
    } catch (e) {
      throw Exception('Error saving to downloads: $e');
    }
  }

  // Share CSV file
  Future<void> shareCSVFile(String filePath) async {
    try {
      // Verify file exists
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist at path: $filePath');
      }

      // Use native Android sharing with MediaStore (Android 10+) or FileProvider (older)
      // MediaStore will insert file into Downloads and create a content:// URI
      // FileProvider will create a content:// URI for the file in cache
      if (Platform.isAndroid) {
        final success = await NativeShare.shareFile(filePath);
        if (!success) {
          throw Exception('Native share failed');
        }
      } else {
        // Fallback to share_plus for other platforms
        final xFile = XFile(filePath,
            mimeType: 'text/csv',
            name: filePath.split(Platform.pathSeparator).last);

        final result = await SharePlus.instance.share(ShareParams(
          files: [xFile],
        ));

        if (result.status == ShareResultStatus.dismissed ||
            result.status == ShareResultStatus.unavailable) {
          // Handle or ignore
        }
      }
    } catch (e) {
      throw Exception('Error sharing file: $e');
    }
  }

  // Generate export summary
  Future<ExportSummary> getExportSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions = await _transactionsRepository
        .getTransactionsByDateRange(startDate, endDate);

    double totalIncome = 0;
    double totalExpense = 0;
    int incomeCount = 0;
    int expenseCount = 0;

    for (var transaction in transactions) {
      if (transaction.type == 'INCOME') {
        totalIncome += transaction.amount;
        incomeCount++;
      } else {
        totalExpense += transaction.amount;
        expenseCount++;
      }
    }

    return ExportSummary(
      startDate: startDate,
      endDate: endDate,
      totalTransactions: transactions.length,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      incomeCount: incomeCount,
      expenseCount: expenseCount,
      netBalance: totalIncome - totalExpense,
    );
  }

  // Helper functions to get app colors as PdfColor (class methods for reuse)
  static PdfColor getIncomePdfColor() {
    return PdfColor(
        0x06 / 255.0, 0x5F / 255.0, 0x46 / 255.0); // #065F46 (Darker Green)
  }

  static PdfColor getExpensePdfColor() {
    return PdfColor(
        0x99 / 255.0, 0x1B / 255.0, 0x1B / 255.0); // #991B1B (Darker Red)
  }

  static PdfColor getPayablePdfColor() {
    return PdfColor(0x92 / 255.0, 0x40 / 255.0,
        0x0E / 255.0); // #92400E (Darker Amber/Orange)
  }

  static PdfColor getReceivablePdfColor() {
    return PdfColor(
        0x15 / 255.0, 0x5E / 255.0, 0x75 / 255.0); // #155E75 (Darker Cyan/Blue)
  }

  // Generate PDF document
  Future<pw.Document> generatePDFDocument({
    required DateTime startDate,
    required DateTime endDate,
    String? currencySymbol,
    pw.Font? materialIconsFont,
    pw.Font? unicodeFont,
    pw.Font? hindiFont,
    pw.Font? englishFont,
    AppLocalizations? l10n,
  }) async {
    final payablesRepository = PayablesRepository(_database);
    final receivablesRepository = ReceivablesRepository(_database);

    // Fetch all data
    final transactionsWithDetails = await _transactionsRepository
        .getTransactionsWithDetailsByDateRange(startDate, endDate);
    final payablesWithContacts = await payablesRepository
        .getPayablesWithContactsByDateRange(startDate, endDate);
    final receivablesWithContacts = await receivablesRepository
        .getReceivablesWithContactsByDateRange(startDate, endDate);

    // Filter transactions (same logic as CSV export)
    final filteredTransactions = transactionsWithDetails.where((item) {
      final t = item.transaction;
      if (t.type == 'EXPENSE' && t.linkedPayableUuid != null) {
        if (item.linkedPayable?.status != 'PAID') {
          return false;
        }
      }
      if (t.type == 'INCOME' && t.linkedReceivableUuid != null) {
        if (item.linkedReceivable?.status != 'RECEIVED') {
          return false;
        }
      }
      return true;
    }).toList();

    // Calculate summaries
    double totalIncome = 0;
    double totalExpense = 0;
    double totalPayablePending = 0;
    double totalPayablePaid = 0;
    double totalReceivablePending = 0;
    double totalReceivableReceived = 0;

    for (var transaction in filteredTransactions) {
      if (transaction.transaction.type == 'INCOME') {
        totalIncome += transaction.transaction.amount;
      } else {
        totalExpense += transaction.transaction.amount;
      }
    }

    for (var payable in payablesWithContacts) {
      if (payable.payable.status == 'PAID') {
        totalPayablePaid += payable.payable.amount;
      } else {
        totalPayablePending += payable.payable.amount;
      }
    }

    for (var receivable in receivablesWithContacts) {
      if (receivable.receivable.status == 'RECEIVED') {
        totalReceivableReceived += receivable.receivable.amount;
      } else {
        totalReceivablePending += receivable.receivable.amount;
      }
    }

    final currency = currencySymbol ?? '₹';
    final dateFormat = AppDateFormatter.getFormatter(_dateFormat);
    final dateTimeFormat = AppDateFormatter.getFormatter('dd MMM yyyy, HH:mm');

    // Create PDF document
    final pdf = pw.Document();

    // Set default theme with Unicode font and fallbacks
    final theme = pw.ThemeData.withFont(
      base: englishFont ?? unicodeFont,
      bold: englishFont ?? unicodeFont,
      fontFallback: [
        if (unicodeFont != null) unicodeFont,
        if (hindiFont != null) hindiFont,
        if (englishFont != null) englishFont,
      ],
    );

    // Helper function to convert hex color to PdfColor
    PdfColor hexToPdfColor(String hex) {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) {
        final r = int.parse(hex.substring(0, 2), radix: 16) / 255.0;
        final g = int.parse(hex.substring(2, 4), radix: 16) / 255.0;
        final b = int.parse(hex.substring(4, 6), radix: 16) / 255.0;
        return PdfColor(r, g, b);
      }
      return PdfColors.black;
    }

    // Helper function to get contact color as PdfColor
    PdfColor getContactPdfColor(String name) {
      final color = AppColors.getContactColor(name);
      return PdfColor(color.r, color.g, color.b);
    }

    // Helper function to get initials
    String getInitials(String name) {
      if (name.isEmpty) return '?';
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }

    // Add pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: theme,
        build: (pw.Context context) {
          // Capture this reference for use in closure
          final self = this;

          final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);

          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: isRtl
                    ? pw.CrossAxisAlignment.end
                    : pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    alignment: isRtl
                        ? pw.Alignment.centerRight
                        : pw.Alignment.centerLeft,
                    child: _buildText(
                      l10n?.appTitle != null
                          ? '${l10n!.appTitle} ${l10n.exportSummary}'
                          : 'FlowPaisa Export Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor(
                            0 / 255.0, 100 / 255.0, 150 / 255.0), // Darker Cyan
                      ),
                      align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Table(
                    columnWidths: {
                      0: const pw.IntrinsicColumnWidth(),
                      1: const pw.FixedColumnWidth(5),
                      2: const pw.IntrinsicColumnWidth(),
                    },
                    children: [
                      _buildLocalizedTableRow(
                        [
                          _buildText(
                            l10n?.createdLabel('').split(':')[0] ??
                                'Generated on',
                            style: pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey700),
                            align:
                                isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                          ),
                          _buildText(':',
                              style: pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700)),
                          _buildText(
                            dateTimeFormat.format(DateTime.now()),
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                            align:
                                isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                          ),
                        ],
                        l10n: l10n,
                      ),
                      _buildLocalizedTableRow(
                        [
                          _buildText(
                            l10n?.dateRange ?? 'Date Range',
                            style: pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey700),
                            align:
                                isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                          ),
                          _buildText(':',
                              style: pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700)),
                          _buildText(
                            '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                            align:
                                isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                          ),
                        ],
                        l10n: l10n,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Overall Summary
            _buildLocalizedHeader(l10n?.summary ?? 'Summary',
                level: 1, l10n: l10n),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        l10n?.totalTransactions ?? 'Total Transactions',
                        filteredTransactions.length.toString(),
                        null,
                        l10n),
                    _buildTableCell(
                        l10n?.income ?? 'Total Income',
                        '$currency ${totalIncome.toStringAsFixed(2)}',
                        ExportService.getIncomePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        l10n?.expense ?? 'Total Expense',
                        '$currency ${totalExpense.toStringAsFixed(2)}',
                        ExportService.getExpensePdfColor(),
                        l10n),
                    _buildTableCell(
                        l10n?.netBalance ?? 'Net Balance',
                        '$currency ${(totalIncome - totalExpense).toStringAsFixed(2)}',
                        (totalIncome - totalExpense) == 0
                            ? PdfColors.black
                            : (totalIncome - totalExpense) >= 0
                                ? ExportService.getIncomePdfColor()
                                : ExportService.getExpensePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        '${l10n?.payables ?? 'Payables'} (${l10n?.pending ?? 'Pending'})',
                        '$currency ${totalPayablePending.toStringAsFixed(2)}',
                        ExportService.getPayablePdfColor(),
                        l10n),
                    _buildTableCell(
                        '${l10n?.payables ?? 'Payables'} (${l10n?.paid ?? 'Paid'})',
                        '$currency ${totalPayablePaid.toStringAsFixed(2)}',
                        ExportService.getPayablePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        '${l10n?.receivables ?? 'Receivables'} (${l10n?.pending ?? 'Pending'})',
                        '$currency ${totalReceivablePending.toStringAsFixed(2)}',
                        ExportService.getReceivablePdfColor(),
                        l10n),
                    _buildTableCell(
                        '${l10n?.receivables ?? 'Receivables'} (${l10n?.receivedLabel ?? 'Received'})',
                        '$currency ${totalReceivableReceived.toStringAsFixed(2)}',
                        ExportService.getReceivablePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                // Net Payable/Receivable row (only pending amounts)
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        totalPayablePending >= totalReceivablePending
                            ? '${l10n?.netBalance ?? 'Net'} ${l10n?.payable ?? 'Payable'} (${l10n?.pending ?? 'Pending'})'
                            : '${l10n?.netBalance ?? 'Net'} ${l10n?.receivable ?? 'Receivable'} (${l10n?.pending ?? 'Pending'})',
                        '$currency ${(totalPayablePending - totalReceivablePending).abs().toStringAsFixed(2)}',
                        (totalPayablePending - totalReceivablePending).abs() ==
                                0
                            ? PdfColors.black
                            : totalPayablePending >= totalReceivablePending
                                ? ExportService.getPayablePdfColor()
                                : ExportService.getReceivablePdfColor(),
                        l10n),
                    _buildTableCell('', null, null, l10n),
                  ],
                  l10n: l10n,
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Transactions Section
            _buildLocalizedHeader(l10n?.transactions ?? 'Transactions',
                level: 1, l10n: l10n),
            pw.SizedBox(height: 10),
            if (filteredTransactions.isEmpty)
              _buildText(
                  l10n?.noTransactionsInRange ??
                      'No transactions in this date range.',
                  style: pw.TextStyle(color: PdfColors.grey700),
                  align: isRtl ? pw.TextAlign.right : pw.TextAlign.left)
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  1: const pw.FixedColumnWidth(80),
                  2: const pw.FixedColumnWidth(100),
                  3: const pw.FlexColumnWidth(2),
                  4: const pw.FlexColumnWidth(2),
                  5: const pw.FlexColumnWidth(3),
                },
                children: [
                  _buildLocalizedTableRow(
                    [
                      _buildTableHeaderCell(l10n?.date ?? 'Date', l10n: l10n),
                      _buildTableHeaderCell(l10n?.type ?? 'Type', l10n: l10n),
                      _buildTableHeaderCell(l10n?.amount ?? 'Amount',
                          l10n: l10n),
                      _buildTableHeaderCell(l10n?.category ?? 'Category',
                          l10n: l10n),
                      _buildTableHeaderCell(l10n?.contact ?? 'Contact',
                          l10n: l10n),
                      _buildTableHeaderCell(l10n?.description ?? 'Description',
                          l10n: l10n),
                    ],
                    l10n: l10n,
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                  ),
                  ...filteredTransactions.map((item) {
                    final t = item.transaction;
                    final categoryColor = item.category?.color != null
                        ? hexToPdfColor(item.category!.color!)
                        : PdfColors.grey600;
                    final contactColor = item.contact != null
                        ? getContactPdfColor(item.contact!.name)
                        : PdfColors.grey600;
                    final amountColor = t.type == 'INCOME'
                        ? ExportService.getIncomePdfColor()
                        : ExportService.getExpensePdfColor();
                    return _buildLocalizedTableRow(
                      [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(dateFormat.format(t.date),
                                style: const pw.TextStyle(fontSize: 9),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                _getLocalizedTypeShort(t.type[0], l10n),
                                style: const pw.TextStyle(fontSize: 9),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                '$currency ${t.amount.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9, color: amountColor),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Row(
                              children: [
                                pw.SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: self._buildCategoryIcon(
                                    item.category?.icon,
                                    categoryColor,
                                    materialIconsFont,
                                    l10n: l10n,
                                  ),
                                ),
                                pw.SizedBox(width: 4),
                                pw.Expanded(
                                  child: _buildText(
                                    _getLocalizedCategoryName(
                                        item.category?.name, l10n),
                                    style: const pw.TextStyle(fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: item.contact != null
                                ? pw.Row(
                                    children: [
                                      pw.Container(
                                        width: 12,
                                        height: 12,
                                        decoration: pw.BoxDecoration(
                                          color: contactColor,
                                          shape: pw.BoxShape.circle,
                                        ),
                                        child: pw.Center(
                                          child: pw.Text(
                                            getInitials(item.contact!.name),
                                            style: pw.TextStyle(
                                                fontSize: 6,
                                                color: PdfColors.white),
                                          ),
                                        ),
                                      ),
                                      pw.SizedBox(width: 4),
                                      pw.Expanded(
                                        child: _buildText(
                                          item.contact!.name,
                                          style:
                                              const pw.TextStyle(fontSize: 9),
                                          align: isRtl
                                              ? pw.TextAlign.right
                                              : pw.TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  )
                                : _buildText('-',
                                    style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                              t.description ?? '-',
                              style: const pw.TextStyle(fontSize: 9),
                              align: isRtl
                                  ? pw.TextAlign.right
                                  : pw.TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                      l10n: l10n,
                    );
                  }),
                ],
              ),
            pw.SizedBox(height: 30),

            // Payables Section
            _buildLocalizedHeader(l10n?.payables ?? 'Payables',
                level: 1, l10n: l10n),
            pw.SizedBox(height: 10),
            if (payablesWithContacts.isEmpty)
              _buildText(
                  l10n?.noPayablesInRange ?? 'No payables in this date range.',
                  style: pw.TextStyle(color: PdfColors.grey700),
                  align: isRtl ? pw.TextAlign.right : pw.TextAlign.left)
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FixedColumnWidth(100),
                  2: const pw.FixedColumnWidth(80),
                  3: const pw.FixedColumnWidth(80),
                  4: const pw.FlexColumnWidth(3),
                },
                children: [
                  _buildLocalizedTableRow(
                    [
                      _buildTableHeaderCell(l10n?.contact ?? 'Contact'),
                      _buildTableHeaderCell(l10n?.amount ?? 'Amount'),
                      _buildTableHeaderCell(l10n?.date ?? 'Date'),
                      _buildTableHeaderCell(l10n?.statusPending ?? 'Status',
                          l10n: l10n),
                      _buildTableHeaderCell(l10n?.description ?? 'Description'),
                    ],
                    l10n: l10n,
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                  ),
                  ...payablesWithContacts.map((item) {
                    final p = item.payable;
                    final contactColor = item.contact != null
                        ? getContactPdfColor(item.contact!.name)
                        : PdfColors.grey600;
                    return _buildLocalizedTableRow(
                      [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: item.contact != null
                                ? pw.Row(
                                    children: [
                                      pw.Container(
                                        width: 12,
                                        height: 12,
                                        decoration: pw.BoxDecoration(
                                          color: contactColor,
                                          shape: pw.BoxShape.circle,
                                        ),
                                        child: pw.Center(
                                          child: pw.Text(
                                            getInitials(item.contact!.name),
                                            style: pw.TextStyle(
                                                fontSize: 6,
                                                color: PdfColors.white),
                                          ),
                                        ),
                                      ),
                                      pw.SizedBox(width: 4),
                                      pw.Expanded(
                                        child: _buildText(
                                          item.contact!.name,
                                          style:
                                              const pw.TextStyle(fontSize: 9),
                                          align: isRtl
                                              ? pw.TextAlign.right
                                              : pw.TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  )
                                : _buildText('-',
                                    style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: _buildText(
                                '$currency ${p.amount.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color: ExportService.getPayablePdfColor())),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(dateFormat.format(p.date),
                                style: const pw.TextStyle(fontSize: 9),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                _getLocalizedStatus(p.status, l10n),
                                style: const pw.TextStyle(fontSize: 9),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                              p.description ?? '-',
                              style: const pw.TextStyle(fontSize: 9),
                              align: isRtl
                                  ? pw.TextAlign.right
                                  : pw.TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                      l10n: l10n,
                    );
                  }),
                ],
              ),
            pw.SizedBox(height: 30),

            // Receivables Section
            _buildLocalizedHeader(l10n?.receivables ?? 'Receivables',
                level: 1, l10n: l10n),
            pw.SizedBox(height: 10),
            if (receivablesWithContacts.isEmpty)
              _buildText(
                  l10n?.noReceivablesInRange ??
                      'No receivables in this date range.',
                  style: pw.TextStyle(color: PdfColors.grey700),
                  align: isRtl ? pw.TextAlign.right : pw.TextAlign.left)
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FixedColumnWidth(100),
                  2: const pw.FixedColumnWidth(80),
                  3: const pw.FixedColumnWidth(80),
                  4: const pw.FlexColumnWidth(3),
                },
                children: [
                  _buildLocalizedTableRow(
                    [
                      _buildTableHeaderCell(l10n?.contact ?? 'Contact'),
                      _buildTableHeaderCell(l10n?.amount ?? 'Amount'),
                      _buildTableHeaderCell(l10n?.date ?? 'Date'),
                      _buildTableHeaderCell(l10n?.statusPending ?? 'Status',
                          l10n: l10n),
                      _buildTableHeaderCell(l10n?.description ?? 'Description'),
                    ],
                    l10n: l10n,
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                  ),
                  ...receivablesWithContacts.map((item) {
                    final r = item.receivable;
                    final contactColor = item.contact != null
                        ? getContactPdfColor(item.contact!.name)
                        : PdfColors.grey600;
                    return _buildLocalizedTableRow(
                      [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: item.contact != null
                                ? pw.Row(
                                    children: [
                                      pw.Container(
                                        width: 12,
                                        height: 12,
                                        decoration: pw.BoxDecoration(
                                          color: contactColor,
                                          shape: pw.BoxShape.circle,
                                        ),
                                        child: pw.Center(
                                          child: pw.Text(
                                            getInitials(item.contact!.name),
                                            style: pw.TextStyle(
                                                fontSize: 6,
                                                color: PdfColors.white),
                                          ),
                                        ),
                                      ),
                                      pw.SizedBox(width: 4),
                                      pw.Expanded(
                                        child: _buildText(
                                          item.contact!.name,
                                          style:
                                              const pw.TextStyle(fontSize: 9),
                                          align: isRtl
                                              ? pw.TextAlign.right
                                              : pw.TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  )
                                : _buildText('-',
                                    style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: _buildText(
                                '$currency ${r.amount.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color:
                                        ExportService.getReceivablePdfColor())),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(dateFormat.format(r.date),
                                style: const pw.TextStyle(fontSize: 9),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                _getLocalizedStatus(r.status, l10n),
                                style: const pw.TextStyle(fontSize: 9),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                              r.description ?? '-',
                              style: const pw.TextStyle(fontSize: 9),
                              align: isRtl
                                  ? pw.TextAlign.right
                                  : pw.TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                      l10n: l10n,
                    );
                  }),
                ],
              ),
          ];
        },
      ),
    );

    return pdf;
  }

  // Helper method to build category icon
  pw.Widget _buildCategoryIcon(
      String? iconCodePoint, PdfColor color, pw.Font? font,
      {AppLocalizations? l10n}) {
    // Try to parse icon codePoint and render with Material Icons font
    if (font != null && iconCodePoint != null && iconCodePoint.isNotEmpty) {
      final codePoint = int.tryParse(iconCodePoint);
      if (codePoint != null) {
        // Material Icons use private Unicode range 0xe000-0xefff
        // Validate codePoint is in valid range
        if (codePoint >= 0xe000 && codePoint <= 0xefff) {
          // Use pw.Icon widget with pw.IconData wrapped in circular container
          // to match avatar appearance (12x12 with colored background)
          return pw.SizedBox(
            width: 12,
            height: 12,
            child: pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                color: color,
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Icon(
                  pw.IconData(codePoint),
                  font: font,
                  size: 8,
                  color: PdfColors.white,
                ),
              ),
            ),
          );
        }
      }
    }
    // Fallback to colored circle if font is not available or codePoint is invalid
    return pw.SizedBox(
      width: 12,
      height: 12,
      child: pw.Container(
        width: 12,
        height: 12,
        decoration: pw.BoxDecoration(
          color: color,
          shape: pw.BoxShape.circle,
        ),
      ),
    );
  }

  // Helper method to build a table row with RTL support
  pw.TableRow _buildLocalizedTableRow(List<pw.Widget> children,
      {AppLocalizations? l10n, pw.BoxDecoration? decoration}) {
    final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);
    return pw.TableRow(
      decoration: decoration,
      children: isRtl ? children.reversed.toList() : children,
    );
  }

  // Helper method to build a header with RTL support
  pw.Widget _buildLocalizedHeader(String text,
      {int level = 1, AppLocalizations? l10n, pw.TextStyle? style}) {
    final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);
    return pw.Header(
      level: level,
      child: pw.Container(
        width: double.infinity,
        alignment: isRtl ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
        child: _buildText(
          text,
          style: style ??
              pw.TextStyle(
                fontSize: level == 0 ? 24 : 18,
                fontWeight: pw.FontWeight.bold,
                color: level == 0
                    ? const PdfColor(0 / 255.0, 100 / 255.0, 150 / 255.0)
                    : null,
              ),
          align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
        ),
      ),
    );
  }

  // Helper methods for table cells
  pw.Widget _buildTableCell(String text,
      [String? value, PdfColor? color, AppLocalizations? l10n]) {
    final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);

    final children = [
      _buildText(text,
          style: const pw.TextStyle(fontSize: 10),
          align: isRtl ? pw.TextAlign.right : pw.TextAlign.left),
      if (value != null)
        _buildText(value,
            style: pw.TextStyle(
                fontSize: 10, fontWeight: pw.FontWeight.bold, color: color),
            align: isRtl ? pw.TextAlign.right : pw.TextAlign.left),
    ];

    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: isRtl ? children.reversed.toList() : children,
      ),
    );
  }

  pw.Widget _buildTableHeaderCell(String text, {AppLocalizations? l10n}) {
    final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Container(
        alignment: isRtl ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
        child: _buildText(text,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            align: isRtl ? pw.TextAlign.right : pw.TextAlign.left),
      ),
    );
  }

  // Helper method to build text with RTL and character shaping support
  pw.Widget _buildText(String text,
      {pw.TextStyle? style, pw.TextAlign? align}) {
    if (Bidi.hasAnyRtl(text)) {
      List<String> parts = text.split(' ');
      List<pw.Widget> widgets = [];
      for (String part in parts) {
        if (Bidi.hasAnyRtl(part)) {
          // 1. Reshape to get the connected glyphs
          final reshaped = _reshaper.reshape(part);
          String fixedRtl = reshaped;
          widgets.add(pw.Text(fixedRtl,
              style: style?.copyWith(font: _unicodeFont), textAlign: align));
        } else {
          widgets.add(pw.Text(part, style: style, textAlign: align));
        }
      }

      return pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Wrap(
          children: widgets.toList(),
        ),
      );
    }

    return pw.Text(
      text,
      style: style,
      textAlign: align ?? pw.TextAlign.left,
    );
  }

  // A helper to reverse the string while keeping numbers/English intact
  // String _logicalToVisual(String input) { ... }

  // Export transactions to PDF
  Future<Uint8List> exportTransactionsToPDF({
    required DateTime startDate,
    required DateTime endDate,
    String? currencySymbol,
    AppLocalizations? l10n,
  }) async {
    try {
      // Load Material Icons and Unicode fonts
      final materialIconsFont = await loadMaterialIconsFont();
      final unicodeFont = await loadUnicodeFont();
      final hindiFont = await loadHindiFont();
      final englishFont = await loadEnglishFont();

      final pdf = await generatePDFDocument(
        startDate: startDate,
        endDate: endDate,
        currencySymbol: currencySymbol,
        materialIconsFont: materialIconsFont,
        unicodeFont: unicodeFont,
        hindiFont: hindiFont,
        englishFont: englishFont,
        l10n: l10n,
      );
      return pdf.save();
    } catch (e) {
      throw Exception('Error generating PDF: $e');
    }
  }

  // Save PDF to file
  Future<String> savePDFToFile({
    required DateTime startDate,
    required DateTime endDate,
    String? currencySymbol,
    bool useCache = false,
    AppLocalizations? l10n,
  }) async {
    try {
      final pdfBytes = await exportTransactionsToPDF(
        startDate: startDate,
        endDate: endDate,
        currencySymbol: currencySymbol,
        l10n: l10n,
      );

      final directory = await (useCache
          ? getTemporaryDirectory()
          : getApplicationDocumentsDirectory());
      final fileName =
          'flowpaisa_export_${AppDateFormatter.formatForFileName(DateTime.now())}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      return file.path;
    } catch (e) {
      throw Exception('Error saving PDF: $e');
    }
  }

  // Test PDF: Generate a PDF with all symbol icons showing icon, codepoint, and glyph code
  Future<Uint8List> generateTestCategoriesPDF() async {
    try {
      // Load Material Icons font
      final materialIconsFont = await loadMaterialIconsFont();

      // Get all icons info from IconHelper
      final allIconsInfo = IconHelper.getAllIconsInfo();

      // Helper function to build icon widget
      pw.Widget buildIconWidget(IconData icon, pw.Font? font) {
        if (font != null) {
          final codePoint = icon.codePoint;
          if (codePoint >= 0xe000 && codePoint <= 0xefff) {
            return pw.Icon(
              pw.IconData(codePoint),
              font: font,
              size: 20,
              color: PdfColors.black,
            );
          }
        }
        // Fallback to colored circle
        return pw.Container(
          width: 20,
          height: 20,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey400,
            shape: pw.BoxShape.circle,
          ),
        );
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          theme: materialIconsFont != null
              ? pw.ThemeData.withFont(icons: materialIconsFont)
              : null,
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Text(
                  'All Symbol Icons - Icon, Codepoint, and Glyph Code',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Total Icons: ${allIconsInfo.length}',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 20),

              // Icons Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FixedColumnWidth(60),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FixedColumnWidth(100),
                },
                children: [
                  _buildLocalizedTableRow(
                    [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Icon',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Glyph Code',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Codepoint',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                  ),
                  // Icon rows
                  ...allIconsInfo.map((iconInfo) {
                    final icon = iconInfo['icon'] as IconData;
                    final codepoint = iconInfo['codepoint'] as int;
                    final glyphCode = iconInfo['glyphCode'] as String;

                    return _buildLocalizedTableRow(
                      [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Center(
                            child: buildIconWidget(icon, materialIconsFont),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            glyphCode,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            codepoint.toString(),
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ];
          },
        ),
      );

      return pdf.save();
    } catch (e) {
      throw Exception('Error generating test PDF: $e');
    }
  }

  // Share PDF file
  Future<void> sharePDFFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist at path: $filePath');
      }

      if (Platform.isAndroid) {
        final success = await NativeShare.shareFile(filePath);
        if (!success) {
          throw Exception('Native share failed');
        }
      } else {
        final xFile = XFile(
          filePath,
          mimeType: 'application/pdf',
          name: filePath.split(Platform.pathSeparator).last,
        );

        final result = await SharePlus.instance.share(ShareParams(
          files: [xFile],
        ));

        if (result.status == ShareResultStatus.dismissed ||
            result.status == ShareResultStatus.unavailable) {
          // Handle or ignore
        }
      }
    } catch (e) {
      throw Exception('Error sharing PDF file: $e');
    }
  }

  // Export analytics to PDF
  Future<Uint8List> exportAnalyticsToPDF({
    required DateTime startDate,
    required DateTime endDate,
    String? currencySymbol,
    AppLocalizations? l10n,
  }) async {
    try {
      // Load Material Icons and Unicode fonts
      final materialIconsFont = await loadMaterialIconsFont();
      final unicodeFont = await loadUnicodeFont();
      final hindiFont = await loadHindiFont();
      final englishFont = await loadEnglishFont();

      final pdf = await generateAnalyticsPDFDocument(
        startDate: startDate,
        endDate: endDate,
        currencySymbol: currencySymbol,
        materialIconsFont: materialIconsFont,
        unicodeFont: unicodeFont,
        hindiFont: hindiFont,
        englishFont: englishFont,
        l10n: l10n,
      );
      return pdf.save();
    } catch (e) {
      throw Exception('Error generating analytics PDF: $e');
    }
  }

  // Generate Analytics PDF document
  Future<pw.Document> generateAnalyticsPDFDocument({
    required DateTime startDate,
    required DateTime endDate,
    String? currencySymbol,
    pw.Font? materialIconsFont,
    pw.Font? unicodeFont,
    pw.Font? hindiFont,
    pw.Font? englishFont,
    AppLocalizations? l10n,
  }) async {
    // Fetch all analytics data
    final financialSummary =
        await _analyticsRepository.getFinancialSummary(startDate, endDate);
    final allTimeFinancialSummary =
        await _analyticsRepository.getAllTimeFinancialSummary();
    final contactSummaries =
        await _analyticsRepository.getContactSummaries(startDate, endDate);
    final expensesByCategory =
        await _analyticsRepository.getExpensesByCategory(startDate);
    final incomeByCategory =
        await _analyticsRepository.getIncomeByCategory(startDate, endDate);
    final monthlyTrends = await _analyticsRepository.getMonthlyTrends(6);
    final payableReceivableTrends =
        await _analyticsRepository.getPayableReceivableTrends(6);
    final topContacts = await _analyticsRepository.getTopContactsByBalance(
        startDate, endDate, 10);
    final statusDistribution = await _analyticsRepository
        .getPaymentStatusDistribution(startDate, endDate);

    final currency = currencySymbol ?? '₹';
    final dateFormat = AppDateFormatter.getFormatter(_dateFormat);
    final dateTimeFormat = AppDateFormatter.getFormatter('dd MMM yyyy, HH:mm');

    // Helper function to convert hex color to PdfColor
    PdfColor hexToPdfColor(String hex) {
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) {
        final r = int.parse(hex.substring(0, 2), radix: 16) / 255.0;
        final g = int.parse(hex.substring(2, 4), radix: 16) / 255.0;
        final b = int.parse(hex.substring(4, 6), radix: 16) / 255.0;
        return PdfColor(r, g, b);
      }
      return PdfColors.black;
    }

    // Helper function to get contact color as PdfColor
    PdfColor getContactPdfColor(String name) {
      final color = AppColors.getContactColor(name);
      return PdfColor(color.r, color.g, color.b);
    }

    // Helper function to get initials
    String getInitials(String name) {
      if (name.isEmpty) return '?';
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }

    // Create PDF document
    final pdf = pw.Document();

    // Set default theme with Unicode font and fallbacks
    final theme = pw.ThemeData.withFont(
      base: englishFont ?? unicodeFont,
      bold: englishFont ?? unicodeFont,
      fontFallback: [
        if (unicodeFont != null) unicodeFont,
        if (hindiFont != null) hindiFont,
        if (englishFont != null) englishFont,
      ],
    );

    // Capture this for use in closure
    final self = this;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: theme,
        build: (pw.Context context) {
          final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);

          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: isRtl
                    ? pw.CrossAxisAlignment.end
                    : pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    alignment: isRtl
                        ? pw.Alignment.centerRight
                        : pw.Alignment.centerLeft,
                    child: _buildText(
                      l10n?.exportAnalyticsPDF ?? 'FlowPaisa Analytics Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor(
                            0 / 255.0, 100 / 255.0, 150 / 255.0), // Darker Cyan
                      ),
                      align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Table(
                    columnWidths: {
                      0: const pw.IntrinsicColumnWidth(),
                      1: const pw.FixedColumnWidth(5),
                      2: const pw.IntrinsicColumnWidth(),
                    },
                    children: [
                      _buildLocalizedTableRow(
                        [
                          _buildText(
                            l10n?.createdLabel('').split(':')[0] ??
                                'Generated on',
                            style: pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey700),
                            align:
                                isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                          ),
                          _buildText(':',
                              style: pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700)),
                          _buildText(
                            dateTimeFormat.format(DateTime.now()),
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                            align:
                                isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                          ),
                        ],
                        l10n: l10n,
                      ),
                      _buildLocalizedTableRow(
                        [
                          _buildText(
                            l10n?.dateRange ?? 'Date Range',
                            style: pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey700),
                            align:
                                isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                          ),
                          _buildText(':',
                              style: pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700)),
                          _buildText(
                            '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                            align:
                                isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                          ),
                        ],
                        l10n: l10n,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Financial Summary
            _buildLocalizedHeader(l10n?.summary ?? 'Financial Summary',
                level: 1, l10n: l10n),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        '${l10n?.payable ?? 'Payable'}',
                        '$currency ${financialSummary.totalPayable.toStringAsFixed(2)}',
                        ExportService.getPayablePdfColor(),
                        l10n),
                    _buildTableCell(
                        '${l10n?.payable ?? 'Payable'} (${l10n?.allTime.replaceAll(':', '').trim() ?? 'All Time'})',
                        '$currency ${allTimeFinancialSummary.totalPayable.toStringAsFixed(2)}',
                        ExportService.getPayablePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        '${l10n?.receivable ?? 'Receivable'}',
                        '$currency ${financialSummary.totalReceivable.toStringAsFixed(2)}',
                        ExportService.getReceivablePdfColor(),
                        l10n),
                    _buildTableCell(
                        '${l10n?.receivable ?? 'Receivable'} (${l10n?.allTime.replaceAll(':', '').trim() ?? 'All Time'})',
                        '$currency ${allTimeFinancialSummary.totalReceivable.toStringAsFixed(2)}',
                        ExportService.getReceivablePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        '${l10n?.expense ?? 'Expenses'}',
                        '$currency ${financialSummary.totalExpense.toStringAsFixed(2)}',
                        ExportService.getExpensePdfColor(),
                        l10n),
                    _buildTableCell(
                        '${l10n?.expense ?? 'Expenses'} (${l10n?.allTime.replaceAll(':', '').trim() ?? 'All Time'})',
                        '$currency ${allTimeFinancialSummary.totalExpense.toStringAsFixed(2)}',
                        ExportService.getExpensePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        '${l10n?.income ?? 'Income'}',
                        '$currency ${financialSummary.totalIncome.toStringAsFixed(2)}',
                        ExportService.getIncomePdfColor(),
                        l10n),
                    _buildTableCell(
                        '${l10n?.income ?? 'Income'} (${l10n?.allTime.replaceAll(':', '').trim() ?? 'All Time'})',
                        '$currency ${allTimeFinancialSummary.totalIncome.toStringAsFixed(2)}',
                        ExportService.getIncomePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        '${l10n?.netBalance ?? 'Net Balance'}',
                        '$currency ${financialSummary.netBalance.toStringAsFixed(2)}',
                        financialSummary.netBalance == 0
                            ? PdfColors.black
                            : financialSummary.netBalance >= 0
                                ? ExportService.getIncomePdfColor()
                                : ExportService.getExpensePdfColor(),
                        l10n),
                    _buildTableCell(
                        '${l10n?.netBalance ?? 'Net Balance'} (${l10n?.allTime.replaceAll(':', '').trim() ?? 'All Time'})',
                        '$currency ${allTimeFinancialSummary.netBalance.toStringAsFixed(2)}',
                        allTimeFinancialSummary.netBalance == 0
                            ? PdfColors.black
                            : allTimeFinancialSummary.netBalance >= 0
                                ? ExportService.getIncomePdfColor()
                                : ExportService.getExpensePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Contact Summaries
            if (contactSummaries.isNotEmpty) ...[
              _buildLocalizedHeader(l10n?.contacts ?? 'Contact Summaries',
                  level: 1, l10n: l10n),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FixedColumnWidth(100),
                  2: const pw.FixedColumnWidth(100),
                  3: const pw.FixedColumnWidth(100),
                },
                children: [
                  _buildLocalizedTableRow(
                    [
                      _buildTableHeaderCell(l10n?.contact ?? 'Contact',
                          l10n: l10n),
                      _buildTableHeaderCell(l10n?.payable ?? 'Total Payable',
                          l10n: l10n),
                      _buildTableHeaderCell(
                          l10n?.receivable ?? 'Total Receivable',
                          l10n: l10n),
                      _buildTableHeaderCell(l10n?.balanceLabel ?? 'Balance',
                          l10n: l10n),
                    ],
                    l10n: l10n,
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                  ),
                  ...contactSummaries.map((summary) {
                    final contactColor =
                        getContactPdfColor(summary.contact.name);
                    final balanceColor = summary.balance == 0
                        ? PdfColors.black
                        : summary.balance >= 0
                            ? ExportService.getReceivablePdfColor()
                            : ExportService.getPayablePdfColor();
                    return _buildLocalizedTableRow(
                      [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: pw.Row(
                              mainAxisAlignment: isRtl
                                  ? pw.MainAxisAlignment.end
                                  : pw.MainAxisAlignment.start,
                              children: isRtl
                                  ? [
                                      pw.Expanded(
                                        child: _buildText(
                                          summary.contact.name,
                                          style:
                                              const pw.TextStyle(fontSize: 9),
                                          align: isRtl
                                              ? pw.TextAlign.right
                                              : pw.TextAlign.left,
                                        ),
                                      ),
                                      pw.SizedBox(width: 4),
                                      pw.Container(
                                        width: 12,
                                        height: 12,
                                        decoration: pw.BoxDecoration(
                                          color: contactColor,
                                          shape: pw.BoxShape.circle,
                                        ),
                                        child: pw.Center(
                                          child: pw.Text(
                                            getInitials(summary.contact.name),
                                            style: pw.TextStyle(
                                                fontSize: 6,
                                                color: PdfColors.white),
                                          ),
                                        ),
                                      ),
                                    ]
                                  : [
                                      pw.Container(
                                        width: 12,
                                        height: 12,
                                        decoration: pw.BoxDecoration(
                                          color: contactColor,
                                          shape: pw.BoxShape.circle,
                                        ),
                                        child: pw.Center(
                                          child: pw.Text(
                                            getInitials(summary.contact.name),
                                            style: pw.TextStyle(
                                                fontSize: 6,
                                                color: PdfColors.white),
                                          ),
                                        ),
                                      ),
                                      pw.SizedBox(width: 4),
                                      pw.Expanded(
                                        child: _buildText(
                                          summary.contact.name,
                                          style:
                                              const pw.TextStyle(fontSize: 9),
                                          align: isRtl
                                              ? pw.TextAlign.right
                                              : pw.TextAlign.left,
                                        ),
                                      ),
                                    ],
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                '$currency ${summary.totalPayable.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color: ExportService.getPayablePdfColor()),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                '$currency ${summary.totalReceivable.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color:
                                        ExportService.getReceivablePdfColor()),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                '$currency ${summary.balance.abs().toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9, color: balanceColor),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                      ],
                      l10n: l10n,
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 30),
            ],

            // Expenses by Category
            if (expensesByCategory.isNotEmpty) ...[
              _buildLocalizedHeader(
                  l10n?.expensesByCategory ?? 'Expenses by Category',
                  level: 1,
                  l10n: l10n),
              pw.SizedBox(height: 10),
              // Visual chart representation
              self._buildVisualCategoryChart(expensesByCategory, currency,
                  hexToPdfColor, ExportService.getExpensePdfColor(),
                  self: self, l10n: l10n),
              pw.SizedBox(height: 10),
              // Data table
              self._buildCategoryTable(
                  expensesByCategory,
                  currency,
                  hexToPdfColor,
                  materialIconsFont,
                  ExportService.getExpensePdfColor(),
                  self: self,
                  l10n: l10n),
              pw.SizedBox(height: 30),
            ],

            // Income by Category
            if (incomeByCategory.isNotEmpty) ...[
              _buildLocalizedHeader(
                  l10n?.incomeByCategory ?? 'Income by Category',
                  level: 1,
                  l10n: l10n),
              pw.SizedBox(height: 10),
              // Visual chart representation
              self._buildVisualCategoryChart(incomeByCategory, currency,
                  hexToPdfColor, ExportService.getIncomePdfColor(),
                  self: self, l10n: l10n),
              pw.SizedBox(height: 10),
              // Data table
              self._buildCategoryTable(
                  incomeByCategory,
                  currency,
                  hexToPdfColor,
                  materialIconsFont,
                  ExportService.getIncomePdfColor(),
                  self: self,
                  l10n: l10n),
              pw.SizedBox(height: 30),
            ],

            // Monthly Trends
            if (monthlyTrends.isNotEmpty) ...[
              _buildLocalizedHeader(
                  l10n?.incomeVsExpenseTrend ??
                      'Monthly Trends (Last 6 Months)',
                  level: 1,
                  l10n: l10n),
              pw.SizedBox(height: 10),
              // Visual bar chart representation
              self._buildVisualBarChart(monthlyTrends, currency,
                  self: self, l10n: l10n),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FixedColumnWidth(120),
                  2: const pw.FixedColumnWidth(120),
                },
                children: [
                  _buildLocalizedTableRow(
                    [
                      _buildTableHeaderCell(l10n?.month ?? 'Month', l10n: l10n),
                      _buildTableHeaderCell(l10n?.income ?? 'Income',
                          l10n: l10n),
                      _buildTableHeaderCell(l10n?.expense ?? 'Expense',
                          l10n: l10n),
                    ],
                    l10n: l10n,
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                  ),
                  ...monthlyTrends.map((trend) {
                    return _buildLocalizedTableRow(
                      [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                _getLocalizedMonth(trend.month, l10n),
                                style: const pw.TextStyle(fontSize: 9),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                '$currency ${trend.income.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color: ExportService.getIncomePdfColor()),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                '$currency ${trend.expense.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color: ExportService.getExpensePdfColor()),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                      ],
                      l10n: l10n,
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 30),
            ],

            // Payable/Receivable Trends
            if (payableReceivableTrends.isNotEmpty) ...[
              _buildLocalizedHeader(
                  l10n?.payableVsReceivableTrend ??
                      'Payable/Receivable Trends (Last 6 Months)',
                  level: 1,
                  l10n: l10n),
              pw.SizedBox(height: 10),
              // Visual bar chart representation
              self._buildVisualPayableReceivableChart(
                  payableReceivableTrends, currency,
                  self: self, l10n: l10n),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FixedColumnWidth(120),
                  2: const pw.FixedColumnWidth(120),
                },
                children: [
                  _buildLocalizedTableRow(
                    [
                      _buildTableHeaderCell(l10n?.month ?? 'Month', l10n: l10n),
                      _buildTableHeaderCell(l10n?.payable ?? 'Payable',
                          l10n: l10n),
                      _buildTableHeaderCell(l10n?.receivable ?? 'Receivable',
                          l10n: l10n),
                    ],
                    l10n: l10n,
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                  ),
                  ...payableReceivableTrends.map((trend) {
                    return _buildLocalizedTableRow(
                      [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                _getLocalizedMonth(trend.month, l10n),
                                style: const pw.TextStyle(fontSize: 9),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                '$currency ${trend.totalPayable.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color: ExportService.getPayablePdfColor()),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                '$currency ${trend.totalReceivable.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color:
                                        ExportService.getReceivablePdfColor()),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                      ],
                      l10n: l10n,
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 30),
            ],

            // Top Contacts by Balance
            if (topContacts.isNotEmpty) ...[
              _buildLocalizedHeader(l10n?.contacts ?? 'Top Contacts by Balance',
                  level: 1, l10n: l10n),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FixedColumnWidth(120),
                },
                children: [
                  _buildLocalizedTableRow(
                    [
                      _buildTableHeaderCell(l10n?.contact ?? 'Contact',
                          l10n: l10n),
                      _buildTableHeaderCell(l10n?.balanceLabel ?? 'Balance',
                          l10n: l10n),
                    ],
                    l10n: l10n,
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                  ),
                  ...topContacts.map((contact) {
                    final contactColor =
                        getContactPdfColor(contact.contact.name);
                    final balanceColor = contact.balance == 0
                        ? PdfColors.black
                        : contact.balance >= 0
                            ? ExportService.getReceivablePdfColor()
                            : ExportService.getPayablePdfColor();
                    return _buildLocalizedTableRow(
                      [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: pw.Row(
                              mainAxisAlignment: isRtl
                                  ? pw.MainAxisAlignment.end
                                  : pw.MainAxisAlignment.start,
                              children: isRtl
                                  ? [
                                      pw.Expanded(
                                        child: _buildText(
                                          contact.contact.name,
                                          style:
                                              const pw.TextStyle(fontSize: 9),
                                          align: isRtl
                                              ? pw.TextAlign.right
                                              : pw.TextAlign.left,
                                        ),
                                      ),
                                      pw.SizedBox(width: 4),
                                      pw.Container(
                                        width: 12,
                                        height: 12,
                                        decoration: pw.BoxDecoration(
                                          color: contactColor,
                                          shape: pw.BoxShape.circle,
                                        ),
                                        child: pw.Center(
                                          child: pw.Text(
                                            getInitials(contact.contact.name),
                                            style: pw.TextStyle(
                                                fontSize: 6,
                                                color: PdfColors.white),
                                          ),
                                        ),
                                      ),
                                    ]
                                  : [
                                      pw.Container(
                                        width: 12,
                                        height: 12,
                                        decoration: pw.BoxDecoration(
                                          color: contactColor,
                                          shape: pw.BoxShape.circle,
                                        ),
                                        child: pw.Center(
                                          child: pw.Text(
                                            getInitials(contact.contact.name),
                                            style: pw.TextStyle(
                                                fontSize: 6,
                                                color: PdfColors.white),
                                          ),
                                        ),
                                      ),
                                      pw.SizedBox(width: 4),
                                      pw.Expanded(
                                        child: _buildText(
                                          contact.contact.name,
                                          style:
                                              const pw.TextStyle(fontSize: 9),
                                          align: isRtl
                                              ? pw.TextAlign.right
                                              : pw.TextAlign.left,
                                        ),
                                      ),
                                    ],
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                                '$currency ${contact.balance.abs().toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9, color: balanceColor),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left),
                          ),
                        ),
                      ],
                      l10n: l10n,
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 30),
            ],

            // Payment Status Distribution
            _buildLocalizedHeader(
                l10n?.paymentStatusDistribution ??
                    'Payment Status Distribution',
                level: 1,
                l10n: l10n),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FixedColumnWidth(120),
              },
              children: [
                _buildLocalizedTableRow(
                  [
                    _buildTableHeaderCell(l10n?.status ?? 'Status'),
                    _buildTableHeaderCell(l10n?.amount ?? 'Amount'),
                  ],
                  l10n: l10n,
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                ),
                if (statusDistribution.pendingPayables > 0)
                  _buildStatusRow(
                      '${l10n?.payables ?? 'Payables'} - ${l10n?.pending ?? 'Pending'}',
                      statusDistribution.pendingPayables,
                      Colors.orange,
                      currency,
                      l10n: l10n),
                if (statusDistribution.paidPayables > 0)
                  _buildStatusRow(
                      '${l10n?.payables ?? 'Payables'} - ${l10n?.statusPaid ?? 'Paid'}',
                      statusDistribution.paidPayables,
                      Colors.green,
                      currency,
                      l10n: l10n),
                if (statusDistribution.cancelledPayables > 0)
                  _buildStatusRow(
                      '${l10n?.payables ?? 'Payables'} - ${l10n?.statusCancelled ?? 'Cancelled'}',
                      statusDistribution.cancelledPayables,
                      Colors.grey,
                      currency,
                      l10n: l10n),
                if (statusDistribution.pendingReceivables > 0)
                  _buildStatusRow(
                      '${l10n?.receivables ?? 'Receivables'} - ${l10n?.pending ?? 'Pending'}',
                      statusDistribution.pendingReceivables,
                      Colors.orange,
                      currency,
                      l10n: l10n),
                if (statusDistribution.receivedReceivables > 0)
                  _buildStatusRow(
                      '${l10n?.receivables ?? 'Receivables'} - ${l10n?.statusReceived ?? 'Received'}',
                      statusDistribution.receivedReceivables,
                      Colors.green,
                      currency,
                      l10n: l10n),
                if (statusDistribution.cancelledReceivables > 0)
                  _buildStatusRow(
                      '${l10n?.receivables ?? 'Receivables'} - ${l10n?.statusCancelled ?? 'Cancelled'}',
                      statusDistribution.cancelledReceivables,
                      Colors.grey,
                      currency,
                      l10n: l10n),
              ],
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  // Helper method to build category table
  pw.Widget _buildCategoryTable(
      List<dynamic> categories,
      String currency,
      PdfColor Function(String) hexToPdfColor,
      pw.Font? materialIconsFont,
      PdfColor defaultColor,
      {ExportService? self,
      AppLocalizations? l10n}) {
    final service = self ?? this;
    double total = 0;
    final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);
    for (var cat in categories) {
      if (cat is CategoryExpense) {
        total += cat.totalAmount;
      } else if (cat is CategoryIncome) {
        total += cat.totalAmount;
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3), // Category (with icon)
        1: const pw.FixedColumnWidth(80), // Percentage
        2: const pw.FixedColumnWidth(100), // Amount
      },
      children: [
        service._buildLocalizedTableRow(
          [
            _buildTableHeaderCell(l10n?.category ?? 'Category'),
            _buildTableHeaderCell(l10n?.percentage ?? 'Percentage'),
            _buildTableHeaderCell(l10n?.amount ?? 'Amount'),
          ],
          l10n: l10n,
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        ),
        ...categories.map((cat) {
          final category = cat is CategoryExpense
              ? cat.category
              : (cat as CategoryIncome).category;
          final amount = cat is CategoryExpense
              ? cat.totalAmount
              : (cat as CategoryIncome).totalAmount;
          final percentage = total > 0 ? (amount / total) * 100 : 0.0;
          final categoryColor = category.color != null
              ? hexToPdfColor(category.color!)
              : defaultColor;

          return service._buildLocalizedTableRow(
            [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 12,
                        height: 12,
                        child: service._buildCategoryIcon(
                            category.icon, categoryColor, materialIconsFont),
                      ),
                      pw.SizedBox(width: 4),
                      pw.Expanded(
                        child: service._buildText(
                          service._getLocalizedCategoryName(
                              category.name, l10n),
                          style: const pw.TextStyle(fontSize: 9),
                          align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: service._buildText(
                    '${percentage.toStringAsFixed(1)}%',
                    style: pw.TextStyle(fontSize: 9, color: categoryColor),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: service._buildText(
                    '$currency ${amount.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 9, color: categoryColor),
                  ),
                ),
              ),
            ],
            l10n: l10n,
          );
        }),
      ],
    );
  }

  // Helper method to build status row
  pw.TableRow _buildStatusRow(
      String label, double amount, Color color, String currency,
      {AppLocalizations? l10n}) {
    final pdfColor = PdfColor(color.r, color.g, color.b);
    final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);
    return _buildLocalizedTableRow(
      [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Container(
            alignment:
                isRtl ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
            child: _buildText(_getLocalizedStatus(label, l10n),
                style: const pw.TextStyle(fontSize: 9),
                align: isRtl ? pw.TextAlign.right : pw.TextAlign.left),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Container(
            alignment:
                isRtl ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
            child: _buildText('$currency ${amount.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 9, color: pdfColor),
                align: isRtl ? pw.TextAlign.right : pw.TextAlign.left),
          ),
        ),
      ],
      l10n: l10n,
    );
  }

  // Helper method to build visual category chart (horizontal bars)
  pw.Widget _buildVisualCategoryChart(List<dynamic> categories, String currency,
      PdfColor Function(String) hexToPdfColor, PdfColor defaultColor,
      {ExportService? self, AppLocalizations? l10n}) {
    double total = 0;
    for (var cat in categories) {
      if (cat is CategoryExpense) {
        total += cat.totalAmount;
      } else if (cat is CategoryIncome) {
        total += cat.totalAmount;
      }
    }

    if (total == 0 || categories.isEmpty) {
      return pw.SizedBox(height: 0);
    }

    // Get top 5 categories for visualization
    final topCategories = categories.take(5).toList();
    final maxAmount = topCategories.isNotEmpty
        ? (topCategories.first is CategoryExpense
            ? (topCategories.first as CategoryExpense).totalAmount
            : (topCategories.first as CategoryIncome).totalAmount)
        : 0.0;

    final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment:
            isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          _buildText(
              l10n?.incomeVsExpenseTrendVisual ?? 'Top Categories (Visual)',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left),
          pw.SizedBox(height: 8),
          ...topCategories.map((cat) {
            final category = cat is CategoryExpense
                ? cat.category
                : (cat as CategoryIncome).category;
            final amount = cat is CategoryExpense
                ? cat.totalAmount
                : (cat as CategoryIncome).totalAmount;
            final percentage = total > 0 ? (amount / total) : 0.0;
            final categoryColor = category.color != null
                ? hexToPdfColor(category.color!)
                : defaultColor;
            final barWidth = maxAmount > 0 ? (amount / maxAmount) : 0.0;

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Column(
                crossAxisAlignment: isRtl
                    ? pw.CrossAxisAlignment.end
                    : pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: isRtl
                        ? [
                            _buildText(
                              '${(percentage * 100).toStringAsFixed(1)}%',
                              style: pw.TextStyle(
                                  fontSize: 8, color: categoryColor),
                            ),
                            pw.Expanded(
                              child: _buildText(
                                _getLocalizedCategoryName(category.name, l10n),
                                style: const pw.TextStyle(fontSize: 8),
                                align: pw.TextAlign.left,
                              ),
                            ),
                          ]
                        : [
                            pw.Expanded(
                              child: _buildText(
                                _getLocalizedCategoryName(category.name, l10n),
                                style: const pw.TextStyle(fontSize: 8),
                                align: pw.TextAlign.left,
                              ),
                            ),
                            _buildText(
                              '${(percentage * 100).toStringAsFixed(1)}%',
                              style: pw.TextStyle(
                                  fontSize: 8, color: categoryColor),
                            ),
                          ],
                  ),
                  pw.SizedBox(height: 2),
                  // Visual progress bar
                  pw.Container(
                    height: 8,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Stack(
                      alignment: isRtl
                          ? pw.Alignment.centerRight
                          : pw.Alignment.centerLeft,
                      children: [
                        pw.Container(
                          width: 200.0 * barWidth,
                          height: 8,
                          decoration: pw.BoxDecoration(
                            color: categoryColor,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Helper method to build visual bar chart for monthly trends
  pw.Widget _buildVisualBarChart(
      List<MonthlyFinancials> trends, String currency,
      {ExportService? self, AppLocalizations? l10n}) {
    if (trends.isEmpty) {
      return pw.SizedBox(height: 0);
    }

    // Calculate max value for scaling
    double maxValue = 0;
    for (var trend in trends) {
      if (trend.income > maxValue) maxValue = trend.income;
      if (trend.expense > maxValue) maxValue = trend.expense;
    }
    maxValue = maxValue * 1.1;
    if (maxValue == 0) maxValue = 100;

    final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment:
            isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          _buildText(
              l10n?.incomeVsExpenseTrendVisual ??
                  'Income vs Expense Trend (Visual)',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left),
          pw.SizedBox(height: 8),
          ...trends.asMap().entries.map((entry) {
            final trend = entry.value;
            final incomeBar = maxValue > 0 ? (trend.income / maxValue) : 0.0;
            final expenseBar = maxValue > 0 ? (trend.expense / maxValue) : 0.0;
            final monthLabel = _getLocalizedMonth(trend.month, l10n);

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: isRtl
                    ? pw.CrossAxisAlignment.end
                    : pw.CrossAxisAlignment.start,
                children: [
                  _buildText(
                    monthLabel,
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold),
                    align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                  ),
                  pw.SizedBox(height: 4),
                  // Income bar
                  pw.Row(
                    mainAxisAlignment: isRtl
                        ? pw.MainAxisAlignment.end
                        : pw.MainAxisAlignment.start,
                    children: isRtl
                        ? [
                            _buildText(
                              '$currency ${trend.income.toStringAsFixed(0)}',
                              style: pw.TextStyle(
                                fontSize: 7,
                                color: ExportService.getIncomePdfColor(),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            pw.Container(
                              width: 150.0 * incomeBar,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: ExportService.getIncomePdfColor(),
                                borderRadius: pw.BorderRadius.circular(2),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            _buildText(
                                l10n?.incomeShort.replaceAll(':', '').trim() ??
                                    'I',
                                style: const pw.TextStyle(fontSize: 7)),
                          ]
                        : [
                            _buildText(
                                l10n?.incomeShort.replaceAll(':', '').trim() ??
                                    'I',
                                style: const pw.TextStyle(fontSize: 7)),
                            pw.SizedBox(width: 4),
                            pw.Container(
                              width: 150.0 * incomeBar,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: ExportService.getIncomePdfColor(),
                                borderRadius: pw.BorderRadius.circular(2),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            _buildText(
                              '$currency ${trend.income.toStringAsFixed(0)}',
                              style: pw.TextStyle(
                                fontSize: 7,
                                color: ExportService.getIncomePdfColor(),
                              ),
                            ),
                          ],
                  ),
                  pw.SizedBox(height: 2),
                  // Expense bar
                  pw.Row(
                    mainAxisAlignment: isRtl
                        ? pw.MainAxisAlignment.end
                        : pw.MainAxisAlignment.start,
                    children: isRtl
                        ? [
                            _buildText(
                              '$currency ${trend.expense.toStringAsFixed(0)}',
                              style: pw.TextStyle(
                                fontSize: 7,
                                color: ExportService.getExpensePdfColor(),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            pw.Container(
                              width: 150.0 * expenseBar,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: ExportService.getExpensePdfColor(),
                                borderRadius: pw.BorderRadius.circular(2),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            _buildText(
                                l10n?.expenseShort.replaceAll(':', '').trim() ??
                                    'E',
                                style: const pw.TextStyle(fontSize: 7)),
                          ]
                        : [
                            _buildText(
                                l10n?.expenseShort.replaceAll(':', '').trim() ??
                                    'E',
                                style: const pw.TextStyle(fontSize: 7)),
                            pw.SizedBox(width: 4),
                            pw.Container(
                              width: 150.0 * expenseBar,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: ExportService.getExpensePdfColor(),
                                borderRadius: pw.BorderRadius.circular(2),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            _buildText(
                              '$currency ${trend.expense.toStringAsFixed(0)}',
                              style: pw.TextStyle(
                                fontSize: 7,
                                color: ExportService.getExpensePdfColor(),
                              ),
                            ),
                          ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Helper method to build visual bar chart for payable/receivable trends
  pw.Widget _buildVisualPayableReceivableChart(
      List<PayableReceivableTrend> trends, String currency,
      {ExportService? self, AppLocalizations? l10n}) {
    if (trends.isEmpty) {
      return pw.SizedBox(height: 0);
    }

    double maxValue = 0;
    for (var trend in trends) {
      if (trend.totalPayable > maxValue) maxValue = trend.totalPayable;
      if (trend.totalReceivable > maxValue) maxValue = trend.totalReceivable;
    }
    maxValue = maxValue * 1.1;
    if (maxValue == 0) maxValue = 100;

    final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment:
            isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          _buildText(
              l10n?.payableVsReceivableTrendVisual ??
                  'Payable vs Receivable Trend (Visual)',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left),
          pw.SizedBox(height: 8),
          ...trends.asMap().entries.map((entry) {
            final trend = entry.value;
            final payableBar =
                maxValue > 0 ? (trend.totalPayable / maxValue) : 0.0;
            final receivableBar =
                maxValue > 0 ? (trend.totalReceivable / maxValue) : 0.0;
            final monthLabel = _getLocalizedMonth(trend.month, l10n);

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: isRtl
                    ? pw.CrossAxisAlignment.end
                    : pw.CrossAxisAlignment.start,
                children: [
                  _buildText(
                    monthLabel,
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold),
                    align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                  ),
                  pw.SizedBox(height: 4),
                  // Payable bar
                  pw.Row(
                    mainAxisAlignment: isRtl
                        ? pw.MainAxisAlignment.end
                        : pw.MainAxisAlignment.start,
                    children: isRtl
                        ? [
                            _buildText(
                              '$currency ${trend.totalPayable.toStringAsFixed(0)}',
                              style: pw.TextStyle(
                                fontSize: 7,
                                color: ExportService.getPayablePdfColor(),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            pw.Container(
                              width: 150.0 * payableBar,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: ExportService.getPayablePdfColor(),
                                borderRadius: pw.BorderRadius.circular(2),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            _buildText(
                                l10n?.payableShort.replaceAll(':', '').trim() ??
                                    'P',
                                style: const pw.TextStyle(fontSize: 7)),
                          ]
                        : [
                            _buildText(
                                l10n?.payableShort.replaceAll(':', '').trim() ??
                                    'P',
                                style: const pw.TextStyle(fontSize: 7)),
                            pw.SizedBox(width: 4),
                            pw.Container(
                              width: 150.0 * payableBar,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: ExportService.getPayablePdfColor(),
                                borderRadius: pw.BorderRadius.circular(2),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            _buildText(
                              '$currency ${trend.totalPayable.toStringAsFixed(0)}',
                              style: pw.TextStyle(
                                fontSize: 7,
                                color: ExportService.getPayablePdfColor(),
                              ),
                            ),
                          ],
                  ),
                  pw.SizedBox(height: 2),
                  // Receivable bar
                  pw.Row(
                    mainAxisAlignment: isRtl
                        ? pw.MainAxisAlignment.end
                        : pw.MainAxisAlignment.start,
                    children: isRtl
                        ? [
                            _buildText(
                              '$currency ${trend.totalReceivable.toStringAsFixed(0)}',
                              style: pw.TextStyle(
                                fontSize: 7,
                                color: ExportService.getReceivablePdfColor(),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            pw.Container(
                              width: 150.0 * receivableBar,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: ExportService.getReceivablePdfColor(),
                                borderRadius: pw.BorderRadius.circular(2),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            _buildText(
                                l10n?.receivableShort
                                        .replaceAll(':', '')
                                        .trim() ??
                                    'R',
                                style: const pw.TextStyle(fontSize: 7)),
                          ]
                        : [
                            _buildText(
                                l10n?.receivableShort
                                        .replaceAll(':', '')
                                        .trim() ??
                                    'R',
                                style: const pw.TextStyle(fontSize: 7)),
                            pw.SizedBox(width: 4),
                            pw.Container(
                              width: 150.0 * receivableBar,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: ExportService.getReceivablePdfColor(),
                                borderRadius: pw.BorderRadius.circular(2),
                              ),
                            ),
                            pw.SizedBox(width: 4),
                            _buildText(
                              '$currency ${trend.totalReceivable.toStringAsFixed(0)}',
                              style: pw.TextStyle(
                                fontSize: 7,
                                color: ExportService.getReceivablePdfColor(),
                              ),
                            ),
                          ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ExportSummary {
  final DateTime startDate;
  final DateTime endDate;
  final int totalTransactions;
  final double totalIncome;
  final double totalExpense;
  final int incomeCount;
  final int expenseCount;
  final double netBalance;

  ExportSummary({
    required this.startDate,
    required this.endDate,
    required this.totalTransactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.incomeCount,
    required this.expenseCount,
    required this.netBalance,
  });
}
