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

/// Base class for property widgets - kept for backward compatibility
class PropertyWidget extends StatelessWidget {
  final String propertyKey;
  final LayoutModelController controller;
  
  const PropertyWidget(this.controller, this.propertyKey, {super.key});

  /// Factory method for creating appropriate property widgets based on type
  factory PropertyWidget.create(
    LayoutModelController controller,
    String propertyKey,
  ) {
    switch (controller.getCurrentItem()?.properties[propertyKey]?.type) {
      case const (CustomBorderRadius):
        return PropertyBorderRadiusWidget(controller, propertyKey) as PropertyWidget;
      case const (CustomBorderStyle):
        return PropertyBorderStyleWidget(controller, propertyKey) as PropertyWidget;
      case const (Offset):
        return PropertyOffsetWidget(controller, propertyKey) as PropertyWidget;
      case const (CustomMargin):
        return PropertyMarginWidget(controller, propertyKey) as PropertyWidget;
      case const (List<int>):
        return PropertyPaddingWidget(controller, propertyKey) as PropertyWidget;
      case const (Size):
        return PropertySizeWidget(controller, propertyKey) as PropertyWidget;
      case const (Color):
        return PropertyColorWidget(controller, propertyKey) as PropertyWidget;
      case const (Alignment):
        return PropertyAlignmentWidget(controller, propertyKey) as PropertyWidget;
      case const (Style):
        return PropertyStyleWidget(controller, propertyKey) as PropertyWidget;
      case const (FontWeight):
        return PropertyFontWeightWidget(controller, propertyKey) as PropertyWidget;
      case const (UuidValue):
        return PropertyUuidWidget(controller, propertyKey) as PropertyWidget;
      case const (Uint8List):
        return PropertyImageWidget(controller, propertyKey) as PropertyWidget;
      default:
        return PropertyWidget(controller, propertyKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputTextPropertyWidget(controller, propertyKey);
  }
}

/// Default text input property widget for unhandled types
class InputTextPropertyWidget extends StatefulWidget {
  final String propertyKey;
  final LayoutModelController controller;
  
  const InputTextPropertyWidget(this.controller, this.propertyKey, {super.key});

  @override
  State<InputTextPropertyWidget> createState() => _InputTextPropertyWidgetState();
}

class _InputTextPropertyWidgetState extends State<InputTextPropertyWidget> {
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
      AttributeChangeEvent(id: const Uuid().v4(), itemId: widget.controller.selectedId),
    );
    setState(() {}); // перерисовать поле, если нужно
  }
}
