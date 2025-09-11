import 'package:frame_forge/src/color_picker/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../ui_kit/ui_kit.dart';
import 'controller/events.dart';
import 'property.dart';
import 'property_widget.dart';
import 'style.dart';

/// Widget for editing border style properties
/// Handles width, color, and side of the border
class PropertyBorderStyleWidget extends PropertyWidget {
  const PropertyBorderStyleWidget(
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
    final Property? property = controller.getCurrentItem()?.properties[propertyKey]!;
    final String widthValue = property?.value?.width.toString() ?? '';

    const List<CustomBorderSide> sides = CustomBorderSide.values;

    if (!sides.contains(property?.value.side)) {
      property?.value.side = CustomBorderSide.none;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text('Width: '),
            Expanded(
              child: NumericPropertyTextField(
                defaultValue: widthValue,
                onChanged: (String value) {
                  property?.value.width = double.tryParse(value) ?? 0;
                },
                onSubmitted: _emitChange,
                onTapOutside: _emitChange,
                onTabPressed: _emitChange,
                onFocusLost: _emitChange,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: property?.value.color,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Choose a color!'),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: property?.value?.color, //default color
                        onColorChanged: (Color color) {
                          property?.value.color = color;
                          Navigator.of(context).pop();
                          _emitChange();
                        },
                      ),
                    ),
                  );
                },
              );
            },
            child: const Text('Color'),
          ),
        ),
        DropdownButton<CustomBorderSide>(
          value: property?.value.side,
          isExpanded: true,
          items: sides
              .map<DropdownMenuItem<CustomBorderSide>>(
                (CustomBorderSide e) => DropdownMenuItem<CustomBorderSide>(value: e, child: Text(e.title)),
              )
              .toList(),
          onChanged: (CustomBorderSide? value) {
            property?.value.side = value ?? CustomBorderSide.none;
            _emitChange();
          },
        ),
      ],
    );
  }
}
