import 'dart:io';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  final TransactionsRepository _transactionsRepository;

  ExportService(this._transactionsRepository);

  // Export transactions to CSV
  Future<String> exportTransactionsToCSV({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get transactions in date range
      final transactions = await _transactionsRepository
          .getTransactionsByDateRange(startDate, endDate);

      // Create CSV data
      List<List<dynamic>> csvData = [
        // Header row
        ['Date', 'Type', 'Amount', 'Category', 'Contact', 'Description'],
      ];

      // Add transaction rows
      for (var transaction in transactions) {
        csvData.add([
          DateFormat('dd/MM/yyyy').format(transaction.date),
          transaction.type,
          transaction.amount.toStringAsFixed(2),
          transaction.categoryId?.toString() ?? '',
          transaction.contactId?.toString() ?? '',
          transaction.description ?? '',
        ]);
      }

      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'flowpaisa_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString);

      return file.path;
    } catch (e) {
      throw Exception('Error exporting to CSV: $e');
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
