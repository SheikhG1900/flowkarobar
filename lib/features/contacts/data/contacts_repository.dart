import 'package:drift/drift.dart';
import 'package:flowpaisa/core/database/database.dart';

class ContactsRepository {
  final AppDatabase _database;

  ContactsRepository(this._database);

  /// Watch all contacts
  Stream<List<Contact>> watchAllContacts() {
    return (_database.select(_database.contacts)
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Watch contacts with usage stats (most used first)
  Stream<List<ContactWithUsage>> watchContactsWithUsage() {
    final query = _database.select(_database.contacts).join([
      leftOuterJoin(
        _database.contactUsageStats,
        _database.contactUsageStats.contactId
            .equalsExp(_database.contacts.id),
      ),
    ])
      ..orderBy([
        OrderingTerm.desc(
          _database.contactUsageStats.usageCount,
        ),
        OrderingTerm.asc(_database.contacts.name),
      ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ContactWithUsage(
          contact: row.readTable(_database.contacts),
          usageCount: row.readTableOrNull(_database.contactUsageStats)?.usageCount ?? 0,
          lastUsed: row.readTableOrNull(_database.contactUsageStats)?.lastUsed,
        );
      }).toList();
    });
  }

  /// Get contact by ID
  Future<Contact?> getContactById(int id) {
    return (_database.select(_database.contacts)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get contact by phone number
  Future<Contact?> getContactByPhone(String phone) {
    return (_database.select(_database.contacts)
          ..where((c) => c.phone.equals(phone)))
        .getSingleOrNull();
  }

  /// Create contact
  Future<int> createContact(ContactsCompanion contact) {
    return _database.into(_database.contacts).insert(contact);
  }

  /// Update contact
  Future<bool> updateContact(Contact contact) {
    return _database.update(_database.contacts).replace(contact);
  }

  /// Delete contact
  Future<int> deleteContact(int id) {
    return (_database.delete(_database.contacts)
          ..where((c) => c.id.equals(id)))
        .go();
  }

  /// Search contacts by name
  Stream<List<Contact>> searchContactsByName(String query) {
    return (_database.select(_database.contacts)
          ..where((c) => c.name.contains(query))
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  /// Increment contact usage count
  Future<void> incrementUsageCount(int contactId) async {
    await _database.transaction(() async {
      // Check if usage stat exists
      final existingStat = await (_database.select(_database.contactUsageStats)
            ..where((s) => s.contactId.equals(contactId)))
          .getSingleOrNull();

      if (existingStat != null) {
        // Update existing
        await _database.update(_database.contactUsageStats).replace(
              existingStat.copyWith(
                usageCount: existingStat.usageCount + 1,
                lastUsed: Value(DateTime.now()),
              ),
            );
      } else {
        // Create new
        await _database.into(_database.contactUsageStats).insert(
              ContactUsageStatsCompanion(
                contactId: Value(contactId),
                usageCount: const Value(1),
                lastUsed: Value(DateTime.now()),
              ),
            );
      }
    });
  }

  /// Get most used contacts
  Future<List<ContactWithUsage>> getMostUsedContacts(int limit) async {
    final query = _database.select(_database.contacts).join([
      innerJoin(
        _database.contactUsageStats,
        _database.contactUsageStats.contactId
            .equalsExp(_database.contacts.id),
      ),
    ])
      ..orderBy([
        OrderingTerm.desc(
          _database.contactUsageStats.usageCount,
        ),
      ])
      ..limit(limit);

    final rows = await query.get();
    return rows.map((row) {
      return ContactWithUsage(
        contact: row.readTable(_database.contacts),
        usageCount: row.readTable(_database.contactUsageStats).usageCount,
        lastUsed: row.readTable(_database.contactUsageStats).lastUsed,
      );
    }).toList();
  }

  /// Get recently used contacts
  Future<List<ContactWithUsage>> getRecentlyUsedContacts(int limit) async {
    final query = _database.select(_database.contacts).join([
      innerJoin(
        _database.contactUsageStats,
        _database.contactUsageStats.contactId
            .equalsExp(_database.contacts.id),
      ),
    ])
      ..orderBy([
        OrderingTerm.desc(
          _database.contactUsageStats.lastUsed,
        ),
      ])
      ..limit(limit);

    final rows = await query.get();
    return rows.map((row) {
      return ContactWithUsage(
        contact: row.readTable(_database.contacts),
        usageCount: row.readTable(_database.contactUsageStats).usageCount,
        lastUsed: row.readTable(_database.contactUsageStats).lastUsed,
      );
    }).toList();
  }

  /// Find contact by phone or create if not exists
  Future<int> findOrCreateContactByPhone({
    required String phone,
    required String name,
  }) async {
    // Clean phone number
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Try to find existing contact
    final existingContact = await getContactByPhone(cleanPhone);
    if (existingContact != null) {
      return existingContact.id;
    }

    // Create new contact
    return await createContact(
      ContactsCompanion(
        name: Value(name),
        phone: Value(cleanPhone),
      ),
    );
  }

  /// Get contact statistics
  Future<ContactStatistics> getContactStatistics(int contactId) async {
    final contact = await getContactById(contactId);
    if (contact == null) {
      throw Exception('Contact not found');
    }

    // Get transactions count
    final transactionsCount = await (_database.selectOnly(_database.transactions)
          ..addColumns([_database.transactions.id.count()])
          ..where(_database.transactions.contactId.equals(contactId)))
        .getSingle()
        .then((row) => row.read(_database.transactions.id.count()) ?? 0);

    // Get receivables count
    final receivablesCount = await (_database.selectOnly(_database.receivables)
          ..addColumns([_database.receivables.id.count()])
          ..where(_database.receivables.contactId.equals(contactId)))
        .getSingle()
        .then((row) => row.read(_database.receivables.id.count()) ?? 0);

    // Get payables count
    final payablesCount = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.id.count()])
          ..where(_database.payables.contactId.equals(contactId)))
        .getSingle()
        .then((row) => row.read(_database.payables.id.count()) ?? 0);

    // Get total receivable amount
    final totalReceivable = await (_database.selectOnly(_database.receivables)
          ..addColumns([_database.receivables.amount.sum()])
          ..where(_database.receivables.contactId.equals(contactId))
          ..where(_database.receivables.status.equals('PENDING')))
        .getSingle()
        .then((row) => row.read(_database.receivables.amount.sum()) ?? 0.0);

    // Get total payable amount
    final totalPayable = await (_database.selectOnly(_database.payables)
          ..addColumns([_database.payables.amount.sum()])
          ..where(_database.payables.contactId.equals(contactId))
          ..where(_database.payables.status.equals('PENDING')))
        .getSingle()
        .then((row) => row.read(_database.payables.amount.sum()) ?? 0.0);

    return ContactStatistics(
      contact: contact,
      transactionsCount: transactionsCount,
      receivablesCount: receivablesCount,
      payablesCount: payablesCount,
      totalReceivable: totalReceivable,
      totalPayable: totalPayable,
    );
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

  ContactStatistics({
    required this.contact,
    required this.transactionsCount,
    required this.receivablesCount,
    required this.payablesCount,
    required this.totalReceivable,
    required this.totalPayable,
  });

  double get netBalance => totalReceivable - totalPayable;
}

