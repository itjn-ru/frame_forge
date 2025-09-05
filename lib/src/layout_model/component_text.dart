import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'component.dart';
import 'property.dart';

class ComponentText extends LayoutComponent {
  ComponentText(name) : super('text', name) {
    properties['text'] = Property('текст', '');
    properties['alignment'] = Property(
      'выравнивание',
      Alignment.centerLeft,
      type: Alignment,
    );
  }
}
