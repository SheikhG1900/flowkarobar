import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/orders/presentation/screens/add_order_screen.dart';
import 'package:flowpaisa/features/orders/presentation/screens/orders_list_screen.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

Future<void> showOrderActionSheet(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context)!;

  void push(BuildContext sheetContext, Widget screen) {
    Navigator.pop(sheetContext);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionTile(
            icon: Icons.point_of_sale_rounded,
            color: AppColors.incomeColor,
            title: l10n.newSale,
            onTap: () => push(
              sheetContext,
              const AddOrderScreen(orderType: orderTypeSale),
            ),
          ),
          _ActionTile(
            icon: Icons.shopping_cart_outlined,
            color: AppColors.expenseColor,
            title: l10n.newPurchase,
            onTap: () => push(
              sheetContext,
              const AddOrderScreen(orderType: orderTypePurchase),
            ),
          ),
          _ActionTile(
            icon: Icons.payments_outlined,
            color: Theme.of(sheetContext).colorScheme.primary,
            title: l10n.recordPayment,
            onTap: () {
              Navigator.pop(sheetContext);
              _showPaymentSheet(context);
            },
          ),
          _ActionTile(
            icon: Icons.assignment_return_outlined,
            color: Theme.of(sheetContext).colorScheme.secondary,
            title: l10n.newReturn,
            onTap: () {
              Navigator.pop(sheetContext);
              ToastUtils.showInfoToast(context, ref, l10n.comingSoon);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Future<void> _showPaymentSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  void open(BuildContext sheetContext, int tab) {
    Navigator.pop(sheetContext);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrdersListScreen(initialTab: tab)),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionTile(
            icon: Icons.south_west_rounded,
            color: AppColors.receivableColor,
            title: l10n.collectPayment,
            onTap: () => open(sheetContext, 0),
          ),
          _ActionTile(
            icon: Icons.north_east_rounded,
            color: AppColors.payableColor,
            title: l10n.payToSupplier,
            onTap: () => open(sheetContext, 1),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}
