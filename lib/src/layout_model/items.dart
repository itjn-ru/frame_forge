import 'package:flutter/material.dart';
import 'package:flutter/src/gestures/events.dart';
import 'package:frame_forge/src/flutter_context_menu/core/models/context_menu_entry.dart';
import 'package:frame_forge/src/layout_model/controller/events.dart';

import '../canvas/context_menu.dart';
import '../canvas/layout_model_provider.dart';
import 'controller/layout_model_controller.dart';
import 'item.dart';
import 'menu.dart';
import 'page.dart';
import 'root.dart';

/// A widget that displays a hierarchical tree of layout items
///
/// This widget renders the items in a layout model as an interactive tree view,
/// allowing users to navigate and select different layout components.
/// It integrates with the layout model controller to handle selection state
/// and updates.
class Items extends StatefulWidget {
  /// The root item to display
  final Item _item;

  /// The controller managing the layout model state
  final LayoutModelController controller;

  /// Creates an Items widget
  ///
  /// [_item] The root item to display in the tree
  /// [controller] The layout model controller
  const Items(this._item, this.controller, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ItemsState();
  }
}

class ItemsState extends State<Items> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutModelControllerProvider(
      controller: widget.controller,
      child: ValueListenableBuilder<String?>(
        valueListenable: widget.controller.selectedIdNotifier,
        builder: (BuildContext context, String? selectedId, _) {
          return _buildItem(widget._item, selectedId);
        },
      ),
    );
  }

  Widget _buildItem(Item item, String? selectedId) {
    Widget child;

    if (item.items.isNotEmpty) {
      final List<Widget> children = <Widget>[];
      children.add(ItemWidget(item));
      late final List<Item> items;
      if (item is Root) {
        items = item.items.whereType<ComponentPage>().toList();
      } else {
        items = item.items;
      }

      children
        ..addAll(
          List.generate(
            items.length,
            (int index) => Padding(
              padding: index == items.length - 1
                  ? const EdgeInsets.only(left: 5, right: 5)
                  : const EdgeInsets.only(left: 5, right: 5, bottom: 5),
              child: _buildItem(items[index], selectedId),
            ),
          ),
        )
        ..add(
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(item['name'], softWrap: true))
              ],
            ),
          ),
        );

      child = ListView(shrinkWrap: true, children: children);
    } else {
      child = ItemWidget(item);
    }

    final Type curPageType = switch (widget._item.runtimeType) {
      const (SourcePage) => SourcePage,
      const (StylePage) => StylePage,
      const (ProcessPage) => ProcessPage,
      _ => ComponentPage,
    };

    // final curItem = widget.controller.layoutModel.curItemOnPage[curPageType];

    return InkWell(
      child: DecoratedBox(
        //padding: const EdgeInsets.only(left: 5,  right: 5),
        /*const EdgeInsets.all(5),*/
        decoration: BoxDecoration(
          color: item.id == selectedId
              ? Colors.amber
              : item is ComponentAndSourcePage
                  ? Colors.grey
                  : Colors.white,
          border: Border.all(),
        ),
        child: child,
      ),
      onTap: () {
        if (item.id == selectedId) {
          return;
        }
        if (curPageType is ComponentPage) {
          widget.controller.layoutModel.curComponentItem = item;
        }
        // widget.controller.layoutModel.curItem = item;
        // setState(() {
        //   widget.controller.layoutModel.curItem = item;
        // });
        widget.controller.select(item.id);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ItemWidget extends StatefulWidget {
  final Item item;
  const ItemWidget(this.item, {super.key});

  @override
  State<StatefulWidget> createState() => ItemWidgetState();
}

class ItemWidgetState extends State<ItemWidget> {
  late bool hover;
  bool dragging = false;
  Offset? position;

  late final LayoutModelController controller =
      LayoutModelControllerProvider.of(context);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        setState(() {
          position = event.position;
        });
      },
      child: GestureDetector(
        onTap: () {
          if (widget.item == controller.layoutModel.curItem) {
            return;
          }
          // controller.layoutModel.curItem = widget.item;
          controller.select(widget.item.id);
          // controller.eventBus.emit(SelectionEvent(id: const Uuid().v4(), itemId: widget.item.id));
          setState(() {});
        },
        onSecondaryTap: () {
          final ComponentAndSourceMenu menu =
              ComponentAndSourceMenu.create(controller, widget.item);

          final List<ContextMenuEntry> menuItems = menu.getContextMenu(
            (LayoutModelEvent event) => controller.eventBus.emit(event),
          );
          createAndShowContextMenu(
            context,
            entries: menuItems,
            position: position!,
          );
          if (widget.item == controller.layoutModel.curItem) {
            return;
          }
          // controller.layoutModel.curItem = widget.item;
          controller.select(widget.item.id);
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5, right: 5),
          decoration: BoxDecoration(
            color: dragging ? Colors.green : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.item['name'],
                overflow: TextOverflow.clip,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
