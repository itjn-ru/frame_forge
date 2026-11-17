import 'dart:async';

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
import 'strings.dart';

/// Session-level memory of expanded tree nodes, shared by all [Items] trees.
///
/// Keys are item ids. A missing id means "use the default rule":
/// the tree root (depth 0) is expanded so the first level of items is
/// visible, everything deeper starts collapsed.
///
/// Keeping this outside the widget state is what makes expansion survive
/// page switches and tab changes within one editing session.
final Map<String, bool> _itemExpansionState = <String, bool>{};

/// Height of a single tree row and indentation step per depth level.
const double _kTreeRowHeight = 34.0;
const double _kTreeIndentWidth = 16.0;

/// A collapsible navigation tree of layout items (components, sources,
/// styles).
///
/// Instead of rendering the whole subtree expanded (the previous behavior),
/// [Items] shows a compact expandable list:
/// - every item with children has a toggle chevron (tap to expand/collapse),
/// - by default the first level is visible, deeper levels are collapsed,
/// - expanded nodes are remembered per session, including across page
///   switches,
/// - a search field filters items by name and auto-reveals matching
///   branches,
/// - toolbar buttons expand/collapse the whole tree,
/// - selecting an item on the canvas auto-expands the branch up to it,
///   highlights it and scrolls it into view.
///
/// The right-click context menu and tap-to-select behavior are unchanged.
class Items extends StatefulWidget {
  /// The root item to display
  final Item _item;

  /// The controller managing the layout model state
  final LayoutModelController controller;

  /// Whether to show the search bar above the tree.
  final bool showSearchBar;

  /// Whether to show the expand-all / collapse-all toolbar buttons.
  final bool showToolbar;

  /// Creates an Items widget
  ///
  /// [_item] The root item to display in the tree
  /// [controller] The layout model controller
  const Items(
    this._item,
    this.controller, {
    this.showSearchBar = true,
    this.showToolbar = true,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return ItemsState();
  }
}

class ItemsState extends State<Items> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _query = '';
  StreamSubscription<LayoutModelEvent>? _eventsSubscription;

  /// Rows currently visible, rebuilt on every build.
  List<_TreeRow> _rows = <_TreeRow>[];

  @override
  void initState() {
    super.initState();
    // Rebuild on structural changes (add/delete/rename/load/undo).
    _eventsSubscription = widget.controller.eventBus.events.listen(
      (LayoutModelEvent event) {
        if (event is AddItemEvent ||
            event is RemoveItemEvent ||
            event is AttributeChangeEvent ||
            event is LoadProjectEvent ||
            event is NewProjectEvent ||
            event is UndoPerformed ||
            event is RedoPerformed) {
          if (event is LoadProjectEvent || event is NewProjectEvent) {
            // Fresh model: drop expansion memory of the old items.
            _itemExpansionState.clear();
          }
          if (mounted) setState(() {});
        }
      },
    );
    // Reveal the selected item when it is picked on the canvas.
    widget.controller.selectedIdNotifier.addListener(_revealSelected);
  }

  @override
  void dispose() {
    widget.controller.selectedIdNotifier.removeListener(_revealSelected);
    _eventsSubscription?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Children shown under [item] in the tree.
  ///
  /// Mirrors the legacy behavior: under [Root] only component pages are
  /// listed, under any other item all children are listed.
  List<Item> _childrenOf(Item item) {
    if (item is Root) {
      return item.items.whereType<ComponentPage>().toList();
    }
    return item.items;
  }

  /// Whether the node is expanded, applying the default rule when the user
  /// has not toggled it yet: the tree root starts expanded (so the first
  /// level is visible), deeper nodes start collapsed.
  bool _isExpanded(Item item, int depth) {
    return _itemExpansionState[item.id] ?? depth == 0;
  }

  void _toggleExpanded(Item item, int depth) {
    _itemExpansionState[item.id] = !_isExpanded(item, depth);
    setState(() {});
  }

  /// True when the item name matches the current search query.
  bool _matches(Item item) {
    if (_query.isEmpty) return true;
    return (item['name'] ?? '').toString().toLowerCase().contains(_query);
  }

  /// True when the item or any of its descendants matches the query.
  bool _hasMatchBelow(Item item) {
    if (_matches(item)) return true;
    for (final Item child in _childrenOf(item)) {
      if (_hasMatchBelow(child)) return true;
    }
    return false;
  }

  /// Flattens the visible tree into rows for the list view.
  ///
  /// Without an active query the expansion state decides which branches are
  /// walked. With an active query only matching items and their ancestors
  /// are shown, fully expanded.
  List<_TreeRow> _buildRows() {
    final List<_TreeRow> rows = <_TreeRow>[];
    final bool filtering = _query.isNotEmpty;

    void walk(Item item, int depth) {
      final List<Item> children = _childrenOf(item);
      if (filtering && !_hasMatchBelow(item)) return;
      rows.add(_TreeRow(item, depth, children.isNotEmpty));
      if (children.isEmpty) return;
      if (filtering) {
        for (final Item child in children) {
          walk(child, depth + 1);
        }
      } else if (_isExpanded(item, depth)) {
        for (final Item child in children) {
          walk(child, depth + 1);
        }
      }
    }

    walk(widget._item, 0);
    return rows;
  }

  /// Ids from this tree root down to the item with [id] (inclusive).
  /// Returns an empty list when the item is outside this tree.
  List<String> _ancestorPath(Item branch, String id) {
    if (branch.id == id) return <String>[branch.id];
    for (final Item child in _childrenOf(branch)) {
      final List<String> path = _ancestorPath(child, id);
      if (path.isNotEmpty) return <String>[branch.id, ...path];
    }
    return <String>[];
  }

  /// Expands the branch to the currently selected item and scrolls it into
  /// view. Called on selection changes (canvas, quick switcher, menus).
  void _revealSelected() {
    final String? selectedId = widget.controller.selectedIdNotifier.value;
    if (selectedId == null || !mounted) return;
    final List<String> path = _ancestorPath(widget._item, selectedId);
    if (path.isEmpty) return; // Selection lives in another tree.
    for (final String id in path) {
      _itemExpansionState[id] = true;
    }
    setState(() {});
    _scrollToId(selectedId);
  }

  void _scrollToId(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final int index = _rows.indexWhere((_TreeRow row) => row.item.id == id);
      if (index < 0) return; // Hidden by an active filter.
      final double target = index * _kTreeRowHeight;
      final double max = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        target.clamp(0.0, max),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _expandAll() {
    void walk(Item item) {
      if (_childrenOf(item).isNotEmpty) {
        _itemExpansionState[item.id] = true;
        for (final Item child in _childrenOf(item)) {
          walk(child);
        }
      }
    }

    walk(widget._item);
    setState(() {});
  }

  /// Collapses everything below the first level, restoring the default
  /// look (the tree root stays expanded).
  void _collapseAll() {
    void walk(Item item, int depth) {
      for (final Item child in _childrenOf(item)) {
        if (_childrenOf(child).isNotEmpty) {
          _itemExpansionState[child.id] = false;
        }
        walk(child, depth + 1);
      }
    }

    walk(widget._item, 0);
    setState(() {});
  }

  void _onRowTap(Item item) {
    // Page rows switch the editor to that page, other rows select.
    if (item is ComponentPage) {
      widget.controller.switchPage(item);
    } else {
      widget.controller.select(item.id);
    }
  }

  void _onRowSecondaryTap(Item item, Offset position) {
    final ComponentAndSourceMenu menu =
        ComponentAndSourceMenu.create(widget.controller, item);
    final List<ContextMenuEntry> menuItems = menu.getContextMenu(
      (LayoutModelEvent event) => widget.controller.eventBus.emit(event),
    );
    createAndShowContextMenu(
      context,
      entries: menuItems,
      position: position,
    );
    if (widget.controller.selectedId != item.id) {
      widget.controller.select(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutModelControllerProvider(
      controller: widget.controller,
      child: ValueListenableBuilder<String?>(
        valueListenable: widget.controller.selectedIdNotifier,
        builder: (BuildContext context, String? selectedId, _) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool bounded = constraints.maxHeight.isFinite;
              _rows = _buildRows();
              final bool filtering = _query.isNotEmpty;

              final Widget list = _rows.isEmpty
                  ? Center(
                      child: Text(
                        filtering
                            ? FrameForgeStrings.itemsNoMatch
                            : FrameForgeStrings.itemsEmpty,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: !bounded,
                      itemExtent: _kTreeRowHeight,
                      itemCount: _rows.length,
                      itemBuilder: (BuildContext context, int index) =>
                          _buildRow(_rows[index], selectedId, filtering),
                    );

              return Column(
                mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (widget.showSearchBar || widget.showToolbar)
                    _buildToolbar(filtering),
                  if (bounded) Expanded(child: list) else list,
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildToolbar(bool filtering) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: <Widget>[
          if (widget.showSearchBar)
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (String value) => setState(() {
                  _query = value.toLowerCase().trim();
                }),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: FrameForgeStrings.itemsSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: FrameForgeStrings.itemsSearchClear,
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          if (widget.showToolbar) ...<Widget>[
            IconButton(
              tooltip: FrameForgeStrings.itemsExpandAllTooltip,
              onPressed: _expandAll,
              icon: const Icon(Icons.unfold_more),
              color: colorScheme.onSurfaceVariant,
            ),
            IconButton(
              tooltip: FrameForgeStrings.itemsCollapseAllTooltip,
              onPressed: _collapseAll,
              icon: const Icon(Icons.unfold_less),
              color: colorScheme.onSurfaceVariant,
            ),
          ] else if (widget.showSearchBar && filtering)
            // Without a toolbar the clear button lives in the text field,
            // nothing extra is needed here.
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildRow(_TreeRow row, String? selectedId, bool filtering) {
    final Item item = row.item;
    final bool selected = item.id == selectedId;
    final bool isPage = item is ComponentAndSourcePage;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color background = selected
        ? colorScheme.secondaryContainer
        : isPage && !selected
            ? colorScheme.surfaceContainerHighest
            : Colors.transparent;
    final Color foreground = selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;

    return InkWell(
      onTap: () => _onRowTap(item),
      onSecondaryTapUp: (TapUpDetails details) =>
          _onRowSecondaryTap(item, details.globalPosition),
      child: Container(
        height: _kTreeRowHeight,
        padding: EdgeInsets.only(left: 4 + row.depth * _kTreeIndentWidth),
        decoration: BoxDecoration(
          color: background,
          border: Border(
            bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
          ),
        ),
        child: Row(
          children: <Widget>[
            if (row.hasChildren && !filtering)
              InkWell(
                onTap: () => _toggleExpanded(item, row.depth),
                child: Icon(
                  _isExpanded(item, row.depth)
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              const SizedBox(width: 20),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                (item['name'] ?? '').toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// One flattened row of the collapsible tree.
class _TreeRow {
  final Item item;
  final int depth;
  final bool hasChildren;

  const _TreeRow(this.item, this.depth, this.hasChildren);
}

/// A single tree row widget showing the item name.
///
/// Legacy widget kept for API compatibility: the collapsible [Items] tree
/// renders its own rows, but external code may still embed [ItemWidget].
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
          // Page rows switch the whole editor to that page.
          if (widget.item is ComponentPage) {
            controller.switchPage(widget.item as ComponentPage);
          } else {
            controller.select(widget.item.id);
          }
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
            position: position ?? Offset.zero,
          );
          if (widget.item == controller.layoutModel.curItem) {
            return;
          }
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
