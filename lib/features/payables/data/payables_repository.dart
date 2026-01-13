import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';

class PayablesRepository {
  final AppDatabase _database;

  PayablesRepository(this._database);

  /// Watch all payables
  Stream<List<Payable>> watchAllPayables() {
    return (_database.select(_database.payables)
          ..orderBy([(p) => OrderingTerm.desc(p.date)]))
        .watch();
  }

  /// Watch payables by status
  Stream<List<Payable>> watchPayablesByStatus(String status) {
    return (_database.select(_database.payables)
          ..where((p) => p.status.equals(status))
          ..orderBy([(p) => OrderingTerm.desc(p.date)]))
        .watch();
  }

  /// Watch payables with contact information
  Stream<List<PayableWithContact>> watchPayablesWithContacts() {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.id.equalsExp(_database.payables.contactId),
      ),
    ]);
    
    // Default order
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return PayableWithContact(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }

  /// Watch payables with contact information filtered by status
  Stream<List<PayableWithContact>> watchPayablesWithContactsByStatus(String status) {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.id.equalsExp(_database.payables.contactId),
      ),
    ]);

    query.where(_database.payables.status.equals(status));
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return PayableWithContact(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }

  /// Watch payables with ALL linked data (contact + linked transaction + linked category)
  /// This method uses JOINs to fetch all related data in a single efficient query
  Stream<List<PayableWithLinkedData>> watchPayablesWithLinkedData(String status) {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.id.equalsExp(_database.payables.contactId),
      ),
      leftOuterJoin(
        _database.transactions,
        _database.transactions.id.equalsExp(_database.payables.linkedExpenseId),
      ),
      leftOuterJoin(
        _database.categories,
        _database.categories.id.equalsExp(_database.transactions.categoryId),
      ),
    ]);

    query.where(_database.payables.status.equals(status));
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return PayableWithLinkedData(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
          linkedTransaction: row.readTableOrNull(_database.transactions),
          linkedCategory: row.readTableOrNull(_database.categories),
        );
      }).toList();
    });
  }

  /// Update payable (with companion for partial updates)
  Future<int> updatePayableWithCompanion(int id, PayablesCompanion companion) {
    return (_database.update(_database.payables)
          ..where((p) => p.id.equals(id)))
        .write(companion);
  }

  /// Get payable by ID
  Future<Payable?> getPayableById(int id) {
    return (_database.select(_database.payables)
          ..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  /// Create payable
  Future<int> createPayable(PayablesCompanion payable) {
    return _database.into(_database.payables).insert(payable);
  }

  /// Update payable
  Future<bool> updatePayable(Payable payable) {
    return _database.update(_database.payables).replace(payable);
  }

  /// Delete payable
  Future<int> deletePayable(int id) {
    return (_database.delete(_database.payables)
          ..where((p) => p.id.equals(id)))
        .go();
  }

  /// Mark payable as paid and activate linked transaction
  Future<void> markAsPaid(int payableId) async {
    await _database.transaction(() async {
      final payable = await getPayableById(payableId);
      if (payable == null) return;

      // Update payable status and store paid date
      await _database.update(_database.payables).replace(
        payable.copyWith(
          status: 'PAID',
          paidDate: Value(DateTime.now()),
          updatedAt: DateTime.now(),
        ),
      );

      // Auto-create expense if enabled (for non-linked payables like PAID_FOR/RECEIVED_FROM)
      if (payable.autoCreateExpense && payable.linkedExpenseId == null) {
        final expenseId = await _database.into(_database.transactions).insert(
          TransactionsCompanion(
            amount: Value(payable.amount),
            type: const Value('EXPENSE'),
            categoryId: Value(null),
            contactId: Value(payable.contactId),
            description: Value(payable.description),
            date: Value(DateTime.now()),
            linkedPayableId: Value(payableId),
            isAutoGenerated: const Value(true), // Mark as auto-generated
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );

        // Link the expense back to payable
        await _database.update(_database.payables).replace(
          payable.copyWith(
            linkedExpenseId: Value(expenseId),
            status: 'PAID',
            paidDate: Value(DateTime.now()),
            updatedAt: DateTime.now(),
          ),
        );
      }
    });
  }

  /// Get total pending payables
  Future<double> getTotalPendingPayables() async {
    final query = _database.selectOnly(_database.payables)
      ..addColumns([_database.payables.amount.sum()])
      ..where(_database.payables.status.equals('PENDING'));

    final result = await query.getSingle();
    return result.read(_database.payables.amount.sum()) ?? 0.0;
  }

  /// Get payables by contact
  Stream<List<Payable>> watchPayablesByContact(int contactId) {
    return (_database.select(_database.payables)
          ..where((p) => p.contactId.equals(contactId))
          ..orderBy([(p) => OrderingTerm.desc(p.date)]))
        .watch();
  }

  /// Get payable by external link ID (for shared transactions)
  Future<Payable?> getPayableByExternalLinkId(String externalLinkId) {
    return (_database.select(_database.payables)
          ..where((p) => p.externalLinkId.equals(externalLinkId)))
        .getSingleOrNull();
  }

  /// Check if external link ID already exists
  Future<bool> checkIfExternalLinkExists(String externalLinkId) async {
    final payable = await getPayableByExternalLinkId(externalLinkId);
    return payable != null;
  }

  /// Import payable from shared link
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

    return await createPayable(
      PayablesCompanion(
        contactId: Value(contactId!),
        amount: Value(sharedData.amount),
        description: Value(sharedData.description),
        date: Value(sharedData.date),
        dueDate: Value(sharedData.dueDate),
        status: const Value('PENDING'),
        externalLinkId: Value(sharedData.externalLinkId),
        autoCreateExpense: const Value(false),
      ),
    );
  }

  /// Get payables with contact information by date range
  Future<List<PayableWithContact>> getPayablesWithContactsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    final query = _database.select(_database.payables).join([
      leftOuterJoin(
        _database.contacts,
        _database.contacts.id.equalsExp(_database.payables.contactId),
      ),
    ]);

    query.where(_database.payables.date.isBetweenValues(start, end));
    query.orderBy([OrderingTerm.desc(_database.payables.date)]);

    return query.get().then((rows) {
      return rows.map((row) {
        return PayableWithContact(
          payable: row.readTable(_database.payables),
          contact: row.readTableOrNull(_database.contacts),
        );
      }).toList();
    });
  }
}

/// Data class for payable with contact information
class PayableWithContact {
  final Payable payable;
  final Contact? contact;

  PayableWithContact({
    required this.payable,
    this.contact,
  });
}

