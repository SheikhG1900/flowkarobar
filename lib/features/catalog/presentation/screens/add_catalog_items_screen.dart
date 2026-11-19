import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/catalog/data/catalog_repository.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_discounts.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_pricing.dart';
import 'package:flowpaisa/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flowpaisa/features/catalog/presentation/widgets/catalog_discount_editor.dart';
import 'package:flowpaisa/features/catalog/presentation/widgets/catalog_pricing_approach_picker.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_entity_pickers.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/entity_picker_sheet.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/shared/widgets/hover_border_card.dart';

class _SelectableTarget {
  final String? productUuid;
  final String? sellingProductUuid;
  final String name;
  final bool isSelling;
  final bool isService;
  final String? categoryUuid;

  _SelectableTarget.product(Product p)
      : productUuid = p.uuid,
        sellingProductUuid = null,
        name = p.name,
        isSelling = false,
        isService = p.isService,
        categoryUuid = p.categoryUuid;

  _SelectableTarget.selling(SellingProduct sp)
      : productUuid = null,
        sellingProductUuid = sp.uuid,
        name = sp.name,
        isSelling = true,
        isService = false,
        categoryUuid = sp.categoryUuid;

  String get key => productUuid ?? sellingProductUuid!;
}

class AddCatalogItemsScreen extends ConsumerStatefulWidget {
  final String catalogUuid;

  const AddCatalogItemsScreen({super.key, required this.catalogUuid});

  @override
  ConsumerState<AddCatalogItemsScreen> createState() =>
      _AddCatalogItemsScreenState();
}

class _AddCatalogItemsScreenState extends ConsumerState<AddCatalogItemsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _selected = <String>{};
  final _percent = TextEditingController(text: '0');
  final _fixed = TextEditingController(text: '0');
  final _defaultDiscountValue = TextEditingController();
  final _tiers = <CatalogDiscountTierDraft>[];
  String _approach = CatalogPricingApproach.markup;
  bool _enableDefaultDiscount = false;
  String _defaultDiscountType = CatalogDiscountType.percent;
  bool _saving = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadCatalogDefaults();
  }

  Future<void> _loadCatalogDefaults() async {
    final catalog =
        await ref.read(catalogRepositoryProvider).getCatalog(widget.catalogUuid);
    if (!mounted || catalog == null) return;
    final approach =
        CatalogPricingApproach.all.contains(catalog.defaultPricingApproach)
            ? catalog.defaultPricingApproach
            : CatalogPricingApproach.markup;
    setState(() {
      _approach = approach;
      _percent.text = catalog.defaultMarkupOrMarginPercent.toString();
      _fixed.text = catalog.defaultFixedAmount.toString();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _percent.dispose();
    _fixed.dispose();
    _defaultDiscountValue.dispose();
    for (final t in _tiers) {
      t.dispose();
    }
    super.dispose();
  }

  CatalogItemDiscountInput _discountInput() {
    final tiers = <CatalogDiscountTierInput>[
      for (final t in _tiers)
        if (t.toInputOrNull() != null) t.toInputOrNull()!,
    ];
    if (!_enableDefaultDiscount) {
      return CatalogItemDiscountInput(tiers: tiers);
    }
    return CatalogItemDiscountInput(
      defaultDiscountType: _defaultDiscountType,
      defaultDiscountValue:
          double.tryParse(_defaultDiscountValue.text.trim()) ?? 0,
      tiers: tiers,
    );
  }

  Future<void> _submit(List<_SelectableTarget> allTargets) async {
    final l10n = AppLocalizations.of(context)!;
    if (_selected.isEmpty) {
      ToastUtils.showErrorToast(context, ref, l10n.fieldRequired);
      return;
    }
    final percent = double.tryParse(_percent.text.trim()) ?? 0;
    final fixed = double.tryParse(_fixed.text.trim()) ?? 0;
    if (CatalogPricingApproach.isMarginBased(_approach) && percent >= 100) {
      ToastUtils.showErrorToast(context, ref, l10n.pricingFixedThenMarginHint);
      return;
    }

    final targets = allTargets
        .where((t) => _selected.contains(t.key))
        .map(
          (t) => CatalogItemPricingInput(
            productUuid: t.productUuid,
            sellingProductUuid: t.sellingProductUuid,
          ),
        )
        .toList();

    setState(() => _saving = true);
    try {
      final added = await ref.read(catalogRepositoryProvider).addItemsBulk(
            catalogUuid: widget.catalogUuid,
            targets: targets,
            pricingApproach: _approach,
            markupOrMarginPercent: percent,
            fixedAmount: fixed,
            discounts: _discountInput(),
          );
      if (!mounted) return;
      ToastUtils.showSuccessToast(
        context,
        ref,
        l10n.catalogImportDone(added, 0, targets.length - added),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
          context,
          ref,
          l10n.errorOccurred(e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = AppColors.receivableColor;
    final products =
        ref.watch(productsStreamProvider).value ?? const <Product>[];
    final selling =
        ref.watch(sellingProductsStreamProvider).value ?? const <SellingProduct>[];
    final existing =
        ref.watch(catalogItemsStreamProvider(widget.catalogUuid)).value ??
            const <CatalogItem>[];
    final existingProductIds = {
      for (final i in existing)
        if (i.productUuid != null) i.productUuid!,
    };
    final existingSellingIds = {
      for (final i in existing)
        if (i.sellingProductUuid != null) i.sellingProductUuid!,
    };

    final q = _query.trim().toLowerCase();
    final productTargets = products
        .where((p) => !existingProductIds.contains(p.uuid))
        .where((p) => q.isEmpty || p.name.toLowerCase().contains(q))
        .map(_SelectableTarget.product)
        .toList();
    final sellingTargets = selling
        .where((s) => !existingSellingIds.contains(s.uuid))
        .where((s) => q.isEmpty || s.name.toLowerCase().contains(q))
        .map(_SelectableTarget.selling)
        .toList();
    final allTargets = [...productTargets, ...sellingTargets];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addCatalogItems),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l10n.products),
            Tab(text: l10n.sellingProducts),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.48,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormSectionCard(
                  title: l10n.sectionPricing,
                  icon: Icons.calculate_outlined,
                  accentColor: accent,
                  children: [
                    CatalogPricingApproachPicker(
                      value: _approach,
                      accentColor: accent,
                      onChanged: (v) => setState(() => _approach = v),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _percent,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: l10n.markupOrMarginPercent,
                              filled: true,
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _fixed,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: InputDecoration(
                              labelText: l10n.fixedAmount,
                              filled: true,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                FormSectionCard(
                  title: l10n.discount,
                  icon: Icons.percent_outlined,
                  accentColor: accent,
                  children: [
                    CatalogDiscountEditor(
                      accent: accent,
                      enabledDefault: _enableDefaultDiscount,
                      defaultType: _defaultDiscountType,
                      defaultValue: _defaultDiscountValue,
                      onEnabledDefaultChanged: (v) =>
                          setState(() => _enableDefaultDiscount = v),
                      onDefaultTypeChanged: (v) =>
                          setState(() => _defaultDiscountType = v),
                      tiers: _tiers,
                      onAddTier: () => setState(
                        () => _tiers.add(CatalogDiscountTierDraft()),
                      ),
                      onRemoveTier: (i) => setState(() {
                        _tiers[i].dispose();
                        _tiers.removeAt(i);
                      }),
                      onTierTypeChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
                GradientButton(
                  label:
                      '${l10n.applyPricingAndAdd} (${l10n.selectedCount(_selected.length)})',
                  icon: Icons.check_rounded,
                  isLoading: _saving,
                  width: double.infinity,
                  gradient: AppColors.getPrimaryGradient(accent),
                  onPressed: _saving ? null : () => _submit(allTargets),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l10n.selectCatalogItems,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _TargetList(
                  targets: productTargets,
                  selected: _selected,
                  accent: accent,
                  emptyLabel: l10n.noProductsAvailable,
                  categoriesById: {
                    for (final c
                        in (ref.watch(productCategoriesStreamProvider).value ??
                            const <ProductCategory>[]))
                      c.uuid: c,
                  },
                  onToggle: (key) => setState(() {
                    if (_selected.contains(key)) {
                      _selected.remove(key);
                    } else {
                      _selected.add(key);
                    }
                  }),
                ),
                _TargetList(
                  targets: sellingTargets,
                  selected: _selected,
                  accent: accent,
                  emptyLabel: l10n.noSellingProductsYet,
                  categoriesById: {
                    for (final c
                        in (ref.watch(productCategoriesStreamProvider).value ??
                            const <ProductCategory>[]))
                      c.uuid: c,
                  },
                  onToggle: (key) => setState(() {
                    if (_selected.contains(key)) {
                      _selected.remove(key);
                    } else {
                      _selected.add(key);
                    }
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetList extends StatelessWidget {
  final List<_SelectableTarget> targets;
  final Set<String> selected;
  final Color accent;
  final String emptyLabel;
  final Map<String, ProductCategory> categoriesById;
  final ValueChanged<String> onToggle;

  const _TargetList({
    required this.targets,
    required this.selected,
    required this.accent,
    required this.emptyLabel,
    required this.categoriesById,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (targets.isEmpty) {
      return Center(child: Text(emptyLabel));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: targets.length,
      itemBuilder: (context, index) {
        final theme = Theme.of(context);
        final t = targets[index];
        final isOn = selected.contains(t.key);
        final category = t.categoryUuid == null
            ? null
            : categoriesById[t.categoryUuid];
        final itemAccent = parseCategoryColor(category?.color, accent);
        final fallback = t.isSelling
            ? Icons.sell_outlined
            : (t.isService
                ? Icons.miscellaneous_services_outlined
                : Icons.inventory_2_outlined);
        final icon =
            category == null ? fallback : categoryIconData(category);
        final categoryName = category?.name.trim();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: HoverBorderCard(
            accent: itemAccent,
            onTap: () => onToggle(t.key),
            padding: const EdgeInsets.all(16),
            fillColor: isOn
                ? itemAccent.withValues(alpha: 0.08)
                : null,
            child: Row(
              children: [
                categoryLeadingAvatar(
                  color: itemAccent,
                  icon: icon,
                  radius: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (categoryName != null &&
                          categoryName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          categoryName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: itemAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isOn
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: isOn
                      ? itemAccent
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
