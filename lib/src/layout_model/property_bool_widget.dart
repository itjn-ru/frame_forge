import 'package:flutter/material.dart';
import 'package:frame_forge/src/layout_model/property.dart';
import 'package:uuid/uuid.dart';

import 'controller/events.dart';
import 'property_widget.dart';

enum BoolOption {
  trueOption(value: true, displayText: 'Yes'),
  falseOption(value: false, displayText: 'No');

  final String displayText;
  final bool value;
  const BoolOption({required this.value, required this.displayText});
}

class PropertyBoolWidget extends PropertyWidget {
  const PropertyBoolWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final Property? property =
        controller.getCurrentItem()?.properties[propertyKey]!;
    final bool? initialValue = property?.value as bool?;
    return Row(children: <Widget>[
      Expanded(
        child: DropdownButton<BoolOption>(
          value: initialValue == true
              ? BoolOption.trueOption
              : BoolOption.falseOption,
          isExpanded: true,
          items: BoolOption.values
              .map<DropdownMenuItem<BoolOption>>(
                  (BoolOption option) => DropdownMenuItem(
                        value: option,
                        child: Text(option.displayText),
                      ))
              .toList(),
          onChanged: (BoolOption? value) {
            property?.value = value?.value ?? BoolOption.falseOption.value;
            controller.eventBus.emit(ChangeItem(
                id: const Uuid().v4(),
                itemId: controller.getCurrentItem()?.id));
          },
        ),
      ),
    ]);
  }
}
