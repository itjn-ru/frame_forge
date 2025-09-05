import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'controller/events.dart';
import 'controller/layout_model_controller.dart';
import 'property_widget.dart';

class PropertyPaddingWidget extends PropertyWidget {
  const PropertyPaddingWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text("Отступ слева: "),
            PaddingStyleWidget(
              controller: controller,
              propertyKey: propertyKey,
              index: 0,
            ),
            const Text("Отступ справа: "),
            PaddingStyleWidget(
              controller: controller,
              propertyKey: propertyKey,
              index: 2,
            ),
          ],
        ),
        Row(
          children: [
            const Text("Отступ сверху: "),
            PaddingStyleWidget(
              controller: controller,
              propertyKey: propertyKey,
              index: 1,
            ),
            const Text("Отступ снизу: "),
            PaddingStyleWidget(
              controller: controller,
              propertyKey: propertyKey,
              index: 3,
            ),
          ],
        ),
      ],
    );
  }
}

class PaddingStyleWidget extends StatefulWidget {
  final LayoutModelController controller;
  final String propertyKey;
  final int index;
  const PaddingStyleWidget({
    required this.controller,
    required this.propertyKey,
    required this.index,
    super.key,
  });

  @override
  State<PaddingStyleWidget> createState() => _PaddingStyleWidgetState();
}

class _PaddingStyleWidgetState extends State<PaddingStyleWidget> {
  late final property = widget.controller
      .getCurrentItem()
      ?.properties[widget.propertyKey]!;
  var controller = TextEditingController();

  @override
  void initState() {
    controller.text = property?.value[widget.index].toString() ?? '';
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        focusNode: FocusNode(),
        onSubmitted: (value) => onChanged(),
        onTapOutside: (value) => onChanged(),
        onEditingComplete: onChanged,
        controller: controller,
        onChanged: (value) =>
            property?.value[widget.index] = int.tryParse(value) ?? 0,
      ),
    );
  }

  onChanged() {
    widget.controller.eventBus.emit(
      ChangeItem(
        id: const Uuid().v4(),
        itemId: widget.controller.layoutModel.curItem.id,
      ),
    );
  }
}
