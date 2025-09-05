import 'package:flutter/material.dart';
import 'menu.dart';
import 'item.dart';

import 'process_element.dart';

class ProcessItemMenu extends ComponentAndSourceMenu {
  ProcessItemMenu(super.controller, super.target, {super.onChanged});

  List<PopupMenuEntry<Item>> getComponentMenu(void Function(Item)? onChanged) {

    return [
      PopupMenuItem(
        child: const Text("Добавить событие"),
        onTap: () {
          var item = ProcessElement("Событие");
          controller.layoutModel.addItem(target, item);
          onChanged!(item);
        },
      ),
      PopupMenuItem(
        child: const Text("Удалить процесс"),
        onTap: () {
          controller.layoutModel.deleteItem(controller.layoutModel.curItem);
          onChanged!(controller.layoutModel.curItem);
        },
      ),
    ];
  }
}