
import 'package:frame_forge/src/layout_model/property.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../item.dart';
import '../layout_model.dart';
import 'clipboard.dart';
import 'event_bus.dart';
import 'events.dart';
import 'project.dart';

/// Controller for managing layout model operations and state.
///
/// The [LayoutModelController] handles all interactions with the layout model,
/// including selection, clipboard operations, project management, and event handling.
/// It serves as the central coordinator between the UI and the data model.
///
/// Example usage:
/// ```dart
/// final controller = LayoutModelController(
///   layoutModel: myLayoutModel,
///   projectSaver: (map) async => saveToFile(map),
///   projectLoader: (isSaved) async => loadFromFile(),
/// );
/// ```
class LayoutModelController {
  /// The layout model being controlled.
  LayoutModel layoutModel;
  
  /// Event bus for handling layout model events.
  final LayoutModelEventBus eventBus;

  final ValueNotifier<Set<String?>> changedItems = ValueNotifier({});
  final ValueNotifier<Map<String, Property>> propertiesNotifier =
      ValueNotifier({});

  late final LayoutModelClipboard clipboard;
  late final LayoutModelEditorProject project;

  LayoutModelEvent? lastEvent;

  /// Вместо хранения текущего item, можно использовать id
  late final ValueNotifier<String?> selectedIdNotifier;

  /// Creates a [LayoutModelController] with the specified [layoutModel].
  ///
  /// The [eventBus] parameter is optional and defaults to a new [LayoutModelEventBus].
  /// 
  /// Optional callbacks can be provided for project management:
  /// - [projectSaver]: Function to save project data
  /// - [projectLoader]: Function to load project data  
  /// - [projectCreator]: Function to create new projects
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

  /// Selects an item by its [itemId].
  ///
  /// Updates the selected item, properties notifier, and emits a [SelectionEvent].
  /// If [itemId] is null, no item will be selected.
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
