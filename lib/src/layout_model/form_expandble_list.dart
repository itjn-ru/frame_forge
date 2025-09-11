import 'package:flutter/material.dart';

import 'component.dart';
import 'component_group.dart';
import 'property.dart';

class FormExpandbleList extends LayoutComponent {
  FormExpandbleList(String name) : super("expandblelist", name) {
    properties['expandble'] = Property('expanded', false, type: bool);
    properties['expandedSize'] = Property(
      'expanded size',
      const Size(360, 30),
      type: Size,
    );
    properties["source"] = Property("source", "");
    items.add(ComponentGroup("header"));
  }
}
