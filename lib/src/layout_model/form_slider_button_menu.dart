import 'package:flutter/material.dart';
import 'item.dart';
import 'menu.dart';

class FormSliderButtonMenu extends ComponentAndSourceMenu {
  FormSliderButtonMenu(super.controller, super.target, {super.onChanged});

  List<PopupMenuEntry<Item>> getComponentMenu(void Function(Item)? onChanged) {
    return [
      PopupMenuItem(
        child: const Text("Удалить переключатель"),
        onTap: () {
          controller.layoutModel.deleteItem(target);
          onChanged!(target);
        },
      )
    ];
  }
}