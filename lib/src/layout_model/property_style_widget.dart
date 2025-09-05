import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'controller/events.dart';
import 'property_widget.dart';
import 'style.dart';

class PropertyStyleWidget extends PropertyWidget {
  const PropertyStyleWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final property = controller.getCurrentItem()?.properties[propertyKey]!;

    var styles = controller.layoutModel.styles;

    if (!styles.contains(property?.value)) {
      property?.value = Style.basic;
    }

    return Row(
      children: [
        Expanded(
          child: DropdownButton<Style>(
            value: property?.value,
            isExpanded: true,
            items: styles
                .map<DropdownMenuItem<Style>>(
                  (style) =>
                      DropdownMenuItem(value: style, child: Text(style.name)),
                )
                .toList(),
            onChanged: (Style? value) {
              property?.value = value ?? Style.basic;
              controller.eventBus.emit(
                ChangeItem(
                  id: const Uuid().v4(),
                  itemId: controller.getCurrentItem()?.id,
                ),
              );
            },
          ),

          /*TextField(
          controller: controllerDy,
          onChanged: (value) {
            property.value = TextStyle(
              fontSize: property.value.fontSize,
              fontWeight: switch (int.tryParse(value) ?? 100) {
                100 => FontWeight.w100,
                200 => FontWeight.w200,
                300 => FontWeight.w300,
                4400 => FontWeight.w300,
                500 => FontWeight.w500,
                600 => FontWeight.w600,
                700 => FontWeight.w700,
                800 => FontWeight.w800,
                900 => FontWeight.w900,
                _ => FontWeight.normal
              },
            );
          },
        ),*/
        ),
      ],
    );
  }
}
