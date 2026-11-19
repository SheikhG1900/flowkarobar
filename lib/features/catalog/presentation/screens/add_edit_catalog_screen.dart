import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_pricing.dart';
import 'package:flowpaisa/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flowpaisa/features/catalog/presentation/widgets/catalog_pricing_approach_picker.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/shared/widgets/pending_sync_badge.dart';
import 'package:material_symbols_icons/symbols.dart';

class AddEditCatalogScreen extends ConsumerStatefulWidget {
  final Catalog? existing;

  const AddEditCatalogScreen({super.key, this.existing});

  @override
  ConsumerState<AddEditCatalogScreen> createState() =>
      _AddEditCatalogScreenState();
}

class _AddEditCatalogScreenState extends ConsumerState<AddEditCatalogScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _defaultPercent;
  late final TextEditingController _defaultFixed;
  DateTime? _validUntil;
  late bool _isDefault;
  late String _defaultApproach;
  bool _saving = false;
  bool _deleting = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _validUntil = c?.validUntil;
    _isDefault = c?.isDefault ?? false;
    _defaultApproach = CatalogPricingApproach.all.contains(c?.defaultPricingApproach)
        ? c!.defaultPricingApproach
        : CatalogPricingApproach.markup;
    _defaultPercent = TextEditingController(
      text: (c?.defaultMarkupOrMarginPercent ?? 0).toString(),
    );
    _defaultFixed = TextEditingController(
      text: (c?.defaultFixedAmount ?? 0).toString(),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _defaultPercent.dispose();
    _defaultFixed.dispose();
    super.dispose();
  }

  Future<void> _pickValidUntil() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _validUntil ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null) return;
    setState(() => _validUntil = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final percent = double.tryParse(_defaultPercent.text.trim()) ?? 0;
    final fixed = double.tryParse(_defaultFixed.text.trim()) ?? 0;
    if (CatalogPricingApproach.isMarginBased(_defaultApproach) &&
        percent >= 100) {
      ToastUtils.showErrorToast(context, ref, l10n.pricingFixedThenMarginHint);
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(catalogRepositoryProvider);
      if (_isEditing) {
        await repo.updateCatalog(
          uuid: widget.existing!.uuid,
          name: _name.text.trim(),
          description: _description.text.trim(),
          validUntil: _validUntil,
          isDefault: _isDefault,
          defaultPricingApproach: _defaultApproach,
          defaultMarkupOrMarginPercent: percent,
          defaultFixedAmount: fixed,
        );
      } else {
        await repo.createCatalog(
          name: _name.text.trim(),
          description: _description.text.trim(),
          validUntil: _validUntil,
          isDefault: _isDefault,
          defaultPricingApproach: _defaultApproach,
          defaultMarkupOrMarginPercent: percent,
          defaultFixedAmount: fixed,
        );
      }
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.catalogSaved);
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
        content: Text(l10n.confirmDeleteCatalog),
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
          .read(catalogRepositoryProvider)
          .softDeleteCatalog(widget.existing!.uuid);
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.catalogDeleted);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accent = AppColors.receivableColor;
    final showPending = widget.existing?.isNotSynced == true;

    return FormPageScaffold(
      accentColor: accent,
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editCatalog : l10n.newCatalog),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Stack(
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
                    child: Row(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name.text.trim().isEmpty
                                    ? l10n.catalog
                                    : _name.text.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.catalogHint,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showPending)
                    const PositionedDirectional(
                      top: -6,
                      end: -6,
                      child: PendingSyncDetailBadge(),
                    ),
                ],
              ),
            ),
            FormSectionCard(
              title: l10n.sectionDetails,
              icon: Icons.price_change_outlined,
              accentColor: accent,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                ),
                TextFormField(
                  controller: _description,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    prefixIcon: const Icon(Icons.notes_outlined),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(l10n.catalogValidUntil),
                  subtitle: Text(
                    _validUntil == null
                        ? '—'
                        : AppDateFormatter.formatDate(_validUntil!),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_validUntil != null)
                        IconButton(
                          onPressed: () => setState(() => _validUntil = null),
                          icon: const Icon(Icons.clear),
                        ),
                      IconButton(
                        onPressed: _pickValidUntil,
                        icon: const Icon(Icons.calendar_month_outlined),
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.setAsDefaultCatalog),
                  value: _isDefault,
                  activeThumbColor: accent,
                  onChanged: (v) => setState(() => _isDefault = v),
                ),
              ],
            ),
            FormSectionCard(
              title: l10n.catalogDefaultPricing,
              icon: Icons.calculate_outlined,
              accentColor: accent,
              children: [
                Text(
                  l10n.catalogDefaultPricingHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                CatalogPricingApproachPicker(
                  value: _defaultApproach,
                  accentColor: accent,
                  onChanged: (v) => setState(() => _defaultApproach = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _defaultPercent,
                        keyboardType: const TextInputType.numberWithOptions(
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
                      child: TextFormField(
                        controller: _defaultFixed,
                        keyboardType: const TextInputType.numberWithOptions(
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
          ],
        ),
      ),
    );
  }
}
