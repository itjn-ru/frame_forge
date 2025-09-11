import 'dart:typed_data';

import 'component.dart';
import 'property.dart';

class FormImage extends LayoutComponent {
  FormImage(name) : super("image", name) {
    properties["Uint8List"] = Property(
      "imageData",
      Uint8List.fromList([0]),
      type: Uint8List,
    );
  }
}
