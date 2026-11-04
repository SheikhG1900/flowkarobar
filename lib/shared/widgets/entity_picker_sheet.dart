import 'package:flutter/material.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

/// One row in a searchable entity bottom sheet.
class EntityPickerItem<T> {
  final T value;
  final String title;
  final String? subtitle;
  final Widget leading;
  final bool enabled;

  const EntityPickerItem({
    required this.value,
    required this.title,
    required this.leading,
    this.subtitle,
    this.enabled = true,
  });
}

/// Confirmed pick from [showEntityPickerSheet].
/// Sheet dismiss without picking returns `null` from the Future.
/// Clear / “None” returns [EntityPickResult] with `value == null`.
class EntityPickResult<T> {
  final T? value;
  const EntityPickResult(this.value);
}

/// Consistent searchable bottom drawer used for contacts, products, categories, etc.
Future<EntityPickResult<T>?> showEntityPickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<EntityPickerItem<T>> items,
  T? selected,
  String? searchHint,
  bool allowClear = false,
  String? clearLabel,
  Future<T?> Function()? onAddNew,
  String? addNewLabel,
}) {
  return showModalBottomSheet<EntityPickResult<T>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _EntityPickerSheet<T>(
      title: title,
      items: items,
      selected: selected,
      searchHint: searchHint,
      allowClear: allowClear,
      clearLabel: clearLabel,
      onAddNew: onAddNew,
      addNewLabel: addNewLabel,
    ),
  );
}

class _EntityPickerSheet<T> extends StatefulWidget {
  final String title;
  final List<EntityPickerItem<T>> items;
  final T? selected;
  final String? searchHint;
  final bool allowClear;
  final String? clearLabel;
  final Future<T?> Function()? onAddNew;
  final String? addNewLabel;

  const _EntityPickerSheet({
    required this.title,
    required this.items,
    this.selected,
    this.searchHint,
    this.allowClear = false,
    this.clearLabel,
    this.onAddNew,
    this.addNewLabel,
  });

  @override
  State<_EntityPickerSheet<T>> createState() => _EntityPickerSheetState<T>();
}

class _EntityPickerSheetState<T> extends State<_EntityPickerSheet<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EntityPickerItem<T>> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return widget.items.where((item) {
      final hay = '${item.title} ${item.subtitle ?? ''}'.toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final filtered = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.onAddNew != null)
                    TextButton.icon(
                      onPressed: () async {
                        final created = await widget.onAddNew!();
                        if (created != null && context.mounted) {
                          Navigator.pop(context, EntityPickResult(created));
                        }
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: Text(widget.addNewLabel ?? l10n.addNew),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: widget.searchHint ?? l10n.search,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  if (widget.allowClear)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.block,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(widget.clearLabel ?? l10n.none),
                      trailing: widget.selected == null
                          ? Icon(Icons.check_circle,
                              color: theme.colorScheme.primary)
                          : null,
                      onTap: () =>
                          Navigator.pop(context, EntityPickResult<T>(null)),
                    ),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          l10n.noResultsFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    for (final item in filtered)
                      Opacity(
                        opacity: item.enabled ? 1 : 0.45,
                        child: ListTile(
                          enabled: item.enabled,
                          leading: item.leading,
                          title: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: item.subtitle == null
                              ? null
                              : Text(
                                  item.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          trailing: widget.selected == item.value
                              ? Icon(Icons.check_circle,
                                  color: theme.colorScheme.primary)
                              : null,
                          onTap: item.enabled
                              ? () => Navigator.pop(
                                    context,
                                    EntityPickResult(item.value),
                                  )
                              : null,
                        ),
                      ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tappable field that opens an entity picker — matches AccountPickerField look.
class EntityPickerField extends StatelessWidget {
  final String label;
  final String? valueText;
  final String? valueSubtitle;
  final Widget? leading;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final Color? accentColor;
  final IconData placeholderIcon;

  const EntityPickerField({
    super.key,
    required this.label,
    required this.onTap,
    this.valueText,
    this.valueSubtitle,
    this.leading,
    this.onClear,
    this.accentColor,
    this.placeholderIcon = Icons.list_alt_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = valueText != null && valueText!.isNotEmpty;
    final accent = accentColor ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: selected ? accent : theme.dividerColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Row(
          children: [
            leading ??
                CircleAvatar(
                  radius: 18,
                  backgroundColor: selected
                      ? accent.withValues(alpha: 0.12)
                      : theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    placeholderIcon,
                    size: 18,
                    color: selected
                        ? accent
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selected ? valueText! : label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: selected
                        ? theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: accent,
                          )
                        : theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                  ),
                  if (selected && valueSubtitle != null)
                    Text(
                      valueSubtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (selected && onClear != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close, size: 18, color: accent),
                onPressed: onClear,
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

/// Circular avatar for contacts (initial + gradient).
Widget contactLeadingAvatar(String name, {double radius = 20}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.transparent,
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.getContactGradient(name),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget categoryLeadingAvatar({
  required Color color,
  required IconData icon,
  double radius = 20,
}) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: color.withValues(alpha: 0.15),
    child: Icon(icon, color: color, size: radius),
  );
}
