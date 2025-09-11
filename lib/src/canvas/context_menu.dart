import 'package:flutter/material.dart';

import '../flutter_context_menu/core/models/context_menu.dart';
import '../flutter_context_menu/core/models/context_menu_entry.dart';
import '../flutter_context_menu/core/utils/helpers.dart';

bool isContextMenuVisible = false;

void createAndShowContextMenu(
  BuildContext context, {
  required List<ContextMenuEntry> entries,
  required Offset position,
  Function(String? value)? onDismiss,
}) async {
  if (isContextMenuVisible) return;

  isContextMenuVisible = true;

  final ContextMenu menu = ContextMenu(
    clipBehavior: Clip.hardEdge,
    entries: entries,
    position: position,
    padding: const EdgeInsets.all(8),
  );

  final String? copiedValue = await showContextMenu(context, contextMenu: menu).then((
    value,
  ) {
    isContextMenuVisible = false;
    return value;
  });

  if (onDismiss != null) onDismiss(copiedValue);
}
