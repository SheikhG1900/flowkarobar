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
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:material_symbols_icons/symbols.dart';

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

  Future<void> _openAddManualLot(Product product) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddManualLotSheet(product: product),
    );
    if (saved == true && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ToastUtils.showSuccessToast(context, ref, l10n.manualLotSaved);
    }
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
        final inventoryValue = openLots.fold<double>(
          0,
          (sum, l) => sum + (l.remainingQuantity * l.effectiveCost),
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
          floatingActionButton: product.isService
              ? null
              : AppFloatingActionButton(
                  heroTag: 'add_manual_lot_fab',
                  tooltip: l10n.addManualLot,
                  onPressed: () => _openAddManualLot(product),
                  child: const Icon(Icons.add),
                ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              _ProductHero(
                product: product,
                category: category,
                accent: accent,
                isLowStock: isLowStock,
              ),
              if (!product.isService) ...[
                const SizedBox(height: 14),
                _StockSnapshotRow(
                  onHandLabel: l10n.onHandStock,
                  onHandValue:
                      '${AmountFormatter.formatQuantity(product.stockQuantity)} ${product.unit}',
                  openLotsLabel: l10n.openLots,
                  openLotsValue: '${openLots.length}',
                  valueLabel: l10n.inventoryValue,
                  valueAmount: formatOrderAmount(ref, inventoryValue),
                  accent: isLowStock ? AppColors.warning : accent,
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
                    _LotFilterChip(
                      label: l10n.lotFilterOpen,
                      selected: _filter == _LotFilter.open,
                      onTap: () => setState(() => _filter = _LotFilter.open),
                    ),
                    const SizedBox(width: 6),
                    _LotFilterChip(
                      label: l10n.lotFilterAll,
                      selected: _filter == _LotFilter.all,
                      onTap: () => setState(() => _filter = _LotFilter.all),
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
                const SizedBox(height: 10),
                if (batchesAsync.isLoading && lots.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: OrderEmptyState(
                      icon: Icons.inventory_2_outlined,
                      message: lots.isEmpty
                          ? l10n.noLotsYet
                          : l10n.noOpenLots,
                      color: accent,
                    ),
                  )
                else
                  for (final key in groupKeys) ...[
                    if (grouped.length > 1 || key.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 6, left: 2),
                        child: Text(
                          key.isEmpty ? '—' : key,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    for (final lot in grouped[key]!) ...[
                      Builder(
                        builder: (context) {
                          final lotSource = sources[lot.uuid];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _LotCard(
                              lot: lot,
                              unit: product.unit,
                              source: lotSource,
                              dateFormat: dateFormat,
                              onOpenOrder: lotSource == null
                                  ? null
                                  : () {
                                      Navigator.push<void>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OrderDetailScreen(
                                            orderUuid: lotSource.orderUuid,
                                          ),
                                        ),
                                      );
                                    },
                            ),
                          );
                        },
                      ),
                    ],
                  ],
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: OrderEmptyState(
                    icon: Icons.miscellaneous_services_outlined,
                    message: l10n.serviceNoStockHint,
                    color: accent,
                  ),
                ),
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
            Positioned(
              right: -24,
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
            Positioned(
              right: 0,
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

class _StockSnapshotRow extends StatelessWidget {
  final String onHandLabel;
  final String onHandValue;
  final String openLotsLabel;
  final String openLotsValue;
  final String valueLabel;
  final String valueAmount;
  final Color accent;

  const _StockSnapshotRow({
    required this.onHandLabel,
    required this.onHandValue,
    required this.openLotsLabel,
    required this.openLotsValue,
    required this.valueLabel,
    required this.valueAmount,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: onHandLabel,
            value: onHandValue,
            accent: accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            label: openLotsLabel,
            value: openLotsValue,
            accent: accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            label: valueLabel,
            value: valueAmount,
            accent: accent,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.accent,
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
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
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

class _LotCard extends StatelessWidget {
  final ProductBatche lot;
  final String unit;
  final LotPurchaseContext? source;
  final String dateFormat;
  final VoidCallback? onOpenOrder;

  const _LotCard({
    required this.lot,
    required this.unit,
    required this.source,
    required this.dateFormat,
    this.onOpenOrder,
  });

  Color _accent(BuildContext context) {
    if (!lot.isOpen) {
      return Theme.of(context).colorScheme.outline;
    }
    if (lot.expiryDate != null) {
      final days = lot.expiryDate!.difference(DateTime.now()).inDays;
      if (days <= 60) return AppColors.warning;
    }
    if (lot.isManual) return AppColors.info;
    return AppColors.expenseColor;
  }

  String _typeLabel(AppLocalizations l10n) {
    if (!lot.isManual) return l10n.lotTypePurchase;
    switch (lot.manualType) {
      case ManualBatchType.opening:
        return l10n.lotTypeOpening;
      case ManualBatchType.production:
        return l10n.lotTypeProduction;
      case ManualBatchType.adjustment:
        return l10n.lotTypeAdjustment;
      default:
        return l10n.lotTypeAdjustment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = _accent(context);
    final remaining = lot.remainingQuantity;
    final progress = lot.totalQuantity <= 0
        ? 0.0
        : (lot.consumedQuantity / lot.totalQuantity).clamp(0.0, 1.0);

    return Container(
      decoration: AppColors.transactionListItemDecoration(theme, accent),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onOpenOrder,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    OrderStatusChip(
                      label: _typeLabel(l10n),
                      color: accent,
                      icon: lot.isManual
                          ? Icons.handyman_outlined
                          : Icons.local_shipping_outlined,
                    ),
                    const Spacer(),
                    Text(
                      '${AmountFormatter.formatQuantity(remaining)} $unit',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: lot.isOpen
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.lotRemaining} · ${l10n.ofTotalQty(AmountFormatter.formatQuantity(lot.totalQuantity))} · ${l10n.lotConsumed} ${AmountFormatter.formatQuantity(lot.consumedQuantity)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: accent.withValues(alpha: 0.12),
                    color: accent.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.payments_outlined,
                        size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      '${l10n.lotUnitCost}: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, _) => Text(
                        formatOrderAmount(ref, lot.effectiveCost),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (lot.expiryDate != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 14,
                        color: accent == AppColors.warning
                            ? AppColors.warning
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${l10n.lotExpiry}: ${AppDateFormatter.formatDate(lot.expiryDate!, pattern: dateFormat)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: accent == AppColors.warning
                              ? AppColors.warning
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (source != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Symbols.receipt_long, size: 16, color: accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                source!.orderNumber,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                              if (source!.supplierName != null)
                                Text(
                                  l10n.fromSupplier(source!.supplierName!),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              if (source!.receivedAt != null)
                                Text(
                                  l10n.receivedOn(
                                    AppDateFormatter.formatDate(
                                      source!.receivedAt!,
                                      pattern: dateFormat,
                                    ),
                                  ),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: accent,
                        ),
                      ],
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

class _AddManualLotSheet extends ConsumerStatefulWidget {
  final Product product;

  const _AddManualLotSheet({required this.product});

  @override
  ConsumerState<_AddManualLotSheet> createState() => _AddManualLotSheetState();
}

class _AddManualLotSheetState extends ConsumerState<_AddManualLotSheet> {
  final _formKey = GlobalKey<FormState>();
  final _qty = TextEditingController();
  final _cost = TextEditingController();
  final _batch = TextEditingController();
  String _manualType = ManualBatchType.opening;
  DateTime? _expiry;
  DateTime? _mfg;
  bool _saving = false;

  @override
  void dispose() {
    _qty.dispose();
    _cost.dispose();
    _batch.dispose();
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

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    final qty = double.tryParse(_qty.text.trim());
    final cost = double.tryParse(_cost.text.trim()) ?? 0;
    if (qty == null || qty <= 0) return;

    setState(() => _saving = true);
    try {
      await ref.read(inventoryRepositoryProvider).receiveIntoBatch(
            productUuid: widget.product.uuid,
            quantity: qty,
            effectiveCost: cost,
            batchNumber: _batch.text.trim().isEmpty ? null : _batch.text.trim(),
            isManual: true,
            manualType: _manualType,
            manufactureDate: _mfg,
            expiryDate: _expiry,
          );
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
                  l10n.addManualLot,
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
                    labelText: '${l10n.lotQuantity} (${widget.product.unit})',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final n = double.tryParse(v?.trim() ?? '');
                    if (n == null || n <= 0) {
                      return l10n.pleaseEnterValidNumber;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cost,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: l10n.effectiveCostLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _batch,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l10n.lotBatchNumber,
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
