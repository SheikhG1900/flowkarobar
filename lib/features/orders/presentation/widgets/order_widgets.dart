import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';

const String orderTypeSale = 'SALE';
const String orderTypePurchase = 'PURCHASE';

String formatOrderAmount(WidgetRef ref, double amount) {
  final currency = ref.watch(currentCurrencyProvider).value;
  if (currency != null) {
    return AmountFormatter.formatWithCurrency(amount, currency);
  }
  return AmountFormatter.formatWithCurrency(
    amount,
    ref.watch(currencySymbolProvider),
    ref.watch(currencyDecimalPlacesProvider),
  );
}

Color orderTypeColor(String orderType) =>
    orderType == orderTypeSale ? AppColors.incomeColor : AppColors.expenseColor;

Color paymentStatusColor(String orderType, String status) {
  if (status == 'PAID') return AppColors.success;
  return orderType == orderTypeSale
      ? AppColors.receivableColor
      : AppColors.payableColor;
}

Color deliveryStatusColor(String status) {
  switch (status) {
    case 'DELIVERED':
      return AppColors.success;
    case 'CANCELLED':
      return AppColors.error;
    case 'SHIPPED':
      return AppColors.info;
    default:
      return AppColors.warning;
  }
}

String paymentStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'PAID':
      return l10n.paid;
    case 'PARTIALLY_PAID':
      return l10n.partiallyPaid;
    default:
      return l10n.unpaid;
  }
}

String deliveryStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'DELIVERED':
      return l10n.delivered;
    case 'SHIPPED':
      return l10n.shipped;
    case 'CANCELLED':
      return l10n.cancelled;
    default:
      return l10n.deliveryPending;
  }
}

class OrderStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const OrderStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const OrderEmptyState({
    super.key,
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: color.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
