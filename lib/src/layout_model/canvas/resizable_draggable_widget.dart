import 'layout_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../component.dart';
import 'drag_resize_logic.dart';
import '../component_widget.dart';
import '../controller/events.dart';
import '../item.dart';
import 'resize_types.dart';

/// A widget that allows its child to be resized and dragged within a canvas.
/// It provides visual cues for resizing and handles user interactions.
class ResizableDraggableWidget extends StatefulWidget {
  const ResizableDraggableWidget({
    super.key,
    this.initWidth,
    this.initHeight = 60,
    this.child,
    this.bgColor,
    this.squareColor,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.scaleFactor,
    this.cellWidth = 10.0,
    this.cellHeight = 10.0,
    required this.position,
    required this.selected,
  });

  /// width at start, default 360
  final double? initWidth;

  /// height at start, default 60
  final double? initHeight;

  /// scale of canvas constraints to real size
  final double scaleFactor;

  /// width of each cell in the grid
  final double cellWidth;

  /// height of each cell in the grid
  final double cellHeight;

  /// initial position of the widget
  final Offset position;

  /// The child widget to be made resizable and draggable.
  final Item? child;

  /// If true, shows a square handle for resizing.
  final Color? squareColor;

  /// Background color of the widget.
  final Color? bgColor;

  //final Function(double width, double height, Offset transformOffset)? changed;
  final double canvasHeight;
  final double canvasWidth;
  final bool selected;
  @override
  State<ResizableDraggableWidget> createState() =>
      _ResizableDraggableWidgetState();
}

class _ResizableDraggableWidgetState extends State<ResizableDraggableWidget> {
  double _dynamicH = 0;
  double _dynamicW = 0;

  late double trH;
  late double trW;

  double trLastH = 0;
  double trLastW = 0;

  bool _isResizing = false; // Flag to track the resizing process

  // Accumulators for slow resize changes
  double _accumulatedDx = 0.0;
  double _accumulatedDy = 0.0;

  // Build child on the fly to reflect latest properties
  Color? _bgColor;
  double scale = 1.0;

  late final controller = LayoutModelControllerProvider.of(context);
  DragResizeLogic? _logic;

  @override
  void initState() {
    trW = widget.position.dx;
    trH = widget.position.dy;

    trLastH = trH;
    trLastW = trW;
    trW = (trW / 5.0).round() * 5.0;
    trH = (trH / 5.0).round() * 5.0;

    // Get real sizes from the component
    final item = widget.child;
    final componentSize = item?.properties["size"]?.value as Size?;
    final componentWidth = componentSize?.width ?? 360.0;
    final componentHeight = componentSize?.height ?? 30.0;

    // Initialize dynamic sizes with scale factor
    _dynamicH = componentHeight * widget.scaleFactor;
    _dynamicW = componentWidth * widget.scaleFactor;

    _bgColor = widget.bgColor == null ? Colors.amber : widget.bgColor!;
    super.initState();
    _logic = DragResizeLogic(
      scaleFactor: widget.scaleFactor,
      gridStep: 5.0,
      canvasWidth: widget.canvasWidth,
      canvasHeight: widget.canvasHeight,
    );

    // if(_showSquare) context.read<LayoutModel>().curComponentItem=widget.child!;
  }

  @override
  void didUpdateWidget(ResizableDraggableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if component sizes changed externally
    // BUT DO NOT UPDATE sizes if we are currently resizing
    if (!_isResizing) {
      final item = widget.child;
      final componentSize = item?.properties["size"]?.value as Size?;
      final componentWidth = componentSize?.width ?? 360.0;
      final componentHeight = componentSize?.height ?? 30.0;

      final newDynamicW = componentWidth * widget.scaleFactor;
      final newDynamicH = componentHeight * widget.scaleFactor;

      // Increase threshold to prevent minor updates
      if ((_dynamicW - newDynamicW).abs() > 5.0 ||
          (_dynamicH - newDynamicH).abs() > 5.0) {
        setState(() {
          _dynamicW = newDynamicW;
          _dynamicH = newDynamicH;
        });
      }
    } else {
      debugPrint('Skipping external size check - currently resizing');
    }

    // Update child if it changed
    // Child rebuild handled in build via factory to reflect property changes
  }

  // Variables for tracking resize areas
  static const double _resizeEdgeWidth = 15.0; // Increase the edge capture area
  ResizeDirection _currentResizeDirection = ResizeDirection.none;

  // Determines resize direction based on cursor position
  ResizeDirection _getResizeDirection(Offset localPosition) {
    if (!widget.selected) return ResizeDirection.none;

    final double width = _dynamicW;
    final double height = _dynamicH;
    final double x = localPosition.dx;
    final double y = localPosition.dy;

    // Remove excessive logs for performance
    // debugPrint('_getResizeDirection: pos($x, $y), size($width x $height), edge: $_resizeEdgeWidth');

    // Check corners (with priority)
    if (x <= _resizeEdgeWidth && y <= _resizeEdgeWidth) {
      return ResizeDirection.topLeft;
    } else if (x >= width - _resizeEdgeWidth && y <= _resizeEdgeWidth) {
      return ResizeDirection.topRight;
    } else if (x <= _resizeEdgeWidth && y >= height - _resizeEdgeWidth) {
      return ResizeDirection.bottomLeft;
    } else if (x >= width - _resizeEdgeWidth &&
        y >= height - _resizeEdgeWidth) {
      return ResizeDirection.bottomRight;
    }
    // Check edges
    else if (y <= _resizeEdgeWidth) {
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

  // Returns appropriate cursor for resize direction
  SystemMouseCursor _getCursorForDirection(ResizeDirection direction) {
    switch (direction) {
      case ResizeDirection.top:
      case ResizeDirection.bottom:
        return SystemMouseCursors.resizeUpDown;
      case ResizeDirection.left:
      case ResizeDirection.right:
        return SystemMouseCursors.resizeLeftRight;
      case ResizeDirection.topLeft:
      case ResizeDirection.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case ResizeDirection.topRight:
      case ResizeDirection.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case ResizeDirection.none:
        return SystemMouseCursors.basic;
    }
  }

  Widget getResizeable() {
    return MouseRegion(
      onHover: (event) {
        final direction = _getResizeDirection(event.localPosition);
        if (direction != _currentResizeDirection) {
          setState(() {
            _currentResizeDirection = direction;
          });
          // Remove excessive logs - keep only for debugging when necessary
          // debugPrint('Hover direction changed to: $direction');
        }
      },
      cursor: _getCursorForDirection(_currentResizeDirection),
      child: Container(
        decoration: BoxDecoration(
          color: _bgColor,
          border: Border.all(
            color: widget.selected ? Colors.red : Colors.transparent,
            width: widget.selected ? 2 : 0,
          ),
        ),
        width: _dynamicW <= 0 ? 1 : _dynamicW,
        height: _dynamicH <= 0 ? 1 : _dynamicH,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            ComponentWidget.create(
              widget.child as LayoutComponent,
              scaleFactor: widget.scaleFactor,
            ),
            if (widget.selected)
              Positioned(
                right: 10,
                top: -10,
                child: IconButton(
                  onPressed: () {
                    controller.layoutModel.deleteItem(widget.child!);
                    controller.eventBus.emit(
                      RemoveItemEvent(id: widget.child!.id),
                    );
                  },
                  icon: const Icon(Icons.delete),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Offset startMoveOffset = const Offset(0, 0);
  Offset endMoveOffset = const Offset(0, 0);
  Offset updateMoveOffset = const Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: updateMoveOffset + Offset(trW, trH),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (widget.selected) {
            controller.select(null);
            return;
          }
          controller.select(widget.child!.id);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            if (!widget.selected) return;

            _currentResizeDirection = _getResizeDirection(
              details.localPosition,
            );

            if (_currentResizeDirection != ResizeDirection.none) {
              _isResizing = true;
              _accumulatedDx =
                  0.0; // Reset accumulators at the start of resizing
              _accumulatedDy = 0.0;
            } else {
              startMoveOffset = details.localPosition;
            }
          },
          onPanUpdate: (details) {
            if (!widget.selected) return;

            if (_isResizing) {
              _handleResize(details);
            } else {
              _handleMove(details);
            }
          },
          onPanEnd: (details) {
            if (widget.selected) {
              if (_isResizing) {
                // Final size in model coordinates with grid snapping
                final finalSizeModel = _logic!.snapFinalSize(
                  _dynamicW,
                  _dynamicH,
                );

                // Apply to controller (emits ChangeItem and updates properties)
                controller.resize(widget.child!, finalSizeModel, snap: false);

                // If resizing from left/top edges, position may change too
                final snappedModelPos = _logic!.snapFinalPosition(
                  updateMoveOffset,
                  trW,
                  trH,
                );
                final currentModelPos =
                    (widget.child?.properties["position"]?.value as Offset?) ??
                    Offset.zero;
                final deltaPos = snappedModelPos - currentModelPos;
                if (deltaPos.dx != 0 || deltaPos.dy != 0) {
                  controller.move(widget.child!, deltaPos, snap: false);
                }

                // Sync local dynamic sizes to snapped values
                setState(() {
                  _dynamicW = finalSizeModel.width * widget.scaleFactor;
                  _dynamicH = finalSizeModel.height * widget.scaleFactor;

                  // Sync local translation to snapped position
                  final scaled = Offset(
                    snappedModelPos.dx * widget.scaleFactor,
                    snappedModelPos.dy * widget.scaleFactor,
                  );
                  final relative = scaled - Offset(trW, trH);
                  updateMoveOffset = relative;
                  endMoveOffset = relative;
                });

                // Reset resize flag AFTER all updates
                _isResizing = false;
                _currentResizeDirection = ResizeDirection.none;
              } else {
                // Final position in model coordinates with grid snapping
                endMoveOffset = updateMoveOffset;
                final snappedModelPos = _logic!.snapFinalPosition(
                  updateMoveOffset,
                  trW,
                  trH,
                );

                // Compute delta in model space from current property
                final currentModelPos =
                    (widget.child?.properties["position"]?.value as Offset?) ??
                    Offset.zero;
                final delta = snappedModelPos - currentModelPos;

                // Apply to controller (emits ChangeItem and updates properties)
                controller.move(widget.child!, delta, snap: false);

                // Update local state to the snapped scaled position
                setState(() {
                  final scaled = Offset(
                    snappedModelPos.dx * widget.scaleFactor,
                    snappedModelPos.dy * widget.scaleFactor,
                  );
                  final relative = scaled - Offset(trW, trH);
                  updateMoveOffset = relative;
                  endMoveOffset = relative;
                });
              }
              controller.eventBus.emit(PanEnd(id: widget.child!.id));
            }
          },
          child: getResizeable(),
        ),
      ),
    );
  }

  // removed: onChanged (controller is called onPanEnd)

  void _handleMove(DragUpdateDetails details) {
    final intervalOffset = _logic!.computeMoveOffset(
      details.localPosition,
      startMoveOffset,
      endMoveOffset,
      trLastH,
    );

    setState(() {
      updateMoveOffset = intervalOffset; // no snapping during move
    });
  }

  void _handleResize(DragUpdateDetails details) {
    // Accumulate delta for handling slow movements
    _accumulatedDx += details.delta.dx;
    _accumulatedDy += details.delta.dy;

    // Apply changes only when accumulated delta reaches threshold (e.g., 5 pixels)
    double dx = 0.0;
    double dy = 0.0;

    if (_accumulatedDx.abs() >= 5.0) {
      dx = (_accumulatedDx / 5.0).round() * 5.0;
      _accumulatedDx -= dx;
    }

    if (_accumulatedDy.abs() >= 5.0) {
      dy = (_accumulatedDy / 5.0).round() * 5.0;
      _accumulatedDy -= dy;
    }

    // If no significant changes, exit
    if (dx == 0.0 && dy == 0.0) {
      return;
    }

    // Compute new sizes/translation using logic helper
    final outcome = _logic!.computeResize(
      direction: _currentResizeDirection,
      dx: dx,
      dy: dy,
      dynamicW: _dynamicW,
      dynamicH: _dynamicH,
      trW: trW,
      trH: trH,
    );

    // Apply changes and update state
    setState(() {
      _dynamicW = outcome.dynamicW;
      _dynamicH = outcome.dynamicH;
      trW = outcome.trW;
      trH = outcome.trH;

      // Update component sizes in real time during resize
      if (widget.child?.properties["size"] != null) {
        final newComponentSize = Size(
          outcome.dynamicW / widget.scaleFactor,
          outcome.dynamicH / widget.scaleFactor,
        );
        widget.child?.properties["size"]?.value = newComponentSize;

        // Recreate child with new sizes
        // child is rebuilt in build
      }
    });

    // Skip controller updates during drag; apply on pan end
  }
}
