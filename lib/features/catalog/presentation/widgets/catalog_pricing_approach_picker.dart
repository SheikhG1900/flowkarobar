import 'package:flutter/material.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_pricing.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

typedef _PricingOption = ({
  String id,
  String title,
  String scenario,
  String formula,
});

List<_PricingOption> _pricingOptions(AppLocalizations l10n) => [
      (
        id: CatalogPricingApproach.markup,
        title: l10n.pricingMarkupThenFixed,
        scenario: l10n.pricingMarkupThenFixedScenario,
        formula: l10n.pricingMarkupThenFixedHint,
      ),
      (
        id: CatalogPricingApproach.markupOnBase,
        title: l10n.pricingFixedThenMarkup,
        scenario: l10n.pricingFixedThenMarkupScenario,
        formula: l10n.pricingFixedThenMarkupHint,
      ),
      (
        id: CatalogPricingApproach.margin,
        title: l10n.pricingFixedThenMargin,
        scenario: l10n.pricingFixedThenMarginScenario,
        formula: l10n.pricingFixedThenMarginHint,
      ),
      (
        id: CatalogPricingApproach.marginThenFixed,
        title: l10n.pricingMarginThenFixed,
        scenario: l10n.pricingMarginThenFixedScenario,
        formula: l10n.pricingMarginThenFixedHint,
      ),
    ];

_PricingOption _optionFor(AppLocalizations l10n, String approach) {
  final options = _pricingOptions(l10n);
  return options.firstWhere(
    (o) => o.id == approach,
    orElse: () => options.first,
  );
}

/// Shows the selected approach; tap opens a bottom drawer to choose among four.
class CatalogPricingApproachPicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final Color? accentColor;

  const CatalogPricingApproachPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.accentColor,
  });

  Future<void> _openSheet(BuildContext context) async {
    final accent = accentColor ?? AppColors.receivableColor;
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _PricingApproachSheet(
        selected: value,
        accent: accent,
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accent = accentColor ?? AppColors.receivableColor;
    final selected = _optionFor(l10n, value);

    return Material(
      color: accent.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openSheet(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.calculate_outlined, color: accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pricingApproach,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selected.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selected.scenario,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selected.formula,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PricingApproachSheet extends StatelessWidget {
  final String selected;
  final Color accent;

  const _PricingApproachSheet({
    required this.selected,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final options = _pricingOptions(l10n);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.pricingApproach,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            for (final opt in options)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: selected == opt.id
                      ? accent.withValues(alpha: 0.10)
                      : theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.pop(context, opt.id),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            selected == opt.id
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 22,
                            color: selected == opt.id
                                ? accent
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: selected == opt.id ? accent : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  opt.scenario,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  opt.formula,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Short label for list / summary rows.
String catalogPricingApproachLabel(AppLocalizations l10n, String approach) {
  return _optionFor(l10n, approach).title;
}
