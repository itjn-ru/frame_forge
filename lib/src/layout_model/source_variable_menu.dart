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
    return <ContextMenuEntry>[
      MenuItem.submenu(
        label: 'Add',
        icon: Icons.add,
        items: <ContextMenuEntry>[
          MenuItem(
            label: 'Variable',
            icon: Icons.add,
            onSelected: () {
              final SourceVariable item = SourceVariable('variable');
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
