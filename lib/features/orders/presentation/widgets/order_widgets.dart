import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_discounts.dart';
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

/// Effective discounted unit from snapshot or legacy line discount.
double orderItemDiscountedUnitPrice({
  required double listUnitPrice,
  required double quantity,
  required double lineDiscountAmount,
  double? discountedUnitPrice,
}) {
  if (discountedUnitPrice != null && discountedUnitPrice.isFinite) {
    return discountedUnitPrice < 0 ? 0 : discountedUnitPrice;
  }
  final qty = quantity.isFinite && quantity > 0 ? quantity : 0.0;
  if (qty <= 0) return listUnitPrice.isFinite ? listUnitPrice : 0.0;
  final list = listUnitPrice.isFinite ? listUnitPrice : 0.0;
  final disc = lineDiscountAmount.isFinite ? lineDiscountAmount : 0.0;
  final after = list - disc / qty;
  return after < 0 ? 0 : after;
}

/// Compact price hierarchy shared by New Sale lines and order detail.
class OrderLinePriceStack extends StatelessWidget {
  final double listUnitPrice;
  final double discountedUnitPrice;
  final double quantity;
  final Color accent;
  final WidgetRef ref;

  const OrderLinePriceStack({
    super.key,
    required this.listUnitPrice,
    required this.discountedUnitPrice,
    required this.quantity,
    required this.accent,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final qty = quantity;
    final multiQty = qty > 1.0000001;
    final unitDisc = SaleLinePricing.unitDiscountFixed(
      listUnitPrice: listUnitPrice,
      discountedUnitPrice: discountedUnitPrice,
    );
    final hasDiscount = unitDisc > 1e-9;
    final pct = AmountFormatter.formatDiscountPercent(
      SaleLinePricing.unitDiscountPercent(
        listUnitPrice: listUnitPrice,
        discountedUnitPrice: discountedUnitPrice,
      ),
    );
    final listText = formatOrderAmount(ref, listUnitPrice);
    final discountedUnitText = formatOrderAmount(ref, discountedUnitPrice);
    final unitDiscText = formatOrderAmount(ref, unitDisc);
    final lineTotalText = formatOrderAmount(
      ref,
      SaleLinePricing.lineTotal(
        discountedUnitPrice: discountedUnitPrice,
        quantity: qty,
      ),
    );
    final lineDiscText = formatOrderAmount(
      ref,
      SaleLinePricing.lineDiscountFixed(
        listUnitPrice: listUnitPrice,
        discountedUnitPrice: discountedUnitPrice,
        quantity: qty,
      ),
    );
    final qtyText = AmountFormatter.formatQuantity(qty);

    Widget discountAmountText({
      required String amountText,
      required Color color,
    }) {
      return Text(
        '−$amountText ($pct%)',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.end,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (hasDiscount)
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  listText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: muted.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                discountAmountText(
                  amountText: unitDiscText,
                  color: AppColors.expenseColor,
                ),
              ],
            ),
          ),
        if (hasDiscount) const SizedBox(height: 2),
        if (multiQty)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: discountedUnitText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' × $qtyText',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.end,
          )
        else
          Text(
            discountedUnitText,
            style: theme.textTheme.titleMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.end,
          ),
        if (multiQty) ...[
          const SizedBox(height: 2),
          Text(
            lineTotalText,
            style: theme.textTheme.titleMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.end,
          ),
        ],
        if (hasDiscount && multiQty) ...[
          const SizedBox(height: 1),
          discountAmountText(
            amountText: lineDiscText,
            color: AppColors.incomeColor,
          ),
        ],
      ],
    );
  }
}
