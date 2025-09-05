import 'package:flutter/material.dart';
import 'menu.dart';
import 'item.dart';
import 'source.dart';
import 'source_table.dart';

class SourceTableMenu extends ComponentAndSourceMenu {
  SourceTableMenu(super.controller, super.target, {super.onChanged});

  List<PopupMenuEntry<Item>> getComponentMenu(void Function(Item?)? onChanged) {
    if (controller.layoutModel.curItem is LayoutSource) {
      return [
        PopupMenuItem(
          child: const Text("Добавить колонку"),
          onTap: () {
            var item = SourceTableColumn("колонка");
            controller.layoutModel.addItem(target, item);
            onChanged!(item);
          },
        ),

        PopupMenuItem(
          child: const Text("Удалить таблицу"),
          onTap: () {
            controller.layoutModel.deleteItem(controller.layoutModel.curItem);

//            controller.layoutModel.curPage.items.remove(controller.layoutModel.curItem);
//            controller.layoutModel.curItem = controller.layoutModel.curPage;

            onChanged!(controller.layoutModel.curItem);
          },
        ),
      ];
    } else {
      switch (controller.layoutModel.curItem.runtimeType) {
        case SourceTableColumn:
          return [
            PopupMenuItem(
              onTap: controller.layoutModel.getComponentByItem(target)!.items
                          .whereType<SourceTableColumn>()
                          .length >
                      1
                  ? () {
                      controller.layoutModel.deleteItem(controller.layoutModel.curItem);
                      onChanged!(controller.layoutModel.curItem);
                    }
                  : null,
              child: const Text("Удалить колонку"),
            ),
          ];



        default:
          return [];
      }
    }
  }
}
