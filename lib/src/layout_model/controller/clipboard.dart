import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../from_map_to_map_mixin.dart';
import '../item.dart';
import '../page.dart';
import 'event_bus.dart';
import 'events.dart';
import 'helpers/snackbar.dart';
import 'layout_model_controller.dart';

/// Class that manages clipboard operations.
class LayoutModelClipboard with FromMapToMap {
  ///Controller for clipboard operations.
  final LayoutModelController controller;

  ///Event bus for emitting clipboard-related events.
  LayoutModelEventBus get eventBus => controller.eventBus;

  ///Getter for the currently selected item.
  Item? get item => controller.getCurrentItem();

  ComponentAndSourcePage? get page =>
      item == null ? null : controller.layoutModel.getPageByItem(item!);

  LayoutModelClipboard(this.controller);

  Future<String> copySelection() async {
    if (item == null) {
      showNodeEditorSnackbar(
        'Ошибка копирования. Нет выбранного элемента.',
        SnackbarType.error,
      );
      return '';
    }
    final selectedItem = item!.toMap();

    late final String base64Data;

    try {
      final itemJsonData = jsonEncode(selectedItem);
      base64Data = base64Encode(utf8.encode(itemJsonData));
    } catch (e) {
      showNodeEditorSnackbar(
        'Ошибка копирования. Неверные данные в буфере обмена. ($e)',
        SnackbarType.error,
      );
      return '';
    }

    await Clipboard.setData(ClipboardData(text: base64Data));

    showNodeEditorSnackbar(
      'Элемент скопирован в буфер обмена.',
      SnackbarType.success,
    );
    return base64Data;
  }

  
  void pasteSelection({required Item parent}) async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData == null || clipboardData.text!.isEmpty) return;

    late final Item newItem;
    try {
      final base64Data = utf8.decode(base64Decode(clipboardData.text!));
      final Map<String, dynamic> itemJson =
          jsonDecode(base64Data) as Map<String, dynamic>;
      newItem = Item('item', 'item').fromMap(itemJson);
    } catch (e) {
      showNodeEditorSnackbar(
        'Не удалось вставить элемент. Неверные данные буфера обмена. ($e)',
        SnackbarType.error,
      );
      return;
    }
    final Item pasteItem = switchItem({'type': newItem.type}, parent);
    pasteItem
      ..type = newItem.type
      ..mayBeParent = newItem.mayBeParent
      ..properties.addAll(newItem.properties)
      ..items.addAll(newItem.items);
    pasteItem.properties['id']?.value = const Uuid().v4();
    // Insert via controller to make it undoable
    controller.pasteItem(parent, pasteItem);
    eventBus.emit(
      PasteSelectionEvent(id: const Uuid().v4(), clipboardData.text!),
    );
  }

  /// Вырезает выбранный элемент в буфер обмена.
  ///
  /// Выбранный элемент копируется в буфер обмена, а затем удаляется из редактора.
  /// После чего элемент удаляется из редактора, и выделение очищается.
  void cutSelection() async {
    final clipboardContent = await copySelection();
    await controller.cutSelected();
    eventBus.emit(CutSelectionEvent(id: const Uuid().v4(), clipboardContent));
  }
}
