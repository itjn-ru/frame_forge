import 'package:flutter/material.dart';
import 'canvas/layout_model_provider.dart';
import 'canvas/resizable_draggable_widget.dart';
import 'component.dart';
import 'component_decoration_widget.dart';
import 'component_widget.dart';
import 'controller/events.dart';
import 'controller/layout_model_controller.dart';
import 'item.dart';

class ComponentGroupWidget extends ComponentWidget {
  final double scaleFactor;
  const ComponentGroupWidget({
    required super.component,
    required this.scaleFactor,
    super.key,
  });

  @override
  Widget buildWidget(BuildContext context) {
    final List<Item> items = List<Item>.generate(
      component.items.length,
      (int index) => component.items[index],
    );
    return ComponentDecorationWidget(
      component: component,
      scaleFactor: scaleFactor,
      child: GroupCanvas(component, scaleFactor, items: items),
    );
  }
}

class GroupCanvas extends StatelessWidget {
  final LayoutComponent component;
  final List<Item> items;
  final double scale;
  const GroupCanvas(
    this.component,
    this.scale, {
    required this.items,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final LayoutModelController controller = LayoutModelControllerProvider.of(context);

    return ValueListenableBuilder<Set<String?>>(
      valueListenable: controller.changedItems,
      builder: (BuildContext context, Set<String?> updatedItemIds, _) {
        final List<Widget> list = <Widget>[];
        for (final Item item in items) {
          list.add(
            _ItemUpdateScope(
              itemId: item.id,
              updatedItemIds: updatedItemIds,
              child: ValueListenableBuilder<String?>(
                valueListenable: controller.selectedIdNotifier,
                builder: (BuildContext context, String? selectedId, _) {
                  return ResizableDraggableWidget(
                    key: ValueKey<String>(item.id),
                    position: Offset(
                      item["position"]?.dx * scale ?? 0,
                      item["position"]?.dy * scale ?? 0,
                    ),
                    initWidth: item["size"]?.width * scale,
                    initHeight: item["size"]?.height * scale ?? 50,
                    canvasWidth: component['size'].width * scale,
                    canvasHeight: component['size'].height * scale,
                    bgColor: const Color(0x33FFFFFF),
                    squareColor: Colors.blueAccent,
                    scaleFactor: scale,
                    child: item,
                    selected: selectedId == item.id,
                  );
                },
              ),
            ),
          );
        }
        return Stack(
          children: [
            ...list,
            // ...templateWidgets,
          ],
        );
      },
    );
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
    final LayoutModelController controller = LayoutModelControllerProvider.of(context);
    final bool shouldUpdate = updatedItemIds.contains(itemId);
    // Mark as handled after repaint
    if (shouldUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.markItemAsHandled(itemId);
      });

      // Redraw — data has changed
      return child;
    }
    // Here RepaintBoundary helps avoid unnecessary redrawing,
    // if it was just a ChangeItem, but not related to this item
    final LayoutModelEvent? last = controller.lastEvent;

    final bool isIsolated = last is ChangeItem;
    return isIsolated ? RepaintBoundary(child: child) : child;
  }
}
