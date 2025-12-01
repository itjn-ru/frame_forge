import 'package:flutter/material.dart';

import 'component_widget.dart';
import 'hidden_field_file.dart';

class FormHiddenFieldWidget extends ComponentWidget {
  const FormHiddenFieldWidget({required super.component, super.key});

  @override
  Widget buildWidget(BuildContext context) {
    String text = component['source']?.isNotEmpty ?? false
        ? '\$${component["source"]}'
        : '';
    if (text.isEmpty) {
      text = component['text'] ?? '';
    }
    if (component['style']?.name == 'attachment') {
      return HiddenFieldFile(component: component);
    } else if (component['name'] == 'photo') {
      // return PhotoSignHiddenField(component: component);
    }
    return Text(component['id'].toString());
  }
}
