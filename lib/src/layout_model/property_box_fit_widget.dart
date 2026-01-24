import 'package:flutter/material.dart';
import 'package:frame_forge/frame_forge.dart';
import 'package:frame_forge/src/layout_model/property.dart';
import 'package:uuid/uuid.dart';

import 'property_widget.dart';

class PropertyBoxFitWidget extends PropertyWidget {
  const PropertyBoxFitWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final Property? property =
        controller.layoutModel.curItem.properties[propertyKey];
    return ShowBoxFitProperty(
        property: property, propertyKey: propertyKey, controller: controller);
  }
}

class ShowBoxFitProperty extends StatefulWidget {
  final Property? property;
  final String propertyKey;
  final LayoutModelController controller;
  const ShowBoxFitProperty(
      {super.key,
      this.property,
      required this.propertyKey,
      required this.controller});

  @override
  State<ShowBoxFitProperty> createState() => _ShowBoxFitPropertyState();
}

class _ShowBoxFitPropertyState extends State<ShowBoxFitProperty> {
  @override
  Widget build(BuildContext context) {
    final Property? property =
        widget.controller.getCurrentItem()?.properties[widget.propertyKey];
    return DropdownButton<BoxFit>(
      value: property?.value as BoxFit? ?? BoxFit.contain,
      onChanged: (BoxFit? newValue) {
        property?.value = newValue;
        widget.controller.eventBus.emit(ChangeItem(
            id: const Uuid().v4(),
            itemId: widget.controller.getCurrentItem()?.id));
        setState(() {});
      },
      items: BoxFit.values.map<DropdownMenuItem<BoxFit>>((BoxFit value) {
        return DropdownMenuItem<BoxFit>(
          value: value,
          child: Text(value.toString().split('.').last),
        );
      }).toList(),
    );
  }
}
