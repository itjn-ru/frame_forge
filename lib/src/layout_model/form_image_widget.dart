import 'package:flutter/material.dart';

import 'component_decoration_widget.dart';
import 'component_widget.dart';

class FormImageWidget extends ComponentWidget {
  final double scaleFactor;
  const FormImageWidget(
      {required super.component, super.key, required this.scaleFactor});

  @override
  Widget buildWidget(BuildContext context) {
    return ComponentDecorationWidget(
      component: component,
      scaleFactor: scaleFactor,
      child: Image.memory(component.properties['Uint8List']?.value,
          fit: component.properties['BoxFit']?.value ?? BoxFit.none),
    );
  }
}
