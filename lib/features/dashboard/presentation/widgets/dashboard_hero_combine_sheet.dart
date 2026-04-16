import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook_summary.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
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
          final activeId = ref.watch(activeCashbookIdProvider);
          final cashbooks = ref.watch(cashbooksProvider);
          final selected =
              ref.watch(dashboardHeroCombinedCashbookIdsProvider);
          final prefs = ref.watch(sharedPreferencesProvider);
          final summaries = CashbookSummaryService.readAllSummariesSync(prefs);
          final symbol = ref.watch(currencySymbolProvider);
          final decimals = ref.watch(currencyDecimalPlacesProvider);

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
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: _BalanceMetricColumn(
                                                  label: l10n.availableCash,
                                                  value: summary != null
                                                      ? AmountFormatter
                                                          .formatWithCurrency(
                                                          summary
                                                              .availableCash,
                                                          symbol,
                                                          decimals,
                                                        )
                                                      : '—',
                                                  theme: theme,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _BalanceMetricColumn(
                                                  label: l10n.netWorth,
                                                  value: summary != null
                                                      ? AmountFormatter
                                                          .formatWithCurrency(
                                                          summary.netWorth,
                                                          symbol,
                                                          decimals,
                                                        )
                                                      : '—',
                                                  theme: theme,
                                                ),
                                              ),
                                            ],
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
