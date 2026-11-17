import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/catalog/data/selling_product_repository.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_pricing.dart';
import 'package:flowpaisa/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_entity_pickers.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/entity_picker_sheet.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/shared/widgets/pending_sync_badge.dart';
import 'package:material_symbols_icons/symbols.dart';

final _decimalFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
];

class _ComponentLine {
  Product product;
  final TextEditingController qty;
  String consumeMode;
  String? batchNumber;

  _ComponentLine({
    required this.product,
    double quantity = 1,
    this.consumeMode = SellingConsumeMode.auto,
    this.batchNumber,
  }) : qty = TextEditingController(
          text: AmountFormatter.formatQuantity(quantity),
        );

  void dispose() => qty.dispose();
}

class AddSellingProductScreen extends ConsumerStatefulWidget {
  final String? existingUuid;

  const AddSellingProductScreen({super.key, this.existingUuid});

  @override
  ConsumerState<AddSellingProductScreen> createState() =>
      _AddSellingProductScreenState();
}

class _AddSellingProductScreenState
    extends ConsumerState<AddSellingProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _unit = TextEditingController();
  final _description = TextEditingController();
  final _components = <_ComponentLine>[];
  String? _categoryUuid;
  bool _saving = false;
  bool _loading = false;
  bool _deleting = false;
  bool _pendingSync = false;

  bool get _isEditing => widget.existingUuid != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }
  }

  Future<void> _load() async {
    final repo = ref.read(sellingProductRepositoryProvider);
    final inv = ref.read(inventoryRepositoryProvider);
    final sp = await repo.get(widget.existingUuid!);
    if (sp == null || !mounted) {
      if (mounted) {
        setState(() => _loading = false);
        Navigator.pop(context);
      }
      return;
    }

    _name.text = sp.name;
    _sku.text = sp.sku ?? '';
    _unit.text = sp.unit ?? '';
    _description.text = sp.description ?? '';
    _categoryUuid = sp.categoryUuid;
    _pendingSync = sp.isNotSynced == true;

    final comps = await repo.getComponents(sp.uuid);
    for (final c in comps) {
      final p = await inv.getProduct(c.productUuid);
      if (p == null) continue;
      final mode = SellingConsumeMode.all.contains(c.consumeMode)
          ? c.consumeMode
          : SellingConsumeMode.auto;
      final batch = c.batchNumber?.trim();
      _components.add(
        _ComponentLine(
          product: p,
          quantity: c.quantity,
          consumeMode: mode,
          batchNumber: mode == SellingConsumeMode.batch ? batch : null,
        ),
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _unit.dispose();
    _description.dispose();
    for (final c in _components) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addComponent() async {
    final result = await showOrderProductPicker(context: context, ref: ref);
    final product = result?.value;
    if (product == null || !mounted) return;
    setState(() => _components.add(_ComponentLine(product: product)));
  }

  Future<void> _pickBatch(_ComponentLine line) async {
    final l10n = AppLocalizations.of(context)!;
    final batches = await ref
        .read(inventoryRepositoryProvider)
        .distinctBatchNumbers(line.product.uuid);
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
                selected: line.batchNumber == b,
                onTap: () => Navigator.pop(context, b),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() {
      line.consumeMode = SellingConsumeMode.batch;
      line.batchNumber = picked;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_name.text.trim().isEmpty) {
      ToastUtils.showErrorToast(context, ref, l10n.fieldRequired);
      return;
    }
    if (_components.isEmpty) {
      ToastUtils.showErrorToast(context, ref, l10n.atLeastOneComponent);
      return;
    }
    for (final c in _components) {
      if (c.consumeMode == SellingConsumeMode.batch &&
          (c.batchNumber == null || c.batchNumber!.trim().isEmpty)) {
        ToastUtils.showErrorToast(context, ref, l10n.selectBatch);
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(sellingProductRepositoryProvider);
      final inputs = _components
          .map(
            (c) => SellingProductComponentInput(
              productUuid: c.product.uuid,
              quantity: double.tryParse(c.qty.text.trim()) ?? 0,
              consumeMode: c.consumeMode,
              batchNumber: c.consumeMode == SellingConsumeMode.batch
                  ? c.batchNumber?.trim()
                  : null,
            ),
          )
          .toList();

      if (_isEditing) {
        await repo.update(
          uuid: widget.existingUuid!,
          name: _name.text.trim(),
          sku: _sku.text.trim(),
          description: _description.text.trim(),
          categoryUuid: _categoryUuid,
          unit: _unit.text.trim(),
          components: inputs,
        );
      } else {
        await repo.create(
          name: _name.text.trim(),
          sku: _sku.text.trim(),
          description: _description.text.trim(),
          categoryUuid: _categoryUuid,
          unit: _unit.text.trim(),
          components: inputs,
        );
      }
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.sellingProductSaved);
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

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDeleteSellingProduct),
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

    setState(() => _deleting = true);
    try {
      await ref
          .read(sellingProductRepositoryProvider)
          .softDelete(widget.existingUuid!);
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.sellingProductDeleted);
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
      if (mounted) setState(() => _deleting = false);
    }
  }

  InputDecoration _fieldDecoration(
    ThemeData theme,
    String label, {
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final categories =
        ref.watch(productCategoriesStreamProvider).value ?? const [];
    final selectedCategory =
        categories.where((c) => c.uuid == _categoryUuid).firstOrNull;
    final categoryColor = selectedCategory == null
        ? AppColors.receivableColor
        : parseCategoryColor(selectedCategory.color, AppColors.receivableColor);
    final accent = AppColors.receivableColor;

    if (_loading) {
      return FormPageScaffold(
        accentColor: accent,
        appBar: AppBar(
          title: Text(
            _isEditing ? l10n.editSellingProduct : l10n.newSellingProduct,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return FormPageScaffold(
      accentColor: accent,
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.editSellingProduct : l10n.newSellingProduct,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: l10n.delete,
              onPressed: _deleting || _saving ? null : _delete,
              icon: _deleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
            ),
        ],
      ),
      bottomBar: FormBottomBar(
        child: GradientButton(
          label: l10n.save,
          icon: Icons.check_rounded,
          isLoading: _saving,
          width: double.infinity,
          gradient: AppColors.getPrimaryGradient(accent),
          onPressed: _saving || _deleting ? null : _save,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _SellingProductHeroHeader(
              accent: categoryColor,
              isEditing: _isEditing,
              showPendingSync: _isEditing && _pendingSync,
              nameHint: _name.text.trim().isEmpty
                  ? l10n.sellingProducts
                  : _name.text.trim(),
              categoryName: selectedCategory?.name,
              categoryIcon: selectedCategory == null
                  ? Symbols.sell
                  : categoryIconData(selectedCategory),
              hintText: l10n.sellingProductHint,
            ),
            FormSectionCard(
              title: l10n.sectionDetails,
              icon: Icons.sell_outlined,
              accentColor: accent,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                  decoration: _fieldDecoration(
                    theme,
                    l10n.name,
                    icon: Icons.badge_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.fieldRequired;
                    }
                    return null;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _sku,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration(
                          theme,
                          l10n.sku,
                          icon: Icons.qr_code_2_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _unit,
                        textInputAction: TextInputAction.next,
                        decoration: _fieldDecoration(
                          theme,
                          l10n.unit,
                          icon: Icons.straighten_outlined,
                        ).copyWith(
                          hintText: _components.isNotEmpty
                              ? _components.first.product.unit
                              : l10n.sellingProductUnitHint,
                        ),
                      ),
                    ),
                  ],
                ),
                EntityPickerField(
                  label: l10n.category,
                  valueText: selectedCategory?.name,
                  placeholderIcon: Symbols.category,
                  accentColor:
                      selectedCategory == null ? null : categoryColor,
                  leading: selectedCategory == null
                      ? null
                      : categoryLeadingAvatar(
                          color: categoryColor,
                          icon: categoryIconData(selectedCategory),
                          radius: 18,
                        ),
                  onClear: selectedCategory == null
                      ? null
                      : () => setState(() => _categoryUuid = null),
                  onTap: () async {
                    final result = await showProductCategoryPicker(
                      context: context,
                      ref: ref,
                      selected: selectedCategory,
                    );
                    if (result == null || !mounted) return;
                    setState(() => _categoryUuid = result.value?.uuid);
                  },
                ),
                TextFormField(
                  controller: _description,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _fieldDecoration(
                    theme,
                    l10n.description,
                    icon: Icons.notes_outlined,
                  ),
                ),
              ],
            ),
            FormSectionCard(
              title: l10n.sectionComponents,
              icon: Icons.layers_outlined,
              accentColor: accent,
              trailing: TextButton.icon(
                onPressed: _addComponent,
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addComponent),
              ),
              children: [
                if (_components.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l10n.atLeastOneComponent,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (var i = 0; i < _components.length; i++) ...[
                    if (i > 0) const Divider(height: 24),
                    _componentCard(_components[i], l10n, theme),
                  ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _componentCard(
    _ComponentLine line,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                line.product.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _components.remove(line);
                line.dispose();
              }),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        TextFormField(
          controller: line.qty,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: _decimalFormatters,
          decoration: InputDecoration(
            labelText: l10n.lotQuantity,
            suffixText: line.product.unit,
            filled: true,
            isDense: true,
          ),
          validator: (v) {
            final n = double.tryParse(v?.trim() ?? '');
            if (n == null || n <= 0) return l10n.pleaseEnterValidNumber;
            return null;
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.consumeModeAuto),
              selected: line.consumeMode == SellingConsumeMode.auto,
              onSelected: (_) => setState(() {
                line.consumeMode = SellingConsumeMode.auto;
                line.batchNumber = null;
              }),
            ),
            ChoiceChip(
              label: Text(
                line.batchNumber == null || line.batchNumber!.isEmpty
                    ? l10n.consumeModeBatch
                    : '${l10n.consumeModeBatch}: ${line.batchNumber}',
              ),
              selected: line.consumeMode == SellingConsumeMode.batch,
              onSelected: (_) => _pickBatch(line),
            ),
          ],
        ),
      ],
    );
  }
}

class _SellingProductHeroHeader extends StatelessWidget {
  final Color accent;
  final bool isEditing;
  final bool showPendingSync;
  final String nameHint;
  final String? categoryName;
  final IconData categoryIcon;
  final String hintText;

  const _SellingProductHeroHeader({
    required this.accent,
    required this.isEditing,
    required this.showPendingSync,
    required this.nameHint,
    required this.categoryName,
    required this.categoryIcon,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final gradient = AppColors.getPrimaryGradient(accent);
    const onGradient = Colors.white;
    final onGradientMuted = Colors.white.withValues(alpha: 0.88);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.48),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  PositionedDirectional(
                    end: -28,
                    top: -32,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    end: 28,
                    bottom: -40,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            color: Colors.white.withValues(alpha: 0.18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                              width: 1.5,
                            ),
                          ),
                          child:
                              Icon(categoryIcon, color: onGradient, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.40),
                                  ),
                                ),
                                child: Text(
                                  isEditing
                                      ? l10n.editSellingProduct
                                      : l10n.newSellingProduct,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: onGradient,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                nameHint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: onGradient,
                                  height: 1.15,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    categoryName == null
                                        ? Icons.info_outline_rounded
                                        : Symbols.category,
                                    size: 15,
                                    color: onGradientMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      categoryName ?? hintText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: onGradientMuted,
                                        height: 1.35,
                                        fontWeight: FontWeight.w500,
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
          ),
          if (showPendingSync)
            const PositionedDirectional(
              top: -6,
              end: -6,
              child: PendingSyncDetailBadge(),
            ),
        ],
      ),
    );
  }
}
