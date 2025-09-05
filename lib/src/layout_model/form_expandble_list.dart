import 'package:flutter/material.dart';

import 'component.dart';
import 'component_group.dart';
import 'property.dart';

class FormExpandbleList extends LayoutComponent {
  FormExpandbleList(name) : super("expandblelist", name) {
    properties['expandble'] = Property('развернут', false, type: bool);
    properties['expandedSize'] = Property(
      'расширяемый размер',
      const Size(360, 30),
      type: Size,
    );
    properties["source"] = Property("источник", "");
    items.add(ComponentGroup("заголовок"));
  }
}
