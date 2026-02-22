import 'package:flutter/material.dart';
import 'package:flowpaisa/core/theme/app_colors.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';
import 'package:flowpaisa/l10n/app_localizations.dart';

/// Operation applied to the amount (stacked, undoable in order).
enum _CalcOpType { multiply, divide, percent }

class _CalcOp {
  final _CalcOpType type;
  final double operand;

  _CalcOp({required this.type, required this.operand});
}

/// Fixed size for all operation buttons so the wrap arranges them evenly.
const double _kOpButtonSize = 56;

/// Custom financial calculator: multiply (×2..×9), divide (/2../9), percent (slider).
/// No keypad; operates on the initial amount. All operations are stacked and undoable.
class AmountCalculatorSheet extends StatefulWidget {
  final double initialAmount;
  final String currencySymbol;
  final int decimalPlaces;
  final void Function(double result) onDone;

  const AmountCalculatorSheet({
    super.key,
    required this.initialAmount,
    required this.currencySymbol,
    required this.decimalPlaces,
    required this.onDone,
  });

  /// Shows the calculator as a modal bottom sheet. [onDone] is called with the result when user taps Done.
  static Future<void> show(
    BuildContext context, {
    required double initialAmount,
    required String currencySymbol,
    required int decimalPlaces,
    required void Function(double result) onDone,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AmountCalculatorSheet(
        initialAmount: initialAmount,
        currencySymbol: currencySymbol,
        decimalPlaces: decimalPlaces,
        onDone: onDone,
      ),
    );
  }

  @override
  State<AmountCalculatorSheet> createState() => _AmountCalculatorSheetState();
}

class _AmountCalculatorSheetState extends State<AmountCalculatorSheet> {
  final List<_CalcOp> _stack = [];

  double get _currentValue {
    double v = widget.initialAmount;
    for (final op in _stack) {
      switch (op.type) {
        case _CalcOpType.multiply:
          v = v * op.operand;
          break;
        case _CalcOpType.divide:
          v = op.operand != 0 ? v / op.operand : v;
          break;
        case _CalcOpType.percent:
          v = v * (op.operand / 100);
          break;
      }
    }
    return v;
  }

  String get _resultFormatted => AmountFormatter.formatWithCurrency(
      _currentValue, widget.currencySymbol, widget.decimalPlaces);

  /// Value after applying the first [count] operations (0 = initial amount).
  double _valueAfterStep(int count) {
    if (count <= 0) return widget.initialAmount;
    double v = widget.initialAmount;
    for (var i = 0; i < count && i < _stack.length; i++) {
      final op = _stack[i];
      switch (op.type) {
        case _CalcOpType.multiply:
          v = v * op.operand;
          break;
        case _CalcOpType.divide:
          v = op.operand != 0 ? v / op.operand : v;
          break;
        case _CalcOpType.percent:
          v = v * (op.operand / 100);
          break;
      }
    }
    return v;
  }

  /// Go to calculation state [index]. State 0 = original amount, state i = after (i-1)th op.
  /// Clicking current state (index == _stack.length) does nothing.
  void _goToState(int index) {
    if (index <= 0) {
      setState(() => _stack.clear());
      return;
    }
    if (index >= _stack.length) return; // already at this state
    setState(() => _stack.removeRange(index, _stack.length));
  }

  Color _colorForOp(_CalcOp op) {
    switch (op.type) {
      case _CalcOpType.multiply:
        return AppColors.incomeColor;
      case _CalcOpType.divide:
        return AppColors.expenseColor;
      case _CalcOpType.percent:
        return AppColors.receivableColor;
    }
  }

  String _labelForOp(_CalcOp op) {
    switch (op.type) {
      case _CalcOpType.multiply:
        return '×${op.operand.toInt()}';
      case _CalcOpType.divide:
        return '/${op.operand.toInt()}';
      case _CalcOpType.percent:
        return '${op.operand.toStringAsFixed(0)}%';
    }
  }

  void _applyMultiply(int n) {
    setState(() =>
        _stack.add(_CalcOp(type: _CalcOpType.multiply, operand: n.toDouble())));
  }

  void _applyDivide(int n) {
    if (n == 0) return;
    setState(() =>
        _stack.add(_CalcOp(type: _CalcOpType.divide, operand: n.toDouble())));
  }

  void _openPercentDrawer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _PercentSliderSheet(
        amount: _currentValue,
        currencySymbol: widget.currencySymbol,
        decimalPlaces: widget.decimalPlaces,
        onApply: (percent) {
          Navigator.pop(ctx);
          setState(() =>
              _stack.add(_CalcOp(type: _CalcOpType.percent, operand: percent)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final bottomPadding = MediaQuery.of(context).padding.bottom + 16;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: bottomPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.amountCalculatorTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Current result
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _resultFormatted,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                // Calculation states: first chip = original amount, then one per applied op. Tap to go to that state. LTR for numbers/ops.
                const SizedBox(height: 12),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // State 0: original amount
                      _StackChip(
                        label: l10n.amountCalculatorOriginal,
                        amountText: AmountFormatter.formatWithCurrency(
                          widget.initialAmount,
                          widget.currencySymbol,
                          widget.decimalPlaces,
                        ),
                        color: theme.colorScheme.outline,
                        onTap: () => _goToState(0),
                      ),
                      // State 1..n: after each operation
                      ...List.generate(_stack.length, (i) {
                        final op = _stack[i];
                        final amountAfter = _valueAfterStep(i + 1);
                        final stateIndex = i + 1;
                        return _StackChip(
                          label: _labelForOp(op),
                          amountText: AmountFormatter.formatWithCurrency(
                            amountAfter,
                            widget.currencySymbol,
                            widget.decimalPlaces,
                          ),
                          color: _colorForOp(op),
                          onTap: () => _goToState(stateIndex),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // All operations in one wrap: ×2..×9, /2../9, %. LTR so order is consistent.
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...[2, 3, 4, 5, 6, 7, 8, 9].map((n) => SizedBox(
                            width: _kOpButtonSize,
                            height: _kOpButtonSize,
                            child: _OpChip(
                              label: '×$n',
                              color: AppColors.incomeColor,
                              onTap: () => _applyMultiply(n),
                            ),
                          )),
                      ...[2, 3, 4, 5, 6, 7, 8, 9].map((n) => SizedBox(
                            width: _kOpButtonSize,
                            height: _kOpButtonSize,
                            child: _OpChip(
                              label: '/$n',
                              color: AppColors.expenseColor,
                              onTap: () => _applyDivide(n),
                            ),
                          )),
                      SizedBox(
                        width: _kOpButtonSize,
                        height: _kOpButtonSize,
                        child: _OpChip(
                          label: '%',
                          color: AppColors.receivableColor,
                          onTap: _openPercentDrawer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Done
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      widget.onDone(_currentValue);
                      Navigator.pop(context);
                    },
                    child: Text(l10n.done),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip showing one applied operation and the calculated amount; tap to undo back to that step.
class _StackChip extends StatelessWidget {
  final String label;
  final String amountText;
  final Color color;
  final VoidCallback onTap;

  const _StackChip({
    required this.label,
    required this.amountText,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.25 : 0.15),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                amountText,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OpChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox.expand(
      child: Material(
        color: color.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.25 : 0.15),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PercentSliderSheet extends StatefulWidget {
  final double amount;
  final String currencySymbol;
  final int decimalPlaces;
  final void Function(double percent) onApply;

  const _PercentSliderSheet({
    required this.amount,
    required this.currencySymbol,
    required this.decimalPlaces,
    required this.onApply,
  });

  @override
  State<_PercentSliderSheet> createState() => _PercentSliderSheetState();
}

class _PercentSliderSheetState extends State<_PercentSliderSheet> {
  double _percent = 100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final calculatedValue = widget.amount * (_percent / 100);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.amountCalculatorPercent,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_percent.toStringAsFixed(0)}%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.receivableColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AmountFormatter.formatWithCurrency(
                    calculatedValue,
                    widget.currencySymbol,
                    widget.decimalPlaces,
                  ),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.receivableColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: _percent,
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: AppColors.receivableColor,
              onChanged: (v) => setState(() => _percent = v),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => widget.onApply(_percent),
              child: Text(l10n.done),
            ),
          ],
        ),
      ),
    );
  }
}
