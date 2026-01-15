import 'package:flutter/material.dart';

/// Reusable widget for showing pagination loading states
class PaginationLoader extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final String? noMoreText;

  const PaginationLoader({
    super.key,
    required this.isLoading,
    required this.hasMore,
    this.noMoreText,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            noMoreText ?? 'No more items',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
