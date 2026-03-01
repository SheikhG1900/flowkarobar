import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/features/transactions/data/schedules_repository.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/shared/models/paginated_state.dart';

import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';

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

// Watch all schedules with category and contact details
final allSchedulesWithDetailsProvider =
    StreamProvider<List<ScheduleWithDetails>>((ref) {
  final repository = ref.watch(schedulesRepositoryProvider);
  return repository.watchAllSchedulesWithDetails();
});

// Watch a single schedule with details by UUID
final scheduleWithDetailsProvider =
    StreamProvider.family<ScheduleWithDetails?, String>((ref, uuid) {
  final repository = ref.watch(schedulesRepositoryProvider);
  return repository.watchScheduleWithDetailsByUuid(uuid);
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

  // Explicitly watch the underlying table to ensure refresh after sync
  ref.watch(allTransactionsProvider);

  return repository.watchTransactionsWithDetails();
});

// Watch a single transaction with details by UUID
final transactionWithDetailsProvider =
    StreamProvider.family<TransactionWithDetails?, String>((ref, uuid) {
  final repository = ref.watch(transactionsRepositoryProvider);

  // Also watch all transactions, payables, and receivables to ensure we refresh
  // when any related data changes (e.g. when a linked entry is marked as paid)
  ref.watch(allTransactionsProvider);
  ref.watch(allPayablesProvider);
  ref.watch(allReceivablesProvider);

  return repository.watchTransactionWithDetailsByUuid(uuid);
});

/// All transactions in the same split group as the given transaction (for group edit / sibling list).
final transactionGroupProvider =
    StreamProvider.family<List<TransactionWithDetails>, String>(
        (ref, transactionUuid) {
  final repository = ref.watch(transactionsRepositoryProvider);

  // Watch all transactions, payables, and receivables to ensure we refresh
  // when any transaction in the group or its linked entries change
  ref.watch(allTransactionsProvider);
  ref.watch(allPayablesProvider);
  ref.watch(allReceivablesProvider);

  // First get the transaction to find its linkedGroupId
  // We use watchTransactionWithDetailsByUuid to get the initial item and its groupId
  return repository
      .watchTransactionWithDetailsByUuid(transactionUuid)
      .switchMap((item) {
    if (item == null) return Stream.value(<TransactionWithDetails>[]);
    final linkedGroupId = item.transaction.linkedGroupId;
    if (linkedGroupId == null || linkedGroupId.isEmpty)
      return Stream.value([item]);

    // Watch the entire group. This stream will emit whenever any transaction,
    // payable, or receivable in the group changes because of the JOIN in the repository method.
    return repository
        .watchTransactionsWithDetailsByLinkedGroupId(linkedGroupId);
  });
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
  TransactionFilters _filters = TransactionFilters();

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
      initialItems =
          await _repository.getTransactionsWithDetailsFilteredPaginated(
        filters: _filters,
        searchQuery: _searchQuery,
        limit: state.pageSize,
        offset: 0,
      );

      state = state.replaceItems(initialItems,
          hasMore: initialItems.length == state.pageSize);

      // Watch for real-time updates to loaded items
      _subscription?.cancel();
      final stream = _repository.watchTransactionsWithDetailsFilteredPaginated(
        filters: _filters,
        searchQuery: _searchQuery,
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
      newItems = await _repository.getTransactionsWithDetailsFilteredPaginated(
        filters: _filters,
        searchQuery: _searchQuery,
        limit: state.pageSize,
        offset: state.currentOffset,
      );

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
        final stream =
            _repository.watchTransactionsWithDetailsFilteredPaginated(
          filters: _filters,
          searchQuery: _searchQuery,
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

  Future<void> applyFilters(TransactionFilters filters) async {
    _filters = filters;
    _subscription?.cancel();
    state = state.copyWith(items: [], isLoading: true, hasMore: true);
    await _loadInitial();
  }

  TransactionFilters get currentFilters => _filters;

  Future<void> refresh() async {
    _subscription?.cancel();
    await _loadInitial();
  }
}

final transactionsPaginatedProvider = NotifierProvider<
    TransactionsPaginatedNotifier, PaginatedState<TransactionWithDetails>>(() {
  return TransactionsPaginatedNotifier();
});
