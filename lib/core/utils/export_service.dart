import 'package:flowpaisa/core/utils/tabular_parser.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/data/accounts_repository.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flowpaisa/core/utils/native_share.dart';
import 'package:path/path.dart' as p;
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/features/analytics/data/analytics_repository.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:intl/intl.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';

class ExportService {
  final TransactionsRepository _transactionsRepository;
  final AppDatabase _database;
  final String _dateFormat;
  static pw.Font? _cachedFont;
  static pw.Font? _unicodeFont;
  static pw.Font? _unicodeFontBold;
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
  String _getLocalizedType(String type, AppLocalizations? l10n) {
    if (l10n == null) {
      if (type == 'INCOME') return 'Income';
      if (type == 'EXPENSE') return 'Expense';
      return type;
    }
    if (type == 'INCOME') return l10n.income;
    if (type == 'EXPENSE') return l10n.expense;
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

  /// Payment status label for export (Receivable/Payable/Paid/Received).
  /// When l10n is null, returns English fallbacks.
  String _getPaymentStatusLabel(
      {Payable? linkedPayable,
      Receivable? linkedReceivable,
      AppLocalizations? l10n}) {
    if (linkedPayable != null) {
      return linkedPayable.status == 'PAID'
          ? (l10n?.paidPayable ?? 'Paid')
          : (l10n?.pendingPayable ?? 'Payable (Pending)');
    }
    if (linkedReceivable != null) {
      return linkedReceivable.status == 'RECEIVED'
          ? (l10n?.receivedPayment ?? 'Received')
          : (l10n?.pendingReceivable ?? 'Receivable (Pending)');
    }
    return '—';
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
      try {
        _unicodeFontBold = await PdfGoogleFonts.amiriBold();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error loading Arabic bold font: $e');
        }
      }
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
    AppLocalizations? l10n,
    TransactionFilters? filters,
    String? searchQuery,
    AppCurrency? currency,
    bool includePayablesAndReceivables = true,
  }) async {
    try {
      // Get transactions in date range with details or using filters
      final List<TransactionWithDetails> transactionsWithDetails;
      if (filters != null) {
        transactionsWithDetails = await _transactionsRepository
            .getTransactionsWithDetailsFilteredPaginated(
          filters: filters,
          searchQuery: searchQuery,
          limit: 1000000,
        );
      } else {
        transactionsWithDetails = await _transactionsRepository
            .getTransactionsWithDetailsByDateRange(startDate, endDate);
      }

      final statusHeader = l10n?.status ?? 'Status';

      // Create CSV data
      List<List<dynamic>> csvData = [
        // Header row
        [
          'Date',
          'Type',
          'Amount',
          'Category',
          'Contact',
          'Description',
          statusHeader,
        ],
      ];

      final scaleFactor = currency?.scaleFactor ?? 1.0;
      final divisor = scaleFactor != 0 ? scaleFactor : 1.0;

      // Add transaction rows
      for (var item in transactionsWithDetails) {
        final t = item.transaction;

        // Filter out inactive transactions (unsettled linked entries)
        bool include = true;

        if (!includePayablesAndReceivables &&
            (t.linkedPayableUuid != null || t.linkedReceivableUuid != null)) {
          include = false;
        }

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
        final paymentStatus = _getPaymentStatusLabel(
          linkedPayable: item.linkedPayable,
          linkedReceivable: item.linkedReceivable,
          l10n: l10n,
        );
        final scaledAmount = t.amount / divisor;

        // If description is tabular (itemized), extract only the summary text
        String cleanDescription = t.description ?? '';
        if (TabularParser.isTabular(cleanDescription)) {
          cleanDescription = TabularParser.parse(cleanDescription).$1;
        }

        csvData.add([
          AppDateFormatter.formatDate(t.date, pattern: _dateFormat),
          t.type,
          scaledAmount.toStringAsFixed(currency?.decimalPlaces ?? 2),
          item.category?.name ?? '', // Use name instead of ID
          item.contact?.name ?? '', // Use name instead of ID
          cleanDescription,
          paymentStatus,
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
    TransactionFilters? filters,
    String? searchQuery,
    AppCurrency? currency,
    bool includePayablesAndReceivables = true,
  }) async {
    try {
      final csvString = await generateCSVContent(
        startDate: startDate,
        endDate: endDate,
        filters: filters,
        searchQuery: searchQuery,
        currency: currency,
        includePayablesAndReceivables: includePayablesAndReceivables,
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

  // Generate export summary (same logic as PDF/CSV: only include settled
  // linked transactions and count/sum from that filtered set)
  Future<ExportSummary> getExportSummary({
    required DateTime startDate,
    required DateTime endDate,
    TransactionFilters? filters,
    String? searchQuery,
  }) async {
    final List<TransactionWithDetails> transactionsWithDetails;
    if (filters != null) {
      transactionsWithDetails = await _transactionsRepository
          .getTransactionsWithDetailsFilteredPaginated(
        filters: filters,
        searchQuery: searchQuery,
        limit: 1000000,
      );
    } else {
      transactionsWithDetails = await _transactionsRepository
          .getTransactionsWithDetailsByDateRange(startDate, endDate);
    }

    // Same filter as PDF and CSV: exclude expense linked to non-PAID payable,
    // and income linked to non-RECEIVED receivable
    final filtered = transactionsWithDetails.where((item) {
      final t = item.transaction;
      if (t.type == 'EXPENSE' && t.linkedPayableUuid != null) {
        if (item.linkedPayable?.status != 'PAID') return false;
      }
      if (t.type == 'INCOME' && t.linkedReceivableUuid != null) {
        if (item.linkedReceivable?.status != 'RECEIVED') return false;
      }
      return true;
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    int incomeCount = 0;
    int expenseCount = 0;

    for (var item in filtered) {
      final t = item.transaction;
      if (t.type == 'INCOME') {
        totalIncome += t.amount;
        incomeCount++;
      } else {
        totalExpense += t.amount;
        expenseCount++;
      }
    }

    return ExportSummary(
      startDate: startDate,
      endDate: endDate,
      totalTransactions: filtered.length,
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
    int decimalPlaces = 2,
    pw.Font? materialIconsFont,
    pw.Font? unicodeFont,
    pw.Font? hindiFont,
    pw.Font? englishFont,
    AppLocalizations? l10n,
    TransactionFilters? filters,
    String? searchQuery,
    AppCurrency? currencyObj,
    bool includePayablesAndReceivables = true,
  }) async {
    String? logoSvgString;
    try {
      logoSvgString =
          await rootBundle.loadString('assets/images/logo_square.svg');
    } catch (e) {
      if (kDebugMode) {
        print('ExportService: Failed to load logo SVG: $e');
      }
    }

    final payablesRepository = PayablesRepository(_database);
    final receivablesRepository = ReceivablesRepository(_database);

    // Fetch all data
    final List<TransactionWithDetails> transactionsWithDetails;
    if (filters != null) {
      transactionsWithDetails = await _transactionsRepository
          .getTransactionsWithDetailsFilteredPaginated(
        filters: filters,
        searchQuery: searchQuery,
        limit: 1000000,
      );
    } else {
      transactionsWithDetails = await _transactionsRepository
          .getTransactionsWithDetailsByDateRange(startDate, endDate);
    }
    var payablesWithContacts = await payablesRepository
        .getPayablesWithContactsByDateRange(startDate, endDate);
    var receivablesWithContacts = await receivablesRepository
        .getReceivablesWithContactsByDateRange(startDate, endDate);

    if (!includePayablesAndReceivables) {
      payablesWithContacts = [];
      receivablesWithContacts = [];
    }

    // Apply filters to payables and receivables to match screen/UI behavior
    if (filters != null) {
      // 1. If category filter is applied, filter payables/receivables that are linked to transactions of those categories
      if (filters.categoryUuids != null && filters.categoryUuids!.isNotEmpty) {
        payablesWithContacts = payablesWithContacts.where((p) {
          final isLinkedExpenseMatch = p.payable.linkedExpenseUuid != null && 
              transactionsWithDetails.any((t) => t.transaction.uuid == p.payable.linkedExpenseUuid);
          final isLinkedIncomeMatch = p.payable.linkedIncomeUuid != null && 
              transactionsWithDetails.any((t) => t.transaction.uuid == p.payable.linkedIncomeUuid);
          return isLinkedExpenseMatch || isLinkedIncomeMatch;
        }).toList();

        receivablesWithContacts = receivablesWithContacts.where((r) {
          final isLinkedExpenseMatch = r.receivable.linkedExpenseUuid != null && 
              transactionsWithDetails.any((t) => t.transaction.uuid == r.receivable.linkedExpenseUuid);
          final isLinkedIncomeMatch = r.receivable.linkedIncomeUuid != null && 
              transactionsWithDetails.any((t) => t.transaction.uuid == r.receivable.linkedIncomeUuid);
          return isLinkedExpenseMatch || isLinkedIncomeMatch;
        }).toList();
      }

      // 2. If contact filter is applied
      if (filters.contactUuids != null && filters.contactUuids!.isNotEmpty) {
        payablesWithContacts = payablesWithContacts
            .where((p) => filters.contactUuids!.contains(p.contact?.uuid))
            .toList();
        receivablesWithContacts = receivablesWithContacts
            .where((r) => filters.contactUuids!.contains(r.contact?.uuid))
            .toList();
      }

      // 3. If account filter is applied, payables/receivables are zero/empty on UI
      if (filters.accountUuids != null && filters.accountUuids!.isNotEmpty) {
        payablesWithContacts = [];
        receivablesWithContacts = [];
      }

      // 4. If transaction type filter is active, filter out based on type
      if (filters.type != null && filters.type!.isNotEmpty) {
        if (filters.type == 'INCOME') {
          // If filtering by Income, payables are zero
          payablesWithContacts = [];
        } else if (filters.type == 'EXPENSE') {
          // If filtering by Expense, receivables are zero
          receivablesWithContacts = [];
        }
      }

      // 5. If amount filter is active (minAmount or maxAmount), match the due/pending amounts of payables/receivables
      if (filters.minAmount != null) {
        payablesWithContacts = payablesWithContacts
            .where((p) => p.payable.amount >= filters.minAmount!)
            .toList();
        receivablesWithContacts = receivablesWithContacts
            .where((r) => r.receivable.amount >= filters.minAmount!)
            .toList();
      }
      if (filters.maxAmount != null) {
        payablesWithContacts = payablesWithContacts
            .where((p) => p.payable.amount <= filters.maxAmount!)
            .toList();
        receivablesWithContacts = receivablesWithContacts
            .where((r) => r.receivable.amount <= filters.maxAmount!)
            .toList();
      }

      // 6. If status/relationships filters are active
      if (filters.statusCodes != null && filters.statusCodes!.isNotEmpty) {
        final hasPayableStatus = filters.statusCodes!.contains('PAYABLE');
        final hasReceivableStatus = filters.statusCodes!.contains('RECEIVABLE');
        
        if (!hasPayableStatus) {
          payablesWithContacts = [];
        }
        if (!hasReceivableStatus) {
          receivablesWithContacts = [];
        }
      }
    }

    String? accountNames;
    if (filters != null &&
        filters.accountUuids != null &&
        filters.accountUuids!.isNotEmpty) {
      final accounts = await (_database.select(_database.accounts)
            ..where((t) => t.uuid.isIn(filters.accountUuids!)))
          .get();
      accountNames = accounts.map((a) => a.name).join(', ');
    }

    String? categoryNames;
    if (filters != null &&
        filters.categoryUuids != null &&
        filters.categoryUuids!.isNotEmpty) {
      final categories = await (_database.select(_database.categories)
            ..where((t) => t.uuid.isIn(filters.categoryUuids!)))
          .get();
      categoryNames = categories
          .map((c) => _getLocalizedCategoryName(c.name, l10n))
          .join(', ');
    }

    String? contactNames;
    if (filters != null &&
        filters.contactUuids != null &&
        filters.contactUuids!.isNotEmpty) {
      final contacts = await (_database.select(_database.contacts)
            ..where((t) => t.uuid.isIn(filters.contactUuids!)))
          .get();
      contactNames = contacts.map((c) => c.name).join(', ');
    }

    final List<pw.TableRow> filterRows = [];
    final isRtl = l10n?.localeName == 'ur' || l10n?.localeName == 'ar';

    if (accountNames != null) {
      filterRows.add(
        _buildLocalizedTableRow(
          [
            _buildText(
              l10n?.account ?? 'Account',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
            ),
            _buildText(':',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            _buildText(
              accountNames,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
            ),
          ],
          l10n: l10n,
        ),
      );
    }

    if (categoryNames != null) {
      filterRows.add(
        _buildLocalizedTableRow(
          [
            _buildText(
              l10n?.category ?? 'Category',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
            ),
            _buildText(':',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            _buildText(
              categoryNames,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
            ),
          ],
          l10n: l10n,
        ),
      );
    }

    if (contactNames != null) {
      filterRows.add(
        _buildLocalizedTableRow(
          [
            _buildText(
              l10n?.contact ?? 'Contact',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
            ),
            _buildText(':',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            _buildText(
              contactNames,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
            ),
          ],
          l10n: l10n,
        ),
      );
    }

    if (filters?.type != null) {
      final typeLabel = filters!.type == 'INCOME'
          ? (l10n?.income ?? 'Income')
          : (l10n?.expense ?? 'Expense');
      filterRows.add(
        _buildLocalizedTableRow(
          [
            _buildText(
              l10n?.type ?? 'Type',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
            ),
            _buildText(':',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            _buildText(
              typeLabel,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
            ),
          ],
          l10n: l10n,
        ),
      );
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filterRows.add(
        _buildLocalizedTableRow(
          [
            _buildText(
              l10n?.search ?? 'Search',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
            ),
            _buildText(':',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            _buildText(
              searchQuery,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.black,
              ),
              align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
            ),
          ],
          l10n: l10n,
        ),
      );
    }

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
    String fmt(num amount) {
      if (currencyObj != null) {
        return AmountFormatter.formatWithCurrency(
            amount.toDouble(), currencyObj);
      }
      return AmountFormatter.formatWithCurrency(
          amount.toDouble(), currency, decimalPlaces);
    }

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

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      theme: theme,
      buildBackground: logoSvgString != null
          ? (pw.Context context) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Center(
                  child: pw.Opacity(
                    opacity: 0.03,
                    child: pw.Container(
                      width: 250,
                      height: 250,
                      child: pw.SvgImage(
                        svg: logoSvgString!,
                        colorFilter: const PdfColor(0 / 255.0, 102 / 255.0,
                            153 / 255.0), // #006699 (Deep Brand Blue)
                      ),
                    ),
                  ),
                ),
              );
            }
          : null,
    );

    // Add pages
    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        footer: (pw.Context context) {
          final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);
          final pageText = 'Page ${context.pageNumber} / ${context.pagesCount}';
          final appTitle = l10n?.appTitle ?? 'Flowpaisa';

          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            padding: const pw.EdgeInsets.only(top: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: isRtl
                  ? [
                      _buildText(
                        pageText,
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 8,
                        ),
                      ),
                      pw.Row(
                        children: [
                          _buildText(
                            appTitle,
                            style: pw.TextStyle(
                              color: PdfColors.grey600,
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (logoSvgString != null) ...[
                            pw.SizedBox(width: 4),
                            pw.Container(
                              width: 12,
                              height: 12,
                              child: pw.SvgImage(
                                svg: logoSvgString,
                                colorFilter: const PdfColor(
                                    0 / 255.0,
                                    102 / 255.0,
                                    153 / 255.0), // #006699 (Deep Brand Blue)
                              ),
                            ),
                          ],
                        ],
                      ),
                    ]
                  : [
                      pw.Row(
                        children: [
                          if (logoSvgString != null) ...[
                            pw.Container(
                              width: 12,
                              height: 12,
                              child: pw.SvgImage(
                                svg: logoSvgString,
                                colorFilter: const PdfColor(
                                    0 / 255.0,
                                    102 / 255.0,
                                    153 / 255.0), // #006699 (Deep Brand Blue)
                              ),
                            ),
                            pw.SizedBox(width: 4),
                          ],
                          _buildText(
                            appTitle,
                            style: pw.TextStyle(
                              color: PdfColors.grey600,
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _buildText(
                        pageText,
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 8,
                        ),
                      ),
                    ],
            ),
          );
        },
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
                          : 'Flowpaisa Export Report',
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
                      ...filterRows,
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
                        fmt(totalIncome),
                        ExportService.getIncomePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        l10n?.expense ?? 'Total Expense',
                        fmt(totalExpense),
                        ExportService.getExpensePdfColor(),
                        l10n),
                    _buildTableCell(
                        l10n?.netBalance ?? 'Net Balance',
                        fmt(totalIncome - totalExpense),
                        (totalIncome - totalExpense) == 0
                            ? PdfColors.black
                            : (totalIncome - totalExpense) >= 0
                                ? ExportService.getIncomePdfColor()
                                : ExportService.getExpensePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                if (includePayablesAndReceivables) ...[
                  _buildLocalizedTableRow(
                    [
                      _buildTableCell(
                          '${l10n?.payables ?? 'Payables'} (${l10n?.pending ?? 'Pending'})',
                          fmt(totalPayablePending),
                          ExportService.getPayablePdfColor(),
                          l10n),
                      _buildTableCell(
                          '${l10n?.payables ?? 'Payables'} (${l10n?.paid ?? 'Paid'})',
                          fmt(totalPayablePaid),
                          ExportService.getPayablePdfColor(),
                          l10n),
                    ],
                    l10n: l10n,
                  ),
                  _buildLocalizedTableRow(
                    [
                      _buildTableCell(
                          '${l10n?.receivables ?? 'Receivables'} (${l10n?.pending ?? 'Pending'})',
                          fmt(totalReceivablePending),
                          ExportService.getReceivablePdfColor(),
                          l10n),
                      _buildTableCell(
                          '${l10n?.receivables ?? 'Receivables'} (${l10n?.receivedLabel ?? 'Received'})',
                          fmt(totalReceivableReceived),
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
                          fmt((totalPayablePending - totalReceivablePending)
                              .abs()),
                          (totalPayablePending - totalReceivablePending)
                                      .abs() ==
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
                columnWidths: isRtl
                    ? {
                        0: const pw.FixedColumnWidth(70), // Status
                        1: const pw.FlexColumnWidth(3), // Description
                        2: const pw.FlexColumnWidth(2.5), // Contact
                        3: const pw.FlexColumnWidth(2.5), // Category
                        4: const pw.FixedColumnWidth(80), // Amount
                        5: const pw.FixedColumnWidth(45), // Type
                        6: const pw.FixedColumnWidth(65), // Date
                      }
                    : {
                        0: const pw.FixedColumnWidth(65), // Date
                        1: const pw.FixedColumnWidth(45), // Type
                        2: const pw.FixedColumnWidth(80), // Amount
                        3: const pw.FlexColumnWidth(2.5), // Category
                        4: const pw.FlexColumnWidth(2.5), // Contact
                        5: const pw.FlexColumnWidth(3), // Description
                        6: const pw.FixedColumnWidth(70), // Status
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
                      _buildTableHeaderCell(l10n?.status ?? 'Status',
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
                            child: _buildText(_getLocalizedType(t.type, l10n),
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
                            child: _buildText(fmt(t.amount),
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
                            child: () {
                              String cleanDescription = t.description ?? '-';
                              if (TabularParser.isTabular(cleanDescription)) {
                                cleanDescription =
                                    TabularParser.parse(cleanDescription).$1;
                                if (cleanDescription.isEmpty) {
                                  cleanDescription = '-';
                                }
                              }
                              return _buildText(
                                cleanDescription,
                                style: const pw.TextStyle(fontSize: 9),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left,
                              );
                            }(),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                              _getPaymentStatusLabel(
                                linkedPayable: item.linkedPayable,
                                linkedReceivable: item.linkedReceivable,
                                l10n: l10n,
                              ),
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
                            child: _buildText(fmt(p.amount),
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
                            child: () {
                              String cleanDescription = p.description ?? '-';
                              if (TabularParser.isTabular(cleanDescription)) {
                                cleanDescription =
                                    TabularParser.parse(cleanDescription).$1;
                                if (cleanDescription.isEmpty) {
                                  cleanDescription = '-';
                                }
                              }
                              return _buildText(
                                cleanDescription,
                                style: const pw.TextStyle(fontSize: 9),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left,
                              );
                            }(),
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
                            child: _buildText(fmt(r.amount),
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
                            child: () {
                              String cleanDescription = r.description ?? '-';
                              if (TabularParser.isTabular(cleanDescription)) {
                                cleanDescription =
                                    TabularParser.parse(cleanDescription).$1;
                                if (cleanDescription.isEmpty) {
                                  cleanDescription = '-';
                                }
                              }
                              return _buildText(
                                cleanDescription,
                                style: const pw.TextStyle(fontSize: 9),
                                align: isRtl
                                    ? pw.TextAlign.right
                                    : pw.TextAlign.left,
                              );
                            }(),
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
          final isBold = style?.fontWeight == pw.FontWeight.bold;
          final fontToUse = isBold ? (_unicodeFontBold ?? _unicodeFont) : _unicodeFont;
          widgets.add(pw.Text(fixedRtl,
              style: style?.copyWith(font: fontToUse), textAlign: align));
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
    int decimalPlaces = 2,
    AppLocalizations? l10n,
    TransactionFilters? filters,
    String? searchQuery,
    AppCurrency? currency,
    bool includePayablesAndReceivables = true,
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
        decimalPlaces: decimalPlaces,
        materialIconsFont: materialIconsFont,
        unicodeFont: unicodeFont,
        hindiFont: hindiFont,
        englishFont: englishFont,
        l10n: l10n,
        filters: filters,
        searchQuery: searchQuery,
        currencyObj: currency,
        includePayablesAndReceivables: includePayablesAndReceivables,
      );
      return await pdf.save();
    } catch (e) {
      throw Exception('Error generating PDF: $e');
    }
  }

  // Save PDF to file
  Future<String> savePDFToFile({
    required DateTime startDate,
    required DateTime endDate,
    String? currencySymbol,
    int decimalPlaces = 2,
    bool useCache = false,
    AppLocalizations? l10n,
    TransactionFilters? filters,
    String? searchQuery,
    AppCurrency? currency,
    bool includePayablesAndReceivables = true,
  }) async {
    try {
      final pdfBytes = await exportTransactionsToPDF(
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

  // Generate PDF containing all transactions with attachments and their physical files
  Future<Uint8List> exportTransactionsWithAttachmentsToPDF({
    String? currencySymbol,
    int decimalPlaces = 2,
    AppLocalizations? l10n,
    AppCurrency? currencyObj,
    DateTime? startDate,
    DateTime? endDate,
    TransactionFilters? filters,
    String? searchQuery,
  }) async {
    try {
      // 1. Load fonts and logo
      final unicodeFont = await loadUnicodeFont();
      final hindiFont = await loadHindiFont();
      final englishFont = await loadEnglishFont();

      String? logoSvgString;
      try {
        logoSvgString =
            await rootBundle.loadString('assets/images/logo_square.svg');
      } catch (e) {
        if (kDebugMode) {
          print('ExportService: Failed to load logo SVG: $e');
        }
      }

      // Query the matching transactions using the centralized repository query
      final List<TransactionWithDetails> filteredTransactions;
      if (filters != null) {
        filteredTransactions = await _transactionsRepository
            .getTransactionsWithDetailsFilteredPaginated(
          filters: filters,
          searchQuery: searchQuery,
          limit: 1000000,
        );
      } else {
        final actualFilters = TransactionFilters(
          startDate: startDate,
          endDate: endDate,
        );
        filteredTransactions = await _transactionsRepository
            .getTransactionsWithDetailsFilteredPaginated(
          filters: actualFilters,
          searchQuery: searchQuery,
          limit: 1000000,
        );
      }

      final matchingTxUuids = filteredTransactions.map((tx) => tx.transaction.uuid).toSet();
      final txMap = {for (final tx in filteredTransactions) tx.transaction.uuid: tx};

      // 2. Fetch all active documents
      final documents = await (_database.select(_database.transactionDocuments)
            ..where((d) => d.isDeleted.equals(false)))
          .get();

      final appDir = await getApplicationDocumentsDirectory();
      final docDir = Directory(p.join(appDir.path, 'documents', _transactionsRepository.cashbookId));

      // Group by transactionUuid, only for matching transactions
      final Map<String, List<TransactionDocument>> groupedDocs = {};
      for (final doc in documents) {
        if (matchingTxUuids.contains(doc.transactionUuid)) {
          groupedDocs.putIfAbsent(doc.transactionUuid, () => []).add(doc);
        }
      }

      if (kDebugMode) {
        print('ExportService: Grouped documents by transactionUuid. Count: ${groupedDocs.length}');
      }

      // Construct transaction list with attachments cleanly and efficiently
      final List<
          ({
            TransactionWithDetails details,
            List<TransactionDocument> docs
          })> transactionsWithAttachments = [];
      for (final entry in groupedDocs.entries) {
        final details = txMap[entry.key];
        if (details != null) {
          transactionsWithAttachments.add((details: details, docs: entry.value));
        }
      }

      if (kDebugMode) {
        print('ExportService: Transactions with attachments after filtering. Count: ${transactionsWithAttachments.length}');
      }

      // Sort by transaction date descending
      transactionsWithAttachments.sort((a, b) =>
          b.details.transaction.date.compareTo(a.details.transaction.date));

      // 3. Pre-load attachment files asynchronously
      if (kDebugMode) {
        print('ExportService: Preloading attachments from directory: ${docDir.path}');
      }

      final List<
          ({
            TransactionWithDetails details,
            List<
                ({
                  TransactionDocument doc,
                  List<Uint8List> pagesBytes,
                  bool isImage,
                  bool isPdf,
                  Uint8List? originalPdfBytes, // Store original PDF bytes
                })> attachments,
          })> preloadedData = [];

      for (final item in transactionsWithAttachments) {
        final List<
            ({
              TransactionDocument doc,
              List<Uint8List> pagesBytes,
              bool isImage,
              bool isPdf,
              Uint8List? originalPdfBytes,
            })> attachments = [];
        for (final doc in item.docs) {
          final file = File(p.join(docDir.path, doc.fileName));
          final List<Uint8List> pagesBytes = [];
          Uint8List? originalPdfBytes;
          bool isImage = false;
          bool isPdf = false;

          final fileExists = await file.exists();
          if (kDebugMode) {
            print('ExportService: Checking attachment file: ${file.path}. Exists: $fileExists');
          }

          if (fileExists) {
            final mime = (doc.mimeType ?? '').toLowerCase();
            final isImgType = mime.startsWith('image/') ||
                ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(p
                    .extension(doc.originalName)
                    .replaceAll('.', '')
                    .toLowerCase());
            final isPdfType = mime == 'application/pdf' ||
                p.extension(doc.originalName).toLowerCase() == '.pdf';

            if (isImgType) {
              isImage = true;
              try {
                final imgBytes = await file.readAsBytes();
                pagesBytes.add(imgBytes);
              } catch (e) {
                if (kDebugMode) print('Error reading image file: $e');
              }
            } else if (isPdfType) {
              isPdf = true;
              try {
                originalPdfBytes = await file.readAsBytes();
                // Rasterize ONLY the first page of the PDF for a thumbnail preview
                await for (final page in Printing.raster(originalPdfBytes, pages: [0], dpi: 100)) {
                  final pagePng = await page.toPng();
                  pagesBytes.add(pagePng);
                  break; // Just in case, only take the first page
                }
              } catch (e) {
                if (kDebugMode) print('Error reading/rasterizing PDF file: $e');
              }
            }
          }
          attachments.add(
              (doc: doc, pagesBytes: pagesBytes, isImage: isImage, isPdf: isPdf, originalPdfBytes: originalPdfBytes));
        }
        preloadedData.add((details: item.details, attachments: attachments));
      }

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

      final pageTheme = pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: theme,
        buildBackground: logoSvgString != null
            ? (pw.Context context) {
                return pw.FullPage(
                  ignoreMargins: true,
                  child: pw.Center(
                    child: pw.Opacity(
                      opacity: 0.03,
                      child: pw.Container(
                        width: 250,
                        height: 250,
                        child: pw.SvgImage(
                          svg: logoSvgString!,
                          colorFilter: const PdfColor(0 / 255.0, 102 / 255.0,
                              153 / 255.0), // #006699 (Deep Brand Blue)
                        ),
                      ),
                    ),
                  ),
                );
              }
            : null,
      );

      final List<Uint8List> pdfParts = [];

      if (preloadedData.isEmpty) {
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            pageTheme: pageTheme,
            build: (pw.Context context) {
              return pw.Center(
                child: _buildText(
                  l10n?.noTransactionsWithAttachments ?? 'No transactions with attachments found.',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
                ),
              );
            },
          ),
        );
        final bytes = await pdf.save();
        pdfParts.add(bytes);
      } else {
        bool isFirstPage = true;
        for (final item in preloadedData) {
          final formattedAmount = AmountFormatter.formatWithCurrency(
            item.details.transaction.amount.toDouble(),
            currencyObj,
          );
          final categoryName =
              _getLocalizedCategoryName(item.details.category?.name, l10n);

          final currentIsFirstPage = isFirstPage;
          isFirstPage = false;

          final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);

          // 1. Generate the transaction details part
          final pdf = pw.Document();
          pdf.addPage(
            pw.MultiPage(
              pageTheme: pageTheme,
              header: (pw.Context context) {
                final appTitle = l10n?.appTitle ?? 'Flowpaisa';
                final reportTitle = l10n?.exportPdfWithAttachments ?? 'Transactions with Attachments';
                return pw.Container(
                  alignment: isRtl ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(bottom: 20),
                  child: _buildText(
                    '$appTitle - $reportTitle',
                    style: pw.TextStyle(color: PdfColors.grey500, fontSize: 9),
                  ),
                );
              },
              footer: (pw.Context context) {
                final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);
                final appTitle = l10n?.appTitle ?? 'Flowpaisa';
                final pageText = 'Page ${context.pageNumber} / ${context.pagesCount}';

                return pw.Container(
                  alignment: pw.Alignment.center,
                  margin: const pw.EdgeInsets.only(top: 20),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                    ),
                  ),
                  padding: const pw.EdgeInsets.only(top: 10),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: isRtl
                        ? [
                            _buildText(
                              pageText,
                              style: const pw.TextStyle(
                                color: PdfColors.grey600,
                                fontSize: 8,
                              ),
                            ),
                            _buildText(
                              '$categoryName • $formattedAmount',
                              style: pw.TextStyle(
                                color: PdfColors.grey600,
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Row(
                              children: [
                                _buildText(
                                  appTitle,
                                  style: pw.TextStyle(
                                    color: PdfColors.grey600,
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                if (logoSvgString != null) ...[
                                  pw.SizedBox(width: 4),
                                  pw.Container(
                                    width: 12,
                                    height: 12,
                                    child: pw.SvgImage(
                                      svg: logoSvgString,
                                      colorFilter: const PdfColor(
                                          0 / 255.0,
                                          102 / 255.0,
                                          153 / 255.0), // #006699 (Deep Brand Blue)
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ]
                        : [
                            pw.Row(
                              children: [
                                if (logoSvgString != null) ...[
                                  pw.Container(
                                    width: 12,
                                    height: 12,
                                    child: pw.SvgImage(
                                      svg: logoSvgString,
                                      colorFilter: const PdfColor(
                                          0 / 255.0,
                                          102 / 255.0,
                                          153 / 255.0), // #006699 (Deep Brand Blue)
                                    ),
                                  ),
                                  pw.SizedBox(width: 4),
                                ],
                                _buildText(
                                  appTitle,
                                  style: pw.TextStyle(
                                    color: PdfColors.grey600,
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            _buildText(
                              '$categoryName • $formattedAmount',
                              style: pw.TextStyle(
                                color: PdfColors.grey600,
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            _buildText(
                              pageText,
                              style: const pw.TextStyle(
                                  color: PdfColors.grey600, fontSize: 8),
                            ),
                          ],
                  ),
                );
              },
              build: (pw.Context context) {
                final List<pw.Widget> pageWidgets = [];

                // Title on the first page of the document
                if (currentIsFirstPage) {
                  pageWidgets.add(
                    pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 24),
                      child: pw.Column(
                        crossAxisAlignment: isRtl
                            ? pw.CrossAxisAlignment.end
                            : pw.CrossAxisAlignment.start,
                        children: [
                          _buildText(
                            l10n?.transactionsAttachmentReport ?? 'Transactions Attachment Report',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: const PdfColor(
                                  0 / 255.0, 100 / 255.0, 150 / 255.0),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: isRtl ? pw.MainAxisAlignment.end : pw.MainAxisAlignment.start,
                            children: isRtl
                                ? [
                                    _buildText(
                                      AppDateFormatter.formatDate(DateTime.now()),
                                      style: pw.TextStyle(
                                          fontSize: 10, color: PdfColors.grey600),
                                    ),
                                    pw.SizedBox(width: 4),
                                    _buildText(
                                      l10n != null ? l10n.generatedOn('').trim() : 'Generated on',
                                      style: pw.TextStyle(
                                          fontSize: 10, color: PdfColors.grey600),
                                    ),
                                  ]
                                : [
                                    _buildText(
                                      l10n != null ? l10n.generatedOn('').trim() : 'Generated on',
                                      style: pw.TextStyle(
                                          fontSize: 10, color: PdfColors.grey600),
                                    ),
                                    pw.SizedBox(width: 4),
                                    _buildText(
                                      AppDateFormatter.formatDate(DateTime.now()),
                                      style: pw.TextStyle(
                                          fontSize: 10, color: PdfColors.grey600),
                                    ),
                                  ],
                          ),
                        ],
                      ),
                    ),
                  );
                  pageWidgets.add(pw.Divider(color: PdfColors.grey300, thickness: 1));
                  pageWidgets.add(pw.SizedBox(height: 16));
                }

                pageWidgets.addAll(
                  _buildTransactionAttachmentBlock(
                    item.details,
                    item.attachments,
                    l10n,
                    currencySymbol,
                    decimalPlaces,
                    currencyObj,
                  ),
                );

                // Now, check if there are any image attachments
                final imageAttachments = item.attachments.where((att) => att.isImage).toList();
                if (imageAttachments.isNotEmpty) {
                  // Set a safe maximum printable height for each image on A4 (841.89) minus margins (64) and header/footer (60) which is ~717.
                  // Non-image elements (header, padding, borders, spacing) take ~67.
                  // By setting maxHeight to 600, each image is allowed to expand to cover the page fully.
                  // If there are multiple images, they will naturally print on separate pages unless they are naturally small enough to fit together without being scaled down.
                  final double maxHeight = 600;

                  for (final att in imageAttachments) {
                    if (att.pagesBytes.isNotEmpty) {
                      pageWidgets.add(
                        pw.Inseparable(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              // Attachment Header
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: const pw.BoxDecoration(
                                  color: PdfColors.grey200,
                                  borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
                                ),
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Expanded(
                                      child: _buildText(
                                        att.doc.originalName,
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColors.grey800,
                                        ),
                                      ),
                                    ),
                                    _buildText(
                                      _formatFileSize(att.doc.fileSize),
                                      style: const pw.TextStyle(
                                        fontSize: 9,
                                        color: PdfColors.grey600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Full Image Content
                              pw.Container(
                                width: double.infinity,
                                padding: const pw.EdgeInsets.all(12),
                                decoration: const pw.BoxDecoration(
                                  border: pw.Border(
                                    left: pw.BorderSide(color: PdfColors.grey200, width: 1),
                                    right: pw.BorderSide(color: PdfColors.grey200, width: 1),
                                    bottom: pw.BorderSide(color: PdfColors.grey200, width: 1),
                                  ),
                                ),
                                child: pw.Center(
                                  child: pw.Container(
                                    constraints: pw.BoxConstraints(maxHeight: maxHeight),
                                    child: pw.Image(
                                      pw.MemoryImage(att.pagesBytes.first),
                                      fit: pw.BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              pw.SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    }
                  }
                }

                return pageWidgets;
              },
            ),
          );

          final detailsBytes = await pdf.save();
          pdfParts.add(detailsBytes);

          // 2. Append PDF attachments immediately after this transaction details block
          for (final att in item.attachments) {
            if (att.isPdf && att.originalPdfBytes != null) {
              pdfParts.add(att.originalPdfBytes!);
            }
          }
        }
      }

      Uint8List finalPdfBytes;
      if (pdfParts.length == 1) {
        finalPdfBytes = pdfParts.first;
      } else {
        try {
          final sf.PdfDocument destDocument = sf.PdfDocument();
          // Disable default margins on the destination document to prevent template shrinking/clipping
          destDocument.pageSettings.margins.all = 0;
          
          for (final pdfBytes in pdfParts) {
            final sf.PdfDocument sourceDocument = sf.PdfDocument(inputBytes: pdfBytes);
            for (int i = 0; i < sourceDocument.pages.count; i++) {
              final sf.PdfPage page = sourceDocument.pages[i];
              final sf.PdfTemplate template = page.createTemplate();
              
              // Add a page with matching size to prevent cutting off
              final sf.PdfPage destPage = destDocument.pages.add();
              destPage.graphics.drawPdfTemplate(
                template, 
                const Offset(0, 0), 
                Size(destPage.size.width, destPage.size.height),
              );
            }
            sourceDocument.dispose();
          }
          
          final List<int> mergedBytes = await destDocument.save();
          destDocument.dispose();
          finalPdfBytes = Uint8List.fromList(mergedBytes);
        } catch (e) {
          if (kDebugMode) {
            print('Error merging PDFs sequentially using Syncfusion: $e');
          }
          // Fallback to the first details part if merge fails
          finalPdfBytes = pdfParts.first;
        }
      }

      return finalPdfBytes;
    } catch (e) {
      throw Exception('Error generating attachments PDF: $e');
    }
  }

  List<pw.Widget> _buildTransactionAttachmentBlock(
    TransactionWithDetails details,
    List<
            ({
              TransactionDocument doc,
              List<Uint8List> pagesBytes,
              bool isImage,
              bool isPdf,
              Uint8List? originalPdfBytes,
            })>
        attachments,
    AppLocalizations? l10n,
    String? currencySymbol,
    int decimalPlaces,
    AppCurrency? currencyObj,
  ) {
    final isIncome = details.transaction.type == 'INCOME';
    final amountColor = isIncome ? PdfColors.green700 : PdfColors.red700;

    // Format amount
    final formattedAmount = AmountFormatter.formatWithCurrency(
      details.transaction.amount.toDouble(),
      currencyObj,
    );

    final List<pw.Widget> widgets = [];

    final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);

    // 1. Transaction Card
    widgets.add(
      pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
        ),
        padding: const pw.EdgeInsets.all(16),
        child: pw.Column(
          crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: isRtl
                  ? [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildText(
                            formattedAmount,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: amountColor,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          _buildText(
                            AppDateFormatter.formatDate(details.transaction.date),
                            style: const pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _buildText(
                            _getLocalizedCategoryName(details.category?.name, l10n),
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 4),
                          _buildText(
                            details.account?.name ?? 'Cashbook',
                            style: const pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                    ]
                  : [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildText(
                            _getLocalizedCategoryName(details.category?.name, l10n),
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 4),
                          _buildText(
                            details.account?.name ?? 'Cashbook',
                            style: const pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          _buildText(
                            formattedAmount,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: amountColor,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          _buildText(
                            AppDateFormatter.formatDate(details.transaction.date),
                            style: const pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                    ],
            ),
            if (details.contact != null ||
                details.transaction.description != null) ...[
              pw.SizedBox(height: 12),
              pw.Divider(color: PdfColors.grey300, thickness: 0.5),
              pw.SizedBox(height: 8),
              if (details.contact != null)
                pw.Row(
                  mainAxisAlignment: isRtl ? pw.MainAxisAlignment.end : pw.MainAxisAlignment.start,
                  children: isRtl
                      ? [
                          pw.Expanded(
                            child: _buildText(
                              details.contact!.name,
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700),
                            ),
                          ),
                          _buildText(
                            '${l10n?.contact ?? "Contact"}: ',
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey700),
                          ),
                        ]
                      : [
                          _buildText(
                            '${l10n?.contact ?? "Contact"}: ',
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey700),
                          ),
                          pw.Expanded(
                            child: _buildText(
                              details.contact!.name,
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700),
                            ),
                          ),
                        ],
                ),
              if (details.transaction.description != null &&
                  details.transaction.description!.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: isRtl ? pw.MainAxisAlignment.end : pw.MainAxisAlignment.start,
                  children: isRtl
                      ? [
                          pw.Expanded(
                            child: _buildText(
                              TabularParser.isTabular(details.transaction.description)
                                  ? TabularParser.parse(details.transaction.description).$1
                                  : details.transaction.description!,
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700),
                            ),
                          ),
                          _buildText(
                            '${l10n?.description ?? "Description"}: ',
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey700),
                          ),
                        ]
                      : [
                          _buildText(
                            '${l10n?.description ?? "Description"}: ',
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey700),
                          ),
                          pw.Expanded(
                            child: _buildText(
                              TabularParser.isTabular(details.transaction.description)
                                  ? TabularParser.parse(details.transaction.description).$1
                                  : details.transaction.description!,
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700),
                            ),
                          ),
                        ],
                ),
              ],
            ],
          ],
        ),
      ),
    );

    widgets.add(pw.SizedBox(height: 12));

    // 2. Attachments Header
    widgets.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 8),
        child: _buildText(
          '${l10n?.attachments ?? "Attachments"} (${attachments.length}):',
          style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800),
        ),
      ),
    );
    widgets.add(pw.SizedBox(height: 8));

    // 3. Render each attachment
    for (final att in attachments) {
      // Create a single, cohesive container for the attachment to keep the header and content together
      widgets.add(
        pw.Inseparable(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Render attachment metadata header
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: _buildText(
                        att.doc.originalName,
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800),
                      ),
                    ),
                    _buildText(
                      _formatFileSize(att.doc.fileSize),
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ),
              // Render the content (images or pages)
              if (att.isImage)
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.grey200, width: 1),
                      right: pw.BorderSide(color: PdfColors.grey200, width: 1),
                      bottom: pw.BorderSide(color: PdfColors.grey200, width: 1),
                    ),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (att.pagesBytes.isNotEmpty)
                        pw.Container(
                          width: 45,
                          height: 60,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                          ),
                          child: pw.Image(
                            pw.MemoryImage(att.pagesBytes.first),
                            fit: pw.BoxFit.cover,
                          ),
                        )
                      else
                        pw.Container(
                          width: 45,
                          height: 60,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                          ),
                          child: pw.Center(
                            child: pw.Container(
                              width: 16,
                              height: 20,
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.grey300,
                              ),
                              child: pw.Center(
                                child: pw.Text(
                                  'IMG',
                                  style: pw.TextStyle(
                                    fontSize: 6,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildText(
                              l10n?.attachmentFile ?? 'Image Attachment',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey800,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            _buildText(
                              l10n?.imageAppendedMessage ?? 'Image Attachment (Appended on the next page)',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else if (att.isPdf)
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.grey200, width: 1),
                      right: pw.BorderSide(color: PdfColors.grey200, width: 1),
                      bottom: pw.BorderSide(color: PdfColors.grey200, width: 1),
                    ),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (att.pagesBytes.isNotEmpty)
                        pw.Container(
                          width: 45,
                          height: 60,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                          ),
                          child: pw.Image(
                            pw.MemoryImage(att.pagesBytes.first),
                            fit: pw.BoxFit.cover,
                          ),
                        )
                      else
                        pw.Container(
                          width: 45,
                          height: 60,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                          ),
                          child: pw.Center(
                            child: pw.Container(
                              width: 16,
                              height: 20,
                              decoration: const pw.BoxDecoration(
                                color: PdfColors.grey300,
                              ),
                              child: pw.Center(
                                child: pw.Text(
                                  'PDF',
                                  style: pw.TextStyle(
                                    fontSize: 6,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildText(
                              l10n?.exportPdfWithAttachments ?? 'PDF Document',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey800,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            _buildText(
                              l10n?.pdfAppendedMessage ?? 'PDF Document (Appended natively after this card)',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 16),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: PdfColors.grey200, width: 1),
                      right: pw.BorderSide(color: PdfColors.grey200, width: 1),
                      bottom: pw.BorderSide(color: PdfColors.grey200, width: 1),
                    ),
                  ),
                  child: pw.Center(
                    child: _buildText(
                      l10n?.attachmentFile ?? 'Attachment File',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
                    ),
                  ),
                ),
              pw.SizedBox(height: 12),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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

      return await pdf.save();
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
    int decimalPlaces = 2,
    AppLocalizations? l10n,
    AppCurrency? currency,
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
        decimalPlaces: decimalPlaces,
        materialIconsFont: materialIconsFont,
        unicodeFont: unicodeFont,
        hindiFont: hindiFont,
        englishFont: englishFont,
        l10n: l10n,
        currencyObj: currency,
      );
      return await pdf.save();
    } catch (e) {
      throw Exception('Error generating analytics PDF: $e');
    }
  }

  // Generate Analytics PDF document
  Future<pw.Document> generateAnalyticsPDFDocument({
    required DateTime startDate,
    required DateTime endDate,
    String? currencySymbol,
    int decimalPlaces = 2,
    pw.Font? materialIconsFont,
    pw.Font? unicodeFont,
    pw.Font? hindiFont,
    pw.Font? englishFont,
    AppLocalizations? l10n,
    AppCurrency? currencyObj,
  }) async {
    String? logoSvgString;
    try {
      logoSvgString =
          await rootBundle.loadString('assets/images/logo_square.svg');
    } catch (e) {
      if (kDebugMode) {
        print('ExportService: Failed to load logo SVG: $e');
      }
    }

    // Fetch all analytics data
    final financialSummary =
        await _analyticsRepository.getFinancialSummary(startDate, endDate);
    final allTimeFinancialSummary =
        await _analyticsRepository.getAllTimeFinancialSummary();
    final contactSummaries =
        await _analyticsRepository.getContactSummaries(startDate, endDate);
    final expensesByCategory =
        await _analyticsRepository.getExpensesByCategory(startDate, endDate);
    final incomeByCategory =
        await _analyticsRepository.getIncomeByCategory(startDate, endDate);
    final monthlyTrends = await _analyticsRepository.getMonthlyTrends(6);
    final payableReceivableTrends =
        await _analyticsRepository.getPayableReceivableTrends(6);
    final topContacts = await _analyticsRepository.getTopContactsByBalance(
        startDate, endDate, 10);
    final statusDistribution = await _analyticsRepository
        .getPaymentStatusDistribution(startDate, endDate);

    final accountsRepo = AccountsRepository(_database);
    final accountFlowSummaries = await accountsRepo.getAccountFlowSummaries(startDate, endDate);

    final currency = currencySymbol ?? '₹';
    String fmt(num amount) {
      if (currencyObj != null) {
        return AmountFormatter.formatWithCurrency(
            amount.toDouble(), currencyObj);
      }
      return AmountFormatter.formatWithCurrency(
          amount.toDouble(), currency, decimalPlaces);
    }

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

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      theme: theme,
      buildBackground: logoSvgString != null
          ? (pw.Context context) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Center(
                  child: pw.Opacity(
                    opacity: 0.03,
                    child: pw.Container(
                      width: 250,
                      height: 250,
                      child: pw.SvgImage(
                        svg: logoSvgString!,
                        colorFilter: const PdfColor(0 / 255.0, 102 / 255.0,
                            153 / 255.0), // #006699 (Deep Brand Blue)
                      ),
                    ),
                  ),
                ),
              );
            }
          : null,
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        footer: (pw.Context context) {
          final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);
          final pageText = 'Page ${context.pageNumber} / ${context.pagesCount}';
          final appTitle = l10n?.appTitle ?? 'Flowpaisa';

          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            padding: const pw.EdgeInsets.only(top: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: isRtl
                  ? [
                      _buildText(
                        pageText,
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 8,
                        ),
                      ),
                      pw.Row(
                        children: [
                          _buildText(
                            appTitle,
                            style: pw.TextStyle(
                              color: PdfColors.grey600,
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (logoSvgString != null) ...[
                            pw.SizedBox(width: 4),
                            pw.Container(
                              width: 12,
                              height: 12,
                              child: pw.SvgImage(
                                svg: logoSvgString,
                                colorFilter: const PdfColor(
                                    0 / 255.0,
                                    102 / 255.0,
                                    153 / 255.0), // #006699 (Deep Brand Blue)
                              ),
                            ),
                          ],
                        ],
                      ),
                    ]
                  : [
                      pw.Row(
                        children: [
                          if (logoSvgString != null) ...[
                            pw.Container(
                              width: 12,
                              height: 12,
                              child: pw.SvgImage(
                                svg: logoSvgString,
                                colorFilter: const PdfColor(
                                    0 / 255.0,
                                    102 / 255.0,
                                    153 / 255.0), // #006699 (Deep Brand Blue)
                              ),
                            ),
                            pw.SizedBox(width: 4),
                          ],
                          _buildText(
                            appTitle,
                            style: pw.TextStyle(
                              color: PdfColors.grey600,
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _buildText(
                        pageText,
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 8,
                        ),
                      ),
                    ],
            ),
          );
        },
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
                      l10n?.exportAnalyticsPDF ?? 'Flowpaisa Analytics Report',
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
                        fmt(financialSummary.totalPayable),
                        ExportService.getPayablePdfColor(),
                        l10n),
                    _buildTableCell(
                        '${l10n?.payable ?? 'Payable'} (${l10n?.allTime.replaceAll(':', '').trim() ?? 'All Time'})',
                        fmt(allTimeFinancialSummary.totalPayable),
                        ExportService.getPayablePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        '${l10n?.receivable ?? 'Receivable'}',
                        fmt(financialSummary.totalReceivable),
                        ExportService.getReceivablePdfColor(),
                        l10n),
                    _buildTableCell(
                        '${l10n?.receivable ?? 'Receivable'} (${l10n?.allTime.replaceAll(':', '').trim() ?? 'All Time'})',
                        fmt(allTimeFinancialSummary.totalReceivable),
                        ExportService.getReceivablePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        '${l10n?.expense ?? 'Expenses'}',
                        fmt(financialSummary.totalExpense),
                        ExportService.getExpensePdfColor(),
                        l10n),
                    _buildTableCell(
                        '${l10n?.expense ?? 'Expenses'} (${l10n?.allTime.replaceAll(':', '').trim() ?? 'All Time'})',
                        fmt(allTimeFinancialSummary.totalExpense),
                        ExportService.getExpensePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        '${l10n?.income ?? 'Income'}',
                        fmt(financialSummary.totalIncome),
                        ExportService.getIncomePdfColor(),
                        l10n),
                    _buildTableCell(
                        '${l10n?.income ?? 'Income'} (${l10n?.allTime.replaceAll(':', '').trim() ?? 'All Time'})',
                        fmt(allTimeFinancialSummary.totalIncome),
                        ExportService.getIncomePdfColor(),
                        l10n),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                        '${l10n?.netBalance ?? 'Net Balance'}',
                        fmt(financialSummary.netBalance),
                        financialSummary.netBalance == 0
                            ? PdfColors.black
                            : financialSummary.netBalance >= 0
                                ? ExportService.getIncomePdfColor()
                                : ExportService.getExpensePdfColor(),
                        l10n),
                    _buildTableCell(
                        '${l10n?.netBalance ?? 'Net Balance'} (${l10n?.allTime.replaceAll(':', '').trim() ?? 'All Time'})',
                        fmt(allTimeFinancialSummary.netBalance),
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
                            child: _buildText(fmt(summary.totalPayable),
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
                            child: _buildText(fmt(summary.totalReceivable),
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
                            child: _buildText(fmt(summary.balance.abs()),
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
                  decimalPlaces,
                  hexToPdfColor,
                  materialIconsFont,
                  ExportService.getExpensePdfColor(),
                  self: self,
                  l10n: l10n,
                  currencyObj: currencyObj),
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
                  decimalPlaces,
                  hexToPdfColor,
                  materialIconsFont,
                  ExportService.getIncomePdfColor(),
                  self: self,
                  l10n: l10n,
                  currencyObj: currencyObj),
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
              self._buildVisualBarChart(monthlyTrends, currency, decimalPlaces,
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
                            child: _buildText(fmt(trend.income),
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
                            child: _buildText(fmt(trend.expense),
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
                  payableReceivableTrends, currency, decimalPlaces,
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
                            child: _buildText(fmt(trend.totalPayable),
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
                            child: _buildText(fmt(trend.totalReceivable),
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
                            child: _buildText(fmt(contact.balance.abs()),
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
                      decimalPlaces,
                      l10n: l10n,
                      currencyObj: currencyObj),
                if (statusDistribution.paidPayables > 0)
                  _buildStatusRow(
                      '${l10n?.payables ?? 'Payables'} - ${l10n?.statusPaid ?? 'Paid'}',
                      statusDistribution.paidPayables,
                      Colors.green,
                      currency,
                      decimalPlaces,
                      l10n: l10n,
                      currencyObj: currencyObj),
                if (statusDistribution.cancelledPayables > 0)
                  _buildStatusRow(
                      '${l10n?.payables ?? 'Payables'} - ${l10n?.statusCancelled ?? 'Cancelled'}',
                      statusDistribution.cancelledPayables,
                      Colors.grey,
                      currency,
                      decimalPlaces,
                      l10n: l10n,
                      currencyObj: currencyObj),
                if (statusDistribution.pendingReceivables > 0)
                  _buildStatusRow(
                      '${l10n?.receivables ?? 'Receivables'} - ${l10n?.pending ?? 'Pending'}',
                      statusDistribution.pendingReceivables,
                      Colors.orange,
                      currency,
                      decimalPlaces,
                      l10n: l10n,
                      currencyObj: currencyObj),
                if (statusDistribution.receivedReceivables > 0)
                  _buildStatusRow(
                      '${l10n?.receivables ?? 'Receivables'} - ${l10n?.statusReceived ?? 'Received'}',
                      statusDistribution.receivedReceivables,
                      Colors.green,
                      currency,
                      decimalPlaces,
                      l10n: l10n,
                      currencyObj: currencyObj),
                if (statusDistribution.cancelledReceivables > 0)
                  _buildStatusRow(
                      '${l10n?.receivables ?? 'Receivables'} - ${l10n?.statusCancelled ?? 'Cancelled'}',
                      statusDistribution.cancelledReceivables,
                      Colors.grey,
                      currency,
                      decimalPlaces,
                      l10n: l10n,
                      currencyObj: currencyObj),
              ],
            ),

            if (accountFlowSummaries.isNotEmpty) ...[
              pw.SizedBox(height: 30),
              _buildLocalizedHeader(
                  l10n?.accountFlowSummary ?? 'Account Cashflow',
                  level: 1,
                  l10n: l10n),
              pw.SizedBox(height: 10),
              ...accountFlowSummaries.map((summary) {
                final accountNamesMap = {for (final s in accountFlowSummaries) s.account.uuid: s.account.name};

                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Header with account name
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          _buildText(
                            summary.account.name,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          _buildText(
                            '${l10n?.netFlow ?? "Net Flow"}: ${summary.netFlow >= 0 ? "+" : ""}${fmt(summary.netFlow)}',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                              color: summary.netFlow >= 0
                                  ? const PdfColor(0 / 255.0, 150 / 255.0, 0 / 255.0) // Green
                                  : const PdfColor(200 / 255.0, 0 / 255.0, 0 / 255.0), // Red
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Divider(color: PdfColors.grey300, thickness: 0.5),
                      pw.SizedBox(height: 6),

                      // Opening / Closing
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          _buildText(
                            '${l10n?.openingBalanceLabel ?? "Opening"}: ${fmt(summary.openingBalance)}',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                          ),
                          _buildText(
                            '${l10n?.closingBalanceLabel ?? "Closing"}: ${fmt(summary.closingBalance)}',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),

                      // Inflow Table
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
                        children: [
                          _buildLocalizedTableRow(
                            [
                              _buildTableHeaderCell('${l10n?.inflow ?? "Inflow"}: ${fmt(summary.totalInflow)}', l10n: l10n),
                              _buildTableHeaderCell(l10n?.amount ?? 'Amount', l10n: l10n),
                            ],
                            l10n: l10n,
                            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                          ),
                          if (summary.totalIncome > 0)
                            _buildLocalizedTableRow(
                              [
                                _buildTableCell(l10n?.income ?? 'Income', null, null, l10n),
                                _buildTableCell(fmt(summary.totalIncome), null, null, l10n),
                              ],
                              l10n: l10n,
                            ),
                          ...summary.transfersInBreakdown.entries.map((entry) {
                            final otherAccName = accountNamesMap[entry.key] ?? l10n?.unknownAccount ?? 'Other Account';
                            return _buildLocalizedTableRow(
                              [
                                _buildTableCell(l10n?.transferFromAnalytics(otherAccName) ?? 'From $otherAccName', null, null, l10n),
                                _buildTableCell(fmt(entry.value), null, null, l10n),
                              ],
                              l10n: l10n,
                            );
                          }),
                        ],
                      ),
                      pw.SizedBox(height: 8),

                      // Outflow Table
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
                        children: [
                          _buildLocalizedTableRow(
                            [
                              _buildTableHeaderCell('${l10n?.outflow ?? "Outflow"}: ${fmt(summary.totalOutflow)}', l10n: l10n),
                              _buildTableHeaderCell(l10n?.amount ?? 'Amount', l10n: l10n),
                            ],
                            l10n: l10n,
                            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                          ),
                          if (summary.totalExpense > 0)
                            _buildLocalizedTableRow(
                              [
                                _buildTableCell(l10n?.expenses ?? 'Expense', null, null, l10n),
                                _buildTableCell(fmt(summary.totalExpense), null, null, l10n),
                              ],
                              l10n: l10n,
                            ),
                          ...summary.transfersOutBreakdown.entries.map((entry) {
                            final otherAccName = accountNamesMap[entry.key] ?? l10n?.unknownAccount ?? 'Other Account';
                            return _buildLocalizedTableRow(
                              [
                                _buildTableCell(l10n?.transferToAnalytics(otherAccName) ?? 'To $otherAccName', null, null, l10n),
                                _buildTableCell(fmt(entry.value), null, null, l10n),
                              ],
                              l10n: l10n,
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ];
        },
      ),
    );

    return pdf;
  }

  Future<pw.Document> generateAccountStatementPDF({
    required String accountName,
    required DateTime startDate,
    required DateTime endDate,
    required List<StatementEntry> entries,
    required AppCurrency currency,
    AppLocalizations? l10n,
  }) async {
    pw.SvgImage? logoSvg;
    String? logoSvgString;
    try {
      logoSvgString =
          await rootBundle.loadString('assets/images/logo_square.svg');
      logoSvg = pw.SvgImage(svg: logoSvgString);
    } catch (e) {
      if (kDebugMode) {
        print('ExportService: Failed to load logo SVG: $e');
      }
    }

    final unicodeFont = await loadUnicodeFont();
    final hindiFont = await loadHindiFont();
    final englishFont = await loadEnglishFont();

    final theme = pw.ThemeData.withFont(
      base: englishFont ?? unicodeFont,
      bold: englishFont ?? unicodeFont,
      fontFallback: [
        if (unicodeFont != null) unicodeFont,
        if (hindiFont != null) hindiFont,
        if (englishFont != null) englishFont,
      ],
    );

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      theme: theme,
      buildBackground: logoSvgString != null
          ? (pw.Context context) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Center(
                  child: pw.Opacity(
                    opacity: 0.03,
                    child: pw.Container(
                      width: 250,
                      height: 250,
                      child: pw.SvgImage(
                        svg: logoSvgString!,
                        colorFilter: const PdfColor(0 / 255.0, 102 / 255.0,
                            153 / 255.0), // #006699 (Deep Brand Blue)
                      ),
                    ),
                  ),
                ),
              );
            }
          : null,
    );

    final pdf = pw.Document();

    // Calculate Summary Values
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
      startingBalance = firstEntry.runningBalance -
          (firstIsExpense ? -firstEntry.amount : firstEntry.amount);
    }

    final dateFormat = AppDateFormatter.getFormatter(_dateFormat);
    final dateTimeFormat = AppDateFormatter.getFormatter('dd MMM yyyy, HH:mm');

    String fmt(num amount) {
      return AmountFormatter.formatWithCurrency(amount.toDouble(), currency);
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        footer: (pw.Context context) {
          final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);
          final pageText = 'Page ${context.pageNumber} / ${context.pagesCount}';
          final appTitle = l10n?.appTitle ?? 'Flowpaisa';

          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            padding: const pw.EdgeInsets.only(top: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: isRtl
                  ? [
                      _buildText(
                        pageText,
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 8,
                        ),
                      ),
                      pw.Row(
                        children: [
                          _buildText(
                            appTitle,
                            style: pw.TextStyle(
                              color: PdfColors.grey600,
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (logoSvgString != null) ...[
                            pw.SizedBox(width: 4),
                            pw.Container(
                              width: 12,
                              height: 12,
                              child: pw.SvgImage(
                                svg: logoSvgString,
                                colorFilter: const PdfColor(
                                    0 / 255.0,
                                    102 / 255.0,
                                    153 / 255.0), // #006699 (Deep Brand Blue)
                              ),
                            ),
                          ],
                        ],
                      ),
                    ]
                  : [
                      pw.Row(
                        children: [
                          if (logoSvgString != null) ...[
                            pw.Container(
                              width: 12,
                              height: 12,
                              child: pw.SvgImage(
                                svg: logoSvgString,
                                colorFilter: const PdfColor(
                                    0 / 255.0,
                                    102 / 255.0,
                                    153 / 255.0), // #006699 (Deep Brand Blue)
                              ),
                            ),
                            pw.SizedBox(width: 4),
                          ],
                          _buildText(
                            appTitle,
                            style: pw.TextStyle(
                              color: PdfColors.grey600,
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _buildText(
                        pageText,
                        style: const pw.TextStyle(
                          color: PdfColors.grey600,
                          fontSize: 8,
                        ),
                      ),
                    ],
            ),
          );
        },
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
                      l10n?.accountStatement ?? 'Account Statement',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color:
                            const PdfColor(0 / 255.0, 100 / 255.0, 150 / 255.0),
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
                            l10n?.account ?? 'Account',
                            style: pw.TextStyle(
                                fontSize: 10, color: PdfColors.grey700),
                            align:
                                isRtl ? pw.TextAlign.right : pw.TextAlign.left,
                          ),
                          _buildText(':',
                              style: pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey700)),
                          _buildText(
                            accountName,
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

            // Summary Section
            _buildLocalizedHeader(l10n?.summary ?? 'Summary',
                level: 1, l10n: l10n),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                      l10n?.startingBalance ?? 'Starting Balance',
                      fmt(startingBalance),
                      null,
                      l10n,
                    ),
                    _buildTableCell(
                      l10n?.endingBalance ?? 'Ending Balance',
                      fmt(endingBalance),
                      null,
                      l10n,
                    ),
                  ],
                  l10n: l10n,
                ),
                _buildLocalizedTableRow(
                  [
                    _buildTableCell(
                      l10n?.totalCredits ?? 'Total Credits',
                      fmt(totalCredits),
                      ExportService.getIncomePdfColor(),
                      l10n,
                    ),
                    _buildTableCell(
                      l10n?.totalDebits ?? 'Total Debits',
                      fmt(totalDebits),
                      ExportService.getExpensePdfColor(),
                      l10n,
                    ),
                  ],
                  l10n: l10n,
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Entries Section
            _buildLocalizedHeader(l10n?.transactions ?? 'Transactions',
                level: 1, l10n: l10n),
            pw.SizedBox(height: 10),
            if (entries.isEmpty)
              _buildText(
                l10n?.noStatementEntries ??
                    'No statement entries in this date range.',
                style: pw.TextStyle(color: PdfColors.grey700),
                align: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
              )
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FixedColumnWidth(80),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FixedColumnWidth(80),
                  3: const pw.FixedColumnWidth(80),
                  4: const pw.FixedColumnWidth(100),
                },
                children: [
                  _buildLocalizedTableRow(
                    [
                      _buildTableHeaderCell(l10n?.date ?? 'Date'),
                      _buildTableHeaderCell(l10n?.description ?? 'Description'),
                      _buildTableHeaderCell(l10n?.debit ?? 'Debit'),
                      _buildTableHeaderCell(l10n?.credit ?? 'Credit'),
                      _buildTableHeaderCell(l10n?.runningBalance ?? 'Balance'),
                    ],
                    l10n: l10n,
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                  ),
                  ...entries.reversed.map((entry) {
                    final isDebit = entry.entryType == StatementEntryType.debit;
                    final amountColor = isDebit
                        ? ExportService.getExpensePdfColor()
                        : ExportService.getIncomePdfColor();

                    // Extract clean description if tabular
                    String cleanDescription = entry.description ?? '';
                    if (TabularParser.isTabular(cleanDescription)) {
                      cleanDescription =
                          TabularParser.parse(cleanDescription).$1;
                    }
                    if (cleanDescription.isEmpty) {
                      cleanDescription = entry.title;
                    }

                    return _buildLocalizedTableRow(
                      [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: isRtl
                                ? pw.Alignment.centerRight
                                : pw.Alignment.centerLeft,
                            child: _buildText(
                              dateFormat.format(entry.date),
                              style: const pw.TextStyle(fontSize: 9),
                              align: isRtl
                                  ? pw.TextAlign.right
                                  : pw.TextAlign.left,
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
                              cleanDescription,
                              style: const pw.TextStyle(fontSize: 9),
                              align: isRtl
                                  ? pw.TextAlign.right
                                  : pw.TextAlign.left,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: _buildText(
                              isDebit ? fmt(entry.amount) : '-',
                              style: pw.TextStyle(
                                fontSize: 9,
                                color: isDebit ? amountColor : PdfColors.black,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: _buildText(
                              !isDebit ? fmt(entry.amount) : '-',
                              style: pw.TextStyle(
                                fontSize: 9,
                                color: !isDebit ? amountColor : PdfColors.black,
                              ),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Container(
                            alignment: pw.Alignment.centerLeft,
                            child: _buildText(
                              fmt(entry.runningBalance),
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
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

  // Helper method to build category table
  pw.Widget _buildCategoryTable(
      List<dynamic> categories,
      String currency,
      int decimalPlaces,
      PdfColor Function(String) hexToPdfColor,
      pw.Font? materialIconsFont,
      PdfColor defaultColor,
      {ExportService? self,
      AppLocalizations? l10n,
      AppCurrency? currencyObj}) {
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

          final formattedAmount = currencyObj != null
              ? AmountFormatter.formatWithCurrency(amount, currencyObj)
              : AmountFormatter.formatWithCurrency(
                  amount, currency, decimalPlaces);

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
                    formattedAmount,
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
  pw.TableRow _buildStatusRow(String label, double amount, Color color,
      String currency, int decimalPlaces,
      {AppLocalizations? l10n, AppCurrency? currencyObj}) {
    final pdfColor = PdfColor(color.r, color.g, color.b);
    final isRtl = l10n != null && Bidi.isRtlLanguage(l10n.localeName);
    final formattedAmount = currencyObj != null
        ? AmountFormatter.formatWithCurrency(amount, currencyObj)
        : AmountFormatter.formatWithCurrency(amount, currency, decimalPlaces);
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
            child: _buildText(formattedAmount,
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
      List<MonthlyFinancials> trends, String currency, int decimalPlaces,
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
                              AmountFormatter.formatWithCurrency(
                                  trend.income, currency, decimalPlaces),
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
                              AmountFormatter.formatWithCurrency(
                                  trend.income, currency, decimalPlaces),
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
                              AmountFormatter.formatWithCurrency(
                                  trend.expense, currency, decimalPlaces),
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
                              AmountFormatter.formatWithCurrency(
                                  trend.expense, currency, decimalPlaces),
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
      List<PayableReceivableTrend> trends, String currency, int decimalPlaces,
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
                              AmountFormatter.formatWithCurrency(
                                  trend.totalPayable, currency, decimalPlaces),
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
                              AmountFormatter.formatWithCurrency(
                                  trend.totalPayable, currency, decimalPlaces),
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
                              AmountFormatter.formatWithCurrency(
                                  trend.totalReceivable,
                                  currency,
                                  decimalPlaces),
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
                              AmountFormatter.formatWithCurrency(
                                  trend.totalReceivable,
                                  currency,
                                  decimalPlaces),
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
