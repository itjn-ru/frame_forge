import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../ui_kit/ui_kit.dart';
import 'controller/events.dart';
import 'property_widget.dart';

/// Widget for editing offset properties
/// Handles left (dx) and top (dy) offsets
class PropertyOffsetWidget extends PropertyWidget {
  const PropertyOffsetWidget(super.controller, super.propertyKey, {super.key});
  
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
    final Offset offset = property?.value ?? Offset.zero;

    void updateDx(String value) {
      property?.value = Offset(double.tryParse(value) ?? 0, offset.dy);
    }

    void updateDy(String value) {
      property?.value = Offset(offset.dx, double.tryParse(value) ?? 0);
    }

    return DualPropertyTextField(
      firstLabel: "Л",
      secondLabel: "В",
      firstValue: offset.dx.toString(),
      secondValue: offset.dy.toString(),
      onFirstChanged: updateDx,
      onSecondChanged: updateDy,
      onSubmitted: _emitChange,
      onTapOutside: _emitChange,
      onTabPressed: _emitChange,
      onFocusLost: _emitChange,
    );
  }
}
