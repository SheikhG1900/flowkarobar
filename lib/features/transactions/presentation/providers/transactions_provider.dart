import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' hide Category;
import 'package:rxdart/rxdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/features/transactions/data/transactions_repository.dart';
import 'package:flowpaisa/core/utils/export_service.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/data/schedules_repository.dart';
import 'package:flowpaisa/features/transactions/data/transaction_documents_repository.dart';
import 'package:flowpaisa/core/services/document_backup_service.dart';
import 'package:flowpaisa/features/backup/presentation/providers/backup_provider.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transaction_service_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/shared/models/paginated_state.dart';
import 'package:collection/collection.dart';

import 'package:flowpaisa/features/payables/presentation/providers/payables_provider.dart';
import 'package:flowpaisa/features/receivables/presentation/providers/receivables_provider.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Repository provider
final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final activeCashbook = ref.watch(activeCashbookProvider);
  return TransactionsRepository(database, activeCashbook.id);
});

// Transaction Documents Repository provider
final transactionDocumentsRepositoryProvider = Provider<TransactionDocumentsRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final activeCashbook = ref.watch(activeCashbookProvider);
  return TransactionDocumentsRepository(database, activeCashbook.id);
});

// Document Backup Service provider
final documentBackupServiceProvider = Provider<DocumentBackupService>((ref) {
  final docRepo = ref.watch(transactionDocumentsRepositoryProvider);
  final database = ref.watch(databaseProvider);
  final driveService = ref.watch(googleDriveServiceProvider);
  return DocumentBackupService(docRepo, database, driveService);
});

// Provider to check if document backup/sync is required
final documentSyncRequiredProvider = NotifierProvider<DocumentSyncRequiredNotifier, bool>(() {
  return DocumentSyncRequiredNotifier();
});

class DocumentSyncRequiredNotifier extends Notifier<bool> {
  late String _cashbookId;
  late SharedPreferences _prefs;
  StreamSubscription? _subscription;

  @override
  bool build() {
    final activeCashbook = ref.watch(activeCashbookProvider);
    _cashbookId = activeCashbook.id;
    _prefs = ref.watch(sharedPreferencesProvider);

    _init();

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return _prefs.getBool(_prefKey) ?? false;
  }

  String get _prefKey => 'document_sync_required_$_cashbookId';

  void _init() {
    _subscription?.cancel();

    // Listen to changes in the transaction documents table
    final db = ref.read(databaseProvider);
    _subscription = db.select(db.transactionDocuments).watch().listen((docs) {
      if (!ref.mounted) return;

      final txs = ref.read(allTransactionsProvider).value ?? [];
      final activeTxUuids = txs.map((t) => t.uuid).toSet();

      // Only evaluate documents belonging to the transactions of the current Cashbook
      final cashbookDocs = docs.where((d) => activeTxUuids.contains(d.transactionUuid)).toList();

      if (cashbookDocs.isNotEmpty && !state) {
        final lastExportTimeStr = _prefs.getString('last_document_export_$_cashbookId');
        if (lastExportTimeStr == null) {
          setSyncRequired(true);
        } else {
          final lastExportTime = DateTime.parse(lastExportTimeStr);
          // Check 'updatedAt' instead of 'createdAt' to capture both updates and soft deletions!
          final hasChanges = cashbookDocs.any((d) => d.updatedAt.isAfter(lastExportTime));
          if (hasChanges) {
            setSyncRequired(true);
          }
        }
      }
    });
  }

  void setSyncRequired(bool required) {
    _prefs.setBool(_prefKey, required);
    state = required;
  }

  void markExportSuccessful() {
    _prefs.setString('last_document_export_$_cashbookId', DateTime.now().toIso8601String());
    setSyncRequired(false);
  }
}

// Watch documents for a specific transaction
final transactionDocumentsProvider = StreamProvider.family<List<TransactionDocument>, String>((ref, transactionUuid) {
  final repository = ref.watch(transactionDocumentsRepositoryProvider);
  return repository.watchDocumentsForTransaction(transactionUuid);
});

// Watch all documents
final allDocumentsProvider = StreamProvider<List<TransactionDocument>>((ref) {
  final repository = ref.watch(transactionDocumentsRepositoryProvider);
  return repository.watchAllDocuments();
});

// Watch all display documents including orphans
final displayDocumentsProvider = StreamProvider<List<DisplayDocument>>((ref) async* {
  final docsAsync = ref.watch(allDocumentsProvider);
  final txsAsync = ref.watch(allTransactionsProvider);
  final docRepo = ref.watch(transactionDocumentsRepositoryProvider);

  final docs = docsAsync.value ?? [];
  final txs = txsAsync.value ?? [];

  final docDir = await docRepo.getDocumentsDirectory();

  List<File> physicalFiles = [];
  if (await docDir.exists()) {
    try {
      physicalFiles = docDir
          .listSync()
          .whereType<File>()
          .toList();
    } catch (_) {}
  }

  final dbDocsMap = {for (final doc in docs) doc.fileName: doc};
  final activeTxUuids = txs.map((t) => t.uuid).toSet();

  final List<DisplayDocument> displayDocs = [];

  // 1. Process DB documents
  for (final doc in docs) {
    final file = File(p.join(docDir.path, doc.fileName));
    final fileExists = await file.exists();
    final txExists = activeTxUuids.contains(doc.transactionUuid);
    final isOrphan = !txExists || !fileExists;

    displayDocs.add(DisplayDocument(
      uuid: doc.uuid,
      fileName: doc.fileName,
      originalName: doc.originalName,
      fileSize: doc.fileSize,
      mimeType: doc.mimeType,
      createdAt: doc.createdAt,
      isOrphan: isOrphan,
      file: file,
      dbDoc: doc,
      isMissingPhysicalFile: !fileExists,
    ));
  }

  // 2. Process physical-only orphan files
  for (final file in physicalFiles) {
    final fileName = p.basename(file.path);
    if (!dbDocsMap.containsKey(fileName)) {
      final stat = file.statSync();
      final ext = p.extension(file.path).toLowerCase().replaceAll('.', '');
      String mimeType = 'application/octet-stream';
      if (ext == 'pdf') {
        mimeType = 'application/pdf';
      } else if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) {
        mimeType = 'image/$ext';
      }
      displayDocs.add(DisplayDocument(
        uuid: fileName,
        fileName: fileName,
        originalName: fileName,
        fileSize: stat.size,
        mimeType: mimeType,
        createdAt: stat.changed,
        isOrphan: true,
        file: file,
        dbDoc: null,
        isMissingPhysicalFile: false,
      ));
    }
  }

  displayDocs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  yield displayDocs;
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

  return repository
      .watchTransactionsWithDetails()
      .distinct((prev, next) => const ListEquality().equals(prev, next))
      .debounceTime(const Duration(milliseconds: 100));
});

// Watch a single transaction with details by UUID
final transactionWithDetailsProvider =
    StreamProvider.family<TransactionWithDetails?, String>((ref, uuid) {
  final repository = ref.watch(transactionsRepositoryProvider);

  return repository
      .watchTransactionWithDetailsByUuid(uuid)
      .distinct((prev, next) => prev == next)
      .debounceTime(const Duration(milliseconds: 100));
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

/// All transactions that share the same UUID prefix (e.g. scheduleUuid_YYYYMMDD).
final relatedTransactionsProvider =
    StreamProvider.family<List<TransactionWithDetails>, String>(
        (ref, transactionUuid) {
  final repository = ref.watch(transactionsRepositoryProvider);

  return repository
      .watchTransactionWithDetailsByUuid(transactionUuid)
      .switchMap((item) {
    if (item == null) return Stream.value(<TransactionWithDetails>[]);

    final uuid = item.transaction.uuid;
    // Relaxed regex: everything before the last underscore is the prefix
    final match = RegExp(r'(.+)_(\d+)').firstMatch(uuid);
    if (match == null) return Stream.value(<TransactionWithDetails>[]);

    final prefix = match.group(1)!;

    return repository.watchTransactionsWithDetailsByUuidPrefix(prefix).map((list) {
      // Include all transactions with the same prefix (including the current one)
      return list;
    });
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
  bool _acceptStreamUpdates = true;

  @override
  PaginatedState<TransactionWithDetails> build() {
    // Watch activeCashbookProvider so that when the cashbook changes,
    // this notifier's build() is re-run, resetting the state and loading the new cashbook's transactions.
    ref.watch(activeCashbookProvider);

    _acceptStreamUpdates = true;
    _repository = ref.read(transactionsRepositoryProvider);

    ref.onDispose(() {
      _acceptStreamUpdates = false;
      _subscription?.cancel();
      _subscription = null;
    });

    // Load initial data asynchronously
    Future.microtask(() => _loadInitial());

    return PaginatedState<TransactionWithDetails>(
      items: [],
      isLoading: true,
      filters: TransactionFilters(),
      searchQuery: '',
    );
  }

  Future<void> _loadInitial() async {
    _repository = ref.read(transactionsRepositoryProvider);

    // Do not set isLoading: true if we already have items to prevent flickering
    if (state.items.isEmpty) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      // Load first page
      final List<TransactionWithDetails> initialItems;
      initialItems =
          await _repository.getTransactionsWithDetailsFilteredPaginated(
        filters: state.filters ?? TransactionFilters(),
        searchQuery: state.searchQuery ?? '',
        limit: state.pageSize,
        offset: 0,
      );

      if (!ref.mounted) return;

      state = state.replaceItems(initialItems,
          hasMore: initialItems.length == state.pageSize);

      // Watch for real-time updates to loaded items
      _subscription?.cancel();
      final stream = _repository.watchTransactionsWithDetailsFilteredPaginated(
        filters: state.filters ?? TransactionFilters(),
        searchQuery: state.searchQuery ?? '',
        limit: state.items.length > state.pageSize
            ? state.items.length
            : state.pageSize,
        offset: 0,
      );

      _subscription = stream
          .distinct((prev, next) => const ListEquality().equals(prev, next))
          .debounceTime(const Duration(milliseconds: 100))
          .listen(_applyStreamPage);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void _applyStreamPage(List<TransactionWithDetails> updatedItems) {
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
      final List<TransactionWithDetails> newItems;
      newItems = await _repository.getTransactionsWithDetailsFilteredPaginated(
        filters: state.filters ?? TransactionFilters(),
        searchQuery: state.searchQuery ?? '',
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
        final stream =
            _repository.watchTransactionsWithDetailsFilteredPaginated(
          filters: state.filters ?? TransactionFilters(),
          searchQuery: state.searchQuery ?? '',
          limit: state.items.length,
          offset: 0,
        );

        _subscription = stream
            .distinct((prev, next) => const ListEquality().equals(prev, next))
            .debounceTime(const Duration(milliseconds: 100))
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

  Future<void> search(String query) async {
    if (state.searchQuery == query) return;
    _subscription?.cancel();
    // Only show loading if we are starting a new search
    state = state.copyWith(
        items: [], isLoading: true, hasMore: true, searchQuery: query);
    await _loadInitial();
  }

  Future<void> applyFilters(TransactionFilters filters) async {
    if (state.filters == filters) return;
    _subscription?.cancel();
    // Only show loading if we are applying new filters
    state = state.copyWith(
        items: [], isLoading: true, hasMore: true, filters: filters);
    await _loadInitial();
  }

  TransactionFilters get currentFilters => state.filters ?? TransactionFilters();

  Future<void> refresh() async {
    _subscription?.cancel();
    await _loadInitial();
  }
}

final transactionsPaginatedProvider = NotifierProvider<
    TransactionsPaginatedNotifier, PaginatedState<TransactionWithDetails>>(() {
  return TransactionsPaginatedNotifier();
});

class RecentSearch {
  final String id;
  final String name;
  final String searchQuery;
  final String? type; // 'INCOME', 'EXPENSE', or null
  final List<String>? categoryUuids;
  final List<String>? contactUuids;
  final List<String>? accountUuids;
  final double? minAmount;
  final double? maxAmount;
  final List<String>? statusCodes;
  final DateTime timestamp;

  RecentSearch({
    required this.id,
    required this.name,
    this.searchQuery = '',
    this.type,
    this.categoryUuids,
    this.contactUuids,
    this.accountUuids,
    this.minAmount,
    this.maxAmount,
    this.statusCodes,
    required this.timestamp,
    this.isPinned = false,
  });

  final bool isPinned;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'searchQuery': searchQuery,
      'type': type,
      'categoryUuids': categoryUuids,
      'contactUuids': contactUuids,
      'accountUuids': accountUuids,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
      'statusCodes': statusCodes,
      'timestamp': timestamp.toIso8601String(),
      'isPinned': isPinned,
    };
  }

  factory RecentSearch.fromJson(Map<String, dynamic> json) {
    return RecentSearch(
      id: json['id'] as String,
      name: json['name'] as String,
      searchQuery: json['searchQuery'] as String? ?? '',
      type: json['type'] as String?,
      categoryUuids: (json['categoryUuids'] as List<dynamic>?)?.map((e) => e as String).toList(),
      contactUuids: (json['contactUuids'] as List<dynamic>?)?.map((e) => e as String).toList(),
      accountUuids: (json['accountUuids'] as List<dynamic>?)?.map((e) => e as String).toList(),
      minAmount: (json['minAmount'] as num?)?.toDouble(),
      maxAmount: (json['maxAmount'] as num?)?.toDouble(),
      statusCodes: (json['statusCodes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  String generateDefaultName({
    required List<Category> categories,
    required List<Contact> contacts,
    required List<Account> accounts,
  }) {
    final parts = <String>[];

    if (searchQuery.trim().isNotEmpty) {
      parts.add('"${searchQuery.trim()}"');
    }

    if (type != null) {
      parts.add(type == 'INCOME' ? 'Income' : 'Expense');
    }

    if (categoryUuids != null && categoryUuids!.isNotEmpty) {
      final names = categoryUuids!
          .map((uuid) => categories.firstWhereOrNull((c) => c.uuid == uuid)?.name)
          .whereNotNull()
          .join(', ');
      if (names.isNotEmpty) {
        parts.add('in $names');
      }
    }

    if (contactUuids != null && contactUuids!.isNotEmpty) {
      final names = contactUuids!
          .map((uuid) => contacts.firstWhereOrNull((c) => c.uuid == uuid)?.name)
          .whereNotNull()
          .join(', ');
      if (names.isNotEmpty) {
        parts.add('with $names');
      }
    }

    if (accountUuids != null && accountUuids!.isNotEmpty) {
      final namesList = accountUuids!
          .map((uuid) {
            if (uuid == 'no_account') return 'No Account';
            return accounts.firstWhereOrNull((a) => a.uuid == uuid)?.name;
          })
          .whereNotNull()
          .toList();
      final names = namesList.join(', ');
      if (names.isNotEmpty) {
        parts.add('from $names');
      }
    }

    if (minAmount != null && maxAmount != null) {
      parts.add('amount $minAmount - $maxAmount');
    } else if (minAmount != null) {
      parts.add('amount >= $minAmount');
    } else if (maxAmount != null) {
      parts.add('amount <= $maxAmount');
    }

    if (statusCodes != null && statusCodes!.isNotEmpty) {
      parts.add('status: ${statusCodes!.join(", ")}');
    }

    if (parts.isEmpty) {
      return 'All Transactions';
    }

    return parts.join(' ');
  }
}

class RecentSearchesNotifier extends Notifier<List<RecentSearch>> {
  static const _key = 'recent_transaction_searches';

  @override
  List<RecentSearch> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonStrList = prefs.getStringList(_key) ?? [];
    try {
      return jsonStrList
          .map((str) => RecentSearch.fromJson(json.decode(str) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) {
          // Pinned items stay at the top, then sort by timestamp
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.timestamp.compareTo(a.timestamp);
        });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading recent searches: $e');
      }
      return [];
    }
  }

  Future<void> saveSearch({
    required String searchQuery,
    required TransactionFilters filters,
  }) async {
    // Exclude date filters for simplicity
    final cleanFilters = filters.copyWith(
      clearStartDate: true,
      clearEndDate: true,
    );

    // If both query and filters are empty, don't save
    if (searchQuery.trim().isEmpty && cleanFilters.isEmpty) {
      return;
    }

    final prefs = ref.read(sharedPreferencesProvider);
    
    // Check if an identical search already exists (ignoring id, name, timestamp)
    final existingIndex = state.indexWhere((item) {
      final itemFilters = TransactionFilters(
        type: item.type,
        categoryUuids: item.categoryUuids,
        contactUuids: item.contactUuids,
        accountUuids: item.accountUuids,
        minAmount: item.minAmount,
        maxAmount: item.maxAmount,
        statusCodes: item.statusCodes,
      );
      return item.searchQuery == searchQuery && itemFilters == cleanFilters;
    });

    List<RecentSearch> updatedList = List.from(state);

    if (existingIndex != -1) {
      // Move existing to top (unless pinned, keep order) by updating timestamp
      final existing = updatedList.removeAt(existingIndex);
      updatedList.insert(
        0,
        RecentSearch(
          id: existing.id,
          name: existing.name, // Keep the custom name if renamed
          searchQuery: existing.searchQuery,
          type: existing.type,
          categoryUuids: existing.categoryUuids,
          contactUuids: existing.contactUuids,
          accountUuids: existing.accountUuids,
          minAmount: existing.minAmount,
          maxAmount: existing.maxAmount,
          statusCodes: existing.statusCodes,
          timestamp: DateTime.now(),
          isPinned: existing.isPinned,
        ),
      );
    } else {
      // Generate default name
      final categories = ref.read(categoriesListProvider).value ?? [];
      final contacts = ref.read(contactsListProvider).value ?? [];
      final accounts = ref.read(accountsStreamProvider).value ?? [];

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      
      final tempSearch = RecentSearch(
        id: id,
        name: '',
        searchQuery: searchQuery,
        type: cleanFilters.type,
        categoryUuids: cleanFilters.categoryUuids,
        contactUuids: cleanFilters.contactUuids,
        accountUuids: cleanFilters.accountUuids,
        minAmount: cleanFilters.minAmount,
        maxAmount: cleanFilters.maxAmount,
        statusCodes: cleanFilters.statusCodes,
        timestamp: DateTime.now(),
      );

      final defaultName = tempSearch.generateDefaultName(
        categories: categories,
        contacts: contacts,
        accounts: accounts,
      );

      final newSearch = RecentSearch(
        id: id,
        name: defaultName,
        searchQuery: searchQuery,
        type: cleanFilters.type,
        categoryUuids: cleanFilters.categoryUuids,
        contactUuids: cleanFilters.contactUuids,
        accountUuids: cleanFilters.accountUuids,
        minAmount: cleanFilters.minAmount,
        maxAmount: cleanFilters.maxAmount,
        statusCodes: cleanFilters.statusCodes,
        timestamp: DateTime.now(),
      );

      updatedList.insert(0, newSearch);
    }

    // Limit to 20 recent searches, but don't delete pinned ones if possible
    if (updatedList.length > 20) {
      // Keep pinned ones and fill the rest with unpinned ones up to 20
      final pinned = updatedList.where((item) => item.isPinned).toList();
      final unpinned = updatedList.where((item) => !item.isPinned).toList();
      final allowedUnpinnedCount = 20 - pinned.length;
      if (allowedUnpinnedCount > 0) {
        updatedList = [...pinned, ...unpinned.sublist(0, allowedUnpinnedCount)];
      } else {
        updatedList = pinned.sublist(0, 20);
      }
    }

    // Sort to ensure pinned are at top
    updatedList.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.timestamp.compareTo(a.timestamp);
    });

    state = updatedList;
    await _saveToPrefs(prefs);
  }

  Future<void> renameSearch(String id, String newName) async {
    if (newName.trim().isEmpty) return;
    final prefs = ref.read(sharedPreferencesProvider);
    state = state.map((item) {
      if (item.id == id) {
        return RecentSearch(
          id: item.id,
          name: newName.trim(),
          searchQuery: item.searchQuery,
          type: item.type,
          categoryUuids: item.categoryUuids,
          contactUuids: item.contactUuids,
          accountUuids: item.accountUuids,
          minAmount: item.minAmount,
          maxAmount: item.maxAmount,
          statusCodes: item.statusCodes,
          timestamp: item.timestamp,
          isPinned: item.isPinned,
        );
      }
      return item;
    }).toList();
    await _saveToPrefs(prefs);
  }

  Future<void> togglePinSearch(String id) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = state.map((item) {
      if (item.id == id) {
        return RecentSearch(
          id: item.id,
          name: item.name,
          searchQuery: item.searchQuery,
          type: item.type,
          categoryUuids: item.categoryUuids,
          contactUuids: item.contactUuids,
          accountUuids: item.accountUuids,
          minAmount: item.minAmount,
          maxAmount: item.maxAmount,
          statusCodes: item.statusCodes,
          timestamp: item.timestamp,
          isPinned: !item.isPinned,
        );
      }
      return item;
    }).toList()
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.timestamp.compareTo(a.timestamp);
      });
    await _saveToPrefs(prefs);
  }

  Future<void> deleteSearch(String id) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = state.where((item) => item.id != id).toList();
    await _saveToPrefs(prefs);
  }

  Future<void> clearHistory() async {
    final prefs = ref.read(sharedPreferencesProvider);
    // Only clear unpinned searches!
    state = state.where((item) => item.isPinned).toList();
    await _saveToPrefs(prefs);
  }

  Future<void> _saveToPrefs(SharedPreferences prefs) async {
    final jsonList = state.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }
}

final recentSearchesProvider = NotifierProvider<RecentSearchesNotifier, List<RecentSearch>>(() {
  return RecentSearchesNotifier();
});

// Centralized Export Service provider
final exportServiceProvider = Provider<ExportService>((ref) {
  final db = ref.watch(databaseProvider);
  final userProfile = ref.watch(userProfileProvider);
  final transactionsRepository = ref.watch(transactionsRepositoryProvider);
  return ExportService(transactionsRepository, db,
      dateFormat: userProfile.dateFormat);
});
