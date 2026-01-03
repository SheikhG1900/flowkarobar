import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';

// Repository provider
final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TransactionsRepository(database);
});

// Watch all transactions
final allTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final repository = ref.watch(transactionsRepositoryProvider);
  return repository.watchAllTransactions();
});

// Watch transactions by date range
final transactionsByDateRangeProvider = StreamProvider.family<List<Transaction>, DateRange>(
  (ref, dateRange) {
    final repository = ref.watch(transactionsRepositoryProvider);
    return repository.watchTransactionsByDateRange(
      dateRange.start,
      dateRange.end,
    );
  },
);

// Watch transactions by type
final transactionsByTypeProvider = StreamProvider.family<List<Transaction>, String>(
  (ref, type) {
    final repository = ref.watch(transactionsRepositoryProvider);
    return repository.watchTransactionsByType(type);
  },
);

// Date range model
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}


