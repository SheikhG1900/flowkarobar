import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flowpaisa/core/utils/tabular_parser.dart';
import 'package:flowpaisa/core/utils/date_formatter.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/shared/widgets/voice_input_button.dart';

class TabularEditor extends StatefulWidget {
  final List<TabularRow> rows;
  final String currencySymbol;
  final int decimalPlaces;
  final Function(List<TabularRow>) onChanged;
  final VoidCallback onSyncTotal;
  final double currentTransactionAmount;

  const TabularEditor({
    super.key,
    required this.rows,
    required this.currencySymbol,
    required this.decimalPlaces,
    required this.onChanged,
    required this.onSyncTotal,
    required this.currentTransactionAmount,
  });

  @override
  State<TabularEditor> createState() => _TabularEditorState();
}

class _TabularEditorState extends State<TabularEditor> {
  double get tabularTotal => widget.rows.fold(0, (sum, row) => sum + row.totalAmount);

  void _addRow() {
    setState(() {
      widget.rows.add(TabularRow(date: DateTime.now()));
      widget.onChanged(widget.rows);
    });
  }

  void _removeRow(int index) {
    setState(() {
      widget.rows.removeAt(index);
      widget.onChanged(widget.rows);
    });
  }

  void _copyRow(int index) {
    setState(() {
      final original = widget.rows[index];
      widget.rows.insert(
        index + 1,
        original.copyWith(date: DateTime.now()),
      );
      widget.onChanged(widget.rows);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDiff = (tabularTotal - widget.currentTransactionAmount).abs() > 0.01;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          return _TabularRowInput(
            key: ValueKey(row),
            row: row,
            currencySymbol: widget.currencySymbol,
            decimalPlaces: widget.decimalPlaces,
            onChanged: () {
              setState(() {});
              widget.onChanged(widget.rows);
            },
            onDelete: () => _removeRow(index),
            onCopy: () => _copyRow(index),
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _addRow,
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: Text(l10n.addNew),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _TabularRowInput extends StatefulWidget {
  final TabularRow row;
  final String currencySymbol;
  final int decimalPlaces;
  final VoidCallback onChanged;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const _TabularRowInput({
    super.key,
    required this.row,
    required this.currencySymbol,
    required this.decimalPlaces,
    required this.onChanged,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  State<_TabularRowInput> createState() => _TabularRowInputState();
}

class _TabularRowInputState extends State<_TabularRowInput> {
  late TextEditingController _qtyController;
  late TextEditingController _unitAmountController;
  late TextEditingController _descController;
  final _descFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _qtyController =
        TextEditingController(text: widget.row.quantity.toString());
    _unitAmountController =
        TextEditingController(text: widget.row.unitAmount.toString());
    _descController = TextEditingController(text: widget.row.description);
    _descController.addListener(_onDescChanged);
  }

  void _onDescChanged() {
    widget.row.description = _descController.text;
    widget.onChanged();
  }

  @override
  void dispose() {
    _descController.removeListener(_onDescChanged);
    _qtyController.dispose();
    _unitAmountController.dispose();
    _descController.dispose();
    _descFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: widget.row.date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => widget.row.date = picked);
                    widget.onChanged();
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        AppDateFormatter.formatDate(widget.row.date,
                            pattern: 'dd/MM/yy'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Copy Button
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                tooltip: l10n.copy,
                onPressed: widget.onCopy,
                style: IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const Spacer(),
              // Calculated Item Total (Price) on Top
              Text(
                AmountFormatter.formatWithCurrency(widget.row.totalAmount,
                    widget.currencySymbol, widget.decimalPlaces),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                tooltip: l10n.delete,
                onPressed: widget.onDelete,
                style: IconButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          TextFormField(
            controller: _descController,
            focusNode: _descFocusNode,
            decoration: InputDecoration(
              hintText: l10n.descriptionHint,
              labelText: l10n.description,
              isDense: true,
              prefixIcon: const Icon(Icons.notes, size: 18),
              suffixIcon: VoiceInputButton(
                controller: _descController,
                focusNode: _descFocusNode,
                size: 18.0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Units/Quantity
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _qtyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: l10n.unitsQuantity,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        final current = double.tryParse(_qtyController.text) ?? 1.0;
                        if (current > 1) {
                          final newValue = current - 1;
                          final displayValue = newValue % 1 == 0 ? newValue.toInt().toString() : newValue.toString();
                          _qtyController.text = displayValue;
                          widget.row.quantity = newValue;
                          widget.onChanged();
                          setState(() {});
                        }
                      },
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        final current = double.tryParse(_qtyController.text) ?? 1.0;
                        final newValue = current + 1;
                        final displayValue = newValue % 1 == 0 ? newValue.toInt().toString() : newValue.toString();
                        _qtyController.text = displayValue;
                        widget.row.quantity = newValue;
                        widget.onChanged();
                        setState(() {});
                      },
                    ),
                  ),
                  onChanged: (val) {
                    widget.row.quantity = double.tryParse(val) ?? 0.0;
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Unit Price
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _unitAmountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.unitPrice,
                    isDense: true,
                    prefixText: widget.currencySymbol,
                  ),
                  onChanged: (val) {
                    widget.row.unitAmount = double.tryParse(val) ?? 0.0;
                    widget.onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
