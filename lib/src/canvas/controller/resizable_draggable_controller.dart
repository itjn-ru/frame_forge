import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../layout_model/controller/events.dart';
import '../../layout_model/controller/layout_model_controller.dart';
import '../../layout_model/item.dart';
import '../model/resize_types.dart';
import '../model/sessions.dart';
import 'snap_policy.dart';
import 'bounds_policy.dart';

/// Controller that holds all drag/resize state and math, and notifies listeners for UI rebuilds.
/// It interacts with [LayoutModelController] to apply final changes to the model.
class ResizableDraggableController extends ChangeNotifier {
  ResizableDraggableController({
    required this.layoutController,
    required this.scaleFactor,
    required this.canvasWidth,
    required this.canvasHeight,
    this.cellWidth = 10.0,
    this.cellHeight = 10.0,
  })  : _snapPolicy =
            GridSnapPolicy(stepX: cellWidth, stepY: cellHeight, enabled: true),
        _boundsPolicy = BoundsPolicy(
          minWidth: 20.0,
          minHeight: 20.0,
          maxRight: canvasWidth,
          maxBottom: canvasHeight,
        );

  /// Target item and visual options
  final LayoutModelController layoutController;

  /// scale of canvas constraints to real size
  final double scaleFactor;

  /// width of each cell in the grid
  final double canvasWidth;

  /// height of each cell in the grid
  final double canvasHeight;

  /// width of each cell in the grid
  final double cellWidth;

  /// height of each cell in the grid
  final double cellHeight;

  /// Policies for snapping
  SnapPolicy _snapPolicy;

  /// Policy for bounding within canvas
  BoundsPolicy _boundsPolicy;

  // Target item and visual options
  Item? child;

  // Dynamic (scaled) size
  double _dynamicW = 0;
  double _dynamicH = 0;

  // Base translation (scaled)
  double _trW = 0;
  double _trH = 0;

  // Move offsets (scaled, relative)
  Offset _updateMoveOffset = Offset.zero;

  // Resize state
  bool _isResizing = false;
  ResizeDirection _currentResizeDirection = ResizeDirection.none;

  // Snap settings
  bool _snapToGridEnabled = true;

  bool get snapToGridEnabled => _snapToGridEnabled;
  set snapToGridEnabled(bool v) {
    if (_snapToGridEnabled == v) return;
    _snapToGridEnabled = v;
    if (_snapPolicy is GridSnapPolicy) {
      _snapPolicy = (_snapPolicy as GridSnapPolicy).copyWith(enabled: v);
    }
    notifyListeners();
  }

  // Allow changing snapping strategy at runtime
  void setSnapPolicy(SnapPolicy policy) {
    _snapPolicy = policy;
    // If policy is GridSnapPolicy, keep _snapToGridEnabled in sync with its flag
    if (policy is GridSnapPolicy) {
      _snapToGridEnabled = policy.enabled;
    }
    notifyListeners();
  }

  // Hover edge width
  static const double _resizeEdgeWidth = 15.0;

  // Getters for the view
  double get dynamicW => _dynamicW;
  double get dynamicH => _dynamicH;
  double get trW => _trW;
  double get trH => _trH;
  Offset get updateMoveOffset => _updateMoveOffset;
  Offset get translateOffset => _updateMoveOffset + Offset(_trW, _trH);
  ResizeDirection get currentResizeDirection => _currentResizeDirection;

  void initFromItem({required Item? item, required Offset position}) {
    child = item;

    // Initial position: snap in model space via SnapPolicy if enabled
    final leftM0 = position.dx / scaleFactor;
    final topM0 = position.dy / scaleFactor;
    final leftM = _snapToGridEnabled ? _snapPolicy.snapX(leftM0) : leftM0;
    final topM = _snapToGridEnabled ? _snapPolicy.snapY(topM0) : topM0;
    _trW = leftM * scaleFactor;
    _trH = topM * scaleFactor;

    // Get real sizes from the component
    final componentSize = item?.properties["size"]?.value as Size?;
    final componentWidth = componentSize?.width ?? 360.0;
    final componentHeight = componentSize?.height ?? 30.0;

    _dynamicW = componentWidth * scaleFactor;
    _dynamicH = componentHeight * scaleFactor;

    _updateMoveOffset = Offset.zero;

    _isResizing = false;
    _currentResizeDirection = ResizeDirection.none;

    notifyListeners();
  }

  // Logic: determine which edge/corner is being resized
  ResizeDirection _getResizeDirection(Offset localPosition) {
    final double width = _dynamicW;
    final double height = _dynamicH;
    final double x = localPosition.dx;
    final double y = localPosition.dy;

    if (x <= _resizeEdgeWidth && y <= _resizeEdgeWidth) {
      return ResizeDirection.topLeft;
    } else if (x >= width - _resizeEdgeWidth && y <= _resizeEdgeWidth) {
      return ResizeDirection.topRight;
    } else if (x <= _resizeEdgeWidth && y >= height - _resizeEdgeWidth) {
      return ResizeDirection.bottomLeft;
    } else if (x >= width - _resizeEdgeWidth &&
        y >= height - _resizeEdgeWidth) {
      return ResizeDirection.bottomRight;
    } else if (y <= _resizeEdgeWidth) {
      return ResizeDirection.top;
    } else if (y >= height - _resizeEdgeWidth) {
      return ResizeDirection.bottom;
    } else if (x <= _resizeEdgeWidth) {
      return ResizeDirection.left;
    } else if (x >= width - _resizeEdgeWidth) {
      return ResizeDirection.right;
    }

    return ResizeDirection.none;
  }

  void onHover(Offset localPosition, {required bool selected}) {
    if (!selected) return;
    final d = _getResizeDirection(localPosition);
    if (d != _currentResizeDirection) {
      _currentResizeDirection = d;
      notifyListeners();
    }
  }

  void onTap({required bool selected}) {
    if (child == null) return;
    if (selected) {
      layoutController.select(null);
    } else {
      layoutController.select(child!.id);
    }
  }

  void onPanStart(DragStartDetails details, {required bool selected}) {
    if (!selected) return;

    _currentResizeDirection = _getResizeDirection(details.localPosition);

    if (_currentResizeDirection != ResizeDirection.none) {
      _isResizing = true;
      _startResizeSession();
    } else {
      // Begin a move session in model space
      _startMoveSession();
    }
  }

  void onPanUpdate(DragUpdateDetails details, {required bool selected}) {
    if (!selected) return;

    if (_isResizing) {
      _handleResize(details);
    } else {
      _handleMove(details);
    }
  }

  void onPanEnd({required bool selected}) {
    if (!selected || child == null) return;

    if (_isResizing) {
      // Final size in model coordinates with grid snapping (separate X/Y) in model space
      final modelW = _dynamicW / scaleFactor;
      final modelH = _dynamicH / scaleFactor;
      final snappedW = _snapPolicy.snapX(modelW);
      final snappedH = _snapPolicy.snapY(modelH);
      final finalSizeModel = Size(snappedW, snappedH);

      // Capture the size before resize started for accurate undo
      final startSize = _resizeSession != null
          ? Size(_resizeSession!.startWidthM, _resizeSession!.startHeightM)
          : (child?.properties["size"]?.value as Size? ??
              Size(_dynamicW / scaleFactor, _dynamicH / scaleFactor));

      // Compute new absolute position (snapped) in model space
      final absScaled =
          Offset(_updateMoveOffset.dx + _trW, _updateMoveOffset.dy + _trH);
      final absModel =
          Offset(absScaled.dx / scaleFactor, absScaled.dy / scaleFactor);
      final snappedModelPos = Offset(
        _snapPolicy.snapX(absModel.dx),
        _snapPolicy.snapY(absModel.dy),
      );

      // Apply both size and potential position change as one undoable action
      final currentModelPos =
          (child?.properties["position"]?.value as Offset?) ?? Offset.zero;
      resizeAndMaybeMove(
        child!,
        finalSizeModel,
        snappedModelPos,
        fromSize: startSize,
        fromAbsPos: currentModelPos,
      );

      // Sync local dynamic sizes to snapped values
      _dynamicW = finalSizeModel.width * scaleFactor;
      _dynamicH = finalSizeModel.height * scaleFactor;

      // Sync local translation to snapped position
      final scaled = Offset(
        snappedModelPos.dx * scaleFactor,
        snappedModelPos.dy * scaleFactor,
      );
      final relative = scaled - Offset(_trW, _trH);
      _updateMoveOffset = relative;

      // Reset resize flag AFTER all updates
      _isResizing = false;
      _currentResizeDirection = ResizeDirection.none;

      notifyListeners();
      _moveSession = null;
      _endResizeSession();
    } else {
      // Final position in model coordinates with grid snapping
      final finalAbsScaled = Offset(
        _updateMoveOffset.dx + _trW,
        _updateMoveOffset.dy + _trH,
      );
      final finalAbsModel = Offset(
        finalAbsScaled.dx / scaleFactor,
        finalAbsScaled.dy / scaleFactor,
      );
      final snappedModelPos = Offset(
        _snapPolicy.snapX(finalAbsModel.dx),
        _snapPolicy.snapY(finalAbsModel.dy),
      );

      // Compute delta in model space from current property
      final currentModelPos =
          (child?.properties["position"]?.value as Offset?) ?? Offset.zero;
      final delta = snappedModelPos - currentModelPos;

      // Apply to controller (emits ChangeItem and updates properties)
      moveItem(child!, delta, snap: false);

      // Update local state to the snapped scaled position
      final scaled = Offset(
        snappedModelPos.dx * scaleFactor,
        snappedModelPos.dy * scaleFactor,
      );
      final relative = scaled - Offset(_trW, _trH);
      _updateMoveOffset = relative;

      notifyListeners();
      _moveSession = null;
    }

    layoutController.eventBus.emit(PanEnd(id: child!.id));
  }

  void _handleMove(DragUpdateDetails details) {
    // Accumulate deltas in model space
    if (_moveSession == null) {
      _startMoveSession();
    }
    final dxM = details.delta.dx / scaleFactor;
    final dyM = details.delta.dy / scaleFactor;
    _accumulateMove(dxM, dyM);

    // Determine display position (snap optionally)
    final altPressed = _isAltPressed();
    final widthM = _dynamicW / scaleFactor;
    final heightM = _dynamicH / scaleFactor;
    double leftM = _moveSession!.leftM;
    double topM = _moveSession!.topM;
    if (_snapToGridEnabled && !altPressed) {
      leftM = _snapPolicy.snapX(leftM);
      topM = _snapPolicy.snapY(topM);
    }
    // Clamp for display as well
    leftM = _boundsPolicy.clampLeftForWidth(leftM, widthM);
    topM = _boundsPolicy.clampTopForHeight(topM, heightM);

    // Convert back to relative scaled offset
    final leftS = leftM * scaleFactor;
    final topS = topM * scaleFactor;
    final intervalOffset = Offset(leftS - _trW, topS - _trH);

    _updateMoveOffset = intervalOffset;
    notifyListeners();
  }

  // --- move session (model space) ---
  MoveSession? _moveSession;

  void _startMoveSession() {
    final leftM = (_trW + _updateMoveOffset.dx) / scaleFactor;
    final topM = (_trH + _updateMoveOffset.dy) / scaleFactor;
    _moveSession = MoveSession(leftM: leftM, topM: topM);
  }

  void _accumulateMove(double dxM, double dyM) {
    if (_moveSession == null) _startMoveSession();
    final s = _moveSession!;
    s.leftM += dxM;
    s.topM += dyM;
    // Clamp raw position to canvas considering current size
    final widthM = _dynamicW / scaleFactor;
    final heightM = _dynamicH / scaleFactor;
    s.leftM = _boundsPolicy.clampLeftForWidth(s.leftM, widthM);
    s.topM = _boundsPolicy.clampTopForHeight(s.topM, heightM);
  }

  // No explicit end needed; session is reset implicitly after pan end logic

  void _handleResize(DragUpdateDetails details) {
    // Initialize raw edges once, then accumulate in model space
    final dxM = details.delta.dx / scaleFactor;
    final dyM = details.delta.dy / scaleFactor;

    _accumulateResize(dxM, dyM);

    // Bounds and min in model space
    // bounds are enforced via _boundsPolicy below

    // Apply snapping for display if enabled and Alt not pressed
    final altPressed = _isAltPressed();
    final s = _resizeSession!;
    double leftM = s.leftM;
    double topM = s.topM;
    double rightM = s.rightM;
    double bottomM = s.bottomM;
    if (_snapToGridEnabled && !altPressed) {
      switch (_currentResizeDirection) {
        case ResizeDirection.right:
          rightM = _snapPolicy.snapX(rightM);
          break;
        case ResizeDirection.left:
          leftM = _snapPolicy.snapX(leftM);
          break;
        case ResizeDirection.bottom:
          bottomM = _snapPolicy.snapY(bottomM);
          break;
        case ResizeDirection.top:
          topM = _snapPolicy.snapY(topM);
          break;
        case ResizeDirection.topLeft:
          leftM = _snapPolicy.snapX(leftM);
          topM = _snapPolicy.snapY(topM);
          break;
        case ResizeDirection.topRight:
          rightM = _snapPolicy.snapX(rightM);
          topM = _snapPolicy.snapY(topM);
          break;
        case ResizeDirection.bottomLeft:
          leftM = _snapPolicy.snapX(leftM);
          bottomM = _snapPolicy.snapY(bottomM);
          break;
        case ResizeDirection.bottomRight:
          rightM = _snapPolicy.snapX(rightM);
          bottomM = _snapPolicy.snapY(bottomM);
          break;
        case ResizeDirection.none:
          break;
      }
    }

    // Re-apply clamps after snap
    leftM = _boundsPolicy.clampLeft(leftM);
    topM = _boundsPolicy.clampTop(topM);
    rightM = _boundsPolicy.clampRight(leftM, rightM);
    bottomM = _boundsPolicy.clampBottom(topM, bottomM);

    // Compose scaled outcome
    _dynamicW = (rightM - leftM) * scaleFactor;
    _dynamicH = (bottomM - topM) * scaleFactor;
    _trW = leftM * scaleFactor - _updateMoveOffset.dx;
    _trH = topM * scaleFactor - _updateMoveOffset.dy;

    // Don't mutate model during live resize; commit on pan end

    notifyListeners();
  }

  // --- resize session (model space) ---
  ResizeSession? _resizeSession;

  void _startResizeSession() {
    final leftM = (_trW + _updateMoveOffset.dx) / scaleFactor;
    final topM = (_trH + _updateMoveOffset.dy) / scaleFactor;
    final rightM = leftM + (_dynamicW / scaleFactor);
    final bottomM = topM + (_dynamicH / scaleFactor);
    _resizeSession = ResizeSession(
      leftM: leftM,
      topM: topM,
      rightM: rightM,
      bottomM: bottomM,
      direction: _currentResizeDirection,
      startWidthM: _dynamicW / scaleFactor,
      startHeightM: _dynamicH / scaleFactor,
    );
  }

  void _accumulateResize(double dxM, double dyM) {
    if (_resizeSession == null) _startResizeSession();
    final s = _resizeSession!;
    switch (_currentResizeDirection) {
      case ResizeDirection.right:
        s.rightM = (s.rightM + dxM);
        break;
      case ResizeDirection.left:
        s.leftM = (s.leftM + dxM);
        break;
      case ResizeDirection.bottom:
        s.bottomM = (s.bottomM + dyM);
        break;
      case ResizeDirection.top:
        s.topM = (s.topM + dyM);
        break;
      case ResizeDirection.topLeft:
        s.leftM = (s.leftM + dxM);
        s.topM = (s.topM + dyM);
        break;
      case ResizeDirection.topRight:
        s.rightM = (s.rightM + dxM);
        s.topM = (s.topM + dyM);
        break;
      case ResizeDirection.bottomLeft:
        s.leftM = (s.leftM + dxM);
        s.bottomM = (s.bottomM + dyM);
        break;
      case ResizeDirection.bottomRight:
        s.rightM = (s.rightM + dxM);
        s.bottomM = (s.bottomM + dyM);
        break;
      case ResizeDirection.none:
        break;
    }

    // clamp raw edges to canvas and min size
    const minSizeM = 20.0;
    final maxRightM = canvasWidth;
    final maxBottomM = canvasHeight;
    // ensure ordering
    s.leftM = s.leftM.clamp(0.0, maxRightM - minSizeM);
    s.topM = s.topM.clamp(0.0, maxBottomM - minSizeM);
    s.rightM = s.rightM.clamp(s.leftM + minSizeM, maxRightM);
    s.bottomM = s.bottomM.clamp(s.topM + minSizeM, maxBottomM);
  }

  void _endResizeSession() {
    _resizeSession = null;
  }

  bool _isAltPressed() {
    final keys = RawKeyboard.instance.keysPressed;
    return keys.contains(LogicalKeyboardKey.altLeft) ||
        keys.contains(LogicalKeyboardKey.altRight) ||
        keys.contains(LogicalKeyboardKey.alt);
  }

  void moveItem(
    Item element,
    Offset delta, {
    bool snap = false,
    double step = 5.0,
  }) {
    // Delegate to transformation service
    layoutController.transformationService
        .moveItem(element, delta, snap: snap, step: step);
  }

  /// Сдвинуть элемент по id.
  void moveItemById(
    String? itemId,
    Offset delta, {
    bool snap = false,
    double step = 5.0,
  }) {
    // Delegate to transformation service
    layoutController.transformationService
        .moveItemById(itemId, delta, snap: snap, step: step);
  }

  void resizeItem(
    Item element,
    Size newSize, {
    bool snap = false,
    double step = 5.0,
    Size? fromSize,
  }) {
    layoutController.transformationService.resizeItem(element, newSize,
        snap: snap, step: step, fromSize: fromSize);
  }

  void resizeAndMaybeMove(
    Item element,
    Size newSize,
    Offset? newAbsPos, {
    Size? fromSize,
    Offset? fromAbsPos,
  }) {
    layoutController.transformationService.resizeAndMaybeMove(
      element,
      newSize,
      newAbsPos,
      fromSize: fromSize,
      fromPosition: fromAbsPos,
    );
  }
}
