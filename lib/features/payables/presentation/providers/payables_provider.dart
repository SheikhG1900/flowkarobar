import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
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

