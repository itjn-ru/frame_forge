import 'package:flutter/material.dart';

/// Interface for canvas/viewport management
abstract class CanvasViewService {
  /// Current viewport offset
  Offset get viewportOffset;
  set viewportOffset(Offset offset);
  
  /// Current viewport zoom level
  double get viewportZoom;
  set viewportZoom(double zoom);
  
  /// Grid step X in model units
  double get gridStepX;
  
  /// Grid step Y in model units
  double get gridStepY;
  
  /// Update grid steps
  void setGridSteps({double? stepX, double? stepY});
}
