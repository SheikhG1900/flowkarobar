import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/orders/presentation/providers/orders_provider.dart';
import 'package:flowpaisa/features/orders/presentation/screens/add_order_screen.dart';
import 'package:flowpaisa/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/app_floating_action_button.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const OrdersListScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  void _openAddOrder(String orderType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddOrderScreen(orderType: orderType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final contacts = ref.watch(contactsListProvider).value ?? const <Contact>[];
    final contactNames = {for (final c in contacts) c.uuid: c.name};

    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTab.clamp(0, 2),
      child: Builder(
        builder: (context) {
          final controller = DefaultTabController.of(context);
          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.orders),
              bottom: TabBar(
                tabs: [
                  Tab(text: l10n.sales),
                  Tab(text: l10n.purchases),
                  Tab(text: l10n.returns),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _OrdersTab(
                  orderType: orderTypeSale,
                  contactNames: contactNames,
                  emptyMessage: l10n.noSalesYet,
                  emptyIcon: Icons.point_of_sale_rounded,
                ),
                _OrdersTab(
                  orderType: orderTypePurchase,
                  contactNames: contactNames,
                  emptyMessage: l10n.noPurchasesYet,
                  emptyIcon: Icons.shopping_cart_outlined,
                ),
                _ReturnsTab(contactNames: contactNames),
              ],
            ),
            floatingActionButton: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final index = controller.index;
                if (index > 1) return const SizedBox.shrink();
                final orderType =
                    index == 0 ? orderTypeSale : orderTypePurchase;
                return AppFloatingActionButton(
                  heroTag: 'orders_fab',
                  backgroundColor: orderTypeColor(orderType),
                  foregroundColor: Colors.white,
                  tooltip: index == 0 ? l10n.newSale : l10n.newPurchase,
                  onPressed: () => _openAddOrder(orderType),
                  child: const Icon(Icons.add),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _OrdersTab extends ConsumerWidget {
  final String orderType;
  final Map<String, String> contactNames;
  final String emptyMessage;
  final IconData emptyIcon;

  const _OrdersTab({
    required this.orderType,
    required this.contactNames,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ordersAsync = ref.watch(ordersByTypeStreamProvider(orderType));

    return ordersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.errorOccurred(e.toString()))),
      data: (orders) {
        if (orders.isEmpty) {
          return OrderEmptyState(
            icon: emptyIcon,
            message: emptyMessage,
            color: orderTypeColor(orderType),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = orders[index];
            return _OrderCard(
              order: order,
              contactName: contactNames[order.contactUuid],
            );
          },
        );
      },
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  final String? contactName;

  const _OrderCard({required this.order, required this.contactName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final typeColor = orderTypeColor(order.orderType);

    return Container(
      decoration: AppColors.transactionListItemDecoration(theme, typeColor),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderUuid: order.uuid),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.orderNumber,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      formatOrderAmount(ref, order.totalAmount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        contactName ?? l10n.walkInCustomer,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      AppDateFormatter.formatDate(
                        order.orderDate,
                        pattern: dateFormat,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    OrderStatusChip(
                      label: paymentStatusLabel(l10n, order.paymentStatus),
                      color: paymentStatusColor(
                        order.orderType,
                        order.paymentStatus,
                      ),
                    ),
                    OrderStatusChip(
                      label: deliveryStatusLabel(l10n, order.deliveryStatus),
                      color: deliveryStatusColor(order.deliveryStatus),
                      icon: Icons.local_shipping_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReturnsTab extends ConsumerWidget {
  final Map<String, String> contactNames;

  const _ReturnsTab({required this.contactNames});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final returnsAsync = ref.watch(allReturnsStreamProvider);

    return returnsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l10n.errorOccurred(e.toString()))),
      data: (returns) {
        if (returns.isEmpty) {
          return OrderEmptyState(
            icon: Icons.assignment_return_outlined,
            message: l10n.noReturnsYet,
            color: theme.colorScheme.primary,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: returns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = returns[index];
            final color = orderTypeColor(item.orderType);
            return Container(
              decoration:
                  AppColors.transactionListItemDecoration(theme, color),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.returnNumber,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        formatOrderAmount(ref, item.totalRefundAmount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contactNames[item.contactUuid] ??
                              l10n.walkInCustomer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        AppDateFormatter.formatDate(
                          item.date,
                          pattern: dateFormat,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
