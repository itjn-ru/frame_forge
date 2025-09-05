import 'package:flutter/material.dart';
import 'menu.dart';
import 'item.dart';

class SourceVariableMenu extends ComponentAndSourceMenu {
  SourceVariableMenu(super.controller, super.target, {super.onChanged});

  List<PopupMenuEntry<Item>> getComponentMenu(void Function(Item)? onChanged) {
    return [
      PopupMenuItem(
        child: const Text('Удалить переменную'),
        onTap: () {
          controller.layoutModel.deleteItem(target);
          onChanged!(target);
        },
      ),
    ];
  }
}
