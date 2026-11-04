import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/businesses/domain/models/business_summary.dart';
import 'package:flowpaisa/features/businesses/presentation/providers/business_provider.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_hero_combine_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';

Future<void> showDashboardHeroCombineSheet(
    BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Consumer(
        builder: (context, ref, _) {
          final l10n = AppLocalizations.of(context)!;
          final theme = Theme.of(ctx);
          final activeId = ref.watch(activeBusinessIdProvider);
          final cashbooks = ref.watch(businessesProvider);
          final selected =
              ref.watch(dashboardHeroCombinedCashbookIdsProvider);
          final prefs = ref.watch(sharedPreferencesProvider);
          final summaries = BusinessSummaryService.readAllSummariesSync(prefs);

          final others =
              cashbooks.where((c) => c.id != activeId).toList()
                ..sort((a, b) => a.name.compareTo(b.name));

          final bottomInset = MediaQuery.paddingOf(ctx).bottom;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: bottomInset + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    l10n.dashboardHeroCombineTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dashboardHeroCombineSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (others.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        l10n.dashboardHeroCombineNoOthers,
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(ctx).height * 0.5,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: others.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final c = others[index];
                          final on = selected.contains(c.id);
                          final summary = summaries[c.id];

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                ref
                                    .read(
                                      dashboardHeroCombinedCashbookIdsProvider
                                          .notifier,
                                    )
                                    .toggle(c.id, !on);
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: on ? 2 : 1,
                                    color: on
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outlineVariant,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  color: on
                                      ? theme.colorScheme.primary
                                          .withValues(alpha: 0.08)
                                      : theme.colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.35),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: c.color
                                            .withValues(alpha: 0.2),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        c.icon,
                                        color: c.color,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.name,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          _CombineCashbookBalances(
                                            summary: summary,
                                            l10n: l10n,
                                            theme: theme,
                                          ),
                                          if (summary == null) ...[
                                            const SizedBox(height: 6),
                                            Text(
                                              l10n.dashboardHeroCombineNoSummary,
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                color: theme
                                                    .colorScheme.tertiary,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        on
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: on
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.outline,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _CombineCashbookBalances extends ConsumerWidget {
  const _CombineCashbookBalances({
    required this.summary,
    required this.l10n,
    required this.theme,
  });

  final BusinessSummary? summary;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sm = summary;
    if (sm == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _BalanceMetricColumn(
              label: l10n.availableCash,
              value: '—',
              theme: theme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BalanceMetricColumn(
              label: l10n.netWorth,
              value: '—',
              theme: theme,
            ),
          ),
        ],
      );
    }

    final asyncCurrency =
        ref.watch(cashbookSummaryCurrencyProvider(sm.currencyUuid));
    final fallbackSym = ref.watch(currencySymbolProvider);
    final fallbackDec = ref.watch(currencyDecimalPlacesProvider);

    return asyncCurrency.when(
      data: (AppCurrency currency) => _metricsRow(
        sm,
        currency.symbol,
        currency.decimalPlaces,
      ),
      loading: () => _metricsRow(sm, fallbackSym, fallbackDec),
      error: (_, __) => _metricsRow(sm, fallbackSym, fallbackDec),
    );
  }

  Widget _metricsRow(BusinessSummary s, String symbol, int decimals) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _BalanceMetricColumn(
            label: l10n.availableCash,
            value: AmountFormatter.formatWithCurrency(
              s.availableCash,
              symbol,
              decimals,
            ),
            theme: theme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BalanceMetricColumn(
            label: l10n.netWorth,
            value: AmountFormatter.formatWithCurrency(
              s.netWorth,
              symbol,
              decimals,
            ),
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _BalanceMetricColumn extends StatelessWidget {
  const _BalanceMetricColumn({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
