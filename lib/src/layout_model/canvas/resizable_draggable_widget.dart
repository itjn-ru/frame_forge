import '../controller/layout_model_controller.dart';
import 'layout_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../component.dart';
import 'controller/resizable_draggable_controller.dart';
import '../component_widget.dart';
import '../controller/events.dart';
import '../item.dart';
import 'model/resize_types.dart';

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
  this.rdController,
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
  // Optional external controller to keep state outside this stateless widget
  final ResizableDraggableController? rdController;
  @override
  State<ResizableDraggableWidget> createState() => _ResizableDraggableWidgetState();
}

class _ResizableDraggableWidgetState extends State<ResizableDraggableWidget> {
  ResizableDraggableController? _ownController;

  ResizableDraggableController get _ctrl =>
      widget.rdController ?? _ownController!;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.rdController == null && _ownController == null) {
      _ensureController(createdBy: 'didChangeDependencies');
    }
  }

  @override
  void didUpdateWidget(covariant ResizableDraggableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recreate our own controller if critical inputs changed and no external controller is provided
    final bool inputsChanged = oldWidget.scaleFactor != widget.scaleFactor ||
        oldWidget.canvasWidth != widget.canvasWidth ||
        oldWidget.canvasHeight != widget.canvasHeight ||
        oldWidget.cellWidth != widget.cellWidth ||
        oldWidget.cellHeight != widget.cellHeight;
    if (widget.rdController == null && inputsChanged) {
      _disposeOwnController();
      _ensureController(createdBy: 'didUpdateWidget(inputs)');
    }
    // Update item/position on controller if item changed or position changed
    if (oldWidget.child != widget.child || oldWidget.position != widget.position) {
      _ctrl.initFromItem(item: widget.child, position: widget.position);
    }
  }

  void _ensureController({required String createdBy}) {
    if (widget.rdController != null) return; // using external controller
  final LayoutModelController layoutCtrl = LayoutModelControllerProvider.of(context);
    _ownController = ResizableDraggableController(
      layoutController: layoutCtrl,
      scaleFactor: widget.scaleFactor,
      canvasWidth: widget.canvasWidth,
      canvasHeight: widget.canvasHeight,
      cellWidth: widget.cellWidth,
      cellHeight: widget.cellHeight,
    )..initFromItem(item: widget.child, position: widget.position);
  }

  @override
  void dispose() {
    _disposeOwnController();
    super.dispose();
  }

  void _disposeOwnController() {
    if (_ownController != null) {
      _ownController!.dispose();
      _ownController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LayoutModelController layoutCtrl = LayoutModelControllerProvider.of(context);
    final Color bg = widget.bgColor ?? Colors.amber;

    Widget getResizeable() {
      return MouseRegion(
        onHover: (PointerHoverEvent event) => _ctrl.onHover(event.localPosition, selected: widget.selected),
        cursor: _getCursorForDirection(_ctrl.currentResizeDirection),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(
              color: widget.selected ? Colors.red : Colors.transparent,
              width: widget.selected ? 2 : 0,
            ),
          ),
          width: _ctrl.dynamicW <= 0 ? 1 : _ctrl.dynamicW,
          height: _ctrl.dynamicH <= 0 ? 1 : _ctrl.dynamicH,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (widget.child is LayoutComponent)
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
                      layoutCtrl.layoutModel.deleteItem(widget.child!);
                      layoutCtrl.eventBus.emit(
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

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (BuildContext context, _) {
        return Transform.translate(
          offset: _ctrl.translateOffset,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _ctrl.onTap(selected: widget.selected),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (DragStartDetails details) => _ctrl.onPanStart(details, selected: widget.selected),
              onPanUpdate: (DragUpdateDetails details) => _ctrl.onPanUpdate(details, selected: widget.selected),
              onPanEnd: (_) => _ctrl.onPanEnd(selected: widget.selected),
              child: getResizeable(),
            ),
          ),
        );
      },
    );
  }
}

// Local helper to reuse existing cursors mapping
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
