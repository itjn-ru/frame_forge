import 'package:flutter/material.dart';
import 'canvas/layout_model_provider.dart';
import 'component_widget.dart';
import 'style_element.dart';

class FormCheckboxWidget extends ComponentWidget {
  const FormCheckboxWidget({required super.component, super.key});

  @override
  Widget buildWidget(BuildContext context) {
    final controller = LayoutModelControllerProvider.of(context);
    final layoutModel = controller.layoutModel;
    StyleElement style =
        layoutModel.getStyleElementById(component['style'].id) ??
        StyleElement("стиль");
    final double fontSize = style['fontSize'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (component.properties["text"]?.value != null)
          Expanded(
            child: Text(
              '${component.properties["text"]?.value}: ',
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        const Checkbox(value: true, onChanged: null),
      ],
    );
  }
}
