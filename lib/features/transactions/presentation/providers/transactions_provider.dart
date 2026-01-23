import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/transactions/data/schedules_repository.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/shared/models/paginated_state.dart';

// Repository provider
final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TransactionsRepository(database);
});

// Schedules repository provider
final schedulesRepositoryProvider = Provider<SchedulesRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return SchedulesRepository(database);
});

// Watch all schedules
final allSchedulesProvider = StreamProvider<List<TransactionSchedule>>((ref) {
  final repository = ref.watch(schedulesRepositoryProvider);
  return repository.watchAllSchedules();
});

// Watch all transactions
final allTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final repository = ref.watch(transactionsRepositoryProvider);
  return repository.watchAllTransactions();
});

// Watch transactions with category details
final transactionsWithCategoryProvider =
    StreamProvider<List<TransactionWithCategory>>((ref) {
  final repository = ref.watch(transactionsRepositoryProvider);
  return repository.watchTransactionsWithCategory();
});

// Watch transactions with ALL details (category + contact)
// Uses efficient JOINs to avoid N+1 query problems
final transactionsWithDetailsProvider =
    StreamProvider<List<TransactionWithDetails>>((ref) {
  final repository = ref.watch(transactionsRepositoryProvider);
  return repository.watchTransactionsWithDetails();
});

// Watch transactions by date range
final transactionsByDateRangeProvider =
    StreamProvider.family<List<Transaction>, DateRange>(
  (ref, dateRange) {
    final repository = ref.watch(transactionsRepositoryProvider);
    return repository.watchTransactionsByDateRange(
      dateRange.start,
      dateRange.end,
    );
  },
);

// Watch transactions by type
final transactionsByTypeProvider =
    StreamProvider.family<List<Transaction>, String>(
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

// Paginated transactions provider
class TransactionsPaginatedNotifier
    extends Notifier<PaginatedState<TransactionWithDetails>> {
  StreamSubscription<List<TransactionWithDetails>>? _subscription;
  late TransactionsRepository _repository;
  String _searchQuery = '';

  @override
  PaginatedState<TransactionWithDetails> build() {
    _repository = ref.watch(transactionsRepositoryProvider);
    // Load initial data asynchronously
    Future.microtask(() => _loadInitial());

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return PaginatedState<TransactionWithDetails>(
      items: [],
      isLoading: true,
    );
  }

  Future<void> _loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load first page
      final List<TransactionWithDetails> initialItems;
      if (_searchQuery.isEmpty) {
        initialItems = await _repository.getTransactionsWithDetailsPaginated(
          limit: state.pageSize,
          offset: 0,
        );
      } else {
        initialItems =
            await _repository.getTransactionsWithDetailsSearchPaginated(
          query: _searchQuery,
          limit: state.pageSize,
          offset: 0,
        );
      }

      state = state.replaceItems(initialItems,
          hasMore: initialItems.length == state.pageSize);

      // Watch for real-time updates to loaded items
      _subscription?.cancel();
      final stream = _searchQuery.isEmpty
          ? _repository.watchTransactionsWithDetailsPaginated(
              limit: initialItems.length > state.pageSize
                  ? initialItems.length
                  : state.pageSize,
              offset: 0,
            )
          : _repository.watchTransactionsWithDetailsSearchPaginated(
              query: _searchQuery,
              limit: initialItems.length > state.pageSize
                  ? initialItems.length
                  : state.pageSize,
              offset: 0,
            );

      _subscription = stream.listen((updatedItems) {
        if (!state.isLoadingMore) {
          state = state.copyWith(items: updatedItems);
        }
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final List<TransactionWithDetails> newItems;
      if (_searchQuery.isEmpty) {
        newItems = await _repository.getTransactionsWithDetailsPaginated(
          limit: state.pageSize,
          offset: state.currentOffset,
        );
      } else {
        newItems = await _repository.getTransactionsWithDetailsSearchPaginated(
          query: _searchQuery,
          limit: state.pageSize,
          offset: state.currentOffset,
        );
      }

      if (newItems.isEmpty) {
        state = state.copyWith(
          isLoadingMore: false,
          hasMore: false,
        );
      } else {
        state = state.appendItems(
          newItems,
          hasMore: newItems.length == state.pageSize,
        );

        // Update subscription to watch all loaded items
        _subscription?.cancel();
        final stream = _searchQuery.isEmpty
            ? _repository.watchTransactionsWithDetailsPaginated(
                limit: state.items.length > state.pageSize
                    ? state.items.length
                    : state.pageSize,
                offset: 0,
              )
            : _repository.watchTransactionsWithDetailsSearchPaginated(
                query: _searchQuery,
                limit: state.items.length > state.pageSize
                    ? state.items.length
                    : state.pageSize,
                offset: 0,
              );

        _subscription = stream.listen((updatedItems) {
          if (!state.isLoadingMore) {
            state = state.copyWith(items: updatedItems);
          }
        });
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> search(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _subscription?.cancel();
    state = state.copyWith(items: [], isLoading: true, hasMore: true);
    await _loadInitial();
  }

  Future<void> refresh() async {
    _subscription?.cancel();
    await _loadInitial();
  }
}

final transactionsPaginatedProvider = NotifierProvider<
    TransactionsPaginatedNotifier, PaginatedState<TransactionWithDetails>>(() {
  return TransactionsPaginatedNotifier();
});
