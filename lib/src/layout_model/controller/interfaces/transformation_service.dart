import 'package:flutter/material.dart';
import '../../item.dart';

/// Interface for transformation operations (move, resize, etc.)
abstract class TransformationService {
  /// Move item by delta offset
  void moveItem(Item element, Offset delta, {bool snap = false, double step = 5.0});
  
  /// Move item by ID with delta offset
  void moveItemById(String? itemId, Offset delta, {bool snap = false, double step = 5.0});
  
  /// Resize item to new size
  void resizeItem(Item element, Size newSize, {bool snap = false, double step = 5.0, Size? fromSize});
  
  /// Combined resize and move operation
  void resizeAndMaybeMove(
    Item element,
    Size newSize,
    Offset? newPosition, {
    Size? fromSize,
    Offset? fromPosition,
  });
  
  /// Snap value to grid
  double snapToGrid(double value, {double step = 5.0});
}
