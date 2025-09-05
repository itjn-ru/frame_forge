import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'controller/events.dart';
import 'property_widget.dart';

class PropertyOffsetWidget extends PropertyWidget {
  const PropertyOffsetWidget(super.controller, super.propertyKey, {super.key});
  void _emitChange() {
    controller.eventBus.emit(
      ChangeItem(
        id: const Uuid().v4(),
        itemId: controller.getCurrentItem()?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = controller
        .getItemById(controller.selectedId)
        ?.properties[propertyKey];
    final Offset offset = property?.value ?? Offset.zero;

    final controllerDx = TextEditingController(text: offset.dx.toString());
    final controllerDy = TextEditingController(text: offset.dy.toString());

    void updateDx(String value) {
      property?.value = Offset(double.tryParse(value) ?? 0, offset.dy);
    }

    void updateDy(String value) {
      property?.value = Offset(offset.dx, double.tryParse(value) ?? 0);
    }

    return Row(
      children: [
        const Text("Л: "),
        Expanded(
          child: TextField(
            controller: controllerDx,
            onTap: _emitChange,
            onSubmitted: (_) => _emitChange(),
            onTapOutside: (_) => _emitChange(),
            onEditingComplete: _emitChange,
            onChanged: updateDx,
          ),
        ),
        const Text("В: "),
        Expanded(
          child: TextField(
            controller: controllerDy,
            onTap: _emitChange,
            onSubmitted: (_) => _emitChange(),
            onTapOutside: (_) => _emitChange(),
            onEditingComplete: _emitChange,
            onChanged: updateDy,
          ),
        ),
      ],
    );
  }
}
