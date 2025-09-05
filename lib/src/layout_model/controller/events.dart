import 'package:flutter/material.dart';

import 'layout_model_controller.dart';

/// События используются для связи между [LayoutModelController] и виджетами редактора.
/// События могут (где это применимо) содержать данные, которые будут использоваться виджетами для обновления их состояния.
/// События можно использовать для запуска анимации или для обновления состояния виджетов.
/// Виджеты могут обрабатывать события, чтобы предотвратить попадание события на родительские виджеты.
/// Событие может быть отброшено с помощью флага [isHandled] для группировки перестроек виджетов.
/// Между методами контроллера и событиями не существует однозначного соответствия,
/// последние существуют только если есть данные, которые нужно передать,
/// или перестроения, которые нужно запустить.

/// Базовый класс событий для [LayoutModelController].
@immutable
abstract base class LayoutModelEvent {
  final String id;
  final bool isHandled;
  final bool isUndoable;

  const LayoutModelEvent({
    required this.id,
    this.isHandled = false,
    this.isUndoable = false,
  });

  Map<String, dynamic> toJson(Map<String, DataHandler> dataHandlers) => {
        'id': id,
        'isHandled': isHandled,
        'isUndoable': isUndoable,
      };
}

final class ViewportOffsetEvent extends LayoutModelEvent {
  final Offset offset;
  final bool animate;

  const ViewportOffsetEvent(
    this.offset, {
    this.animate = true,
    required super.id,
    super.isHandled,
  });
}

final class ViewportZoomEvent extends LayoutModelEvent {
  final double zoom;
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
  Map<String, dynamic> toJson(dataHandlers) => {
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
  Map<String, dynamic> toJson(dataHandlers) => {
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
  Map<String, dynamic> toJson(dataHandlers) => {
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
  const SelectionEvent({required super.id,required this.itemId, super.isHandled});
}


/// Event fired when a new item is added to the layout.
/// 
/// This event is undoable and can be used to trigger UI updates
/// when components are added to the layout model.
final class AddItemEvent extends LayoutModelEvent {
  /// Creates an [AddItemEvent] with the specified [id].
  const AddItemEvent({
    required super.id,
    super.isHandled,
  }) : super(isUndoable: true);
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

/// Event fired when an item in the layout is modified.
/// 
/// Contains the [itemId] of the changed item to identify which
/// component was modified. Used to trigger specific UI updates.
final class ChangeItem extends LayoutModelEvent {
  /// The ID of the item that was changed.
  final String? itemId;
  
  /// Creates a [ChangeItem] event for the specified [itemId].
  const ChangeItem({required super.id, required this.itemId});
}

/// Класс, позволяющий задавать логику сериализации и десериализации
/// для пользовательских типов данных.
class DataHandler {
  final String Function(dynamic data) toJson;
  final dynamic Function(String json) fromJson;

  DataHandler(this.toJson, this.fromJson);
}
