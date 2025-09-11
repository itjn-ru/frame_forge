import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'controller/events.dart';
import 'property.dart';
import 'property_widget.dart';

class PropertyAlignmentWidget extends PropertyWidget {
  const PropertyAlignmentWidget(
    super.controller,
    super.propertyKey, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Property?  property = controller
        .getItemById(controller.selectedId)
        ?.properties[propertyKey]!;
    return Row(
      children: <Widget>[
        Expanded(
          child: DropdownButton<Alignment>(
            value: property?.value,
            isExpanded: true,
            items:
                <Alignment>[
                      Alignment.topLeft,
                      Alignment.topCenter,
                      Alignment.topRight,
                      Alignment.centerLeft,
                      Alignment.center,
                      Alignment.centerRight,
                      Alignment.bottomLeft,
                      Alignment.bottomCenter,
                      Alignment.bottomRight,
                    ]
                    .map<DropdownMenuItem<Alignment>>(
                      (Alignment alignment) => DropdownMenuItem(
                        value: alignment,
                        child: Text(switch (alignment) {
                          Alignment.topLeft => "Up left",
                          Alignment.topCenter => "Up center",
                          Alignment.topRight => "Up right",
                          Alignment.centerLeft => "Center left",
                          Alignment.center => "Center",
                          Alignment.centerRight => "Center right",
                          Alignment.bottomLeft => "Bottom left",
                          Alignment.bottomCenter => "Bottom center",
                          Alignment.bottomRight => "Bottom right",
                          _ => "",
                        }),
                      ),
                    )
                    .toList(),
            onChanged: (Object? value) {
              property?.value = value;
              controller.eventBus.emit(
                AttributeChangeEvent(
                  id: const Uuid().v4(),
                  itemId: controller.layoutModel.curItem.id,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
