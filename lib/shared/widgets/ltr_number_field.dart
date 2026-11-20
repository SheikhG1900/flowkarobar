import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Input formatters for decimal quantity / amount fields.
final ltrDecimalInputFormatters = <TextInputFormatter>[
  // Character-class allowlist (anchored ^…$ patterns break caret edits in RTL).
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text;
    if ('.'.allMatches(text).length <= 1) return newValue;
    return oldValue;
  }),
];

/// Forces LTR editing for numeric values.
///
/// Wraps the field in [Directionality.ltr] so digits type correctly in RTL
/// locales. Under that LTR decorator:
/// - [InputDecoration.prefixText] → left
/// - [InputDecoration.suffixText] → right
///
/// So for currency, use [AmountFormatter.currencyAffix] with the **app**
/// RTL flag (read outside this widget): LTR → prefix, RTL → suffix, which
/// places the symbol on opposite sides.
class LtrNumberField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final int? maxLength;
  final TextAlign? textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;

  const LtrNumberField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.onChanged,
    this.validator,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLength,
    this.textAlign,
    this.inputFormatters,
    this.keyboardType =
        const TextInputType.numberWithOptions(decimal: true),
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        enabled: enabled,
        readOnly: readOnly,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters ?? ltrDecimalInputFormatters,
        textAlign: textAlign ?? TextAlign.start,
        decoration: decoration,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}
