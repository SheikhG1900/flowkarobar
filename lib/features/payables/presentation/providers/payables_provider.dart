import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/payables/data/payables_repository.dart';
import 'package:flowpaisa/features/payables/domain/models.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/shared/models/paginated_state.dart';

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

// Watch overdue payables count
final overduePayablesCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(payablesRepositoryProvider);
  return repository
      .watchPayablesWithLinkedDataOverdue()
      .map((payables) => payables.length);
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

// Watch pending payables count
final pendingPayablesCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(payablesRepositoryProvider);
  return repository
      .watchPayablesByStatus('PENDING')
      .map((payables) => payables.length);
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

// Paginated payables provider
class PayablesPaginatedNotifier
    extends Notifier<PaginatedState<PayableWithLinkedData>> {
  StreamSubscription<List<PayableWithLinkedData>>? _subscription;
  late PayablesRepository _repository;
  String? _status;
  bool _isInitialized = false;
  PayableFilters _filters = PayableFilters();

  @override
  PaginatedState<PayableWithLinkedData> build() {
    _repository = ref.watch(payablesRepositoryProvider);
    return PaginatedState<PayableWithLinkedData>(
      items: [],
      isLoading: true,
    );
  }

  void initialize(String status) {
    if (_isInitialized && _status == status) return;
    _status = status;
    _isInitialized = true;
    // Load initial data asynchronously
    Future.microtask(() => _loadInitial());
  }

  Future<void> _loadInitial() async {
    if (_status == null) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load first page
      final List<PayableWithLinkedData> initialItems;
      initialItems =
          await _repository.getPayablesWithLinkedDataFilteredPaginated(
        filters: _filters,
        status: _status!,
        limit: state.pageSize,
        offset: 0,
      );

      state = state.replaceItems(initialItems,
          hasMore: initialItems.length == state.pageSize);

      // Watch for real-time updates to loaded items
      _subscription?.cancel();
      _subscription = _repository
          .watchPayablesWithLinkedDataFilteredPaginated(
        filters: _filters,
        status: _status!,
        limit: initialItems.length > state.pageSize
            ? initialItems.length
            : state.pageSize,
        offset: 0,
      )
          .listen((updatedItems) {
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
      final List<PayableWithLinkedData> newItems;
      newItems = await _repository.getPayablesWithLinkedDataFilteredPaginated(
        filters: _filters,
        status: _status!,
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
        _subscription = _repository
            .watchPayablesWithLinkedDataFilteredPaginated(
          filters: _filters,
          status: _status!,
          limit: state.items.length > state.pageSize
              ? state.items.length
              : state.pageSize,
          offset: 0,
        )
            .listen((updatedItems) {
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

  void applyFilters(PayableFilters filters) {
    _filters = filters;
    _subscription?.cancel();
    state = state.copyWith(items: [], isLoading: true, hasMore: true);
    _loadInitial();
  }

  void updateSearchQuery(String query) {
    if (_filters.searchQuery == query) return;
    applyFilters(_filters.copyWith(searchQuery: query));
  }

  PayableFilters get currentFilters => _filters;

  Future<void> refresh() async {
    _subscription?.cancel();
    await _loadInitial();
  }
}

final payablesPaginatedProvider = NotifierProvider.family<
    PayablesPaginatedNotifier,
    PaginatedState<PayableWithLinkedData>,
    String>((status) {
  final notifier = PayablesPaginatedNotifier();
  notifier.initialize(status);
  return notifier;
});
