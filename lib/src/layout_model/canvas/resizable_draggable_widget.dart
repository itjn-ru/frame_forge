import '../property.dart';
import 'layout_model_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../component.dart';
import '../component_widget.dart';
import '../controller/events.dart';
import '../item.dart';

// Направления изменения размера
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

///Возвращает изменяемый виджет

class ResizableDraggableWidget extends StatefulWidget {
  const ResizableDraggableWidget({
    super.key,
    this.initWidth,
    this.initHeight = 60,
    this.child,
    this.bgColor,
    this.squareColor,
    // this.changed,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.scaleConstraints,
    this.cellWidth = 10.0,
    this.cellHeight = 10.0,
    required this.position,
    required this.selected,
  });

  ///Начальня ширина, по умолчанию ширина canvas
  final double? initWidth;

  ///Начальная высота, по умолчанию 60
  final double? initHeight;
  final double scaleConstraints;
  final double cellWidth;
  final double cellHeight;
  final Offset position;
  final Item? child;
  final Color? squareColor;

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

  bool _isResizing = false; // Флаг для отслеживания процесса изменения размера

  // Накопители для медленного изменения размера
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

    // Получаем реальные размеры из компонента
    final item = widget.child;
    final componentSize = item?.properties["size"]?.value as Size?;
    final componentWidth = componentSize?.width ?? 360.0;
    final componentHeight = componentSize?.height ?? 30.0;

    // Инициализируем динамические размеры с учетом scale
    _dynamicH = componentHeight * widget.scaleConstraints;
    _dynamicW = componentWidth * widget.scaleConstraints;

    // Отладочная информация
    debugPrint('Component size: $componentWidth x $componentHeight');
    debugPrint('Scale constraints: ${widget.scaleConstraints}');
    debugPrint('Dynamic size: $_dynamicW x $_dynamicH');

    _child = ComponentWidget.create(widget.child as LayoutComponent);
    _bgColor = widget.bgColor == null ? Colors.amber : widget.bgColor!;
    super.initState();

    // if(_showSquare) context.read<LayoutModel>().curComponentItem=widget.child!;
  }

  @override
  void didUpdateWidget(ResizableDraggableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Проверяем, не изменились ли размеры компонента извне
    // НО НЕ ОБНОВЛЯЕМ размеры если мы сейчас в процессе изменения размера
    if (!_isResizing) {
      final item = widget.child;
      final componentSize = item?.properties["size"]?.value as Size?;
      final componentWidth = componentSize?.width ?? 360.0;
      final componentHeight = componentSize?.height ?? 30.0;

      final newDynamicW = componentWidth * widget.scaleConstraints;
      final newDynamicH = componentHeight * widget.scaleConstraints;

      // Увеличиваем порог для предотвращения мелких обновлений
      if ((_dynamicW - newDynamicW).abs() > 5.0 ||
          (_dynamicH - newDynamicH).abs() > 5.0) {
        debugPrint(
          'External size change detected: $_dynamicW x $_dynamicH -> $newDynamicW x $newDynamicH',
        );
        debugPrint(
          'Component size from properties: $componentWidth x $componentHeight',
        );
        setState(() {
          _dynamicW = newDynamicW;
          _dynamicH = newDynamicH;
        });
      }
    } else {
      debugPrint('Skipping external size check - currently resizing');
    }

    // Обновляем child, если он изменился
    if (oldWidget.child != widget.child) {
      _child = ComponentWidget.create(widget.child as LayoutComponent);
    }
  }

  // Переменные для отслеживания областей изменения размера
  static const double _resizeEdgeWidth =
      15.0; // Увеличиваем область захвата края
  ResizeDirection _currentResizeDirection = ResizeDirection.none;

  // Определяет направление изменения размера на основе позиции курсора
  ResizeDirection _getResizeDirection(Offset localPosition) {
    if (!widget.selected) return ResizeDirection.none;

    final double width = _dynamicW;
    final double height = _dynamicH;
    final double x = localPosition.dx;
    final double y = localPosition.dy;

    // Убираем избыточные логи для производительности
    // debugPrint('_getResizeDirection: pos($x, $y), size($width x $height), edge: $_resizeEdgeWidth');

    // Проверяем углы (с приоритетом)
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
    // Проверяем края
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

  // Возвращает соответствующий курсор для направления изменения размера
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
          // Убираем избыточные логи - оставляем только для отладки при необходимости
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
    // Отладочная информация о текущих размерах при каждом рендеринге
    if (widget.selected) {
      debugPrint(
        'Building widget with size: $_dynamicW x $_dynamicH, position: ${trW + updateMoveOffset.dx} x ${trH + updateMoveOffset.dy}',
      );
    }

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
            debugPrint('onPanStart called! selected: ${widget.selected}');
            if (!widget.selected) return;

            _currentResizeDirection = _getResizeDirection(
              details.localPosition,
            );

            debugPrint(
              'onPanStart: localPosition=${details.localPosition}, direction=$_currentResizeDirection',
            );
            debugPrint(
              'Widget size: $_dynamicW x $_dynamicH, edge width: $_resizeEdgeWidth',
            );

            if (_currentResizeDirection != ResizeDirection.none) {
              _isResizing = true;
              _accumulatedDx =
                  0.0; // Сбрасываем накопители при начале изменения размера
              _accumulatedDy = 0.0;
              debugPrint(
                'Start resizing in direction: $_currentResizeDirection',
              );
            } else {
              startMoveOffset = details.localPosition;
              debugPrint('Start moving, startOffset: $startMoveOffset');
            }
          },
          onPanUpdate: (details) {
            if (!widget.selected) return;

            if (_isResizing) {
              debugPrint('onPanUpdate: resizing with delta=${details.delta}');
              _handleResize(details);
            } else {
              debugPrint('onPanUpdate: moving with delta=${details.delta}');
              _handleMove(details);
            }
          },
          onPanEnd: (details) {
            if (widget.selected) {
              if (_isResizing) {
                debugPrint(
                  'Resize completed. Final size: $_dynamicW x $_dynamicH',
                );

                // Финальное обновление свойств компонента с привязкой к сетке
                final finalSize = Size(
                  ((_dynamicW / widget.scaleConstraints) / 5.0).round() * 5.0,
                  ((_dynamicH / widget.scaleConstraints) / 5.0).round() * 5.0,
                );

                // Принудительно обновляем свойства компонента
                if (widget.child?.properties["size"] != null) {
                  widget.child?.properties["size"]?.value = finalSize;
                  controller.updateProperty(
                    "size",
                    Property("размер", finalSize, type: Size),
                  );
                }

                debugPrint('Final component size set to: $finalSize');

                // Принудительно обновляем состояние после завершения изменения размера
                setState(() {
                  // Убеждаемся, что размеры соответствуют новым значениям
                  final newComponentSize =
                      widget.child?.properties["size"]?.value as Size?;
                  if (newComponentSize != null) {
                    final expectedDynamicW =
                        newComponentSize.width * widget.scaleConstraints;
                    final expectedDynamicH =
                        newComponentSize.height * widget.scaleConstraints;
                    debugPrint(
                      'Expected dynamic size based on component: $expectedDynamicW x $expectedDynamicH',
                    );
                    // Синхронизируем динамические размеры с компонентом
                    _dynamicW = expectedDynamicW;
                    _dynamicH = expectedDynamicH;
                  }
                });

                // Сбрасываем флаг изменения размера ПОСЛЕ всех обновлений
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
      ((transformOffset.dx / widget.scaleConstraints) / 5.0).round() * 5.0,
      ((transformOffset.dy / widget.scaleConstraints) / 5.0).round() * 5.0,
    );

    // Привязка к сетке кратно 5 пикселям для размеров
    final size = Size(
      ((width / widget.scaleConstraints) / 5.0).round() * 5.0,
      ((height / widget.scaleConstraints) / 5.0).round() * 5.0,
    );

    // Обновляем свойства компонента
    if (widget.child?.properties["position"] != null) {
      widget.child?.properties["position"]?.value = offset;
    }

    if (widget.child?.properties["size"] != null) {
      widget.child?.properties["size"]?.value = size;
    }

    // Уведомляем контроллер об изменениях
    controller.updateProperty(
      "position",
      Property("положение", offset, type: Offset),
    );
    controller.updateProperty("size", Property("размер", size, type: Size));

    debugPrint(
      'onChanged: new size: $size, new position: $offset, scale: ${widget.scaleConstraints}, dynamic size: $width x $height',
    );
  }

  void _handleMove(DragUpdateDetails details) {
    var intervalOffset =
        details.localPosition - startMoveOffset + endMoveOffset;

    // Ограничение по вертикали
    if (intervalOffset.dy < -trLastH) {
      intervalOffset = Offset(intervalOffset.dx, -trLastH);
    }

    // Привязка к сетке кратно 5 пикселям
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
    debugPrint(
      '_handleResize: direction=$_currentResizeDirection, delta=${details.delta}, current size: $_dynamicW x $_dynamicH',
    );

    // Накапливаем дельту для обработки медленных движений
    _accumulatedDx += details.delta.dx;
    _accumulatedDy += details.delta.dy;

    // Применяем изменения только когда накопленная дельта достигает порога (например, 5 пикселей)
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

    // Если нет значимых изменений, выходим
    if (dx == 0.0 && dy == 0.0) {
      return;
    }

    final oldW = _dynamicW;
    final oldH = _dynamicH;
    final oldTrW = trW;
    final oldTrH = trH;

    // Сначала вычисляем новые размеры без привязки к сетке
    double newDynamicW = _dynamicW;
    double newDynamicH = _dynamicH;
    double newTrW = trW;
    double newTrH = trH;

    switch (_currentResizeDirection) {
      case ResizeDirection.right:
        newDynamicW = (_dynamicW + dx).clamp(20, widget.canvasWidth).toDouble();
        debugPrint('Right resize: $oldW -> $newDynamicW (delta: $dx)');
        break;
      case ResizeDirection.left:
        // При тяжении левого края вправо: уменьшаем размер, увеличиваем отступ
        // При тяжении левого края влево: увеличиваем размер, уменьшаем отступ
        newDynamicW = (_dynamicW - dx).clamp(20, widget.canvasWidth).toDouble();
        newTrW = trW + dx; // Сдвигаем позицию на величину изменения
        debugPrint(
          'Left resize: $oldW -> $newDynamicW, trW: $oldTrW -> $newTrW (delta: $dx)',
        );
        break;
      case ResizeDirection.bottom:
        newDynamicH = (_dynamicH + dy)
            .clamp(20, widget.canvasHeight)
            .toDouble();
        debugPrint('Bottom resize: $oldH -> $newDynamicH (delta: $dy)');
        break;
      case ResizeDirection.top:
        // При тяжении верхнего края вниз: уменьшаем размер, увеличиваем отступ
        // При тяжении верхнего края вверх: увеличиваем размер, уменьшаем отступ
        newDynamicH = (_dynamicH - dy)
            .clamp(20, widget.canvasHeight)
            .toDouble();
        newTrH = trH + dy; // Сдвигаем позицию на величину изменения
        debugPrint(
          'Top resize: $oldH -> $newDynamicH, trH: $oldTrH -> $newTrH (delta: $dy)',
        );
        break;
      case ResizeDirection.topLeft:
        newDynamicW = (_dynamicW - dx).clamp(20, widget.canvasWidth).toDouble();
        newDynamicH = (_dynamicH - dy)
            .clamp(20, widget.canvasHeight)
            .toDouble();
        newTrW = trW + dx;
        newTrH = trH + dy;
        debugPrint(
          'TopLeft resize: ${oldW}x$oldH -> ${newDynamicW}x$newDynamicH, pos: $oldTrW,$oldTrH -> $newTrW,$newTrH',
        );
        break;
      case ResizeDirection.topRight:
        newDynamicW = (_dynamicW + dx).clamp(20, widget.canvasWidth).toDouble();
        newDynamicH = (_dynamicH - dy)
            .clamp(20, widget.canvasHeight)
            .toDouble();
        newTrH = trH + dy;
        debugPrint(
          'TopRight resize: ${oldW}x$oldH -> ${newDynamicW}x$newDynamicH, trH: $oldTrH -> $newTrH',
        );
        break;
      case ResizeDirection.bottomLeft:
        newDynamicW = (_dynamicW - dx).clamp(20, widget.canvasWidth).toDouble();
        newDynamicH = (_dynamicH + dy)
            .clamp(20, widget.canvasHeight)
            .toDouble();
        newTrW = trW + dx;
        debugPrint(
          'BottomLeft resize: ${oldW}x$oldH -> ${newDynamicW}x$newDynamicH, trW: $oldTrW -> $newTrW',
        );
        break;
      case ResizeDirection.bottomRight:
        newDynamicW = (_dynamicW + dx).clamp(20, widget.canvasWidth).toDouble();
        newDynamicH = (_dynamicH + dy)
            .clamp(20, widget.canvasHeight)
            .toDouble();
        debugPrint(
          'BottomRight resize: ${oldW}x$oldH -> ${newDynamicW}x$newDynamicH',
        );
        break;
      case ResizeDirection.none:
        return; // Не делаем ничего, если нет направления
    }

    // Применяем изменения и обновляем состояние
    setState(() {
      _dynamicW = newDynamicW;
      _dynamicH = newDynamicH;
      trW = newTrW;
      trH = newTrH;

      // Размеры уже кратны 5, так как dx и dy уже округлены
    });

    // Обновляем свойства компонента и уведомляем контроллер
    onChanged(_dynamicW, _dynamicH, updateMoveOffset + Offset(trW, trH));
  }
}
