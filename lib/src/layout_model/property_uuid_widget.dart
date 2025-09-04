import 'package:flutter/material.dart';
import 'property_widget.dart';

class PropertyUuidWidget extends PropertyWidget {
  const PropertyUuidWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final property = controller.layoutModel.curItem.properties[propertyKey]!;

    return Text(property.value.toString());
  }
}
