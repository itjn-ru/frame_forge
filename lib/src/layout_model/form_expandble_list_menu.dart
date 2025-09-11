import 'package:flutter/material.dart';
import '../flutter_context_menu/flutter_context_menu.dart';
import 'component_group.dart';
import 'component_text.dart';
import 'controller/events.dart';
import 'form_checkbox.dart';
import 'form_text_field.dart';
import 'menu.dart';
import 'component_table.dart';

import 'form_hidden_field.dart';
import 'form_radio.dart';
import 'form_slider_button.dart';

class FormExpandbleListMenu extends ComponentAndSourceMenu {
  FormExpandbleListMenu(super.controller, super.target, {super.onChanged});

  @override
  List<ContextMenuEntry> getContextMenu(
    void Function(LayoutModelEvent event)? onChanged,
  ) {
    return [
      const MenuHeader(text: "Editing"),
      MenuItem.submenu(
        label: 'Add',
        icon: Icons.add,
        items: [
          MenuItem(
            label: 'Add Group',
            icon: Icons.widgets,
            onSelected: () {
              final ComponentGroup item = ComponentGroup("group");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Add Slider',
            icon: Icons.smart_button,
            onSelected: () {
              final FormSliderButton item = FormSliderButton("slider");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Add Text',
            icon: Icons.text_snippet,
            onSelected: () {
              final ComponentText item = ComponentText("text");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Add Table',
            icon: Icons.table_chart,
            onSelected: () {
              final ComponentTable item = ComponentTable("table");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Add Text Field',
            icon: Icons.text_snippet,
            onSelected: () {
              final FormTextField item = FormTextField("text field");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Add Radio Button',
            icon: Icons.radio_button_checked,
            onSelected: () {
              final FormRadio item = FormRadio("radio button");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Add Checkbox',
            icon: Icons.check_box,
            onSelected: () {
              final FormCheckbox item = FormCheckbox("checkbox");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Add Hidden Field',
            icon: Icons.text_fields,
            onSelected: () {
              final FormHiddenField item = FormHiddenField("hidden field");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
        ],
      ),
      const MenuDivider(),
      MenuItem(
        label: 'Copy',
        icon: Icons.copy,
        onSelected: () {
          controller.clipboard.copySelection();
        },
      ),
      MenuItem(
        label: 'Paste',
        icon: Icons.paste,
        onSelected: () {
          controller.clipboard.pasteSelection(parent: target);
        },
      ),
      MenuItem(
        label: 'Cut',
        icon: Icons.content_cut,
        onSelected: () {
          controller.clipboard.cutSelection();
        },
      ),
      const MenuDivider(),
      MenuItem(
        label: 'Delete',
        icon: Icons.delete,
        onSelected: () {
          controller.layoutModel.deleteItem(target);
          onChanged!(RemoveItemEvent(id: target.id));
        },
      ),
    ];
  }
}
