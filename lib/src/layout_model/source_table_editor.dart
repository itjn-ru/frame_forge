import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import 'controller/events.dart';
import 'controller/layout_model_controller.dart';
import 'item.dart';
import 'page.dart';
import 'property.dart';
import 'source_variable.dart';
import 'source_variable_group.dart';
import 'strings.dart';
import '../ui_kit/property_text_field.dart';

/// Opens the fullscreen spreadsheet-style editor for the [SourcePage].
///
/// The Data tab tree stays untouched; the table is opened on top of the
/// whole window so long variable names get all the space they need:
/// inline cell editing (name, type, nullable, possible values), collapsible
/// group sections, search and type filter, add/delete with undo, and
/// Excel-style TSV copy/paste.
Future<void> showSourceTableEditor(
  BuildContext context,
  LayoutModelController controller,
) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (BuildContext context) => SourceTableEditor(controller: controller),
  );
}

/// Column widths of the table, computed from the available viewport width.
class _Columns {
  final double checkbox;
  final double name;
  final double type;
  final double nullable;
  final double possibleValues;
  final double actions;

  const _Columns({
    required this.checkbox,
    required this.name,
    required this.type,
    required this.nullable,
    required this.possibleValues,
    required this.actions,
  });

  factory _Columns.forWidth(double width) {
    const double checkboxW = 44;
    const double typeW = 120;
    const double nullableW = 90;
    const double actionsW = 56;
    final double free =
        math.max(0, width - (checkboxW + typeW + nullableW + actionsW));
    return _Columns(
      checkbox: checkboxW,
      name: math.max(240, free * 0.55),
      type: typeW,
      nullable: nullableW,
      possibleValues: math.max(200, free * 0.45),
      actions: actionsW,
    );
  }

  double get total =>
      checkbox + name + type + nullable + possibleValues + actions;
}

/// One flattened row of the source table: either a group section header or
/// a variable row.
class _Row {
  final SourceVariableGroup? group;
  final SourceVariable? variable;
  final int depth;
  final int count;

  const _Row._(this.group, this.variable, this.depth, this.count);

  factory _Row.section(SourceVariableGroup? group, int depth, int count) =>
      _Row._(group, null, depth, count);

  factory _Row.variable(SourceVariable variable, int depth) =>
      _Row._(null, variable, depth, 0);

  bool get isSection => variable == null;

  String get key => isSection
      ? 'section:${group?.id ?? ''}'
      : 'variable:${variable!.id}';
}

/// Fullscreen Excel-like editor for the variables of the [SourcePage].
///
/// Edits go straight into the layout model (the same properties the
/// properties panel edits), so the tree, the canvas and undo/redo stay in
/// sync. Structural changes (add/delete) reuse the controller's undoable
/// insert/delete helpers; renaming a variable also updates all component
/// source references pointing at the old name.
class SourceTableEditor extends StatefulWidget {
  /// The layout model controller.
  final LayoutModelController controller;

  /// Creates the source page table editor.
  const SourceTableEditor({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => _SourceTableEditorState();
}

class _SourceTableEditorState extends State<SourceTableEditor> {
  static const String _rootSectionKey = '';

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _typeFilter = '';

  /// Ids of collapsed group sections; the root section uses the empty id.
  final Set<String> _collapsed = <String>{};

  /// Ids of variables checked for mass deletion.
  final Set<String> _selectedIds = <String>{};

  /// Variable name captured when its cell gains focus. [onChanged] writes
  /// into the property on every keystroke, so the original name must be
  /// remembered before typing starts to keep renames reference-safe.
  final Map<String, String> _editingNames = <String, String>{};

  StreamSubscription<LayoutModelEvent>? _eventsSubscription;

  SourcePage get _sourcePage => widget
      .controller.layoutModel.root.items.whereType<SourcePage>().first;

  @override
  void initState() {
    super.initState();
    // Keep the table in sync with undo/redo, external edits and reloads.
    _eventsSubscription = widget.controller.eventBus.events.listen(
      (LayoutModelEvent event) {
        if (event is AddItemEvent ||
            event is RemoveItemEvent ||
            event is AttributeChangeEvent ||
            event is LoadProjectEvent ||
            event is NewProjectEvent ||
            event is UndoPerformed ||
            event is RedoPerformed) {
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

  // --- Filtering ---------------------------------------------------------

  bool _matches(SourceVariable variable) {
    if (_typeFilter.isNotEmpty &&
        (variable.properties['type']?.value?.toString() ?? '') !=
            _typeFilter) {
      return false;
    }
    if (_query.isEmpty) return true;
    final String name = variable.properties['name']?.value?.toString() ?? '';
    return name.toLowerCase().contains(_query);
  }

  /// Whether the group subtree contains any visible variable.
  bool _hasVisibleBelow(SourceVariableGroup group) {
    for (final Item item in group.items) {
      if (item is SourceVariable && _matches(item)) return true;
      if (item is SourceVariableGroup && _hasVisibleBelow(item)) return true;
    }
    return false;
  }

  List<_Row> _buildRows() {
    final SourcePage page = _sourcePage;
    final List<_Row> rows = <_Row>[];
    final bool filtering = _query.isNotEmpty || _typeFilter.isNotEmpty;

    final List<SourceVariable> rootVars = page.items
        .whereType<SourceVariable>()
        .where(_matches)
        .toList();

    if (!filtering || rootVars.isNotEmpty) {
      rows.add(_Row.section(null, 0, rootVars.length));
      if (!_collapsed.contains(_rootSectionKey)) {
        for (final SourceVariable variable in rootVars) {
          rows.add(_Row.variable(variable, 0));
        }
      }
    }

    void walk(SourceVariableGroup group, int depth) {
      if (filtering && !_hasVisibleBelow(group)) return;
      final int visibleCount = group.items
          .whereType<SourceVariable>()
          .where(_matches)
          .length;
      rows.add(_Row.section(group, depth, visibleCount));
      if (_collapsed.contains(group.id)) return;
      for (final Item item in group.items) {
        if (item is SourceVariable && _matches(item)) {
          rows.add(_Row.variable(item, depth + 1));
        } else if (item is SourceVariableGroup) {
          walk(item, depth + 1);
        }
      }
    }

    for (final SourceVariableGroup group
        in page.items.whereType<SourceVariableGroup>()) {
      walk(group, 0);
    }

    return rows;
  }

  // --- Model helpers -----------------------------------------------------

  void _emitChange(String? itemId) {
    widget.controller.eventBus.emit(
      AttributeChangeEvent(
        id: const Uuid().v4(),
        itemId: itemId ?? widget.controller.selectedId,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// All variables of the source page, including those inside groups.
  Iterable<SourceVariable> _allVariables() =>
      _variablesIn(_sourcePage.items);

  Iterable<SourceVariable> _variablesIn(List<Item> items) sync* {
    for (final Item item in items) {
      if (item is SourceVariable) yield item;
      if (item is SourceVariableGroup) {
        yield* _variablesIn(item.items);
      }
    }
  }

  bool _hasGroups() {
    bool walk(List<Item> items) {
      for (final Item item in items) {
        if (item is SourceVariableGroup) return true;
        if (item is SourceVariable && walk(item.items)) return true;
      }
      return false;
    }

    return walk(_sourcePage.items);
  }

  bool _nameExists(String name, {SourceVariable? excluding}) {
    return _allVariables().any(
      (SourceVariable v) =>
          !identical(v, excluding) &&
          (v.properties['name']?.value?.toString() ?? '') == name,
    );
  }

  /// Name of the parent variable when [variable] is a child (map key) of a
  /// Map variable, otherwise null.
  String? _parentMapName(SourceVariable variable) {
    final Item? parent = widget.controller.layoutModel.findParentById(
      widget.controller.layoutModel.root,
      variable.id,
    );
    if (parent is SourceVariable &&
        (parent.properties['type']?.value?.toString() ?? '') == 'Map') {
      return parent.properties['name']?.value?.toString();
    }
    return null;
  }

  String _uniqueName(List<Item> siblings, String base) {
    final Set<String> used = siblings
        .whereType<SourceVariable>()
        .map((SourceVariable v) => v.properties['name']?.value?.toString() ?? '')
        .toSet();
    if (!used.contains(base)) return base;
    for (int i = 2;; i++) {
      final String candidate = '$base $i';
      if (!used.contains(candidate)) return candidate;
    }
  }

  // --- Row actions -------------------------------------------------------

  void _addVariable(Item parent) {
    final SourceVariable variable =
        SourceVariable(_uniqueName(parent.items, 'variable'));
    widget.controller.insertItemUndoable(parent, variable);
  }

  void _addGroup() {
    final SourceVariableGroup group =
        SourceVariableGroup(_uniqueName(_sourcePage.items, 'group'));
    widget.controller.insertItemUndoable(_sourcePage, group);
  }

  void _deleteItem(Item item) {
    widget.controller.deleteItemUndoable(item);
  }

  /// Expands or collapses a group section. Public because the row widgets
  /// live outside the state class and must not call [setState] directly.
  void toggleSectionCollapsed(String sectionKey) {
    setState(() {
      if (_collapsed.contains(sectionKey)) {
        _collapsed.remove(sectionKey);
      } else {
        _collapsed.add(sectionKey);
      }
    });
  }

  // --- Mass selection ----------------------------------------------------

  void _toggleSelected(SourceVariable variable) {
    setState(() {
      if (_selectedIds.remove(variable.id)) return;
      _selectedIds.add(variable.id);
    });
  }

  /// Selects or deselects every currently visible variable row.
  void _selectAllVisible(List<_Row> rows, {required bool select}) {
    setState(() {
      for (final _Row row in rows) {
        if (row.isSection) continue;
        if (select) {
          _selectedIds.add(row.variable!.id);
        } else {
          _selectedIds.remove(row.variable!.id);
        }
      }
    });
  }

  /// Whether every visible variable row is selected.
  bool _allVisibleSelected(List<_Row> rows) {
    final List<SourceVariable> visible = rows
        .where((_Row row) => !row.isSection)
        .map((_Row row) => row.variable!)
        .toList();
    if (visible.isEmpty) return false;
    return visible.every(
      (SourceVariable v) => _selectedIds.contains(v.id),
    );
  }

  /// Deletes every checked variable after a confirmation dialog; the whole
  /// batch is a single undo step.
  Future<void> _deleteSelected(List<_Row> rows) async {
    final List<SourceVariable> selected = rows
        .where((_Row row) => !row.isSection)
        .map((_Row row) => row.variable!)
        .where((SourceVariable v) => _selectedIds.contains(v.id))
        .toList();
    if (selected.isEmpty) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          FrameForgeStrings.sourceTableDeleteSelectedTitle(selected.length),
        ),
        content: Text(FrameForgeStrings.sourceTableDeleteSelectedBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(FrameForgeStrings.sourceTableConfirmCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(FrameForgeStrings.sourceTableConfirmDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    widget.controller.deleteItemsUndoable(selected);
    setState(() {
      for (final SourceVariable variable in selected) {
        _selectedIds.remove(variable.id);
      }
    });
    _showSnackBar(
      FrameForgeStrings.sourceTableDeletedBatch(selected.length),
    );
  }

  /// Fills empty sourceV2 bindings of all components from their legacy
  /// source texts (word matching) and reports the result.
  void _autoFillBindings() {
    final List<String> updatedIds =
        widget.controller.layoutModel.autoFillSourceReferences();
    for (final String itemId in updatedIds) {
      _emitChange(itemId);
    }
    _showSnackBar(
      updatedIds.isEmpty
          ? FrameForgeStrings.sourceTableAutoFillEmpty
          : FrameForgeStrings.sourceTableAutoFillResult(updatedIds.length),
    );
  }

  void _onNameFocusGained(SourceVariable variable) {
    _editingNames[variable.id] =
        variable.properties['name']?.value?.toString() ?? '';
  }

  void _commitName(SourceVariable variable) {
    final String oldName = _editingNames.remove(variable.id) ??
        variable.properties['name']?.value?.toString() ??
        '';
    final String newName =
        (variable.properties['name']?.value?.toString() ?? '').trim();
    if (newName.isEmpty || newName == oldName) {
      if (newName.isEmpty) {
        variable.properties['name']?.value = oldName;
      }
      _emitChange(variable.id);
      return;
    }
    if (_nameExists(newName, excluding: variable)) {
      variable.properties['name']?.value = oldName;
      _showSnackBar(FrameForgeStrings.sourceTableDuplicateName);
      setState(() {});
      return;
    }
    variable.properties['name']?.value = newName;
    // Keep component bindings pointing at the renamed variable.
    widget.controller.layoutModel.renameSourceVariable(
      oldName,
      newName,
      parentName: _parentMapName(variable),
    );
    _emitChange(variable.id);
  }

  // --- Clipboard ---------------------------------------------------------

  String _sanitize(String value) =>
      value.replaceAll('\t', ' ').replaceAll('\n', ' ');

  Future<void> _copyVisible(List<_Row> rows) async {
    final List<SourceVariable> variables = rows
        .where((_Row row) => !row.isSection)
        .map((_Row row) => row.variable!)
        .toList();
    if (variables.isEmpty) return;
    final String tsv = variables.map((SourceVariable v) {
      final String type = v.properties['type']?.value?.toString() ?? '';
      final bool nullable = v.properties['nullable']?.value != false;
      final String possible =
          v.properties['possibleValues']?.value?.toString() ?? '';
      return <String>[
        _sanitize(v.properties['name']?.value?.toString() ?? ''),
        _sanitize(type),
        nullable ? 'true' : 'false',
        _sanitize(possible),
      ].join('\t');
    }).join('\n');
    await Clipboard.setData(ClipboardData(text: tsv));
    if (mounted) {
      _showSnackBar(FrameForgeStrings.sourceTableCopied(variables.length));
    }
  }

  Future<void> _pasteRows() async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    final String text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      _showSnackBar(FrameForgeStrings.sourceTablePasteEmpty);
      return;
    }
    final List<String> lines = text
        .split('\n')
        .map((String line) => line.trimRight())
        .where((String line) => line.isNotEmpty)
        .toList();
    // Skip a header row copied from a spreadsheet.
    if (lines.isNotEmpty &&
        lines.first.split('\t').first.trim().toLowerCase() == 'name') {
      lines.removeAt(0);
    }

    int added = 0;
    int skipped = 0;
    for (final String line in lines) {
      final List<String> cols = line.split('\t');
      final String name = cols.isNotEmpty ? cols.first.trim() : '';
      if (name.isEmpty || _nameExists(name)) {
        skipped++;
        continue;
      }
      final SourceVariable variable = SourceVariable(name);
      final String type =
          cols.length > 1 && sourceVariableTypes.contains(cols[1].trim())
              ? cols[1].trim()
              : 'String';
      variable.properties['type']?.value = SourceVariableType(type);
      variable.properties['nullable']?.value =
          cols.length > 2 ? cols[2].trim().toLowerCase() != 'false' : true;
      if (cols.length > 3) {
        variable.properties['possibleValues']?.value = cols[3].trim();
      }
      widget.controller.insertItemUndoable(_sourcePage, variable);
      added++;
    }
    if (mounted) {
      _showSnackBar(
        added == 0 && skipped == 0
            ? FrameForgeStrings.sourceTablePasteEmpty
            : FrameForgeStrings.sourceTablePasteResult(added, skipped),
      );
    }
  }

  // --- Build -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final SourcePage page = _sourcePage;
    final String pageName = page.properties['name']?.value?.toString() ?? '';
    final List<_Row> rows = _buildRows();
    final int totalVariables = _allVariables().length;
    final bool treeEmpty = totalVariables == 0 && !_hasGroups();

    return Dialog.fullscreen(
      child: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.of(context).pop(),
        },
        child: Focus(
          autofocus: true,
          child: ScaffoldMessenger(
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  '${FrameForgeStrings.sourceTableTitle}'
                  '${pageName.isEmpty ? '' : ' · $pageName'}',
                ),
                actions: <Widget>[
                  IconButton(
                    tooltip: FrameForgeStrings.sourceTableCloseTooltip,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              body: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final _Columns columns = _Columns.forWidth(
                    constraints.maxWidth,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildToolbar(colorScheme, rows, totalVariables),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: columns.total,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                _buildHeader(rows, columns, colorScheme),
                                Expanded(
                                  child: rows.isEmpty || treeEmpty
                                      ? _buildEmptyState(
                                          colorScheme,
                                          filtering || treeEmpty,
                                        )
                                      : ListView.builder(
                                          itemCount: rows.length,
                                          itemBuilder: (
                                            BuildContext context,
                                            int index,
                                          ) {
                                            final _Row row = rows[index];
                                            return row.isSection
                                                ? _SectionRow(
                                                    key: ValueKey<String>(
                                                      row.key,
                                                    ),
                                                    row: row,
                                                    state: this,
                                                  )
                                                : _VariableRow(
                                                    key: ValueKey<String>(
                                                      row.key,
                                                    ),
                                                    row: row,
                                                    state: this,
                                                    columns: columns,
                                                    shaded: index.isOdd,
                                                  );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get filtering => _query.isNotEmpty || _typeFilter.isNotEmpty;

  Widget _buildToolbar(
    ColorScheme colorScheme,
    List<_Row> rows,
    int totalVariables,
  ) {
    final int visibleVariables =
        rows.where((_Row row) => !row.isSection).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              key: const ValueKey<String>('sourceTableSearch'),
              controller: _searchController,
              onChanged: (String value) => setState(() {
                _query = value.toLowerCase().trim();
              }),
              decoration: InputDecoration(
                isDense: true,
                hintText: FrameForgeStrings.sourceTableSearchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: FrameForgeStrings.itemsSearchClear,
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: FrameForgeStrings.sourceTableTypeFilterTooltip,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _typeFilter,
                  isDense: true,
                  items: <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text(
                        FrameForgeStrings.sourceTableTypeAll,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ...sourceVariableTypes.map(
                      (String type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (String? value) =>
                      setState(() => _typeFilter = value ?? ''),
                  icon: const Icon(Icons.arrow_drop_down, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            filtering
                ? '$visibleVariables / $totalVariables'
                : FrameForgeStrings.sourceTableVariableCount(totalVariables),
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: FrameForgeStrings.sourceTableExpandAllTooltip,
            icon: const Icon(Icons.unfold_more),
            color: colorScheme.onSurfaceVariant,
            onPressed: () => setState(_collapsed.clear),
          ),
          IconButton(
            tooltip: FrameForgeStrings.sourceTableCollapseAllTooltip,
            icon: const Icon(Icons.unfold_less),
            color: colorScheme.onSurfaceVariant,
            onPressed: () => setState(() {
              _collapsed
                ..clear()
                ..add(_rootSectionKey);
              void walk(List<Item> items) {
                for (final Item item in items) {
                  if (item is SourceVariableGroup) {
                    _collapsed.add(item.id);
                    walk(item.items);
                  }
                }
              }

              walk(_sourcePage.items);
            }),
          ),
          IconButton(
            tooltip: FrameForgeStrings.sourceTableCopyTooltip,
            icon: const Icon(Icons.copy),
            color: colorScheme.onSurfaceVariant,
            onPressed: () => _copyVisible(rows),
          ),
          IconButton(
            tooltip: FrameForgeStrings.sourceTablePasteTooltip,
            icon: const Icon(Icons.paste),
            color: colorScheme.onSurfaceVariant,
            onPressed: _pasteRows,
          ),
          IconButton(
            tooltip: FrameForgeStrings.sourceTableAutoFillTooltip,
            icon: const Icon(Icons.auto_fix_high),
            color: colorScheme.onSurfaceVariant,
            onPressed: _autoFillBindings,
          ),
          IconButton(
            tooltip: _selectedIds.isEmpty
                ? FrameForgeStrings.sourceTableDeleteSelectedTooltip
                : FrameForgeStrings.sourceTableDeleteSelected(
                    _selectedIds.length),
            icon: const Icon(Icons.delete_sweep),
            color: _selectedIds.isEmpty
                ? colorScheme.onSurfaceVariant
                : colorScheme.error,
            onPressed: _selectedIds.isEmpty
                ? null
                : () => _deleteSelected(rows),
          ),
          if (_selectedIds.isNotEmpty)
            Text(
              '${_selectedIds.length}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
            ),
          IconButton(
            tooltip: FrameForgeStrings.sourceTableAddVariableTooltip,
            icon: const Icon(Icons.add),
            color: colorScheme.onSurfaceVariant,
            onPressed: () => _addVariable(_sourcePage),
          ),
          IconButton(
            tooltip: FrameForgeStrings.sourceTableAddGroupTooltip,
            icon: const Icon(Icons.create_new_folder_outlined),
            color: colorScheme.onSurfaceVariant,
            onPressed: _addGroup,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    List<_Row> rows,
    _Columns columns,
    ColorScheme colorScheme,
  ) {
    final Color background = colorScheme.surfaceContainerHigh;
    BorderSide grid() => BorderSide(
          color: colorScheme.outlineVariant,
          width: 0.5,
        );

    Widget cell(double width, String label, {bool center = false}) {
      return Container(
        width: width,
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: center ? Alignment.center : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: background,
          border: Border(right: grid()),
        ),
        child: Text(
          center ? label : label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outline)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: columns.checkbox,
            height: 42,
            decoration: BoxDecoration(
              color: background,
              border: Border(right: grid()),
            ),
            child: Checkbox(
              key: const ValueKey<String>('sourceTableSelectAll'),
              tristate: true,
              value: _allVisibleSelected(rows)
                  ? true
                  : _selectedIds.isEmpty
                      ? false
                      : null,
              visualDensity: VisualDensity.compact,
              // tristate cycle: false -> null -> true; a partial selection
              // (null) selects everything, true clears the selection.
              onChanged: (bool? value) => _selectAllVisible(
                rows,
                select: value != false,
              ),
            ),
          ),
          cell(columns.name, FrameForgeStrings.sourceTableColumnName),
          cell(columns.type, FrameForgeStrings.sourceTableColumnType),
          cell(
            columns.nullable,
            FrameForgeStrings.sourceTableColumnNullable,
            center: true,
          ),
          cell(
            columns.possibleValues,
            FrameForgeStrings.sourceTableColumnPossibleValues,
          ),
          Container(
            width: columns.actions,
            height: 42,
            decoration: BoxDecoration(
              color: background,
              border: Border(right: grid()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, bool showFilterHint) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.grid_on_outlined,
            size: 40,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            showFilterHint
                ? FrameForgeStrings.sourceTableNoMatch
                : FrameForgeStrings.sourceTableEmpty,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            FrameForgeStrings.sourceTableEmptyHint,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsible group section header row.
class _SectionRow extends StatelessWidget {
  final _Row row;
  final _SourceTableEditorState state;

  const _SectionRow({
    super.key,
    required this.row,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final SourceVariableGroup? group = row.group;
    final String sectionKey = group?.id ?? _SourceTableEditorState
        ._rootSectionKey;
    final bool collapsed = state._collapsed.contains(sectionKey);
    final String name =
        group?.properties['name']?.value?.toString() ??
            FrameForgeStrings.sourceTableUngrouped;
    final bool isRoot = group == null;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 8.0 + row.depth * 16.0),
          InkWell(
            onTap: () => state.toggleSectionCollapsed(sectionKey),
            child: Icon(
              collapsed
                  ? Icons.keyboard_arrow_right
                  : Icons.keyboard_arrow_down,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isRoot ? Icons.dataset_outlined : Icons.folder,
            size: 16,
            color: isRoot ? colorScheme.primary : Colors.amber,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: isRoot
                ? Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Tooltip(
                    message: FrameForgeStrings.sourceTableRenameTooltip,
                    child: _CellTextField(
                      key: ValueKey<String>('section-name:$sectionKey'),
                      property: group.properties['name'],
                      onCommit: () => state._emitChange(group.id),
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${row.count}',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: isRoot
                ? FrameForgeStrings.sourceTableAddVariableTooltip
                : FrameForgeStrings.sourceTableAddVariableToGroupTooltip,
            icon: const Icon(Icons.add, size: 16),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            color: colorScheme.onSurfaceVariant,
            onPressed: () =>
                state._addVariable(isRoot ? state._sourcePage : group),
          ),
          if (!isRoot)
            IconButton(
              tooltip: FrameForgeStrings.sourceTableDeleteGroupTooltip,
              icon: const Icon(Icons.delete_outline, size: 16),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              color: colorScheme.onSurfaceVariant,
              onPressed: () => state._deleteItem(group),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// One variable row of the table with hover highlight.
class _VariableRow extends StatefulWidget {
  final _Row row;
  final _SourceTableEditorState state;
  final _Columns columns;
  final bool shaded;

  const _VariableRow({
    super.key,
    required this.row,
    required this.state,
    required this.columns,
    required this.shaded,
  });

  @override
  State<StatefulWidget> createState() => _VariableRowState();
}

class _VariableRowState extends State<_VariableRow> {
  bool hover = false;

  SourceVariable get variable => widget.row.variable!;

  BorderSide grid() => BorderSide(
        color: Theme.of(context).colorScheme.outlineVariant,
        width: 0.5,
      );

  Widget cell({
    required double width,
    required Widget child,
    AlignmentGeometry alignment = Alignment.centerLeft,
  }) {
    return Container(
      width: width,
      height: 40,
      alignment: alignment,
      decoration: BoxDecoration(border: Border(right: grid())),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool nullable = variable.properties['nullable']?.value != false;

    return MouseRegion(
      cursor: MouseCursor.defer,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: hover
              ? colorScheme.surfaceContainerHighest
              : widget.shaded
                  ? colorScheme.surfaceContainerLowest
                  : colorScheme.surface,
          border: Border(bottom: grid()),
        ),
        child: Row(
          children: <Widget>[
            cell(
              width: widget.columns.checkbox,
              alignment: Alignment.center,
              child: Checkbox(
                key: ValueKey<String>('check:${variable.id}'),
                value: widget.state._selectedIds.contains(variable.id),
                visualDensity: VisualDensity.compact,
                onChanged: (bool? value) =>
                    widget.state._toggleSelected(variable),
              ),
            ),
            cell(
              width: widget.columns.name,
              child: Row(
                children: <Widget>[
                  SizedBox(width: 8.0 + widget.row.depth * 16.0),
                  Expanded(
                    child: _CellTextField(
                      key: ValueKey<String>('name:${variable.id}'),
                      property: variable.properties['name'],
                      onCommit: () => widget.state._commitName(variable),
                      onFocusGained: () =>
                          widget.state._onNameFocusGained(variable),
                    ),
                  ),
                ],
              ),
            ),
            cell(
              width: widget.columns.type,
              child: _TypeCell(variable: variable, controller: widget.state.widget.controller),
            ),
            cell(
              width: widget.columns.nullable,
              alignment: Alignment.center,
              child: Checkbox(
                value: nullable,
                visualDensity: VisualDensity.compact,
                onChanged: (bool? value) {
                  variable.properties['nullable']?.value = value ?? true;
                  widget.state._emitChange(variable.id);
                },
              ),
            ),
            cell(
              width: widget.columns.possibleValues,
              child: _CellTextField(
                key: ValueKey<String>('possible:${variable.id}'),
                property: variable.properties['possibleValues'],
                onCommit: () => widget.state._emitChange(variable.id),
                hintText: '—',
              ),
            ),
            cell(
              width: widget.columns.actions,
              alignment: Alignment.center,
              child: IconButton(
                tooltip: FrameForgeStrings.sourceTableDeleteTooltip,
                icon: const Icon(Icons.delete_outline, size: 16),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                color: colorScheme.onSurfaceVariant,
                onPressed: () => widget.state._deleteItem(variable),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Borderless always-editable text cell (Excel-like).
class _CellTextField extends StatelessWidget {
  final Property? property;
  final VoidCallback onCommit;
  final VoidCallback? onFocusGained;
  final String? hintText;

  const _CellTextField({
    super.key,
    required this.property,
    required this.onCommit,
    this.onFocusGained,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return PropertyTextField(
      defaultValue: property?.value?.toString() ?? '',
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      onChanged: (String value) {
        property?.value = value;
      },
      onSubmitted: onCommit,
      onTapOutside: onCommit,
      onFocusLost: onCommit,
      onFocusGained: onFocusGained,
    );
  }
}

/// Type dropdown cell for a source variable.
class _TypeCell extends StatelessWidget {
  final SourceVariable variable;
  final LayoutModelController controller;

  const _TypeCell({
    required this.variable,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String current =
        variable.properties['type']?.value?.toString() ?? 'String';
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: sourceVariableTypes.contains(current) ? current : 'String',
        isExpanded: true,
        isDense: true,
        style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        items: sourceVariableTypes
            .map(
              (String type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type, style: const TextStyle(fontSize: 12)),
              ),
            )
            .toList(),
        icon: Icon(
          Icons.arrow_drop_down,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        onChanged: (String? value) {
          variable.properties['type']?.value =
              SourceVariableType(value ?? 'String');
          controller.eventBus.emit(
            AttributeChangeEvent(
              id: const Uuid().v4(),
              itemId: variable.id,
            ),
          );
        },
      ),
    );
  }
}
