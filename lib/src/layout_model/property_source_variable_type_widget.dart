import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'controller/events.dart';
import 'property.dart';
import 'property_widget.dart';
import 'source_variable.dart';

/// A dropdown widget for selecting the type of a SourceVariable.
class PropertySourceVariableTypeWidget extends PropertyWidget {
  const PropertySourceVariableTypeWidget(
    super.controller,
    super.propertyKey, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Property? property =
        controller.getCurrentItem()?.properties[propertyKey];
    if (property == null) return const SizedBox.shrink();

    final String currentValue = property.value is SourceVariableType
        ? (property.value as SourceVariableType).value
        : property.value?.toString() ?? 'String';

    return Row(
      children: <Widget>[
        Expanded(
          child: DropdownButton<String>(
            value: sourceVariableTypes.contains(currentValue)
                ? currentValue
                : 'String',
            isExpanded: true,
            items: sourceVariableTypes
                .map<DropdownMenuItem<String>>(
                  (String type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  ),
                )
                .toList(),
            onChanged: (String? value) {
              property.value = SourceVariableType(value ?? 'String');
              controller.eventBus.emit(
                AttributeChangeEvent(
                  id: const Uuid().v4(),
                  itemId: controller.selectedId,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
