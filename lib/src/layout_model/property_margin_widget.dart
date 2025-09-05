import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'controller/events.dart';
import 'controller/layout_model_controller.dart';
import 'property_widget.dart';

class PropertyMarginWidget extends PropertyWidget {
  const PropertyMarginWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text("Внешний край\n слева: "),
            MarginStyleWidget(
              controller: controller,
              propertyKey: propertyKey,
              index: 0,
            ),
            const Text("Внешний край\n справа: "),
            MarginStyleWidget(
              controller: controller,
              propertyKey: propertyKey,
              index: 2,
            ),
          ],
        ),
        Row(
          children: [
            const Text("Внешний край\n сверху: "),
            MarginStyleWidget(
              controller: controller,
              propertyKey: propertyKey,
              index: 1,
            ),
            const Text("Внешний край\n снизу: "),
            MarginStyleWidget(
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

class MarginStyleWidget extends StatefulWidget {
  final LayoutModelController controller;
  final String propertyKey;
  final int index;
  const MarginStyleWidget({
    required this.controller,
    required this.propertyKey,
    required this.index,
    super.key,
  });

  @override
  State<MarginStyleWidget> createState() => _MarginStyleWidgetState();
}

class _MarginStyleWidgetState extends State<MarginStyleWidget> {
  late final property = widget.controller
      .getCurrentItem()
      ?.properties[widget.propertyKey]!;
  var controller = TextEditingController();

  @override
  void initState() {
    controller.text = property?.value[widget.index].toString() ?? '0';
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
