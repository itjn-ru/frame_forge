import 'package:flutter/material.dart';
import '../flutter_context_menu/flutter_context_menu.dart';
import 'component_text.dart';
import 'controller/events.dart';
import 'form_checkbox.dart';
import 'form_text_field.dart';
import 'menu.dart';
import 'component_table.dart';

import 'form_hidden_field.dart';
import 'form_radio.dart';
import 'form_slider_button.dart';

class ComponentGroupMenu extends ComponentAndSourceMenu {
  ComponentGroupMenu(super.controller, super.target, {super.onChanged});

  @override
  List<ContextMenuEntry> getContextMenu(
    void Function(LayoutModelEvent event)? onChanged,
  ) {
    // Removed unused variable pageCount
    return [
      const MenuHeader(text: "Редактирование"),
      MenuItem.submenu(
        label: 'Добавить',
        icon: Icons.add,
        items: [
          MenuItem(
            label: 'Добавить слайдер',
            icon: Icons.smart_button,
            onSelected: () {
              var item = FormSliderButton("слайдер");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Добавить текст',
            icon: Icons.text_snippet,
            onSelected: () {
              var item = ComponentText("текст");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Добавить таблицу',
            icon: Icons.table_chart,
            onSelected: () {
              var item = ComponentTable("таблица");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Добавить текстовое поле',
            icon: Icons.text_snippet,
            onSelected: () {
              var item = FormTextField("текстовое поле");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Добавить радиокнопку',
            icon: Icons.radio_button_checked,
            onSelected: () {
              var item = FormRadio("радиокнопка");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Добавить флажок',
            icon: Icons.check_box,
            onSelected: () {
              var item = FormCheckbox("флажок");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Добавить скрытое поле',
            icon: Icons.text_fields,
            onSelected: () {
              var item = FormHiddenField("скрытое поле");
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
        ],
      ),
      const MenuDivider(),
      MenuItem(
        label: 'Копировать',
        icon: Icons.delete,
        onSelected: () {
          controller.clipboard.copySelection();
        },
      ),
      MenuItem(
        label: 'Вставить',
        icon: Icons.delete,
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
        label: 'Удалить группу',
        icon: Icons.delete,
        onSelected: () {
          controller.layoutModel.deleteItem(target);
          onChanged!(RemoveItemEvent(id: target.id));
        },
      ),
    ];
  }
}
