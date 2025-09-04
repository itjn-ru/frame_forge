import 'package:flutter/material.dart';
import 'item.dart';
import 'menu.dart';

class FormImageMenu extends ComponentAndSourceMenu {
  FormImageMenu(super.controller, super.target, {super.onChanged});

  @override
  List<PopupMenuEntry<Item>> getComponentMenu(void Function(Item)? onChanged) {
    return [
      PopupMenuItem(
        child: const Text("Удалить картинку"),
        onTap: () {
  controller.layoutModel.deleteItem(target);
          onChanged!(target);
        },
      )
    ];
  }
}
