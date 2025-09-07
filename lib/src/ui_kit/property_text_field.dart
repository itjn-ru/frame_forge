import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable TextField for property widgets with Tab and focus handling
class PropertyTextField extends StatefulWidget {
  final String defaultValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onTapOutside;
  final VoidCallback? onTabPressed;
  final VoidCallback? onFocusLost;
  final String? hintText;
  final String? labelText;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool selectAllOnFocus;

  const PropertyTextField({
    super.key,
    required this.defaultValue,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.onTabPressed,
    this.onFocusLost,
    this.hintText,
    this.labelText,
    this.decoration,
    this.keyboardType,
    this.enabled = true,
    this.selectAllOnFocus = true,
  });

  @override
  State<PropertyTextField> createState() => _PropertyTextFieldState();
}

class _PropertyTextFieldState extends State<PropertyTextField> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    controller.text = widget.defaultValue;
    // Configuring Tab handling
    focusNode.onKeyEvent = (FocusNode node, KeyEvent event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
        widget.onTabPressed?.call();
        // Returning ignored to allow default Tab behavior
        return KeyEventResult.ignored;
      }
      return KeyEventResult.ignored;
    };

    // Listening to focus changes
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        // When gaining focus, select all text (if enabled)
        if (widget.selectAllOnFocus) {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        }
      } else {
        // When losing focus, call the callback
        widget.onFocusLost?.call();
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PropertyTextField oldWidget) {
    if (oldWidget.defaultValue != widget.defaultValue) {
      controller.text = widget.defaultValue;
      if (widget.selectAllOnFocus && focusNode.hasFocus) {
        controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        );
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      decoration:
          widget.decoration ??
          InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            border: const UnderlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
          ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted != null
          ? (_) => widget.onSubmitted!()
          : null,
      onTapOutside: widget.onTapOutside != null
          ? (_) => widget.onTapOutside!()
          : null,
    );
  }
}
