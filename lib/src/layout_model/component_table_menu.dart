import 'package:flutter/material.dart';

import '../flutter_context_menu/flutter_context_menu.dart';
import 'component.dart';
import 'component_table.dart';
import 'controller/events.dart';
import 'item.dart';
import 'menu.dart';

class ComponentTableMenu extends ComponentAndSourceMenu {
  ComponentTableMenu(super.controller, super.target, {super.onChanged});

  @override
  List<ContextMenuEntry> getContextMenu(
    void Function(LayoutModelEvent event)? onChanged,
  ) {
    if (target is LayoutComponent) {
      return <ContextMenuEntry>[
        const MenuHeader(text: 'Editing'),
        MenuItem.submenu(
          label: 'Add',
          icon: Icons.add,
          items: <ContextMenuEntry>[
            MenuItem(
              label: 'Column',
              icon: Icons.view_column_outlined,
              onSelected: () {
                final ComponentTableColumn item =
                    ComponentTableColumn('column');
                controller.layoutModel.addItem(target, item);
                onChanged!(AddItemEvent(id: item.id));
              },
            ),
            MenuItem(
              label: 'Row Group',
              icon: Icons.table_rows,
              onSelected: () {
                final ComponentTableRowGroup item =
                    ComponentTableRowGroup('row group');
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
        MenuItem(
          label: 'Delete',
          icon: Icons.delete,
          onSelected: () {
            controller.layoutModel.deleteItem(target);
            onChanged!(RemoveItemEvent(id: target.id));
          },
        ),
      ];
    } else {
      switch (target.runtimeType) {
        case const (ComponentTableColumn):
          return <ContextMenuEntry>[
            const MenuHeader(text: 'Editing'),
            MenuItem(
              label: 'Delete column',
              icon: Icons.delete,
              onSelected: controller.layoutModel
                          .getComponentByItem(target)!
                          .items
                          .whereType<ComponentTableColumn>()
                          .length >
                      1
                  ? () {
                      controller.layoutModel.deleteItem(target);
                      onChanged!(RemoveItemEvent(id: target.id));
                    }
                  : null,
            ),
          ];
        case const (ComponentTableRowGroup):
          return <ContextMenuEntry>[
            const MenuHeader(text: 'Editing'),
            MenuItem(
              label: 'Add Row',
              icon: Icons.add,
              onSelected: () {
                final ComponentTableRow item = ComponentTableRow('row');
                controller.layoutModel.addItem(target, item);

                onChanged!(AddItemEvent(id: target.id));
              },
            ),
            MenuItem(
              label: 'Delete group of rows',
              icon: Icons.delete,
              onSelected: controller.layoutModel
                      .getComponentByItem(target)!
                      .items
                      .whereType<ComponentTableRowGroup>()
                      .isNotEmpty
                  ? () {
                      controller.layoutModel.deleteItem(target);
                      onChanged!(RemoveItemEvent(id: target.id));
                    }
                  : null,
            ),
          ];
        case const (ComponentTableRow):
          //Ищем группу строк, владеющую этой строкой
          ComponentTableRowGroup? foundGroup;
          controller.layoutModel
              .getComponentByItem(target)!
              .items
              .whereType<ComponentTableRowGroup>()
              .forEach((ComponentTableRowGroup rowGroup) {
            if (rowGroup.items.where((Item row) => row == target).isNotEmpty) {
              foundGroup = rowGroup;
            }
          });

          if (foundGroup == null) {
            return <ContextMenuEntry>[];
          }
          return <ContextMenuEntry>[
            const MenuHeader(text: 'Editing'),
            MenuItem(
              label: 'Delete row',
              icon: Icons.delete,
              onSelected:
                  foundGroup!.items.whereType<ComponentTableRow>().length > 1
                      ? () {
                          controller.layoutModel.deleteItem(target);
                          onChanged!(RemoveItemEvent(id: target.id));
                        }
                      : null,
            ),
          ];
      }
    }
    return <ContextMenuEntry>[];
  }
}
