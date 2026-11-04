import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/features/businesses/domain/models/business_summary.dart';
import 'package:flowpaisa/features/businesses/presentation/providers/business_provider.dart';
import 'package:flowpaisa/shared/providers/shared_preferences_provider.dart';
import 'package:flowpaisa/shared/providers/database_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_provider.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

class BusinessSlider extends ConsumerStatefulWidget {
  const BusinessSlider({super.key});

  @override
  ConsumerState<BusinessSlider> createState() => _BusinessSliderState();
}

class _BusinessSliderState extends ConsumerState<BusinessSlider> {
  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final activeId = ref.watch(activeBusinessIdProvider);
    final businesses = ref.watch(businessesProvider);

    final otherBusinessesCount = businesses.where((c) => c.id != activeId).length;
    if (otherBusinessesCount == 0) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: FutureBuilder<List<BusinessSummary>>(
        future: BusinessSummaryService.getOtherSummaries(prefs, activeId),
        builder: (context, snapshot) {
          final raw = snapshot.data ?? [];
          // Only summaries for businesses that still exist (and are not active).
          // Prefs can keep stale rows after a business is deleted.
          final otherIds =
              businesses.where((c) => c.id != activeId).map((c) => c.id).toSet();
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
                height: 208, // Increased height to accommodate bottom padding for shadows
                width: double.infinity,
                child: expandSingle
                    ? Padding(
                        padding: const EdgeInsets.only(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                        ),
                        child: _BusinessSummaryCard(
                          summary: summaries.single,
                          expandHorizontally: true,
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.only(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 12, // Extra bottom padding so shadows don't get cropped
                        ),
                        itemCount: summaries.length,
                        itemBuilder: (context, index) {
                          return _BusinessSummaryCard(
                            summary: summaries[index],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BusinessSummaryCard extends ConsumerWidget {
  final BusinessSummary summary;

  /// Single card in slider: grow to full row width (parent must be width-bounded).
  final bool expandHorizontally;

  const _BusinessSummaryCard({
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
    final businesses = ref.watch(businessesProvider);

    final business = businesses.firstWhereOrNull((c) => c.id == summary.uuid);
    if (business == null) return const SizedBox.shrink();

    final businessColor = business.color;
    final iconData = business.icon;
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = ref.watch(premiumProvider).isPremium;
    final isLocked = !isPremium &&
        business.id != 'default' &&
        (business.addSeq ?? 0) >= PremiumGate.cashbookTotalLimit;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: expandHorizontally ? 0 : 6,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: businessColor.withValues(alpha: isDark ? 0.3 : 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: expandHorizontally ? double.infinity : 280,
          height: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLocked
                  ? () => PremiumGate.showPremiumDialog(context)
                  : () async {
                      // 1. Calculate summary for CURRENT business before switching
                      try {
                        final currentDb = ref.read(databaseProvider);
                        final currentBusiness =
                            ref.read(activeBusinessProvider);
                        final prefs = ref.read(sharedPreferencesProvider);

                        // Ensure database is initialized
                        await currentDb.customSelect('SELECT 1').getSingle();

                        await BusinessSummaryService.calculateAndUpdate(
                            prefs, currentDb, currentBusiness);
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error updating active business summary before switch: $e');
                        }
                      }

                      // 2. Set active business ID (switches Riverpod databaseProvider)
                      await ref
                          .read(activeBusinessIdProvider.notifier)
                          .setActive(business.id);

                      if (context.mounted) {
                        ToastUtils.showSuccessToast(
                          context,
                          ref,
                          l10n.switchedToCashbook(business.name),
                        );
                      }
                    },
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            theme.cardColor,
                            Color.lerp(theme.cardColor, businessColor, 0.08) ??
                                theme.cardColor
                          ]
                        : [
                            Colors.white,
                            Color.lerp(Colors.white, businessColor, 0.05) ??
                                Colors.white
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative large icon background (subtle)
                    Positioned(
                      right: -16,
                      bottom: -16,
                      child: Icon(
                        iconData,
                        size: 110,
                        color: businessColor.withValues(alpha: isDark ? 0.05 : 0.06),
                      ),
                    ),
                    if (isLocked)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock,
                                  size: 12, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                l10n.upgrade,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: businessColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  iconData,
                                  color: businessColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      business.name,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      l10n.switchCashbook,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
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
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
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
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: summary.availableCash >= 0
                                              ? AppColors.incomeColor
                                              : AppColors.expenseColor,
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
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
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
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: summary.netWorth >= 0
                                              ? theme.colorScheme.onSurface
                                              : AppColors.expenseColor,
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
      ),
    );
  }
}
