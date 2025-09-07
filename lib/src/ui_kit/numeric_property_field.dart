import 'package:flutter/material.dart';
import 'property_text_field.dart';

/// Specialized TextField for numeric values with Tab handling
class NumericPropertyTextField extends PropertyTextField {
  const NumericPropertyTextField({
    super.key,
    required super.defaultValue,
    super.onChanged,
    super.onSubmitted,
    super.onTapOutside,
    super.onTabPressed,
    super.onFocusLost,
    super.hintText,
    super.labelText,
    super.decoration,
    super.enabled = true,
    super.selectAllOnFocus = true,
  }) : super(keyboardType: TextInputType.number);
}



/// Виджет для ввода пары значений (например, координат, размеров)
class DualPropertyTextField extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;
  final String firstValue;
  final String secondValue;
  final ValueChanged<String>? onFirstChanged;
  final ValueChanged<String>? onSecondChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onTapOutside;
  final VoidCallback? onTabPressed;
  final VoidCallback? onFocusLost;
  final bool enabled;
  final bool selectAllOnFocus;

  const DualPropertyTextField({
    super.key,
    required this.firstLabel,
    required this.secondLabel,
    required this.firstValue,
    required this.secondValue,
    this.onFirstChanged,
    this.onSecondChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.onTabPressed,
    this.onFocusLost,
    this.enabled = true,
    this.selectAllOnFocus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("$firstLabel: "),
        Expanded(
          child: NumericPropertyTextField(
           defaultValue: firstValue,
            onChanged: onFirstChanged,
            onSubmitted: onSubmitted,
            onTapOutside: onTapOutside,
            onTabPressed: onTabPressed,
            onFocusLost: onFocusLost,
            enabled: enabled,
            selectAllOnFocus: selectAllOnFocus,
          ),
        ),
        const SizedBox(width: 8),
        Text("$secondLabel: "),
        Expanded(
          child: NumericPropertyTextField(
            defaultValue: secondValue,
            onChanged: onSecondChanged,
            onSubmitted: onSubmitted,
            onTapOutside: onTapOutside,
            onTabPressed: onTabPressed,
            onFocusLost: onFocusLost,
            enabled: enabled,
            selectAllOnFocus: selectAllOnFocus,
          ),
        ),
      ],
    );
  }
}
