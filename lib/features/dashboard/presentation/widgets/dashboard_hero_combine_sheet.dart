import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook_summary.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/features/dashboard/presentation/providers/dashboard_hero_combine_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';

Future<void> showDashboardHeroCombineSheet(
    BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Consumer(
        builder: (context, ref, _) {
          final activeId = ref.watch(activeCashbookIdProvider);
          final cashbooks = ref.watch(cashbooksProvider);
          final selected =
              ref.watch(dashboardHeroCombinedCashbookIdsProvider);
          final prefs = ref.watch(sharedPreferencesProvider);
          final summaries = CashbookSummaryService.readAllSummariesSync(prefs);

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
                        color: Theme.of(ctx)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    l10n.dashboardHeroCombineTitle,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dashboardHeroCombineSubtitle,
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
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
                        maxHeight: MediaQuery.sizeOf(ctx).height * 0.45,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: others.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = others[index];
                          final on = selected.contains(c.id);
                          final hasSummary = summaries[c.id] != null;
                          return SwitchListTile(
                            value: on,
                            onChanged: (v) {
                              ref
                                  .read(
                                    dashboardHeroCombinedCashbookIdsProvider
                                        .notifier,
                                  )
                                  .toggle(c.id, v);
                            },
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: c.color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(c.icon, color: c.color, size: 22),
                            ),
                            title: Text(c.name),
                            subtitle: !hasSummary && on
                                ? Text(
                                    l10n.dashboardHeroCombineNoSummary,
                                    style: TextStyle(
                                      color: Theme.of(ctx)
                                          .colorScheme
                                          .tertiary,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
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

