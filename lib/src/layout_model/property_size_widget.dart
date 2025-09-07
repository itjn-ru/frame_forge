import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../ui_kit/ui_kit.dart';
import 'controller/events.dart';
import 'property_widget.dart';

class PropertySizeWidget extends PropertyWidget {
  const PropertySizeWidget(super.controller, super.propertyKey, {super.key});
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
    final property = controller
        .getItemById(controller.selectedId)
        ?.properties[propertyKey];
    final Size size = property?.value ?? Size.zero;

    void updateWidth(String value) {
      property?.value = Size(double.tryParse(value) ?? 0, size.height);
    }

    void updateHeight(String value) {
      property?.value = Size(size.width, double.tryParse(value) ?? 0);
    }

    return DualPropertyTextField(
      firstLabel: "Ш",
      secondLabel: "В",
      firstValue: size.width.toString(),
      secondValue: size.height.toString(),
      onFirstChanged: updateWidth,
      onSecondChanged: updateHeight,
      onSubmitted: _emitChange,
      onTapOutside: _emitChange,
      onTabPressed: _emitChange,
      onFocusLost: _emitChange,
    );
  }
}
