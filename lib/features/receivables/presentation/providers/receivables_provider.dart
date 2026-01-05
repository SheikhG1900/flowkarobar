import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

// Repository provider
final receivablesRepositoryProvider = Provider<ReceivablesRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ReceivablesRepository(database);
});

// Watch all receivables
final allReceivablesProvider = StreamProvider<List<Receivable>>((ref) {
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.watchAllReceivables();
});

// Watch receivables by status
final receivablesByStatusProvider =
    StreamProvider.family<List<Receivable>, String>(
  (ref, status) {
    final repository = ref.watch(receivablesRepositoryProvider);
    return repository.watchReceivablesByStatus(status);
  },
);

// Watch receivables with contacts
final receivablesWithContactsProvider =
    StreamProvider<List<ReceivableWithContact>>((ref) {
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.watchReceivablesWithContacts();
});

// Get total pending receivables
final totalPendingReceivablesProvider = FutureProvider<double>((ref) {
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.getTotalPendingReceivables();
});

// Watch pending receivables
final pendingReceivablesProvider = StreamProvider<List<Receivable>>((ref) {
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.watchReceivablesByStatus('PENDING');
});

// Watch received receivables
final receivedReceivablesProvider = StreamProvider<List<Receivable>>((ref) {
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.watchReceivablesByStatus('RECEIVED');
});

