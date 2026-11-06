import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_picker.dart';
import 'package:flowpaisa/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/orders/presentation/providers/orders_provider.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_entity_pickers.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_widgets.dart';
import 'package:flowpaisa/features/premium/domain/premium_gate.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/entity_picker_sheet.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';

class _OrderLine {
  final Product product;
  final TextEditingController quantity;
  final TextEditingController unitPrice;
  final TextEditingController discount;
  /// Service sale COGS; stamped to [OrderItem.purchasePriceSnapshot].
  final TextEditingController unitCost;

  _OrderLine({
    required this.product,
    required double price,
    double? defaultUnitCost,
  })  : quantity = TextEditingController(text: '1'),
        unitPrice = TextEditingController(text: _plain(price)),
        discount = TextEditingController(text: '0'),
        unitCost = TextEditingController(
          text: _plain(defaultUnitCost ?? product.purchasePrice),
        );

  double get quantityValue => _parse(quantity);
  double get unitPriceValue => _parse(unitPrice);
  double get discountValue => _parse(discount);
  double get unitCostValue => _parse(unitCost);
  double get gross => quantityValue * unitPriceValue;
  double get lineTotal => (gross - discountValue).clamp(0, double.infinity);

  void dispose() {
    quantity.dispose();
    unitPrice.dispose();
    discount.dispose();
    unitCost.dispose();
  }

  static String _plain(double value) => AmountFormatter.formatQuantity(value);
}

double _parse(TextEditingController controller) =>
    double.tryParse(controller.text.trim()) ?? 0;

class AddOrderScreen extends ConsumerStatefulWidget {
  final String orderType;

  const AddOrderScreen({super.key, required this.orderType});

  @override
  ConsumerState<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends ConsumerState<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _paymentController = TextEditingController();
  final List<_OrderLine> _lines = [];

  String? _contactUuid;
  String? _accountUuid;
  bool _showAllContacts = false;
  bool _delivered = false;
  bool _saving = false;
  DateTime _orderDate = DateTime.now();

  bool get _isSale => widget.orderType == orderTypeSale;
  Color get _color => orderTypeColor(widget.orderType);

  double get _subtotal => _lines.fold<double>(0, (sum, l) => sum + l.gross);
  double get _discountTotal =>
      _lines.fold<double>(0, (sum, l) => sum + l.discountValue);
  double get _total =>
      (_subtotal - _discountTotal).clamp(0, double.infinity).toDouble();

  @override
  void dispose() {
    _notesController.dispose();
    _paymentController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  Future<void> _pickProduct() async {
    final result = await showOrderProductPicker(context: context, ref: ref);
    final product = result?.value;
    if (product == null || !mounted) return;

    final existing =
        _lines.where((l) => l.product.uuid == product.uuid).firstOrNull;
    setState(() {
      if (existing != null) {
        existing.quantity.text =
            AmountFormatter.formatQuantity(existing.quantityValue + 1);
      } else {
        _lines.add(_OrderLine(
          product: product,
          price: _isSale ? product.retailPrice : product.purchasePrice,
          defaultUnitCost: product.purchasePrice,
        ));
      }
    });
  }

  Future<void> _pickContact() async {
    final contacts = ref.read(contactsListProvider).value ?? const <Contact>[];
    final selected =
        contacts.where((c) => c.uuid == _contactUuid).firstOrNull;
    final result = await showOrderContactPicker(
      context: context,
      ref: ref,
      isSale: _isSale,
      selected: selected,
      showAll: _showAllContacts,
    );
    if (result == null || !mounted) return;
    setState(() => _contactUuid = result.value?.uuid);
  }

  void _removeLine(int index) {
    final line = _lines[index];
    setState(() => _lines.removeAt(index));
    WidgetsBinding.instance.addPostFrameCallback((_) => line.dispose());
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _orderDate = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_lines.isEmpty) {
      ToastUtils.showErrorToast(context, ref, l10n.addAtLeastOneItem);
      return;
    }

    final total = _total;
    final payment = _parse(_paymentController).clamp(0, total).toDouble();
    if (payment > 0 && _accountUuid == null) {
      ToastUtils.showErrorToast(context, ref, l10n.selectAccountForPayment);
      return;
    }

    final isPremium = PremiumGate.isPremium(ref);
    if (_isSale && !isPremium) {
      final limits = await ref.read(receivableLimitsProvider.future);
      if (!mounted) return;
      if (!limits.canAdd) {
        PremiumGate.showPremiumDialog(context);
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final repository = ref.read(ordersRepositoryProvider);
      final orderUuid = const Uuid().v4();
      final orderNumber = await repository.nextOrderNumber(widget.orderType);
      final notes = _notesController.text.trim();
      final paymentStatus = payment <= 0
          ? 'UNPAID'
          : payment + 0.001 >= total
              ? 'PAID'
              : 'PARTIALLY_PAID';

      final order = OrdersCompanion.insert(
        uuid: orderUuid,
        orderNumber: orderNumber,
        orderType: widget.orderType,
        orderDate: _orderDate,
        subtotal: _subtotal,
        totalAmount: total,
        contactUuid: drift.Value(_contactUuid),
        discountAmount: drift.Value(_discountTotal),
        paymentStatus: drift.Value(paymentStatus),
        deliveryStatus: drift.Value(_delivered ? 'DELIVERED' : 'PENDING'),
        deliveredDate: drift.Value(_delivered ? DateTime.now() : null),
        notes: drift.Value(notes.isEmpty ? null : notes),
      );

      final items = _lines
          .map((line) => OrderItemsCompanion.insert(
                uuid: const Uuid().v4(),
                orderUuid: orderUuid,
                productUuid: line.product.uuid,
                productNameSnapshot: line.product.name,
                quantity: line.quantityValue,
                unitPrice: line.unitPriceValue,
                discountAmount: drift.Value(line.discountValue),
                // Services: freeze line COGS. Goods: FEFO overwrites on deliver.
                purchasePriceSnapshot: drift.Value(
                  line.product.isService
                      ? line.unitCostValue
                      : line.product.purchasePrice,
                ),
                unit: drift.Value(line.product.unit),
              ))
          .toList();

      await repository.createOrder(
        order: order,
        items: items,
        paymentAmount: payment,
        accountUuid: payment > 0 ? _accountUuid : null,
      );

      if (_isSale && !isPremium) {
        await ref
            .read(usageTrackerRepositoryProvider)
            .incrementReceivableCount();
      }
      if (_isSale) ref.invalidate(receivableLimitsProvider);

      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.orderCreated);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ToastUtils.showErrorToast(context, ref, l10n.errorOccurred(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final contacts = ref.watch(contactsListProvider).value ?? const <Contact>[];
    final accounts =
        ref.watch(accountsStreamProvider).value ?? const <Account>[];
    final categories = ref.watch(productCategoriesStreamProvider).value ??
        const <ProductCategory>[];
    final categoryById = {for (final c in categories) c.uuid: c};

    final selectedContact =
        contacts.where((c) => c.uuid == _contactUuid).firstOrNull;
    final selectedAccount =
        accounts.where((a) => a.uuid == _accountUuid).firstOrNull;

    final total = _total;
    final payment = _parse(_paymentController).clamp(0, total).toDouble();

    return FormPageScaffold(
      accentColor: _color,
      appBar: AppBar(
        title: Text(_isSale ? l10n.newSale : l10n.newPurchase),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomBar: FormBottomBar(
        child: GradientButton(
          label: l10n.save,
          icon: Icons.check_rounded,
          isLoading: _saving,
          width: double.infinity,
          gradient: AppColors.getPrimaryGradient(_color),
          onPressed: _saving ? null : _save,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            FormSectionCard(
              title: l10n.sectionDetails,
              icon: Icons.person_outline_rounded,
              accentColor: _color,
              children: [
                EntityPickerField(
                  label: _isSale ? l10n.customer : l10n.supplier,
                  valueText: selectedContact?.name ?? l10n.walkInCustomer,
                  valueSubtitle: selectedContact?.phone,
                  accentColor: selectedContact == null
                      ? null
                      : AppColors.getContactColor(selectedContact.name),
                  leading: selectedContact == null
                      ? null
                      : contactLeadingAvatar(selectedContact.name, radius: 18),
                  placeholderIcon: Icons.person_outline,
                  onClear: selectedContact == null
                      ? null
                      : () => setState(() => _contactUuid = null),
                  onTap: _pickContact,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(l10n.showAllContacts),
                  value: _showAllContacts,
                  onChanged: (value) =>
                      setState(() => _showAllContacts = value),
                ),
                Material(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.event_outlined,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.date,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          Text(
                            AppDateFormatter.formatDate(
                              _orderDate,
                              pattern: dateFormat,
                            ),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right,
                              color: theme.colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            FormSectionCard(
              title: l10n.items,
              icon: Icons.shopping_bag_outlined,
              accentColor: _color,
              trailing: TextButton.icon(
                onPressed: _pickProduct,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.addItem),
              ),
              children: [
                if (_lines.isEmpty)
                  _EmptyItemsHint(onAdd: _pickProduct, color: _color)
                else
                  for (var i = 0; i < _lines.length; i++)
                    _OrderLineCard(
                      key: ObjectKey(_lines[i]),
                      line: _lines[i],
                      color: _color,
                      category: _lines[i].product.categoryUuid == null
                          ? null
                          : categoryById[_lines[i].product.categoryUuid],
                      amountLabel: formatOrderAmount(ref, _lines[i].lineTotal),
                      showUnitCost: _isSale && _lines[i].product.isService,
                      onChanged: () => setState(() {}),
                      onRemove: () => _removeLine(i),
                    ),
              ],
            ),
            FormSectionCard(
              title: l10n.sectionSummary,
              icon: Icons.receipt_long_outlined,
              accentColor: _color,
              children: [
                _SummaryRow(label: l10n.subtotal, value: _subtotal, ref: ref),
                if (_discountTotal > 0)
                  _SummaryRow(
                    label: l10n.discount,
                    value: -_discountTotal,
                    ref: ref,
                  ),
                const Divider(height: 8),
                _SummaryRow(
                  label: l10n.totalAmount,
                  value: total,
                  ref: ref,
                  color: _color,
                  bold: true,
                ),
              ],
            ),
            FormSectionCard(
              title: l10n.sectionPayment,
              icon: Icons.payments_outlined,
              accentColor: _isSale
                  ? AppColors.receivableColor
                  : AppColors.payableColor,
              children: [
                Builder(
                  builder: (context) {
                    final isRtl =
                        Directionality.of(context) == TextDirection.rtl;
                    final affix = AmountFormatter.currencyAffix(
                      ref.watch(currencySymbolProvider),
                      isRtl: isRtl,
                    );
                    return TextFormField(
                      controller: _paymentController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: _decimalFormatters,
                      decoration: InputDecoration(
                        labelText: l10n.paymentNow,
                        prefixIcon: const Icon(Icons.payments_outlined),
                        prefixText: affix.prefixText,
                        suffixText: affix.suffixText,
                        filled: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    );
                  },
                ),
                if (payment > 0)
                  AccountPickerField(
                    selectedAccount: selectedAccount,
                    label: l10n.selectAccount,
                    onChanged: (account) =>
                        setState(() => _accountUuid = account?.uuid),
                  ),
                if (total - payment > 0)
                  _SummaryRow(
                    label: l10n.balanceDue,
                    value: total - payment,
                    ref: ref,
                    color: _isSale
                        ? AppColors.receivableColor
                        : AppColors.payableColor,
                    bold: true,
                  ),
              ],
            ),
            FormSectionCard(
              title: l10n.sectionDelivery,
              icon: Icons.local_shipping_outlined,
              accentColor: _color,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.markDelivered),
                  subtitle: Text(
                    _delivered ? l10n.delivered : l10n.deliveryPending,
                  ),
                  value: _delivered,
                  activeThumbColor: _color,
                  onChanged: (value) => setState(() => _delivered = value),
                ),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.notesLabel,
                    prefixIcon: const Icon(Icons.notes_outlined),
                    filled: true,
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final _decimalFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
];

class _EmptyItemsHint extends StatelessWidget {
  final VoidCallback onAdd;
  final Color color;

  const _EmptyItemsHint({required this.onAdd, required this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            style: BorderStyle.solid,
          ),
          color: color.withValues(alpha: 0.04),
        ),
        child: Column(
          children: [
            Icon(Icons.add_shopping_cart_outlined, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              l10n.addItem,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.noProductsYet,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderLineCard extends ConsumerWidget {
  final _OrderLine line;
  final Color color;
  final ProductCategory? category;
  final String amountLabel;
  final bool showUnitCost;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _OrderLineCard({
    super.key,
    required this.line,
    required this.color,
    required this.amountLabel,
    required this.onChanged,
    required this.onRemove,
    this.category,
    this.showUnitCost = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final currencyAffix = AmountFormatter.currencyAffix(
      ref.watch(currencySymbolProvider),
      isRtl: isRtl,
    );

    String? positive(String? value) {
      final number = double.tryParse(value?.trim() ?? '');
      if (number == null) return l10n.invalidNumber;
      return number > 0 ? null : l10n.amountGreaterThanZero;
    }

    String? nonNegative(String? value) {
      final number = double.tryParse(value?.trim() ?? '');
      return number == null || number < 0 ? l10n.invalidNumber : null;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              productLeadingAvatar(
                product: line.product,
                category: category,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      [
                        if (category != null) category!.name,
                        amountLabel,
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: l10n.delete,
                icon: Icon(Icons.close_rounded,
                    color: theme.colorScheme.onSurfaceVariant),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: line.quantity,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: _decimalFormatters,
                  decoration: InputDecoration(
                    labelText: l10n.quantity,
                    suffixText: line.product.unit,
                    filled: true,
                    isDense: true,
                  ),
                  validator: positive,
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: TextFormField(
                  controller: line.unitPrice,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: _decimalFormatters,
                  decoration: InputDecoration(
                    labelText: l10n.unitPrice,
                    prefixText: currencyAffix.prefixText,
                    suffixText: currencyAffix.suffixText,
                    filled: true,
                    isDense: true,
                  ),
                  validator: nonNegative,
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: line.discount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: _decimalFormatters,
                  decoration: InputDecoration(
                    labelText: l10n.discount,
                    prefixText: currencyAffix.prefixText,
                    suffixText: currencyAffix.suffixText,
                    filled: true,
                    isDense: true,
                  ),
                  validator: (value) {
                    final error = nonNegative(value);
                    if (error != null) return error;
                    return _parse(line.discount) > line.gross
                        ? l10n.invalidNumber
                        : null;
                  },
                  onChanged: (_) => onChanged(),
                ),
              ),
            ],
          ),
          if (showUnitCost) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: line.unitCost,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _decimalFormatters,
              decoration: InputDecoration(
                labelText: l10n.lineUnitCost,
                helperText: l10n.serviceUnitCostHint,
                prefixText: currencyAffix.prefixText,
                suffixText: currencyAffix.suffixText,
                filled: true,
                isDense: true,
              ),
              validator: nonNegative,
              onChanged: (_) => onChanged(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final WidgetRef ref;
  final Color? color;
  final bool bold;

  const _SummaryRow({
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
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(formatOrderAmount(ref, value), style: style),
      ],
    );
  }
}
