import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_picker.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/transfer_account_box.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_availability.dart';
import 'package:flowpaisa/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:flowpaisa/features/catalog/presentation/screens/add_selling_product_screen.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/contacts/presentation/screens/contact_details_screen.dart';
import 'package:flowpaisa/features/inventory/data/inventory_repository.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/inventory/presentation/screens/product_details_screen.dart';
import 'package:flowpaisa/features/orders/domain/order_shipment.dart';
import 'package:flowpaisa/features/orders/presentation/providers/orders_provider.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_entity_pickers.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/corner_badge_container.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/entity_picker_sheet.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';
import 'package:flowpaisa/shared/widgets/ltr_number_field.dart';
import 'package:flowpaisa/shared/widgets/pending_sync_badge.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderUuid;

  const OrderDetailScreen({super.key, required this.orderUuid});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _busy = false;

  void _refresh() {
    ref.invalidate(singleOrderProvider(widget.orderUuid));
    ref.invalidate(orderPaidAmountProvider(widget.orderUuid));
    ref.invalidate(orderPaymentsStreamProvider(widget.orderUuid));
    ref.invalidate(orderCostsStreamProvider(widget.orderUuid));
    ref.invalidate(orderItemsStreamProvider(widget.orderUuid));
    ref.invalidate(orderChargesStreamProvider(widget.orderUuid));
    ref.invalidate(orderDeliveriesStreamProvider(widget.orderUuid));
    ref.invalidate(orderReceiptsStreamProvider(widget.orderUuid));
    ref.invalidate(orderItemFulfillableQtyProvider(widget.orderUuid));
    ref.invalidate(saleOrderCatalogLineIssuesProvider(widget.orderUuid));
  }

  Future<void> _recordPayment(Order order, double balance) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<_PaymentResult>(
      context: context,
      builder: (context) => _PaymentDialog(
        title: l10n.recordPayment,
        initialAmount: balance,
        maxAmount: balance,
      ),
    );
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(ordersRepositoryProvider).recordOrderPayment(
            orderUuid: order.uuid,
            amount: result.amount,
            accountUuid: result.accountUuid,
            date: result.date,
            description: result.description,
          );
      _refresh();
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.paymentRecorded);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openPaymentActions({
    required Order order,
    required Transaction payment,
    required Account? account,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = ref.read(userProfileProvider).dateFormat;
    final isSale = order.orderType == orderTypeSale;
    final accent =
        isSale ? AppColors.incomeColor : AppColors.expenseColor;
    final desc = payment.description?.trim();
    final dateText = AppDateFormatter.formatDate(
      payment.date,
      pattern: dateFormat,
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.getPrimaryGradient(accent),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSale
                                ? l10n.collectPayment
                                : l10n.payToSupplier,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${isSale ? '\u200E+' : '\u200E-'} ${formatOrderAmount(ref, payment.amount)}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _SheetMetaChip(
                                icon: Icons.event_outlined,
                                label: dateText,
                              ),
                              if (account != null)
                                _SheetMetaChip(
                                  icon: TransferAccountBox.iconForAccount(
                                    account,
                                  ),
                                  label: account.name,
                                ),
                            ],
                          ),
                          if (desc != null && desc.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              desc,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: Column(
                      children: [
                        _SheetActionTile(
                          icon: Icons.edit_outlined,
                          color: accent,
                          title: l10n.correctPayment,
                          subtitle: l10n.description,
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _correctPayment(order: order, payment: payment);
                          },
                        ),
                        _SheetActionTile(
                          icon: Icons.delete_outline,
                          color: AppColors.error,
                          title: l10n.deletePayment,
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _deletePayment(order: order, payment: payment);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _correctPayment({
    required Order order,
    required Transaction payment,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(ordersRepositoryProvider);
    final maxAmount = await repo.maxPayableAmountForOrder(
      order.uuid,
      excludingPaymentUuid: payment.uuid,
    );
    if (!mounted) return;

    final result = await showDialog<_PaymentResult>(
      context: context,
      builder: (context) => _PaymentDialog(
        title: l10n.correctPayment,
        initialAmount: payment.amount,
        maxAmount: maxAmount,
        initialAccountUuid: payment.accountUuid,
        initialDate: payment.date,
        initialDescription: payment.description,
      ),
    );
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await repo.updateOrderPayment(
        orderUuid: order.uuid,
        paymentUuid: payment.uuid,
        amount: result.amount,
        accountUuid: result.accountUuid,
        date: result.date,
        description: result.description,
      );
      _refresh();
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.paymentCorrected);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deletePayment({
    required Order order,
    required Transaction payment,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePayment),
        content: Text(l10n.confirmDeletePayment),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(ordersRepositoryProvider).deleteOrderPayment(
            orderUuid: order.uuid,
            paymentUuid: payment.uuid,
          );
      _refresh();
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.paymentDeleted);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _markDelivered(Order order) async {
    final l10n = AppLocalizations.of(context)!;
    final items =
        await ref.read(orderItemsStreamProvider(order.uuid).future);
    if (!mounted) return;

    if (order.orderType == orderTypeSale) {
      final issues = await ref
          .read(catalogRepositoryProvider)
          .saleLineCatalogIssuesForOrder(order.uuid);
      final problemCount =
          issues.values.where((i) => i.isProblem).length;
      if (problemCount > 0) {
        if (!mounted) return;
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.saleCatalogLinesInvalidTitle),
            content: Text(l10n.saleCatalogLinesInvalidBody(problemCount)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.proceed),
              ),
            ],
          ),
        );
        if (proceed != true || !mounted) return;
      }
    }

    final fulfillable = order.orderType == orderTypeSale
        ? await ref.read(orderItemFulfillableQtyProvider(order.uuid).future)
        : const <String, double?>{};
    if (!mounted) return;

    final shipment = await showModalBottomSheet<_ShipmentQtyResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ShipmentQtySheet(
        order: order,
        items: items,
        availableByItem: fulfillable,
      ),
    );
    if (shipment == null || shipment.lines.isEmpty || !mounted) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(ordersRepositoryProvider);
      if (order.orderType == orderTypePurchase) {
        await repo.receivePurchaseShipment(
          orderUuid: order.uuid,
          lines: [
            for (final line in shipment.lines)
              ReceiveLineInput(
                orderItemUuid: line.orderItemUuid,
                quantity: line.quantity,
              ),
          ],
          freightAmount: shipment.freight,
          dutyAmount: shipment.duty,
        );
      } else {
        await repo.deliverSaleShipment(
          orderUuid: order.uuid,
          lines: shipment.lines,
        );
      }
      _refresh();
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.orderMarkedDelivered);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recordRelatedCost(Order order) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<_CostResult>(
      context: context,
      builder: (context) => const _CostDialog(),
    );
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(ordersRepositoryProvider).recordOrderCost(
            orderUuid: order.uuid,
            amount: result.amount,
            accountUuid: result.accountUuid,
            description: result.description,
            date: result.date,
          );
      _refresh();
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.costRecorded);
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteRelatedCost(Order order, Transaction cost) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRelatedCost),
        content: Text(l10n.deleteRelatedCostConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(ordersRepositoryProvider).deleteOrderCost(
            orderUuid: order.uuid,
            costUuid: cost.uuid,
          );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareInvoice(Order order, Contact? contact) async {
    final l10n = AppLocalizations.of(context)!;
    if (order.orderType == orderTypeSale && !PremiumGate.isPremium(ref)) {
      PremiumGate.showPremiumDialog(context);
      return;
    }

    setState(() => _busy = true);
    try {
      final items =
          await ref.read(orderItemsStreamProvider(order.uuid).future);
      await ref.read(invoicePdfServiceProvider).shareInvoicePdf(
            order: order,
            items: items,
            contact: contact,
            l10n: l10n,
          );
    } catch (e) {
      if (!mounted) return;
      ToastUtils.showErrorToast(context, ref, l10n.errorSharing(e.toString()));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orderAsync = ref.watch(singleOrderProvider(widget.orderUuid));

    final typeColor = orderAsync.maybeWhen(
      data: (o) => o == null
          ? Theme.of(context).colorScheme.primary
          : orderTypeColor(o.orderType),
      orElse: () => Theme.of(context).colorScheme.primary,
    );

    return FormPageScaffold(
      accentColor: typeColor,
      appBar: AppBar(
        title: Text(l10n.orderDetails),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorOccurred(e.toString()))),
        data: (order) {
          if (order == null) {
            return Center(child: Text(l10n.orderNotFound));
          }
          return _buildContent(context, order);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Order order) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final typeColor = orderTypeColor(order.orderType);
    final isSale = order.orderType == orderTypeSale;

    final contacts = ref.watch(contactsListProvider).value ?? const <Contact>[];
    final contact =
        contacts.where((c) => c.uuid == order.contactUuid).firstOrNull;
    final itemsAsync = ref.watch(orderItemsStreamProvider(order.uuid));
    final chargesAsync = ref.watch(orderChargesStreamProvider(order.uuid));
    final paymentsAsync = ref.watch(orderPaymentsStreamProvider(order.uuid));
    final costsAsync = ref.watch(orderCostsStreamProvider(order.uuid));
    final fulfillableAsync = isSale
        ? ref.watch(orderItemFulfillableQtyProvider(order.uuid))
        : null;
    final fulfillableByItem =
        fulfillableAsync?.asData?.value ?? const <String, double?>{};
    final shipmentsAsync = isSale
        ? ref.watch(orderDeliveriesStreamProvider(order.uuid))
        : ref.watch(orderReceiptsStreamProvider(order.uuid));
    final accounts =
        ref.watch(accountsStreamProvider).value ?? const <Account>[];
    final accountsByUuid = {for (final a in accounts) a.uuid: a};
    final catalogIssues = isSale
        ? ref.watch(saleOrderCatalogLineIssuesProvider(order.uuid)).asData?.value
        : null;
    final invalidCatalogCount = catalogIssues?.values
            .where((i) => i.isProblem)
            .length ??
        0;
    final paid = ref.watch(orderPaidAmountProvider(order.uuid)).value ?? 0.0;
    final balance =
        (order.totalAmount - paid).clamp(0, double.infinity).toDouble();

    final canPay = order.paymentStatus != 'PAID' && balance > 0;
    final canDeliver = order.deliveryStatus != 'DELIVERED' &&
        order.deliveryStatus != 'CANCELLED';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        if (isSale && invalidCatalogCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: AppColors.warning.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.saleCatalogLinesInvalidBody(invalidCatalogCount),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        _OrderHero(
          typeLabel: isSale ? l10n.sale : l10n.purchase,
          orderNumber: order.orderNumber,
          accent: typeColor,
          amountText: formatOrderAmount(ref, order.totalAmount),
          paymentLabel: paymentStatusLabel(l10n, order.paymentStatus),
          deliveryLabel: deliveryStatusLabel(l10n, order.deliveryStatus),
          showPendingSync: order.isNotSynced == true,
        ),
        FormSectionCard(
          title: l10n.information,
          icon: Icons.info_outline,
          accentColor: typeColor,
          children: [
            _DetailRow(
              icon: Icons.person_outline,
              label: l10n.contact,
              value: contact?.name ?? l10n.walkInCustomer,
              onTap: contact == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContactDetailsScreen(
                            contactUuid: contact.uuid,
                          ),
                        ),
                      );
                    },
            ),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: l10n.date,
              value: AppDateFormatter.formatDate(
                order.orderDate,
                pattern: dateFormat,
              ),
            ),
            if (order.dueDate != null)
              _DetailRow(
                icon: Icons.event_outlined,
                label: l10n.dueDate,
                value: AppDateFormatter.formatDate(
                  order.dueDate!,
                  pattern: dateFormat,
                ),
              ),
            if (order.notes != null && order.notes!.trim().isNotEmpty)
              _DetailRow(
                icon: Icons.notes_outlined,
                label: l10n.notesLabel,
                value: order.notes!.trim(),
              ),
          ],
        ),
        FormSectionCard(
          title: l10n.items,
          icon: Icons.shopping_bag_outlined,
          accentColor: typeColor,
          children: [
            itemsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(l10n.errorOccurred(e.toString())),
              data: (items) {
                if (items.isEmpty) {
                  return Text(
                    l10n.noProductsYet,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _ItemTile(
                        item: items[i],
                        ref: ref,
                        accent: typeColor,
                        isSale: isSale,
                        catalogIssue:
                            catalogIssues?[items[i].uuid] ??
                                SaleCatalogLineIssue.none,
                        availableQuantity:
                            fulfillableByItem[items[i].uuid],
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
        FormSectionCard(
          title: isSale ? l10n.deliveriesSection : l10n.receiptsSection,
          icon: isSale
              ? Icons.local_shipping_outlined
              : Icons.move_to_inbox_outlined,
          accentColor: typeColor,
          children: [
            shipmentsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(l10n.errorOccurred(e.toString())),
              data: (shipments) {
                if (shipments.isEmpty) {
                  return Text(
                    isSale ? l10n.noDeliveriesYet : l10n.noReceiptsYet,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < shipments.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _ShipmentTile(
                        shipment: shipments[i],
                        accent: typeColor,
                        isSale: isSale,
                        dateFormat: dateFormat,
                        ref: ref,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
        FormSectionCard(
          title: l10n.sectionSummary,
          icon: Icons.receipt_long_outlined,
          accentColor: typeColor,
          children: [
            _AmountRow(label: l10n.subtotal, value: order.subtotal, ref: ref),
            if (order.discountAmount > 0)
              _AmountRow(
                label: l10n.discount,
                value: -order.discountAmount,
                ref: ref,
              ),
            _AmountRow(
              label: l10n.taxableAmount,
              value: (order.subtotal - order.discountAmount)
                  .clamp(0, double.infinity)
                  .toDouble(),
              ref: ref,
              muted: true,
            ),
            if (order.taxAmount > 0 || order.taxRate > 0)
              _AmountRow(
                label: l10n.salesTax,
                value: order.taxAmount,
                ref: ref,
                valueSuffix: order.taxRate > 0
                    ? '${AmountFormatter.formatQuantity(order.taxRate)}%'
                    : null,
              ),
            ...?(chargesAsync.asData?.value
                .where((c) => c.amount > 0)
                .map(
                  (c) => _AmountRow(
                    label: c.description,
                    value: c.amount,
                    ref: ref,
                  ),
                )),
            const Divider(height: 8),
            _AmountRow(
              label: l10n.totalAmount,
              value: order.totalAmount,
              ref: ref,
              color: typeColor,
              bold: true,
            ),
            _AmountRow(
              label: l10n.paid,
              value: paid,
              ref: ref,
              color: AppColors.success,
            ),
            _AmountRow(
              label: l10n.balanceDue,
              value: balance,
              ref: ref,
              color: isSale
                  ? AppColors.receivableColor
                  : AppColors.payableColor,
              bold: true,
            ),
          ],
        ),
        FormSectionCard(
          title: l10n.orderPayments,
          icon: Icons.payments_outlined,
          accentColor: typeColor,
          children: [
            paymentsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(l10n.errorOccurred(e.toString())),
              data: (payments) {
                if (payments.isEmpty) {
                  return Text(
                    l10n.noOrderPayments,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < payments.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _PaymentTile(
                        payment: payments[i],
                        account: payments[i].accountUuid == null
                            ? null
                            : accountsByUuid[payments[i].accountUuid!],
                        accent: typeColor,
                        isSale: isSale,
                        dateFormat: dateFormat,
                        ref: ref,
                        onTap: _busy
                            ? null
                            : () => _openPaymentActions(
                                  order: order,
                                  payment: payments[i],
                                  account: payments[i].accountUuid == null
                                      ? null
                                      : accountsByUuid[
                                          payments[i].accountUuid!],
                                ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
        FormSectionCard(
          title: l10n.relatedCosts,
          icon: Icons.outbound_outlined,
          accentColor: AppColors.expenseColor,
          trailing: TextButton.icon(
            onPressed: _busy ? null : () => _recordRelatedCost(order),
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.addRelatedCost),
          ),
          children: [
            Text(
              l10n.relatedCostHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            costsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text(l10n.errorOccurred(e.toString())),
              data: (costs) {
                if (costs.isEmpty) {
                  return Text(
                    l10n.noRelatedCosts,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < costs.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _PaymentTile(
                        payment: costs[i],
                        account: costs[i].accountUuid == null
                            ? null
                            : accountsByUuid[costs[i].accountUuid!],
                        accent: AppColors.expenseColor,
                        isSale: false,
                        dateFormat: dateFormat,
                        ref: ref,
                        onTap: _busy
                            ? null
                            : () => _deleteRelatedCost(order, costs[i]),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
        FormSectionCard(
          title: l10n.sectionActions,
          icon: Icons.bolt_outlined,
          accentColor: typeColor,
          children: [
            if (canPay)
              GradientButton(
                label: l10n.recordPayment,
                icon: Icons.payments_outlined,
                isLoading: _busy,
                width: double.infinity,
                gradient: AppColors.getPrimaryGradient(
                  isSale
                      ? AppColors.receivableColor
                      : AppColors.payableColor,
                ),
                onPressed:
                    _busy ? null : () => _recordPayment(order, balance),
              ),
            if (canDeliver)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: _busy ? null : () => _markDelivered(order),
                icon: const Icon(Icons.local_shipping_outlined),
                label: Text(
                  isSale ? l10n.deliverShipment : l10n.receiveShipment,
                ),
              ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _busy ? null : () => _shareInvoice(order, contact),
              icon: const Icon(Icons.share_outlined),
              label: Text(l10n.shareInvoice),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderHero extends StatelessWidget {
  final String typeLabel;
  final String orderNumber;
  final Color accent;
  final String amountText;
  final String paymentLabel;
  final String deliveryLabel;
  final bool showPendingSync;

  const _OrderHero({
    required this.typeLabel,
    required this.orderNumber,
    required this.accent,
    required this.amountText,
    required this.paymentLabel,
    required this.deliveryLabel,
    this.showPendingSync = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.getPrimaryGradient(accent),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                typeLabel,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                orderNumber,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                amountText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  _HeroPill(
                    icon: Icons.payments_outlined,
                    label: paymentLabel,
                  ),
                  _HeroPill(
                    icon: Icons.local_shipping_outlined,
                    label: deliveryLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showPendingSync)
          const PositionedDirectional(
            top: -6,
            end: -6,
            child: PendingSyncDetailBadge(),
          ),
      ],
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.chevron_right,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
      ],
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: row,
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final OrderItem item;
  final WidgetRef ref;
  final Color accent;
  final bool isSale;
  final SaleCatalogLineIssue catalogIssue;
  /// Captured once when detail loads; compared to open qty (not recalculated).
  final double? availableQuantity;

  const _ItemTile({
    required this.item,
    required this.ref,
    required this.accent,
    required this.isSale,
    this.catalogIssue = SaleCatalogLineIssue.none,
    this.availableQuantity,
  });

  String? _issueLabel(AppLocalizations l10n) {
    switch (catalogIssue) {
      case SaleCatalogLineIssue.catalogItemUnavailable:
        return l10n.saleLineCatalogItemUnavailable;
      case SaleCatalogLineIssue.catalogDeleted:
        return l10n.saleLineCatalogDeleted;
      case SaleCatalogLineIssue.catalogExpired:
        return l10n.saleLineCatalogExpired;
      case SaleCatalogLineIssue.none:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final issueLabel = _issueLabel(l10n);
    final catalogWarn = catalogIssue.isProblem;
    final openQty = isSale
        ? (item.quantity - item.deliveredQuantity)
            .clamp(0, double.infinity)
            .toDouble()
        : 0.0;
    final stockShort = isSale &&
        availableQuantity != null &&
        openQty > availableQuantity! + 1e-9;
    final warn = catalogWarn || stockShort;
    final catalogLabel = item.catalogNameSnapshot?.trim();
    final listUnit = item.unitPrice;
    final discountedUnit = orderItemDiscountedUnitPrice(
      listUnitPrice: listUnit,
      quantity: item.quantity,
      lineDiscountAmount: item.discountAmount,
      discountedUnitPrice: item.discountedUnitPrice,
    );
    final borderColor = warn
        ? AppColors.warning.withValues(alpha: 0.45)
        : accent.withValues(alpha: 0.2);
    final fillColor = warn
        ? AppColors.warning.withValues(alpha: 0.1)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);

    final products =
        ref.watch(productsStreamProvider).value ?? const <Product>[];
    final categories = ref.watch(productCategoriesStreamProvider).value ??
        const <ProductCategory>[];
    final sellingProducts =
        ref.watch(sellingProductsStreamProvider).value ??
            const <SellingProduct>[];
    final byCategory = {for (final c in categories) c.uuid: c};
    final productUuid = item.productUuid?.trim();
    final product = (productUuid == null || productUuid.isEmpty)
        ? null
        : products.where((p) => p.uuid == productUuid).firstOrNull;
    final spUuid = item.sellingProductUuid?.trim();
    final sellingProduct = (spUuid == null || spUuid.isEmpty)
        ? null
        : sellingProducts.where((s) => s.uuid == spUuid).firstOrNull;
    final categoryUuid = product?.categoryUuid ?? sellingProduct?.categoryUuid;
    final category =
        categoryUuid == null ? null : byCategory[categoryUuid];

    final Widget leading;
    if (warn) {
      leading = categoryLeadingAvatar(
        color: AppColors.warning,
        icon: Icons.warning_amber_rounded,
      );
    } else if (product != null) {
      leading = productLeadingAvatar(product: product, category: category);
    } else {
      leading = categoryLeadingAvatar(
        color: parseCategoryColor(category?.color, accent),
        icon: category == null
            ? (isSale ? Icons.sell_outlined : Icons.inventory_2_outlined)
            : categoryIconData(category),
      );
    }

    VoidCallback? openLinkedEntity;
    if (product != null) {
      openLinkedEntity = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailsScreen(productUuid: product.uuid),
          ),
        );
      };
    } else if (sellingProduct != null) {
      openLinkedEntity = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddSellingProductScreen(
              existingUuid: sellingProduct.uuid,
            ),
          ),
        );
      };
    }

    final identity = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leading,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      item.productNameSnapshot,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (openLinkedEntity != null)
                    Icon(Icons.chevron_right, size: 18, color: muted),
                ],
              ),
              if ((isSale &&
                      catalogLabel != null &&
                      catalogLabel.isNotEmpty) ||
                  issueLabel != null) ...[
                const SizedBox(height: 1),
                Text.rich(
                  TextSpan(
                    children: [
                      if (isSale &&
                          catalogLabel != null &&
                          catalogLabel.isNotEmpty)
                        TextSpan(
                          text: catalogLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (isSale &&
                          catalogLabel != null &&
                          catalogLabel.isNotEmpty &&
                          issueLabel != null)
                        TextSpan(
                          text: ' · ',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: muted),
                        ),
                      if (issueLabel != null)
                        TextSpan(
                          text: issueLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 2),
              Text(
                isSale
                    ? l10n.deliveredQtyProgress(
                        AmountFormatter.formatQuantity(item.deliveredQuantity),
                        AmountFormatter.formatQuantity(item.quantity),
                      )
                    : l10n.receivedQtyProgress(
                        AmountFormatter.formatQuantity(item.receivedQuantity),
                        AmountFormatter.formatQuantity(item.quantity),
                      ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (stockShort && availableQuantity != null) ...[
                const SizedBox(height: 2),
                Text(
                  l10n.orderLineStockShort(
                    AmountFormatter.formatQuantity(availableQuantity!),
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: openLinkedEntity == null
                ? identity
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: openLinkedEntity,
                      borderRadius: BorderRadius.circular(10),
                      child: identity,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          OrderLinePriceStack(
            listUnitPrice: listUnit,
            discountedUnitPrice: discountedUnit,
            quantity: item.quantity,
            accent: accent,
            ref: ref,
          ),
        ],
      ),
    );
  }
}

class _ShipmentTile extends StatelessWidget {
  final OrderShipmentView shipment;
  final Color accent;
  final bool isSale;
  final String dateFormat;
  final WidgetRef ref;

  const _ShipmentTile({
    required this.shipment,
    required this.accent,
    required this.isSale,
    required this.dateFormat,
    required this.ref,
  });

  void _openDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final dateText = AppDateFormatter.formatDate(
      shipment.at,
      pattern: dateFormat,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isSale ? l10n.deliveryDetails : l10n.receiptDetails,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                ),
                if (shipment.notes != null &&
                    shipment.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    shipment.notes!.trim(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                if (!isSale &&
                    (shipment.freightAmount > 0 ||
                        shipment.dutyAmount > 0)) ...[
                  const SizedBox(height: 10),
                  if (shipment.freightAmount > 0)
                    _AmountRow(
                      label: l10n.inboundFreight,
                      value: shipment.freightAmount,
                      ref: ref,
                      muted: true,
                    ),
                  if (shipment.dutyAmount > 0)
                    _AmountRow(
                      label: l10n.importDuty,
                      value: shipment.dutyAmount,
                      ref: ref,
                      muted: true,
                    ),
                ],
                const SizedBox(height: 12),
                Text(
                  l10n.items,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                if (shipment.lines.isEmpty)
                  Text(
                    l10n.noProductsYet,
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  )
                else
                  for (var i = 0; i < shipment.lines.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              shipment.lines[i].productName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            [
                              AmountFormatter.formatQuantity(
                                shipment.lines[i].quantity,
                              ),
                              if (shipment.lines[i].unit.trim().isNotEmpty)
                                shipment.lines[i].unit,
                            ].join(' '),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final muted = theme.colorScheme.onSurfaceVariant;
    final dateText = AppDateFormatter.formatDate(
      shipment.at,
      pattern: dateFormat,
    );
    final qtyText = AmountFormatter.formatQuantity(shipment.totalQuantity);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(
                isSale
                    ? Icons.local_shipping_outlined
                    : Icons.move_to_inbox_outlined,
                size: 18,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateText,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.shipmentLineCount(
                        shipment.lines.length.toString(),
                        qtyText,
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final Transaction payment;
  final Account? account;
  final Color accent;
  final bool isSale;
  final String dateFormat;
  final WidgetRef ref;
  final VoidCallback? onTap;

  const _PaymentTile({
    required this.payment,
    required this.account,
    required this.accent,
    required this.isSale,
    required this.dateFormat,
    required this.ref,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final muted = theme.colorScheme.onSurfaceVariant;
    final isDark = theme.brightness == Brightness.dark;
    final amountColor =
        isSale ? AppColors.incomeColor : AppColors.expenseColor;
    final desc = payment.description?.trim();
    final title = (desc != null && desc.isNotEmpty)
        ? desc
        : (isSale ? l10n.collectPayment : l10n.payToSupplier);
    final dateText = AppDateFormatter.formatDate(
      payment.date,
      pattern: dateFormat,
    );
    final amountText =
        '${isSale ? '\u200E+' : '\u200E-'} ${formatOrderAmount(ref, payment.amount)}';
    final amountFontSize =
        AmountFormatter.getFontSize(payment.amount).clamp(14.0, 22.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            hoverColor: Colors.transparent,
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: amountColor.withValues(alpha: isDark ? 0.2 : 0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: amountColor.withValues(alpha: isDark ? 0.05 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: amountColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: amountColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          isSale
                              ? Icons.call_received_rounded
                              : Icons.call_made_rounded,
                          color: amountColor,
                          size: 22,
                        ),
                      ),
                      if (payment.isNotSynced == true)
                        const Positioned(
                          right: -3,
                          bottom: -3,
                          child: PendingSyncCornerBadge(iconSize: 11),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    amountText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                      fontSize: amountFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (account != null)
          PositionedDirectional(
            end: -6,
            bottom: -5,
            child: Tooltip(
              message: account!.name,
              child: CornerBadgeContainer(
                accentColor: TransferAccountBox.accentColorFor(account!, theme),
                padding: const EdgeInsets.all(4),
                child: Icon(
                  TransferAccountBox.iconForAccount(account),
                  size: 11,
                  color: TransferAccountBox.accentColorFor(account!, theme),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double value;
  final WidgetRef ref;
  final Color? color;
  final bool bold;
  final bool muted;
  final String? valueSuffix;

  const _AmountRow({
    required this.label,
    required this.value,
    required this.ref,
    this.color,
    this.bold = false,
    this.muted = false,
    this.valueSuffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = (muted
            ? theme.textTheme.bodyMedium
            : theme.textTheme.bodyLarge)
        ?.copyWith(
      color: color ??
          (muted ? theme.colorScheme.onSurfaceVariant : null),
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    final suffix = valueSuffix?.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (suffix != null && suffix.isNotEmpty) ...[
                Text(
                  suffix,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(formatOrderAmount(ref, value), style: style),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SheetMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SheetActionTile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color == AppColors.error
                              ? AppColors.error
                              : null,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentResult {
  final double amount;
  final String accountUuid;
  final DateTime date;
  final String? description;

  const _PaymentResult(
    this.amount,
    this.accountUuid,
    this.date,
    this.description,
  );
}

class _PaymentDialog extends ConsumerStatefulWidget {
  final String title;
  final double initialAmount;
  final double maxAmount;
  final String? initialAccountUuid;
  final DateTime? initialDate;
  final String? initialDescription;

  const _PaymentDialog({
    required this.title,
    required this.initialAmount,
    required this.maxAmount,
    this.initialAccountUuid,
    this.initialDate,
    this.initialDescription,
  });

  @override
  ConsumerState<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<_PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  String? _accountUuid;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: AmountFormatter.formatQuantity(widget.initialAmount),
    );
    _descriptionController = TextEditingController(
      text: widget.initialDescription?.trim() ?? '',
    );
    _accountUuid = widget.initialAccountUuid;
    _date = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_accountUuid == null) return;
    final desc = _descriptionController.text.trim();
    Navigator.pop(
      context,
      _PaymentResult(
        double.parse(_amountController.text.trim()),
        _accountUuid!,
        _date,
        desc.isEmpty ? null : desc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accounts = ref.watch(accountsStreamProvider).value ?? const <Account>[];
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final affix = AmountFormatter.currencyAffix(
      ref.watch(currencySymbolProvider),
      isRtl: isRtl,
    );
    final maxLabel = formatOrderAmount(ref, widget.maxAmount);

    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LtrNumberField(
                controller: _amountController,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: ltrDecimalInputFormatters,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  prefixText: affix.prefixText,
                  suffixText: affix.suffixText,
                  helperText: l10n.paymentExceedsBalance(maxLabel),
                ),
                validator: (value) {
                  final number = double.tryParse(value?.trim() ?? '');
                  if (number == null || number <= 0) {
                    return l10n.amountGreaterThanZero;
                  }
                  if (number > widget.maxAmount + 0.001) {
                    return l10n.paymentExceedsBalance(maxLabel);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AccountPickerField(
                selectedAccount: accounts
                    .where((a) => a.uuid == _accountUuid)
                    .firstOrNull,
                label: l10n.selectAccount,
                onChanged: (account) =>
                    setState(() => _accountUuid = account?.uuid),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(l10n.date),
                subtitle: Text(
                  AppDateFormatter.formatDate(_date, pattern: dateFormat),
                ),
                trailing: const Icon(Icons.edit_outlined, size: 18),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  alignLabelWithHint: true,
                  hintText: l10n.notesLabel,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}

class _ShipmentQtyResult {
  final List<({String orderItemUuid, double quantity})> lines;
  final double freight;
  final double duty;

  const _ShipmentQtyResult({
    required this.lines,
    this.freight = 0,
    this.duty = 0,
  });
}

class _ShipmentQtySheet extends ConsumerStatefulWidget {
  final Order order;
  final List<OrderItem> items;
  /// Resolved once when the sheet opens; compared to deliver qty edits.
  final Map<String, double?> availableByItem;

  const _ShipmentQtySheet({
    required this.order,
    required this.items,
    this.availableByItem = const {},
  });

  @override
  ConsumerState<_ShipmentQtySheet> createState() => _ShipmentQtySheetState();
}

class _ShipmentQtySheetState extends ConsumerState<_ShipmentQtySheet> {
  late final Map<String, TextEditingController> _qtyByItem;
  final _freight = TextEditingController();
  final _duty = TextEditingController();

  bool get _isSale => widget.order.orderType == orderTypeSale;

  @override
  void initState() {
    super.initState();
    _qtyByItem = {};
    for (final item in widget.items) {
      final done =
          _isSale ? item.deliveredQuantity : item.receivedQuantity;
      final open =
          (item.quantity - done).clamp(0, double.infinity).toDouble();
      if (open <= 1e-9) continue;
      // Purchases skip non-product lines in receive; sales include all open.
      if (!_isSale &&
          (item.productUuid == null || item.productUuid!.trim().isEmpty)) {
        continue;
      }
      _qtyByItem[item.uuid] = TextEditingController(
        text: AmountFormatter.formatQuantity(open),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _qtyByItem.values) {
      c.dispose();
    }
    _freight.dispose();
    _duty.dispose();
    super.dispose();
  }

  double _openQty(OrderItem item) {
    final done = _isSale ? item.deliveredQuantity : item.receivedQuantity;
    return (item.quantity - done).clamp(0, double.infinity).toDouble();
  }

  void _setQty(String itemUuid, double qty, double open) {
    final clamped = qty.clamp(0, open).toDouble();
    _qtyByItem[itemUuid]?.text = clamped <= 0
        ? ''
        : AmountFormatter.formatQuantity(clamped);
    setState(() {});
  }

  void _nudgeQty(String itemUuid, double delta, double open) {
    final current =
        double.tryParse(_qtyByItem[itemUuid]?.text.trim() ?? '') ?? 0;
    _setQty(itemUuid, current + delta, open);
  }

  void _submit() {
    final lines = <({String orderItemUuid, double quantity})>[];
    for (final entry in _qtyByItem.entries) {
      final qty = double.tryParse(entry.value.text.trim()) ?? 0;
      if (qty > 1e-9) {
        lines.add((orderItemUuid: entry.key, quantity: qty));
      }
    }
    if (lines.isEmpty) return;
    Navigator.pop(
      context,
      _ShipmentQtyResult(
        lines: lines,
        freight: double.tryParse(_freight.text.trim()) ?? 0,
        duty: double.tryParse(_duty.text.trim()) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final affix = AmountFormatter.currencyAffix(
      ref.watch(currencySymbolProvider),
      isRtl: isRtl,
    );
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final byId = {for (final i in widget.items) i.uuid: i};

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isSale ? l10n.deliverShipment : l10n.receiveShipment,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (_qtyByItem.isEmpty)
                Text(
                  l10n.deliveryPending,
                  style: theme.textTheme.bodyMedium,
                )
              else
                for (final entry in _qtyByItem.entries) ...[
                  Builder(
                    builder: (context) {
                      final item = byId[entry.key]!;
                      final done = _isSale
                          ? item.deliveredQuantity
                          : item.receivedQuantity;
                      final open = _openQty(item);
                      final qty =
                          double.tryParse(entry.value.text.trim()) ?? 0;
                      final available = widget.availableByItem[item.uuid];
                      final stockShort = _isSale &&
                          available != null &&
                          qty > available + 1e-9;
                      final accent = orderTypeColor(widget.order.orderType);
                      final outlineColor = stockShort
                          ? AppColors.warning.withValues(alpha: 0.45)
                          : accent.withValues(alpha: 0.22);
                      final fillColor = stockShort
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                          decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: outlineColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productNameSnapshot,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _isSale
                                              ? l10n.deliveredQtyProgress(
                                                  AmountFormatter
                                                      .formatQuantity(done),
                                                  AmountFormatter
                                                      .formatQuantity(
                                                          item.quantity),
                                                )
                                              : l10n.receivedQtyProgress(
                                                  AmountFormatter
                                                      .formatQuantity(done),
                                                  AmountFormatter
                                                      .formatQuantity(
                                                          item.quantity),
                                                ),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: muted,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface
                                          .withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.dividerColor
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: qty <= 0
                                              ? null
                                              : () => _nudgeQty(
                                                    item.uuid,
                                                    -1,
                                                    open,
                                                  ),
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                            minHeight: 40,
                                          ),
                                          icon: const Icon(Icons.remove,
                                              size: 18),
                                        ),
                                        SizedBox(
                                          width: 56,
                                          child: LtrNumberField(
                                            controller: entry.value,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              filled: false,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8,
                                              ),
                                              hintText: '0',
                                            ),
                                            onChanged: (value) {
                                              final parsed = double.tryParse(
                                                  value.trim());
                                              if (parsed == null) {
                                                setState(() {});
                                                return;
                                              }
                                              if (parsed > open + 1e-9) {
                                                _setQty(item.uuid, open, open);
                                              } else {
                                                setState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: qty + 1e-9 >= open
                                              ? null
                                              : () => _nudgeQty(
                                                    item.uuid,
                                                    1,
                                                    open,
                                                  ),
                                          visualDensity: VisualDensity.compact,
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                            minHeight: 40,
                                          ),
                                          icon:
                                              const Icon(Icons.add, size: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    '${AmountFormatter.formatQuantity(open)} ${item.unit}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: muted,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: qty + 1e-9 >= open
                                        ? null
                                        : () =>
                                            _setQty(item.uuid, open, open),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(l10n.fillOpenQuantity),
                                  ),
                                ],
                              ),
                              if (stockShort)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    l10n.orderLineStockShort(
                                      AmountFormatter.formatQuantity(
                                          available!),
                                    ),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              if (!_isSale && _qtyByItem.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.landedCostHint,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                LtrNumberField(
                  controller: _freight,
                  decoration: InputDecoration(
                    labelText: l10n.inboundFreight,
                    prefixText: affix.prefixText,
                    suffixText: affix.suffixText,
                    filled: true,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                LtrNumberField(
                  controller: _duty,
                  decoration: InputDecoration(
                    labelText: l10n.importDuty,
                    prefixText: affix.prefixText,
                    suffixText: affix.suffixText,
                    filled: true,
                    isDense: true,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _qtyByItem.isEmpty ? null : _submit,
                      child: Text(
                        _isSale
                            ? l10n.deliverShipment
                            : l10n.receiveShipment,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostResult {
  final double amount;
  final String accountUuid;
  final DateTime date;
  final String? description;

  const _CostResult(
    this.amount,
    this.accountUuid,
    this.date,
    this.description,
  );
}

class _CostDialog extends ConsumerStatefulWidget {
  const _CostDialog();

  @override
  ConsumerState<_CostDialog> createState() => _CostDialogState();
}

class _CostDialogState extends ConsumerState<_CostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _accountUuid;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_accountUuid == null) return;
    final desc = _descriptionController.text.trim();
    Navigator.pop(
      context,
      _CostResult(
        double.parse(_amountController.text.trim()),
        _accountUuid!,
        _date,
        desc.isEmpty ? null : desc,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accounts =
        ref.watch(accountsStreamProvider).value ?? const <Account>[];
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final affix = AmountFormatter.currencyAffix(
      ref.watch(currencySymbolProvider),
      isRtl: isRtl,
    );

    return AlertDialog(
      title: Text(l10n.addRelatedCost),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.relatedCostHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              LtrNumberField(
                controller: _amountController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  prefixText: affix.prefixText,
                  suffixText: affix.suffixText,
                ),
                validator: (value) {
                  final number = double.tryParse(value?.trim() ?? '');
                  if (number == null || number <= 0) {
                    return l10n.amountGreaterThanZero;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.chargeDescription,
                ),
              ),
              const SizedBox(height: 12),
              AccountPickerField(
                selectedAccount: accounts
                    .where((a) => a.uuid == _accountUuid)
                    .firstOrNull,
                label: l10n.selectAccount,
                onChanged: (account) =>
                    setState(() => _accountUuid = account?.uuid),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(l10n.date),
                subtitle: Text(
                  AppDateFormatter.formatDate(_date, pattern: dateFormat),
                ),
                onTap: _pickDate,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
