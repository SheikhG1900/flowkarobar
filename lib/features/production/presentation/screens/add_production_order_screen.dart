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
import 'package:flowpaisa/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:flowpaisa/features/orders/presentation/widgets/order_entity_pickers.dart';
import 'package:flowpaisa/features/production/domain/production_models.dart';
import 'package:flowpaisa/features/production/presentation/providers/production_provider.dart';
import 'package:flowpaisa/features/settings/presentation/providers/settings_provider.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/providers/currency_provider.dart';
import 'package:flowpaisa/shared/widgets/form_section_card.dart';
import 'package:flowpaisa/shared/widgets/gradient_button.dart';

final _decimalFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
];

double _parse(TextEditingController c) =>
    double.tryParse(c.text.trim()) ?? 0;

class _InputLine {
  Product product;
  final TextEditingController qty;
  String consumeMode;
  String? batchNumber;

  _InputLine({required this.product, double quantity = 1})
      : qty = TextEditingController(
          text: AmountFormatter.formatQuantity(quantity),
        ),
        consumeMode = ProductionConsumeMode.auto;

  void dispose() => qty.dispose();
}

class _OutputLine {
  Product product;
  final TextEditingController qty;
  final TextEditingController weight;
  final TextEditingController batch;

  _OutputLine({required this.product, double quantity = 1, double costWeight = 1})
      : qty = TextEditingController(
          text: AmountFormatter.formatQuantity(quantity),
        ),
        weight = TextEditingController(
          text: AmountFormatter.formatQuantity(costWeight),
        ),
        batch = TextEditingController();

  void dispose() {
    qty.dispose();
    weight.dispose();
    batch.dispose();
  }
}

class _ChargeLine {
  final TextEditingController description;
  final TextEditingController amount;

  _ChargeLine({String desc = '', double amountValue = 0})
      : description = TextEditingController(text: desc),
        amount = TextEditingController(
          text: amountValue <= 0
              ? ''
              : AmountFormatter.formatQuantity(amountValue),
        );

  void dispose() {
    description.dispose();
    amount.dispose();
  }
}

class AddProductionOrderScreen extends ConsumerStatefulWidget {
  final String? existingUuid;

  const AddProductionOrderScreen({super.key, this.existingUuid});

  @override
  ConsumerState<AddProductionOrderScreen> createState() =>
      _AddProductionOrderScreenState();
}

class _AddProductionOrderScreenState
    extends ConsumerState<AddProductionOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notes = TextEditingController();
  final _inputs = <_InputLine>[];
  final _outputs = <_OutputLine>[];
  final _charges = <_ChargeLine>[];
  DateTime _date = DateTime.now();
  bool _saving = false;
  bool _loading = false;

  bool get _isEditing => widget.existingUuid != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  Future<void> _loadExisting() async {
    final repo = ref.read(productionRepositoryProvider);
    final uuid = widget.existingUuid!;
    final order = await repo.getOrder(uuid);
    if (order == null || order.status != ProductionStatus.draft) {
      if (mounted) {
        setState(() => _loading = false);
        Navigator.pop(context);
      }
      return;
    }
    final inputs = await repo.getInputs(uuid);
    final outputs = await repo.getOutputs(uuid);
    final charges = await repo.getCharges(uuid);
    final inv = ref.read(inventoryRepositoryProvider);

    for (final i in inputs) {
      final p = await inv.getProduct(i.productUuid);
      if (p == null) continue;
      final line = _InputLine(product: p, quantity: i.plannedQuantity);
      line.consumeMode = i.consumeMode;
      line.batchNumber = i.batchNumber;
      _inputs.add(line);
    }
    for (final o in outputs) {
      final p = await inv.getProduct(o.productUuid);
      if (p == null) continue;
      final line = _OutputLine(
        product: p,
        quantity: o.plannedQuantity,
        costWeight: o.costWeight,
      );
      line.batch.text = o.batchNumber;
      _outputs.add(line);
    }
    for (final c in charges) {
      _charges.add(_ChargeLine(desc: c.description, amountValue: c.amount));
    }
    _notes.text = order.notes ?? '';
    _date = order.productionDate;
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _notes.dispose();
    for (final i in _inputs) {
      i.dispose();
    }
    for (final o in _outputs) {
      o.dispose();
    }
    for (final c in _charges) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickStockProduct({required bool forInput}) async {
    final result = await showOrderProductPicker(context: context, ref: ref);
    final product = result?.value;
    if (product == null || !mounted) return;
    if (product.isService) {
      ToastUtils.showErrorToast(
        context,
        ref,
        AppLocalizations.of(context)!.isServiceProduct,
      );
      return;
    }
    setState(() {
      if (forInput) {
        _inputs.add(_InputLine(product: product));
      } else {
        _outputs.add(_OutputLine(product: product));
      }
    });
  }

  Future<String?> _showBatchPicker(List<String> batches) async {
    final l10n = AppLocalizations.of(context)!;
    if (batches.isEmpty) {
      ToastUtils.showErrorToast(context, ref, l10n.noOpenLots);
      return null;
    }
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text(l10n.selectBatch)),
            for (final b in batches)
              ListTile(
                title: Text(b),
                onTap: () => Navigator.pop(context, b),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBatch(_InputLine line) async {
    final batches = await ref
        .read(inventoryRepositoryProvider)
        .openBatchNumbers(line.product.uuid);
    if (!mounted) return;
    final picked = await _showBatchPicker(batches);
    if (picked == null) return;
    setState(() {
      line.batchNumber = picked;
      line.consumeMode = ProductionConsumeMode.batch;
    });
  }

  Future<void> _pickOutputBatch(_OutputLine line) async {
    final batches = await ref
        .read(inventoryRepositoryProvider)
        .distinctBatchNumbers(line.product.uuid);
    if (!mounted) return;
    final picked = await _showBatchPicker(batches);
    if (picked == null) return;
    setState(() => line.batch.text = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_inputs.isEmpty) {
      ToastUtils.showErrorToast(context, ref, l10n.atLeastOneInput);
      return;
    }
    if (_outputs.isEmpty) {
      ToastUtils.showErrorToast(context, ref, l10n.atLeastOneOutput);
      return;
    }
    for (final i in _inputs) {
      if (i.consumeMode == ProductionConsumeMode.batch &&
          (i.batchNumber == null || i.batchNumber!.trim().isEmpty)) {
        ToastUtils.showErrorToast(context, ref, l10n.selectBatch);
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(productionRepositoryProvider);
      final inputRows = _inputs
          .map(
            (i) => ProductionOrderInputsCompanion.insert(
              uuid: const Uuid().v4(),
              productionOrderUuid: '',
              productUuid: i.product.uuid,
              productNameSnapshot: i.product.name,
              plannedQuantity: _parse(i.qty),
              consumeMode: drift.Value(i.consumeMode),
              batchNumber: drift.Value(
                i.consumeMode == ProductionConsumeMode.batch
                    ? i.batchNumber
                    : null,
              ),
              unit: drift.Value(i.product.unit),
            ),
          )
          .toList();
      final outputRows = _outputs
          .map(
            (o) => ProductionOrderOutputsCompanion.insert(
              uuid: const Uuid().v4(),
              productionOrderUuid: '',
              productUuid: o.product.uuid,
              productNameSnapshot: o.product.name,
              plannedQuantity: _parse(o.qty),
              costWeight: drift.Value(
                _parse(o.weight) <= 0 ? 1.0 : _parse(o.weight),
              ),
              batchNumber: drift.Value(o.batch.text.trim()),
              unit: drift.Value(o.product.unit),
            ),
          )
          .toList();
      final chargeRows = _charges
          .where((c) => c.description.text.trim().isNotEmpty)
          .map(
            (c) => ProductionOrderChargesCompanion.insert(
              uuid: const Uuid().v4(),
              productionOrderUuid: '',
              description: c.description.text.trim(),
              amount: drift.Value(_parse(c.amount)),
            ),
          )
          .toList();

      final notes = _notes.text.trim();
      if (_isEditing) {
        await repo.updateDraft(
          orderUuid: widget.existingUuid!,
          productionDate: _date,
          notes: notes.isEmpty ? null : notes,
          inputs: inputRows,
          outputs: outputRows,
          charges: chargeRows,
        );
      } else {
        await repo.createDraft(
          productionDate: _date,
          notes: notes.isEmpty ? null : notes,
          inputs: inputRows,
          outputs: outputRows,
          charges: chargeRows,
        );
      }
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, ref, l10n.productionSaved);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(
            context, ref, l10n.errorOccurred(e.toString()));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = ref.watch(userProfileProvider).dateFormat;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final affix = AmountFormatter.currencyAffix(
      ref.watch(currencySymbolProvider),
      isRtl: isRtl,
    );
    final accent = AppColors.incomeColor;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing
              ? l10n.editProductionOrder
              : l10n.newProductionOrder),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? l10n.editProductionOrder
            : l10n.newProductionOrder),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: GradientButton(
            label: l10n.save,
            isLoading: _saving,
            width: double.infinity,
            gradient: AppColors.getPrimaryGradient(accent),
            onPressed: _saving ? null : _save,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            FormSectionCard(
              title: l10n.sectionDetails,
              icon: Icons.event_outlined,
              accentColor: accent,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(l10n.productionDate),
                  subtitle: Text(
                    AppDateFormatter.formatDate(_date, pattern: dateFormat),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
                TextFormField(
                  controller: _notes,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.notesLabel,
                    filled: true,
                  ),
                ),
              ],
            ),
            FormSectionCard(
              title: l10n.sectionInputs,
              icon: Icons.input_rounded,
              accentColor: AppColors.expenseColor,
              trailing: TextButton.icon(
                onPressed: () => _pickStockProduct(forInput: true),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addInput),
              ),
              children: [
                if (_inputs.isEmpty)
                  Text(
                    l10n.atLeastOneInput,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                for (var i = 0; i < _inputs.length; i++) ...[
                  if (i > 0) const Divider(height: 20),
                  _buildInputCard(_inputs[i], l10n, theme),
                ],
              ],
            ),
            FormSectionCard(
              title: l10n.sectionCharges,
              icon: Icons.payments_outlined,
              accentColor: AppColors.payableColor,
              trailing: TextButton.icon(
                onPressed: () => setState(() => _charges.add(_ChargeLine())),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addCharge),
              ),
              children: [
                if (_charges.isEmpty)
                  Text(
                    l10n.serviceUnitCostHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                for (var i = 0; i < _charges.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _charges[i].description,
                          decoration: InputDecoration(
                            labelText: l10n.chargeDescription,
                            filled: true,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _charges[i].amount,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: _decimalFormatters,
                          decoration: InputDecoration(
                            labelText: l10n.amount,
                            prefixText: affix.prefixText,
                            suffixText: affix.suffixText,
                            filled: true,
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => _charges.removeAt(i).dispose()),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            FormSectionCard(
              title: l10n.sectionOutputs,
              icon: Icons.output_rounded,
              accentColor: accent,
              trailing: TextButton.icon(
                onPressed: () => _pickStockProduct(forInput: false),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.addOutput),
              ),
              children: [
                if (_outputs.isEmpty)
                  Text(
                    l10n.atLeastOneOutput,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                for (var i = 0; i < _outputs.length; i++) ...[
                  if (i > 0) const Divider(height: 20),
                  _buildOutputCard(_outputs[i], l10n),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(
    _InputLine line,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                line.product.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _inputs.remove(line);
                line.dispose();
              }),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        TextFormField(
          controller: line.qty,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: _decimalFormatters,
          decoration: InputDecoration(
            labelText: l10n.plannedQty,
            suffixText: line.product.unit,
            filled: true,
            isDense: true,
          ),
          validator: (v) {
            final n = double.tryParse(v?.trim() ?? '');
            if (n == null || n <= 0) return l10n.pleaseEnterValidNumber;
            return null;
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.consumeModeAuto),
              selected: line.consumeMode == ProductionConsumeMode.auto,
              onSelected: (_) => setState(() {
                line.consumeMode = ProductionConsumeMode.auto;
                line.batchNumber = null;
              }),
            ),
            ChoiceChip(
              label: Text(
                line.batchNumber == null || line.batchNumber!.isEmpty
                    ? l10n.consumeModeBatch
                    : '${l10n.consumeModeBatch}: ${line.batchNumber}',
              ),
              selected: line.consumeMode == ProductionConsumeMode.batch,
              onSelected: (_) => _pickBatch(line),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutputCard(_OutputLine line, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                line.product.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _outputs.remove(line);
                line.dispose();
              }),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: line.qty,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _decimalFormatters,
                decoration: InputDecoration(
                  labelText: l10n.plannedQty,
                  suffixText: line.product.unit,
                  filled: true,
                  isDense: true,
                ),
                validator: (v) {
                  final n = double.tryParse(v?.trim() ?? '');
                  if (n == null || n <= 0) return l10n.pleaseEnterValidNumber;
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: line.weight,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: _decimalFormatters,
                decoration: InputDecoration(
                  labelText: l10n.costWeight,
                  filled: true,
                  isDense: true,
                  suffixIcon: Tooltip(
                    message: l10n.costWeightHint,
                    child: Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: line.batch,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: l10n.outputBatchNumber,
            filled: true,
            isDense: true,
            suffixIcon: IconButton(
              tooltip: l10n.selectBatch,
              onPressed: () => _pickOutputBatch(line),
              icon: const Icon(Icons.list_alt_outlined),
            ),
          ),
        ),
      ],
    );
  }
}
