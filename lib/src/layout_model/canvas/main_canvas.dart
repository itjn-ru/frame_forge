import 'screensize_provider.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart' show DeepCollectionEquality;
import 'dart:async';
import 'package:uuid/uuid.dart';

import '../controller/events.dart';
import '../controller/layout_model_controller.dart';
import '../item.dart';
import '../layout_model.dart';
import '../screen_size_enum.dart';
import 'grid_background_widget.dart';
import 'layout_model_provider.dart';
import 'resizable_draggable_widget.dart';

class MainCanvas extends StatefulWidget {
  final BoxConstraints constraints;
  const MainCanvas({super.key, required this.constraints});

  @override
  State<MainCanvas> createState() => _MainCanvasState();
}

class _MainCanvasState extends State<MainCanvas> {
  List<Widget> templateWidgets = [];
  List<Item> items = [];
  double wrappedWidth = 0;
  double wrappedHeight = 0;
  Offset position = const Offset(0, 0);
  late double _canvasHeight;
  late double _canvasWidth;

  /// The transformation controller for the interactive viewer.
  final TransformationController _transform = TransformationController();

  /// The scale factor for the canvas, calculated based on the screen size.
  double scaleFactor = 1.0;

  /// The scale size for the viewport, used to zoom in and out.
  /// This is updated when the user interacts with the canvas.
  double scaleZoom = 1;
  double cellWidth = 20;
  double cellHeight = 20;
  bool onIteraction = false;
  late Rect viewport;
  late LayoutModel layoutModel;
  Function deepEq = const DeepCollectionEquality().equals;
  bool changed = false;
  late BoxConstraints oldConstraints;
  late final LayoutModelController controller;

  late final ScreenSizeEnum screenSize;
  // Debounce timer to avoid emitting PanEnd on every interaction update
  Timer? _panDebounce;
  // Simple debug mode flag. Set to true for overlay with diagnostics.
  bool debugMode = false;
  // Count of items actually rendered in last build
  int _renderedItemCount = 0;
  final FocusNode _focusNode = FocusNode(debugLabel: 'MainCanvasFocus');
  @override
  void initState() {
    oldConstraints = widget.constraints;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = LayoutModelControllerProvider.of(context);
    screenSize = ScreenSizeProvider.of(context);
    layoutModel = controller.layoutModel;
    _recalculateScale();
    // Ensure canvas can receive keyboard focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant MainCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate scale if constraints changed
    if (widget.constraints != oldWidget.constraints) {
      oldConstraints = widget.constraints;
      _recalculateScale();
      setState(() {});
    }
  }

  void _recalculateScale() {
    _canvasWidth = widget.constraints.maxWidth - 20;
    _canvasHeight = widget.constraints.maxHeight - 20;
    scaleFactor = _canvasWidth / screenSize.width;
  // Grid step is stored in model units; convert to pixels for drawing
  final modelStepX = controller.gridStepX; // default 20
  final modelStepY = controller.gridStepY; // default 20
  cellWidth = modelStepX * scaleFactor;
  cellHeight = modelStepY * scaleFactor;
    viewport = Rect.fromLTRB(0, 0, _canvasWidth, _canvasHeight);
  }

  @override
  void dispose() {
    _transform.dispose();
    _panDebounce?.cancel();
  _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          color: Colors.grey.shade50,
          margin: const EdgeInsets.all(10),
        child: InteractiveViewer.builder(
          panEnabled: true,
          transformationController: _transform,
          onInteractionStart: (details) {},
          onInteractionUpdate: (details) {
            _onPanUpdate(details.focalPointDelta);
            // Debounce emitting PanEnd to avoid spamming event bus on each frame
            _schedulePanEndEmit();
          },
          onInteractionEnd: (scaleEndDetails) {
            scaleZoom = _transform.value.getMaxScaleOnAxis();
            controller.viewportZoom = scaleZoom;
            // Cancel any pending debounce and emit final PanEnd immediately
            _panDebounce?.cancel();
            controller.eventBus.emit(PanEnd(id: const Uuid().v4()));
          },
          minScale: 1,
          maxScale: 8,
          builder: (BuildContext context, quad) {
            return SizedBox.fromSize(
              key: ValueKey('${_canvasWidth}_${_canvasHeight}'),
              // key: UniqueKey(),
              size: viewport.size,
              child: ValueListenableBuilder<Set<String?>>(
                valueListenable: controller.changedItems,
                builder: (context, updatedItemIds, _) {
                  // Rebuild ordering when selection changes so selected is on top
                  return ValueListenableBuilder<String?>(
                    valueListenable: controller.selectedIdNotifier,
                    builder: (context, selectedId, __) {
                      final curPage = controller.getCurrentPage();
                      // Simple view culling: render only items that intersect the viewport
                      final expandedViewport = viewport.inflate(200);
                      final items = curPage.items;
                      final nonSelected = <Widget>[];
                      Widget? selectedWidget;
                      _renderedItemCount = 0;

                      for (var i = 0; i < items.length; i++) {
                        final item = items[i];
                        final dx = (item["position"]?.dx ?? 0) * scaleFactor;
                        final dy = (item["position"]?.dy ?? 0) * scaleFactor;
                        final w =
                            (item["size"]?.width ?? _canvasWidth) * scaleFactor;
                        final h = (item["size"]?.height ?? 30) * scaleFactor;

                        final itemRect = Rect.fromLTWH(dx, dy, w, h);
                        if (!itemRect.overlaps(expandedViewport)) {
                          continue;
                        }

                        _renderedItemCount++;
                        final widgetItem = _ItemUpdateScope(
                          itemId: item.id,
                          updatedItemIds: updatedItemIds,
                          child: ResizableDraggableWidget(
                            key: ValueKey(item.id),
                            position: Offset(dx, dy),
                            initWidth: w == 0 ? _canvasWidth : w,
                            initHeight: h == 0 ? 30 : h,
                            // Pass grid step in model units
                            cellWidth: controller.gridStepX,
                            cellHeight: controller.gridStepY,
                            canvasWidth: _canvasWidth,
                            canvasHeight: _canvasHeight,
                            bgColor: Colors.white,
                            squareColor: Colors.blueAccent,
                            scaleFactor: scaleFactor,
                            child: item,
                            selected: selectedId == item.id,
                          ),
                        );

                        if (selectedId == item.id) {
                          selectedWidget = widgetItem;
                        } else {
                          nonSelected.add(widgetItem);
                        }
                      }

                      final children = <Widget>[
                        Positioned.fill(
                          child: GridBackgroundBuilder(
                            quad: quad,
                            cellHeight: cellHeight,
                            cellWidth: cellWidth,
                            canvasWidth: _canvasWidth,
                          ),
                        ),
                        ...nonSelected,
                        if (selectedWidget != null) selectedWidget,
                      ];

                      // Debug overlay stays on top of everything
                      if (debugMode) {
                        children.add(
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.black.withAlpha(160),
                              child: DefaultTextStyle(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'scaleFactor: ${scaleFactor.toStringAsFixed(2)}',
                                    ),
                                    Text(
                                      'viewport: ${viewport.width.toStringAsFixed(0)}x${viewport.height.toStringAsFixed(0)}',
                                    ),
                                    Text(
                                      'rendered items: $_renderedItemCount / ${items.length}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return Stack(children: children);
                    },
                  );
                },
              ),
              // }),
            );
          },
        ),
      ),
    );
  }

  void _onPanUpdate(Offset delta) {
    final Matrix4 matrix = _transform.value.clone();
    matrix.translate(delta.dx, delta.dy);
    if (delta.dy < 0) {
      Rect rect = Rect.fromLTRB(
        0,
        0,
        _canvasWidth,
        viewport.height + delta.dy.abs(),
      );
      setState(() {
        viewport = rect;
      });
    }
  }



  void _schedulePanEndEmit() {
    _panDebounce?.cancel();
    _panDebounce = Timer(const Duration(milliseconds: 120), () {
      try {
        controller.eventBus.emit(PanEnd(id: const Uuid().v4()));
      } catch (_) {}
    });
  }


}

class _ItemUpdateScope extends StatelessWidget {
  final String itemId;
  final Widget child;
  final Set<String?> updatedItemIds;
  const _ItemUpdateScope({
    required this.itemId,
    required this.child,
    required this.updatedItemIds,
  });

  @override
  Widget build(BuildContext context) {
    final controller = LayoutModelControllerProvider.of(context);
    final shouldUpdate = updatedItemIds.contains(itemId);
    // Отметим как обработанный после перерисовки
    if (shouldUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.markItemAsHandled(itemId);
      });

      return child;
    }
    // Не трогай
    // Здесь RepaintBoundary помогает избежать лишней перерисовки,
    // если это просто был ChangeItem, но не относящийся к этому item
    final last = controller.lastEvent;

    final isIsolated = (last is ChangeEvent && last.itemId == itemId);
    return isIsolated ? RepaintBoundary(child: child) : child;
  }
}
