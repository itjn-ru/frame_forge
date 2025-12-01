import 'package:flutter/material.dart';

import '../flutter_context_menu/flutter_context_menu.dart';
import 'controller/events.dart';
import 'menu.dart';
import 'page.dart';

class ComponentRootMenu extends ComponentAndSourceMenu {
  ComponentRootMenu(super.controller, super.target, {super.onChanged});

  @override
  List<ContextMenuEntry> getContextMenu(
    void Function(LayoutModelEvent event)? onChanged,
  ) {
    return <ContextMenuEntry>[
      const MenuHeader(text: 'Editing'),
      MenuItem(
        label: 'Add Page',
        icon: Icons.add,
        onSelected: () {
          final ComponentPage item = ComponentPage('page');
          controller.layoutModel.addItem(target, item);
          onChanged!(AddItemEvent(id: item.id));
        },
      ),
    ];
  }
}
