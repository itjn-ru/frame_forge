import 'package:flutter/material.dart';
import 'menu.dart';
import 'item.dart';

class FormCheckboxMenu extends ComponentAndSourceMenu {
  FormCheckboxMenu(super.controller, super.target, {super.onChanged});

  @override
  List<PopupMenuEntry<Item>> getComponentMenu(void Function(Item)? onChanged) {
    return [
      PopupMenuItem(
        child: const Text("Удалить флажок"),
        onTap: () {
  controller.layoutModel.deleteItem(target);
          onChanged!(target);
        },
      )
    ];
  }
}
