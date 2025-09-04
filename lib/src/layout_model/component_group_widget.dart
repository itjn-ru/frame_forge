import 'package:flutter/material.dart';
import 'canvas/layout_model_provider.dart';
import 'canvas/resizable_draggable_widget.dart';
import 'canvas/screensize_provider.dart';
import 'component.dart';
import 'component_widget.dart';
import 'controller/events.dart';
import 'item.dart';
import 'style_element.dart';
import 'custom_border_radius.dart';

class ComponentGroupWidget extends ComponentWidget {
  const ComponentGroupWidget({required super.component, super.key});

  @override
  Widget buildWidget(BuildContext context) {
    final screenSize = ScreenSizeProvider.of(context);
    final controller = LayoutModelControllerProvider.of(context);
    final layoutModel = controller.layoutModel;
    var style = layoutModel.getStyleElementById(component['style'].id) ??
        StyleElement("стиль");
        final border = component.properties['borderRadius']?.value;
    // final border = component.properties['borderRadius']?.value;
     final topBorder = component.properties['topBorder']?.value;
    final bottomBorder = component.properties['bottomBorder']?.value;
    final leftBorder = component.properties['leftBorder']?.value;
    final rightBorder = component.properties['rightBorder']?.value;
    final padding = style['padding'] ?? [0, 0, 0, 0];
    return LayoutBuilder(builder: (context, constraints) {
      final scale = screenSize.width / constraints.maxWidth;
      final List<Item> items = List.generate(
          component.items.length, (index) => component.items[index]);
      return Container(
        key: UniqueKey(),
        // key: ValueKey('${component['id']}'),
        decoration: BoxDecoration(
          border: Border(
            top: topBorder.value,
            bottom: bottomBorder.value,
            left: leftBorder.value,
            right: rightBorder.value,
          ),
          color: style['backgroundColor'],
          borderRadius: (() {
            try {
              if (border is CustomBorderRadius) {
                return border.borderRadius(1 / scale);
              }
            } catch (_) {}
            return BorderRadius.zero;
          })(),
        ),
        padding: EdgeInsets.fromLTRB(padding[0] / scale, padding[1] / scale,
            padding[2] / scale, padding[3] / scale),
        alignment: component['alignment'],
        width: component['size'].width / scale,
        height: component['size'].height / scale,
        child: GroupCanvas(
          component,
          scale,
          items: items,
        ),
      );
    });
  }
}

class GroupCanvas extends StatelessWidget {
  final LayoutComponent component;
  final List<Item> items;
  final double scale;
  const GroupCanvas(this.component, this.scale,
      {required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    // return Stack(
    //   children: _initWidgetList(),
    // );
    final controller = LayoutModelControllerProvider.of(context);

    return ValueListenableBuilder<Set<String?>>(
        valueListenable: controller.changedItems,
        builder: (context, updatedItemIds, _) {
          final list = [];
          for (final item in items) {
            list.add(
              _ItemUpdateScope(
                itemId: item.id,
                updatedItemIds: updatedItemIds,
                child: ValueListenableBuilder<String?>(
                    valueListenable: controller.selectedIdNotifier,
                    builder: (context, selectedId, _) {
                      return ResizableDraggableWidget(
                        key: ValueKey(item.id),
                        position: Offset(item["position"]?.dx / scale ?? 0,
                            item["position"]?.dy / scale ?? 0),
                        initWidth: item["size"]?.width / scale,
                        initHeight: item["size"]?.height / scale ?? 50,
                        canvasWidth: component['size'].width / scale,
                        canvasHeight: component['size'].height / scale,
                        bgColor: const Color(0x33FFFFFF),
                        squareColor: Colors.blueAccent,
                        scaleConstraints: 1 / scale,
                        child: item,
                        selected: selectedId == item.id,
                      );
                    }),
              ),
            );
          }
          return Stack(children: [
            ...list,
            // ...templateWidgets,
          ]);
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

      // Перерисовываем — данные изменились
      return child;
    }
    // Здесь RepaintBoundary помогает избежать лишней перерисовки,
    // если это просто был ChangeItem, но не относящийся к этому item
    final last = controller.lastEvent;

    final isIsolated = last is ChangeItem;
    return isIsolated ? RepaintBoundary(child: child) : child;
  }
}
