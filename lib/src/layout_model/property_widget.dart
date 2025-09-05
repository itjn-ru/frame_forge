import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'custom_margin.dart';
import 'controller/events.dart';
import 'controller/layout_model_controller.dart';
import 'custom_border_radius.dart';
import 'property.dart';
import 'property_alignment_widget.dart';
import 'property_border_radius_widget.dart';
import 'property_color_widget.dart';
import 'property_font_weight_widget.dart';
import 'property_image_widget.dart';
import 'property_margin_widget.dart';
import 'property_offset_widget.dart';
import 'property_size_widget.dart';
import 'property_style_widget.dart';
import 'property_uuid_widget.dart';
import 'package:uuid/uuid.dart';
import 'property_padding_widget.dart';
import 'style.dart';
import 'property_border_style_widget.dart';

class PropertyWidget extends StatelessWidget {
  final String propertyKey;
  final LayoutModelController controller;
  const PropertyWidget(this.controller, this.propertyKey, {super.key});

  factory PropertyWidget.create(
    LayoutModelController controller,
    String propertyKey,
  ) {
    switch (controller.getCurrentItem()?.properties[propertyKey]?.type) {
      case const (CustomBorderRadius):
        return PropertyBorderRadiusWidget(controller, propertyKey);
      case const (CustomBorderStyle):
        return PropertyBorderStyleWidget(controller, propertyKey);
      case const (Offset):
        return PropertyOffsetWidget(controller, propertyKey);
      case const (CustomMargin):
        return PropertyMarginWidget(controller, propertyKey);
      case const (List<int>):
        return PropertyPaddingWidget(controller, propertyKey);
      case const (Size):
        return PropertySizeWidget(controller, propertyKey);
      case const (Color):
        return PropertyColorWidget(controller, propertyKey);
      case const (Alignment):
        return PropertyAlignmentWidget(controller, propertyKey);
      case const (Style):
        return PropertyStyleWidget(controller, propertyKey);
      case const (FontWeight):
        return PropertyFontWeightWidget(controller, propertyKey);
      case const (UuidValue):
        return PropertyUuidWidget(controller, propertyKey);
      case const (Uint8List):
        return PropertyImageWidget(controller, propertyKey);
      default:
        return PropertyWidget(controller, propertyKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputTextProperty(
      controller,
      propertyKey,
      key: ValueKey(
        controller.getCurrentItem()?.properties['id']?.value ??
            const Uuid().v4(),
      ),
    );
  }
}

class InputTextProperty extends StatefulWidget {
  final LayoutModelController controller;
  final String propertyKey;
  const InputTextProperty(this.controller, this.propertyKey, {super.key});

  @override
  State<InputTextProperty> createState() => _InputTextPropertyState();
}

class _InputTextPropertyState extends State<InputTextProperty> {
  final txtController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Property? get property =>
      widget.controller.getCurrentItem()?.properties[widget.propertyKey];

  @override
  void initState() {
    super.initState();

    final prop = property;
    if (prop != null && prop.value != null) {
      txtController.text = prop.value.toString();
    } else {
      txtController.text = '';
    }
    // _focusNode.addListener(() {
    //     if (!_focusNode.hasFocus) {
    //       onChanged(); // Вызываем onChanged при потере фокуса
    //     }
    //   });
  }

  @override
  void dispose() {
    txtController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: txtController,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onEditingComplete: () => FocusScope.of(context).unfocus(),
            focusNode: _focusNode,
            onChanged: (value) {
              switch (property?.type) {
                case const (double):
                  property?.value = double.tryParse(value);
                default:
                  property?.value = value;
              }
              onChanged();
            },
          ),
        ),
      ],
    );
  }

  void onChanged() {
    widget.controller.eventBus.emit(
      ChangeItem(id: const Uuid().v4(), itemId: widget.controller.selectedId),
    );
    setState(() {}); // перерисовать поле, если нужно
  }
}
