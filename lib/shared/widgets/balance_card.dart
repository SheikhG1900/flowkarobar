import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';

/// Balance Card with Gradient Background
/// Prominent balance card displaying total balance with income/expense breakdown
class BalanceCard extends ConsumerWidget {
  final double balance;
  final double income;
  final double expense;
  final VoidCallback? onTap;
  final bool showDetails;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    this.onTap,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currencyAsync = ref.watch(currentCurrencyProvider);

    return currencyAsync.when(
      data: (currency) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.getPrimaryGradient(theme.colorScheme.primary),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ), // Diagonal beveled
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4 / 1.0),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.totalBalance,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 16,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Balance Amount
                Text(
                  AmountFormatter.formatWithCurrency(balance, currency.symbol, currency.decimalPlaces),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    fontSize: AmountFormatter.getFontSize(balance,
                        baseSize: theme.textTheme.displayMedium?.fontSize ?? 45.0,
                        decimalPlaces: currency.decimalPlaces),
                  ),
                ),
                
                if (showDetails) ...[
                  const SizedBox(height: 24),
                  
                  // Income & Expense Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          context,
                          icon: Icons.arrow_downward_rounded,
                          label: l10n.income,
                          amount: income,
                          color: Colors.greenAccent,
                          currency: currency.symbol,
                          decimalPlaces: currency.decimalPlaces,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          icon: Icons.arrow_upward_rounded,
                          label: l10n.expense,
                          amount: expense,
                          color: Colors.redAccent,
                          currency: currency.symbol,
                          decimalPlaces: currency.decimalPlaces,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(child: Text(l10n.errorLoadingCurrency)),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    required String currency,
    required int decimalPlaces,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ), // Diagonal beveled
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AmountFormatter.formatWithCurrency(amount, currency, decimalPlaces),
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact Balance Card
/// Smaller version for inline displays
class CompactBalanceCard extends ConsumerWidget {
  final double balance;
  final String? label;
  final Gradient? gradient;

  const CompactBalanceCard({
    super.key,
    required this.balance,
    this.label,
    this.gradient,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currencyAsync = ref.watch(currentCurrencyProvider);

    return currencyAsync.when(
      data: (currency) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: gradient ?? AppColors.getSecondaryGradient(theme.colorScheme.primary),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ), // Diagonal beveled
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label ?? l10n.balanceLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AmountFormatter.formatWithCurrency(balance, currency.symbol, currency.decimalPlaces),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: AmountFormatter.getFontSize(balance,
                          baseSize: theme.textTheme.titleLarge?.fontSize ?? 20.0,
                          decimalPlaces: currency.decimalPlaces),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(width: 100, height: 50, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => SizedBox(width: 100, height: 50, child: Center(child: Text(l10n.errorLabel))),
    );
  }
}
