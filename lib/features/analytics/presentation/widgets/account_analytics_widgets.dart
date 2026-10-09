import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/icon_helper.dart';
import 'package:flowpaisa/features/accounts/domain/models/account_models.dart';
import 'package:flowpaisa/features/accounts/data/accounts_repository.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:flowpaisa/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contact_details_screen.dart';
import 'package:flowpaisa/features/transactions/domain/models.dart';
import 'package:flowpaisa/features/transactions/presentation/providers/transactions_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper
// ─────────────────────────────────────────────────────────────────────────────

Color _accountColor(AccountWithBalance awb, ThemeData theme) =>
    awb.account.color != null
        ? Color(int.parse(awb.account.color!.replaceAll('#', '0xFF')))
        : theme.colorScheme.primary;

IconData _accountIcon(AccountWithBalance awb) {
  final icon = IconHelper.getIconData(awb.account.icon);
  if (icon != null) return icon;
  switch (awb.type) {
    case AccountType.cash:
      return Symbols.payments;
    case AccountType.bank:
      return Symbols.account_balance;
    case AccountType.savings:
      return Symbols.savings;
    case AccountType.creditCard:
      return Symbols.credit_card;
  }
}

Widget _emptyState(BuildContext context, IconData icon, String message) {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.disabledColor),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(color: theme.disabledColor),
              textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Net Worth Card
// ─────────────────────────────────────────────────────────────────────────────

class AccountNetWorthCard extends ConsumerWidget {
  const AccountNetWorthCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsWithBalanceProvider);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final symbol = currency.symbol;
    final decimals = currency.decimalPlaces;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return accountsAsync.when(
      data: (accounts) {
        if (accounts.isEmpty) {
          return _emptyState(
              context, Symbols.account_balance_wallet, l10n.noAccountActivity);
        }

        double totalAssets = 0;
        double totalLiabilities = 0;
        for (final awb in accounts) {
          if (awb.type.isCreditCard) {
            if (awb.balance < 0) totalLiabilities += awb.balance.abs();
          } else {
            if (awb.balance > 0) {
              totalAssets += awb.balance;
            } else {
              totalLiabilities += awb.balance.abs();
            }
          }
        }
        final netWorth = totalAssets - totalLiabilities;
        final total = totalAssets + totalLiabilities;
        final assetFlex = total > 0
            ? (totalAssets / total * 1000).round().clamp(20, 980)
            : 500;
        final liabFlex = 1000 - assetFlex;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Net Worth headline
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.getPrimaryGradient(
                  netWorth >= 0
                      ? AppColors.incomeColor
                      : AppColors.expenseColor,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.netWorth,
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white70, letterSpacing: 0.8)),
                  const SizedBox(height: 6),
                  Text(
                    AmountFormatter.formatWithCurrency(
                        netWorth, currency),
                    style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Assets vs Liabilities row
            Row(
              children: [
                Expanded(
                  child: _NetWorthTile(
                    label: l10n.totalAssets,
                    amount: totalAssets,
                    currency: currency,
                    color: AppColors.incomeColor,
                    icon: Symbols.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NetWorthTile(
                    label: l10n.totalLiabilities,
                    amount: totalLiabilities,
                    currency: currency,
                    color: AppColors.expenseColor,
                    icon: Symbols.trending_down,
                  ),
                ),
              ],
            ),

            if (total > 0) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 8,
                  child: Row(
                    children: [
                      Expanded(
                        flex: assetFlex,
                        child: Container(color: AppColors.incomeColor),
                      ),
                      Expanded(
                        flex: liabFlex,
                        child: Container(color: AppColors.expenseColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(totalAssets / total * 100).toStringAsFixed(1)}% ${l10n.totalAssets}',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.incomeColor,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${(totalLiabilities / total * 100).toStringAsFixed(1)}% ${l10n.totalLiabilities}',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.expenseColor,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _emptyState(context, Symbols.error, e.toString()),
    );
  }
}

class _NetWorthTile extends StatelessWidget {
  final String label;
  final double amount;
  final AppCurrency currency;
  final Color color;
  final IconData icon;

  const _NetWorthTile({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: color, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AmountFormatter.formatWithCurrency(amount, currency),
            style: theme.textTheme.titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Account Flow Summary (Unified Cashflow Overview)
// ─────────────────────────────────────────────────────────────────────────────

class AccountFlowSummaryChart extends ConsumerWidget {
  const AccountFlowSummaryChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowSummaryAsync = ref.watch(accountFlowSummaryProvider);
    final accountsAsync = ref.watch(accountsWithBalanceProvider);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return flowSummaryAsync.when(
      data: (summaries) {
        if (summaries.isEmpty) {
          return _emptyState(
              context, Symbols.swap_horiz, l10n.noAccountActivity);
        }

        return accountsAsync.when(
          data: (accounts) {
            final accountMap = {for (final a in accounts) a.account.uuid: a};

            return Column(
              children: summaries.map((item) {
                final acc = item.account;
                final awb = AccountWithBalance(account: acc, balance: 0);
                final color = _accountColor(awb, theme);
                final icon = _accountIcon(awb);

                final netFlowColor = item.netFlow >= 0
                    ? AppColors.incomeColor
                    : AppColors.expenseColor;

                // Max value to scale our bars within this account card
                final double cardMaxInflow = [
                  item.totalIncome,
                  ...item.transfersInBreakdown.values,
                ].fold(0.0, (m, v) => v > m ? v : m);

                final double cardMaxOutflow = [
                  item.totalExpense,
                  ...item.transfersOutBreakdown.values,
                ].fold(0.0, (m, v) => v > m ? v : m);

                final double cardMax = cardMaxInflow > cardMaxOutflow ? cardMaxInflow : cardMaxOutflow;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Account Header ──
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AccountDetailScreen(accountUuid: acc.uuid),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(icon, size: 16, color: color),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                acc.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.chevron_right, size: 18, color: theme.disabledColor),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Balance Info (Opening, Closing, Net Flow) ──
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.openingBalanceLabel,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AmountFormatter.formatWithCurrency(item.openingBalance, currency),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: theme.dividerColor.withValues(alpha: 0.5),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      l10n.netFlow,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.netFlow >= 0 ? "+" : ""}${AmountFormatter.formatWithCurrency(item.netFlow, currency)}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: netFlowColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: theme.dividerColor.withValues(alpha: 0.5),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    l10n.closingBalanceLabel,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AmountFormatter.formatWithCurrency(item.closingBalance, currency),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── INFLOWS ──
                      Row(
                        children: [
                          Icon(Symbols.arrow_downward, color: AppColors.incomeColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${l10n.inflow}: ${AmountFormatter.formatWithCurrency(item.totalInflow, currency)}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.incomeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Direct Income Bar
                      if (item.totalIncome > 0) ...[
                        InkWell(
                          onTap: () {
                            final dateRange = ref.read(selectedDateRangeProvider);
                            ref.read(transactionsPaginatedProvider.notifier).applyFilters(
                              TransactionFilters(
                                type: 'INCOME',
                                accountUuids: [acc.uuid],
                                startDate: dateRange.startDate,
                                endDate: dateRange.endDate,
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TransactionsListScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: _MaskedBar(
                            label: l10n.income,
                            amount: AmountFormatter.formatWithCurrency(item.totalIncome, currency),
                            barColor: AppColors.incomeColor,
                            fillFactor: cardMax > 0 ? (item.totalIncome / cardMax).clamp(0.0, 1.0) : 0.0,
                            icon: Symbols.payments,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Transfers In breakdown
                      ...item.transfersInBreakdown.entries.map((entry) {
                        final otherAccAwb = accountMap[entry.key];
                        final otherAccColor = otherAccAwb != null ? _accountColor(otherAccAwb, theme) : AppColors.incomeColor;
                        final otherAccIcon = otherAccAwb != null ? _accountIcon(otherAccAwb) : Symbols.account_balance_wallet;
                        final otherAccName = otherAccAwb?.account.name ?? l10n.unknownAccount;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            onTap: otherAccAwb != null
                                ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AccountDetailScreen(accountUuid: otherAccAwb.account.uuid),
                                      ),
                                    )
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            child: _MaskedBar(
                              label: l10n.transferFromAnalytics(otherAccName),
                              amount: AmountFormatter.formatWithCurrency(entry.value, currency),
                              barColor: otherAccColor,
                              fillFactor: cardMax > 0 ? (entry.value / cardMax).clamp(0.0, 1.0) : 0.0,
                              icon: otherAccIcon,
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 12),

                      // ── OUTFLOWS ──
                      Row(
                        children: [
                          Icon(Symbols.arrow_upward, color: AppColors.expenseColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${l10n.outflow}: ${AmountFormatter.formatWithCurrency(item.totalOutflow, currency)}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.expenseColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Direct Expense Bar
                      if (item.totalExpense > 0) ...[
                        InkWell(
                          onTap: () {
                            final dateRange = ref.read(selectedDateRangeProvider);
                            ref.read(transactionsPaginatedProvider.notifier).applyFilters(
                              TransactionFilters(
                                type: 'EXPENSE',
                                accountUuids: [acc.uuid],
                                startDate: dateRange.startDate,
                                endDate: dateRange.endDate,
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TransactionsListScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: _MaskedBar(
                            label: l10n.expenses,
                            amount: AmountFormatter.formatWithCurrency(item.totalExpense, currency),
                            barColor: AppColors.expenseColor,
                            fillFactor: cardMax > 0 ? (item.totalExpense / cardMax).clamp(0.0, 1.0) : 0.0,
                            icon: Symbols.credit_card,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Transfers Out breakdown
                      ...item.transfersOutBreakdown.entries.map((entry) {
                        final otherAccAwb = accountMap[entry.key];
                        final otherAccColor = otherAccAwb != null ? _accountColor(otherAccAwb, theme) : AppColors.expenseColor;
                        final otherAccIcon = otherAccAwb != null ? _accountIcon(otherAccAwb) : Symbols.account_balance_wallet;
                        final otherAccName = otherAccAwb?.account.name ?? l10n.unknownAccount;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            onTap: otherAccAwb != null
                                ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AccountDetailScreen(accountUuid: otherAccAwb.account.uuid),
                                      ),
                                    )
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            child: _MaskedBar(
                              label: l10n.transferToAnalytics(otherAccName),
                              amount: AmountFormatter.formatWithCurrency(entry.value, currency),
                              barColor: otherAccColor,
                              fillFactor: cardMax > 0 ? (entry.value / cardMax).clamp(0.0, 1.0) : 0.0,
                              icon: otherAccIcon,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _emptyState(context, Symbols.error, e.toString()),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _emptyState(context, Symbols.error, e.toString()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Credit Card Utilisation
// ─────────────────────────────────────────────────────────────────────────────

class CreditUtilisationChart extends ConsumerWidget {
  const CreditUtilisationChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsWithBalanceProvider);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final symbol = currency.symbol;
    final decimals = currency.decimalPlaces;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return accountsAsync.when(
      data: (accounts) {
        final cards = accounts
            .where(
                (a) => a.type.isCreditCard && (a.account.creditLimit ?? 0) > 0)
            .toList();

        if (cards.isEmpty) {
          return _emptyState(
              context, Symbols.credit_card, l10n.noAccountActivity);
        }

        // Aggregate totals
        double totalLimit = 0;
        double totalOutstanding = 0;
        for (final c in cards) {
          totalLimit += c.account.creditLimit ?? 0;
          if (c.balance < 0) totalOutstanding += c.balance.abs();
        }
        final overallPct = totalLimit > 0
            ? (totalOutstanding / totalLimit).clamp(0.0, 1.0)
            : 0.0;
        final overallColor = overallPct > 0.8
            ? AppColors.expenseColor
            : overallPct > 0.5
                ? Colors.orange
                : AppColors.incomeColor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aggregate masked bar — same layout as per-card but larger text
            _MaskedBar(
              label: AmountFormatter.formatWithCurrency(
                  totalOutstanding, currency),
              amount: AmountFormatter.formatWithCurrency(
                  totalLimit, currency),
              barColor: overallColor,
              fillFactor: overallPct,
              icon: Symbols.credit_score,
              labelFontSize: 18,
              amountFontSize: 18,
            ),
            const SizedBox(height: 16),

            // Per-card breakdown
            ...cards.map((awb) {
              final color = _accountColor(awb, theme);
              final limit = awb.account.creditLimit ?? 0;
              final outstanding = awb.balance < 0 ? awb.balance.abs() : 0.0;
              final pct =
                  limit > 0 ? (outstanding / limit).clamp(0.0, 1.0) : 0.0;
              final barColor = pct > 0.8 ? AppColors.expenseColor : color;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountDetailScreen(
                          accountUuid: awb.account.uuid),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account name row
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(_accountIcon(awb), size: 15,
                                color: color),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(awb.account.name,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Icon(Icons.chevron_right,
                              size: 16, color: theme.disabledColor),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _MaskedBar(
                        label: AmountFormatter.formatWithCurrency(
                            outstanding, currency),
                        amount: AmountFormatter.formatWithCurrency(
                            limit, currency),
                        barColor: barColor,
                        fillFactor: pct,
                        icon: Symbols.credit_card,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _emptyState(context, Symbols.error, e.toString()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Balance Distribution (Donut Chart)
// ─────────────────────────────────────────────────────────────────────────────

class BalanceDistributionChart extends ConsumerWidget {
  const BalanceDistributionChart();

  static const double _centerSpaceRadius = 35;
  static const double _baseSectionRadius = 28;
  static const double _radiusRangeByPercent = 45;
  static const double _chartHeight = 280;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsWithBalanceProvider);
    final selectedIndex = ref.watch(selectedBalanceAccountIndexProvider);
    final currencyAsync = ref.watch(currentCurrencyProvider);
    final currency = currencyAsync.value;

    if (currency == null) {
      return const SizedBox.shrink();
    }

    final symbol = currency.symbol;
    final decimals = currency.decimalPlaces;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return accountsAsync.when(
      data: (accounts) {
        final positiveAccounts = accounts.where((a) => a.balance > 0).toList();

        if (positiveAccounts.isEmpty) {
          return _emptyState(
              context, Symbols.pie_chart, l10n.noAccountActivity);
        }

        final total = positiveAccounts.fold(0.0, (s, a) => s + a.balance);

        double maxPct = 0.0;
        for (final a in positiveAccounts) {
          final p = total > 0 ? (a.balance / total) * 100 : 0.0;
          if (p > maxPct) maxPct = p;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _chartHeight,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: _centerSpaceRadius,
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback:
                        (FlTouchEvent event, PieTouchResponse? response) {
                      final index =
                          response?.touchedSection?.touchedSectionIndex;
                      if (event is FlTapUpEvent) {
                        ref
                            .read(selectedBalanceAccountIndexProvider.notifier)
                            .setIndex(index != null
                                ? (selectedIndex == index ? null : index)
                                : null);
                      }
                    },
                  ),
                  sections: List.generate(positiveAccounts.length, (i) {
                    final awb = positiveAccounts[i];
                    final color = _accountColor(awb, theme);
                    final pct =
                        total > 0 ? (awb.balance / total) * 100 : 0.0;
                    final isSelected = selectedIndex == i;

                    final radius = _centerSpaceRadius +
                        _baseSectionRadius +
                        (maxPct > 0
                            ? (pct / maxPct) * _radiusRangeByPercent
                            : 0.0);

                    final String title = pct >= 5
                        ? '${pct.toStringAsFixed(0)}%'
                        : pct >= 1
                            ? '${pct.toStringAsFixed(0)}%'
                            : pct > 0
                                ? '<1%'
                                : '';
                    final double fontSize =
                        pct >= 10 ? 12 : pct >= 5 ? 10 : pct >= 1 ? 8 : 7;

                    final icon = _accountIcon(awb);
                    Widget? badgeWidget;
                    if (pct >= 10) {
                      badgeWidget = Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(icon, size: 18, color: Colors.white),
                      );
                    }

                    return PieChartSectionData(
                      color:
                          isSelected ? color.withValues(alpha: 0.85) : color,
                      value: awb.balance,
                      title: title,
                      showTitle: title.isNotEmpty,
                      titleStyle: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      radius: radius,
                      badgeWidget: badgeWidget,
                      badgePositionPercentageOffset: 0.98,
                      titlePositionPercentageOffset:
                          badgeWidget != null ? 0.55 : 0.98,
                      borderSide: isSelected
                          ? BorderSide(
                              color: theme.colorScheme.surface, width: 3)
                          : BorderSide(
                              color: color.withValues(alpha: 0.3), width: 1),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(positiveAccounts.length, (i) {
              final awb = positiveAccounts[i];
              final color = _accountColor(awb, theme);
              final pct = total > 0 ? (awb.balance / total) * 100 : 0.0;
              final isSelected = selectedIndex == i;
              final icon = _accountIcon(awb);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? color
                        : theme.dividerColor.withValues(alpha: 0.5),
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: GestureDetector(
                  onDoubleTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AccountDetailScreen(accountUuid: awb.account.uuid),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => ref
                        .read(selectedBalanceAccountIndexProvider.notifier)
                        .setIndex(selectedIndex == i ? null : i),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: color.withValues(alpha: 0.4)),
                            ),
                            alignment: Alignment.center,
                            child: Icon(icon, size: 26, color: color),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  awb.account.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: color.withValues(alpha: 0.3),
                                        width: 1),
                                  ),
                                  child: Text(
                                    '${pct.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!.doubleTapForDetails,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            AmountFormatter.formatWithCurrency(
                                awb.balance, currency),
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _emptyState(context, Symbols.error, e.toString()),
    );
  }
}


class _FlowStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String amount;
  final Color color;
  final ThemeData theme;

  const _FlowStat({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _AccountChip extends StatelessWidget {
  final AccountWithBalance? awb;
  final Color color;
  final ThemeData theme;

  const _AccountChip({
    required this.awb,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final name = awb?.account.name ?? '?';
    final icon =
        awb != null ? _accountIcon(awb!) : Symbols.account_balance_wallet;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(
              name,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Masked progress bar — label + amount inside, color-masked like _CreditProgressBar
// ─────────────────────────────────────────────────────────────────────────────
class _MaskedBar extends StatelessWidget {
  final String label;
  final String amount;
  final Color barColor;
  final double fillFactor;
  final IconData icon;
  final double labelFontSize;
  final double amountFontSize;
  /// When true the fill grows from the right (used for inflow bars).
  final bool reversed;

  const _MaskedBar({
    required this.label,
    required this.amount,
    required this.barColor,
    required this.fillFactor,
    required this.icon,
    this.labelFontSize = 11,
    this.amountFontSize = 12,
    this.reversed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // Inflow bars fill from right; outflow bars fill from left.
    // RTL flips the logical direction.
    final fillFromRight = reversed ? !isRtl : isRtl;

    Widget content(Color textColor) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon,
                  size: labelFontSize + 1,
                  color: textColor.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                    fontSize: labelFontSize,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: amountFontSize,
                ),
              ),
            ],
          ),
        );

    final barHeight = labelFontSize > 11 ? 48.0 : 36.0;
    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: barColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: barColor.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: content(barColor),
          ),
          ClipRect(
            child: Align(
              alignment: fillFromRight
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              widthFactor: fillFactor,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: content(Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
