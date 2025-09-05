import 'package:flutter/widgets.dart';
import 'component.dart';
import 'component_radio_widget.dart';
import 'component_table.dart';
import 'component_text.dart';
import 'form_checkbox.dart';
import 'form_checkbox_widget.dart';
import 'form_expandble_list.dart';
import 'form_expandble_list_widget.dart';
import 'form_hidden_field.dart';
import 'form_image.dart';
import 'form_image_widget.dart';
import 'form_radio.dart';
import 'form_text_field.dart';
import 'component_group.dart';
import 'component_group_widget.dart';
import 'component_table_widget.dart';
import 'component_text_widget.dart';
import 'form_hidden_field_widget.dart';
import 'form_text_field_widget.dart';

/// Base widget for rendering layout components.
///
/// [ComponentWidget] is the foundation for all visual components in the layout.
/// It provides a factory method to create appropriate widget types based on
/// the component's runtime type.
///
/// Example usage:
/// ```dart
/// ComponentWidget.create(myComponent)
/// ```
class ComponentWidget extends StatelessWidget {
  /// The layout component to render.
  final LayoutComponent component;

  /// Creates a [ComponentWidget] for the given [component].
  const ComponentWidget(
      {super.key,
      required this.component});

  /// Factory method to create the appropriate widget for a [component].
  ///
  /// Automatically selects the correct widget implementation based on
  /// the component's runtime type (FormRadio, ComponentGroup, etc.).
  factory ComponentWidget.create(LayoutComponent component,
     ) {
    switch (component.runtimeType) {
      case const (FormHiddenField):
        return FormHiddenFieldWidget(
            component: component
            );
      case const (FormRadio):
        return ComponentRadioWidget(
            component: component);
      case const (ComponentGroup):
        return ComponentGroupWidget(
            component: component);
      case const (ComponentText):
        return ComponentTextWidget(
            component: component);
      case const (ComponentTable):
        return ComponentTableWidget(
            component: component);
      case const (FormTextField):
        return FormTextFieldWidget(
            component: component);
      case const (FormImage):
        return FormImageWidget(
            component: component);
      case const (FormCheckbox):
        return FormCheckboxWidget(
            component: component);
      case const (FormExpandbleList):
        return FormExpandbleListWidget(
            component: component);
      default:
        return ComponentWidget(
            component: component);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildWidget(context),
    );
  }

  Widget buildWidget(BuildContext context) {
    return Text(component.type);
  }
}
