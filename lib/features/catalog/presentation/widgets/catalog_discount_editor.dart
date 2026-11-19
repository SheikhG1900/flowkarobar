import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/catalog/data/catalog_repository.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_discounts.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class CatalogDiscountTierDraft {
  final String? uuid;
  final TextEditingController minQty;
  final TextEditingController value;
  String type;

  CatalogDiscountTierDraft({
    this.uuid,
    double minQuantity = 10,
    String discountType = CatalogDiscountType.percent,
    double discountValue = 0,
  })  : minQty = TextEditingController(
          text: minQuantity == 0 ? '' : minQuantity.toString(),
        ),
        value = TextEditingController(
          text: discountValue == 0 ? '' : discountValue.toString(),
        ),
        type = discountType;

  void dispose() {
    minQty.dispose();
    value.dispose();
  }

  CatalogDiscountTierInput? toInputOrNull() {
    final minQ = double.tryParse(minQty.text.trim()) ?? 0;
    final v = double.tryParse(value.text.trim()) ?? 0;
    if (minQ <= 0 && v <= 0) return null;
    return CatalogDiscountTierInput(
      uuid: uuid,
      minQuantity: minQ,
      discountType: type,
      discountValue: v,
    );
  }
}

/// Editable default discount + qty tiers (copied onto items at add/save).
class CatalogDiscountEditor extends StatelessWidget {
  final Color accent;
  final bool enabledDefault;
  final String defaultType;
  final TextEditingController defaultValue;
  final ValueChanged<bool> onEnabledDefaultChanged;
  final ValueChanged<String> onDefaultTypeChanged;
  final List<CatalogDiscountTierDraft> tiers;
  final VoidCallback onAddTier;
  final ValueChanged<int> onRemoveTier;
  final ValueChanged<int> onTierTypeChanged;

  const CatalogDiscountEditor({
    super.key,
    required this.accent,
    required this.enabledDefault,
    required this.defaultType,
    required this.defaultValue,
    required this.onEnabledDefaultChanged,
    required this.onDefaultTypeChanged,
    required this.tiers,
    required this.onAddTier,
    required this.onRemoveTier,
    required this.onTierTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.catalogDiscountHint,
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.defaultDiscount),
          subtitle: Text(l10n.defaultDiscountHint),
          value: enabledDefault,
          activeThumbColor: accent,
          onChanged: onEnabledDefaultChanged,
        ),
        if (enabledDefault) ...[
          Row(
            children: [
              _DiscountTypeToggle(
                value: defaultType,
                accent: accent,
                percentTooltip: l10n.discountTypePercent,
                fixedTooltip: l10n.discountTypeFixed,
                onChanged: onDefaultTypeChanged,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: defaultValue,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: defaultType == CatalogDiscountType.fixed
                        ? l10n.discountAmount
                        : l10n.discountPercent,
                    filled: true,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.tieredDiscounts,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onAddTier,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addDiscountTier),
            ),
          ],
        ),
        if (tiers.isEmpty)
          Text(
            l10n.noDiscountTiers,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          )
        else
          for (var i = 0; i < tiers.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            _TierRow(
              context: context,
              l10n: l10n,
              accent: accent,
              draft: tiers[i],
              onTypeChanged: () => onTierTypeChanged(i),
              onRemove: () => onRemoveTier(i),
            ),
          ],
      ],
    );
  }

  Widget _TierRow({
    required BuildContext context,
    required AppLocalizations l10n,
    required Color accent,
    required CatalogDiscountTierDraft draft,
    required VoidCallback onTypeChanged,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: draft.minQty,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: l10n.minQuantity,
                filled: true,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 6),
          _DiscountTypeToggle(
            value: draft.type,
            accent: accent,
            percentTooltip: l10n.discountTypePercent,
            fixedTooltip: l10n.discountTypeFixed,
            onChanged: (v) {
              draft.type = v;
              onTypeChanged();
            },
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: TextField(
              controller: draft.value,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: draft.type == CatalogDiscountType.fixed
                    ? l10n.discountAmount
                    : l10n.discountPercent,
                filled: true,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.delete,
            onPressed: onRemove,
            iconSize: 20,
            padding: const EdgeInsets.all(6),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Icon(Icons.close, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

/// Compact % / fixed-amount toggle (icons only — currency symbol may be empty).
/// On narrow screens shows only the selected type; tap cycles to the other.
class _DiscountTypeToggle extends StatelessWidget {
  final String value;
  final Color accent;
  final String percentTooltip;
  final String fixedTooltip;
  final ValueChanged<String> onChanged;

  static const double _narrowBreakpoint = 520;

  const _DiscountTypeToggle({
    required this.value,
    required this.accent,
    required this.percentTooltip,
    required this.fixedTooltip,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPercent = value == CatalogDiscountType.percent;
    final compact =
        MediaQuery.sizeOf(context).width < _narrowBreakpoint;

    Widget chip({
      required bool selected,
      required IconData icon,
      required String tooltip,
      required VoidCallback onTap,
    }) {
      return Tooltip(
        message: tooltip,
        child: Material(
          color: selected
              ? accent.withValues(alpha: 0.16)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                icon,
                size: 20,
                color: selected ? accent : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    final children = compact
        ? [
            chip(
              selected: true,
              icon: isPercent
                  ? Icons.percent_rounded
                  : Icons.payments_outlined,
              tooltip: isPercent
                  ? '$percentTooltip → $fixedTooltip'
                  : '$fixedTooltip → $percentTooltip',
              onTap: () => onChanged(
                isPercent
                    ? CatalogDiscountType.fixed
                    : CatalogDiscountType.percent,
              ),
            ),
          ]
        : [
            chip(
              selected: isPercent,
              icon: Icons.percent_rounded,
              tooltip: percentTooltip,
              onTap: () => onChanged(CatalogDiscountType.percent),
            ),
            chip(
              selected: !isPercent,
              icon: Icons.payments_outlined,
              tooltip: fixedTooltip,
              onTap: () => onChanged(CatalogDiscountType.fixed),
            ),
          ];

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

String formatCatalogDiscountLabel({
  required String type,
  required double value,
  required String Function(double) formatAmount,
}) {
  if (value <= 0) return '';
  if (type == CatalogDiscountType.fixed) {
    return '-${formatAmount(value)}';
  }
  final trimmed = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  return '-$trimmed%';
}
