import 'package:uuid/uuid.dart';

import '../../frame_forge.dart';
import 'canvas/context_menu.dart';
import 'package:flutter/material.dart';

/// A widget that displays process items in a hierarchical tree view
///
/// This widget renders process definitions and workflows as an interactive
/// tree structure, allowing users to navigate and manage business logic
/// processes within the layout model.
class ProcessItems extends StatefulWidget {
  /// The root process item to display
  final Item _item;

  /// The controller managing the layout model state
  final LayoutModelController controller;

  /// Creates a ProcessItems widget
  ///
  /// [_item] The root process item to display in the tree
  /// [controller] The layout model controller
  const ProcessItems(this._item, this.controller, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ProcessItemsState();
  }
}

class ProcessItemsState extends State<ProcessItems>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: _buildItem(widget._item, null, constraints.maxWidth),
        );
      },
    );
  }

  Widget _buildItem(Item item, String? processType, double width) {
    Widget child;
    if (item.items.isNotEmpty) {
      final children = <Widget>[];

      final items = item.items;

      children.addAll(
        List.generate(
          items.length,
          (index) => SizedBox(
            //width: (width - 5) / (first ? 1 : items.length),
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
              child: _buildItem(
                items[index],
                item.properties['processType']?.value,
                (width) / (items.length) - 5 * items.length,
              ),
            ),
          ),
        ),
      );
      processType = item.properties['processType']?.value ?? 'последовательно';
      child = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(item['name'], softWrap: true),
          ),
          Flex(
            mainAxisSize: MainAxisSize.min,
            direction: processType != 'параллельно'
                ? Axis.vertical
                : Axis.horizontal,
            children: children,
          ),
        ],
      );
    } else {
      child = ProcessItemWidget(item, widget.controller);
    }

    return ItemWrapper(controller: widget.controller, item: item, child: child);
  }

  @override
  bool get wantKeepAlive => true;
}

class ItemWrapper extends StatefulWidget {
  final Item item;
  final LayoutModelController controller;
  final Widget child;

  const ItemWrapper({
    super.key,
    required this.child,
    required this.controller,
    required this.item,
  });

  @override
  State<ItemWrapper> createState() => _ItemWrapperState();
}

class _ItemWrapperState extends State<ItemWrapper> {
  Offset? position;

  @override
  void initState() {
    widget.controller.eventBus.events.listen(_handleRunnerEvents);
    super.initState();
  }

  void _handleRunnerEvents(LayoutModelEvent event) {
    if (mounted &&
        (event is SelectionEvent ||
            event is PanEnd ||
            event is NewProjectEvent)) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          position = event.position;
        });
      },
      child: GestureDetector(
        onTap: () {
          if (widget.item == widget.controller.layoutModel.curItem) {
            return;
          }
          // widget.controller.layoutModel.curItem = widget.item;
          widget.controller.eventBus.emit(
            SelectionEvent(id: const Uuid().v4(), itemId: widget.item.id),
          );
        },
        onSecondaryTap: () {
          final menu = ComponentAndSourceMenu.create(
            widget.controller,
            widget.item,
          );

          final menuItems = menu.getContextMenu(
            (event) => widget.controller.eventBus.emit(event),
          );
          createAndShowContextMenu(
            context,
            entries: menuItems,
            position: position!,
          );
          if (widget.item == widget.controller.layoutModel.curItem) {
            return;
          }
          // widget.controller.layoutModel.curItem = widget.item;
          widget.controller.eventBus.emit(
            SelectionEvent(id: const Uuid().v4(), itemId: widget.item.id),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              width: widget.item == widget.controller.layoutModel.curItem
                  ? 2.0
                  : 1.0,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class ProcessItemWidget extends StatelessWidget {
  final Item _item;
  final LayoutModelController controller;

  const ProcessItemWidget(this._item, this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(_item['name'], textAlign: TextAlign.center, softWrap: true),
    );
  }
}
