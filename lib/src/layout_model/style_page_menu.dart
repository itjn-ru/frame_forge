import 'package:flutter/material.dart';

import '../flutter_context_menu/flutter_context_menu.dart';
import 'controller/events.dart';
import 'menu.dart';
import 'style_element.dart';

class StylePageMenu extends ComponentAndSourceMenu {
  StylePageMenu(super.controller, super.target, {super.onChanged});

  @override
  List<ContextMenuEntry> getContextMenu(
    void Function(LayoutModelEvent event)? onChanged,
  ) {
    return <ContextMenuEntry>[
      const MenuHeader(text: 'Editing'),
      MenuItem(
        label: 'Add style',
        icon: Icons.add,
        onSelected: () {
          final StyleElement item = StyleElement('style');
          controller.layoutModel.addItem(target, item);
          onChanged!(AddItemEvent(id: item.id));
        },
      ),
    ];
  }
}
