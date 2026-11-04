import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class ContactsRepository {
  final AppDatabase _database;

  ContactsRepository(this._database);

  Future<int> getNextAvailableSeq<T extends HasResultSet>(
      ResultSetImplementation<T, dynamic> table, GeneratedColumn<int> seqColumn) async {
    // Get isDeleted column from the table
    final isDeletedColumn = table.columnsByName['is_deleted'] as GeneratedColumn<bool>?;

    final query = _database.selectOnly(table)
      ..addColumns([seqColumn])
      ..where(seqColumn.isNotNull());

    // Filter out deleted records if the column exists
    if (isDeletedColumn != null) {
      query.where(isDeletedColumn.equals(false));
    }

    query.orderBy([OrderingTerm.asc(seqColumn)]);

    final rows = await query.get();
    final usedSeqs = rows.map((r) => r.read(seqColumn)!).toSet();

    // Start from 1 for new records (0 is reserved for defaults)
    int nextSeq = 1;
    while (usedSeqs.contains(nextSeq)) {
      nextSeq++;
    }
    return nextSeq;
  }

  /// Watch all contacts
  Stream<List<Contact>> watchAllContacts() {
    return (_database.select(_database.contacts)
          ..where((c) => c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Watch contacts with usage stats (most used first)
  Stream<List<ContactWithUsage>> watchContactsWithUsage() {
    return watchAllContacts().map((contacts) {
      return contacts.map((c) => ContactWithUsage(
        contact: c,
        usageCount: 0,
        lastUsed: DateTime.now(),
      )).toList();
    });
  }

  /// Get contact by UUID
  Future<Contact?> getContactByUuid(String uuid) {
    return (_database.select(_database.contacts)
          ..where((c) => c.uuid.equals(uuid) & c.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Watch contact by UUID (reactive)
  Stream<Contact?> watchContactByUuid(String uuid) {
    return (_database.select(_database.contacts)
          ..where((c) => c.uuid.equals(uuid) & c.isDeleted.equals(false)))
        .watchSingleOrNull();
  }

  /// Get contact by phone number
  Future<Contact?> getContactByPhone(String phone) {
    return (_database.select(_database.contacts)
          ..where((c) => c.phone.equals(phone) & c.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Create contact
  Future<String> createContact(ContactsCompanion contact) async {
    final uuid = contact.uuid.present ? contact.uuid.value : const Uuid().v4();
    final nextSeq = await getNextAvailableSeq(_database.contacts, _database.contacts.addSeq);
    await _database.into(_database.contacts).insert(
          contact.copyWith(
            uuid: Value(uuid),
            isNotSynced: const Value(true),
            addSeq: Value(nextSeq),
          ),
        );
    return uuid;
  }

  /// Update contact
  Future<bool> updateContact(Contact contact) {
    return _database
        .update(_database.contacts)
        .replace(contact.copyWith(isNotSynced: true));
  }

  /// Delete contact
  Future<int> deleteContact(String uuid) {
    return (_database.update(_database.contacts)
          ..where((c) => c.uuid.equals(uuid)))
        .write(const ContactsCompanion(
      isDeleted: Value(true),
      isNotSynced: Value(true),
    ));
  }

  /// Search contacts by name
  Stream<List<Contact>> searchContactsByName(String query) {
    return (_database.select(_database.contacts)
          ..where((c) => c.name.contains(query) & c.isDeleted.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Increment contact usage count
  Future<void> incrementUsageCount(String contactUuid) async {
    // Legacy stub
  }

  /// Decrement contact usage count
  Future<void> decrementUsageCount(String contactUuid) async {
    // Legacy stub
  }

  /// Get most used contacts
  Future<List<ContactWithUsage>> getMostUsedContacts(int limit) async {
    final list = await watchAllContacts().first;
    return list.take(limit).map((c) => ContactWithUsage(
      contact: c,
      usageCount: 0,
      lastUsed: DateTime.now(),
    )).toList();
  }

  /// Get recently used contacts
  Future<List<ContactWithUsage>> getRecentlyUsedContacts(int limit) async {
    final list = await watchAllContacts().first;
    return list.take(limit).map((c) => ContactWithUsage(
      contact: c,
      usageCount: 0,
      lastUsed: DateTime.now(),
    )).toList();
  }

  /// Find contact by phone or create if not exists
  Future<String> findOrCreateContactByPhone({
    required String phone,
    required String name,
  }) async {
    // Clean phone number
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Try to find existing contact
    final existingContact = await getContactByPhone(cleanPhone);
    if (existingContact != null) {
      return existingContact.uuid;
    }

    // Create new contact
    final uuid = const Uuid().v4();
    await createContact(
      ContactsCompanion(
        uuid: Value(uuid),
        name: Value(name),
        phone: Value(cleanPhone),
      ),
    );
    return uuid;
  }

  /// Get contact statistics
  Future<ContactStatistics> getContactStatistics(String contactUuid) async {
    final contact = await getContactByUuid(contactUuid);
    if (contact == null) {
      throw Exception('Contact not found');
    }

    // Get transactions count
    final transactionsCount =
        await (_database.selectOnly(_database.transactions)
              ..addColumns([_database.transactions.uuid.count()])
              ..where(_database.transactions.contactUuid.equals(contactUuid) &
                  _database.transactions.isDeleted.equals(false)))
            .getSingle()
            .then((row) => row.read(_database.transactions.uuid.count()) ?? 0);

    // Get receivables count (PENDING only)
    final receivablesCount = await (_database.selectOnly(_database.orders)
          ..addColumns([_database.orders.uuid.count()])
          ..where(_database.orders.contactUuid.equals(contactUuid) &
              _database.orders.isDeleted.equals(false) &
              _database.orders.orderType.equals('SALE') &
              _database.orders.paymentStatus.equals('PAID').not()))
        .getSingle()
        .then((row) => row.read(_database.orders.uuid.count()) ?? 0);

    // Get payables count (PENDING only)
    final payablesCount = await (_database.selectOnly(_database.orders)
          ..addColumns([_database.orders.uuid.count()])
          ..where(_database.orders.contactUuid.equals(contactUuid) &
              _database.orders.isDeleted.equals(false) &
              _database.orders.orderType.equals('PURCHASE') &
              _database.orders.paymentStatus.equals('PAID').not()))
        .getSingle()
        .then((row) => row.read(_database.orders.uuid.count()) ?? 0);

    // Get total receivable amount
    final totalReceivable = await (_database.selectOnly(_database.orders)
          ..addColumns([_database.orders.totalAmount.sum()])
          ..where(_database.orders.contactUuid.equals(contactUuid) &
              _database.orders.isDeleted.equals(false) &
              _database.orders.orderType.equals('SALE') &
              _database.orders.paymentStatus.equals('PAID').not()))
        .getSingle()
        .then((row) => row.read(_database.orders.totalAmount.sum()) ?? 0.0);

    // Get total payable amount
    final totalPayable = await (_database.selectOnly(_database.orders)
          ..addColumns([_database.orders.totalAmount.sum()])
          ..where(_database.orders.contactUuid.equals(contactUuid) &
              _database.orders.isDeleted.equals(false) &
              _database.orders.orderType.equals('PURCHASE') &
              _database.orders.paymentStatus.equals('PAID').not()))
        .getSingle()
        .then((row) => row.read(_database.orders.totalAmount.sum()) ?? 0.0);

    // Get total received amount
    final totalReceived = await (_database.selectOnly(_database.orders)
          ..addColumns([_database.orders.totalAmount.sum()])
          ..where(_database.orders.contactUuid.equals(contactUuid) &
              _database.orders.isDeleted.equals(false) &
              _database.orders.orderType.equals('SALE') &
              _database.orders.paymentStatus.equals('PAID')))
        .getSingle()
        .then((row) => row.read(_database.orders.totalAmount.sum()) ?? 0.0);

    // Get total paid amount
    final totalPaid = await (_database.selectOnly(_database.orders)
          ..addColumns([_database.orders.totalAmount.sum()])
          ..where(_database.orders.contactUuid.equals(contactUuid) &
              _database.orders.isDeleted.equals(false) &
              _database.orders.orderType.equals('PURCHASE') &
              _database.orders.paymentStatus.equals('PAID')))
        .getSingle()
        .then((row) => row.read(_database.orders.totalAmount.sum()) ?? 0.0);

    return ContactStatistics(
      contact: contact,
      transactionsCount: transactionsCount,
      receivablesCount: receivablesCount,
      payablesCount: payablesCount,
      totalReceivable: totalReceivable,
      totalPayable: totalPayable,
      totalReceived: totalReceived,
      totalPaid: totalPaid,
    );
  }

  /// Watch contact statistics (reactive version)
  Stream<ContactStatistics> watchContactStatistics(String contactUuid) {
    return Rx.combineLatest2(
      watchContactByUuid(contactUuid),
      _database.select(_database.orders).watch(),
      (contact, orders) => contact,
    ).asyncMap((contact) async {
      if (contact == null) {
        throw Exception('Contact not found');
      }
      return getContactStatistics(contactUuid);
    });
  }
}

/// Data class for contact with usage statistics
class ContactWithUsage {
  final Contact contact;
  final int usageCount;
  final DateTime? lastUsed;

  ContactWithUsage({
    required this.contact,
    required this.usageCount,
    this.lastUsed,
  });
}

/// Data class for contact statistics
class ContactStatistics {
  final Contact contact;
  final int transactionsCount;
  final int receivablesCount;
  final int payablesCount;
  final double totalReceivable;
  final double totalPayable;
  final double totalReceived;
  final double totalPaid;

  double get netBalance => totalReceivable - totalPayable;

  ContactStatistics({
    required this.contact,
    required this.transactionsCount,
    required this.receivablesCount,
    required this.payablesCount,
    required this.totalReceivable,
    required this.totalPayable,
    this.totalReceived = 0.0,
    this.totalPaid = 0.0,
  });
}
