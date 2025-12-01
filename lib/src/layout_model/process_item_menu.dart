import 'package:flutter/material.dart';

import 'item.dart';
import 'menu.dart';
import 'process_element.dart';

class ProcessItemMenu extends ComponentAndSourceMenu {
  ProcessItemMenu(super.controller, super.target, {super.onChanged});

  List<PopupMenuEntry<Item>> getComponentMenu(void Function(Item)? onChanged) {
    return <PopupMenuEntry<Item>>[
      PopupMenuItem(
        child: const Text('Add Event'),
        onTap: () {
          final ProcessElement item = ProcessElement('Event');
          controller.layoutModel.addItem(target, item);
          onChanged!(item);
        },
      ),
      PopupMenuItem(
        child: const Text('Delete Process'),
        onTap: () {
          controller.layoutModel.deleteItem(controller.layoutModel.curItem);
          onChanged!(controller.layoutModel.curItem);
        },
      ),
    ];
  }
}
