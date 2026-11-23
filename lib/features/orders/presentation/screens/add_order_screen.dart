import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flowpaisa/core/database/database.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/toast_utils.dart';
import 'package:flowpaisa/features/accounts/presentation/providers/accounts_provider.dart';
import 'package:flowpaisa/features/accounts/presentation/widgets/account_picker.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_discounts.dart';
import 'package:flowpaisa/features/catalog/domain/catalog_sale_pick.dart';
import 'package:flowpaisa/features/catalog/presentation/providers/catalog_provider.dart';
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
import 'package:flowpaisa/shared/widgets/ltr_number_field.dart';

class _OrderLine {
  final Product? product;
  final String? catalogItemUuid;
  final String? sellingProductUuid;
  final String displayName;
  final String unit;
  final String? categoryUuid;
  final bool isService;
  final bool applyCatalogDiscounts;

  /// Mutable so refresh-from-catalog can update the snapshot.
  double listUnitPrice;
  String? defaultDiscountType;
  double defaultDiscountValue;
  List<({double minQuantity, String type, double value})> discountTiers;
  String? catalogName;

  /// When true, qty changes keep the edited discounted unit price.
  bool manualDiscountedPrice;

  /// Stock units available when the line was added (sale goods only). Not refreshed on qty edits.
  double? availableQuantity;

  final TextEditingController quantity;
  final TextEditingController unitPrice;
  final TextEditingController discountedUnitPrice;
  final TextEditingController discount;
  /// Service sale COGS; stamped to [OrderItem.purchasePriceSnapshot].
  final TextEditingController unitCost;

  _OrderLine({
    required this.displayName,
    required this.unit,
    required double price,
    required double defaultUnitCost,
    this.product,
    this.catalogItemUuid,
    this.sellingProductUuid,
    this.categoryUuid,
    this.isService = false,
    this.listUnitPrice = 0,
    this.defaultDiscountType,
    this.defaultDiscountValue = 0,
    this.discountTiers = const [],
    this.applyCatalogDiscounts = false,
    this.catalogName,
    double? initialDiscountedUnitPrice,
    double initialDiscount = 0,
  })  : manualDiscountedPrice = false,
        quantity = TextEditingController(text: '1'),
        unitPrice = TextEditingController(text: _plain(price)),
        discountedUnitPrice = TextEditingController(
          text: _plain(initialDiscountedUnitPrice ?? price),
        ),
        discount = TextEditingController(text: _plain(initialDiscount)),
        unitCost = TextEditingController(text: _plain(defaultUnitCost));

  factory _OrderLine.fromProduct({
    required Product product,
    required double price,
    double? defaultUnitCost,
  }) {
    return _OrderLine(
      product: product,
      displayName: product.name,
      unit: product.unit,
      categoryUuid: product.categoryUuid,
      isService: product.isService,
      price: price,
      listUnitPrice: price,
      defaultUnitCost: defaultUnitCost ?? product.purchasePrice,
    );
  }

  factory _OrderLine.fromCatalogPick(CatalogSalePick pick) {
    final discounted = pick.discountedUnitForQty(1);
    final discount = SaleLinePricing.lineDiscountFixed(
      listUnitPrice: pick.sellPrice,
      discountedUnitPrice: discounted,
      quantity: 1,
    );
    return _OrderLine(
      product: pick.product,
      catalogItemUuid: pick.item.uuid,
      sellingProductUuid: pick.sellingProductUuid,
      displayName: pick.displayName,
      unit: pick.unit,
      categoryUuid: pick.categoryUuid,
      isService: pick.isService,
      price: pick.sellPrice,
      listUnitPrice: pick.sellPrice,
      defaultDiscountType: pick.item.defaultDiscountType,
      defaultDiscountValue: pick.item.defaultDiscountValue,
      discountTiers: pick.discountTiers,
      applyCatalogDiscounts: true,
      catalogName: pick.catalogName,
      defaultUnitCost: pick.unitCost,
      initialDiscountedUnitPrice: discounted,
      initialDiscount: discount,
    );
  }

  double get quantityValue => _parse(quantity);
  double get unitPriceValue => _parse(unitPrice);
  double get discountedUnitPriceValue => _parse(discountedUnitPrice);
  double get unitCostValue => _parse(unitCost);

  /// True when ordered qty exceeds [availableQuantity] captured at line create.
  bool get isStockShort {
    final available = availableQuantity;
    if (available == null || isService) return false;
    return quantityValue > available + 1e-9;
  }

  double get effectiveListUnitPrice =>
      applyCatalogDiscounts ? listUnitPrice : unitPriceValue;

  double get effectiveDiscountedUnitPrice => applyCatalogDiscounts
      ? discountedUnitPriceValue
      : unitPriceValue;

  double get discountValue {
    if (applyCatalogDiscounts) {
      return SaleLinePricing.lineDiscountFixed(
        listUnitPrice: listUnitPrice,
        discountedUnitPrice: discountedUnitPriceValue,
        quantity: quantityValue,
      );
    }
    return _parse(discount);
  }

  double get gross {
    if (applyCatalogDiscounts) {
      return SaleLinePricing.lineGross(
        listUnitPrice: listUnitPrice,
        quantity: quantityValue,
      );
    }
    return quantityValue * unitPriceValue;
  }

  double get lineTotal {
    if (applyCatalogDiscounts) {
      return SaleLinePricing.lineTotal(
        discountedUnitPrice: discountedUnitPriceValue,
        quantity: quantityValue,
      );
    }
    return (gross - discountValue).clamp(0, double.infinity);
  }

  double get unitDiscountFixed => SaleLinePricing.unitDiscountFixed(
        listUnitPrice: effectiveListUnitPrice,
        discountedUnitPrice: effectiveDiscountedUnitPrice,
      );

  double get unitDiscountPercent => SaleLinePricing.unitDiscountPercent(
        listUnitPrice: effectiveListUnitPrice,
        discountedUnitPrice: effectiveDiscountedUnitPrice,
      );

  double get lineDiscountPercent => SaleLinePricing.lineDiscountPercent(
        listUnitPrice: effectiveListUnitPrice,
        discountedUnitPrice: effectiveDiscountedUnitPrice,
      );

  void _syncDiscountController() {
    if (!applyCatalogDiscounts) return;
    discount.text = _plain(discountValue);
  }

  /// Recalc discounted unit from catalog tiers unless manually overridden.
  void syncCatalogDiscountFromQty() {
    if (!applyCatalogDiscounts) return;
    if (!manualDiscountedPrice) {
      final after = CatalogDiscounts.unitPriceAfterDiscounts(
        sellPrice: listUnitPrice,
        defaultType: defaultDiscountType,
        defaultValue: defaultDiscountValue,
        quantity: quantityValue,
        tiers: discountTiers,
      );
      discountedUnitPrice.text = _plain(after);
      unitPrice.text = _plain(listUnitPrice);
    }
    _syncDiscountController();
  }

  void onDiscountedUnitPriceEdited() {
    if (!applyCatalogDiscounts) return;
    manualDiscountedPrice = true;
    _syncDiscountController();
  }

  void applyCatalogRefresh(CatalogSalePick pick) {
    listUnitPrice = pick.sellPrice;
    unitPrice.text = _plain(pick.sellPrice);
    defaultDiscountType = pick.item.defaultDiscountType;
    defaultDiscountValue = pick.item.defaultDiscountValue;
    discountTiers = List.of(pick.discountTiers);
    catalogName = pick.catalogName;
    unitCost.text = _plain(pick.unitCost);
    manualDiscountedPrice = false;
    syncCatalogDiscountFromQty();
  }

  void dispose() {
    quantity.dispose();
    unitPrice.dispose();
    discountedUnitPrice.dispose();
    discount.dispose();
    unitCost.dispose();
  }

  static String _plain(double value) => AmountFormatter.formatQuantity(value);
}

double _parse(TextEditingController controller) =>
    double.tryParse(controller.text.trim()) ?? 0;

class _OrderChargeLine {
  final TextEditingController description;
  final TextEditingController amount;

  _OrderChargeLine({String desc = '', double amountValue = 0})
      : description = TextEditingController(text: desc),
        amount = TextEditingController(
          text: amountValue <= 0
              ? ''
              : AmountFormatter.formatQuantity(amountValue),
        );

  double get amountValue => _parse(amount);

  void dispose() {
    description.dispose();
    amount.dispose();
  }
}

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
  final _taxController = TextEditingController();
  final List<_OrderLine> _lines = [];
  final List<_OrderChargeLine> _charges = [];

  String? _contactUuid;
  String? _accountUuid;
  /// User-selected sale catalog (must be an active catalog uuid).
  String? _saleCatalogUuid;
  bool _showAllContacts = false;
  bool _delivered = false;
  bool _saving = false;
  bool _appliedDefaultTax = false;
  DateTime _orderDate = DateTime.now();

  bool get _isSale => widget.orderType == orderTypeSale;
  Color get _color => orderTypeColor(widget.orderType);

  double get _subtotal => _lines.fold<double>(0, (sum, l) => sum + l.gross);
  double get _discountTotal =>
      _lines.fold<double>(0, (sum, l) => sum + l.discountValue);
  double get _itemsNet =>
      (_subtotal - _discountTotal).clamp(0, double.infinity).toDouble();
  double get _taxRate => _parse(_taxController).clamp(0, double.infinity);
  double get _taxAmount =>
      (_itemsNet * _taxRate / 100).clamp(0, double.infinity).toDouble();
  double get _chargesTotal => _charges.fold<double>(
        0,
        (sum, c) => sum + (c.amountValue > 0 ? c.amountValue : 0),
      );
  double get _total =>
      (_itemsNet + _taxAmount + _chargesTotal)
          .clamp(0, double.infinity)
          .toDouble();

  @override
  void dispose() {
    _notesController.dispose();
    _paymentController.dispose();
    _taxController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    for (final charge in _charges) {
      charge.dispose();
    }
    super.dispose();
  }

  void _addCharge({String? preset}) {
    setState(() {
      _charges.add(_OrderChargeLine(desc: preset ?? ''));
    });
  }

  Future<Catalog?> _resolveSelectedSaleCatalog() async {
    final repo = ref.read(catalogRepositoryProvider);
    final active = await repo.listActiveCatalogsForContact(_contactUuid);
    if (active.isEmpty) return null;
    final selectedId = _saleCatalogUuid;
    if (selectedId != null) {
      final match = active.where((c) => c.uuid == selectedId).firstOrNull;
      if (match != null) return match;
    }
    return active.first;
  }

  Future<void> _pickProduct() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isSale) {
      final catalog = await _resolveSelectedSaleCatalog();
      if (!mounted) return;
      if (catalog == null) {
        ToastUtils.showErrorToast(context, ref, l10n.saleNoActiveCatalog);
        return;
      }
      if (_saleCatalogUuid != catalog.uuid) {
        setState(() => _saleCatalogUuid = catalog.uuid);
      }
      final result = await showOrderCatalogItemPicker(
        context: context,
        ref: ref,
        catalogUuid: catalog.uuid,
        catalogName: catalog.name,
      );
      final pick = result?.value;
      if (pick == null || !mounted) return;
      _addOrBumpCatalogLine(pick.withCatalogName(catalog.name));
      return;
    }

    final result = await showOrderProductPicker(context: context, ref: ref);
    final product = result?.value;
    if (product == null || !mounted) return;
    _addOrBumpProductLine(product);
  }

  void _addOrBumpProductLine(Product product) {
    final existing = _lines.where((l) {
      return l.catalogItemUuid == null &&
          l.sellingProductUuid == null &&
          l.product?.uuid == product.uuid;
    }).firstOrNull;
    if (existing != null) {
      setState(() {
        existing.quantity.text =
            AmountFormatter.formatQuantity(existing.quantityValue + 1);
        existing.syncCatalogDiscountFromQty();
      });
      return;
    }
    final line = _OrderLine.fromProduct(
      product: product,
      price: _isSale ? product.retailPrice : product.purchasePrice,
      defaultUnitCost: product.purchasePrice,
    );
    setState(() => _lines.add(line));
    if (_isSale) _captureLineAvailableQty(line);
  }

  void _addOrBumpCatalogLine(CatalogSalePick pick) {
    final existing = _lines
        .where((l) => l.catalogItemUuid == pick.item.uuid)
        .firstOrNull;
    if (existing != null) {
      setState(() {
        existing.quantity.text =
            AmountFormatter.formatQuantity(existing.quantityValue + 1);
        existing.syncCatalogDiscountFromQty();
      });
      return;
    }
    final line = _OrderLine.fromCatalogPick(pick);
    setState(() => _lines.add(line));
    if (_isSale) _captureLineAvailableQty(line);
  }

  /// Resolve stock once when the line is created (or catalog-refreshed).
  Future<void> _captureLineAvailableQty(_OrderLine line) async {
    if (!_isSale || line.isService) return;
    final available =
        await ref.read(inventoryRepositoryProvider).fulfillableSaleQuantity(
              productUuid: line.product?.uuid,
              sellingProductUuid: line.sellingProductUuid,
              isService: line.isService,
            );
    if (!mounted) return;
    setState(() => line.availableQuantity = available);
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
    setState(() {
      _contactUuid = result.value?.uuid;
      _saleCatalogUuid = null; // re-resolve for the new contact
    });
  }

  void _removeLine(int index) {
    final line = _lines[index];
    setState(() => _lines.removeAt(index));
    WidgetsBinding.instance.addPostFrameCallback((_) => line.dispose());
  }

  Future<void> _refreshLineFromCatalog(_OrderLine line) async {
    final l10n = AppLocalizations.of(context)!;
    final itemUuid = line.catalogItemUuid;
    if (itemUuid == null) return;
    final pick =
        await ref.read(catalogRepositoryProvider).resolveSalePick(itemUuid);
    if (!mounted) return;
    if (pick == null) {
      ToastUtils.showErrorToast(context, ref, l10n.saleLineCatalogRefreshFailed);
      return;
    }
    setState(() => line.applyCatalogRefresh(pick));
    if (_isSale) await _captureLineAvailableQty(line);
    if (!mounted) return;
    ToastUtils.showSuccessToast(context, ref, l10n.saleLinePricesRefreshed);
  }

  Future<void> _editDiscountedUnitPrice(_OrderLine line) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final currency = ref.read(currentCurrencyProvider).value;
    final currencyAffix = AmountFormatter.currencyAffix(
      currency?.symbol ?? ref.read(currencySymbolProvider),
      isRtl: isRtl,
    );
    final controller = TextEditingController(
      text: line.discountedUnitPrice.text,
    );
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.editDiscountedUnitPrice,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                line.displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              LtrNumberField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.discountedUnitPrice,
                  helperText: l10n.discountedUnitPriceManualHint,
                  prefixText: currencyAffix.prefixText,
                  suffixText: currencyAffix.suffixText,
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: l10n.save,
                icon: Icons.check_rounded,
                width: double.infinity,
                gradient: AppColors.getPrimaryGradient(_color),
                onPressed: () {
                  final value = double.tryParse(controller.text.trim());
                  if (value == null || value < 0) {
                    ToastUtils.showErrorToast(
                      sheetContext,
                      ref,
                      l10n.invalidNumber,
                    );
                    return;
                  }
                  line.discountedUnitPrice.text =
                      AmountFormatter.formatQuantity(value);
                  line.onDiscountedUnitPriceEdited();
                  Navigator.pop(sheetContext, true);
                },
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (applied == true && mounted) setState(() {});
  }

  Future<void> _editSalesTaxRate() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = TextEditingController(
      text: _taxRate > 0 ? AmountFormatter.formatQuantity(_taxRate) : '',
    );
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.editSalesTax,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.salesTaxOnItemsHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              LtrNumberField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.salesTaxPercent,
                  suffixText: '%',
                  prefixIcon: const Icon(Icons.percent_outlined),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: l10n.save,
                icon: Icons.check_rounded,
                width: double.infinity,
                gradient: AppColors.getPrimaryGradient(_color),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) {
                    _taxController.text = '';
                    Navigator.pop(sheetContext, true);
                    return;
                  }
                  final value = double.tryParse(text);
                  if (value == null || value < 0) {
                    ToastUtils.showErrorToast(
                      sheetContext,
                      ref,
                      l10n.invalidNumber,
                    );
                    return;
                  }
                  _taxController.text = AmountFormatter.formatQuantity(value);
                  Navigator.pop(sheetContext, true);
                },
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    if (applied == true && mounted) setState(() {});
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
        taxRate: drift.Value(_taxRate),
        taxAmount: drift.Value(_taxAmount),
        paymentStatus: drift.Value(paymentStatus),
        deliveryStatus: drift.Value(_delivered ? 'DELIVERED' : 'PENDING'),
        deliveredDate: drift.Value(_delivered ? DateTime.now() : null),
        notes: drift.Value(notes.isEmpty ? null : notes),
      );

      final items = _lines.map((line) {
        final isService = line.isService;
        final stampedCogs = isService
            ? line.unitCostValue
            : (line.product?.purchasePrice ?? line.unitCostValue);
        return OrderItemsCompanion.insert(
          uuid: const Uuid().v4(),
          orderUuid: orderUuid,
          productUuid: drift.Value(line.product?.uuid),
          catalogItemUuid: drift.Value(line.catalogItemUuid),
          sellingProductUuid: drift.Value(line.sellingProductUuid),
          productNameSnapshot: line.displayName,
          quantity: line.quantityValue,
          unitPrice: line.effectiveListUnitPrice,
          discountedUnitPrice: drift.Value(
            line.applyCatalogDiscounts
                ? line.discountedUnitPriceValue
                : line.unitPriceValue,
          ),
          discountAmount: drift.Value(line.discountValue),
          catalogNameSnapshot: drift.Value(line.catalogName),
          // Services: freeze line COGS. Goods / bundles: FEFO overwrites on deliver.
          purchasePriceSnapshot: drift.Value(stampedCogs),
          unit: drift.Value(line.unit),
        );
      }).toList();

      final chargeRows = _charges
          .where((c) =>
              c.description.text.trim().isNotEmpty && c.amountValue > 0)
          .map(
            (c) => OrderChargesCompanion.insert(
              uuid: const Uuid().v4(),
              orderUuid: orderUuid,
              description: c.description.text.trim(),
              amount: drift.Value(c.amountValue),
            ),
          )
          .toList();

      await repository.createOrder(
        order: order,
        items: items,
        charges: chargeRows,
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
    final operatingDefaults = ref.watch(operatingDefaultsProvider);
    if (_isSale &&
        !_appliedDefaultTax &&
        operatingDefaults.defaultSalesTaxRate > 0) {
      final rate = operatingDefaults.defaultSalesTaxRate;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _appliedDefaultTax) return;
        _appliedDefaultTax = true;
        if (_taxController.text.trim().isEmpty) {
          setState(() {
            _taxController.text = AmountFormatter.formatQuantity(rate);
          });
        }
      });
    }

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
    final saleCatalogsAsync = _isSale
        ? ref.watch(activeCatalogsForContactProvider(_contactUuid))
        : null;
    final saleCatalogs = saleCatalogsAsync?.asData?.value;
    final canAddSaleItems = !_isSale ||
        saleCatalogsAsync == null ||
        saleCatalogsAsync.isLoading ||
        (saleCatalogs != null && saleCatalogs.isNotEmpty);
    final selectedSaleCatalogName = () {
      final list = saleCatalogs;
      if (list == null || list.isEmpty) return null;
      final id = _saleCatalogUuid;
      if (id != null) {
        final match = list.where((c) => c.uuid == id).firstOrNull;
        if (match != null) return match.name;
      }
      return list.first.name;
    }();

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
                      : () => setState(() {
                            _contactUuid = null;
                            _saleCatalogUuid = null;
                          }),
                  onTap: _pickContact,
                ),
                if (_isSale)
                  _SaleCatalogPicker(
                    contactUuid: _contactUuid,
                    selectedCatalogUuid: _saleCatalogUuid,
                    onSelected: (uuid) =>
                        setState(() => _saleCatalogUuid = uuid),
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
                onPressed: canAddSaleItems ? _pickProduct : null,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.addItem),
              ),
              children: [
                if (_lines.isEmpty)
                  _EmptyItemsHint(
                    onAdd: canAddSaleItems
                        ? _pickProduct
                        : () => ToastUtils.showErrorToast(
                              context,
                              ref,
                              l10n.saleNoActiveCatalog,
                            ),
                    color: _color,
                  )
                else
                  for (var i = 0; i < _lines.length; i++)
                    _OrderLineCard(
                      key: ObjectKey(_lines[i]),
                      line: _lines[i],
                      color: _color,
                      isSale: _isSale,
                      category: _lines[i].categoryUuid == null
                          ? null
                          : categoryById[_lines[i].categoryUuid],
                      amountLabel: formatOrderAmount(ref, _lines[i].lineTotal),
                      catalogNameFallback: selectedSaleCatalogName,
                      showUnitCost: _isSale && _lines[i].isService,
                      onChanged: () {
                        _lines[i].syncCatalogDiscountFromQty();
                        setState(() {});
                      },
                      onEditDiscountedPrice: () =>
                          _editDiscountedUnitPrice(_lines[i]),
                      onRefreshFromCatalog: _lines[i].catalogItemUuid == null
                          ? null
                          : () => _refreshLineFromCatalog(_lines[i]),
                      onRemove: () => _removeLine(i),
                    ),
              ],
            ),
            FormSectionCard(
              title: l10n.sectionCharges,
              icon: Icons.add_card_outlined,
              accentColor: _color,
              trailing: TextButton.icon(
                onPressed: () => _addCharge(),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addCharge),
              ),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: Text(l10n.deliveryCharge),
                      avatar: const Icon(Icons.local_shipping_outlined, size: 16),
                      onPressed: () =>
                          _addCharge(preset: l10n.deliveryCharge),
                    ),
                    ActionChip(
                      label: Text(l10n.packingCharge),
                      avatar: const Icon(Icons.inventory_2_outlined, size: 16),
                      onPressed: () =>
                          _addCharge(preset: l10n.packingCharge),
                    ),
                  ],
                ),
                for (var i = 0; i < _charges.length; i++) ...[
                  if (i == 0) const SizedBox(height: 4),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _charges[i].description,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: l10n.chargeDescription,
                            filled: true,
                            isDense: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Builder(
                          builder: (context) {
                            final isRtl = Directionality.of(context) ==
                                TextDirection.rtl;
                            final affix = AmountFormatter.currencyAffix(
                              ref.watch(currencySymbolProvider),
                              isRtl: isRtl,
                            );
                            return LtrNumberField(
                              controller: _charges[i].amount,
                              decoration: InputDecoration(
                                labelText: l10n.amount,
                                prefixText: affix.prefixText,
                                suffixText: affix.suffixText,
                                filled: true,
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(
                          () => _charges.removeAt(i).dispose(),
                        ),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
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
                _SummaryRow(
                  label: l10n.taxableAmount,
                  value: _itemsNet,
                  ref: ref,
                  muted: true,
                ),
                _TaxSummaryRow(
                  label: l10n.salesTax,
                  amount: _taxAmount,
                  ratePercent: _taxRate,
                  ref: ref,
                  onEdit: _editSalesTaxRate,
                ),
                for (final charge in _charges)
                  if (charge.description.text.trim().isNotEmpty &&
                      charge.amountValue > 0)
                    _SummaryRow(
                      label: charge.description.text.trim(),
                      value: charge.amountValue,
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
                    return LtrNumberField(
                      controller: _paymentController,
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
  final bool isSale;
  final ProductCategory? category;
  final String amountLabel;
  final String? catalogNameFallback;
  final bool showUnitCost;
  final VoidCallback onChanged;
  final VoidCallback onEditDiscountedPrice;
  final VoidCallback? onRefreshFromCatalog;
  final VoidCallback onRemove;

  const _OrderLineCard({
    super.key,
    required this.line,
    required this.color,
    required this.isSale,
    required this.amountLabel,
    required this.onChanged,
    required this.onEditDiscountedPrice,
    required this.onRemove,
    this.onRefreshFromCatalog,
    this.category,
    this.catalogNameFallback,
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

    final leading = line.product != null
        ? productLeadingAvatar(product: line.product!, category: category)
        : categoryLeadingAvatar(
            color: parseCategoryColor(
              category?.color,
              AppColors.receivableColor,
            ),
            icon: category == null
                ? Icons.sell_outlined
                : categoryIconData(category),
          );

    final storedCatalog = line.catalogName?.trim();
    final fallbackCatalog = catalogNameFallback?.trim();
    final catalogLabel =
        (storedCatalog != null && storedCatalog.isNotEmpty)
            ? storedCatalog
            : ((fallbackCatalog != null && fallbackCatalog.isNotEmpty)
                ? fallbackCatalog
                : null);
    final showSalePricing = isSale && line.applyCatalogDiscounts;
    final muted = theme.colorScheme.onSurfaceVariant;
    final showRefresh =
        showSalePricing && onRefreshFromCatalog != null;
    final stockShort = isSale && line.isStockShort;
    final stockWarnColor = AppColors.warning;
    final borderColor = stockShort
        ? stockWarnColor.withValues(alpha: 0.45)
        : color.withValues(alpha: 0.2);
    final fillColor = stockShort
        ? stockWarnColor.withValues(alpha: 0.1)
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);

    final metaParts = <String>[
      if (category != null) category!.name,
      if (line.sellingProductUuid != null) l10n.sellingProductOffer,
      if (!showSalePricing) amountLabel,
    ];

    final available = line.availableQuantity;
    final stockWarning = (stockShort && available != null)
        ? Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 16, color: stockWarnColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.orderLineStockShort(
                      AmountFormatter.formatQuantity(available),
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: stockWarnColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          )
        : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            showRefresh ? 18 : 12,
            10,
            18,
            12,
          ),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSalePricing) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: title/meta above, quantity below
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              leading,
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 2,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          line.displayName,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Tooltip(
                                          message: l10n.editDiscountedUnitPrice,
                                          child: InkWell(
                                            onTap: onEditDiscountedPrice,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Padding(
                                              padding: const EdgeInsets.all(2),
                                              child: Icon(
                                                line.manualDiscountedPrice
                                                    ? Icons.lock_open_rounded
                                                    : Icons.edit_outlined,
                                                size: 16,
                                                color: line.manualDiscountedPrice
                                                    ? color
                                                    : muted,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if ((showSalePricing &&
                                            catalogLabel != null &&
                                            catalogLabel.isNotEmpty) ||
                                        metaParts.isNotEmpty) ...[
                                      const SizedBox(height: 1),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            if (showSalePricing &&
                                                catalogLabel != null &&
                                                catalogLabel.isNotEmpty)
                                              TextSpan(
                                                text: catalogLabel,
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: color,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            if (showSalePricing &&
                                                catalogLabel != null &&
                                                catalogLabel.isNotEmpty &&
                                                metaParts.isNotEmpty)
                                              TextSpan(
                                                text: ' · ',
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(color: muted),
                                              ),
                                            if (metaParts.isNotEmpty)
                                              TextSpan(
                                                text: metaParts.join(' · '),
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: muted,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 120,
                            child: LtrNumberField(
                              controller: line.quantity,
                              decoration: InputDecoration(
                                labelText: l10n.quantity,
                                suffixText: line.unit,
                                filled: true,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                              validator: positive,
                              onChanged: (_) => onChanged(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Right: prices
                    OrderLinePriceStack(
                      listUnitPrice: line.listUnitPrice,
                      discountedUnitPrice: line.discountedUnitPriceValue,
                      quantity: line.quantityValue,
                      accent: color,
                      ref: ref,
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leading,
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            line.displayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (metaParts.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              metaParts.join(' · '),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: LtrNumberField(
                    controller: line.quantity,
                    decoration: InputDecoration(
                      labelText: l10n.quantity,
                      suffixText: line.unit,
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
                  child: LtrNumberField(
                    controller: line.unitPrice,
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
                  child: LtrNumberField(
                    controller: line.discount,
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
          ],
              if (showUnitCost) ...[
                const SizedBox(height: 8),
                LtrNumberField(
                  controller: line.unitCost,
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
              if (stockWarning != null) stockWarning,
            ],
          ),
        ),
        if (showRefresh)
          Positioned(
            top: -4,
            left: -4,
            child: _LineCornerButton(
              tooltip: l10n.refreshSaleLinePrices,
              icon: Icons.refresh_rounded,
              onPressed: onRefreshFromCatalog!,
            ),
          ),
        Positioned(
          top: -4,
          right: -4,
          child: _LineCornerButton(
            tooltip: l10n.delete,
            icon: Icons.close_rounded,
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}

class _LineCornerButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _LineCornerButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = CircleBorder(
      side: BorderSide(
        color: theme.colorScheme.outline.withValues(alpha: 0.55),
        width: 1,
      ),
    );
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surface,
        shape: outline,
        elevation: 1.5,
        shadowColor: Colors.black26,
        child: InkWell(
          customBorder: outline,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(
              icon,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
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
  final bool muted;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.ref,
    this.color,
    this.bold = false,
    this.muted = false,
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
      fontWeight: bold
          ? FontWeight.w700
          : (muted ? FontWeight.w500 : FontWeight.w500),
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

class _TaxSummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final double ratePercent;
  final WidgetRef ref;
  final VoidCallback onEdit;

  const _TaxSummaryRow({
    required this.label,
    required this.amount,
    required this.ratePercent,
    required this.ref,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final style = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
    );
    final rateLabel = ratePercent > 0
        ? '${AmountFormatter.formatQuantity(ratePercent)}%'
        : '0%';

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: style,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: AppLocalizations.of(context)!.editSalesTax,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(Icons.edit_outlined, size: 18, color: muted),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rateLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(formatOrderAmount(ref, amount), style: style),
          ],
        ),
      ],
    );
  }
}

/// Catalog field that opens a bottom drawer of catalogs allowed for this sale.
class _SaleCatalogPicker extends ConsumerWidget {
  final String? contactUuid;
  final String? selectedCatalogUuid;
  final ValueChanged<String> onSelected;

  const _SaleCatalogPicker({
    required this.contactUuid,
    required this.selectedCatalogUuid,
    required this.onSelected,
  });

  Future<void> _openPicker(
    BuildContext context,
    WidgetRef ref,
    List<Catalog> catalogs,
    Catalog? selected,
  ) async {
    final restricted = await ref
        .read(catalogRepositoryProvider)
        .catalogUuidsWithAssignments();
    if (!context.mounted) return;
    final openIds = {
      for (final c in catalogs)
        if (!restricted.contains(c.uuid)) c.uuid,
    };
    final result = await showOrderCatalogPicker(
      context: context,
      ref: ref,
      catalogs: catalogs,
      selected: selected,
      openCatalogUuids: openIds,
    );
    final picked = result?.value;
    if (picked != null) onSelected(picked.uuid);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(activeCatalogsForContactProvider(contactUuid));
    final preferred =
        ref.watch(resolvedCatalogForContactProvider(contactUuid)).asData?.value;

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 8),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          l10n.errorOccurred(e.toString()),
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.warning),
        ),
      ),
      data: (catalogs) {
        if (catalogs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 18, color: AppColors.warning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.saleNoActiveCatalog,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final preferredId = preferred?.uuid;
        final effectiveId = selectedCatalogUuid != null &&
                catalogs.any((c) => c.uuid == selectedCatalogUuid)
            ? selectedCatalogUuid!
            : (preferredId != null &&
                    catalogs.any((c) => c.uuid == preferredId)
                ? preferredId
                : catalogs.first.uuid);
        final selected =
            catalogs.where((c) => c.uuid == effectiveId).firstOrNull;

        if (selectedCatalogUuid != effectiveId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onSelected(effectiveId);
          });
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: EntityPickerField(
            label: l10n.catalog,
            valueText: selected?.name,
            valueSubtitle: selected == null || !selected.isDefault
                ? null
                : l10n.defaultCatalog,
            accentColor: AppColors.receivableColor,
            placeholderIcon: Icons.price_change_outlined,
            leading: categoryLeadingAvatar(
              color: AppColors.receivableColor,
              icon: Icons.price_change_outlined,
            ),
            onTap: () => _openPicker(context, ref, catalogs, selected),
          ),
        );
      },
    );
  }
}
