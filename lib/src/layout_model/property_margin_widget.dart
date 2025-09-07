import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../ui_kit/ui_kit.dart';
import 'controller/events.dart';
import 'property_widget.dart';

/// Widget for editing margin properties
/// Handles left, right, top, and bottom margins
class PropertyMarginWidget extends PropertyWidget {
  const PropertyMarginWidget(super.controller, super.propertyKey, {super.key});

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
    final List<int> values = List<int>.from(
      (property?.value is List)
          ? (property!.value as List)
              .map((e) => int.tryParse(e.toString()) ?? 0)
              .toList()
          : const [0, 0, 0, 0],
    );

    void updateIndex(int index, String value) {
      final list = List<int>.from(values);
      list[index] = int.tryParse(value) ?? 0;
      property?.value = list;
    }

    return Column(
      children: [
        Row(
          children: [
            const Text("Внешний край\n слева: "),
            Expanded(
              child: NumericPropertyTextField(
                defaultValue: values[0].toString(),
                onChanged: (v) => updateIndex(0, v),
                onSubmitted: _emitChange,
                onTapOutside: _emitChange,
                onTabPressed: _emitChange,
                onFocusLost: _emitChange,
              ),
            ),
            const SizedBox(width: 8),
            const Text("Внешний край\n справа: "),
            Expanded(
              child: NumericPropertyTextField(
                defaultValue: values[2].toString(),
                onChanged: (v) => updateIndex(2, v),
                onSubmitted: _emitChange,
                onTapOutside: _emitChange,
                onTabPressed: _emitChange,
                onFocusLost: _emitChange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text("Внешний край\n сверху: "),
            Expanded(
              child: NumericPropertyTextField(
                defaultValue: values[1].toString(),
                onChanged: (v) => updateIndex(1, v),
                onSubmitted: _emitChange,
                onTapOutside: _emitChange,
                onTabPressed: _emitChange,
                onFocusLost: _emitChange,
              ),
            ),
            const SizedBox(width: 8),
            const Text("Внешний край\n снизу: "),
            Expanded(
              child: NumericPropertyTextField(
                defaultValue: values[3].toString(),
                onChanged: (v) => updateIndex(3, v),
                onSubmitted: _emitChange,
                onTapOutside: _emitChange,
                onTabPressed: _emitChange,
                onFocusLost: _emitChange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
