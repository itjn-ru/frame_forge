import 'package:flutter/material.dart';
import 'component_decoration_widget.dart';
import 'component_widget.dart';

class FormSliderButtonWidget extends ComponentWidget {
  final double scaleFactor;
  const FormSliderButtonWidget({
    required super.component,
    required this.scaleFactor,
    super.key,
  });

  @override
  Widget buildWidget(BuildContext context) {
    return ComponentDecorationWidget(
      component: component,
      scaleFactor: scaleFactor,
      child: Slider(
        value: 1,
        onChanged: (value) {},
        activeColor: component['activeColor'],
        inactiveColor: component['inactiveColor'],
        thumbColor: component['thumbColor'],
      ),
    );
  }
}
