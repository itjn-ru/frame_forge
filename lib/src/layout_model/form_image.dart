import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'component.dart';
import 'property.dart';

class FormImage extends LayoutComponent {
  FormImage(name) : super('image', name) {
    properties['Uint8List'] = Property(
      'imageData',
      Uint8List.fromList(<int>[0]),
      type: Uint8List,
    );
    properties['BoxFit'] = Property(
      'fit',
      BoxFit.contain,
      type: BoxFit,
    );
  }
}
