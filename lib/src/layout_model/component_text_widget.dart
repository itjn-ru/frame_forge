import 'package:flutter/material.dart';
import 'package:frame_forge/src/layout_model/component_decoration_widget.dart';
import 'canvas/layout_model_provider.dart';
import 'component_widget.dart';
import 'style_element.dart';

/// A widget that displays text with styles defined in a StyleElement.
/// It uses ComponentDecorationWidget to apply decorations like borders, background color, and padding.
class ComponentTextWidget extends ComponentWidget {
  final double scaleFactor;
  const ComponentTextWidget({
    required this.scaleFactor,
    required super.component,
    super.key,
  });

  @override
  Widget buildWidget(BuildContext context) {
    String text = component["text"];
    final controller = LayoutModelControllerProvider.of(context);
    final layoutModel = controller.layoutModel;
    StyleElement style =
        layoutModel.getStyleElementById(component['style'].id) ??
        StyleElement("стиль");
    final alignment = component['alignment'];

    // Transform Alignment to TextAlign
    TextAlign getTextAlign(dynamic alignment) {
      if (alignment is Alignment) {
        if (alignment.x < -0.5) return TextAlign.left;
        if (alignment.x > 0.5) return TextAlign.right;
        return TextAlign.center;
      }
      return TextAlign.left; // default
    }

    final TextStyle textStyle = TextStyle(
      color: style['color'],
      fontSize: style['fontSize'] * scaleFactor,
      fontWeight: style['fontWeight'],
    );
    return ComponentDecorationWidget(
      component: component,
      scaleFactor: scaleFactor,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: textStyle,
              textAlign: getTextAlign(alignment),
            ),
          ),
        ],
      ),
    );
  }
}
