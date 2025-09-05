import 'package:flutter/material.dart';
import 'menu.dart';
import 'item.dart';

class FormRadioMenu extends ComponentAndSourceMenu {
  FormRadioMenu(super.controller, super.target, {super.onChanged});

  List<PopupMenuEntry<Item>> getComponentMenu(void Function(Item)? onChanged) {
    return [
      PopupMenuItem(
        child: const Text("Удалить радиокнопку"),
        onTap: () {
          controller.layoutModel.deleteItem(target);
          onChanged!(target);
        },
      ),
    ];
  }
}
