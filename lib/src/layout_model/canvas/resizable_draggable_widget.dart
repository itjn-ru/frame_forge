import 'package:uuid/uuid.dart';

import '../property.dart';
import 'layout_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../component.dart';
import '../component_widget.dart';
import '../controller/events.dart';
import '../item.dart';

/// Directions for resizing
enum ResizeDirection {
  none,
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

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

  Widget? _child;
  Color? _bgColor;
  double scale = 1.0;

  late final controller = LayoutModelControllerProvider.of(context);

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

    _child = ComponentWidget.create(widget.child as LayoutComponent, scaleFactor: widget.scaleFactor);
    _bgColor = widget.bgColor == null ? Colors.amber : widget.bgColor!;
    super.initState();

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
    if (oldWidget.child != widget.child) {
      _child = ComponentWidget.create(widget.child as LayoutComponent, scaleFactor: widget.scaleFactor);
    }
  }

  // Variables for tracking resize areas
  static const double _resizeEdgeWidth =
      15.0; // Increase the edge capture area
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
            _child!,
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

                // Final component property update with grid snapping
                final finalSize = Size(
                  ((_dynamicW / widget.scaleFactor) / 5.0).round() * 5.0,
                  ((_dynamicH / widget.scaleFactor) / 5.0).round() * 5.0,
                );

                // Force update component properties
                if (widget.child?.properties["size"] != null) {
                  widget.child?.properties["size"]?.value = finalSize;
                  controller.updateProperty(
                    "size",
                    Property("размер", finalSize, type: Size),
                  );
                  controller.eventBus.emit(
                      ChangeItem(id: Uuid().v4(), itemId: widget.child!.id),
                    );
                }

                // Force state update after resize completion
                setState(() {
                  // Ensure sizes match new values
                  final newComponentSize =
                      widget.child?.properties["size"]?.value as Size?;
                  if (newComponentSize != null) {
                    final expectedDynamicW =
                        newComponentSize.width * widget.scaleFactor;
                    final expectedDynamicH =
                        newComponentSize.height * widget.scaleFactor;
                    
                    // Synchronize dynamic sizes with component
                    _dynamicW = expectedDynamicW;
                    _dynamicH = expectedDynamicH;
                  }
                });

                // Reset resize flag AFTER all updates
                _isResizing = false;
                _currentResizeDirection = ResizeDirection.none;
              } else {
                endMoveOffset = updateMoveOffset;
              }
              controller.eventBus.emit(PanEnd(id: widget.child!.id));
            }
          },
          child: getResizeable(),
        ),
      ),
    );
  }

  void onChanged(double width, double height, Offset transformOffset) {
    final offset = Offset(
      ((transformOffset.dx / widget.scaleFactor) / 5.0).round() * 5.0,
      ((transformOffset.dy / widget.scaleFactor) / 5.0).round() * 5.0,
    );

    // Grid snapping to multiples of 5 pixels for sizes
    final size = Size(
      ((width / widget.scaleFactor) / 5.0).round() * 5.0,
      ((height / widget.scaleFactor) / 5.0).round() * 5.0,
    );

    // Update component properties
    if (widget.child?.properties["position"] != null) {
      widget.child?.properties["position"]?.value = offset;
    }

    if (widget.child?.properties["size"] != null) {
      widget.child?.properties["size"]?.value = size;
    }

    // Notify controller about changes
    controller.updateProperty(
      "position",
      Property("положение", offset, type: Offset),
    );
    controller.updateProperty("size", Property("размер", size, type: Size));
  }

  void _handleMove(DragUpdateDetails details) {
    var intervalOffset =
        details.localPosition - startMoveOffset + endMoveOffset;

    // Vertical constraint
    if (intervalOffset.dy < -trLastH) {
      intervalOffset = Offset(intervalOffset.dx, -trLastH);
    }

    // Grid snapping to multiples of 5 pixels
    final snappedOffset = Offset(
      (intervalOffset.dx / 5.0).round() * 5.0,
      (intervalOffset.dy / 5.0).round() * 5.0,
    );

    setState(() {
      updateMoveOffset = snappedOffset;
    });
    onChanged(_dynamicW, _dynamicH, updateMoveOffset + Offset(trW, trH));
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

    final oldW = _dynamicW;
    final oldH = _dynamicH;
    final oldTrW = trW;
    final oldTrH = trH;

    // First calculate new sizes without grid snapping
    double newDynamicW = _dynamicW;
    double newDynamicH = _dynamicH;
    double newTrW = trW;
    double newTrH = trH;

    switch (_currentResizeDirection) {
      case ResizeDirection.right:
        newDynamicW = (_dynamicW + dx).clamp(20, widget.canvasWidth).toDouble();
        break;
      case ResizeDirection.left:
        // When dragging left edge right: decrease size, increase offset
        // When dragging left edge left: increase size, decrease offset
        newDynamicW = (_dynamicW - dx).clamp(20, widget.canvasWidth).toDouble();
        newTrW = trW + dx; // Move position by the change amount
        break;
      case ResizeDirection.bottom:
        newDynamicH = (_dynamicH + dy)
            .clamp(20, widget.canvasHeight)
            .toDouble();
        break;
      case ResizeDirection.top:
        // When dragging top edge down: decrease size, increase offset
        // When dragging top edge up: increase size, decrease offset
        newDynamicH = (_dynamicH - dy)
            .clamp(20, widget.canvasHeight)
            .toDouble();
        newTrH = trH + dy; // Move position by the change amount
        break;
      case ResizeDirection.topLeft:
        newDynamicW = (_dynamicW - dx).clamp(20, widget.canvasWidth).toDouble();
        newDynamicH = (_dynamicH - dy)
            .clamp(20, widget.canvasHeight)
            .toDouble();
        newTrW = trW + dx;
        newTrH = trH + dy;
        break;
      case ResizeDirection.topRight:
        newDynamicW = (_dynamicW + dx).clamp(20, widget.canvasWidth).toDouble();
        newDynamicH = (_dynamicH - dy)
            .clamp(20, widget.canvasHeight)
            .toDouble();
        newTrH = trH + dy;
        break;
      case ResizeDirection.bottomLeft:
        newDynamicW = (_dynamicW - dx).clamp(20, widget.canvasWidth).toDouble();
        newDynamicH = (_dynamicH + dy)
            .clamp(20, widget.canvasHeight)
            .toDouble();
        newTrW = trW + dx;
        break;
      case ResizeDirection.bottomRight:
        newDynamicW = (_dynamicW + dx).clamp(20, widget.canvasWidth).toDouble();
        newDynamicH = (_dynamicH + dy)
            .clamp(20, widget.canvasHeight)
            .toDouble();
        break;
      case ResizeDirection.none:
        return; // Do nothing if no direction
    }

    // Apply changes and update state
    setState(() {
      _dynamicW = newDynamicW;
      _dynamicH = newDynamicH;
      trW = newTrW;
      trH = newTrH;

      // Update component sizes in real time during resize
      if (widget.child?.properties["size"] != null) {
        final newComponentSize = Size(
          newDynamicW / widget.scaleFactor,
          newDynamicH / widget.scaleFactor,
        );
        widget.child?.properties["size"]?.value = newComponentSize;
        
        // Recreate child with new sizes
        _child = ComponentWidget.create(widget.child as LayoutComponent, scaleFactor: widget.scaleFactor);
      }
    });

    // Update component properties and notify controller
    onChanged(_dynamicW, _dynamicH, updateMoveOffset + Offset(trW, trH));
  }
}
