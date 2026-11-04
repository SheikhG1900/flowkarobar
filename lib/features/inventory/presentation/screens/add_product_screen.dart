import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_entity_pickers.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/entity_picker_sheet.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:material_symbols_icons/symbols.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final Product? existing;

  const AddProductScreen({super.key, this.existing});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _sku;
  late final TextEditingController _unit;
  late final TextEditingController _purchasePrice;
  late final TextEditingController _retailPrice;
  late final TextEditingController _wholesalePrice;
  late final TextEditingController _openingStock;
  late final TextEditingController _minStockAlert;
  String? _categoryUuid;
  bool _isService = false;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    String number(double? value) =>
        value == null ? '' : AmountFormatter.formatQuantity(value);

    _name = TextEditingController(text: p?.name ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _unit = TextEditingController(text: p?.unit ?? 'Pcs');
    _purchasePrice = TextEditingController(text: number(p?.purchasePrice));
    _retailPrice = TextEditingController(text: number(p?.retailPrice));
    _wholesalePrice = TextEditingController(text: number(p?.wholesalePrice));
    _openingStock = TextEditingController();
    _minStockAlert = TextEditingController(text: number(p?.minStockAlert));
    _categoryUuid = p?.categoryUuid;
    _isService = p?.isService ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _unit.dispose();
    _purchasePrice.dispose();
    _retailPrice.dispose();
    _wholesalePrice.dispose();
    _openingStock.dispose();
    _minStockAlert.dispose();
    super.dispose();
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? 0;

  double? _optionalNumber(TextEditingController controller) =>
      double.tryParse(controller.text.trim());

  String? _optionalText(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final repository = ref.read(inventoryRepositoryProvider);
      final unit = _unit.text.trim().isEmpty ? 'Pcs' : _unit.text.trim();
      final minAlert = _isService ? null : _optionalNumber(_minStockAlert);

      final existing = widget.existing;
      late final Product saved;
      if (existing == null) {
        final uuid = const Uuid().v4();
        final opening = _isService ? 0.0 : _number(_openingStock);
        await repository.createProductWithOpeningStock(
          product: ProductsCompanion.insert(
            uuid: uuid,
            name: _name.text.trim(),
            categoryUuid: drift.Value(_categoryUuid),
            sku: drift.Value(_optionalText(_sku)),
            unit: drift.Value(unit),
            purchasePrice: drift.Value(_number(_purchasePrice)),
            retailPrice: drift.Value(_number(_retailPrice)),
            wholesalePrice: drift.Value(_number(_wholesalePrice)),
            stockQuantity: const drift.Value(0.0),
            minStockAlert: drift.Value(minAlert),
            isService: drift.Value(_isService),
          ),
          openingQuantity: opening,
        );
        saved = (await repository.getProduct(uuid))!;
      } else {
        // Stock is lot-driven; do not overwrite stockQuantity from the form.
        final updated = existing.copyWith(
          name: _name.text.trim(),
          categoryUuid: drift.Value(_categoryUuid),
          sku: drift.Value(_optionalText(_sku)),
          unit: unit,
          purchasePrice: _number(_purchasePrice),
          retailPrice: _number(_retailPrice),
          wholesalePrice: _number(_wholesalePrice),
          minStockAlert: drift.Value(minAlert),
          isService: _isService,
          updatedAt: DateTime.now(),
        );
        await repository.updateProduct(updated);
        saved = updated;
      }

      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.productSaved);
      Navigator.pop(context, saved);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final categories = ref.watch(productCategoriesStreamProvider).value ??
        const <ProductCategory>[];
    final selectedCategory = categories
        .where((c) => c.uuid == _categoryUuid)
        .firstOrNull;
    final accent = AppColors.incomeColor;

    String? requiredText(String? value) =>
        value == null || value.trim().isEmpty ? l10n.fieldRequired : null;

    String? optionalNumber(String? value) {
      if (value == null || value.trim().isEmpty) return null;
      final number = double.tryParse(value.trim());
      return number == null || number < 0 ? l10n.invalidNumber : null;
    }

    InputDecoration fieldDecoration(String label, {IconData? icon}) {
      return InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
        filled: true,
      );
    }

    Widget numberField(
      TextEditingController controller,
      String label, {
      IconData? icon,
    }) {
      return TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: fieldDecoration(label, icon: icon),
        validator: optionalNumber,
      );
    }

    return FormPageScaffold(
      accentColor: accent,
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editProduct : l10n.addProduct),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomBar: FormBottomBar(
        child: GradientButton(
          label: l10n.save,
          icon: Icons.check_rounded,
          isLoading: _saving,
          width: double.infinity,
          gradient: AppColors.getPrimaryGradient(accent),
          onPressed: _saving ? null : _save,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            FormSectionCard(
              title: l10n.sectionDetails,
              icon: Icons.inventory_2_outlined,
              accentColor: accent,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: fieldDecoration(
                    l10n.productName,
                    icon: Icons.badge_outlined,
                  ),
                  validator: requiredText,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sku,
                        decoration: fieldDecoration(l10n.sku),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _unit,
                        decoration: fieldDecoration(l10n.unit),
                      ),
                    ),
                  ],
                ),
                EntityPickerField(
                  label: l10n.category,
                  valueText: selectedCategory?.name,
                  placeholderIcon: Symbols.category,
                  accentColor: selectedCategory == null
                      ? null
                      : parseCategoryColor(selectedCategory.color),
                  leading: selectedCategory == null
                      ? null
                      : categoryLeadingAvatar(
                          color: parseCategoryColor(selectedCategory.color),
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
                Material(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  child: CheckboxListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(l10n.isServiceProduct),
                    value: _isService,
                    onChanged: (value) =>
                        setState(() => _isService = value ?? false),
                  ),
                ),
              ],
            ),
            FormSectionCard(
              title: l10n.sectionPricing,
              icon: Icons.sell_outlined,
              accentColor: AppColors.payableColor,
              children: [
                numberField(
                  _purchasePrice,
                  l10n.purchasePrice,
                  icon: Icons.shopping_cart_outlined,
                ),
                numberField(
                  _retailPrice,
                  l10n.retailPrice,
                  icon: Icons.sell_outlined,
                ),
                numberField(
                  _wholesalePrice,
                  l10n.wholesalePrice,
                  icon: Icons.warehouse_outlined,
                ),
              ],
            ),
            if (!_isService)
              FormSectionCard(
                title: l10n.sectionStock,
                icon: Icons.inventory_outlined,
                accentColor: AppColors.expenseColor,
                children: [
                  if (_isEditing) ...[
                    InputDecorator(
                      decoration: fieldDecoration(
                        l10n.currentStock,
                        icon: Icons.inventory_outlined,
                      ),
                      child: Text(
                        AmountFormatter.formatQuantity(
                          widget.existing!.stockQuantity,
                        ),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      l10n.currentStockHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ] else
                    numberField(
                      _openingStock,
                      l10n.openingStock,
                      icon: Icons.inventory_outlined,
                    ),
                  numberField(
                    _minStockAlert,
                    l10n.minStockAlert,
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
