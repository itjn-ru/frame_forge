import 'package:flutter/material.dart';

import 'canvas/layout_model_provider.dart';
import 'component.dart';
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
    final controller = LayoutModelControllerProvider.of(context);
    final layoutModel = controller.layoutModel;
    var style =
        layoutModel.getStyleElementById(component['style'].id) ??
        StyleElement("стиль");
    final borderRadiusValue = style.properties['borderRadius']?.value;

        final border = (borderRadiusValue == null || borderRadiusValue is Type)
            ? null
            : borderRadiusValue.borderRadius(scaleFactor);
        final padding = style['padding'] ?? [0, 0, 0, 0];
        final margin = style['margin'] ?? [0, 0, 0, 0];
        return Container(
          decoration: BoxDecoration(
            border: _buildBorder(style),
            color: style['backgroundColor'],
            borderRadius: border,
          ),
          alignment: style['alignment'] ?? Alignment.bottomRight,
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
      bottom: style.properties['bottomBorder']?.value.borderSide ?? BorderSide.none,
      left: style.properties['leftBorder']?.value.borderSide ?? BorderSide.none,
      right: style.properties['rightBorder']?.value.borderSide ?? BorderSide.none,
    );
  }
}
