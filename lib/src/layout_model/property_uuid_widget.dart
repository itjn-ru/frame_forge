import 'package:flutter/material.dart';

import 'property.dart';
import 'property_widget.dart';

class PropertyUuidWidget extends PropertyWidget {
  const PropertyUuidWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final Property? property =
        controller.layoutModel.curItem.properties[propertyKey];

    return Text(
        property?.value.toString() ?? '00000000-0000-0000-0000-000000000000');
  }
}
