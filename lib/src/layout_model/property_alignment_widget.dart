import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'controller/events.dart';
import 'property_widget.dart';

class PropertyAlignmentWidget extends PropertyWidget {
  const PropertyAlignmentWidget(
    super.controller,
    super.propertyKey, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final property = controller
        .getItemById(controller.selectedId)
        ?.properties[propertyKey]!;
    return Row(
      children: [
        Expanded(
          child: DropdownButton<Alignment>(
            value: property?.value,
            isExpanded: true,
            items:
                [
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
                      (alignment) => DropdownMenuItem(
                        value: alignment,
                        child: Text(switch (alignment) {
                          Alignment.topLeft => "вверху слева",
                          Alignment.topCenter => "вверху по центру",
                          Alignment.topRight => "вверху справа",
                          Alignment.centerLeft => "по центру слева",
                          Alignment.center => "по центру",
                          Alignment.centerRight => "по центру справа",
                          Alignment.bottomLeft => "внизу слева",
                          Alignment.bottomCenter => "внизу по центру",
                          Alignment.bottomRight => "внизу справа",
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
