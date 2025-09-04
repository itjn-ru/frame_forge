import 'package:flutter/material.dart';
import '../flutter_context_menu/flutter_context_menu.dart';
import 'component.dart';
import 'controller/events.dart';
import 'menu.dart';
import 'component_table.dart';
import 'item.dart';

class ComponentTableMenu extends ComponentAndSourceMenu {
  ComponentTableMenu(super.controller, super.target, {super.onChanged});

  @override
  List<PopupMenuEntry<Item>> getComponentMenu(void Function(Item?)? onChanged) {
    if (target is LayoutComponent) {
      return [
        PopupMenuItem(
          child: const Text('Добавить колонку'),
          onTap: () {
            var item = ComponentTableColumn('колонка');
            controller.layoutModel.addItem(target, item);
            onChanged!(item);
          },
        ),
        PopupMenuItem(
          child: const Text('Добавить группу строк'),
          onTap: () {
            var item = ComponentTableRowGroup('группа строк');
            controller.layoutModel.addItem(target, item);
            onChanged!(item);
          },
          //value: ComponentTable("Таблица"),
        ),
        PopupMenuItem(
          child: const Text('Удалить таблицу'),
          onTap: () {
            controller.layoutModel.deleteItem(target);

//            controller.layoutModel.curPage.items.remove(controller.layoutModel.curItem);
//            controller.layoutModel.curItem = controller.layoutModel.curPage;

            onChanged!(target);
          },
        ),
      ];
    } else {
      switch (target.runtimeType) {
        case const (ComponentTableColumn):
          return [
            PopupMenuItem(
              onTap: controller.layoutModel
                          .getComponentByItem(target)!
                          .items
                          .whereType<ComponentTableColumn>()
                          .length >
                      1
                  ? () {
                      controller.layoutModel.deleteItem(target);
                      onChanged!(target);
                    }
                  : null,
              child: const Text('Удалить колонку'),
            ),
          ];
        case const (ComponentTableRowGroup):
          return [
            PopupMenuItem(
              child: const Text('Добавить строку'),
              onTap: () {
                var item = ComponentTableRow('строка');
                controller.layoutModel.addItem(target, item);
                onChanged!(item);
              },
            ),
            PopupMenuItem(
              onTap: controller.layoutModel
                      .getComponentByItem(target)!
                      .items
                      .whereType<ComponentTableRowGroup>()
                      .isNotEmpty
                  ? () {
                      controller.layoutModel.deleteItem(target);
                      onChanged!(target);
                    }
                  : null,
              child: const Text('Удалить группу строк'),
            ),
          ];

        case const (ComponentTableRow):
          //Ищем группу строк, владеющую этой строкой
          ComponentTableRowGroup? foundGroup;
          controller.layoutModel
              .getComponentByItem(target)!
              .items
              .whereType<ComponentTableRowGroup>()
              .forEach((rowGroup) {
            if (rowGroup.items.where((row) => row == target).isNotEmpty) {
              foundGroup = rowGroup;
            }
          });

          if (foundGroup == null) {
            return [];
          }

          return [
            PopupMenuItem(
              onTap: foundGroup!.items.whereType<ComponentTableRow>().length > 1
                  ? () {
                      controller.layoutModel.deleteItem(target);
                      onChanged!(target);
                    }
                  : null,
              child: const Text('Удалить строку'),
            ),
          ];

        default:
          return [];
      }
    }
  }

  @override
  List<ContextMenuEntry> getContextMenu(
      void Function(LayoutModelEvent event)? onChanged) {
    if (target is LayoutComponent) {
      return [
        const MenuHeader(text: "Редактирование"),
        MenuItem.submenu(
          label: 'Добавить',
          icon: Icons.add,
          items: [
            MenuItem(
              label: 'Колонку',
              icon: Icons.view_column_outlined,
              onSelected: () {
                var item = ComponentTableColumn('колонка');
                controller.layoutModel.addItem(target, item);
                onChanged!(AddItemEvent(id: item.id));
              },
            ),
            MenuItem(
              label: 'Группу строк',
              icon: Icons.table_rows,
              onSelected: () {
                var item = ComponentTableRowGroup('группа строк');
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
        MenuItem(
          label: 'Удалить',
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
          return [
            const MenuHeader(text: "Редактирование"),
            MenuItem(
              label: 'Удалить колонку',
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
          return [
            const MenuHeader(text: "Редактирование"),
            MenuItem(
              label: 'Добавить строку',
              icon: Icons.add,
              onSelected: () {
                var item = ComponentTableRow('строка');
                controller.layoutModel.addItem(target, item);

                onChanged!(AddItemEvent(id: target.id));
              },
            ),
            MenuItem(
              label: 'Удалить группу строк',
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
              .forEach((rowGroup) {
            if (rowGroup.items.where((row) => row == target).isNotEmpty) {
              foundGroup = rowGroup;
            }
          });

          if (foundGroup == null) {
            return [];
          }
          return [
            const MenuHeader(text: "Редактирование"),
            MenuItem(
              label: 'Удалить строку',
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
    return [];
  }
}
