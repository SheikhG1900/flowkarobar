import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/inventory/presentation/screens/add_product_screen.dart';
import 'package:flowpaisa/features/inventory/presentation/screens/product_details_screen.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_entity_pickers.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Sentinel filter value for products with no category.
const _uncategorizedFilter = '__uncategorized__';

class ProductsListScreen extends ConsumerStatefulWidget {
  const ProductsListScreen({super.key});

  @override
  ConsumerState<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  /// `null` = all categories.
  String? _categoryFilter;

  /// Called after [SwipeableListItem] (or hover pill) already confirmed delete.
  Future<void> _deleteProduct(Product product) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(inventoryRepositoryProvider).deleteProduct(product.uuid);
      if (mounted) {
        ToastUtils.showSuccessToast(context, ref, l10n.productDeleted);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    }
  }

  void _openEditor({Product? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(existing: product),
      ),
    );
  }

  void _openDetails(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductDetailsScreen(productUuid: product.uuid),
      ),
    );
  }

  List<Product> _filtered(
    List<Product> products,
  ) {
    final filter = _categoryFilter;
    if (filter == null) return products;
    if (filter == _uncategorizedFilter) {
      return products.where((p) => p.categoryUuid == null).toList();
    }
    return products.where((p) => p.categoryUuid == filter).toList();
  }

  /// Builds flat list entries: optional section headers + products.
  List<_ListEntry> _buildEntries({
    required List<Product> products,
    required Map<String, ProductCategory> categoriesById,
    required AppLocalizations l10n,
  }) {
    final filtered = _filtered(products);
    if (filtered.isEmpty) return const [];

    // Single-category filter → no section headers.
    if (_categoryFilter != null) {
      return [for (final p in filtered) _ListEntry.product(p)];
    }

    final grouped = <String?, List<Product>>{};
    for (final p in filtered) {
      grouped.putIfAbsent(p.categoryUuid, () => []).add(p);
    }

    final categoryIds = grouped.keys.toList()
      ..sort((a, b) {
        if (a == null) return 1;
        if (b == null) return -1;
        final an = categoriesById[a]?.name ?? '';
        final bn = categoriesById[b]?.name ?? '';
        return an.toLowerCase().compareTo(bn.toLowerCase());
      });

    final entries = <_ListEntry>[];
    for (final id in categoryIds) {
      final title = id == null
          ? l10n.uncategorized
          : (categoriesById[id]?.name ?? l10n.uncategorized);
      entries.add(_ListEntry.header(title));
      for (final p in grouped[id]!) {
        entries.add(_ListEntry.product(p));
      }
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsStreamProvider);
    final categoriesAsync = ref.watch(productCategoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.products)),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorOccurred(e.toString()))),
        data: (products) {
          if (products.isEmpty) {
            return OrderEmptyState(
              icon: Icons.inventory_2_outlined,
              message: l10n.noProductsYet,
              color: theme.colorScheme.primary,
            );
          }

          final categories =
              categoriesAsync.value ?? const <ProductCategory>[];
          final categoriesById = {
            for (final c in categories) c.uuid: c,
          };

          // Chips: only categories that currently have products (+ uncategorized).
          final usedCategoryIds = products
              .map((p) => p.categoryUuid)
              .whereType<String>()
              .toSet();
          final chipCategories = categories
              .where((c) => usedCategoryIds.contains(c.uuid))
              .toList()
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
          final hasUncategorized =
              products.any((p) => p.categoryUuid == null);

          final entries = _buildEntries(
            products: products,
            categoriesById: categoriesById,
            l10n: l10n,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                child: entries.isEmpty
                    ? OrderEmptyState(
                        icon: Icons.inventory_2_outlined,
                        message: l10n.noProductsYet,
                        color: theme.colorScheme.primary,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          if (entry.isHeader) {
                            return Padding(
                              padding: EdgeInsets.only(
                                top: index == 0 ? 4 : 16,
                                bottom: 8,
                                left: 4,
                                right: 4,
                              ),
                              child: Text(
                                entry.header!,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            );
                          }

                          final product = entry.product!;
                          final category = product.categoryUuid == null
                              ? null
                              : categoriesById[product.categoryUuid];

                          final accent = parseCategoryColor(
                            category?.color,
                            AppColors.incomeColor,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SwipeableListItem(
                              key: ValueKey('product-swipe-${product.uuid}'),
                              enableEdit: true,
                              enableDelete: true,
                              editBackgroundColor: accent,
                              deleteBackgroundColor: AppColors.error,
                              borderRadius: 20,
                              confirmTitle: l10n.deleteProduct,
                              confirmMessage:
                                  l10n.deleteProductConfirm(product.name),
                              onEdit: () => _openEditor(product: product),
                              onDelete: () => _deleteProduct(product),
                              child: _ProductCard(
                                product: product,
                                category: category,
                                onTap: () => _openDetails(product),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: AppFloatingActionButton(
        heroTag: 'products_fab',
        tooltip: l10n.addProduct,
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ListEntry {
  final String? header;
  final Product? product;

  const _ListEntry._({this.header, this.product});

  factory _ListEntry.header(String title) => _ListEntry._(header: title);

  factory _ListEntry.product(Product product) =>
      _ListEntry._(product: product);

  bool get isHeader => header != null;
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
    final primary = theme.colorScheme.primary;

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
      padding: const EdgeInsets.only(top: 8, bottom: 4),
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

class _ProductLeading extends StatelessWidget {
  final Product product;
  final ProductCategory? category;
  final String serviceTooltip;

  const _ProductLeading({
    required this.product,
    required this.category,
    required this.serviceTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = productLeadingAvatar(
      product: product,
      category: category,
    );

    if (!product.isService) return avatar;

    final badgeColor = theme.colorScheme.primary;
    return Tooltip(
      message: serviceTooltip,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Keep category (or default) icon; service shown as corner badge.
            Positioned.fill(child: Center(child: avatar)),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.miscellaneous_services_outlined,
                  size: 11,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final ProductCategory? category;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final minAlert = product.minStockAlert;
    final isLowStock = !product.isService &&
        minAlert != null &&
        product.stockQuantity <= minAlert;
    final accent = isLowStock
        ? AppColors.warning
        : parseCategoryColor(category?.color, AppColors.incomeColor);

    final stockText = product.isService
        ? null
        : '${AmountFormatter.formatQuantity(product.stockQuantity)} ${product.unit}';

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: AppColors.transactionListItemDecoration(theme, accent),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _ProductLeading(
                  product: product,
                  category: category,
                  serviceTooltip: l10n.serviceProduct,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (product.sku != null &&
                          product.sku!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          product.sku!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (isLowStock) ...[
                        const SizedBox(height: 6),
                        OrderStatusChip(
                          label: l10n.lowStock,
                          color: AppColors.warning,
                          icon: Icons.warning_amber_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!product.isService) ...[
                  const SizedBox(width: 8),
                  Text(
                    stockText!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isLowStock
                          ? AppColors.warning
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
