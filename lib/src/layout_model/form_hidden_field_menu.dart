import 'package:flutter/material.dart';
import 'menu.dart';
import 'item.dart';

class FormHiddenFieldMenu extends ComponentAndSourceMenu {
  FormHiddenFieldMenu(super.controller, super.target, {super.onChanged});

  List<PopupMenuEntry<Item>> getComponentMenu(void Function(Item)? onChanged) {
    return [
      PopupMenuItem(
        child: const Text("Удалить скрытое поле"),
        onTap: () {
          controller.layoutModel.deleteItem(target);
          onChanged!(target);
        },
      )
    ];
  }
}
