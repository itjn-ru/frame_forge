import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../ui_kit/ui_kit.dart';
import 'controller/events.dart';
import 'custom_border_radius.dart';
import 'property_widget.dart';

/// Widget for editing border radius properties
/// Handles different border radius styles: none, all, top, bottom
class PropertyBorderRadiusWidget extends PropertyWidget {
  const PropertyBorderRadiusWidget(
    super.controller,
    super.propertyKey, {
    super.key,
  });

  void _emitChange() {
    controller.eventBus.emit(
      AttributeChangeEvent(
        id: const Uuid().v4(),
        itemId: controller.getCurrentItem()?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = controller.getCurrentItem()?.properties[propertyKey]!;
    final CustomBorderRadiusEnum selected =
        CustomBorderRadiusEnum.fromModel(property?.value);

    double currentRadius = 0;
    final val = property?.value;
    if (val is BorderRadiusAll) currentRadius = val.radius;
    if (val is BorderRadiusTop) currentRadius = val.radius;
    if (val is BorderRadiusBottom) currentRadius = val.radius;

    void updateRadius(String value) {
      final radius = double.tryParse(value) ?? 0;
      switch (selected) {
        case CustomBorderRadiusEnum.none:
          property?.value = const BorderRadiusNone();
        case CustomBorderRadiusEnum.all:
          property?.value = BorderRadiusAll(radius);
        case CustomBorderRadiusEnum.top:
          property?.value = BorderRadiusTop(radius);
        case CustomBorderRadiusEnum.bottom:
          property?.value = BorderRadiusBottom(radius);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Радиус: '),
            Expanded(
              child: NumericPropertyTextField(
                defaultValue: currentRadius.toString(),
                onChanged: updateRadius,
                onSubmitted: _emitChange,
                onTapOutside: _emitChange,
                onTabPressed: _emitChange,
                onFocusLost: _emitChange,
              ),
            ),
          ],
        ),
        DropdownButton<CustomBorderRadiusEnum>(
          value: selected,
          isExpanded: true,
          items: CustomBorderRadiusEnum.values
              .map<DropdownMenuItem<CustomBorderRadiusEnum>>(
                (e) => DropdownMenuItem(value: e, child: Text(e.title)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              final radius = currentRadius;
              switch (value) {
                case CustomBorderRadiusEnum.none:
                  property?.value = const BorderRadiusNone();
                case CustomBorderRadiusEnum.all:
                  property?.value = BorderRadiusAll(radius);
                case CustomBorderRadiusEnum.top:
                  property?.value = BorderRadiusTop(radius);
                case CustomBorderRadiusEnum.bottom:
                  property?.value = BorderRadiusBottom(radius);
              }
              _emitChange();
            }
          },
        ),
      ],
    );
  }
}
