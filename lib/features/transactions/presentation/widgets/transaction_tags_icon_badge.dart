import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';

/// Small colorful tag indicator on the card corner with a soft elevated shadow effect.
/// Shows [icon + name] if there's only a single tag, or a [row of icons] if there are multiple.
class TransactionTagsIconBadge extends ConsumerWidget {
  final List<String> tagUuids;
  final ThemeData theme;
  final bool isInactive;

  const TransactionTagsIconBadge({
    super.key,
    required this.tagUuids,
    required this.theme,
    this.isInactive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tagUuids.isEmpty) return const SizedBox.shrink();

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final tagsMap = ref.watch(allTagsMapProvider);

    final List<Tag> itemTags = tagUuids
        .map((id) => tagsMap[id])
        .where((t) => t != null)
        .cast<Tag>()
        .toList();

    if (itemTags.isEmpty) return const SizedBox.shrink();

    final bool isSingleTag = itemTags.length == 1;

    // Determine the primary tag's color to make the pill outline match the tag color dynamically,
    // which aligns perfectly with how the account badge highlights its border with the account color.
    final firstTag = itemTags.first;
    final primaryTagColor = firstTag.color != null
        ? Color(int.parse(firstTag.color!.replaceAll('#', '0xFF')))
        : AppColors.getTagColor(firstTag.name);

    // Positioned at the opposite corner of the account badge
    // LTR: Account is at bottom-left (left: -8). Tags pill at bottom-right (right: -8).
    // RTL: Account is at bottom-right (right: -8). Tags pill at bottom-left (left: -8).
    return Positioned(
      bottom: -6,
      right: isRtl ? null : -8,
      left: isRtl ? -8 : null,
      child: Opacity(
        opacity: isInactive ? 0.6 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSingleTag ? 8 : 7,
            vertical: isSingleTag ? 4 : 5,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              // Double shadow to simulate a modern soft elevation 2 effect
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: primaryTagColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: isSingleTag
              ? _buildSingleTag(firstTag, primaryTagColor)
              : _buildMultipleTags(itemTags),
        ),
      ),
    );
  }

  Widget _buildSingleTag(Tag tag, Color tagColor) {
    return Tooltip(
      message: tag.name,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer,
            size: 11,
            color: tagColor,
          ),
          const SizedBox(width: 4),
          Text(
            tag.name,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: tagColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleTags(List<Tag> tags) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(tags.length, (index) {
        final tag = tags[index];
        final tagColor = tag.color != null
            ? Color(int.parse(tag.color!.replaceAll('#', '0xFF')))
            : AppColors.getTagColor(tag.name);

        return Tooltip(
          message: tag.name,
          child: Padding(
            padding: EdgeInsets.only(
              left: index > 0 ? 3.0 : 0.0,
              right: index < tags.length - 1 ? 3.0 : 0.0,
            ),
            child: Icon(
              Icons.local_offer,
              size: 13,
              color: tagColor,
            ),
          ),
        );
      }),
    );
  }
}
