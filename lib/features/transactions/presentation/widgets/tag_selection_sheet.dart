import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';

/// Opens the modal bottom sheet for tag selection with search, grid-wrap, and deletion capabilities.
Future<List<String>?> showTagSelectionSheet(
  BuildContext context, {
  required List<String> initialSelectedTagUuids,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => TagSelectionSheet(
        scrollController: scrollController,
        initialSelectedTagUuids: initialSelectedTagUuids,
      ),
    ),
  );
}

class TagSelectionSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final List<String> initialSelectedTagUuids;

  const TagSelectionSheet({
    super.key,
    required this.scrollController,
    required this.initialSelectedTagUuids,
  });

  @override
  ConsumerState<TagSelectionSheet> createState() => _TagSelectionSheetState();
}

class _TagSelectionSheetState extends ConsumerState<TagSelectionSheet> {
  late final List<String> _selectedTagUuids;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedTagUuids = List.from(widget.initialSelectedTagUuids);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final tagsByUsageAsync = ref.watch(tagsByUsageProvider);
    final tagUsageCountsAsync = ref.watch(tagUsageCountsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.tags,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _selectedTagUuids),
                  child: Text(
                    l10n.done,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search / Add Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.addTagHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    onSubmitted: (val) => _addNewTag(tagsByUsageAsync.value ?? []),
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addNewTag(tagsByUsageAsync.value ?? []),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main tags grid
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                tagsByUsageAsync.when(
                  data: (tags) {
                    final filteredTags = tags.where((tag) {
                      if (_searchQuery.isEmpty) return true;
                      return tag.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();

                    final usageCounts = tagUsageCountsAsync.value ?? const {};

                    // Show option to create new tag if query doesn't exist
                    final queryExists = tags.any((t) => t.name.toLowerCase() == _searchQuery.toLowerCase());

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_searchQuery.isNotEmpty && !queryExists) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () => _addNewTag(tags),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.add_circle_outline_rounded, color: theme.colorScheme.primary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        l10n.createTagQuery(_searchQuery),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (filteredTags.isEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                l10n.noTagsUsedYet,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: filteredTags.map((tag) {
                              final isSelected = _selectedTagUuids.contains(tag.uuid);
                              final tagColor = tag.color != null
                                  ? Color(int.parse(tag.color!))
                                  : AppColors.getTagColor(tag.name);
                              final isOrphan = (usageCounts[tag.uuid] ?? 0) == 0;

                              return Tooltip(
                                message: isOrphan ? l10n.deleteTagTitle : '',
                                child: isOrphan
                                    ? InputChip(
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(tag.name),
                                          ],
                                        ),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              _selectedTagUuids.add(tag.uuid);
                                            } else {
                                              _selectedTagUuids.remove(tag.uuid);
                                            }
                                          });
                                        },
                                        backgroundColor: theme.colorScheme.surface,
                                        selectedColor: tagColor.withValues(alpha: 0.2),
                                        side: BorderSide(
                                          color: isSelected ? tagColor : theme.dividerColor.withValues(alpha: 0.1),
                                          width: isSelected ? 1.5 : 1.0,
                                        ),
                                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                          color: isSelected ? tagColor : theme.colorScheme.onSurface,
                                          fontWeight: isSelected ? FontWeight.bold : null,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        deleteIcon: Icon(Icons.close, size: 14, color: tagColor.withValues(alpha: 0.7)),
                                        onDeleted: () => _handleTagLongPress(context, tag),
                                      )
                                    : FilterChip(
                                        label: Text(tag.name),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              _selectedTagUuids.add(tag.uuid);
                                            } else {
                                              _selectedTagUuids.remove(tag.uuid);
                                            }
                                          });
                                        },
                                        backgroundColor: theme.colorScheme.surface,
                                        selectedColor: tagColor.withValues(alpha: 0.2),
                                        side: BorderSide(
                                          color: isSelected ? tagColor : theme.dividerColor.withValues(alpha: 0.2),
                                        ),
                                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                          color: isSelected ? tagColor : theme.colorScheme.onSurface,
                                          fontWeight: isSelected ? FontWeight.bold : null,
                                        ),
                                      ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error loading tags: $err')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewTag(List<Tag> tags) async {
    final text = _searchQuery.isEmpty ? _searchController.text.trim() : _searchQuery;
    if (text.isEmpty) return;

    Tag? existing;
    for (final t in tags) {
      if (t.name.toLowerCase() == text.toLowerCase()) {
        existing = t;
        break;
      }
    }

    if (existing != null) {
      final uuid = existing.uuid;
      if (!_selectedTagUuids.contains(uuid)) {
        setState(() {
          _selectedTagUuids.add(uuid);
          _searchController.clear();
          _searchQuery = '';
        });
      }
      return;
    }

    try {
      final repo = ref.read(transactionsRepositoryProvider);
      final tag = await repo.createTag(text);
      setState(() {
        _selectedTagUuids.add(tag.uuid);
        _searchController.clear();
        _searchQuery = '';
      });
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context, ref, 'Failed to create tag: $e');
      }
    }
  }

  Future<void> _handleTagLongPress(BuildContext context, Tag tag) async {
    final repo = ref.read(transactionsRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    final count = await repo.getTagUsageCount(tag.uuid);
    
    if (!mounted) return;
    
    if (count == 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.deleteTagTitle),
          content: Text(l10n.deleteTagConfirm(tag.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await repo.deleteTag(tag.uuid);
                  setState(() {
                    _selectedTagUuids.remove(tag.uuid);
                  });
                  if (mounted) {
                    ToastUtils.showSuccessToast(context, ref, l10n.tagDeletedSuccessfully);
                  }
                } catch (e) {
                  if (mounted) {
                    ToastUtils.showErrorToast(context, ref, 'Failed to delete tag: $e');
                  }
                }
              },
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.cannotDeleteTagTitle),
          content: Text(l10n.cannotDeleteTagMessage(count)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
    }
  }
}

/// A simplified, unified [TransactionTagsSelector] display chip component.
/// Shows currently selected tags and a beautiful "+ Tag" button to open the bottom sheet.
class TransactionTagsSelector extends ConsumerWidget {
  final List<String> selectedTagUuids;
  final ValueChanged<List<String>> onChanged;

  const TransactionTagsSelector({
    super.key,
    required this.selectedTagUuids,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final allTagsAsync = ref.watch(allTagsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_outlined, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.tags,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          allTagsAsync.when(
            data: (tags) {
              final activeTags = tags.where((t) => selectedTagUuids.contains(t.uuid)).toList();

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...activeTags.map((tag) {
                    final tagColor = tag.color != null
                        ? Color(int.parse(tag.color!))
                        : AppColors.getTagColor(tag.name);
                    return Chip(
                      label: Text(tag.name),
                      backgroundColor: tagColor.withValues(alpha: 0.15),
                      side: BorderSide(color: tagColor.withValues(alpha: 0.3)),
                      labelStyle: TextStyle(
                        color: tagColor,
                        fontWeight: FontWeight.bold,
                      ),
                      deleteIcon: Icon(Icons.close, size: 14, color: tagColor),
                      onDeleted: () {
                        final updated = List<String>.from(selectedTagUuids)..remove(tag.uuid);
                        onChanged(updated);
                      },
                    );
                  }),
                  ActionChip(
                    avatar: Icon(Icons.add_rounded, size: 16, color: theme.colorScheme.primary),
                    label: Text(
                      l10n.tags, // Can show just "Tag" or "Tags"
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                    side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    onPressed: () async {
                      final updated = await showTagSelectionSheet(
                        context,
                        initialSelectedTagUuids: selectedTagUuids,
                      );
                      if (updated != null) {
                        onChanged(updated);
                      }
                    },
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (err, stack) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }
}
