import 'package:flutter/material.dart';

import 'resize_types.dart';

/// Result of a resize computation containing new dimensions and translation deltas.
class ResizeOutcome {
  final double dynamicW;
  final double dynamicH;
  final double trW;
  final double trH;

  const ResizeOutcome({
    required this.dynamicW,
    required this.dynamicH,
    required this.trW,
    required this.trH,
  });
}

/// Encapsulates all business logic for dragging and resizing: snapping, constraints, and math.
class DragResizeLogic {
  final double scaleFactor;
  final double gridStep;
  final double canvasWidth;
  final double canvasHeight;

  const DragResizeLogic({
    required this.scaleFactor,
    this.gridStep = 5.0,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  /// Calculate current move offset during drag, with vertical constraint; no snapping.
  Offset computeMoveOffset(
    Offset localPosition,
    Offset startMoveOffset,
    Offset endMoveOffset,
    double trLastH,
  ) {
    var intervalOffset = localPosition - startMoveOffset + endMoveOffset;
    if (intervalOffset.dy < -trLastH) {
      intervalOffset = Offset(intervalOffset.dx, -trLastH);
    }
    return intervalOffset;
  }

  /// Snap absolute final position to grid (in unscaled canvas units).
  Offset snapFinalPosition(Offset updateMoveOffset, double trW, double trH) {
    final finalPosition = Offset(
      updateMoveOffset.dx + trW,
      updateMoveOffset.dy + trH,
    );
    return Offset(
      ((finalPosition.dx / scaleFactor) / gridStep).round() * gridStep,
      ((finalPosition.dy / scaleFactor) / gridStep).round() * gridStep,
    );
  }

  /// Snap dynamic size (scaled) to grid in unscaled units.
  Size snapFinalSize(double dynamicW, double dynamicH) {
    return Size(
      ((dynamicW / scaleFactor) / gridStep).round() * gridStep,
      ((dynamicH / scaleFactor) / gridStep).round() * gridStep,
    );
  }

  /// Compute new widget size/translation given quantized deltas and resize direction.
  ResizeOutcome computeResize({
    required ResizeDirection direction,
    required double dx,
    required double dy,
    required double dynamicW,
    required double dynamicH,
    required double trW,
    required double trH,
  }) {
    double newDynamicW = dynamicW;
    double newDynamicH = dynamicH;
    double newTrW = trW;
    double newTrH = trH;

    switch (direction) {
      case ResizeDirection.right:
        newDynamicW = (dynamicW + dx).clamp(20, canvasWidth).toDouble();
        break;
      case ResizeDirection.left:
        newDynamicW = (dynamicW - dx).clamp(20, canvasWidth).toDouble();
        newTrW = trW + dx;
        break;
      case ResizeDirection.bottom:
        newDynamicH = (dynamicH + dy).clamp(20, canvasHeight).toDouble();
        break;
      case ResizeDirection.top:
        newDynamicH = (dynamicH - dy).clamp(20, canvasHeight).toDouble();
        newTrH = trH + dy;
        break;
      case ResizeDirection.topLeft:
        newDynamicW = (dynamicW - dx).clamp(20, canvasWidth).toDouble();
        newDynamicH = (dynamicH - dy).clamp(20, canvasHeight).toDouble();
        newTrW = trW + dx;
        newTrH = trH + dy;
        break;
      case ResizeDirection.topRight:
        newDynamicW = (dynamicW + dx).clamp(20, canvasWidth).toDouble();
        newDynamicH = (dynamicH - dy).clamp(20, canvasHeight).toDouble();
        newTrH = trH + dy;
        break;
      case ResizeDirection.bottomLeft:
        newDynamicW = (dynamicW - dx).clamp(20, canvasWidth).toDouble();
        newDynamicH = (dynamicH + dy).clamp(20, canvasHeight).toDouble();
        newTrW = trW + dx;
        break;
      case ResizeDirection.bottomRight:
        newDynamicW = (dynamicW + dx).clamp(20, canvasWidth).toDouble();
        newDynamicH = (dynamicH + dy).clamp(20, canvasHeight).toDouble();
        break;
      case ResizeDirection.none:
        break;
    }

    return ResizeOutcome(
      dynamicW: newDynamicW,
      dynamicH: newDynamicH,
      trW: newTrW,
      trH: newTrH,
    );
  }
}
