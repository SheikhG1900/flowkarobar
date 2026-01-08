import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/contacts/data/contacts_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

// Repository provider
final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ContactsRepository(database);
});

// Stream providers
final contactsListProvider = StreamProvider<List<Contact>>((ref) {
  final repository = ref.watch(contactsRepositoryProvider);
  return repository.watchAllContacts();
});

final contactsWithUsageProvider = StreamProvider<List<ContactWithUsage>>((ref) {
  final repository = ref.watch(contactsRepositoryProvider);
  return repository.watchContactsWithUsage();
});

// Smart contacts provider (alias for contactsWithUsageProvider for clarity)
final smartContactsProvider = StreamProvider<List<ContactWithUsage>>((ref) {
  final repository = ref.watch(contactsRepositoryProvider);
  return repository.watchContactsWithUsage();
});

// Search provider
final contactsSearchProvider = StreamProvider.family<List<Contact>, String>((ref, query) {
  final repository = ref.watch(contactsRepositoryProvider);
  if (query.isEmpty) {
    return repository.watchAllContacts();
  }
  return repository.searchContactsByName(query);
});

// Stats provider
final contactStatisticsProvider = FutureProvider.family<ContactStatistics, int>((ref, contactId) {
  final repository = ref.watch(contactsRepositoryProvider);
  return repository.getContactStatistics(contactId);
});
