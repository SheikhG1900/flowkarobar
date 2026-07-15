import 'package:flutter/material.dart';

/// A lightweight, beautifully animated inline snap bar (badge/pill)
/// that displays a compact and word representation of the entered amount
/// when the amount is greater than 999.
class AmountSnapBar extends StatefulWidget {
  final TextEditingController controller;
  final String currencySymbol;

  const AmountSnapBar({
    super.key,
    required this.controller,
    required this.currencySymbol,
  });

  @override
  State<AmountSnapBar> createState() => _AmountSnapBarState();
}

class _AmountSnapBarState extends State<AmountSnapBar> {
  double _amount = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _parseAmount();
  }

  @override
  void didUpdateWidget(covariant AmountSnapBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      _parseAmount();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {
        _parseAmount();
      });
    }
  }

  void _parseAmount() {
    final text = widget.controller.text.replaceAll(',', '').trim();
    _amount = double.tryParse(text) ?? 0.0;
  }

  String _formatCompactValue(double value) {
    if (value >= 10) {
      return value.toStringAsFixed(0);
    } else {
      final s = value.toStringAsFixed(1);
      if (s.endsWith('.0')) {
        return s.substring(0, s.length - 2);
      }
      return s;
    }
  }

  String _getCompactAndWords(double amount, BuildContext context) {
    final absAmount = amount.abs();
    if (absAmount < 1000) return '';

    final locale = Localizations.localeOf(context).languageCode;
    final isHindi = locale == 'hi';
    final isUrdu = locale == 'ur';

    if (isHindi) {
      // Indian numbering system: Thousand, Lakh, Crore (Hindi)
      if (absAmount >= 10000000) { // 1 Crore = 10,000,000
        final val = absAmount / 10000000;
        final formattedVal = _formatCompactValue(val);
        return '$formattedVal Cr ($formattedVal करोड़)';
      } else if (absAmount >= 100000) { // 1 Lakh = 100,000
        final val = absAmount / 100000;
        final formattedVal = _formatCompactValue(val);
        return '$formattedVal L ($formattedVal लाख)';
      } else { // Thousand
        final val = absAmount / 1000;
        final formattedVal = _formatCompactValue(val);
        return '$formattedVal K ($formattedVal हज़ार)';
      }
    } else if (isUrdu) {
      // Indian numbering system: Thousand, Lakh, Crore (Urdu)
      if (absAmount >= 10000000) { // 1 Crore = 10,000,000
        final val = absAmount / 10000000;
        final formattedVal = _formatCompactValue(val);
        return '$formattedVal Cr ($formattedVal کروڑ)';
      } else if (absAmount >= 100000) { // 1 Lakh = 100,000
        final val = absAmount / 100000;
        final formattedVal = _formatCompactValue(val);
        return '$formattedVal L ($formattedVal لاکھ)';
      } else { // Thousand
        final val = absAmount / 1000;
        final formattedVal = _formatCompactValue(val);
        return '$formattedVal K ($formattedVal ہزار)';
      }
    } else {
      // International numbering system: Thousand, Million, Billion (English/Default)
      if (absAmount >= 1000000000) {
        final val = absAmount / 1000000000;
        final formattedVal = _formatCompactValue(val);
        return '$formattedVal B ($formattedVal Billion)';
      } else if (absAmount >= 1000000) {
        final val = absAmount / 1000000;
        final formattedVal = _formatCompactValue(val);
        return '$formattedVal M ($formattedVal Million)';
      } else {
        final val = absAmount / 1000;
        final formattedVal = _formatCompactValue(val);
        return '$formattedVal K ($formattedVal Thousand)';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_amount < 1000) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayText = _getCompactAndWords(_amount, context);

    if (displayText.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  displayText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
