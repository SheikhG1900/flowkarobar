import 'package:flutter/material.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';

/// A widget that animates a numeric value changes by counting up or down.
class AnimatedAmount extends ImplicitlyAnimatedWidget {
  final double amount;
  final String currencySymbol;
  final int decimalPlaces;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AnimatedAmount({
    super.key,
    required this.amount,
    required this.currencySymbol,
    this.decimalPlaces = 2,
    this.style,
    this.textAlign,
    super.duration = const Duration(milliseconds: 800),
    super.curve = Curves.easeOutCubic,
  });

  @override
  ImplicitlyAnimatedWidgetState<AnimatedAmount> createState() =>
      _AnimatedAmountState();
}

class _AnimatedAmountState extends AnimatedWidgetBaseState<AnimatedAmount> {
  Tween<double>? _amountTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _amountTween = visitor(
      _amountTween,
      widget.amount,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final animatedValue = _amountTween?.evaluate(animation) ?? widget.amount;
    
    return Text(
      AmountFormatter.formatWithCurrency(
        animatedValue,
        widget.currencySymbol,
        widget.decimalPlaces,
      ),
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}
