import 'package:frame_forge/src/layout_model/process_element.dart';
import 'package:flutter/material.dart';
import '../../frame_forge.dart';
import '../flutter_context_menu/components/menu_divider.dart';
import '../flutter_context_menu/components/menu_header.dart';
import '../flutter_context_menu/components/menu_item.dart';
import '../flutter_context_menu/core/models/context_menu_entry.dart';
import 'process_group.dart';

class ProcessGroupMenu extends ComponentAndSourceMenu {
  ProcessGroupMenu(super.controller, super.target, {super.onChanged});

  @override
  List<ContextMenuEntry> getContextMenu(
    void Function(LayoutModelEvent event)? onChanged,
  ) {
    return [
      const MenuHeader(text: "Редактирование"),
      MenuItem.submenu(
        label: 'Добавить группу процессов',
        icon: Icons.add,
        items: [
          MenuItem(
            label: 'Параллельно',
            icon: Icons.widgets,
            onSelected: () {
              var item = ProcessGroup("Параллельный процесс");
              item.properties['processType']?.value = 'параллельно';
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Последовательно',
            icon: Icons.widgets,
            onSelected: () {
              var item = ProcessGroup("Последовательный процесс");
              item.properties['processType']?.value = 'последовательно';
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
        ],
      ),
      MenuItem(
        label: 'Добавить процесс',
        icon: Icons.add,
        onSelected: () {
          var item = ProcessElement("процесс");
          controller.layoutModel.addItem(target, item);
          onChanged!(AddItemEvent(id: item.id));
        },
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
      MenuItem(
        label: 'Удалить',
        icon: Icons.delete,
        onSelected: () {
          var item = ProcessElement("процесс");
          controller.layoutModel.deleteItem(controller.layoutModel.curItem);
          onChanged!(RemoveItemEvent(id: item.id));
        },
      ),
    ];
  }
}
