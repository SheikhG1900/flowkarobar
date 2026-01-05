import 'package:flutter/material.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

/// Balance Card with Gradient Background
/// Hero card displaying total balance with income/expense breakdown
class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final String currency;
  final VoidCallback? onTap;
  final bool showDetails;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    this.currency = '₹',
    this.onTap,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.currency(
      symbol: currency,
      decimalDigits: 2,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.brightCyan.withValues(alpha: 0.4 / 1.0),
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
                  'Total Balance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.7),
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Balance Amount
            Text(
              numberFormat.format(balance),
              style: theme.textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                height: 1.2,
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
                      label: 'Income',
                      amount: income,
                      color: Colors.greenAccent,
                      currency: currency,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      icon: Icons.arrow_upward_rounded,
                      label: 'Expense',
                      amount: expense,
                      color: Colors.redAccent,
                      currency: currency,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    required String currency,
  }) {
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.currency(
      symbol: currency,
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
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
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            numberFormat.format(amount),
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
class CompactBalanceCard extends StatelessWidget {
  final double balance;
  final String currency;
  final String label;
  final Gradient? gradient;

  const CompactBalanceCard({
    super.key,
    required this.balance,
    this.currency = '₹',
    this.label = 'Balance',
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.currency(
      symbol: currency,
      decimalDigits: 2,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.secondaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                numberFormat.format(balance),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

