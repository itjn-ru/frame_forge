import '../color_picker/color_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'controller/events.dart';
import 'property.dart';
import 'property_widget.dart';

class PropertyColorWidget extends PropertyWidget {
  const PropertyColorWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final Property? property = controller.getCurrentItem()?.properties[propertyKey]!;
    return Row(
      children: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: property?.value),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Choose a color!'),
                  content: SingleChildScrollView(
                    child: BlockPicker(
                      pickerColor: property?.value,
                      onColorChanged: (Color color) {
                        property?.value = color;
                        Navigator.of(context).pop();
                        controller.eventBus.emit(
                          ChangeItem(
                            id: const Uuid().v4(),
                            itemId: controller.layoutModel.curItem.id,
                          ),
                        );
                      },
                    ),
                  ),

                  /*actions: <Widget>[
                  ElevatedButton(
                    child: const Text('DONE'),
                    onPressed: () {
                      Navigator.of(context).pop(); //dismiss the color picker
                    },
                  ),
                ],*/
                );
              },
            );
          },
          child: const Text("Color Picker"),
        ),
      ],
    );
  }
}
