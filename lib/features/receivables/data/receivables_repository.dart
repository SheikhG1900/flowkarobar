import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';

class ReceivablesRepository {
  final AppDatabase _database;

  ReceivablesRepository(this._database);

  /// Watch all receivables
  Stream<List<Receivable>> watchAllReceivables() {
    return (_database.select(_database.receivables)
          ..orderBy([(r) => OrderingTerm.desc(r.date)]))
        .watch();
  }

  /// Watch receivables by status
  Stream<List<Receivable>> watchReceivablesByStatus(String status) {
    return (_database.select(_database.receivables)
          ..where((r) => r.status.equals(status))
          ..orderBy([(r) => OrderingTerm.desc(r.date)]))
        .watch();
  }

  /// Watch receivables with contact information
  Stream<List<ReceivableWithContact>> watchReceivablesWithContacts() {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.id.equalsExp(_database.receivables.contactId),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReceivableWithContact(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }

  /// Get receivable by ID
  Future<Receivable?> getReceivableById(int id) {
    return (_database.select(_database.receivables)
          ..where((r) => r.id.equals(id)))
        .getSingleOrNull();
  }

  /// Create receivable
  Future<int> createReceivable(ReceivablesCompanion receivable) {
    return _database.into(_database.receivables).insert(receivable);
  }

  /// Update receivable
  Future<bool> updateReceivable(Receivable receivable) {
    return _database.update(_database.receivables).replace(receivable);
  }

  /// Delete receivable
  Future<int> deleteReceivable(int id) {
    return (_database.delete(_database.receivables)
          ..where((r) => r.id.equals(id)))
        .go();
  }

  /// Mark receivable as received and create income if auto-create is enabled
  Future<void> markAsReceived(int receivableId) async {
    await _database.transaction(() async {
      final receivable = await getReceivableById(receivableId);
      if (receivable == null) return;

      // Update receivable status
      await _database.update(_database.receivables).replace(
        receivable.copyWith(
          status: 'RECEIVED',
          updatedAt: DateTime.now(),
        ),
      );

      // Auto-create income if enabled
      if (receivable.autoCreateIncome) {
        final incomeId = await _database.into(_database.transactions).insert(
          TransactionsCompanion(
            amount: Value(receivable.amount),
            type: const Value('INCOME'),
            categoryId: Value(null),
            contactId: Value(receivable.contactId),
            description: Value(receivable.description),
            date: Value(DateTime.now()),
            linkedReceivableId: Value(receivableId),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );

        // Link the income back to receivable
        await _database.update(_database.receivables).replace(
          receivable.copyWith(
            linkedIncomeId: Value(incomeId),
            status: 'RECEIVED',
            updatedAt: DateTime.now(),
          ),
        );
      }
    });
  }

  /// Get total pending receivables
  Future<double> getTotalPendingReceivables() async {
    final query = _database.selectOnly(_database.receivables)
      ..addColumns([_database.receivables.amount.sum()])
      ..where(_database.receivables.status.equals('PENDING'));

    final result = await query.getSingle();
    return result.read(_database.receivables.amount.sum()) ?? 0.0;
  }

  /// Get receivables by contact
  Stream<List<Receivable>> watchReceivablesByContact(int contactId) {
    return (_database.select(_database.receivables)
          ..where((r) => r.contactId.equals(contactId))
          ..orderBy([(r) => OrderingTerm.desc(r.date)]))
        .watch();
  }

  /// Get receivable by external link ID (for shared transactions)
  Future<Receivable?> getReceivableByExternalLinkId(String externalLinkId) {
    return (_database.select(_database.receivables)
          ..where((r) => r.externalLinkId.equals(externalLinkId)))
        .getSingleOrNull();
  }
}

/// Data class for receivable with contact information
class ReceivableWithContact {
  final Receivable receivable;
  final Contact? contact;

  ReceivableWithContact({
    required this.receivable,
    this.contact,
  });
}

