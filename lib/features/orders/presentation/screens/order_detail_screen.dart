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
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/orders/presentation/providers/orders_provider.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';

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
  }

  Future<void> _recordPayment(Order order, double balance) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<_PaymentResult>(
      context: context,
      builder: (context) => _PaymentDialog(initialAmount: balance),
    );
    if (result == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(ordersRepositoryProvider).recordOrderPayment(
            orderUuid: order.uuid,
            amount: result.amount,
            accountUuid: result.accountUuid,
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

  Future<void> _markDelivered(Order order) async {
    final l10n = AppLocalizations.of(context)!;
    var freight = 0.0;
    var duty = 0.0;
    if (order.orderType == orderTypePurchase) {
      final landed = await showDialog<_LandedCostResult>(
        context: context,
        builder: (context) => const _LandedCostDialog(),
      );
      if (landed == null || !mounted) return;
      freight = landed.freight;
      duty = landed.duty;
    }

    setState(() => _busy = true);
    try {
      await ref.read(ordersRepositoryProvider).markDelivered(
            order.uuid,
            freightAmount: freight,
            dutyAmount: duty,
          );
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
    final paid = ref.watch(orderPaidAmountProvider(order.uuid)).value ?? 0.0;
    final balance =
        (order.totalAmount - paid).clamp(0, double.infinity).toDouble();

    final canPay = order.paymentStatus != 'PAID' && balance > 0;
    final canDeliver = order.deliveryStatus != 'DELIVERED' &&
        order.deliveryStatus != 'CANCELLED';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        FormSectionCard(
          title: order.orderNumber,
          icon: isSale
              ? Icons.point_of_sale_rounded
              : Icons.shopping_cart_outlined,
          accentColor: typeColor,
          trailing: OrderStatusChip(
            label: isSale ? l10n.sale : l10n.purchase,
            color: typeColor,
          ),
          children: [
            _InfoRow(
              icon: Icons.person_outline,
              text: contact?.name ?? l10n.walkInCustomer,
            ),
            _InfoRow(
              icon: Icons.event_outlined,
              text: AppDateFormatter.formatDate(
                order.orderDate,
                pattern: dateFormat,
              ),
            ),
            if (order.notes != null && order.notes!.isNotEmpty)
              _InfoRow(icon: Icons.notes_outlined, text: order.notes!),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                      if (i > 0) const Divider(height: 16),
                      _ItemTile(item: items[i], ref: ref),
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
                label: Text(l10n.markDelivered),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final OrderItem item;
  final WidgetRef ref;

  const _ItemTile({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineTotal = item.quantity * item.unitPrice - item.discountAmount;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productNameSnapshot,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${AmountFormatter.formatQuantity(item.quantity)} ${item.unit} × '
                '${formatOrderAmount(ref, item.unitPrice)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          formatOrderAmount(ref, lineTotal),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
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

  const _AmountRow({
    required this.label,
    required this.value,
    required this.ref,
    this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: bold ? FontWeight.w700 : null,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(formatOrderAmount(ref, value), style: style),
        ],
      ),
    );
  }
}

class _PaymentResult {
  final double amount;
  final String accountUuid;

  const _PaymentResult(this.amount, this.accountUuid);
}

class _PaymentDialog extends ConsumerStatefulWidget {
  final double initialAmount;

  const _PaymentDialog({required this.initialAmount});

  @override
  ConsumerState<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<_PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  String? _accountUuid;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: AmountFormatter.formatQuantity(widget.initialAmount),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_accountUuid == null) return;
    Navigator.pop(
      context,
      _PaymentResult(
        double.parse(_amountController.text.trim()),
        _accountUuid!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accounts = ref.watch(accountsStreamProvider).value ?? const <Account>[];
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final affix = AmountFormatter.currencyAffix(
      ref.watch(currencySymbolProvider),
      isRtl: isRtl,
    );

    return AlertDialog(
      title: Text(l10n.recordPayment),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
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
            AccountPickerField(
              selectedAccount: accounts
                  .where((a) => a.uuid == _accountUuid)
                  .firstOrNull,
              label: l10n.selectAccount,
              onChanged: (account) =>
                  setState(() => _accountUuid = account?.uuid),
            ),
          ],
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

class _LandedCostResult {
  final double freight;
  final double duty;

  const _LandedCostResult(this.freight, this.duty);
}

class _LandedCostDialog extends ConsumerStatefulWidget {
  const _LandedCostDialog();

  @override
  ConsumerState<_LandedCostDialog> createState() => _LandedCostDialogState();
}

class _LandedCostDialogState extends ConsumerState<_LandedCostDialog> {
  final _freight = TextEditingController();
  final _duty = TextEditingController();

  @override
  void dispose() {
    _freight.dispose();
    _duty.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      _LandedCostResult(
        double.tryParse(_freight.text.trim()) ?? 0,
        double.tryParse(_duty.text.trim()) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final affix = AmountFormatter.currencyAffix(
      ref.watch(currencySymbolProvider),
      isRtl: isRtl,
    );
    return AlertDialog(
      title: Text(l10n.receiveShipment),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.landedCostHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _freight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              labelText: l10n.inboundFreight,
              prefixText: affix.prefixText,
              suffixText: affix.suffixText,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _duty,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              labelText: l10n.importDuty,
              prefixText: affix.prefixText,
              suffixText: affix.suffixText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.markDelivered)),
      ],
    );
  }
}
