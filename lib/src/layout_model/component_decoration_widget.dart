import 'package:flutter/material.dart';

import '../canvas/layout_model_provider.dart';
import 'component.dart';
import 'controller/layout_model_controller.dart';
import 'custom_border_radius.dart';
import 'layout_model.dart';
import 'style_element.dart';

/// A widget that applies decorations like borders, background color, padding, and margin
/// to its child widget based on the styles defined in a StyleElement.
class ComponentDecorationWidget extends StatelessWidget {
  final LayoutComponent component;
  final double scaleFactor;
  final Widget child;

  const ComponentDecorationWidget({
    required this.component,
    required this.scaleFactor,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final LayoutModelController controller =
        LayoutModelControllerProvider.of(context);
    final LayoutModel layoutModel = controller.layoutModel;
    final StyleElement style =
        layoutModel.getStyleElementById(component['style'].id) ??
            StyleElement('style');
    final CustomBorderRadius borderRadiusValue =
        style.properties['borderRadius']?.value;

    final BorderRadius? border = (borderRadiusValue is Type)
        ? null
        : borderRadiusValue.borderRadius(scaleFactor);
    final List<dynamic> padding = style['padding'] ?? <dynamic>[0, 0, 0, 0];
    final List<dynamic> margin = style['margin'] ?? <dynamic>[0, 0, 0, 0];
    // Ensure backgroundColor is a Color (defensive against legacy/int values)
    final dynamic bgRaw = style['backgroundColor'];
    final Color bgColor = bgRaw is Color
        ? bgRaw
        : (bgRaw is int ? Color(bgRaw) : Colors.transparent);

    return Container(
      decoration: BoxDecoration(
        border: _buildBorder(style),
        color: bgColor,
        borderRadius: border,
      ),
      padding: EdgeInsets.fromLTRB(
        padding[0] * scaleFactor,
        padding[1] * scaleFactor,
        padding[2] * scaleFactor,
        padding[3] * scaleFactor,
      ),
      margin: EdgeInsets.fromLTRB(
        margin[0] * scaleFactor,
        margin[1] * scaleFactor,
        margin[2] * scaleFactor,
        margin[3] * scaleFactor,
      ),
      width: component['size'].width * scaleFactor,
      height: component['size'].height * scaleFactor,
      child: child,
    );
  }

  BoxBorder _buildBorder(StyleElement style) {
    return Border(
      top: style.properties['topBorder']?.value.borderSide ?? BorderSide.none,
      bottom:
          style.properties['bottomBorder']?.value.borderSide ?? BorderSide.none,
      left: style.properties['leftBorder']?.value.borderSide ?? BorderSide.none,
      right:
          style.properties['rightBorder']?.value.borderSide ?? BorderSide.none,
    );
  }
}
