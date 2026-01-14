import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flowpaisa/core/utils/native_share.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:drift/drift.dart' as drift;

class ExportService {
  final TransactionsRepository _transactionsRepository;
  final AppDatabase _database;
  static pw.Font? _cachedFont;

  ExportService(this._transactionsRepository, this._database);

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
        if (t.type == 'EXPENSE' && t.linkedPayableId != null) {
          if (item.linkedPayable?.status != 'PAID') {
            include = false;
          }
        }

        // Exclude "Will Receive" incomes (linked Receivable) that are 'PENDING'
        if (t.type == 'INCOME' && t.linkedReceivableId != null) {
          if (item.linkedReceivable?.status != 'RECEIVED') {
            include = false;
          }
        }

        if (!include) {
          continue;
        }
        csvData.add([
          DateFormat('dd/MM/yyyy').format(t.date),
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
          'flowpaisa_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
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
      if (t.type == 'EXPENSE' && t.linkedPayableId != null) {
        if (item.linkedPayable?.status != 'PAID') {
          return false;
        }
      }
      if (t.type == 'INCOME' && t.linkedReceivableId != null) {
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
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');

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

    // Helper function to build category icon using pw.Icon widget
    pw.Widget _buildCategoryIcon(
        String? iconCodePoint, PdfColor color, pw.Font? font) {
      // Try to parse icon codePoint and render with Material Icons font
      if (font != null && iconCodePoint != null && iconCodePoint.isNotEmpty) {
        final codePoint = int.tryParse(iconCodePoint);
        if (codePoint != null) {
          // Material Icons use private Unicode range 0xe000-0xefff
          // Validate codePoint is in valid range
          if (codePoint >= 0xe000 && codePoint <= 0xefff) {
            // Use pw.Icon widget with pw.IconData for better icon rendering
            return pw.Icon(
              pw.IconData(codePoint),
              font: font,
              size: 12,
              color: color,
            );
          }
        }
      }
      // Fallback to colored circle if font is not available or codePoint is invalid
      return pw.Container(
        width: 12,
        height: 12,
        decoration: pw.BoxDecoration(
          color: color,
          shape: pw.BoxShape.circle,
        ),
      );
    }

    // Add pages
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
                    _buildTableCell('Total Income',
                        '$currency ${totalIncome.toStringAsFixed(2)}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Total Expense',
                        '$currency ${totalExpense.toStringAsFixed(2)}'),
                    _buildTableCell('Net Balance',
                        '$currency ${(totalIncome - totalExpense).toStringAsFixed(2)}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Payables (Pending)',
                        '$currency ${totalPayablePending.toStringAsFixed(2)}'),
                    _buildTableCell('Payables (Paid)',
                        '$currency ${totalPayablePaid.toStringAsFixed(2)}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _buildTableCell('Receivables (Pending)',
                        '$currency ${totalReceivablePending.toStringAsFixed(2)}'),
                    _buildTableCell('Receivables (Received)',
                        '$currency ${totalReceivableReceived.toStringAsFixed(2)}'),
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
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(dateFormat.format(t.date),
                              style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(t.type,
                              style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                              '$currency ${t.amount.toStringAsFixed(2)}',
                              style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Row(
                            children: [
                              _buildCategoryIcon(
                                item.category?.icon,
                                categoryColor,
                                materialIconsFont,
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
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: item.contact != null
                              ? pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 16,
                                      height: 16,
                                      decoration: pw.BoxDecoration(
                                        color: contactColor,
                                        shape: pw.BoxShape.circle,
                                      ),
                                      child: pw.Center(
                                        child: pw.Text(
                                          getInitials(item.contact!.name),
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              color: PdfColors.white),
                                        ),
                                      ),
                                    ),
                                    pw.SizedBox(width: 4),
                                    pw.Expanded(
                                      child: pw.Text(
                                        item.contact!.name,
                                        style: const pw.TextStyle(fontSize: 9),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                )
                              : pw.Text('-',
                                  style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            t.description ?? '-',
                            style: const pw.TextStyle(fontSize: 9),
                            maxLines: 2,
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
                          child: item.contact != null
                              ? pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 16,
                                      height: 16,
                                      decoration: pw.BoxDecoration(
                                        color: contactColor,
                                        shape: pw.BoxShape.circle,
                                      ),
                                      child: pw.Center(
                                        child: pw.Text(
                                          getInitials(item.contact!.name),
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              color: PdfColors.white),
                                        ),
                                      ),
                                    ),
                                    pw.SizedBox(width: 4),
                                    pw.Expanded(
                                      child: pw.Text(
                                        item.contact!.name,
                                        style: const pw.TextStyle(fontSize: 9),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                )
                              : pw.Text('-',
                                  style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                              '$currency ${p.amount.toStringAsFixed(2)}',
                              style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(dateFormat.format(p.date),
                              style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(p.status,
                              style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            p.description ?? '-',
                            style: const pw.TextStyle(fontSize: 9),
                            maxLines: 2,
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
                          child: item.contact != null
                              ? pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 16,
                                      height: 16,
                                      decoration: pw.BoxDecoration(
                                        color: contactColor,
                                        shape: pw.BoxShape.circle,
                                      ),
                                      child: pw.Center(
                                        child: pw.Text(
                                          getInitials(item.contact!.name),
                                          style: pw.TextStyle(
                                              fontSize: 8,
                                              color: PdfColors.white),
                                        ),
                                      ),
                                    ),
                                    pw.SizedBox(width: 4),
                                    pw.Expanded(
                                      child: pw.Text(
                                        item.contact!.name,
                                        style: const pw.TextStyle(fontSize: 9),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                )
                              : pw.Text('-',
                                  style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                              '$currency ${r.amount.toStringAsFixed(2)}',
                              style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(dateFormat.format(r.date),
                              style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(r.status,
                              style: const pw.TextStyle(fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            r.description ?? '-',
                            style: const pw.TextStyle(fontSize: 9),
                            maxLines: 2,
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

  // Helper methods for table cells
  pw.Widget _buildTableCell(String text, [String? value]) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
          if (value != null)
            pw.Text(value,
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
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
          'flowpaisa_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      return file.path;
    } catch (e) {
      throw Exception('Error saving PDF: $e');
    }
  }

  // Test PDF: Generate a PDF with all categories showing names, icons, and codePoint values
  Future<Uint8List> generateTestCategoriesPDF() async {
    try {
      // Load Material Icons font
      final materialIconsFont = await loadMaterialIconsFont();

      // Fetch all categories
      final categories = await (_database.select(_database.categories)
            ..where((c) => c.isDeleted.equals(false))
            ..orderBy([(c) => drift.OrderingTerm.asc(c.name)]))
          .get();

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

      // Helper function to build category icon
      pw.Widget buildCategoryIcon(
          String? iconCodePoint, PdfColor color, pw.Font? font) {
        if (font != null && iconCodePoint != null && iconCodePoint.isNotEmpty) {
          final codePoint = int.tryParse(iconCodePoint);
          if (codePoint != null) {
            if (codePoint >= 0xe000 && codePoint <= 0xefff) {
              return pw.Icon(
                pw.IconData(codePoint),
                font: font,
                size: 20,
                color: color,
              );
            }
          }
        }
        // Fallback to colored circle
        return pw.Container(
          width: 20,
          height: 20,
          decoration: pw.BoxDecoration(
            color: color,
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
                  'Categories Test - Icons with CodePoints',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Categories Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
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
                          'Name',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Type',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'CodePoint',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Category rows
                  ...categories.map((category) {
                    final categoryColor = category.color != null
                        ? hexToPdfColor(category.color!)
                        : PdfColors.grey600;

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Center(
                            child: buildCategoryIcon(
                              category.icon,
                              categoryColor,
                              materialIconsFont,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(category.name),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(category.type),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            category.icon ?? 'null',
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
