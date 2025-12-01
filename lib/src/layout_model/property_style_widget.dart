import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'controller/events.dart';
import 'property.dart';
import 'property_widget.dart';
import 'style.dart';

class PropertyStyleWidget extends PropertyWidget {
  const PropertyStyleWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final Property? property =
        controller.getCurrentItem()?.properties[propertyKey]!;

    List<Style> styles = controller.layoutModel.styles;

    if (!styles.contains(property?.value)) {
      property?.value = Style.basic;
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: DropdownButton<Style>(
            value: property?.value,
            isExpanded: true,
            items: styles
                .map<DropdownMenuItem<Style>>(
                  (Style style) => DropdownMenuItem<Style>(
                      value: style, child: Text(style.name)),
                )
                .toList(),
            onChanged: (Style? value) {
              property?.value = value ?? Style.basic;
              controller.eventBus.emit(
                AttributeChangeEvent(
                  id: const Uuid().v4(),
                  itemId: controller.getCurrentItem()?.id,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
