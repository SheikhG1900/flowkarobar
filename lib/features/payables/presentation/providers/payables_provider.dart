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

// Watch a single payable with linked data by UUID
final payableWithLinkedDataProvider =
    StreamProvider.family<PayableWithLinkedData?, String>((ref, uuid) {
  final repository = ref.watch(payablesRepositoryProvider);
  return repository.watchPayableWithLinkedDataByUuid(uuid);
});

/// Total amount for the current list tab and filters (for list summary).
final payablesListTotalProvider =
    FutureProvider.autoDispose.family<double, String>((ref, status) async {
  ref.watch(payablesPaginatedProvider(status));
  final filters =
      ref.read(payablesPaginatedProvider(status).notifier).currentFilters;
  final repository = ref.watch(payablesRepositoryProvider);
  return repository.getTotalAmountForFilters(filters, status);
});

// Paginated payables provider
class PayablesPaginatedNotifier
    extends Notifier<PaginatedState<PayableWithLinkedData>> {
  PayablesPaginatedNotifier(this.status);

  final String status;

  StreamSubscription<List<PayableWithLinkedData>>? _subscription;
  late PayablesRepository _repository;
  PayableFilters _filters = PayableFilters();
  bool _acceptStreamUpdates = true;

  @override
  PaginatedState<PayableWithLinkedData> build() {
    _acceptStreamUpdates = true;
    _repository = ref.read(payablesRepositoryProvider);
    ref.onDispose(() {
      _acceptStreamUpdates = false;
      _subscription?.cancel();
      _subscription = null;
    });
    Future.microtask(() => _loadInitial());
    return PaginatedState<PayableWithLinkedData>(
      items: [],
      isLoading: true,
    );
  }

  Future<void> _loadInitial() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load first page
      final List<PayableWithLinkedData> initialItems;
      initialItems =
          await _repository.getPayablesWithLinkedDataFilteredPaginated(
        filters: _filters,
        status: status,
        limit: state.pageSize,
        offset: 0,
      );

      if (!ref.mounted || !_acceptStreamUpdates) return;

      state = state.replaceItems(initialItems,
          hasMore: initialItems.length == state.pageSize);

      if (!ref.mounted || !_acceptStreamUpdates) return;

      // Watch for real-time updates to loaded items
      _subscription?.cancel();
      _subscription = _repository
          .watchPayablesWithLinkedDataFilteredPaginated(
        filters: _filters,
        status: status,
        limit: initialItems.length > state.pageSize
            ? initialItems.length
            : state.pageSize,
        offset: 0,
      )
          .listen(_applyStreamPage);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _applyStreamPage(List<PayableWithLinkedData> updatedItems) {
    if (!_acceptStreamUpdates) return;
    try {
      if (!ref.mounted) return;
      if (!state.isLoadingMore) {
        state = state.copyWith(items: updatedItems);
      }
    } catch (_) {}
  }

  Future<void> loadMore() async {
    if (!_acceptStreamUpdates || !ref.mounted) return;
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final List<PayableWithLinkedData> newItems;
      newItems = await _repository.getPayablesWithLinkedDataFilteredPaginated(
        filters: _filters,
        status: status,
        limit: state.pageSize,
        offset: state.currentOffset,
      );

      if (!ref.mounted) return;

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
          status: status,
          limit: state.items.length > state.pageSize
              ? state.items.length
              : state.pageSize,
          offset: 0,
        )
            .listen(_applyStreamPage);
      }
    } catch (e) {
      if (!ref.mounted) return;
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
    String>(PayablesPaginatedNotifier.new);
