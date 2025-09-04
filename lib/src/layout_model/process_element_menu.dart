import 'package:flutter/material.dart';
import '../../frame_forge.dart';
import '../flutter_context_menu/components/menu_divider.dart';
import '../flutter_context_menu/components/menu_header.dart';
import '../flutter_context_menu/components/menu_item.dart';
import '../flutter_context_menu/core/models/context_menu_entry.dart';

class ProcessElementMenu extends ComponentAndSourceMenu {
  ProcessElementMenu(super.controller, super.target, {super.onChanged,});


  @override
  List<ContextMenuEntry> getContextMenu(
      void Function(LayoutModelEvent event)? onChanged) {
    return [
      const MenuHeader(text: "Редактирование"),
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