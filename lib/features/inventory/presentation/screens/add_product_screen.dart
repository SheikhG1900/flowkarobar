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
import 'package:flowpaisa/features/inventory/presentation/screens/scan_sku_screen.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_entity_pickers.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/entity_picker_sheet.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Introduces / updates a product master record only.
/// Stock lives on lots / POs; sell prices will live on catalogs later.
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
  late final TextEditingController _minStockAlert;
  String? _categoryUuid;
  bool _isService = false;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _name = TextEditingController(text: p?.name ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _unit = TextEditingController(text: p?.unit ?? 'Pcs');
    _minStockAlert = TextEditingController(
      text: p?.minStockAlert == null
          ? ''
          : AmountFormatter.formatQuantity(p!.minStockAlert!),
    );
    _categoryUuid = p?.categoryUuid;
    _isService = p?.isService ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _unit.dispose();
    _minStockAlert.dispose();
    super.dispose();
  }

  double? _optionalNumber(TextEditingController controller) =>
      double.tryParse(controller.text.trim());

  String? _optionalText(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _scanSku() async {
    final l10n = AppLocalizations.of(context)!;
    if (!isSkuScannerSupported) {
      ToastUtils.showErrorToast(context, ref, l10n.scanSkuUnavailable);
      return;
    }

    final scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanSkuScreen()),
    );
    if (!mounted || scanned == null || scanned.isEmpty) return;

    final current = _sku.text.trim();
    if (current.isNotEmpty && current != scanned) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.scanSkuTitle),
          content: Text(l10n.scanSkuReplaceConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.save),
            ),
          ],
        ),
      );
      if (replace != true || !mounted) return;
    }

    setState(() => _sku.text = scanned);
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
        await repository.createProduct(
          ProductsCompanion.insert(
            uuid: uuid,
            name: _name.text.trim(),
            categoryUuid: drift.Value(_categoryUuid),
            sku: drift.Value(_optionalText(_sku)),
            unit: drift.Value(unit),
            stockQuantity: const drift.Value(0.0),
            minStockAlert: drift.Value(minAlert),
            isService: drift.Value(_isService),
          ),
        );
        saved = (await repository.getProduct(uuid))!;
      } else {
        final updated = existing.copyWith(
          name: _name.text.trim(),
          categoryUuid: drift.Value(_categoryUuid),
          sku: drift.Value(_optionalText(_sku)),
          unit: unit,
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
    final selectedCategory =
        categories.where((c) => c.uuid == _categoryUuid).firstOrNull;
    final accent = AppColors.incomeColor;
    final categoryColor = selectedCategory == null
        ? accent
        : parseCategoryColor(selectedCategory.color);

    String? requiredText(String? value) =>
        value == null || value.trim().isEmpty ? l10n.fieldRequired : null;

    String? optionalNumber(String? value) {
      if (value == null || value.trim().isEmpty) return null;
      final number = double.tryParse(value.trim());
      return number == null || number < 0 ? l10n.invalidNumber : null;
    }

    InputDecoration fieldDecoration(
      String label, {
      IconData? icon,
      String? helper,
    }) {
      return InputDecoration(
        labelText: label,
        helperText: helper,
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _ProductHeroHeader(
              accent: categoryColor,
              isEditing: _isEditing,
              isService: _isService,
              nameHint: _name.text.trim().isEmpty
                  ? l10n.product
                  : _name.text.trim(),
              categoryName: selectedCategory?.name,
              categoryIcon: selectedCategory == null
                  ? Symbols.inventory_2
                  : categoryIconData(selectedCategory),
            ),
            FormSectionCard(
              title: l10n.sectionDetails,
              icon: Icons.inventory_2_outlined,
              accentColor: accent,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
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
                      flex: 3,
                      child: TextFormField(
                        controller: _sku,
                        textInputAction: TextInputAction.next,
                        decoration: fieldDecoration(
                          l10n.sku,
                          icon: Icons.qr_code_2_outlined,
                        ).copyWith(
                          suffixIcon: IconButton(
                            tooltip: l10n.scanSkuTooltip,
                            onPressed: _scanSku,
                            icon: Icon(
                              Icons.qr_code_scanner_rounded,
                              color: isSkuScannerSupported
                                  ? accent
                                  : theme.disabledColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _unit,
                        textInputAction: TextInputAction.next,
                        decoration: fieldDecoration(
                          l10n.unit,
                          icon: Icons.straighten_outlined,
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
                _ServiceToggleCard(
                  value: _isService,
                  label: l10n.isServiceProduct,
                  accent: accent,
                  onChanged: (value) =>
                      setState(() => _isService = value ?? false),
                ),
              ],
            ),
            if (!_isService)
              FormSectionCard(
                title: l10n.sectionStock,
                icon: Icons.notifications_active_outlined,
                accentColor: AppColors.expenseColor,
                children: [
                  TextFormField(
                    controller: _minStockAlert,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: fieldDecoration(
                      l10n.minStockAlert,
                      icon: Icons.warning_amber_rounded,
                      helper: l10n.productStockManagedElsewhere,
                    ),
                    validator: optionalNumber,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ProductHeroHeader extends StatelessWidget {
  final Color accent;
  final bool isEditing;
  final bool isService;
  final String nameHint;
  final String? categoryName;
  final IconData categoryIcon;

  const _ProductHeroHeader({
    required this.accent,
    required this.isEditing,
    required this.isService,
    required this.nameHint,
    required this.categoryName,
    required this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final gradient = AppColors.getPrimaryGradient(accent);
    const onGradient = Colors.white;
    final onGradientMuted = Colors.white.withValues(alpha: 0.88);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                  _HeroCategoryIcon(
                    categoryIcon: categoryIcon,
                    accent: accent,
                    onGradient: onGradient,
                    isService: isService,
                    serviceTooltip: l10n.serviceProduct,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeaderChip(
                          label:
                              isEditing ? l10n.editProduct : l10n.addProduct,
                          foreground: onGradient,
                          background: Colors.white.withValues(alpha: 0.20),
                          borderColor: Colors.white.withValues(alpha: 0.40),
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
                                categoryName ?? l10n.productMasterHint,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
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
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;
  final Color? borderColor;

  const _HeaderChip({
    required this.label,
    required this.foreground,
    required this.background,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? foreground.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

class _HeroCategoryIcon extends StatelessWidget {
  final IconData categoryIcon;
  final Color accent;
  final Color onGradient;
  final bool isService;
  final String serviceTooltip;

  const _HeroCategoryIcon({
    required this.categoryIcon,
    required this.accent,
    required this.onGradient,
    required this.isService,
    required this.serviceTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final iconBox = Container(
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
      child: Icon(categoryIcon, color: onGradient, size: 30),
    );

    if (!isService) return iconBox;

    return Tooltip(
      message: serviceTooltip,
      child: SizedBox(
        width: 68,
        height: 68,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            iconBox,
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.35),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
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

class _ServiceToggleCard extends StatelessWidget {
  final bool value;
  final String label;
  final Color accent;
  final ValueChanged<bool?> onChanged;

  const _ServiceToggleCard({
    required this.value,
    required this.label,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: value
          ? accent.withValues(alpha: 0.10)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        controlAffinity: ListTileControlAffinity.leading,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
