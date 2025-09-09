import 'package:flutter/material.dart';

import 'layout_model_controller.dart';

/// Events system for communication between [LayoutModelController] and editor widgets.
///
/// Events can contain data that widgets use to update their state. They can trigger
/// animations or state updates. Widgets can handle events to prevent propagation to
/// parent widgets. Events can be discarded using the [isHandled] flag to group
/// widget rebuilds. There's no one-to-one correspondence between controller methods
/// and events - events exist only when there's data to pass or rebuilds to trigger.

/// Base class for all layout model events.
///
/// All events in the Frame Forge system extend this class, providing common
/// functionality like unique identification, handling state, and undo capability.
@immutable
abstract base class LayoutModelEvent {
  /// Unique identifier for this event instance.
  final String id;

  /// Whether this event has been handled and should not propagate further.
  final bool isHandled;

  /// Whether this event represents an undoable operation.
  final bool isUndoable;

  /// Creates a new layout model event with the specified [id].
  ///
  /// - [isHandled]: Whether the event is already handled (defaults to false)
  /// - [isUndoable]: Whether the event can be undone (defaults to false)
  const LayoutModelEvent({
    required this.id,
    this.isHandled = false,
    this.isUndoable = false,
  });

  /// Converts this event to a JSON representation using the provided [dataHandlers].
  Map<String, dynamic> toJson(Map<String, DataHandler> dataHandlers) => <String, dynamic>{
    'id': id,
    'isHandled': isHandled,
    'isUndoable': isUndoable,
  };
}

/// Event fired when the viewport offset changes.
///
/// This event is triggered when the user pans or programmatically scrolls
/// the canvas viewport.
final class ViewportOffsetEvent extends LayoutModelEvent {
  /// The new viewport offset position.
  final Offset offset;

  /// Whether the offset change should be animated.
  final bool animate;

  /// Creates a new viewport offset event.
  const ViewportOffsetEvent(
    this.offset, {
    this.animate = true,
    required super.id,
    super.isHandled,
  });
}

/// Event fired when the viewport zoom level changes.
///
/// This event is triggered when the user zooms in/out or programmatically
/// changes the canvas zoom level.
final class ViewportZoomEvent extends LayoutModelEvent {
  /// The new zoom level (1.0 = 100%).
  final double zoom;

  /// Whether the zoom change should be animated.
  final bool animate;

  const ViewportZoomEvent(
    this.zoom, {
    this.animate = true,
    required super.id,
    super.isHandled,
  });
}

final class SelectionAreaEvent extends LayoutModelEvent {
  final Rect area;

  const SelectionAreaEvent(this.area, {required super.id, super.isHandled});
}

final class DragSelectionStartEvent extends LayoutModelEvent {
  final Set<String> nodeIds;
  final Offset position;

  const DragSelectionStartEvent(
    this.nodeIds,
    this.position, {
    required super.id,
    super.isHandled,
  });

  @override
  Map<String, dynamic> toJson(Map<String, DataHandler> dataHandlers) => <String, dynamic>{
    ...super.toJson(dataHandlers),
    'nodeIds': nodeIds.toList(),
    'position': [position.dx, position.dy],
  };

  factory DragSelectionStartEvent.fromJson(Map<String, dynamic> json) {
    return DragSelectionStartEvent(
      (json['nodeIds'] as List).cast<String>().toSet(),
      Offset(json['position'][0], json['position'][1]),
      id: json['id'] as String,
      isHandled: json['isHandled'] as bool,
    );
  }
}

final class DragSelectionEvent extends LayoutModelEvent {
  final Set<String> nodeIds;
  final Offset delta;

  const DragSelectionEvent(
    this.nodeIds,
    this.delta, {
    required super.id,
    super.isHandled,
  }) : super(isUndoable: true);

  @override
  Map<String, dynamic> toJson(Map<String, DataHandler> dataHandlers) => {
    ...super.toJson(dataHandlers),
    'nodeIds': nodeIds.toList(),
    'delta': [delta.dx, delta.dy],
  };

  factory DragSelectionEvent.fromJson(Map<String, dynamic> json) {
    return DragSelectionEvent(
      (json['nodeIds'] as List).cast<String>().toSet(),
      Offset(json['delta'][0], json['delta'][1]),
      id: json['id'] as String,
      isHandled: json['isHandled'] as bool,
    );
  }
}

final class DragSelectionEndEvent extends LayoutModelEvent {
  final Offset position;
  final Set<String> nodeIds;

  const DragSelectionEndEvent(
    this.position,
    this.nodeIds, {
    required super.id,
    super.isHandled,
  });

  @override
  Map<String, dynamic> toJson(Map<String, DataHandler> dataHandlers) => {
    ...super.toJson(dataHandlers),
    'position': [position.dx, position.dy],
    'nodeIds': nodeIds.toList(),
  };

  factory DragSelectionEndEvent.fromJson(Map<String, dynamic> json) {
    return DragSelectionEndEvent(
      Offset(json['position'][0], json['position'][1]),
      (json['nodeIds'] as List).cast<String>().toSet(),
      id: json['id'] as String,
      isHandled: json['isHandled'] as bool,
    );
  }
}

final class SelectionEvent extends LayoutModelEvent {
  final String? itemId;
  const SelectionEvent({
    required super.id,
    required this.itemId,
    super.isHandled,
  });
}

/// Event fired when a new item is added to the layout.
///
/// This event is undoable and can be used to trigger UI updates
/// when components are added to the layout model.
final class AddItemEvent extends LayoutModelEvent {
  /// Creates an [AddItemEvent] with the specified [id].
  const AddItemEvent({required super.id, super.isHandled})
    : super(isUndoable: true);
}

final class RemoveItemEvent extends LayoutModelEvent {
  const RemoveItemEvent({required super.id, super.isHandled})
    : super(isUndoable: true);
}

final class PasteSelectionEvent extends LayoutModelEvent {
  final String clipboardContent;

  const PasteSelectionEvent(
    this.clipboardContent, {
    required super.id,
    super.isHandled,
  });
}

final class CutSelectionEvent extends LayoutModelEvent {
  final String clipboardContent;

  const CutSelectionEvent(
    this.clipboardContent, {
    required super.id,
    super.isHandled,
  });
}

final class SaveProjectEvent extends LayoutModelEvent {
  const SaveProjectEvent({required super.id});
}

final class LoadProjectEvent extends LayoutModelEvent {
  const LoadProjectEvent({required super.id});
}

final class NewProjectEvent extends LayoutModelEvent {
  const NewProjectEvent({required super.id});
}

final class UpdateStyleEvent extends LayoutModelEvent {
  const UpdateStyleEvent({required super.id});
}

final class PanEnd extends LayoutModelEvent {
  const PanEnd({required super.id});
}

/// Abstract base for change events (move, resize, attributes, etc.)
sealed class ChangeEvent extends LayoutModelEvent {
  final String? itemId;
  const ChangeEvent({required super.id, required this.itemId, super.isUndoable});
}

/// Backward compatible generic change event
final class ChangeItem extends ChangeEvent {
  const ChangeItem({required super.id, required super.itemId});
}

/// Emitted when an item is moved by a delta in model coordinates
final class MoveEvent extends ChangeEvent {
  final Offset delta;
  final Offset newPosition;
  const MoveEvent({
    required super.id,
    required super.itemId,
    required this.delta,
    required this.newPosition,
  }) : super(isUndoable: true);
}

/// Emitted when an item is resized in model coordinates
final class ResizeEvent extends ChangeEvent {
  final Size newSize;
  const ResizeEvent({
    required super.id,
    required super.itemId,
    required this.newSize,
  }) : super(isUndoable: true);
}

/// Emitted after an undo operation is performed
final class UndoPerformed extends LayoutModelEvent {
  const UndoPerformed({required super.id});
}

/// Emitted after a redo operation is performed
final class RedoPerformed extends LayoutModelEvent {
  const RedoPerformed({required super.id});
}

/// Emitted when item's attributes (non-geometry) change
final class AttributeChangeEvent extends ChangeEvent {
  final Map<String, dynamic> changes;
  const AttributeChangeEvent({
    required super.id,
    required super.itemId,
    this.changes = const <String, dynamic>{},
  });
}

/// Класс, позволяющий задавать логику сериализации и десериализации
/// для пользовательских типов данных.
class DataHandler {
  final String Function(dynamic data) toJson;
  final dynamic Function(String json) fromJson;

  DataHandler(this.toJson, this.fromJson);
}
