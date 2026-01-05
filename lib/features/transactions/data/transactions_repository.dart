import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';

class TransactionsRepository {
  final AppDatabase _database;

  TransactionsRepository(this._database);

  // Get all transactions
  Stream<List<Transaction>> watchAllTransactions() {
    return _database.select(_database.transactions).watch();
  }

  // Get transactions by date range
  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (_database.select(_database.transactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  // Get transaction by ID
  Future<Transaction?> getTransactionById(int id) {
    return (_database.select(_database.transactions)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // Create transaction
  Future<int> createTransaction(TransactionsCompanion transaction) {
    return _database.into(_database.transactions).insert(transaction);
  }

  // Update transaction
  Future<bool> updateTransaction(Transaction transaction) {
    return _database.update(_database.transactions).replace(transaction);
  }

  // Delete transaction
  Future<int> deleteTransaction(int id) {
    return (_database.delete(_database.transactions)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  // Get transactions by type (EXPENSE or INCOME)
  Stream<List<Transaction>> watchTransactionsByType(String type) {
    return (_database.select(_database.transactions)
          ..where((t) => t.type.equals(type))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  // Get transactions by category
  Stream<List<Transaction>> watchTransactionsByCategory(int categoryId) {
    return (_database.select(_database.transactions)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  // Get total expense
  Future<double> getTotalExpense(DateTime? start, DateTime? end) async {
    final query = _database.selectOnly(_database.transactions)
      ..addColumns([_database.transactions.amount.sum()])
      ..where(_database.transactions.type.equals('EXPENSE'));

    if (start != null && end != null) {
      query.where(_database.transactions.date.isBetweenValues(start, end));
    }

    final result = await query.getSingle();
    return result.read(_database.transactions.amount.sum()) ?? 0.0;
  }

  // Get total income
  Future<double> getTotalIncome(DateTime? start, DateTime? end) async {
    final query = _database.selectOnly(_database.transactions)
      ..addColumns([_database.transactions.amount.sum()])
      ..where(_database.transactions.type.equals('INCOME'));

    if (start != null && end != null) {
      query.where(_database.transactions.date.isBetweenValues(start, end));
    }

    final result = await query.getSingle();
    return result.read(_database.transactions.amount.sum()) ?? 0.0;
  }

  // Search transactions
  Stream<List<Transaction>> searchTransactions(String query) {
    return (_database.select(_database.transactions)
          ..where((t) => t.description.contains(query))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }
}



