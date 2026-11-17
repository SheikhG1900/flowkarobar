import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_pricing.dart';
import 'package:flowpaisa/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flowpaisa/features/catalog/presentation/screens/add_catalog_items_screen.dart';
import 'package:flowpaisa/features/catalog/presentation/screens/add_edit_catalog_screen.dart';
import 'package:flowpaisa/features/catalog/presentation/widgets/catalog_pricing_approach_picker.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_entity_pickers.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';
import 'package:flowpaisa/shared/widgets/entity_picker_sheet.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/hover_border_card.dart';
import 'package:flowpaisa/shared/widgets/pending_sync_badge.dart';
import 'package:flowpaisa/shared/widgets/swipeable_list_item.dart';
import 'package:material_symbols_icons/symbols.dart';

class CatalogDetailScreen extends ConsumerStatefulWidget {
  final String catalogUuid;

  const CatalogDetailScreen({super.key, required this.catalogUuid});

  @override
  ConsumerState<CatalogDetailScreen> createState() =>
      _CatalogDetailScreenState();
}

class _CatalogDetailScreenState extends ConsumerState<CatalogDetailScreen> {
  bool _busy = false;

  Future<void> _recalculate() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.recalculateCatalog),
        content: Text(l10n.recalculateCatalogConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.recalculateCatalog),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(catalogRepositoryProvider)
          .recalculateCatalog(widget.catalogUuid);
      if (!mounted) return;
      ToastUtils.showSuccessToast(
        context,
        ref,
        l10n.recalculateCatalogDone(result.updated, result.skipped),
      );
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
          context,
          ref,
          l10n.errorOccurred(e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addFromCatalog() async {
    final l10n = AppLocalizations.of(context)!;
    final catalogs =
        (ref.read(catalogsStreamProvider).value ?? const <Catalog>[])
            .where((c) => c.uuid != widget.catalogUuid)
            .toList();
    if (catalogs.isEmpty) {
      ToastUtils.showErrorToast(context, ref, l10n.noCatalogsYet);
      return;
    }

    final source = await showModalBottomSheet<Catalog>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text(l10n.selectSourceCatalog)),
            for (final c in catalogs)
              ListTile(
                title: Text(c.name),
                onTap: () => Navigator.pop(context, c),
              ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    var priceMode = CatalogImportPriceMode.copy;
    var conflict = CatalogImportConflictAction.skipAll;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(l10n.addFromCatalog),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(source.name),
                  const SizedBox(height: 12),
                  Text(l10n.catalogImportPriceMode),
                  const SizedBox(height: 8),
                  SegmentedButton<CatalogImportPriceMode>(
                    segments: [
                      ButtonSegment(
                        value: CatalogImportPriceMode.copy,
                        label: Text(l10n.catalogImportCopyPrices),
                      ),
                      ButtonSegment(
                        value: CatalogImportPriceMode.recalculate,
                        label: Text(l10n.catalogImportRecalculate),
                      ),
                    ],
                    selected: {priceMode},
                    onSelectionChanged: (s) =>
                        setLocal(() => priceMode = s.first),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.catalogImportConflicts),
                  const SizedBox(height: 8),
                  SegmentedButton<CatalogImportConflictAction>(
                    segments: [
                      ButtonSegment(
                        value: CatalogImportConflictAction.skipAll,
                        label: Text(l10n.catalogImportSkipAll),
                      ),
                      ButtonSegment(
                        value: CatalogImportConflictAction.replaceAll,
                        label: Text(l10n.catalogImportReplaceAll),
                      ),
                    ],
                    selected: {conflict},
                    onSelectionChanged: (s) =>
                        setLocal(() => conflict = s.first),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.addFromCatalog),
                ),
              ],
            );
          },
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final result = await ref.read(catalogRepositoryProvider).addFromCatalog(
            targetCatalogUuid: widget.catalogUuid,
            sourceCatalogUuid: source.uuid,
            priceMode: priceMode,
            conflictAction: conflict,
          );
      if (!mounted) return;
      ToastUtils.showSuccessToast(
        context,
        ref,
        l10n.catalogImportDone(result.added, result.replaced, result.skipped),
      );
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
          context,
          ref,
          l10n.errorOccurred(e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _assignContact() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showOrderContactPicker(
      context: context,
      ref: ref,
      isSale: true,
    );
    final contact = result?.value;
    if (contact == null || !mounted) return;
    try {
      await ref.read(catalogRepositoryProvider).assignCatalog(
            catalogUuid: widget.catalogUuid,
            contactUuid: contact.uuid,
          );
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.catalogAssignmentAdded);
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
          context,
          ref,
          l10n.errorOccurred(e.toString()),
        );
      }
    }
  }

  Future<void> _refreshItemPrice(CatalogItem item) async {
    final l10n = AppLocalizations.of(context)!;
    if (item.priceOverride) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.refreshItemPrice),
          content: Text(l10n.refreshManualPriceConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.refreshItemPrice),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    try {
      await ref.read(catalogRepositoryProvider).refreshItemPrice(item.uuid);
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.catalogItemSaved);
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
          context,
          ref,
          l10n.errorOccurred(e.toString()),
        );
      }
    }
  }

  Future<void> _editItemPricing(CatalogItem item) async {
    final result = await showModalBottomSheet<_PricingEditResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditItemPricingSheet(item: item),
    );
    if (result == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    if (result.refreshOnly) {
      await _refreshItemPrice(item);
      return;
    }
    try {
      await ref.read(catalogRepositoryProvider).updateItemPricing(
            itemUuid: item.uuid,
            pricingApproach: result.approach,
            markupOrMarginPercent: result.percent,
            fixedAmount: result.fixedAmount,
            sellPriceOverride: result.sellPriceOverride,
          );
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.catalogItemSaved);
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
          context,
          ref,
          l10n.errorOccurred(e.toString()),
        );
      }
    }
  }

  Future<void> _showCatalogItemActions(CatalogItem item) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.editItemPricing),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded),
              title: Text(l10n.refreshItemPrice),
              onTap: () => Navigator.pop(context, 'refresh'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(l10n.delete),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'edit':
        await _editItemPricing(item);
      case 'refresh':
        await _refreshItemPrice(item);
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.delete),
            content: Text(l10n.confirmDeleteCatalogItem),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.expenseColor,
                ),
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
        if (ok != true || !mounted) return;
        try {
          await ref.read(catalogRepositoryProvider).softDeleteItem(item.uuid);
          if (!mounted) return;
          ToastUtils.showSuccessToast(context, ref, l10n.catalogItemDeleted);
        } catch (e) {
          if (mounted) {
            ToastUtils.showErrorToast(
              context,
              ref,
              l10n.errorOccurred(e.toString()),
            );
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accent = AppColors.receivableColor;
    final catalogAsync = ref.watch(catalogStreamProvider(widget.catalogUuid));
    final itemsAsync =
        ref.watch(catalogItemsStreamProvider(widget.catalogUuid));
    final assignmentsAsync =
        ref.watch(catalogAssignmentsStreamProvider(widget.catalogUuid));

    return catalogAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.catalog)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.catalog)),
        body: Center(child: Text(l10n.errorOccurred(e.toString()))),
      ),
      data: (catalog) {
        if (catalog == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.catalog)),
            body: Center(child: Text(l10n.noResultsFound)),
          );
        }

        final items = itemsAsync.value ?? const <CatalogItem>[];
        final assignments =
            assignmentsAsync.value ?? const <CatalogAssignment>[];
        final contacts =
            ref.watch(contactsListProvider).value ?? const <Contact>[];
        final contactsById = {for (final c in contacts) c.uuid: c};

        return Scaffold(
          appBar: AppBar(
            title: Text(catalog.name),
            actions: [
              IconButton(
                tooltip: l10n.editCatalog,
                onPressed: _busy
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditCatalogScreen(existing: catalog),
                          ),
                        );
                      },
                icon: const Icon(Icons.edit_outlined),
              ),
              PopupMenuButton<String>(
                enabled: !_busy,
                onSelected: (value) {
                  switch (value) {
                    case 'import':
                      _addFromCatalog();
                    case 'recalc':
                      _recalculate();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'import',
                    child: Text(l10n.addFromCatalog),
                  ),
                  PopupMenuItem(
                    value: 'recalc',
                    child: Text(l10n.recalculateCatalog),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: AppFloatingActionButton(
            heroTag: 'catalog_detail_add_items',
            backgroundColor: accent,
            foregroundColor: Colors.white,
            tooltip: l10n.addCatalogItems,
            onPressed: _busy
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddCatalogItemsScreen(
                          catalogUuid: catalog.uuid,
                        ),
                      ),
                    );
                  },
            child: const Icon(Icons.add),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              _CatalogHero(catalog: catalog, accent: accent),
              const SizedBox(height: 14),
              _CatalogItemsSectionHeader(
                title: l10n.catalogItems,
                accent: accent,
              ),
              if (itemsAsync.isLoading && items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
                  child: Text(
                    l10n.catalogItemsEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SwipeableListItem(
                      key: ValueKey('catalog-item-swipe-${item.uuid}'),
                      enableEdit: true,
                      enableDelete: true,
                      editBackgroundColor: accent,
                      deleteBackgroundColor: AppColors.error,
                      borderRadius: 20,
                      confirmTitle: l10n.delete,
                      confirmMessage: l10n.confirmDeleteCatalogItem,
                      onEdit: () => _editItemPricing(item),
                      onDelete: () async {
                        try {
                          await ref
                              .read(catalogRepositoryProvider)
                              .softDeleteItem(item.uuid);
                          if (context.mounted) {
                            ToastUtils.showSuccessToast(
                              context,
                              ref,
                              l10n.catalogItemDeleted,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ToastUtils.showErrorToast(
                              context,
                              ref,
                              l10n.errorOccurred(e.toString()),
                            );
                          }
                        }
                      },
                      additionalHoverActions: [
                        IconButton(
                          tooltip: l10n.refreshItemPrice,
                          iconSize: 18,
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                          onPressed: () => _refreshItemPrice(item),
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: accent,
                          ),
                        ),
                      ],
                      child: _CatalogItemCard(
                        item: item,
                        onTap: () => _editItemPricing(item),
                        onLongPress: () => _showCatalogItemActions(item),
                      ),
                    ),
                  ),
              FormSectionCard(
                title: l10n.catalogAssignmentsSection,
                icon: Icons.people_outline,
                accentColor: accent,
                trailing: IconButton(
                  tooltip: l10n.assignContact,
                  onPressed: _busy ? null : _assignContact,
                  style: IconButton.styleFrom(
                    foregroundColor: accent,
                    side: BorderSide(color: accent.withValues(alpha: 0.45)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                ),
                children: [
                  if (assignments.isEmpty)
                    Text(
                      l10n.noCatalogAssignments,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    for (final a in assignments)
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Row(
                          children: [
                            contactLeadingAvatar(
                              contactsById[a.contactUuid]?.name ?? '?',
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                contactsById[a.contactUuid]?.name ??
                                    a.contactUuid,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: l10n.delete,
                              onPressed: () async {
                                await ref
                                    .read(catalogRepositoryProvider)
                                    .unassignCatalog(a.uuid);
                                if (context.mounted) {
                                  ToastUtils.showSuccessToast(
                                    context,
                                    ref,
                                    l10n.catalogAssignmentRemoved,
                                  );
                                }
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CatalogHero extends StatelessWidget {
  final Catalog catalog;
  final Color accent;

  const _CatalogHero({required this.catalog, required this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final desc = catalog.description?.trim();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: AppColors.getPrimaryGradient(accent),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    child: const Icon(
                      Symbols.price_change,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      catalog.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (desc != null && desc.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  desc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (catalog.isDefault)
                    OrderStatusChip(
                      label: l10n.defaultCatalog,
                      color: Colors.white,
                      icon: Icons.star_rounded,
                    ),
                  if (catalog.validUntil != null)
                    OrderStatusChip(
                      label:
                          '${l10n.catalogValidUntil}: ${AppDateFormatter.formatDate(catalog.validUntil!)}',
                      color: Colors.white,
                      icon: Icons.event_outlined,
                    ),
                ],
              ),
            ],
          ),
        ),
        if (catalog.isNotSynced == true)
          const PositionedDirectional(
            top: -6,
            end: -6,
            child: PendingSyncDetailBadge(),
          ),
      ],
    );
  }
}

class _CatalogItemsSectionHeader extends StatelessWidget {
  final String title;
  final Color accent;

  const _CatalogItemsSectionHeader({
    required this.title,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.list_alt_outlined, size: 18, color: accent),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogItemCard extends ConsumerWidget {
  final CatalogItem item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CatalogItemCard({
    required this.item,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final muted = theme.colorScheme.onSurfaceVariant;
    final categories =
        ref.watch(productCategoriesStreamProvider).value ?? const [];
    final categoriesById = {for (final c in categories) c.uuid: c};

    String title = '…';
    String? sku;
    String unit = '';
    String? categoryUuid;
    IconData fallbackIcon = Icons.inventory_2_outlined;

    if (item.productUuid != null) {
      final product =
          ref.watch(productStreamProvider(item.productUuid!)).value;
      title = product?.name ?? '…';
      sku = product?.sku?.trim();
      unit = product?.unit.trim() ?? '';
      categoryUuid = product?.categoryUuid;
      fallbackIcon = product?.isService == true
          ? Icons.miscellaneous_services_outlined
          : Icons.inventory_2_outlined;
    } else if (item.sellingProductUuid != null) {
      final sp =
          ref.watch(sellingProductStreamProvider(item.sellingProductUuid!)).value;
      title = sp?.name ?? '…';
      sku = sp?.sku?.trim();
      unit = sp?.unit?.trim() ?? '';
      categoryUuid = sp?.categoryUuid;
      fallbackIcon = Icons.sell_outlined;
    }

    final category =
        categoryUuid == null ? null : categoriesById[categoryUuid];
    final accent = parseCategoryColor(
      category?.color,
      AppColors.receivableColor,
    );
    final icon =
        category == null ? fallbackIcon : categoryIconData(category);
    final categoryName = category?.name.trim();
    final formula =
        '${item.markupOrMarginPercent.toStringAsFixed(1)}% + ${formatOrderAmount(ref, item.fixedAmount)}';

    return HoverBorderCard(
      accent: accent,
      onTap: onTap,
      onLongPress: onLongPress,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Center(
                    child: categoryLeadingAvatar(
                      color: accent,
                      icon: icon,
                      radius: 22,
                    ),
                  ),
                ),
                if (item.isNotSynced == true)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: Tooltip(
                      message: l10n.pendingSync,
                      child: const PendingSyncCornerBadge(iconSize: 11),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (sku != null && sku.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sku,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
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
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.priceOverride)
                      Tooltip(
                        message: l10n.manualCatalogPrice,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: 3,
                            top: 1,
                          ),
                          child: Text(
                            '*',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    Text(
                      formatOrderAmount(ref, item.sellPrice),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 2),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '/$unit',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formula,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PricingEditResult {
  final String approach;
  final double percent;
  final double fixedAmount;
  final double? sellPriceOverride;
  final bool refreshOnly;

  const _PricingEditResult({
    required this.approach,
    required this.percent,
    required this.fixedAmount,
    this.sellPriceOverride,
  }) : refreshOnly = false;

  const _PricingEditResult.refresh()
      : approach = '',
        percent = 0,
        fixedAmount = 0,
        sellPriceOverride = null,
        refreshOnly = true;
}

class _EditItemPricingSheet extends StatefulWidget {
  final CatalogItem item;

  const _EditItemPricingSheet({required this.item});

  @override
  State<_EditItemPricingSheet> createState() => _EditItemPricingSheetState();
}

class _EditItemPricingSheetState extends State<_EditItemPricingSheet> {
  late String _approach;
  late final TextEditingController _percent;
  late final TextEditingController _fixed;
  late final TextEditingController _sellOverride;
  bool _override = false;

  @override
  void initState() {
    super.initState();
    _approach = widget.item.pricingApproach;
    _percent = TextEditingController(
      text: widget.item.markupOrMarginPercent.toString(),
    );
    _fixed = TextEditingController(text: widget.item.fixedAmount.toString());
    _sellOverride =
        TextEditingController(text: widget.item.sellPrice.toString());
    _override = widget.item.priceOverride;
  }

  @override
  void dispose() {
    _percent.dispose();
    _fixed.dispose();
    _sellOverride.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.editItemPricing,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          CatalogPricingApproachPicker(
            value: _approach,
            accentColor: AppColors.receivableColor,
            onChanged: (v) => setState(() => _approach = v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _percent,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.markupOrMarginPercent,
              filled: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _fixed,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.fixedAmount,
              filled: true,
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.sellPrice),
            value: _override,
            onChanged: (v) => setState(() => _override = v),
          ),
          if (_override)
            TextField(
              controller: _sellOverride,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.sellPrice,
                filled: true,
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context, const _PricingEditResult.refresh());
            },
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.refreshItemPrice),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                _PricingEditResult(
                  approach: _approach,
                  percent: double.tryParse(_percent.text.trim()) ?? 0,
                  fixedAmount: double.tryParse(_fixed.text.trim()) ?? 0,
                  sellPriceOverride: _override
                      ? double.tryParse(_sellOverride.text.trim())
                      : null,
                ),
              );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
