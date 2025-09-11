import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../ui_kit/ui_kit.dart';
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
        return PropertyBorderRadiusWidget(controller, propertyKey)
            as PropertyWidget;
      case const (CustomBorderStyle):
        return PropertyBorderStyleWidget(controller, propertyKey)
            as PropertyWidget;
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
        return PropertyAlignmentWidget(controller, propertyKey)
            as PropertyWidget;
      case const (Style):
        return PropertyStyleWidget(controller, propertyKey) as PropertyWidget;
      case const (FontWeight):
        return PropertyFontWeightWidget(controller, propertyKey)
            as PropertyWidget;
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
class InputTextPropertyWidget extends PropertyWidget {
  const InputTextPropertyWidget(
    super.controller,
    super.propertyKey, {
    super.key,
  });

  Property? get property =>
      controller.getCurrentItem()?.properties[propertyKey];

  void _emitChange() {
    controller.eventBus.emit(
      AttributeChangeEvent(
        id: const Uuid().v4(),
        itemId: controller.selectedId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String defaultValue = property?.value?.toString() ?? '';
    final bool isDouble = switch (property?.type) {
      const (double) => true,
      _ => false,
    };

    final Widget field = isDouble
        ? NumericPropertyTextField(
            defaultValue: defaultValue,
            onChanged: (String v) => property?.value = double.tryParse(v),
            onSubmitted: _emitChange,
            onTapOutside: _emitChange,
            onTabPressed: _emitChange,
            onFocusLost: _emitChange,
          )
        : PropertyTextField(
            defaultValue: defaultValue,
            onChanged: (String v) => property?.value = v,
            onSubmitted: _emitChange,
            onTapOutside: _emitChange,
            onTabPressed: _emitChange,
            onFocusLost: _emitChange,
          );

    return Row(children: <Widget>[Expanded(child: field)]);
  }
}
