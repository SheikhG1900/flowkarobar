/// Generic pagination state model for managing paginated data
class PaginatedState<T> {
  final List<T> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentOffset;
  final int pageSize;
  final String? error;

  const PaginatedState({
    required this.items,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentOffset = 0,
    this.pageSize = 50,
    this.error,
  });

  PaginatedState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentOffset,
    int? pageSize,
    String? error,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      pageSize: pageSize ?? this.pageSize,
      error: error ?? this.error,
    );
  }

  /// Reset pagination to initial state
  PaginatedState<T> reset() {
    return PaginatedState<T>(
      items: [],
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      currentOffset: 0,
      pageSize: pageSize,
    );
  }

  /// Add more items to the list
  PaginatedState<T> appendItems(List<T> newItems, {bool hasMore = true}) {
    return copyWith(
      items: [...items, ...newItems],
      currentOffset: currentOffset + newItems.length,
      hasMore: hasMore && newItems.length == pageSize,
      isLoadingMore: false,
    );
  }

  /// Replace all items (for refresh or filter change)
  PaginatedState<T> replaceItems(List<T> newItems, {bool hasMore = true}) {
    return copyWith(
      items: newItems,
      currentOffset: newItems.length,
      hasMore: hasMore && newItems.length == pageSize,
      isLoading: false,
      isLoadingMore: false,
      error: null,
    );
  }
}
