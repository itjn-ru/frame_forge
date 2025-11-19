import 'package:flutter/widgets.dart';

import 'component.dart';
import 'property.dart';

class FormTextField extends LayoutComponent {
  FormTextField(String name) : super('textField', name) {
    properties['text'] = Property('text', '');
    properties['caption'] = Property('caption', '');
    properties['text_button'] = Property('текст кнопки', '');
    properties['source'] = Property('source', '');
    properties['alignment'] =
        Property('alignment', Alignment.centerLeft, type: Alignment);
    properties['required'] = Property('isRequired', false, type: bool);
  }
}
