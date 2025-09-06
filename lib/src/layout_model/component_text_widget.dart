import 'package:flutter/material.dart';
import 'package:frame_forge/src/layout_model/component_decoration_widget.dart';
import 'canvas/layout_model_provider.dart';
import 'canvas/screensize_provider.dart';
import 'component_widget.dart';
import 'style_element.dart';

/// A widget that displays text with styles defined in a StyleElement.
/// It uses ComponentDecorationWidget to apply decorations like borders, background color, and padding.
class ComponentTextWidget extends ComponentWidget {
  const ComponentTextWidget({required super.component, super.key});

  @override
  Widget buildWidget(BuildContext context) {
    final screenSize = ScreenSizeProvider.of(context);
    String text = component["text"];
    final controller = LayoutModelControllerProvider.of(context);
    final layoutModel = controller.layoutModel;
    var style =
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / screenSize.width;
        final TextStyle textStyle = TextStyle(
          color: style['color'],
          fontSize: style['fontSize'] * scale,
          fontWeight: style['fontWeight'],
        );
        return ComponentDecorationWidget(
          component: component,
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
      },
    );
  }
}
