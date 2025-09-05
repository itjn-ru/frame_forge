import 'package:flutter/widgets.dart';
import '../../item.dart';
import 'constants.dart';

/// Извлекает глобальный offset виджета с помощью [GlobalKey].
Offset? getOffsetFromGlobalKey(GlobalKey key) {
  final renderObject = key.currentContext?.findRenderObject();
  if (renderObject is RenderBox) {
    return renderObject.localToGlobal(Offset.zero);
  }
  return null;
}

/// Извлекает глобальный offset виджета относительно другого виджета.
Offset? getOffsetFromGlobalKeyRelativeTo(GlobalKey key, GlobalKey relativeTo) {
  final renderObject = key.currentContext?.findRenderObject();
  final relativeRenderObject = relativeTo.currentContext?.findRenderObject();
  if (renderObject is RenderBox && relativeRenderObject is RenderBox) {
    return renderObject.localToGlobal(
      Offset.zero,
      ancestor: relativeRenderObject,
    );
  }
  return null;
}

/// Извлекает размер виджета с помощью [GlobalKey].
Size? getSizeFromGlobalKey(GlobalKey key) {
  final renderObject = key.currentContext?.findRenderObject();
  if (renderObject is RenderBox) {
    return renderObject.size;
  }
  return null;
}

/// Извлекает границы виджета [Item].
Rect? getNodeBoundsInWorld(Item item) {
  /// Нужен [GlobalKey]
  // final size = getSizeFromGlobalKey(item.key);
  // if (size != null) {
  //   return Rect.fromLTWH(
  //     item['position'].dx,
  //     item['position'].dy,
  //     size.width,
  //     size.height,
  //   );
  // }
  return null;
}

Rect? getEditorBoundsInScreen(GlobalKey key) {
  final size = getSizeFromGlobalKey(key);
  final offset = getOffsetFromGlobalKey(key);
  if (size != null && offset != null) {
    return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
  }
  return null;
}

/// Преобразует положение экрана в положение canvas.
Offset? screenToWorld(Offset screenPosition, Offset offset, double zoom) {
  // Получить доступ к границам виджета редактора на экране
  final nodeEditorBounds = getEditorBoundsInScreen(kNodeEditorWidgetKey);
  if (nodeEditorBounds == null) return null;
  final size = nodeEditorBounds.size;

  // Подогнать положение экрана относительно левого верхнего угла редактора
  final adjustedScreenPosition = screenPosition - nodeEditorBounds.topLeft;

  // Вычислить прямоугольник viewport в canvas
  final viewport = Rect.fromLTWH(
    -size.width / 2 / zoom - offset.dx,
    -size.height / 2 / zoom - offset.dy,
    size.width / zoom,
    size.height / zoom,
  );

  // Вычислить положение canvas, соответствующее положению экрана
  final canvasX =
      viewport.left + (adjustedScreenPosition.dx / size.width) * viewport.width;
  final canvasY =
      viewport.top +
      (adjustedScreenPosition.dy / size.height) * viewport.height;

  return Offset(canvasX, canvasY);
}

RelativeRect buttonMenuPosition(BuildContext context, PointerDownEvent event) {
  //final RenderBox bar = context.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  const Offset offset = Offset.zero;
  final RelativeRect rect = RelativeRect.fromRect(
    Rect.fromPoints(event.localPosition, event.position),
    offset & overlay.size,
  );
  return rect;
}
