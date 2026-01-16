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

// Paginated receivables provider
class ReceivablesPaginatedNotifier
    extends Notifier<PaginatedState<ReceivableWithLinkedData>> {
  StreamSubscription<List<ReceivableWithLinkedData>>? _subscription;
  late ReceivablesRepository _repository;
  String? _status;
  bool _isInitialized = false;

  @override
  PaginatedState<ReceivableWithLinkedData> build() {
    _repository = ref.watch(receivablesRepositoryProvider);
    return PaginatedState<ReceivableWithLinkedData>(
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
      final List<ReceivableWithLinkedData> initialItems;
      if (_status == 'OVERDUE') {
        initialItems =
            await _repository.getReceivablesWithLinkedDataPaginatedOverdue(
          limit: state.pageSize,
          offset: 0,
        );
      } else {
        initialItems = await _repository.getReceivablesWithLinkedDataPaginated(
          status: _status!,
          limit: state.pageSize,
          offset: 0,
        );
      }

      state = state.replaceItems(initialItems,
          hasMore: initialItems.length == state.pageSize);

      // Watch for real-time updates to loaded items
      _subscription?.cancel();
      if (_status == 'OVERDUE') {
        _subscription = _repository
            .watchReceivablesWithLinkedDataPaginatedOverdue(
          limit: initialItems.length,
          offset: 0,
        )
            .listen((updatedItems) {
          if (!state.isLoadingMore) {
            state = state.copyWith(items: updatedItems);
          }
        });
      } else {
        _subscription = _repository
            .watchReceivablesWithLinkedDataPaginated(
          status: _status!,
          limit: initialItems.length,
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
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final List<ReceivableWithLinkedData> newItems;
      if (_status == 'OVERDUE') {
        newItems =
            await _repository.getReceivablesWithLinkedDataPaginatedOverdue(
          limit: state.pageSize,
          offset: state.currentOffset,
        );
      } else {
        newItems = await _repository.getReceivablesWithLinkedDataPaginated(
          status: _status!,
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
        if (_status == 'OVERDUE') {
          _subscription = _repository
              .watchReceivablesWithLinkedDataPaginatedOverdue(
            limit: state.items.length,
            offset: 0,
          )
              .listen((updatedItems) {
            if (!state.isLoadingMore) {
              state = state.copyWith(items: updatedItems);
            }
          });
        } else {
          _subscription = _repository
              .watchReceivablesWithLinkedDataPaginated(
            status: _status!,
            limit: state.items.length,
            offset: 0,
          )
              .listen((updatedItems) {
            if (!state.isLoadingMore) {
              state = state.copyWith(items: updatedItems);
            }
          });
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    _subscription?.cancel();
    await _loadInitial();
  }
}

final receivablesPaginatedProvider = NotifierProvider.family<
    ReceivablesPaginatedNotifier,
    PaginatedState<ReceivableWithLinkedData>,
    String>((status) {
  final notifier = ReceivablesPaginatedNotifier();
  notifier.initialize(status);
  return notifier;
});
