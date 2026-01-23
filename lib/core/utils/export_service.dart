import 'dart:io';
import 'dart:typed_data';
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

class ExportService {
  final TransactionsRepository _transactionsRepository;
  final AppDatabase _database;
  final String _dateFormat;
  static pw.Font? _cachedFont;

  ExportService(this._transactionsRepository, this._database,
      {String? dateFormat})
      : _dateFormat = dateFormat ?? AppDateFormatter.defaultPattern;

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
      print('Warning: Could not load Material Icons font: $e');
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
      await file.writeAsString(csvString);

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

        final result = await Share.shareXFiles([xFile]);

        if (result.status == ShareResultStatus.unavailable) {
          throw Exception('Sharing is not available on this device');
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
    return PdfColor(0x10 / 255.0, 0xB9 / 255.0, 0x81 / 255.0); // #10B981
  }

  static PdfColor getExpensePdfColor() {
    return PdfColor(0xFF / 255.0, 0x70 / 255.0, 0x43 / 255.0); // #FF7043
  }

  static PdfColor getPayablePdfColor() {
    return PdfColor(0xFB / 255.0, 0xBF / 255.0, 0x24 / 255.0); // #FBBF24
  }

  static PdfColor getReceivablePdfColor() {
    return PdfColor(0x22 / 255.0, 0xD3 / 255.0, 0xEE / 255.0); // #22D3EE
  }

  // Generate PDF document
  Future<pw.Document> generatePDFDocument({
    required DateTime startDate,
    required DateTime endDate,
    String? currencySymbol,
    pw.Font? materialIconsFont,
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
      return PdfColor(
          color.red / 255.0, color.green / 255.0, color.blue / 255.0);
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
        build: (pw.Context context) {
          // Capture this reference for use in closure
          final self = this;

          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'FlowPaisa Export Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor(
                          0 / 255.0, 212 / 255.0, 255 / 255.0), // brightCyan
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated on: ${dateTimeFormat.format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'Date Range: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Overall Summary
            pw.Header(
              level: 1,
              child: pw.Text('Summary',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  children: [
                    _buildTableCell('Total Transactions',
                        filteredTransactions.length.toString()),
                    _buildTableCell(
                        'Total Income',
                        '$currency ${totalIncome.toStringAsFixed(2)}',
                        ExportService.getIncomePdfColor()),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell(
                        'Total Expense',
                        '$currency ${totalExpense.toStringAsFixed(2)}',
                        ExportService.getExpensePdfColor()),
                    _buildTableCell(
                        'Net Balance',
                        '$currency ${(totalIncome - totalExpense).toStringAsFixed(2)}',
                        (totalIncome - totalExpense) == 0
                            ? PdfColors.black
                            : (totalIncome - totalExpense) >= 0
                                ? ExportService.getIncomePdfColor()
                                : ExportService.getExpensePdfColor()),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell(
                        'Payables (Pending)',
                        '$currency ${totalPayablePending.toStringAsFixed(2)}',
                        ExportService.getPayablePdfColor()),
                    _buildTableCell(
                        'Payables (Paid)',
                        '$currency ${totalPayablePaid.toStringAsFixed(2)}',
                        ExportService.getPayablePdfColor()),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell(
                        'Receivables (Pending)',
                        '$currency ${totalReceivablePending.toStringAsFixed(2)}',
                        ExportService.getReceivablePdfColor()),
                    _buildTableCell(
                        'Receivables (Received)',
                        '$currency ${totalReceivableReceived.toStringAsFixed(2)}',
                        ExportService.getReceivablePdfColor()),
                  ],
                ),
                // Net Payable/Receivable row (only pending amounts)
                pw.TableRow(
                  children: [
                    _buildTableCell(
                        totalPayablePending >= totalReceivablePending
                            ? 'Net Payable (Pending)'
                            : 'Net Receivable (Pending)',
                        '$currency ${(totalPayablePending - totalReceivablePending).abs().toStringAsFixed(2)}',
                        (totalPayablePending - totalReceivablePending).abs() ==
                                0
                            ? PdfColors.black
                            : totalPayablePending >= totalReceivablePending
                                ? ExportService.getPayablePdfColor()
                                : ExportService.getReceivablePdfColor()),
                    _buildTableCell('', null),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Transactions Section
            pw.Header(
              level: 1,
              child: pw.Text('Transactions',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            if (filteredTransactions.isEmpty)
              pw.Text('No transactions in this date range.',
                  style: pw.TextStyle(color: PdfColors.grey700))
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
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableHeaderCell('Date'),
                      _buildTableHeaderCell('Type'),
                      _buildTableHeaderCell('Amount'),
                      _buildTableHeaderCell('Category'),
                      _buildTableHeaderCell('Contact'),
                      _buildTableHeaderCell('Description'),
                    ],
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
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(dateFormat.format(t.date),
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(t.type,
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                '$currency ${t.amount.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9, color: amountColor)),
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
                                  ),
                                ),
                                pw.SizedBox(width: 4),
                                pw.Expanded(
                                  child: pw.Text(
                                    item.category?.name ?? '-',
                                    style: const pw.TextStyle(fontSize: 9),
                                    maxLines: 1,
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
                                        child: pw.Text(
                                          item.contact!.name,
                                          style:
                                              const pw.TextStyle(fontSize: 9),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  )
                                : pw.Text('-',
                                    style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                              t.description ?? '-',
                              style: const pw.TextStyle(fontSize: 9),
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            pw.SizedBox(height: 30),

            // Payables Section
            pw.Header(
              level: 1,
              child: pw.Text('Payables',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            if (payablesWithContacts.isEmpty)
              pw.Text('No payables in this date range.',
                  style: pw.TextStyle(color: PdfColors.grey700))
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
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableHeaderCell('Contact'),
                      _buildTableHeaderCell('Amount'),
                      _buildTableHeaderCell('Date'),
                      _buildTableHeaderCell('Status'),
                      _buildTableHeaderCell('Description'),
                    ],
                  ),
                  ...payablesWithContacts.map((item) {
                    final p = item.payable;
                    final contactColor = item.contact != null
                        ? getContactPdfColor(item.contact!.name)
                        : PdfColors.grey600;
                    return pw.TableRow(
                      children: [
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
                                        child: pw.Text(
                                          item.contact!.name,
                                          style:
                                              const pw.TextStyle(fontSize: 9),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  )
                                : pw.Text('-',
                                    style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                '$currency ${p.amount.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color: ExportService.getPayablePdfColor())),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(dateFormat.format(p.date),
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(p.status,
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                              p.description ?? '-',
                              style: const pw.TextStyle(fontSize: 9),
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            pw.SizedBox(height: 30),

            // Receivables Section
            pw.Header(
              level: 1,
              child: pw.Text('Receivables',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            if (receivablesWithContacts.isEmpty)
              pw.Text('No receivables in this date range.',
                  style: pw.TextStyle(color: PdfColors.grey700))
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
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableHeaderCell('Contact'),
                      _buildTableHeaderCell('Amount'),
                      _buildTableHeaderCell('Date'),
                      _buildTableHeaderCell('Status'),
                      _buildTableHeaderCell('Description'),
                    ],
                  ),
                  ...receivablesWithContacts.map((item) {
                    final r = item.receivable;
                    final contactColor = item.contact != null
                        ? getContactPdfColor(item.contact!.name)
                        : PdfColors.grey600;
                    return pw.TableRow(
                      children: [
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
                                        child: pw.Text(
                                          item.contact!.name,
                                          style:
                                              const pw.TextStyle(fontSize: 9),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  )
                                : pw.Text('-',
                                    style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
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
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(dateFormat.format(r.date),
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(r.status,
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                              r.description ?? '-',
                              style: const pw.TextStyle(fontSize: 9),
                              maxLines: 2,
                            ),
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

    return pdf;
  }

  // Helper method to build category icon
  pw.Widget _buildCategoryIcon(
      String? iconCodePoint, PdfColor color, pw.Font? font) {
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

  // Helper methods for table cells
  pw.Widget _buildTableCell(String text, [String? value, PdfColor? color]) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
          if (value != null)
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: color)),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
    );
  }

  // Export transactions to PDF
  Future<Uint8List> exportTransactionsToPDF({
    required DateTime startDate,
    required DateTime endDate,
    String? currencySymbol,
  }) async {
    try {
      // Load Material Icons font
      final materialIconsFont = await loadMaterialIconsFont();

      final pdf = await generatePDFDocument(
        startDate: startDate,
        endDate: endDate,
        currencySymbol: currencySymbol,
        materialIconsFont: materialIconsFont,
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
  }) async {
    try {
      final pdfBytes = await exportTransactionsToPDF(
        startDate: startDate,
        endDate: endDate,
        currencySymbol: currencySymbol,
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
                  // Header row
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
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
                  ),
                  // Icon rows
                  ...allIconsInfo.map((iconInfo) {
                    final icon = iconInfo['icon'] as IconData;
                    final codepoint = iconInfo['codepoint'] as int;
                    final glyphCode = iconInfo['glyphCode'] as String;

                    return pw.TableRow(
                      children: [
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

        final result = await Share.shareXFiles([xFile]);

        if (result.status == ShareResultStatus.unavailable) {
          throw Exception('Sharing is not available on this device');
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
  }) async {
    try {
      // Load Material Icons font
      final materialIconsFont = await loadMaterialIconsFont();

      final pdf = await generateAnalyticsPDFDocument(
        startDate: startDate,
        endDate: endDate,
        currencySymbol: currencySymbol,
        materialIconsFont: materialIconsFont,
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
    final monthFormat = AppDateFormatter.getFormatter('MMM yyyy');

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
      return PdfColor(
          color.red / 255.0, color.green / 255.0, color.blue / 255.0);
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

    // Capture this for use in closure
    final self = this;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'FlowPaisa Analytics Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor(
                          0 / 255.0, 212 / 255.0, 255 / 255.0), // brightCyan
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated on: ${dateTimeFormat.format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'Date Range: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Financial Summary
            pw.Header(
              level: 1,
              child: pw.Text('Financial Summary',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  children: [
                    _buildTableCell(
                        'Payable (Selected Period)',
                        '$currency ${financialSummary.totalPayable.toStringAsFixed(2)}',
                        ExportService.getPayablePdfColor()),
                    _buildTableCell(
                        'Payable (All Time)',
                        '$currency ${allTimeFinancialSummary.totalPayable.toStringAsFixed(2)}',
                        ExportService.getPayablePdfColor()),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell(
                        'Receivable (Selected Period)',
                        '$currency ${financialSummary.totalReceivable.toStringAsFixed(2)}',
                        ExportService.getReceivablePdfColor()),
                    _buildTableCell(
                        'Receivable (All Time)',
                        '$currency ${allTimeFinancialSummary.totalReceivable.toStringAsFixed(2)}',
                        ExportService.getReceivablePdfColor()),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell(
                        'Expenses (Selected Period)',
                        '$currency ${financialSummary.totalExpense.toStringAsFixed(2)}',
                        ExportService.getExpensePdfColor()),
                    _buildTableCell(
                        'Expenses (All Time)',
                        '$currency ${allTimeFinancialSummary.totalExpense.toStringAsFixed(2)}',
                        ExportService.getExpensePdfColor()),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell(
                        'Income (Selected Period)',
                        '$currency ${financialSummary.totalIncome.toStringAsFixed(2)}',
                        ExportService.getIncomePdfColor()),
                    _buildTableCell(
                        'Income (All Time)',
                        '$currency ${allTimeFinancialSummary.totalIncome.toStringAsFixed(2)}',
                        ExportService.getIncomePdfColor()),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell(
                        'Net Balance (Selected Period)',
                        '$currency ${financialSummary.netBalance.toStringAsFixed(2)}',
                        financialSummary.netBalance == 0
                            ? PdfColors.black
                            : financialSummary.netBalance >= 0
                                ? ExportService.getIncomePdfColor()
                                : ExportService.getExpensePdfColor()),
                    _buildTableCell(
                        'Net Balance (All Time)',
                        '$currency ${allTimeFinancialSummary.netBalance.toStringAsFixed(2)}',
                        allTimeFinancialSummary.netBalance == 0
                            ? PdfColors.black
                            : allTimeFinancialSummary.netBalance >= 0
                                ? ExportService.getIncomePdfColor()
                                : ExportService.getExpensePdfColor()),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Contact Summaries
            if (contactSummaries.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text('Contact Summaries',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
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
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableHeaderCell('Contact'),
                      _buildTableHeaderCell('Total Payable'),
                      _buildTableHeaderCell('Total Receivable'),
                      _buildTableHeaderCell('Balance'),
                    ],
                  ),
                  ...contactSummaries.map((summary) {
                    final contactColor =
                        getContactPdfColor(summary.contact.name);
                    final balanceColor = summary.balance == 0
                        ? PdfColors.black
                        : summary.balance >= 0
                            ? ExportService.getReceivablePdfColor()
                            : ExportService.getPayablePdfColor();
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Row(
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
                                      getInitials(summary.contact.name),
                                      style: pw.TextStyle(
                                          fontSize: 6, color: PdfColors.white),
                                    ),
                                  ),
                                ),
                                pw.SizedBox(width: 4),
                                pw.Expanded(
                                  child: pw.Text(
                                    summary.contact.name,
                                    style: const pw.TextStyle(fontSize: 9),
                                    maxLines: 1,
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
                            child: pw.Text(
                                '$currency ${summary.totalPayable.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color: ExportService.getPayablePdfColor())),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                '$currency ${summary.totalReceivable.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color:
                                        ExportService.getReceivablePdfColor())),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                '$currency ${summary.balance.abs().toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9, color: balanceColor)),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 30),
            ],

            // Expenses by Category
            if (expensesByCategory.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text('Expenses by Category',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              // Visual chart representation
              self._buildVisualCategoryChart(expensesByCategory, currency,
                  hexToPdfColor, ExportService.getExpensePdfColor(),
                  self: self),
              pw.SizedBox(height: 10),
              // Data table
              self._buildCategoryTable(
                  expensesByCategory,
                  currency,
                  hexToPdfColor,
                  materialIconsFont,
                  ExportService.getExpensePdfColor(),
                  self: self),
              pw.SizedBox(height: 30),
            ],

            // Income by Category
            if (incomeByCategory.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text('Income by Category',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              // Visual chart representation
              self._buildVisualCategoryChart(incomeByCategory, currency,
                  hexToPdfColor, ExportService.getIncomePdfColor(),
                  self: self),
              pw.SizedBox(height: 10),
              // Data table
              self._buildCategoryTable(
                  incomeByCategory,
                  currency,
                  hexToPdfColor,
                  materialIconsFont,
                  ExportService.getIncomePdfColor(),
                  self: self),
              pw.SizedBox(height: 30),
            ],

            // Monthly Trends
            if (monthlyTrends.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text('Monthly Trends (Last 6 Months)',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              // Visual bar chart representation
              self._buildVisualBarChart(monthlyTrends, currency, self: self),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FixedColumnWidth(120),
                  2: const pw.FixedColumnWidth(120),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableHeaderCell('Month'),
                      _buildTableHeaderCell('Income'),
                      _buildTableHeaderCell('Expense'),
                    ],
                  ),
                  ...monthlyTrends.map((trend) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(monthFormat.format(trend.month),
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                '$currency ${trend.income.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color: ExportService.getIncomePdfColor())),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                '$currency ${trend.expense.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color: ExportService.getExpensePdfColor())),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 30),
            ],

            // Payable/Receivable Trends
            if (payableReceivableTrends.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text('Payable/Receivable Trends (Last 6 Months)',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              // Visual bar chart representation
              self._buildVisualPayableReceivableChart(
                  payableReceivableTrends, currency,
                  self: self),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FixedColumnWidth(120),
                  2: const pw.FixedColumnWidth(120),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableHeaderCell('Month'),
                      _buildTableHeaderCell('Payable'),
                      _buildTableHeaderCell('Receivable'),
                    ],
                  ),
                  ...payableReceivableTrends.map((trend) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(monthFormat.format(trend.month),
                                style: const pw.TextStyle(fontSize: 9)),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                '$currency ${trend.totalPayable.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color: ExportService.getPayablePdfColor())),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                                '$currency ${trend.totalReceivable.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9,
                                    color:
                                        ExportService.getReceivablePdfColor())),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 30),
            ],

            // Top Contacts by Balance
            if (topContacts.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text('Top Contacts by Balance',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FixedColumnWidth(120),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableHeaderCell('Contact'),
                      _buildTableHeaderCell('Balance'),
                    ],
                  ),
                  ...topContacts.map((contact) {
                    final contactColor =
                        getContactPdfColor(contact.contact.name);
                    final balanceColor = contact.balance == 0
                        ? PdfColors.black
                        : contact.balance >= 0
                            ? ExportService.getReceivablePdfColor()
                            : ExportService.getPayablePdfColor();
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Row(
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
                                      getInitials(contact.contact.name),
                                      style: pw.TextStyle(
                                          fontSize: 6, color: PdfColors.white),
                                    ),
                                  ),
                                ),
                                pw.SizedBox(width: 4),
                                pw.Expanded(
                                  child: pw.Text(
                                    contact.contact.name,
                                    style: const pw.TextStyle(fontSize: 9),
                                    maxLines: 1,
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
                            child: pw.Text(
                                '$currency ${contact.balance.abs().toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 9, color: balanceColor)),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 30),
            ],

            // Payment Status Distribution
            pw.Header(
              level: 1,
              child: pw.Text('Payment Status Distribution',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FixedColumnWidth(120),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildTableHeaderCell('Status'),
                    _buildTableHeaderCell('Amount'),
                  ],
                ),
                if (statusDistribution.pendingPayables > 0)
                  _buildStatusRow(
                      'Payables - Pending',
                      statusDistribution.pendingPayables,
                      Colors.orange,
                      currency),
                if (statusDistribution.paidPayables > 0)
                  _buildStatusRow('Payables - Paid',
                      statusDistribution.paidPayables, Colors.green, currency),
                if (statusDistribution.cancelledPayables > 0)
                  _buildStatusRow(
                      'Payables - Cancelled',
                      statusDistribution.cancelledPayables,
                      Colors.grey,
                      currency),
                if (statusDistribution.pendingReceivables > 0)
                  _buildStatusRow(
                      'Receivables - Pending',
                      statusDistribution.pendingReceivables,
                      Colors.orange,
                      currency),
                if (statusDistribution.receivedReceivables > 0)
                  _buildStatusRow(
                      'Receivables - Received',
                      statusDistribution.receivedReceivables,
                      Colors.green,
                      currency),
                if (statusDistribution.cancelledReceivables > 0)
                  _buildStatusRow(
                      'Receivables - Cancelled',
                      statusDistribution.cancelledReceivables,
                      Colors.grey,
                      currency),
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
      {ExportService? self}) {
    final service = self ?? this;
    double total = 0;
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
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableHeaderCell('Category'),
            _buildTableHeaderCell('Percentage'),
            _buildTableHeaderCell('Amount'),
          ],
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

          return pw.TableRow(
            children: [
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
                        child: pw.Text(
                          category.name,
                          style: const pw.TextStyle(fontSize: 9),
                          maxLines: 1,
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
                  child: pw.Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: pw.TextStyle(fontSize: 9, color: categoryColor),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    '$currency ${amount.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 9, color: categoryColor),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  // Helper method to build status row
  pw.TableRow _buildStatusRow(
      String label, double amount, Color color, String currency) {
    final pdfColor =
        PdfColor(color.red / 255.0, color.green / 255.0, color.blue / 255.0);
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Container(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 9)),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Container(
            alignment: pw.Alignment.centerLeft,
            child: pw.Text('$currency ${amount.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 9, color: pdfColor)),
          ),
        ),
      ],
    );
  }

  // Helper method to build visual category chart (horizontal bars)
  pw.Widget _buildVisualCategoryChart(List<dynamic> categories, String currency,
      PdfColor Function(String) hexToPdfColor, PdfColor defaultColor,
      {ExportService? self}) {
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

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Top Categories (Visual)',
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
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
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          category.name,
                          style: const pw.TextStyle(fontSize: 8),
                          maxLines: 1,
                        ),
                      ),
                      pw.Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: pw.TextStyle(fontSize: 8, color: categoryColor),
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
      {ExportService? self}) {
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

    final monthFormat = AppDateFormatter.getFormatter('MMM');

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Income vs Expense Trend (Visual)',
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          ...trends.asMap().entries.map((entry) {
            final trend = entry.value;
            final incomeBar = maxValue > 0 ? (trend.income / maxValue) : 0.0;
            final expenseBar = maxValue > 0 ? (trend.expense / maxValue) : 0.0;
            final monthLabel = monthFormat.format(trend.month);

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    monthLabel,
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  // Income bar
                  pw.Row(
                    children: [
                      pw.Text('I:', style: const pw.TextStyle(fontSize: 7)),
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
                      pw.Text(
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
                    children: [
                      pw.Text('E:', style: const pw.TextStyle(fontSize: 7)),
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
                      pw.Text(
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
      {ExportService? self}) {
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

    final monthFormat = AppDateFormatter.getFormatter('MMM');

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Payable vs Receivable Trend (Visual)',
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          ...trends.asMap().entries.map((entry) {
            final trend = entry.value;
            final payableBar =
                maxValue > 0 ? (trend.totalPayable / maxValue) : 0.0;
            final receivableBar =
                maxValue > 0 ? (trend.totalReceivable / maxValue) : 0.0;
            final monthLabel = monthFormat.format(trend.month);

            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    monthLabel,
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  // Payable bar
                  pw.Row(
                    children: [
                      pw.Text('P:', style: const pw.TextStyle(fontSize: 7)),
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
                      pw.Text(
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
                    children: [
                      pw.Text('R:', style: const pw.TextStyle(fontSize: 7)),
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
                      pw.Text(
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
