import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'controller/events.dart';
import 'property_widget.dart';

class PropertySizeWidget extends PropertyWidget {
  const PropertySizeWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final property = controller
        .getItemById(controller.selectedId)
        ?.properties[propertyKey]!;
    var controllerWidth = TextEditingController();
    controllerWidth.text = property?.value.width.toString() ?? '';

    var controllerHeight = TextEditingController();
    controllerHeight.text = property?.value.height.toString() ?? '';

    return Row(
      children: [
        const Text("Ш: "),
        Expanded(
          child: TextField(
            focusNode: FocusNode(),
            onTap: () => controller.eventBus.emit(
              ChangeItem(
                id: const Uuid().v4(),
                itemId: controller.layoutModel.curItem.id,
              ),
            ),
            onSubmitted: (value) => controller.eventBus.emit(
              ChangeItem(
                id: const Uuid().v4(),
                itemId: controller.layoutModel.curItem.id,
              ),
            ),
            onTapOutside: (value) => controller.eventBus.emit(
              ChangeItem(
                id: const Uuid().v4(),
                itemId: controller.layoutModel.curItem.id,
              ),
            ),
            onEditingComplete: () => controller.eventBus.emit(
              ChangeItem(
                id: const Uuid().v4(),
                itemId: controller.layoutModel.curItem.id,
              ),
            ),
            controller: controllerWidth,
            onChanged: (value) {
              property?.value = Size(
                double.tryParse(value) ?? 0,
                property.value.height,
              );
            },
          ),
        ),
        const Text("В: "),
        Expanded(
          child: TextField(
            focusNode: FocusNode(),
            onTap: () => controller.eventBus.emit(
              ChangeItem(
                id: const Uuid().v4(),
                itemId: controller.layoutModel.curItem.id,
              ),
            ),
            onSubmitted: (value) => controller.eventBus.emit(
              ChangeItem(
                id: const Uuid().v4(),
                itemId: controller.layoutModel.curItem.id,
              ),
            ),
            onTapOutside: (value) => controller.eventBus.emit(
              ChangeItem(
                id: const Uuid().v4(),
                itemId: controller.layoutModel.curItem.id,
              ),
            ),
            onEditingComplete: () => controller.eventBus.emit(
              ChangeItem(
                id: const Uuid().v4(),
                itemId: controller.layoutModel.curItem.id,
              ),
            ),
            controller: controllerHeight,
            onChanged: (value) {
              property?.value = Size(
                property.value.width,
                double.tryParse(value) ?? 0,
              );
            },
          ),
        ),
      ],
    );
  }
}
