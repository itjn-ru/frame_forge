import 'dart:async';

import 'package:flutter/material.dart';

import '../canvas/context_menu.dart';
import '../flutter_context_menu/flutter_context_menu.dart';
import 'controller/events.dart';
import 'controller/layout_model_controller.dart';
import 'page.dart';
import 'page_quick_switcher.dart';
import 'strings.dart';

/// Master list of component pages for the master-detail navigation pattern.
///
/// Designed for layouts with many pages (dozens and more):
/// - virtualized list of pages only (no nested component tree),
/// - instant search by name,
/// - current page highlighted with theme colors,
/// - context menu with rename / duplicate / delete,
/// - double-tap to rename, toolbar button to add a page,
/// - quick switcher button (Ctrl+K).
///
/// Pair it with a detail tree of the current page:
/// ```dart
/// Column(children: [
///   Flexible(flex: 3, child: PageList(controller)),
///   Flexible(flex: 4, child: Items(controller.currentComponentPage, controller)),
/// ])
/// ```
class PageList extends StatefulWidget {
  /// The controller managing the layout model state.
  final LayoutModelController controller;

  /// Whether to show the search bar at the top of the page list.
  final bool showSearchBar;

  /// Whether to show the quick switcher button (Ctrl+K) at the top of the page list.
  final bool showQuickSwitcher;

  /// Creates a page list bound to [controller].
  const PageList(this.controller,
      {this.showSearchBar = true, this.showQuickSwitcher = true, super.key});

  @override
  State<PageList> createState() => _PageListState();
}

class _PageListState extends State<PageList> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  StreamSubscription<LayoutModelEvent>? _eventsSubscription;

  @override
  void initState() {
    super.initState();
    // Rebuild on structural changes (add/delete/rename/load).
    _eventsSubscription = widget.controller.eventBus.events.listen(
      (LayoutModelEvent event) {
        if (event is AddItemEvent ||
            event is RemoveItemEvent ||
            event is AttributeChangeEvent ||
            event is LoadProjectEvent ||
            event is NewProjectEvent) {
          if (mounted) setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.controller.selectedIdNotifier,
      builder: (BuildContext context, String? selectedId, _) {
        final List<ComponentPage> pages =
            widget.controller.layoutModel.componentPages;
        final ComponentPage currentPage =
            widget.controller.currentComponentPage;
        final List<ComponentPage> filtered = _query.isEmpty
            ? pages
            : pages
                .where((ComponentPage page) => (page['name'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(_query))
                .toList();

        return Column(
          children: <Widget>[
            if (widget.showSearchBar)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: <Widget>[
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
              ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(_query.isEmpty
                          ? FrameForgeStrings.noPages
                          : FrameForgeStrings.noPagesFound),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ComponentPage page = filtered[index];
                        return _PageTile(
                          key: ValueKey<String>(page.id),
                          page: page,
                          isCurrent: page == currentPage,
                          componentCount: page.items.length,
                          onTap: () => widget.controller.switchPage(page),
                          onRename: () => _showRenameDialog(page),
                          onSecondaryTap: (Offset position) =>
                              _showPageMenu(page, position),
                        );
                      },
                    ),
            ),
          ],
        );
      },
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
    final String? newName = await showDialog<String>(
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
    nameController.dispose();
    if (newName != null && newName.trim().isNotEmpty) {
      widget.controller.renamePage(page, newName);
    }
  }
}

class _PageTile extends StatelessWidget {
  final ComponentPage page;
  final bool isCurrent;
  final int componentCount;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final ValueChanged<Offset> onSecondaryTap;

  const _PageTile({
    super.key,
    required this.page,
    required this.isCurrent,
    required this.componentCount,
    required this.onTap,
    required this.onRename,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String name = (page['name'] ?? '').toString();

    return GestureDetector(
      onDoubleTap: onRename,
      onSecondaryTapUp: (TapUpDetails details) =>
          onSecondaryTap(details.globalPosition),
      child: ListTile(
        dense: true,
        selected: isCurrent,
        selectedTileColor: colorScheme.secondaryContainer,
        selectedColor: colorScheme.onSecondaryContainer,
        // leading: Icon(
        //   isCurrent ? Icons.web : Icons.crop_din,
        //   color: isCurrent ? colorScheme.primary : colorScheme.onSurfaceVariant,
        // ),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: isCurrent
            ? Text(
                FrameForgeStrings.currentPageBadge,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: colorScheme.onSecondaryContainer),
              )
            : null,
        trailing: Text(
          componentCount.toString(),
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        onTap: onTap,
      ),
    );
  }
}
