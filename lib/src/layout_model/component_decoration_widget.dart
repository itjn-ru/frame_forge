import 'package:flutter/material.dart';

import 'canvas/layout_model_provider.dart';
import 'canvas/screensize_provider.dart';
import 'component.dart';
import 'style_element.dart';

/// A widget that applies decorations like borders, background color, padding, and margin
/// to its child widget based on the styles defined in a StyleElement.
class ComponentDecorationWidget extends StatelessWidget {
  final LayoutComponent component;
  final Widget child;
  const ComponentDecorationWidget({
    required this.component,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSizeProvider.of(context);
    final controller = LayoutModelControllerProvider.of(context);
    final layoutModel = controller.layoutModel;
    var style =
        layoutModel.getStyleElementById(component['style'].id) ??
        StyleElement("стиль");
    final borderRadiusValue = style.properties['borderRadius']?.value;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / screenSize.width;
        final border = (borderRadiusValue == null || borderRadiusValue is Type)
            ? null
            : borderRadiusValue.borderRadius(scale);
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
            padding[0] * scale,
            padding[1] * scale,
            padding[2] * scale,
            padding[3] * scale,
          ),
          margin: EdgeInsets.fromLTRB(
            margin[0] * scale,
            margin[1] * scale,
            margin[2] * scale,
            margin[3] * scale,
          ),
          width: component['size'].width * scale,
          height: component['size'].height * scale,
          child: child,
        );
      },
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
