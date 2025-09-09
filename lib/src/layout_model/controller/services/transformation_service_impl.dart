import 'dart:math';
import 'package:flutter/material.dart';
import '../interfaces/transformation_service.dart';
import '../interfaces/canvas_view_service.dart';
import '../layout_model_controller.dart';
import '../../item.dart';

/// Implementation of TransformationService with snap-to-grid functionality
class TransformationServiceImpl implements TransformationService {
  final LayoutModelController _layoutController;

  TransformationServiceImpl(CanvasViewService canvasViewService, this._layoutController);

  @override
  void moveItem(Item element, Offset delta, {bool snap = false, double step = 5.0}) {
    final current = (element.properties["position"]?.value as Offset?) ?? Offset.zero;
    var next = current + delta;
    if (snap) {
      next = Offset(
        snapToGrid(next.dx, step: step),
        snapToGrid(next.dy, step: step),
      );
    }

    // Push undo action and apply through layout controller
    _layoutController.pushMoveAction(element.id, from: current, to: next);
    _layoutController.applyPosition(element.id, next, emitDelta: delta);
  }

  @override
  void moveItemById(String? itemId, Offset delta, {bool snap = false, double step = 5.0}) {
    final item = _layoutController.getItemById(itemId);
    if (item == null) return;
    moveItem(item, delta, snap: snap, step: step);
  }

  @override
  void resizeItem(Item element, Size newSize, {bool snap = false, double step = 5.0, Size? fromSize}) {
    final current = (element.properties["size"]?.value as Size?) ?? Size.zero;
    var next = Size(
      max(newSize.width, 10), // Minimum width
      max(newSize.height, 10), // Minimum height
    );
    if (snap) {
      next = Size(
        snapToGrid(next.width, step: step),
        snapToGrid(next.height, step: step),
      );
    }

    // Push undo action and apply through layout controller
    _layoutController.pushResizeAction(element.id, from: fromSize ?? current, to: next);
    _layoutController.applySize(element.id, next);
  }

  @override
  void resizeAndMaybeMove(Item element, Size newSize, Offset? newPosition, {Size? fromSize, Offset? fromPosition}) {
    final currentSize = (element.properties["size"]?.value as Size?) ?? Size.zero;
    final currentPosition = (element.properties["position"]?.value as Offset?) ?? Offset.zero;
    
    var finalSize = Size(
      max(newSize.width, 10),
      max(newSize.height, 10),
    );
    
    if (newPosition != null) {
      // Combined resize and move
      _layoutController.pushResizeMoveAction(
        element.id,
        fromSize: fromSize ?? currentSize,
        toSize: finalSize,
        fromPos: fromPosition ?? currentPosition,
        toPos: newPosition,
      );
      _layoutController.applySize(element.id, finalSize);
      _layoutController.applyPosition(element.id, newPosition);
    } else {
      // Just resize
      resizeItem(element, newSize, fromSize: fromSize);
    }
  }

  @override
  double snapToGrid(double value, {double step = 5.0}) {
    return (value / step).round() * step;
  }
}
