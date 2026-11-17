import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../canvas/context_menu.dart';
import '../canvas/layout_model_provider.dart';
import '../flutter_context_menu/flutter_context_menu.dart';
import 'controller/events.dart';
import 'controller/layout_model_controller.dart';
import 'item.dart';
import 'menu.dart';
import 'page.dart';
import 'page_quick_switcher.dart';
import 'strings.dart';

/// Session-level memory of expanded nodes of [PageList] trees.
///
/// Keys are item ids (component pages and their nested items). A missing id
/// means "collapsed": every page starts collapsed, so the widget opens as a
/// compact list of pages.
///
/// Keeping this outside the widget state makes expansion survive page
/// switches and tab changes within one editing session.
final Map<String, bool> _pageTreeExpansionState = <String, bool>{};

/// Height of a single tree row and indentation step per depth level.
const double _kTreeRowHeight = 34.0;
const double _kTreeIndentWidth = 16.0;

/// Unified expandable tree of component pages and their items.
///
/// Instead of the master-detail pair (a pages-only list plus an [Items]
/// tree of the current page), [PageList] renders everything in one widget:
/// - the top level lists the component pages, every page starts collapsed;
/// - tapping a page chevron reveals its component tree (nested groups
///   expand the same way);
/// - tapping a page row makes it current; tapping a component row selects
///   it — when the component lives on another page, the editor first
///   switches to that page;
/// - search filters pages and items by name and auto-reveals matching
///   branches;
/// - toolbar buttons expand/collapse the whole tree;
/// - selecting an item on the canvas expands the branch up to it, marks
///   the row and scrolls it into view;
/// - page rows keep double-tap rename and the right-click page menu
///   (rename / duplicate / delete), component rows keep the standard
///   component context menu;
/// - expanded nodes are remembered per session, including across page
///   switches and tab changes.
class PageList extends StatefulWidget {
  /// The controller managing the layout model state.
  final LayoutModelController controller;

  /// Whether to show the search bar at the top of the tree.
  final bool showSearchBar;

  /// Whether to show the expand-all / collapse-all toolbar buttons.
  final bool showToolbar;

  /// Whether to show the quick switcher button (Ctrl+K) at the top of the tree.
  final bool showQuickSwitcher;

  /// Creates a page list bound to [controller].
  const PageList(
    this.controller, {
    this.showSearchBar = true,
    this.showToolbar = true,
    this.showQuickSwitcher = true,
    super.key,
  });

  @override
  State<PageList> createState() => _PageListState();
}

class _PageListState extends State<PageList> {
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
            _pageTreeExpansionState.clear();
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

  /// Whether the node is expanded. Default rule: everything starts
  /// collapsed, so the widget opens as a plain list of pages.
  bool _isExpanded(Item item) => _pageTreeExpansionState[item.id] ?? false;

  void _toggleExpanded(Item item) {
    _pageTreeExpansionState[item.id] = !_isExpanded(item);
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
    for (final Item child in item.items) {
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
      if (filtering && !_hasMatchBelow(item)) return;
      rows.add(_TreeRow(item, depth, item.items.isNotEmpty));
      if (item.items.isEmpty) return;
      if (filtering || _isExpanded(item)) {
        for (final Item child in item.items) {
          walk(child, depth + 1);
        }
      }
    }

    for (final ComponentPage page
        in widget.controller.layoutModel.componentPages) {
      if (filtering && !_hasMatchBelow(page)) continue;
      rows.add(_TreeRow(page, 0, page.items.isNotEmpty, isPage: true));
      if (page.items.isEmpty) continue;
      if (filtering || _isExpanded(page)) {
        for (final Item child in page.items) {
          walk(child, 1);
        }
      }
    }
    return rows;
  }

  /// The component page owning the item with [id] (the page itself when
  /// the id belongs to the page). Returns null when the item lives outside
  /// the component pages (e.g. on the data or styles page).
  ComponentPage? _findPageOfId(String id) {
    bool contains(Item branch) {
      for (final Item child in branch.items) {
        if (child.id == id || contains(child)) return true;
      }
      return false;
    }

    for (final ComponentPage page
        in widget.controller.layoutModel.componentPages) {
      if (page.id == id || contains(page)) return page;
    }
    return null;
  }

  /// Ids from [branch] down to the item with [id] (inclusive).
  /// Returns an empty list when the item is outside this branch.
  List<String> _ancestorPath(Item branch, String id) {
    if (branch.id == id) return <String>[branch.id];
    for (final Item child in branch.items) {
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
    final ComponentPage? owner = _findPageOfId(selectedId);
    if (owner == null) return; // Selection lives outside component pages.
    final List<String> path = _ancestorPath(owner, selectedId);
    if (path.isEmpty) return;
    for (final String id in path) {
      _pageTreeExpansionState[id] = true;
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
      if (item.items.isEmpty) return;
      _pageTreeExpansionState[item.id] = true;
      for (final Item child in item.items) {
        walk(child);
      }
    }

    for (final ComponentPage page
        in widget.controller.layoutModel.componentPages) {
      walk(page);
    }
    setState(() {});
  }

  /// Collapses everything: only the page rows remain visible, matching the
  /// default look of the widget.
  void _collapseAll() {
    void walk(Item item) {
      if (item.items.isEmpty) return;
      _pageTreeExpansionState[item.id] = false;
      for (final Item child in item.items) {
        walk(child);
      }
    }

    for (final ComponentPage page
        in widget.controller.layoutModel.componentPages) {
      walk(page);
    }
    setState(() {});
  }

  void _onRowTap(Item item) {
    // Page rows switch the editor to that page.
    if (item is ComponentPage) {
      widget.controller.switchPage(item);
      return;
    }
    // A component may live on a page other than the current one:
    // make its page current first, then select the component.
    final ComponentPage? owner = _findPageOfId(item.id);
    if (owner != null && owner != widget.controller.currentComponentPage) {
      widget.controller.switchPage(owner);
    }
    widget.controller.select(item.id);
  }

  void _onRowSecondaryTap(_TreeRow row, Offset position) {
    if (row.isPage) {
      _showPageMenu(row.item as ComponentPage, position);
      return;
    }
    final ComponentAndSourceMenu menu =
        ComponentAndSourceMenu.create(widget.controller, row.item);
    final List<ContextMenuEntry> menuItems = menu.getContextMenu(
      (LayoutModelEvent event) => widget.controller.eventBus.emit(event),
    );
    createAndShowContextMenu(
      context,
      entries: menuItems,
      position: position,
    );
    if (widget.controller.selectedId != row.item.id) {
      widget.controller.select(row.item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutModelControllerProvider(
      controller: widget.controller,
      child: ValueListenableBuilder<String?>(
        valueListenable: widget.controller.selectedIdNotifier,
        builder: (BuildContext context, String? selectedId, _) {
          _rows = _buildRows();
          final bool filtering = _query.isNotEmpty;

          final Widget list = _rows.isEmpty
              ? Center(
                  child: Text(_query.isEmpty
                      ? FrameForgeStrings.noPages
                      : FrameForgeStrings.noPagesFound),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemExtent: _kTreeRowHeight,
                  itemCount: _rows.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _buildRow(_rows[index], selectedId, filtering),
                );

          return Column(
            children: <Widget>[
              if (widget.showSearchBar || widget.showToolbar) _buildToolbar(),
              Expanded(child: list),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToolbar() {
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
                  hintText: FrameForgeStrings.pageSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: FrameForgeStrings.pageSearchClear,
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
          ],
          IconButton(
            tooltip: FrameForgeStrings.newPageTooltip,
            onPressed: () => widget.controller.addPage(),
            icon: const Icon(Icons.add),
          ),
          if (widget.showQuickSwitcher)
            IconButton(
              tooltip: FrameForgeStrings.quickSwitcherTooltip,
              onPressed: () =>
                  showPageQuickSwitcher(context, widget.controller),
              icon: const Icon(Icons.bolt),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(_TreeRow row, String? selectedId, bool filtering) {
    final Item item = row.item;
    final bool isPage = row.isPage;
    final bool selected = item.id == selectedId;
    final bool isCurrent =
        isPage && item == widget.controller.currentComponentPage;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color background = selected || isCurrent
        ? colorScheme.secondaryContainer
        : Colors.transparent;
    final Color foreground = selected || isCurrent
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;

    return InkWell(
      onTap: () => _onRowTap(item),
      onDoubleTap:
          isPage ? () => _showRenameDialog(item as ComponentPage) : null,
      onSecondaryTapUp: (TapUpDetails details) =>
          _onRowSecondaryTap(row, details.globalPosition),
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
                onTap: () => _toggleExpanded(item),
                child: Icon(
                  _isExpanded(item)
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
            if (isPage)
              Text(
                item.items.length.toString(),
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  void _showPageMenu(ComponentPage page, Offset position) {
    createAndShowContextMenu(
      context,
      entries: <ContextMenuEntry>[
        MenuHeader(
          text: (page['name'] ?? '').toString(),
          disableUppercase: true,
        ),
        MenuItem<void>(
          label: FrameForgeStrings.pageMenuRename,
          icon: Icons.edit,
          onSelected: () => _showRenameDialog(page),
        ),
        MenuItem<void>(
          label: FrameForgeStrings.pageMenuDuplicate,
          icon: Icons.copy,
          onSelected: () => widget.controller.duplicatePage(page),
        ),
        const MenuDivider(),
        MenuItem<void>(
          label: FrameForgeStrings.pageMenuDelete,
          icon: Icons.delete,
          onSelected: () => widget.controller.deletePage(page),
        ),
      ],
      position: position,
    );
  }

  Future<void> _showRenameDialog(ComponentPage page) async {
    final TextEditingController nameController = TextEditingController(
      text: (page['name'] ?? '').toString(),
    );
    // Pushed as a route (instead of showDialog) to get [Route.completed]:
    // the dialog keeps rendering its TextField during the exit transition,
    // so the controller may only be released once that transition finished.
    final DialogRoute<String> route = DialogRoute<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(FrameForgeStrings.renameDialogTitle),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: FrameForgeStrings.renameDialogLabel,
            ),
            onSubmitted: (String value) =>
                Navigator.of(dialogContext).pop(value),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(FrameForgeStrings.renameDialogCancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(nameController.text),
              child: Text(FrameForgeStrings.renameDialogSave),
            ),
          ],
        );
      },
    );
    unawaited(Navigator.of(context).push(route));
    final String? newName = await route.popped;
    unawaited(route.completed.whenComplete(nameController.dispose));
    if (newName != null && newName.trim().isNotEmpty) {
      widget.controller.renamePage(page, newName);
    }
  }
}

/// One flattened row of the page/component tree.
class _TreeRow {
  final Item item;
  final int depth;
  final bool hasChildren;
  final bool isPage;

  const _TreeRow(this.item, this.depth, this.hasChildren,
      {this.isPage = false});
}
