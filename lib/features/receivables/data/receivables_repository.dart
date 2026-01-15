import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:flowpaisa/features/receivables/domain/models.dart';

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

    // Default order
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReceivableWithContact(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }

  /// Watch receivables with contact information filtered by status
  Stream<List<ReceivableWithContact>> watchReceivablesWithContactsByStatus(String status) {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.id.equalsExp(_database.receivables.contactId),
      ),
    ]);

    query.where(_database.receivables.status.equals(status));
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReceivableWithContact(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }

  /// Watch receivables with ALL linked data (contact + linked transaction + linked category)
  /// This method uses JOINs to fetch all related data in a single efficient query
  Stream<List<ReceivableWithLinkedData>> watchReceivablesWithLinkedData(String status) {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.id.equalsExp(_database.receivables.contactId),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.id.equalsExp(_database.receivables.linkedExpenseId) | 
        _database.transactions.id.equalsExp(_database.receivables.linkedIncomeId),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.id.equalsExp(_database.transactions.categoryId),
      ),
    ]);

    query.where(_database.receivables.status.equals(status));
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReceivableWithLinkedData(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Update receivable (with companion for partial updates)
  Future<int> updateReceivableWithCompanion(int id, ReceivablesCompanion companion) {
    return (_database.update(_database.receivables)
          ..where((r) => r.id.equals(id)))
        .write(companion);
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

  /// Mark receivable as received and activate linked transaction
  Future<void> markAsReceived(int receivableId) async {
    await _database.transaction(() async {
      final receivable = await getReceivableById(receivableId);
      if (receivable == null) return;

      // Update receivable status and store received date
      await _database.update(_database.receivables).replace(
        receivable.copyWith(
          status: 'RECEIVED',
          receivedDate: Value(DateTime.now()),
          updatedAt: DateTime.now(),
        ),
      );

      // Auto-create income if enabled (for PAID_FOR receivables and standalone receivables)
      // Skip if linkedIncomeId exists (WILL_RECEIVE case - already has linked income)
      if (receivable.autoCreateIncome && receivable.linkedIncomeId == null) {
        final incomeId = await _database.into(_database.transactions).insert(
          TransactionsCompanion(
            amount: Value(receivable.amount),
            type: const Value('INCOME'),
            categoryId: Value(null),
            contactId: Value(receivable.contactId),
            description: Value(receivable.description),
            date: Value(DateTime.now()),
            linkedReceivableId: Value(receivableId),
            isAutoGenerated: const Value(true), // Mark as auto-generated
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );

        // Link the income back to receivable
        await _database.update(_database.receivables).replace(
          receivable.copyWith(
            linkedIncomeId: Value(incomeId),
            status: 'RECEIVED',
            receivedDate: Value(DateTime.now()),
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

  /// Check if external link ID already exists
  Future<bool> checkIfExternalLinkExists(String externalLinkId) async {
    final receivable = await getReceivableByExternalLinkId(externalLinkId);
    return receivable != null;
  }

  /// Import receivable from shared link
  Future<int> importFromSharedLink(dynamic sharedData) async {
    // Import shared data (dynamic type for flexibility with SharedData classes)
    // Extract contact ID or create contact
    int? contactId;
    
    if (sharedData.contactPhone != null && sharedData.contactPhone!.isNotEmpty) {
      // Find or create contact
      final contactsRepo = ContactsRepository(_database);
      contactId = await contactsRepo.findOrCreateContactByPhone(
        phone: sharedData.contactPhone!,
        name: sharedData.contactName ?? 'Unknown',
      );
    }

    return await createReceivable(
      ReceivablesCompanion(
        contactId: Value(contactId!),
        amount: Value(sharedData.amount),
        description: Value(sharedData.description),
        date: Value(sharedData.date),
        dueDate: Value(sharedData.dueDate),
        status: const Value('PENDING'),
        externalLinkId: Value(sharedData.externalLinkId),
        autoCreateIncome: const Value(true),
      ),
    );
  }

  /// Get receivables with contact information by date range
  Future<List<ReceivableWithContact>> getReceivablesWithContactsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.id.equalsExp(_database.receivables.contactId),
      ),
    ]);

    query.where(_database.receivables.date.isBetweenValues(start, end));
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);

    return query.get().then((rows) {
      return rows.map((row) {
        return ReceivableWithContact(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }

  /// Watch receivables with ALL linked data (paginated) - Stream version
  Stream<List<ReceivableWithLinkedData>> watchReceivablesWithLinkedDataPaginated({
    required String status,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.id.equalsExp(_database.receivables.contactId),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.id.equalsExp(_database.receivables.linkedExpenseId) | 
        _database.transactions.id.equalsExp(_database.receivables.linkedIncomeId),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.id.equalsExp(_database.transactions.categoryId),
      ),
    ]);

    query.where(_database.receivables.status.equals(status));
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);
    query.limit(limit, offset: offset);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ReceivableWithLinkedData(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Get receivables with ALL linked data (paginated) - Future version for loading more
  Future<List<ReceivableWithLinkedData>> getReceivablesWithLinkedDataPaginated({
    required String status,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _database.select(_database.receivables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.id.equalsExp(_database.receivables.contactId),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.id.equalsExp(_database.receivables.linkedExpenseId) | 
        _database.transactions.id.equalsExp(_database.receivables.linkedIncomeId),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.id.equalsExp(_database.transactions.categoryId),
      ),
    ]);

    query.where(_database.receivables.status.equals(status));
    query.orderBy([OrderingTerm.desc(_database.receivables.date)]);
    query.limit(limit, offset: offset);

    return query.get().then((rows) {
      return rows.map((row) {
        return ReceivableWithLinkedData(
          receivable: row.readTable(_database.receivables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
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

