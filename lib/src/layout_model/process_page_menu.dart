import 'package:flutter/material.dart';
import 'package:frame_forge/src/layout_model/process_group.dart';

import '../../frame_forge.dart';
import '../flutter_context_menu/components/menu_divider.dart';
import '../flutter_context_menu/components/menu_header.dart';
import '../flutter_context_menu/components/menu_item.dart';
import '../flutter_context_menu/core/models/context_menu_entry.dart';

class ProcessPageMenu extends ComponentAndSourceMenu {
  ProcessPageMenu(super.controller, super.target, {super.onChanged});

  @override
  List<ContextMenuEntry> getContextMenu(
    void Function(LayoutModelEvent event)? onChanged,
  ) {
    return <ContextMenuEntry>[
      const MenuHeader(text: 'Editing'),
      MenuItem.submenu(
        label: 'Add Process Group',
        icon: Icons.add,
        items: <ContextMenuEntry>[
          MenuItem(
            label: 'Parallelly',
            icon: Icons.widgets,
            onSelected: () {
              final ProcessGroup item = ProcessGroup('Parallel Process');
              item.properties['processType']?.value = 'parallelly';
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
          MenuItem(
            label: 'Sequentially',
            icon: Icons.widgets,
            onSelected: () {
              final ProcessGroup item = ProcessGroup('Sequential Process');
              item.properties['processType']?.value = 'sequentially';
              controller.layoutModel.addItem(target, item);
              onChanged!(AddItemEvent(id: item.id));
            },
          ),
        ],
      ),
      const MenuDivider(),
      MenuItem(
        label: 'Copy',
        icon: Icons.delete,
        onSelected: () {
          controller.clipboard.copySelection();
        },
      ),
      MenuItem(
        label: 'Paste',
        icon: Icons.delete,
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
      MenuItem(
        label: 'Delete',
        icon: Icons.delete,
        onSelected: () {
          controller.layoutModel.deleteItem(controller.layoutModel.curItem);
          onChanged!(RemoveItemEvent(id: controller.layoutModel.curItem.id));
        },
      ),
    ];
  }
}
