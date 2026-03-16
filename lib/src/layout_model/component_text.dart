import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'component.dart';
import 'property.dart';
import 'source_reference.dart';

class ComponentText extends LayoutComponent {
  ComponentText(String name) : super('text', name) {
    properties['text'] = Property('text', '');
    properties['source'] =
        Property('источник', SourceReference(), type: SourceReference);
    properties['alignment'] = Property(
      'alignment',
      Alignment.centerLeft,
      type: Alignment,
    );
    properties['textFunction'] = Property(
      'generateTextFunction',
      '',
      type: String,
    );
    properties['inputId'] = Property(
      'inputId',
      <String>[],
      type: List<String>,
    );
  }
}
