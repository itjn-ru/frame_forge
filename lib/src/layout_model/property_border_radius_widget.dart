import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'controller/events.dart';
import 'controller/layout_model_controller.dart';
import 'custom_border_radius.dart';
import 'property_widget.dart';

class PropertyBorderRadiusWidget extends PropertyWidget {
  const PropertyBorderRadiusWidget(super.controller, super.propertyKey,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return _PropertyBorderRadiusWidget(controller, propertyKey);
  }
}

class _PropertyBorderRadiusWidget extends StatefulWidget {
  final LayoutModelController controller;
  final String propertyKey;
  const _PropertyBorderRadiusWidget(this.controller, this.propertyKey);

  @override
  State<_PropertyBorderRadiusWidget> createState() =>
      __PropertyBorderRadiusWidgetState();
}

class __PropertyBorderRadiusWidgetState
    extends State<_PropertyBorderRadiusWidget> {
  late final property =
      widget.controller.getCurrentItem()?.properties[widget.propertyKey]!;
  final controllerRadius = TextEditingController();
  late CustomBorderRadiusEnum selected;
  @override
  void initState() {
    if (property?.value.runtimeType == BorderRadiusAll ||
        property?.value.runtimeType == BorderRadiusTop ||
        property?.value.runtimeType == BorderRadiusBottom) {
      controllerRadius.text = property?.value?.radius.toString() ?? '0';
    }
    selected = CustomBorderRadiusEnum.values.firstWhere(
        (e) => e.type.runtimeType == property?.value.runtimeType,
        orElse: () => CustomBorderRadiusEnum.none);
    super.initState();
  }

  @override
  void dispose() {
    controllerRadius.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Радиус: '),
            Expanded(
              child: TextField(
                focusNode: FocusNode(),
                controller: controllerRadius,
                onTap: () => onChanged(),
                onSubmitted: (value) => onChanged(),
                onTapOutside: (value) => onChanged(),
                onEditingComplete: () => onChanged(),
                onChanged: (value) => onChanged(),
              ),
            ),
          ],
        ),
        DropdownButton<CustomBorderRadiusEnum>(
          value: selected,
          isExpanded: true,
          items: CustomBorderRadiusEnum.values
              .map<DropdownMenuItem<CustomBorderRadiusEnum>>(
                  (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.title),
                      ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selected = value;
              });
              onChanged();
            }
          },
        ),
      ],
    );
  }

  onChanged() {
    final radius = double.tryParse(controllerRadius.text) ?? 0;
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
    widget.controller.eventBus.emit(ChangeItem(id: const Uuid().v4(), itemId: widget.controller.layoutModel.curItem.id));
  }
}
