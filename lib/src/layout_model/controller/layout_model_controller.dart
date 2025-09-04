
import 'package:frame_forge/src/layout_model/property.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../item.dart';
import '../layout_model.dart';
import 'clipboard.dart';
import 'event_bus.dart';
import 'events.dart';
import 'project.dart';

class LayoutModelController {
  LayoutModel layoutModel;
  final LayoutModelEventBus eventBus;

  final ValueNotifier<Set<String?>> changedItems = ValueNotifier({});
  final ValueNotifier<Map<String, Property>> propertiesNotifier =
      ValueNotifier({});

  late final LayoutModelClipboard clipboard;
  late final LayoutModelEditorProject project;

  LayoutModelEvent? lastEvent;

  /// Вместо хранения текущего item, можно использовать id
  late final ValueNotifier<String?> selectedIdNotifier;

  LayoutModelController({
    required this.layoutModel,
    LayoutModelEventBus? eventBus,
    Future<bool> Function(Map map)? projectSaver,
    Future<String?> Function(bool isSaved)? projectLoader,
    Future<bool> Function(bool isSaved)? projectCreator,
  }) : eventBus = eventBus ?? LayoutModelEventBus() {
    selectedIdNotifier = ValueNotifier<String?>(layoutModel.curItem.id);
    _listenToEvents();
    clipboard = LayoutModelClipboard(this);
    project = LayoutModelEditorProject(
      this,
      projectSaver: projectSaver,
      projectLoader: projectLoader,
      projectCreator: projectCreator,
    );
  }

  void select(String? itemId) {
    selectedIdNotifier.value = itemId;

    /// Закидывает все [Property] в нотифаер
    propertiesNotifier.value = getItemById(itemId)?.properties ?? {};

    eventBus.emit(SelectionEvent(id: const Uuid().v4(), itemId: itemId));
  }

  String? get selectedId => selectedIdNotifier.value;

  void _listenToEvents() {
    eventBus.events.listen((event) {
      lastEvent = event;
      debugPrint('Got event: $event');
      if (event is ChangeItem) {
        changedItems.value = {...changedItems.value, event.itemId};
      }
    });
  }

  void updateProperty(String key, Property value) {
    propertiesNotifier.value = {
      ...propertiesNotifier.value,
      key: value,
    };
  }

  void markItemAsHandled(String itemId) {
    changedItems.value = {...changedItems.value}..remove(itemId);
  }

  Item? getItemById(String? id) {
    if (id == null) return null;

    Item? searchInItems(List<Item> items) {
      for (final item in items) {
        if (item.id == id) return item;
        final found = searchInItems(item.items);
        if (found != null) return found;
      }
      return null;
    }

    return searchInItems([layoutModel.root]);
  }

  Item? getCurrentItem() => getItemById(selectedId);

  /// This method is used to dispose of the node editor controller and all of its resources, subsystems and members.
  void dispose() {
    eventBus.close();
  }

  void clear() {}

  Offset _viewportOffset = Offset.zero;
  double _viewportZoom = 1.0;

  Offset get viewportOffset => _viewportOffset;

  double get viewportZoom => _viewportZoom;

  set viewportOffset(Offset offset) {
    _viewportOffset = offset;
    eventBus.emit(
      ViewportOffsetEvent(
        id: const Uuid().v4(),
        _viewportOffset,
        animate: false,
        isHandled: true,
      ),
    );
  }

  set viewportZoom(double zoom) {
    _viewportZoom = zoom;
    eventBus.emit(
      ViewportZoomEvent(
        id: const Uuid().v4(),
        _viewportZoom,
        animate: false,
        isHandled: true,
      ),
    );
  }
}
