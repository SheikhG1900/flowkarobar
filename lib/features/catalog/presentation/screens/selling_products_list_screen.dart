import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_pricing.dart';
import 'package:flowpaisa/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flowpaisa/features/catalog/presentation/screens/add_selling_product_screen.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_entity_pickers.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';
import 'package:flowpaisa/shared/widgets/entity_picker_sheet.dart';
import 'package:flowpaisa/shared/widgets/hover_border_card.dart';
import 'package:flowpaisa/shared/widgets/pending_sync_badge.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Sentinel filter value for selling products with no category.
const _uncategorizedFilter = '__uncategorized__';

class SellingProductsListScreen extends ConsumerStatefulWidget {
  const SellingProductsListScreen({super.key});

  @override
  ConsumerState<SellingProductsListScreen> createState() =>
      _SellingProductsListScreenState();
}

class _SellingProductsListScreenState
    extends ConsumerState<SellingProductsListScreen> {
  final _search = TextEditingController();
  String _query = '';

  /// `null` = all categories.
  String? _categoryFilter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<SellingProduct> _filtered(List<SellingProduct> all) {
    Iterable<SellingProduct> items = all;
    final filter = _categoryFilter;
    if (filter == _uncategorizedFilter) {
      items = items.where((p) => p.categoryUuid == null);
    } else if (filter != null) {
      items = items.where((p) => p.categoryUuid == filter);
    }

    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((p) {
        final name = p.name.toLowerCase();
        final sku = (p.sku ?? '').toLowerCase();
        return name.contains(q) || sku.contains(q);
      });
    }
    return items.toList();
  }

  Future<void> _openEditor({String? existingUuid}) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AddSellingProductScreen(existingUuid: existingUuid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accent = AppColors.receivableColor;
    final async = ref.watch(sellingProductsStreamProvider);
    final categoriesAsync = ref.watch(productCategoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sellingProducts),
      ),
      floatingActionButton: AppFloatingActionButton(
        heroTag: 'selling_products_fab',
        backgroundColor: accent,
        foregroundColor: Colors.white,
        tooltip: l10n.newSellingProduct,
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorOccurred(e.toString()))),
        data: (all) {
          if (all.isEmpty) {
            return OrderEmptyState(
              icon: Icons.sell_outlined,
              message: l10n.noSellingProductsYet,
              color: accent,
            );
          }

          final categories =
              categoriesAsync.value ?? const <ProductCategory>[];
          final usedCategoryIds = all
              .map((p) => p.categoryUuid)
              .whereType<String>()
              .toSet();
          final chipCategories = categories
              .where((c) => usedCategoryIds.contains(c.uuid))
              .toList()
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
          final hasUncategorized = all.any((p) => p.categoryUuid == null);
          final items = _filtered(all);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.clear),
                          ),
                  ),
                ),
              ),
              if (chipCategories.isNotEmpty || hasUncategorized)
                _CategoryFilterBar(
                  allLabel: l10n.all,
                  uncategorizedLabel: l10n.uncategorized,
                  categories: chipCategories,
                  showUncategorized: hasUncategorized,
                  selected: _categoryFilter,
                  onSelected: (value) =>
                      setState(() => _categoryFilter = value),
                ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noResultsFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 720 ? 2 : 1;
                          final rowCount = (items.length / columns).ceil();
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                            itemCount: rowCount,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, rowIndex) {
                              final start = rowIndex * columns;
                              Widget cardAt(int index) {
                                final sp = items[index];
                                return _SellingProductCard(
                                  sellingProduct: sp,
                                  onEdit: () =>
                                      _openEditor(existingUuid: sp.uuid),
                                );
                              }

                              if (columns == 1) {
                                return cardAt(start);
                              }

                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    for (var i = 0; i < columns; i++) ...[
                                      if (i > 0) const SizedBox(width: 12),
                                      Expanded(
                                        child: start + i < items.length
                                            ? cardAt(start + i)
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final String allLabel;
  final String uncategorizedLabel;
  final List<ProductCategory> categories;
  final bool showUncategorized;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _CategoryFilterBar({
    required this.allLabel,
    required this.uncategorizedLabel,
    required this.categories,
    required this.showUncategorized,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.receivableColor;

    Widget chip({
      required String label,
      required bool isSelected,
      required VoidCallback onTap,
      Color? accent,
      IconData? icon,
    }) {
      final color = accent ?? primary;
      return Padding(
        padding: const EdgeInsetsDirectional.only(end: 8),
        child: FilterChip(
          showCheckmark: false,
          avatar: icon == null
              ? null
              : Icon(
                  icon,
                  size: 14,
                  color: isSelected
                      ? color
                      : theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.7),
                ),
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onTap(),
          backgroundColor: theme.colorScheme.surface,
          selectedColor: color.withValues(alpha: 0.15),
          side: BorderSide(
            color: isSelected
                ? color
                : theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : null,
            fontSize: 12,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            chip(
              label: allLabel,
              isSelected: selected == null,
              onTap: () => onSelected(null),
            ),
            ...categories.map((c) {
              final accent = parseCategoryColor(c.color, primary);
              return chip(
                label: c.name,
                isSelected: selected == c.uuid,
                accent: accent,
                icon: categoryIconData(c),
                onTap: () => onSelected(c.uuid),
              );
            }),
            if (showUncategorized)
              chip(
                label: uncategorizedLabel,
                isSelected: selected == _uncategorizedFilter,
                icon: Symbols.category,
                onTap: () => onSelected(_uncategorizedFilter),
              ),
          ],
        ),
      ),
    );
  }
}

class _SellingProductCard extends ConsumerWidget {
  final SellingProduct sellingProduct;
  final VoidCallback onEdit;

  const _SellingProductCard({
    required this.sellingProduct,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final categories =
        ref.watch(productCategoriesStreamProvider).value ?? const [];
    final category = sellingProduct.categoryUuid == null
        ? null
        : categories
            .where((c) => c.uuid == sellingProduct.categoryUuid)
            .firstOrNull;
    final accent = parseCategoryColor(
      category?.color,
      AppColors.receivableColor,
    );
    final muted = theme.colorScheme.onSurfaceVariant;
    final compsAsync =
        ref.watch(sellingProductComponentsStreamProvider(sellingProduct.uuid));
    final comps = compsAsync.value ?? const <SellingProductComponent>[];
    final sku = sellingProduct.sku?.trim();
    final desc = sellingProduct.description?.trim();
    final categoryName = category?.name.trim();

    return HoverBorderCard(
      accent: accent,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              categoryLeadingAvatar(
                color: accent,
                icon: category == null
                    ? Icons.sell_outlined
                    : categoryIconData(category),
                radius: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellingProduct.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (sku != null && sku.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sku,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (categoryName != null && categoryName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        categoryName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (desc != null && desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (sellingProduct.isNotSynced == true) ...[
                Tooltip(
                  message: l10n.pendingSync,
                  child: const PendingSyncCornerBadge(iconSize: 12),
                ),
                const SizedBox(width: 8),
              ],
              _CountBadge(
                count: comps.length,
                accent: accent,
                tooltip: l10n.sectionComponents,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.sectionComponents,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: muted,
            ),
          ),
          const SizedBox(height: 8),
          if (compsAsync.isLoading && comps.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (comps.isEmpty)
            Text(
              l10n.noResultsFound,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            )
          else
            for (var i = 0; i < comps.length; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              _ComponentLineRow(component: comps[i], accent: accent),
            ],
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onEdit,
            child: Text(l10n.editSellingProduct),
          ),
        ],
      ),
    );
  }
}

class _ComponentLineRow extends ConsumerWidget {
  final SellingProductComponent component;
  final Color accent;

  const _ComponentLineRow({
    required this.component,
    required this.accent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final muted = theme.colorScheme.onSurfaceVariant;
    final productAsync = ref.watch(productStreamProvider(component.productUuid));
    final product = productAsync.value;
    final name = product?.name ?? '…';
    final unit = product?.unit ?? '';
    final categories =
        ref.watch(productCategoriesStreamProvider).value ?? const [];
    final categoriesById = {for (final c in categories) c.uuid: c};
    final category = product?.categoryUuid == null
        ? null
        : categoriesById[product!.categoryUuid];
    final iconColor = parseCategoryColor(category?.color, accent);
    final iconData = categoryIconData(category);
    final batch = component.batchNumber?.trim();
    final isBatch = component.consumeMode == SellingConsumeMode.batch;
    final modeLabel = isBatch && batch != null && batch.isNotEmpty
        ? batch
        : l10n.consumeModeAutoShort;

    final modeStyle = theme.textTheme.labelSmall?.copyWith(
      color: muted,
      fontWeight: FontWeight.w600,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 16,
            color: iconColor.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(text: '  ', style: modeStyle),
                  TextSpan(text: modeLabel, style: modeStyle),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AmountFormatter.formatQuantity(component.quantity),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color accent;
  final String tooltip;

  const _CountBadge({
    required this.count,
    required this.accent,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          '$count',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: accent,
          ),
        ),
      ),
    );
  }
}
