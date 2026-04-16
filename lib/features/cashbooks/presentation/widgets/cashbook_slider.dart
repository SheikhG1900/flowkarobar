import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/features/cashbooks/domain/models/cashbook_summary.dart';
import 'package:flowpaisa/features/cashbooks/presentation/providers/cashbook_provider.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:material_symbols_icons/symbols.dart';

class CashbookSlider extends ConsumerStatefulWidget {
  const CashbookSlider({super.key});

  @override
  ConsumerState<CashbookSlider> createState() => _CashbookSliderState();
}

class _CashbookSliderState extends ConsumerState<CashbookSlider> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Auto-refresh if no summaries exist yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndAutoRefresh();
    });
  }

  Future<void> _checkAndAutoRefresh() async {
    // Auto-refresh disabled to avoid db path mess.
    // Summaries update only on switch.
  }

  Future<void> _refreshAll() async {
    // Manual refresh disabled to avoid db path mess.
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final activeId = ref.watch(activeCashbookIdProvider);
    final cashbooks = ref.watch(cashbooksProvider);
    final l10n = AppLocalizations.of(context)!;

    final otherCashbooksCount = cashbooks.where((c) => c.id != activeId).length;
    if (otherCashbooksCount == 0) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: FutureBuilder<List<CashbookSummary>>(
        future: CashbookSummaryService.getOtherSummaries(prefs, activeId),
        builder: (context, snapshot) {
          final raw = snapshot.data ?? [];
          // Only summaries for cashbooks that still exist (and are not active).
          // Prefs can keep stale rows after a cashbook is deleted.
          final otherIds =
              cashbooks.where((c) => c.id != activeId).map((c) => c.id).toSet();
          final summaries = raw.where((s) => otherIds.contains(s.uuid)).toList()
            ..sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

          if (summaries.isEmpty) {
            return const SizedBox.shrink();
          }

          final expandSingle = summaries.length == 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: RepaintBoundary(
                  child: expandSingle
                      ? Padding(
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, top: 0, bottom: 15),
                          child: _CashbookSummaryCard(
                            summary: summaries.single,
                            expandHorizontally: true,
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 15),
                          itemCount: summaries.length,
                          itemBuilder: (context, index) {
                            return _CashbookSummaryCard(
                              summary: summaries[index],
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CashbookSummaryCard extends ConsumerWidget {
  final CashbookSummary summary;

  /// Single card in slider: grow to full row width (parent must be width-bounded).
  final bool expandHorizontally;

  const _CashbookSummaryCard({
    required this.summary,
    this.expandHorizontally = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final summaryCurrencyAsync =
        ref.watch(cashbookSummaryCurrencyProvider(summary.currencyUuid));
    final fallbackSym = ref.watch(currencySymbolProvider);
    final fallbackDec = ref.watch(currencyDecimalPlacesProvider);
    final rowCurrency = summaryCurrencyAsync.when<AppCurrency?>(
      data: (c) => c,
      loading: () => null,
      error: (_, __) => null,
    );
    final symbol = rowCurrency?.symbol ?? fallbackSym;
    final decimals = rowCurrency?.decimalPlaces ?? fallbackDec;
    final cashbooks = ref.watch(cashbooksProvider);

    final cashbook = cashbooks.firstWhereOrNull((c) => c.id == summary.uuid);
    if (cashbook == null) return const SizedBox.shrink();

    final cashbookColor = cashbook.color;
    final iconData = cashbook.icon;
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = ref.watch(premiumProvider).isPremium;
    final isLocked = !isPremium &&
        cashbook.id != 'default' &&
        (cashbook.addSeq ?? 0) >= PremiumGate.cashbookTotalLimit;

    return Container(
      width: expandHorizontally ? double.infinity : 280,
      margin: EdgeInsets.symmetric(horizontal: expandHorizontally ? 0 : 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked
              ? () => PremiumGate.showPremiumDialog(context)
              : () async {
                  // 1. Calculate summary for CURRENT cashbook before switching
                  try {
                    final currentDb = ref.read(databaseProvider);
                    final currentCashbook = ref.read(activeCashbookProvider);
                    final prefs = ref.read(sharedPreferencesProvider);

                    // Ensure database is initialized
                    await currentDb.customSelect('SELECT 1').getSingle();

                    await CashbookSummaryService.calculateAndUpdate(
                        prefs, currentDb, currentCashbook);
                  } catch (e) {
                    if (kDebugMode) {
                      print('Error updating summary before switch: $e');
                    }
                  }

                  // 2. Perform the switch
                  ref
                      .read(activeCashbookIdProvider.notifier)
                      .setActive(summary.uuid);
                },
          borderRadius: BorderRadius.circular(20),
          child: Opacity(
            opacity: isLocked ? 0.6 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cashbookColor.withValues(alpha: 0.8),
                    cashbookColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: cashbookColor.withValues(alpha: isDark ? 0.3 : 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative background icon (end = trailing side; mirrors in RTL)
                  PositionedDirectional(
                    end: -20,
                    bottom: -20,
                    child: Icon(
                      iconData,
                      size: 130,
                      color: Colors.white.withValues(alpha: 0.13),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isLocked ? Icons.lock : iconData,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cashbook.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.availableCash,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      AmountFormatter.formatWithCurrency(
                                        summary.availableCash,
                                        symbol,
                                        decimals,
                                      ),
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.netWorth,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      AmountFormatter.formatWithCurrency(
                                        summary.netWorth,
                                        symbol,
                                        decimals,
                                      ),
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }
}
