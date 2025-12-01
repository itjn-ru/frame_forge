import 'package:flutter/material.dart';

import 'component.dart';
import 'property.dart';

class FormSliderButton extends LayoutComponent {
  FormSliderButton(String name) : super('sliderButton', name) {
    properties['text'] = Property('text', '');
    properties['source'] = Property('source', '');
    properties['activeColors'] = Property(
      'activeColors',
      <Color>[const Color(0xFF6200EE)],
      type: List<Color>,
    );
    properties['inactiveColor'] = Property(
      'inactiveColor',
      const Color(0xFFBDBDBD),
      type: Color,
    );
    properties['thumbColor'] = Property(
      'thumbColor',
      const Color(0xFF6200EE),
      type: Color,
    );
    properties['hintText'] = Property(
      'hintText',
      <String>[],
      type: List<String>,
    );
    properties['initialValue'] = Property(
      'initialValue',
      0,
      type: int,
    );
  }
}
