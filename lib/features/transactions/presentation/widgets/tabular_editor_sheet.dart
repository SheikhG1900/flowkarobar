import 'package:flutter/material.dart';
import 'package:flowpaisa/core/utils/tabular_parser.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';
import 'package:flowpaisa/features/transactions/presentation/widgets/tabular_editor.dart';

class TabularEditorSheet extends StatefulWidget {
  final List<TabularRow> initialRows;
  final String currencySymbol;
  final int decimalPlaces;
  final double currentTransactionAmount;
  final Function(List<TabularRow> rows, bool updateAmount) onSave;

  const TabularEditorSheet({
    super.key,
    required this.initialRows,
    required this.currencySymbol,
    required this.decimalPlaces,
    required this.currentTransactionAmount,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required List<TabularRow> initialRows,
    required String currencySymbol,
    required int decimalPlaces,
    required double currentTransactionAmount,
    required Function(List<TabularRow> rows, bool updateAmount) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TabularEditorSheet(
        initialRows: initialRows,
        currencySymbol: currencySymbol,
        decimalPlaces: decimalPlaces,
        currentTransactionAmount: currentTransactionAmount,
        onSave: onSave,
      ),
    );
  }

  @override
  State<TabularEditorSheet> createState() => _TabularEditorSheetState();
}

class _TabularEditorSheetState extends State<TabularEditorSheet> {
  late List<TabularRow> _rows;

  @override
  void initState() {
    super.initState();
    // Create a deep copy of rows to allow cancellation
    _rows = widget.initialRows.isEmpty 
        ? [TabularRow(date: DateTime.now())]
        : widget.initialRows.map((r) => TabularRow(
            date: r.date,
            quantity: r.quantity,
            unitAmount: r.unitAmount,
            description: r.description,
          )).toList();
  }

  double get _tabularTotal => _rows.fold(0, (sum, row) => sum + row.totalAmount);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDiff = (_tabularTotal - widget.currentTransactionAmount).abs() > 0.01;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.itemizedDetails,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          // Scrollable Editor
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: TabularEditor(
                rows: _rows,
                currencySymbol: widget.currencySymbol,
                decimalPlaces: widget.decimalPlaces,
                currentTransactionAmount: widget.currentTransactionAmount,
                onChanged: (rows) => setState(() => _rows = rows),
                onSyncTotal: () {
                  widget.onSave(_rows, true);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          // Footer Actions
          Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onSave([], false);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.clearAll),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      widget.onSave(_rows, false);
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
