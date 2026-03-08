import 'package:flutter/material.dart';
import 'package:flowpaisa/core/utils/amount_formatter.dart';

/// Displays an amount with a scoreboard-style transition when the value changes:
/// the new number slides in (e.g. from below) and fades in; the old slides out.
/// Use for available amount and summary cards so only the number animates.
class RollingAmount extends StatelessWidget {
  final double amount;
  final String currencySymbol;
  final int decimalPlaces;
  final TextStyle? style;
  final TextAlign? textAlign;

  const RollingAmount({
    super.key,
    required this.amount,
    required this.currencySymbol,
    this.decimalPlaces = 2,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = AmountFormatter.formatWithCurrency(
      amount,
      currencySymbol,
      decimalPlaces,
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: Text(
        formatted,
        key: ValueKey<String>(formatted),
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}
