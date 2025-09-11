import 'package:flutter/material.dart';
import '../flutter_context_menu/flutter_context_menu.dart';
import 'component.dart';
import 'component_group.dart';
import 'component_table_menu.dart';
import 'component_text.dart';
import 'controller/events.dart';
import 'controller/layout_model_controller.dart';
import 'form_checkbox.dart';
import 'form_checkbox_menu.dart';
import 'form_expandble_list.dart';
import 'form_expandble_list_menu.dart';
import 'form_hidden_field.dart';
import 'form_hidden_field_menu.dart';
import 'form_image_menu.dart';
import 'form_slider_button.dart';
import 'form_slider_button_menu.dart';
import 'item.dart';
import 'page.dart';
import 'process.dart';
import 'process_element.dart';
import 'process_element_menu.dart';
import 'process_group.dart';
import 'process_group_menu.dart';
import 'process_item_menu.dart';
import 'process_page_menu.dart';
import 'style.dart';
import 'style_element.dart';
import 'style_element_menu.dart';
import 'style_page_menu.dart';
import 'root.dart';
import 'source.dart';
import 'source_page_menu.dart';
import 'source_variable.dart';
import 'source_variable_menu.dart';
import 'component_group_menu.dart';
import 'component_page_menu.dart';
import 'component_root_menu.dart';
import 'component_table.dart';
import 'component_text_menu.dart';
import 'form_image.dart';
import 'form_radio.dart';
import 'form_radio_menu.dart';
import 'form_text_field.dart';
import 'form_text_field_menu.dart';

/// Context menu provider for layout components and data sources.
///
/// [ComponentAndSourceMenu] generates appropriate context menus for different
/// types of layout elements, providing operations like add, delete, and modify
/// based on the target element type.
class ComponentAndSourceMenu {
  /// The controller managing the layout model state.
  final LayoutModelController controller;

  /// The target item for which the menu is being created.
  final Item target;

  /// Optional callback invoked when the target item is changed.
  final void Function(Item?)? onChanged;

  /// Creates a new context menu for the specified [target] item.
  const ComponentAndSourceMenu(this.controller, this.target, {this.onChanged});

  /// Factory constructor that creates the appropriate menu type based on the [target].
  ///
  /// Returns a specialized menu implementation (like [ComponentPageMenu],
  /// [ComponentGroupMenu], etc.) depending on the target's runtime type.
  ///
  /// - [onChanged]: Optional callback for item changes
  /// - [onDeleted]: Optional callback for item deletion
  factory ComponentAndSourceMenu.create(
    LayoutModelController controller,
    Item target, {
    void Function(Item?)? onChanged,
    Function(Item?)? onDeleted,
  }) {
    if (target is Root) {
      return ComponentRootMenu(controller, target, onChanged: onChanged);
    } else if (target is ComponentPage) {
      return ComponentPageMenu(controller, target, onChanged: onChanged);
    } else if (target is ComponentGroup) {
      return ComponentGroupMenu(controller, target, onChanged: onChanged);
    } else if (target is ProcessGroup) {
      return ProcessGroupMenu(controller, target, onChanged: onChanged);
    } else if (target is SourcePage) {
      return SourcePageMenu(controller, target, onChanged: onChanged);
    } else if (target is StylePage) {
      return StylePageMenu(controller, target, onChanged: onChanged);
    } else if (target is ProcessPage) {
      return ProcessPageMenu(controller, target, onChanged: onChanged);
    } else if (target is ProcessElement) {
      return ProcessElementMenu(controller, target, onChanged: onChanged);
    } else if (target is LayoutComponent ||
        target is LayoutSource ||
        target is LayoutStyle ||
        target is LayoutProcess) {
      switch (target.runtimeType) {
        case const (ComponentTable):
          return ComponentTableMenu(controller, target, onChanged: onChanged);
        case const (ComponentText):
          return ComponentTextMenu(controller, target, onChanged: onChanged);
        case const (FormImage):
          return FormImageMenu(controller, target, onChanged: onChanged);
        case const (FormSliderButton):
          return FormSliderButtonMenu(controller, target, onChanged: onChanged);
        case const (FormRadio):
          return FormRadioMenu(controller, target, onChanged: onChanged);
        case const (FormCheckbox):
          return FormCheckboxMenu(controller, target, onChanged: onChanged);
        case const (FormHiddenField):
          return FormHiddenFieldMenu(controller, target, onChanged: onChanged);
        case const (FormTextField):
          return FormTextFieldMenu(controller, target, onChanged: onChanged);
        case const (SourceVariable):
          return SourceVariableMenu(controller, target, onChanged: onChanged);
        case const (StyleElement):
          return StyleElementMenu(controller, target, onChanged: onChanged);
        case const (ProcessElement):
          return ProcessItemMenu(controller, target, onChanged: onChanged);
        case const (FormExpandbleList):
          return FormExpandbleListMenu(
            controller,
            target,
            onChanged: onChanged,
          );
        default:
          return ComponentAndSourceMenu(
            controller,
            target,
            onChanged: onChanged,
          );
      }
    } else {
      var component = controller.layoutModel.getComponentByItem(target);

      if (component == null) {
        return ComponentAndSourceMenu(controller, target, onChanged: onChanged);
      }

      switch (component.runtimeType) {
        case const (ComponentTable):
          return ComponentTableMenu(controller, target, onChanged: onChanged);
        default:
          return ComponentAndSourceMenu(
            controller,
            target,
            onChanged: onChanged,
          );
      }
    }
  }

  List<ContextMenuEntry> getContextMenu(
    Function(LayoutModelEvent event)? onChanged,
  ) {
    return [
      const MenuHeader(text: "Редактирование"),
      MenuItem(
        label: 'Копировать',
        icon: Icons.copy,
        onSelected: () {
          controller.clipboard.copySelection();
        },
      ),
      MenuItem(
        label: 'Вставить',
        icon: Icons.content_paste,
        onSelected: () {
          controller.clipboard.pasteSelection(parent: target);
        },
      ),
      MenuItem(
        label: 'Вырезать',
        icon: Icons.content_cut,
        onSelected: () {
          controller.clipboard.cutSelection();
        },
      ),
      const MenuDivider(),
      MenuItem(
        label: 'Удалить',
        icon: Icons.delete,
        onSelected: () {
          // Use undoable delete instead of direct model manipulation
          final itemToDelete = controller.getItemById(target.id);
          if (itemToDelete != null) {
            controller.select(target.id);
            controller.deleteSelected();
          }
          onChanged!(RemoveItemEvent(id: target.id));
        },
      ),
    ];
  }
}
