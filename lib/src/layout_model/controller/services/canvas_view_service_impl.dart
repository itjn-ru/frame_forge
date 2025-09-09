import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../events.dart';
import '../event_bus.dart';
import '../interfaces/canvas_view_service.dart';

/// Implementation of CanvasViewService for viewport and grid management
class CanvasViewServiceImpl implements CanvasViewService {
  final LayoutModelEventBus _eventBus;
  
  Offset _viewportOffset = Offset.zero;
  double _viewportZoom = 1.0;
  double _gridStepX = 20.0;
  double _gridStepY = 20.0;

  CanvasViewServiceImpl(this._eventBus);

  @override
  Offset get viewportOffset => _viewportOffset;

  @override
  set viewportOffset(Offset offset) {
    _viewportOffset = offset;
    _eventBus.emit(
      ViewportOffsetEvent(
        id: const Uuid().v4(),
        _viewportOffset,
        animate: false,
        isHandled: true,
      ),
    );
  }

  @override
  double get viewportZoom => _viewportZoom;

  @override
  set viewportZoom(double zoom) {
    _viewportZoom = zoom;
    _eventBus.emit(
      ViewportZoomEvent(
        id: const Uuid().v4(),
        _viewportZoom,
        animate: false,
        isHandled: true,
      ),
    );
  }

  @override
  double get gridStepX => _gridStepX;

  @override
  double get gridStepY => _gridStepY;

  @override
  void setGridSteps({double? stepX, double? stepY}) {
    final newX = stepX ?? _gridStepX;
    final newY = stepY ?? _gridStepY;
    if (newX == _gridStepX && newY == _gridStepY) return;
    _gridStepX = newX;
    _gridStepY = newY;
    // Optionally emit grid change event here if needed
  }
}
