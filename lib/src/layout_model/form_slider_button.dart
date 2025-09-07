import 'package:flutter/material.dart';

import 'component.dart';
import 'property.dart';

class FormSliderButton extends LayoutComponent {
  FormSliderButton(name) : super("sliderButton", name) {
    properties["text"] = Property("текст", "");
    properties["source"] = Property("источник", "");
    properties['activeColor'] =
        Property("activeColor", const Color(0xFF6200EE), type: Color);
    properties['inactiveColor'] =
        Property("inactiveColor", const Color(0xFFBDBDBD), type: Color);
    properties['thumbColor'] =
        Property("thumbColor", const Color(0xFF6200EE), type: Color);
  }
}
