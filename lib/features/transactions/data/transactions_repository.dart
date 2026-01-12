import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';

class TransactionsRepository {
  final AppDatabase _database;

  TransactionsRepository(this._database);

  // Get all transactions
  Stream<List<Transaction>> watchAllTransactions() {
    return _database.select(_database.transactions).watch();
  }

  // Get transactions by date range (Stream)
  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (_database.select(_database.transactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  // Get transactions by date range (Future)
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (_database.select(_database.transactions)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
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

  // Helper method to create transaction with individual parameters
  Future<int> createTransactionSimple({
    required double amount,
    required String type,
    String? description,
    required DateTime date,
    int? categoryId,
    int? contactId,
  }) {
    return createTransaction(
      TransactionsCompanion(
        amount: Value(amount),
        type: Value(type),
        description: Value(description),
        date: Value(date),
        categoryId: Value(categoryId),
        contactId: Value(contactId),
      ),
    );
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

  // Watch transactions with category details
  Stream<List<TransactionWithCategory>> watchTransactionsWithCategory() {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.id.equalsExp(_database.transactions.categoryId),
      ),
    ])
      ..orderBy([OrderingTerm.desc(_database.transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  // Watch transactions with ALL details (category + contact)
  // This method uses JOINs to fetch all related data in a single efficient query
  Stream<List<TransactionWithDetails>> watchTransactionsWithDetails() {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.id.equalsExp(_database.transactions.categoryId),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.id.equalsExp(_database.transactions.contactId),
      ),
      leftOuterJoin(
        _database.payables,
        _database.payables.id.equalsExp(_database.transactions.linkedPayableId),
      ),
      leftOuterJoin(
        _database.receivables,
        _database.receivables.id.equalsExp(_database.transactions.linkedReceivableId),
      ),
    ])
      ..orderBy([OrderingTerm.desc(_database.transactions.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.categories),
          contact: row.readTableOrNull(_database.contacts),
          linkedPayable: row.readTableOrNull(_database.payables),
          linkedReceivable: row.readTableOrNull(_database.receivables),
        );
      }).toList();
    });
  }

  // Get transactions with details by date range (Future)
  Future<List<TransactionWithDetails>> getTransactionsWithDetailsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    final query = _database.select(_database.transactions).join([
      leftOuterJoin(
        _database.categories,
        _database.categories.id.equalsExp(_database.transactions.categoryId),
      ),
      leftOuterJoin(
        _database.contacts,
        _database.contacts.id.equalsExp(_database.transactions.contactId),
      ),
      leftOuterJoin(
        _database.payables,
        _database.payables.id.equalsExp(_database.transactions.linkedPayableId),
      ),
      leftOuterJoin(
        _database.receivables,
        _database.receivables.id.equalsExp(_database.transactions.linkedReceivableId),
      ),
    ]);

    query.where(_database.transactions.date.isBetweenValues(start, end));
    query.orderBy([OrderingTerm.desc(_database.transactions.date)]);

    return query.get().then((rows) {
      return rows.map((row) {
        return TransactionWithDetails(
          transaction: row.readTable(_database.transactions),
          category: row.readTableOrNull(_database.categories),
          contact: row.readTableOrNull(_database.contacts),
          linkedPayable: row.readTableOrNull(_database.payables),
          linkedReceivable: row.readTableOrNull(_database.receivables),
        );
      }).toList();
    });
  }

  // Update transaction (with companion for partial updates)
  Future<int> updateTransactionWithCompanion(int id, TransactionsCompanion companion) {
    return (_database.update(_database.transactions)
          ..where((t) => t.id.equals(id)))
        .write(companion);
  }
}

class TransactionWithCategory {
  final Transaction transaction;
  final Category? category;

  TransactionWithCategory({
    required this.transaction,
    this.category,
  });
}



