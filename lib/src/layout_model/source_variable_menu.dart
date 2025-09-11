import 'package:flutter/material.dart';

import '../flutter_context_menu/flutter_context_menu.dart';
import 'controller/events.dart';
import 'menu.dart';
import 'source_variable.dart';

class SourceVariableMenu extends ComponentAndSourceMenu {
  SourceVariableMenu(super.controller, super.target, {super.onChanged});

  @override
  List<ContextMenuEntry> getContextMenu(
    void Function(LayoutModelEvent event)? onChanged,
  ) {
    return [
      MenuItem.submenu(
        label: 'Добавить',
        icon: Icons.add,
        items: [
          MenuItem(
            label: 'Переменную',
            icon: Icons.add,
            onSelected: () {
              final item = SourceVariable('переменная');
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
        label: 'Удалить',
        icon: Icons.delete,
        onSelected: () {
          controller.layoutModel.deleteItem(target);
          onChanged!(RemoveItemEvent(id: target.id));
        },
      ),
    ];
  }
}
