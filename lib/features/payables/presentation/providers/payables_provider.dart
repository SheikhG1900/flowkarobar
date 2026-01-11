import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

// Repository provider
final payablesRepositoryProvider = Provider<PayablesRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return PayablesRepository(database);
});

// Watch all payables
final allPayablesProvider = StreamProvider<List<Payable>>((ref) {
  final repository = ref.watch(payablesRepositoryProvider);
  return repository.watchAllPayables();
});

// Watch payables by status
final payablesByStatusProvider = StreamProvider.family<List<Payable>, String>(
  (ref, status) {
    final repository = ref.watch(payablesRepositoryProvider);
    return repository.watchPayablesByStatus(status);
  },
);

// Watch payables with contacts
final payablesWithContactsProvider =
    StreamProvider<List<PayableWithContact>>((ref) {
  final repository = ref.watch(payablesRepositoryProvider);
  return repository.watchPayablesWithContacts();
});

// Get total pending payables
final totalPendingPayablesProvider = FutureProvider<double>((ref) {
  final repository = ref.watch(payablesRepositoryProvider);
  return repository.getTotalPendingPayables();
});

// Watch payables with contacts by status
final payablesWithContactsByStatusProvider =
    StreamProvider.family<List<PayableWithContact>, String>((ref, status) {
  final repository = ref.watch(payablesRepositoryProvider);
  return repository.watchPayablesWithContactsByStatus(status);
});

// Watch pending payables
final pendingPayablesProvider = StreamProvider<List<Payable>>((ref) {
  final repository = ref.watch(payablesRepositoryProvider);
  return repository.watchPayablesByStatus('PENDING');
});

// Watch paid payables
final paidPayablesProvider = StreamProvider<List<Payable>>((ref) {
  final repository = ref.watch(payablesRepositoryProvider);
  return repository.watchPayablesByStatus('PAID');
});

// Watch payables with ALL linked data (contact + transaction + category)
// Uses efficient JOINs to avoid N+1 query problems
final payablesWithLinkedDataProvider =
    StreamProvider.family<List<PayableWithLinkedData>, String>((ref, status) {
  final repository = ref.watch(payablesRepositoryProvider);
  return repository.watchPayablesWithLinkedData(status);
});