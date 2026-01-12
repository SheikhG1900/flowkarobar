import 'dart:io';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  final TransactionsRepository _transactionsRepository;

  ExportService(this._transactionsRepository);

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
        
        if (!include) continue;

        csvData.add([
          DateFormat('dd/MM/yyyy').format(t.date),
          t.type,
          t.amount.toStringAsFixed(2),
          item.category?.name ?? '', // Use name instead of ID
          item.contact?.name ?? '',  // Use name instead of ID
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
      
      // Handle duplicates
      int counter = 1;
      while (await File(newPath).exists()) {
        final name = fileName.replaceAll('.csv', '');
        newPath = '${downloadsDir.path}/${name}_$counter.csv';
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
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'FlowPaisa Transaction Export',
        text: 'Here are my transaction records from FlowPaisa',
      );
      
      if (result.status == ShareResultStatus.unavailable) {
        throw Exception('Sharing is not available on this device');
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
