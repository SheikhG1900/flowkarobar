import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/receivables/data/receivables_repository.dart';
import 'package:flowpaisa/features/receivables/domain/models.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/shared/models/paginated_state.dart';

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

// Watch overdue receivables count
final overdueReceivablesCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.watchReceivablesWithLinkedDataOverdue().map((receivables) => receivables.length);
});

// Watch receivables with contacts by status
final receivablesWithContactsByStatusProvider =
    StreamProvider.family<List<ReceivableWithContact>, String>((ref, status) {
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.watchReceivablesWithContactsByStatus(status);
});

// Watch pending receivables
final pendingReceivablesProvider = StreamProvider<List<Receivable>>((ref) {
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.watchReceivablesByStatus('PENDING');
});

// Watch pending receivables count
final pendingReceivablesCountProvider = StreamProvider<int>((ref) {
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.watchReceivablesByStatus('PENDING').map((receivables) => receivables.length);
});

// Watch received receivables
final receivedReceivablesProvider = StreamProvider<List<Receivable>>((ref) {
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.watchReceivablesByStatus('RECEIVED');
});

// Watch receivables with ALL linked data (contact + transaction + category)
// Uses efficient JOINs to avoid N+1 query problems
final receivablesWithLinkedDataProvider =
    StreamProvider.family<List<ReceivableWithLinkedData>, String>(
        (ref, status) {
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.watchReceivablesWithLinkedData(status);
});

// Watch a single receivable with linked data by UUID
final receivableWithLinkedDataProvider =
    StreamProvider.family<ReceivableWithLinkedData?, String>((ref, uuid) {
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.watchReceivableWithLinkedDataByUuid(uuid);
});

/// Total amount for the current list tab and filters (for list summary).
final receivablesListTotalProvider =
    FutureProvider.autoDispose.family<double, String>((ref, status) async {
  ref.watch(receivablesPaginatedProvider(status));
  final filters =
      ref.read(receivablesPaginatedProvider(status).notifier).currentFilters;
  final repository = ref.watch(receivablesRepositoryProvider);
  return repository.getTotalAmountForFilters(filters, status);
});

// Paginated receivables provider
class ReceivablesPaginatedNotifier
    extends Notifier<PaginatedState<ReceivableWithLinkedData>> {
  ReceivablesPaginatedNotifier(this.status);

  /// Tab key: PENDING, RECEIVED, OVERDUE, etc. (from [NotifierProvider.family]).
  final String status;

  StreamSubscription<List<ReceivableWithLinkedData>>? _subscription;
  late ReceivablesRepository _repository;
  ReceivableFilters _filters = ReceivableFilters();
  /// Cleared in [Ref.onDispose] before cancel; stream may still deliver one event during Phoenix/rebirth.
  bool _acceptStreamUpdates = true;

  @override
  PaginatedState<ReceivableWithLinkedData> build() {
    _acceptStreamUpdates = true;
    _repository = ref.read(receivablesRepositoryProvider);
    ref.onDispose(() {
      _acceptStreamUpdates = false;
      _subscription?.cancel();
      _subscription = null;
    });
    Future.microtask(() => _loadInitial());
    return PaginatedState<ReceivableWithLinkedData>(
      items: [],
      isLoading: true,
    );
  }

  Future<void> _loadInitial() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load first page
      final List<ReceivableWithLinkedData> initialItems;
      initialItems = await _repository.getReceivablesWithLinkedDataFilteredPaginated(
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
          .watchReceivablesWithLinkedDataFilteredPaginated(
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

  void _applyStreamPage(List<ReceivableWithLinkedData> updatedItems) {
    if (!_acceptStreamUpdates) return;
    try {
      if (!ref.mounted) return;
      if (!state.isLoadingMore) {
        state = state.copyWith(items: updatedItems);
      }
    } catch (_) {
      // Ref/state invalid after dispose (e.g. app rebirth while Drift emits).
    }
  }

  Future<void> loadMore() async {
    if (!_acceptStreamUpdates || !ref.mounted) return;
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final List<ReceivableWithLinkedData> newItems;
      newItems = await _repository.getReceivablesWithLinkedDataFilteredPaginated(
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
            .watchReceivablesWithLinkedDataFilteredPaginated(
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

  void applyFilters(ReceivableFilters filters) {
    _filters = filters;
    _subscription?.cancel();
    state = state.copyWith(items: [], isLoading: true, hasMore: true);
    _loadInitial();
  }

  void updateSearchQuery(String query) {
    if (_filters.searchQuery == query) return;
    applyFilters(_filters.copyWith(searchQuery: query));
  }

  ReceivableFilters get currentFilters => _filters;

  Future<void> refresh() async {
    _subscription?.cancel();
    await _loadInitial();
  }
}

final receivablesPaginatedProvider = NotifierProvider.family<
    ReceivablesPaginatedNotifier,
    PaginatedState<ReceivableWithLinkedData>,
    String>(ReceivablesPaginatedNotifier.new);
