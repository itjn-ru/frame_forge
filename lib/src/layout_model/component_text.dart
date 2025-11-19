import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'component.dart';
import 'property.dart';

class ComponentText extends LayoutComponent {
  ComponentText(String name) : super('text', name) {
    properties['text'] = Property('text', '');
    properties['source'] = Property('источник', '');
    properties['alignment'] = Property(
      'alignment',
      Alignment.centerLeft,
      type: Alignment,
    );
    properties['textFunction'] = Property(
      'generateTextFunction',
      null,
      type: String,
    );
    properties['inputId'] = Property(
      'inputId',
      null,
      type: String,
    );
  }
}
