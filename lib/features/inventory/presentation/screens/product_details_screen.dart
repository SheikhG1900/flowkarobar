import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/inventory/domain/batch_models.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/inventory/presentation/screens/add_product_screen.dart';
import 'package:flowpaisa/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_entity_pickers.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';

enum _LotFilter { open, all, consumed }

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productUuid;

  const ProductDetailsScreen({super.key, required this.productUuid});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  _LotFilter _filter = _LotFilter.open;

  Future<void> _openEditor(Product product) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(existing: product),
      ),
    );
  }

  Future<void> _openManualLotSheet(
    Product product, {
    ProductBatche? existing,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ManualLotSheet(
        product: product,
        existing: existing,
      ),
    );
    if (!mounted) return;
    if (saved == true) {
      ref.invalidate(productBatchesStreamProvider(widget.productUuid));
      ref.invalidate(productStreamProvider(widget.productUuid));
      ref.invalidate(productLotSourcesProvider(widget.productUuid));
      final l10n = AppLocalizations.of(context)!;
      ToastUtils.showSuccessToast(
        context,
        ref,
        existing == null ? l10n.manualLotSaved : l10n.manualLotUpdated,
      );
    }
  }

  VoidCallback? _lotTap({
    required Product product,
    required ProductBatche lot,
    LotPurchaseContext? source,
  }) {
    if (lot.isManual) {
      return () => _openManualLotSheet(product, existing: lot);
    }
    return _orderOpener(context, source);
  }

  List<ProductBatche> _applyFilter(List<ProductBatche> lots) {
    switch (_filter) {
      case _LotFilter.open:
        return lots.where((l) => l.isOpen).toList();
      case _LotFilter.consumed:
        return lots.where((l) => !l.isOpen).toList();
      case _LotFilter.all:
        return lots;
    }
  }

  Map<String, List<ProductBatche>> _groupByBatch(List<ProductBatche> lots) {
    final map = <String, List<ProductBatche>>{};
    for (final lot in lots) {
      map.putIfAbsent(lot.batchNumber, () => []).add(lot);
    }
    return map;
  }

  VoidCallback? _orderOpener(
    BuildContext context,
    LotPurchaseContext? source,
  ) {
    if (source == null) return null;
    return () {
      Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(orderUuid: source.orderUuid),
        ),
      );
    };
  }

  Widget _lotOrBatchCard({
    required Product product,
    required String batchKey,
    required List<ProductBatche> groupLots,
    required Map<String, LotPurchaseContext> sources,
    required String dateFormat,
  }) {
    if (groupLots.length == 1) {
      final lot = groupLots.first;
      final lotSource = sources[lot.uuid];
      return _QtyFocusCard.lot(
        lot: lot,
        unit: product.unit,
        source: lotSource,
        dateFormat: dateFormat,
        showBatchInFooter: true,
        onOpenOrder: _lotTap(
          product: product,
          lot: lot,
          source: lotSource,
        ),
      );
    }
    return _BatchLotPanel(
      product: product,
      batchNumber: batchKey.isEmpty ? '—' : batchKey,
      lots: groupLots,
      sources: sources,
      dateFormat: dateFormat,
      onEditManualLot: (lot) => _openManualLotSheet(product, existing: lot),
    );
  }

  /// 2 columns on wide screens; single column when narrow.
  Widget _lotsGrid({
    required Product product,
    required List<String> groupKeys,
    required Map<String, List<ProductBatche>> grouped,
    required Map<String, LotPurchaseContext> sources,
    required String dateFormat,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final twoCol = constraints.maxWidth >= 720;
        final cards = <Widget>[
          for (final key in groupKeys)
            _lotOrBatchCard(
              product: product,
              batchKey: key,
              groupLots: grouped[key]!,
              sources: sources,
              dateFormat: dateFormat,
            ),
        ];

        if (!twoCol) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: gap),
                cards[i],
              ],
            ],
          );
        }

        final cardWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards)
              SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final productAsync = ref.watch(productStreamProvider(widget.productUuid));
    final batchesAsync =
        ref.watch(productBatchesStreamProvider(widget.productUuid));
    final sourcesAsync =
        ref.watch(productLotSourcesProvider(widget.productUuid));
    final categories =
        ref.watch(productCategoriesStreamProvider).value ?? const [];
    final dateFormat = ref.watch(userProfileProvider).dateFormat;

    return productAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.productDetails)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.productDetails)),
        body: Center(child: Text(l10n.errorOccurred(e.toString()))),
      ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.productDetails)),
            body: Center(child: Text(l10n.noProductsYet)),
          );
        }

        final category = product.categoryUuid == null
            ? null
            : categories.where((c) => c.uuid == product.categoryUuid).firstOrNull;
        final accent = parseCategoryColor(
          category?.color,
          AppColors.incomeColor,
        );
        final lots = batchesAsync.value ?? const <ProductBatche>[];
        final sources = sourcesAsync.value ?? const <String, LotPurchaseContext>{};
        final openLots = lots.where((l) => l.isOpen).toList();
        final onHandQty = openLots.fold<double>(
          0,
          (sum, l) => sum + l.remainingQuantity,
        );
        final inventoryValue = openLots.fold<double>(
          0,
          (sum, l) => sum + (l.remainingQuantity * l.effectiveCost),
        );
        final avgUnitCost =
            onHandQty > 1e-9 ? inventoryValue / onHandQty : 0.0;
        final consumedQty = lots.fold<double>(
          0,
          (sum, l) => sum + l.consumedQuantity,
        );
        // Estimate of stock cost already used (lot effective cost × consumed).
        final consumedValue = lots.fold<double>(
          0,
          (sum, l) => sum + (l.consumedQuantity * l.effectiveCost),
        );
        final filtered = _applyFilter(lots);
        final grouped = _groupByBatch(filtered);
        final groupKeys = grouped.keys.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        final isLowStock = !product.isService &&
            product.minStockAlert != null &&
            product.stockQuantity <= product.minStockAlert!;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.productDetails),
            actions: [
              IconButton(
                tooltip: l10n.editProduct,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _openEditor(product),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _ProductHero(
                product: product,
                category: category,
                accent: accent,
                isLowStock: isLowStock,
              ),
              if (!product.isService) ...[
                const SizedBox(height: 14),
                _StockSummaryPanel(
                  onHandLabel: l10n.onHandStock,
                  onHandValue: AmountFormatter.formatQuantity(
                    product.stockQuantity,
                  ),
                  onHandUnit: product.unit,
                  onHandColor: isLowStock
                      ? AppColors.warning
                      : AppColors.incomeColor,
                  avgUnitCostLabel: l10n.avgUnitCost,
                  avgUnitCostValue: onHandQty > 1e-9
                      ? formatOrderAmount(ref, avgUnitCost)
                      : '—',
                  avgUnitCostColor: AppColors.payableColor,
                  inventoryValueLabel: l10n.inventoryValue,
                  inventoryValueAmount:
                      formatOrderAmount(ref, inventoryValue),
                  inventoryValueColor: AppColors.receivableColor,
                  consumedLabel: l10n.consumedStock,
                  consumedValue:
                      AmountFormatter.formatQuantity(consumedQty),
                  consumedUnit: product.unit,
                  consumedColor: AppColors.expenseColor,
                  consumedWorthLabel: l10n.consumedValue,
                  consumedWorthAmount:
                      formatOrderAmount(ref, consumedValue),
                  consumedWorthColor: AppColors.payableColor,
                  openLotsLabel: l10n.openLots,
                  openLotsValue: '${openLots.length}',
                  openLotsColor: theme.colorScheme.primary,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.lotsSection,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openManualLotSheet(product),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.addManualLot),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _LotFilterChip(
                        label: l10n.lotFilterOpen,
                        selected: _filter == _LotFilter.open,
                        onTap: () =>
                            setState(() => _filter = _LotFilter.open),
                      ),
                      const SizedBox(width: 6),
                      _LotFilterChip(
                        label: l10n.lotFilterAll,
                        selected: _filter == _LotFilter.all,
                        onTap: () =>
                            setState(() => _filter = _LotFilter.all),
                      ),
                      const SizedBox(width: 6),
                      _LotFilterChip(
                        label: l10n.lotFilterConsumed,
                        selected: _filter == _LotFilter.consumed,
                        onTap: () =>
                            setState(() => _filter = _LotFilter.consumed),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (batchesAsync.isLoading && lots.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        OrderEmptyState(
                          icon: Icons.inventory_2_outlined,
                          message: lots.isEmpty
                              ? l10n.noLotsYet
                              : l10n.noOpenLots,
                          color: accent,
                        ),
                        if (lots.isEmpty) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => _openManualLotSheet(product),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.addManualLot),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  _lotsGrid(
                    product: product,
                    groupKeys: groupKeys,
                    grouped: grouped,
                    sources: sources,
                    dateFormat: dateFormat,
                  ),
              ] else ...[
                const SizedBox(height: 16),
                FormSectionCard(
                  title: l10n.sectionCosting,
                  icon: Icons.payments_outlined,
                  accentColor: AppColors.payableColor,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.attach_money_rounded,
                        color: AppColors.payableColor,
                      ),
                      title: Text(l10n.serviceUnitCost),
                      subtitle: Text(l10n.serviceUnitCostHint),
                      trailing: Text(
                        formatOrderAmount(ref, product.purchasePrice),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.payableColor,
                            ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: OrderEmptyState(
                    icon: Icons.miscellaneous_services_outlined,
                    message: l10n.serviceNoStockHint,
                    color: accent,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ProductHero extends StatelessWidget {
  final Product product;
  final ProductCategory? category;
  final Color accent;
  final bool isLowStock;

  const _ProductHero({
    required this.product,
    required this.category,
    required this.accent,
    required this.isLowStock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final gradient = AppColors.getPrimaryGradient(accent);
    const onGradient = Colors.white;
    final muted = Colors.white.withValues(alpha: 0.88);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.42),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -24,
              top: -28,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Row(
                children: [
                  _HeroIcon(
                    category: category,
                    product: product,
                    accent: accent,
                    serviceTooltip: l10n.serviceProduct,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: onGradient,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        if (product.sku != null &&
                            product.sku!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.sku!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (!product.isService)
                              _HeroPill(
                                icon: Icons.straighten_outlined,
                                label: product.unit,
                              ),
                            if (category != null)
                              _HeroPill(
                                icon: categoryIconData(category),
                                label: category!.name,
                              ),
                            if (isLowStock)
                              _HeroPill(
                                icon: Icons.warning_amber_rounded,
                                label: l10n.lowStock,
                              ),
                            if (!product.isService &&
                                product.minStockAlert != null)
                              _HeroPill(
                                icon: Icons.notifications_active_outlined,
                                label: l10n.minStockLabel(
                                  AmountFormatter.formatQuantity(
                                    product.minStockAlert!,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  final Product product;
  final ProductCategory? category;
  final Color accent;
  final String serviceTooltip;

  const _HeroIcon({
    required this.product,
    required this.category,
    required this.accent,
    required this.serviceTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final icon = categoryIconData(category);
    final box = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Icon(icon, color: Colors.white, size: 30),
    );

    if (!product.isService) return box;

    return Tooltip(
      message: serviceTooltip,
      child: SizedBox(
        width: 68,
        height: 68,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            box,
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Icon(
                  Icons.miscellaneous_services_outlined,
                  size: 13,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _StockSummaryPanel extends StatelessWidget {
  final String onHandLabel;
  final String onHandValue;
  final String? onHandUnit;
  final Color onHandColor;
  final String avgUnitCostLabel;
  final String avgUnitCostValue;
  final Color avgUnitCostColor;
  final String inventoryValueLabel;
  final String inventoryValueAmount;
  final Color inventoryValueColor;
  final String consumedLabel;
  final String consumedValue;
  final String? consumedUnit;
  final Color consumedColor;
  final String consumedWorthLabel;
  final String consumedWorthAmount;
  final Color consumedWorthColor;
  final String openLotsLabel;
  final String openLotsValue;
  final Color openLotsColor;

  const _StockSummaryPanel({
    required this.onHandLabel,
    required this.onHandValue,
    required this.onHandColor,
    required this.avgUnitCostLabel,
    required this.avgUnitCostValue,
    required this.avgUnitCostColor,
    required this.inventoryValueLabel,
    required this.inventoryValueAmount,
    required this.inventoryValueColor,
    required this.consumedLabel,
    required this.consumedValue,
    required this.consumedColor,
    required this.consumedWorthLabel,
    required this.consumedWorthAmount,
    required this.consumedWorthColor,
    required this.openLotsLabel,
    required this.openLotsValue,
    required this.openLotsColor,
    this.onHandUnit,
    this.consumedUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: onHandLabel,
                value: onHandValue,
                unit: onHandUnit,
                valueColor: onHandColor,
                accent: onHandColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                label: avgUnitCostLabel,
                value: avgUnitCostValue,
                valueColor: avgUnitCostColor,
                accent: avgUnitCostColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                label: inventoryValueLabel,
                value: inventoryValueAmount,
                valueColor: inventoryValueColor,
                accent: inventoryValueColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: consumedLabel,
                value: consumedValue,
                unit: consumedUnit,
                valueColor: consumedColor,
                accent: consumedColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                label: consumedWorthLabel,
                value: consumedWorthAmount,
                valueColor: consumedWorthColor,
                accent: consumedWorthColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                label: openLotsLabel,
                value: openLotsValue,
                valueColor: openLotsColor,
                accent: openLotsColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color valueColor;
  final Color accent;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.accent,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: AppColors.transactionListItemDecoration(theme, accent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          _QtyWithUnit(
            quantity: value,
            unit: unit,
            quantityStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1,
            ),
            unitColor: valueColor.withValues(alpha: 0.75),
          ),
        ],
      ),
    );
  }
}

class _LotFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LotFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return FilterChip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      showCheckmark: false,
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: primary.withValues(alpha: 0.15),
      side: BorderSide(
        color: selected
            ? primary
            : theme.colorScheme.outline.withValues(alpha: 0.4),
      ),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: selected ? primary : theme.colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      ),
    );
  }
}

Color _lotAccent(BuildContext context, ProductBatche lot) {
  if (!lot.isOpen) return Theme.of(context).colorScheme.outline;
  if (lot.expiryDate != null) {
    final days = lot.expiryDate!.difference(DateTime.now()).inDays;
    if (days <= 60) return AppColors.warning;
  }
  if (lot.isManual) return AppColors.info;
  return AppColors.expenseColor;
}

String _lotTypeLabel(AppLocalizations l10n, ProductBatche lot) {
  if (!lot.isManual) return l10n.lotTypePurchase;
  switch (lot.manualType) {
    case ManualBatchType.opening:
      return l10n.lotTypeOpening;
    case ManualBatchType.production:
      return l10n.lotTypeProduction;
    default:
      return l10n.lotTypeAdjustment;
  }
}

IconData _lotTypeIcon(ProductBatche lot) {
  if (!lot.isManual) return Icons.local_shipping_outlined;
  switch (lot.manualType) {
    case ManualBatchType.opening:
      return Icons.inventory_2_outlined;
    case ManualBatchType.production:
      return Icons.precision_manufacturing_outlined;
    default:
      return Icons.tune_outlined;
  }
}

/// Shared value-first card for a single lot or a multi-lot batch summary.
class _QtyWithUnit extends StatelessWidget {
  final String quantity;
  final String? unit;
  final TextStyle? quantityStyle;
  final Color? unitColor;

  const _QtyWithUnit({
    required this.quantity,
    this.unit,
    this.quantityStyle,
    this.unitColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final hasUnit = unit != null && unit!.trim().isNotEmpty;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            quantity,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: quantityStyle,
          ),
          if (hasUnit) ...[
            const SizedBox(width: 4),
            Text(
              unit!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: unitColor ?? muted,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QtyFocusCard extends ConsumerWidget {
  final double total;
  final double consumed;
  final double remaining;
  final double unitCost;
  final double inventoryValue;
  final DateTime? earliestExpiry;
  final String? orderHint;
  final String dateFormat;
  final Color accent;
  final String unit;
  final bool dense;
  final VoidCallback? onOpenOrder;
  final Widget? bottom;
  final Widget? trailing;

  /// Corner badge: type icon (lot) or omitted when [countBadge] is set.
  final IconData? badgeIcon;
  final String? badgeTooltip;
  /// Batch summary: number of lots in the corner badge.
  final int? countBadge;
  /// Footer: batch label (single lot or batch header).
  final String? footerBatch;
  /// Optional lot note; shown only when non-empty.
  final String? description;
  /// Manual lots: edit affordance next to remaining qty.
  final bool showEditIcon;

  const _QtyFocusCard({
    required this.total,
    required this.consumed,
    required this.remaining,
    required this.unitCost,
    required this.inventoryValue,
    required this.dateFormat,
    required this.accent,
    required this.unit,
    this.earliestExpiry,
    this.orderHint,
    this.dense = false,
    this.onOpenOrder,
    this.bottom,
    this.trailing,
    this.badgeIcon,
    this.badgeTooltip,
    this.countBadge,
    this.footerBatch,
    this.description,
    this.showEditIcon = false,
  });

  static Widget lot({
    required ProductBatche lot,
    required String unit,
    required LotPurchaseContext? source,
    required String dateFormat,
    required bool showBatchInFooter,
    VoidCallback? onOpenOrder,
    bool dense = false,
  }) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final accent = _lotAccent(context, lot);
        final desc = lot.description?.trim();
        return _QtyFocusCard(
          total: lot.totalQuantity,
          consumed: lot.consumedQuantity,
          remaining: lot.remainingQuantity,
          unitCost: lot.effectiveCost,
          inventoryValue: lot.remainingQuantity * lot.effectiveCost,
          earliestExpiry: lot.expiryDate,
          orderHint: source?.orderNumber,
          dateFormat: dateFormat,
          accent: accent,
          unit: unit,
          dense: dense,
          onOpenOrder: onOpenOrder,
          badgeIcon: _lotTypeIcon(lot),
          badgeTooltip: _lotTypeLabel(l10n, lot),
          footerBatch: showBatchInFooter && lot.batchNumber.isNotEmpty
              ? lot.batchNumber
              : null,
          description: desc == null || desc.isEmpty ? null : desc,
          showEditIcon: lot.isManual,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final life = total <= 0 ? 0.0 : (remaining / total).clamp(0.0, 1.0);
    final lifeColor = life <= 0
        ? theme.colorScheme.outline
        : life <= 0.25
            ? AppColors.warning
            : accent;
    final muted = theme.colorScheme.onSurfaceVariant;
    final pad = dense ? 10.0 : 14.0;

    final expiryWarn = earliestExpiry != null &&
        earliestExpiry!.difference(DateTime.now()).inDays <= 60;
    final hasDescription =
        description != null && description!.trim().isNotEmpty;
    final hasFooter = hasDescription ||
        (footerBatch != null && footerBatch!.isNotEmpty) ||
        earliestExpiry != null ||
        (orderHint != null && orderHint!.isNotEmpty);

    return Container(
      decoration: dense
          ? BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            )
          : AppColors.transactionListItemDecoration(theme, accent),
      clipBehavior: Clip.none,
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.none,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: onOpenOrder,
                  borderRadius: BorderRadius.circular(dense ? 14 : 20),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      pad,
                      pad + ((badgeIcon != null || countBadge != null) ? 4 : 0),
                      pad,
                      pad,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _StatusCluster(
                          trailing: trailing,
                          remainingLabel: l10n.lotRemaining,
                          remainingValue:
                              AmountFormatter.formatQuantity(remaining),
                          unit: unit,
                          remainingColor: remaining <= 0
                              ? muted
                              : life <= 0.25
                                  ? AppColors.warning
                                  : AppColors.incomeColor,
                          life: life,
                          lifeColor: lifeColor,
                          dense: dense,
                          showEditIcon: showEditIcon,
                        ),
                        SizedBox(height: dense ? 10 : 12),
                        _MetricStrip(
                          children: [
                            _QtyStat(
                              label: l10n.lotTotal,
                              value: AmountFormatter.formatQuantity(total),
                              unit: unit,
                              valueColor: theme.colorScheme.onSurface,
                            ),
                            _QtyStat(
                              label: l10n.lotConsumed,
                              value: AmountFormatter.formatQuantity(consumed),
                              unit: unit,
                              valueColor: AppColors.expenseColor,
                            ),
                          ],
                        ),
                        SizedBox(height: dense ? 8 : 10),
                        _MetricStrip(
                          children: [
                            _QtyStat(
                              label: l10n.lotUnitCost,
                              value: formatOrderAmount(ref, unitCost),
                              valueColor: AppColors.payableColor,
                            ),
                            _QtyStat(
                              label: l10n.lotInventoryCost,
                              value: formatOrderAmount(ref, inventoryValue),
                              valueColor: AppColors.receivableColor,
                              emphasize: true,
                            ),
                          ],
                        ),
                        if (hasFooter) ...[
                          SizedBox(height: dense ? 8 : 10),
                          _ItemFooter(
                            batch: footerBatch,
                            expiryText: earliestExpiry == null
                                ? null
                                : AppDateFormatter.formatDate(
                                    earliestExpiry!,
                                    pattern: dateFormat,
                                  ),
                            expiryWarn: expiryWarn,
                            orderHint: orderHint,
                            description: hasDescription ? description : null,
                            dense: dense,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (bottom != null) bottom!,
              ],
            ),
            if (badgeIcon != null || countBadge != null)
              PositionedDirectional(
                top: -2,
                start: -2,
                child: _CornerBadge(
                  icon: badgeIcon,
                  count: countBadge,
                  color: accent,
                  tooltip: badgeTooltip ??
                      (countBadge != null
                          ? l10n.lotsInBatch(countBadge!)
                          : null),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Remaining + life bar (+ expand trailing). Type lives on the corner badge.
class _StatusCluster extends StatelessWidget {
  final Widget? trailing;
  final String remainingLabel;
  final String remainingValue;
  final String unit;
  final Color remainingColor;
  final double life;
  final Color lifeColor;
  final bool dense;
  final bool showEditIcon;

  const _StatusCluster({
    required this.remainingLabel,
    required this.remainingValue,
    required this.unit,
    required this.remainingColor,
    required this.life,
    required this.lifeColor,
    required this.dense,
    this.trailing,
    this.showEditIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final qtyStyle = (dense
            ? theme.textTheme.headlineSmall
            : theme.textTheme.headlineMedium)
        ?.copyWith(
      fontWeight: FontWeight.w900,
      height: 1,
      letterSpacing: -0.6,
      color: remainingColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 18), // room for corner badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    remainingLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: _QtyWithUnit(
                          quantity: remainingValue,
                          unit: unit,
                          quantityStyle: qtyStyle,
                          unitColor: remainingColor.withValues(alpha: 0.75),
                        ),
                      ),
                      if (showEditIcon) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.edit_outlined,
                          size: dense ? 16 : 18,
                          color: remainingColor.withValues(alpha: 0.75),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  height: dense ? 8 : 10,
                  child: Stack(
                    children: [
                      ColoredBox(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.08),
                        child: const SizedBox.expand(),
                      ),
                      FractionallySizedBox(
                        widthFactor: life,
                        child: ColoredBox(color: lifeColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(life * 100).round()}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: lifeColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CornerBadge extends StatelessWidget {
  final IconData? icon;
  final int? count;
  final Color color;
  final String? tooltip;

  const _CornerBadge({
    required this.color,
    this.icon,
    this.count,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: count != null
          ? Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            )
          : Icon(icon, size: 14, color: color),
    );
    if (tooltip == null || tooltip!.isEmpty) return child;
    return Tooltip(message: tooltip!, child: child);
  }
}

class _ItemFooter extends StatelessWidget {
  final String? batch;
  final String? expiryText;
  final bool expiryWarn;
  final String? orderHint;
  final String? description;
  final bool dense;

  const _ItemFooter({
    this.batch,
    this.expiryText,
    this.expiryWarn = false,
    this.orderHint,
    this.description,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final hasBatch = batch != null && batch!.isNotEmpty;
    final hasExpiry = expiryText != null && expiryText!.isNotEmpty;
    final hasOrder = orderHint != null && orderHint!.isNotEmpty;
    final hasDescription = description != null && description!.trim().isNotEmpty;

    if (!hasBatch && !hasExpiry && !hasOrder && !hasDescription) {
      return const SizedBox.shrink();
    }

    TextStyle valueStyle(Color color) => TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          height: 1.2,
        );

    Widget cell({
      required IconData icon,
      required String value,
      required Color color,
      String? secondary,
      Color? secondaryColor,
      int maxLines = 1,
    }) {
      return Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: valueStyle(color),
                ),
                if (secondary != null)
                  Text(
                    secondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: valueStyle(secondaryColor ?? muted),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    Widget field(Widget child, {bool expand = true}) {
      final box = Container(
        width: expand ? null : double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
      return expand ? Expanded(child: box) : box;
    }

    final batchCell = hasBatch || hasOrder
        ? cell(
            icon: Icons.qr_code_2_outlined,
            value: hasBatch ? batch! : '—',
            color: muted,
            secondary: hasOrder ? orderHint : null,
            secondaryColor: theme.colorScheme.primary,
          )
        : null;
    final expiryCell = hasExpiry
        ? cell(
            icon: Icons.event_outlined,
            value: expiryText!,
            color: expiryWarn ? AppColors.warning : muted,
          )
        : null;
    final descriptionField = hasDescription
        ? field(
            cell(
              icon: Icons.notes_outlined,
              value: description!.trim(),
              color: muted,
              maxLines: dense ? 2 : 3,
            ),
            expand: false,
          )
        : null;

    Widget? metaRow;
    if (batchCell != null && expiryCell != null) {
      metaRow = Row(
        children: [
          field(batchCell),
          const SizedBox(width: 6),
          field(expiryCell),
        ],
      );
    } else {
      final only = batchCell ?? expiryCell;
      if (only != null) {
        metaRow = Row(children: [field(only)]);
      }
    }

    if (metaRow != null && descriptionField != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          metaRow,
          const SizedBox(height: 6),
          descriptionField,
        ],
      );
    }
    return metaRow ?? descriptionField ?? const SizedBox.shrink();
  }
}

class _MetricStrip extends StatelessWidget {
  final List<Widget> children;

  const _MetricStrip({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: theme.dividerColor.withValues(alpha: 0.6),
              ),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}

class _QtyStat extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color? valueColor;
  final bool emphasize;

  const _QtyStat({
    required this.label,
    required this.value,
    this.unit,
    this.valueColor,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        _QtyWithUnit(
          quantity: value,
          unit: unit,
          quantityStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
            color: valueColor,
            fontSize: 13,
            height: 1,
          ),
          unitColor: (valueColor ?? theme.colorScheme.onSurface)
              .withValues(alpha: 0.7),
        ),
      ],
    );
  }
}

class _BatchLotPanel extends StatefulWidget {
  final Product product;
  final String batchNumber;
  final List<ProductBatche> lots;
  final Map<String, LotPurchaseContext> sources;
  final String dateFormat;
  final ValueChanged<ProductBatche> onEditManualLot;

  const _BatchLotPanel({
    required this.product,
    required this.batchNumber,
    required this.lots,
    required this.sources,
    required this.dateFormat,
    required this.onEditManualLot,
  });

  @override
  State<_BatchLotPanel> createState() => _BatchLotPanelState();
}

class _BatchLotPanelState extends State<_BatchLotPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lots = widget.lots;
    final total = lots.fold<double>(0, (s, l) => s + l.totalQuantity);
    final consumed = lots.fold<double>(0, (s, l) => s + l.consumedQuantity);
    final remaining = lots.fold<double>(0, (s, l) => s + l.remainingQuantity);
    final inventoryValue = lots.fold<double>(
      0,
      (s, l) => s + l.remainingQuantity * l.effectiveCost,
    );
    final unitCost = remaining > 1e-9
        ? inventoryValue / remaining
        : lots.fold<double>(0, (s, l) => s + l.effectiveCost) / lots.length;

    DateTime? earliest;
    for (final lot in lots) {
      final exp = lot.expiryDate;
      if (exp == null) continue;
      if (earliest == null || exp.isBefore(earliest)) earliest = exp;
    }

    final accent = remaining <= 1e-9
        ? theme.colorScheme.outline
        : (earliest != null &&
                earliest.difference(DateTime.now()).inDays <= 60
            ? AppColors.warning
            : AppColors.incomeColor);

    return _QtyFocusCard(
      total: total,
      consumed: consumed,
      remaining: remaining,
      unitCost: unitCost,
      inventoryValue: inventoryValue,
      earliestExpiry: earliest,
      dateFormat: widget.dateFormat,
      accent: accent,
      unit: widget.product.unit,
      countBadge: lots.length,
      footerBatch: widget.batchNumber,
      onOpenOrder: () => setState(() => _expanded = !_expanded),
      trailing: Icon(
        _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      bottom: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: !_expanded
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                    child: Column(
                      children: [
                        for (var i = 0; i < lots.length; i++) ...[
                          if (i > 0) const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              final lot = lots[i];
                              final src = widget.sources[lot.uuid];
                              return _QtyFocusCard.lot(
                                lot: lot,
                                unit: widget.product.unit,
                                source: src,
                                dateFormat: widget.dateFormat,
                                showBatchInFooter: false,
                                dense: true,
                                onOpenOrder: lot.isManual
                                    ? () => widget.onEditManualLot(lot)
                                    : src == null
                                        ? null
                                        : () {
                                            Navigator.push<void>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    OrderDetailScreen(
                                                  orderUuid: src.orderUuid,
                                                ),
                                              ),
                                            );
                                          },
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ManualLotSheet extends ConsumerStatefulWidget {
  final Product product;
  final ProductBatche? existing;

  const _ManualLotSheet({
    required this.product,
    this.existing,
  });

  @override
  ConsumerState<_ManualLotSheet> createState() => _ManualLotSheetState();
}

class _ManualLotSheetState extends ConsumerState<_ManualLotSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _qty;
  late final TextEditingController _cost;
  late final TextEditingController _batch;
  late final TextEditingController _description;
  late String _manualType;
  DateTime? _expiry;
  DateTime? _mfg;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final lot = widget.existing;
    _qty = TextEditingController(
      text: lot == null
          ? ''
          : AmountFormatter.formatQuantity(lot.remainingQuantity),
    );
    _cost = TextEditingController(
      text: lot == null ? '' : AmountFormatter.formatQuantity(lot.effectiveCost),
    );
    _batch = TextEditingController(text: lot?.batchNumber ?? '');
    _description = TextEditingController(text: lot?.description ?? '');
    _manualType = lot?.manualType ?? ManualBatchType.opening;
    if (_manualType.isEmpty || !ManualBatchType.all.contains(_manualType)) {
      _manualType = ManualBatchType.opening;
    }
    _expiry = lot?.expiryDate;
    _mfg = lot?.manufactureDate;
  }

  @override
  void dispose() {
    _qty.dispose();
    _cost.dispose();
    _batch.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool expiry}) async {
    final now = DateTime.now();
    final initial = expiry ? (_expiry ?? now) : (_mfg ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 30),
    );
    if (picked == null) return;
    setState(() {
      if (expiry) {
        _expiry = picked;
      } else {
        _mfg = picked;
      }
    });
  }

  Future<void> _pickBatchNumber() async {
    final l10n = AppLocalizations.of(context)!;
    final batches = await ref
        .read(inventoryRepositoryProvider)
        .distinctBatchNumbers(widget.product.uuid);
    if (!mounted) return;
    if (batches.isEmpty) {
      ToastUtils.showErrorToast(context, ref, l10n.noOpenLots);
      return;
    }
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text(l10n.selectBatch)),
            for (final b in batches)
              ListTile(
                title: Text(b),
                onTap: () => Navigator.pop(context, b),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _batch.text = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final qty = double.tryParse(_qty.text.trim());
    final cost = double.tryParse(_cost.text.trim()) ?? 0;
    if (qty == null) return;
    if (!_isEditing && qty <= 0) return;
    if (_isEditing && qty < 0) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final existing = widget.existing;
      final description = _description.text.trim();
      if (existing == null) {
        await repo.receiveIntoBatch(
          productUuid: widget.product.uuid,
          quantity: qty,
          effectiveCost: cost,
          batchNumber: _batch.text.trim().isEmpty ? null : _batch.text.trim(),
          isManual: true,
          manualType: _manualType,
          manufactureDate: _mfg,
          expiryDate: _expiry,
          description: description.isEmpty ? null : description,
        );
      } else {
        await repo.updateManualLot(
          lotUuid: existing.uuid,
          remainingQuantity: qty,
          effectiveCost: cost,
          batchNumber: _batch.text.trim().isEmpty ? null : _batch.text.trim(),
          manualType: _manualType,
          manufactureDate: _mfg,
          expiryDate: _expiry,
          description: description.isEmpty ? null : description,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final existing = widget.existing;
    final consumed = existing?.consumedQuantity ?? 0;
    final willSplitCost = existing != null &&
        consumed > 1e-9 &&
        existing.remainingQuantity > 1e-9;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  _isEditing ? l10n.editManualLot : l10n.addManualLot,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (willSplitCost) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.manualLotCostSplitHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  l10n.selectLotType,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final type in ManualBatchType.all)
                      ChoiceChip(
                        label: Text(_manualTypeLabel(l10n, type)),
                        selected: _manualType == type,
                        onSelected: (_) => setState(() => _manualType = type),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _qty,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: _isEditing
                        ? '${l10n.lotRemaining} (${widget.product.unit})'
                        : '${l10n.lotQuantity} (${widget.product.unit})',
                    helperText: _isEditing && consumed > 1e-9
                        ? l10n.consumedQtyHint(
                            AmountFormatter.formatQuantity(consumed),
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final n = double.tryParse(v?.trim() ?? '');
                    if (n == null) return l10n.pleaseEnterValidNumber;
                    if (_isEditing) {
                      if (n < 0) return l10n.pleaseEnterValidNumber;
                    } else if (n <= 0) {
                      return l10n.pleaseEnterValidNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final isRtl =
                        Directionality.of(context) == TextDirection.rtl;
                    final affix = AmountFormatter.currencyAffix(
                      ref.watch(currencySymbolProvider),
                      isRtl: isRtl,
                    );
                    return TextFormField(
                      controller: _cost,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.effectiveCostLabel,
                        prefixText: affix.prefixText,
                        suffixText: affix.suffixText,
                        border: const OutlineInputBorder(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _batch,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l10n.lotBatchNumber,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: l10n.selectBatch,
                      onPressed: _pickBatchNumber,
                      icon: const Icon(Icons.list_alt_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.lotDescription,
                    hintText: l10n.lotDescriptionHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(expiry: false),
                        icon: const Icon(Icons.factory_outlined, size: 18),
                        label: Text(
                          _mfg == null
                              ? l10n.lotManufacture
                              : AppDateFormatter.formatDate(
                                  _mfg!,
                                  pattern: dateFormat,
                                ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(expiry: true),
                        icon: const Icon(Icons.event_outlined, size: 18),
                        label: Text(
                          _expiry == null
                              ? l10n.lotExpiry
                              : AppDateFormatter.formatDate(
                                  _expiry!,
                                  pattern: dateFormat,
                                ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                GradientButton(
                  label: l10n.save,
                  isLoading: _saving,
                  width: double.infinity,
                  gradient: AppColors.getPrimaryGradient(AppColors.info),
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _manualTypeLabel(AppLocalizations l10n, String type) {
    switch (type) {
      case ManualBatchType.opening:
        return l10n.lotTypeOpening;
      case ManualBatchType.production:
        return l10n.lotTypeProduction;
      default:
        return l10n.lotTypeAdjustment;
    }
  }
}
