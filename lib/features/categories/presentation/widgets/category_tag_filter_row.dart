import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/categories/presentation/providers/categories_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class CategoryTagFilterRow extends ConsumerWidget {
  const CategoryTagFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsProvider);
    final selectedTags = ref.watch(categoryFilterTagsProvider);
    debugPrint('CategoryTagFilterRow selectedTags: $selectedTags');
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final l10n = AppLocalizations.of(context)!;

    return tagsAsync.when(
      data: (tags) {
        if (tags.isEmpty) return const SizedBox.shrink();

        final isAllSelected = selectedTags.isEmpty;
        final isWithoutTagsSelected = selectedTags.contains('no_tag');

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // "All" Chip
                FilterChip(
                  label: Text(l10n.all),
                  selected: isAllSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(categoryFilterTagsProvider.notifier).clear();
                    }
                  },
                  showCheckmark: false,
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: primaryColor.withValues(alpha: 0.15),
                  side: BorderSide(
                    color: isAllSelected
                        ? primaryColor
                        : theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: isAllSelected ? primaryColor : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isAllSelected ? FontWeight.bold : null,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),

                // "Without Tags" Chip
                FilterChip(
                  avatar: Icon(
                    Icons.block,
                    size: 14,
                    color: isWithoutTagsSelected
                        ? primaryColor
                        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  showCheckmark: false,
                  label: Text(l10n.filterWithoutTags),
                  selected: isWithoutTagsSelected,
                  onSelected: (_) {
                    ref.read(categoryFilterTagsProvider.notifier).toggleTag('no_tag');
                  },
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: primaryColor.withValues(alpha: 0.15),
                  side: BorderSide(
                    color: isWithoutTagsSelected
                        ? primaryColor
                        : theme.colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: isWithoutTagsSelected ? primaryColor : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isWithoutTagsSelected ? FontWeight.bold : null,
                    fontSize: 12,
                  ),
                ),

                // Render dynamic tags
                ...tags.map((tag) {
                  final isSelected = selectedTags.contains(tag.uuid);
                  final tagColor = tag.color != null
                      ? Color(int.parse(tag.color!.replaceAll('#', '0xFF')))
                      : AppColors.getTagColor(tag.name);

                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      showCheckmark: false,
                      label: Text(tag.name),
                      selected: isSelected,
                      onSelected: (_) {
                        ref.read(categoryFilterTagsProvider.notifier).toggleTag(tag.uuid);
                      },
                      backgroundColor: theme.colorScheme.surface,
                      selectedColor: tagColor.withValues(alpha: 0.2),
                      side: BorderSide(
                        color: isSelected ? tagColor : tagColor.withValues(alpha: 0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      labelStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected ? tagColor : tagColor.withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.bold : null,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
