import 'package:frame_forge/src/layout_model/property.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';

import '../item.dart';
import '../layout_model.dart';
import '../page.dart';
import 'file_picker/file_picker_service.dart';
import 'file_picker/file_picker_factory.dart';
import 'clipboard.dart';
import 'event_bus.dart';
import 'events.dart';
import 'project.dart';
import 'undo.dart';
import 'keyboard_handler.dart';
import 'interfaces/undo_redo_service.dart';
import 'interfaces/canvas_view_service.dart';
import 'interfaces/transformation_service.dart';
import 'services/undo_redo_service_impl.dart';
import 'services/canvas_view_service_impl.dart';
import 'services/transformation_service_impl.dart';


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
  final ValueNotifier<Map<String, Property>> propertiesNotifier = ValueNotifier(
    {},
  );

  late final LayoutModelClipboard clipboard;
  late final LayoutModelEditorProject project;
  late final GlobalKeyboardHandler keyboardHandler;
  
  /// Services for di
  late final UndoRedoService undoRedoService;
  late final CanvasViewService canvasViewService;
  late final TransformationService transformationService;

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
    keyboardHandler = GlobalKeyboardHandler(this);
    
    // Initialize services
    canvasViewService = CanvasViewServiceImpl(this.eventBus);
    undoRedoService = UndoRedoServiceImpl(this.eventBus);
    transformationService = TransformationServiceImpl(canvasViewService, this);
  }

  /// Selects an item by its [itemId].
  ///
  /// Updates the selected item, properties notifier, and emits a [SelectionEvent].
  /// If [itemId] is null, no item will be selected.
  void select(String? itemId) {
    selectedIdNotifier.value = itemId;

    /// Update all [Property] in the notifier
    propertiesNotifier.value = getItemById(itemId)?.properties ?? {};

    eventBus.emit(SelectionEvent(id: const Uuid().v4(), itemId: itemId));
  }

  String? get selectedId => selectedIdNotifier.value;

  void _listenToEvents() {
    eventBus.events.listen((event) {
      lastEvent = event;
      if (event is ChangeEvent) {
        changedItems.value = {...changedItems.value, event.itemId};
      }
    });
  }

  void updateProperty(String key, Property value) {
    // Update notifier for UI widgets
    propertiesNotifier.value = {...propertiesNotifier.value, key: value};
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

  /// Returns the current page based on the current item and page type.
  ComponentAndSourcePage getCurrentPage() {
    final currentItem = getCurrentItem();
    if (currentItem == null) {
      return layoutModel.root.items
          .whereType<ComponentAndSourcePage>()
          .first; // Returns the first page by default
    }

    return _findParentPage(currentItem) ??
        layoutModel.root.items
            .whereType<ComponentAndSourcePage>()
            .first; // Returns the first page by default
  }

  /// Finds the nearest parent page for the given item
  ComponentAndSourcePage? _findParentPage(Item item) {
    // Если сам item является Page, возвращаем его
    if (item is ComponentAndSourcePage) {
      return item;
    }

    // Ищем родительскую страницу, обходя дерево элементов
    ComponentAndSourcePage? searchInItems(List<Item> items, Item target) {
      for (final currentItem in items) {
        // Проверяем, есть ли target в дочерних элементах currentItem
        if (currentItem.items.contains(target)) {
          // Если currentItem является Page, возвращаем его
          if (currentItem is ComponentAndSourcePage) {
            return currentItem;
          }
          // Иначе продолжаем поиск вверх по дереву
          return _findParentPage(currentItem);
        }

        // Рекурсивно ищем в дочерних элементах
        final found = searchInItems(currentItem.items, target);
        if (found != null) return found;
      }
      return null;
    }

    return searchInItems([layoutModel.root], item);
  }

  /// This method is used to dispose of the node editor controller and all of its resources, subsystems and members.
  void dispose() {
    eventBus.close();
  }

  void clear() {}

  Offset _viewportOffset = Offset.zero;
  double _viewportZoom = 1.0;

  // Grid steps in model units (not pixels)
  double _gridStepX = 20.0;
  double _gridStepY = 20.0;

  double get gridStepX => _gridStepX;
  double get gridStepY => _gridStepY;

  /// Update grid steps (in model units). Pass null to keep current.
  void setGridSteps({double? stepX, double? stepY}) {
    final newX = stepX ?? _gridStepX;
    final newY = stepY ?? _gridStepY;
    if (newX == _gridStepX && newY == _gridStepY) return;
    _gridStepX = newX;
    _gridStepY = newY;
    // Optionally, we could emit a dedicated event here if needed for listeners.
  }

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

  /// File picker service instance (lazy initialized)
  FilePickerService? _filePickerService;

  FilePickerService get filePickerService {
    _filePickerService ??= createFilePickerService();
    return _filePickerService!;
  }

  /// Picks an image file and returns the bytes
  Future<Uint8List?> pickUploadFiles() async {
    return await filePickerService.pickImageFile();
  }

  // --- Undo/Redo (delegated to service) ---
  bool get canUndo => undoRedoService.canUndo;
  bool get canRedo => undoRedoService.canRedo;

  void undo() {
    (undoRedoService as UndoRedoServiceImpl).executeUndo((action) => action.revert(this));
  }

  void redo() {
    (undoRedoService as UndoRedoServiceImpl).executeRedo((action) => action.apply(this));
  }

  void _pushAction(UndoableAction action) {
    undoRedoService.pushAction(action);
  }

  // --- Public methods for creating undo actions (used by ResizableDraggableController) ---
  void pushMoveAction(String itemId, {required Offset from, required Offset to}) {
    _pushAction(MoveAction(itemId: itemId, from: from, to: to));
  }

  void pushResizeAction(String itemId, {required Size from, required Size to}) {
    _pushAction(ResizeAction(itemId: itemId, from: from, to: to));
  }

  void pushResizeMoveAction(
    String itemId, {
    required Size fromSize,
    required Size toSize,
    required Offset fromPos,
    required Offset toPos,
  }) {
    _pushAction(ResizeMoveAction(
      itemId: itemId,
      fromSize: fromSize,
      toSize: toSize,
      fromPos: fromPos,
      toPos: toPos,
    ));
  }
  
  /// Simple move by ID for keyboard handler (arrows)
  void moveItemById(String? itemId, Offset delta, {bool snap = false, double step = 5.0}) {
    final item = getItemById(itemId);
    if (item == null) return;
    
    final current = (item.properties["position"]?.value as Offset?) ?? Offset.zero;
    var next = current + delta;
    if (snap) {
      double snapToGrid(double value, {double step = 5.0}) => (value / step).round() * step;
      next = Offset(
        snapToGrid(next.dx, step: step),
        snapToGrid(next.dy, step: step),
      );
    }

    // Push undo action and apply
    _pushAction(MoveAction(itemId: item.id, from: current, to: next));
    applyPosition(item.id, next, emitDelta: delta);
  }

  
  // --- Internal direct apply helpers used by undo/redo and actions ---
  void applyPosition(String itemId, Offset next, {Offset? emitDelta}) {
    final item = getItemById(itemId);
    if (item == null) return;
    final prev = (item.properties["position"]?.value as Offset?) ?? Offset.zero;
    item.properties["position"]?.value = next;
    updateProperty("position", Property("положение", next, type: Offset));
    final id = const Uuid().v4();
    eventBus.emit(ChangeItem(id: id, itemId: itemId));
    eventBus.emit(
      MoveEvent(
        id: id,
        itemId: itemId,
        delta: emitDelta ?? (next - prev),
        newPosition: next,
      ),
    );
  }

  void applySize(String itemId, Size size) {
    final item = getItemById(itemId);
    if (item == null) return;
    item.properties["size"]?.value = size;
    updateProperty("size", Property("размер", size, type: Size));
    final id = const Uuid().v4();
    eventBus.emit(ChangeItem(id: id, itemId: itemId));
    eventBus.emit(ResizeEvent(id: id, itemId: itemId, newSize: size));
  }

  // --- Deletion helpers and keyboard API ---
  void deleteSelected() {
    final id = selectedId;
    if (id == null) return;
    final item = getItemById(id);
    if (item == null) return;
  // Find immediate parent and index for undo
  final parent = layoutModel.findParentById(layoutModel.root, item.id);
  if (parent == null) return;
  final index = parent.items.indexOf(item);
    // Push undo and apply delete
    _pushAction(DeleteAction(
      itemId: id,
      parent: parent,
      index: index,
      snapshot: item,
    ));
    applyDelete(id);
  }

  void applyDelete(String itemId) {
    final item = getItemById(itemId);
    if (item == null) return;
  final parent = layoutModel.findParentById(layoutModel.root, item.id);
  if (parent == null) return;
  parent.items.remove(item);
  select(parent.id);
  eventBus.emit(RemoveItemEvent(id: itemId));
  }

  void applyInsert(Item parent, Item item, {int? index}) {
    // Check if parent can have children
    if (parent.mayBeParent) {
      // Use direct insertion for undo operations to bypass complex addItem logic
      layoutModel.addItemDirect(parent, item, index: index);
    } else {
      // Find the real parent and insert after the selected item
      final realParent = layoutModel.findParentById(layoutModel.root, parent.id);
      if (realParent != null) {
        final selectedIndex = realParent.items.indexOf(parent);
        final insertIndex = selectedIndex + 1;
        layoutModel.addItemDirect(realParent, item, index: insertIndex);
      }
    }
    eventBus.emit(AddItemEvent(id: item.id));
  }

  /// Direct insert for undo operations - restores item to exact original location
  void applyInsertDirect(Item parent, Item item, {int? index}) {
    layoutModel.addItemDirect(parent, item, index: index);
    eventBus.emit(AddItemEvent(id: item.id));
  }

  // --- Clipboard with undo wrappers ---
  void pasteItem(Item parent, Item item, {int? index}) {
    // Determine the actual parent and index for insertion
    Item actualParent;
    int? actualIndex;
    
    if (parent.mayBeParent) {
      actualParent = parent;
      actualIndex = index;
    } else {
      // Find the real parent and calculate insertion index
      final realParent = layoutModel.findParentById(layoutModel.root, parent.id);
      if (realParent != null) {
        actualParent = realParent;
        final selectedIndex = realParent.items.indexOf(parent);
        actualIndex = selectedIndex + 1;
      } else {
        actualParent = parent; // Fallback
        actualIndex = index;
      }
    }
    
    _pushAction(InsertAction(parent: actualParent, snapshot: item, index: actualIndex));
    applyInsert(parent, item, index: index);
  }

  Future<void> cutSelected() async {
    final id = selectedId;
    if (id == null) return;
    final item = getItemById(id);
    if (item == null) return;
    final parent = layoutModel.findParentById(layoutModel.root, item.id);
    if (parent == null) return;
    _pushAction(DeleteAction(
      itemId: id,
      parent: parent,
      index: parent.items.indexOf(item),
      snapshot: item,
    ));
    applyDelete(id);
  }
}
