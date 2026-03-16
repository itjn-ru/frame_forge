import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'controller/events.dart';
import 'controller/layout_model_controller.dart';
import 'item.dart';
import 'page.dart';
import 'property.dart';
import 'property_widget.dart';
import 'source_reference.dart';
import 'source_variable.dart';
import 'source_variable_group.dart';

/// A property widget that shows a hierarchical navigator for selecting
/// source variables from the SourcePage. Groups can be drilled into;
/// variables are selectable as source references.
class PropertySourceWidget extends PropertyWidget {
  const PropertySourceWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final Property? property =
        controller.getCurrentItem()?.properties[propertyKey];
    if (property == null) return const SizedBox.shrink();

    final SourceReference sourceRef = property.value is SourceReference
        ? property.value as SourceReference
        : SourceReference.fromString(
            property.value?.toString() ?? '',
          );

    if (property.value is! SourceReference) {
      property.value = sourceRef;
    }

    return _SourceNavigator(
      controller: controller,
      sourceRef: sourceRef,
      property: property,
    );
  }
}

/// Stateful widget that manages drill-down navigation through
/// SourceVariableGroups and selection of SourceVariables.
class _SourceNavigator extends StatefulWidget {
  final LayoutModelController controller;
  final SourceReference sourceRef;
  final Property property;

  const _SourceNavigator({
    required this.controller,
    required this.sourceRef,
    required this.property,
  });

  @override
  State<_SourceNavigator> createState() => _SourceNavigatorState();
}

class _SourceNavigatorState extends State<_SourceNavigator> {
  /// Stack of group IDs representing the current navigation path.
  final List<String> _path = <String>[];

  /// Returns items at the current navigation level.
  List<Item> _currentLevelItems() {
    final SourcePage sourcePage = widget.controller.layoutModel.root.items
        .whereType<SourcePage>()
        .first;

    List<Item> items = sourcePage.items;
    for (final String groupId in _path) {
      final Item? group = items
          .whereType<SourceVariableGroup>()
          .where((SourceVariableGroup g) => g.id == groupId)
          .firstOrNull;
      if (group == null) break;
      items = group.items;
    }
    return items;
  }

  /// Builds breadcrumb labels for the current path.
  List<_BreadcrumbEntry> _buildBreadcrumbs() {
    final SourcePage sourcePage = widget.controller.layoutModel.root.items
        .whereType<SourcePage>()
        .first;

    final List<_BreadcrumbEntry> crumbs = <_BreadcrumbEntry>[
      _BreadcrumbEntry('данные', -1),
    ];

    List<Item> items = sourcePage.items;
    for (int i = 0; i < _path.length; i++) {
      final SourceVariableGroup? group = items
          .whereType<SourceVariableGroup>()
          .where((SourceVariableGroup g) => g.id == _path[i])
          .firstOrNull;
      if (group == null) break;
      final String name =
          group.properties['name']?.value?.toString() ?? '';
      crumbs.add(_BreadcrumbEntry(name, i));
      items = group.items;
    }

    return crumbs;
  }

  /// Finds a SourceVariable by name across the entire SourcePage tree.
  SourceVariable? _findVariableByName(String name) {
    if (name.isEmpty) return null;
    final SourcePage sourcePage = widget.controller.layoutModel.root.items
        .whereType<SourcePage>()
        .first;
    return _searchVariable(sourcePage.items, name);
  }

  SourceVariable? _searchVariable(List<Item> items, String name) {
    for (final Item item in items) {
      if (item is SourceVariable &&
          item.properties['name']?.value?.toString() == name) {
        return item;
      }
      if (item is SourceVariableGroup) {
        final SourceVariable? found = _searchVariable(item.items, name);
        if (found != null) return found;
      }
    }
    return null;
  }

  void _emitChange() {
    widget.controller.eventBus.emit(
      AttributeChangeEvent(
        id: const Uuid().v4(),
        itemId: widget.controller.selectedId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SourceReference sourceRef = widget.sourceRef;
    final List<Item> levelItems = _currentLevelItems();

    final List<SourceVariableGroup> groups =
        levelItems.whereType<SourceVariableGroup>().toList();
    final List<SourceVariable> variables =
        levelItems.whereType<SourceVariable>().toList();

    // Check if the currently selected variable is at this level
    final bool selectedHere = variables.any(
      (SourceVariable v) =>
          v.properties['name']?.value?.toString() == sourceRef.variableName,
    );

    // Dropdown value: selected name if visible at this level, otherwise ''
    final String dropdownValue =
        selectedHere ? sourceRef.variableName : '';

    // Build dropdown items for variables only
    final List<DropdownMenuItem<String>> variableDropdownItems =
        <DropdownMenuItem<String>>[
      const DropdownMenuItem<String>(
        value: '',
        child: Text('—', style: TextStyle(color: Colors.grey)),
      ),
      ...variables.map(
        (SourceVariable v) {
          final String name =
              v.properties['name']?.value?.toString() ?? '';
          final String type =
              v.properties['type']?.value?.toString() ?? '';
          return DropdownMenuItem<String>(
            value: name,
            child: Text('$name ($type)'),
          );
        },
      ),
    ];

    // Find selected variable for Map key handling
    final SourceVariable? selectedVariable =
        _findVariableByName(sourceRef.variableName);

    final bool isMapType =
        selectedVariable?.properties['type']?.value?.toString() == 'Map';

    final List<String> mapKeys =
        isMapType ? _getMapKeys(selectedVariable!) : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Show current selection if not visible at this level
        if (sourceRef.variableName.isNotEmpty && !selectedHere)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: <Widget>[
                const Icon(Icons.check, size: 12, color: Colors.green),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    sourceRef.variableName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    sourceRef.variableName = '';
                    sourceRef.mapKey = '';
                    widget.property.value = sourceRef;
                    _emitChange();
                  },
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

        // Breadcrumb navigation
        if (_path.isNotEmpty) _buildBreadcrumbRow(),

        // Groups as clickable tiles
        if (groups.isNotEmpty)
          ...groups.map(
            (SourceVariableGroup group) {
              final String name =
                  group.properties['name']?.value?.toString() ?? '';
              return InkWell(
                onTap: () => setState(() => _path.add(group.id)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.folder, size: 14, color: Colors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        if (groups.isNotEmpty && variables.isNotEmpty)
          const Divider(height: 4),

        // Variable dropdown
        if (variables.isNotEmpty)
          Row(
            children: <Widget>[
              Expanded(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  isExpanded: true,
                  items: variableDropdownItems,
                  onChanged: (String? value) {
                    sourceRef.variableName = value ?? '';
                    sourceRef.mapKey = '';
                    widget.property.value = sourceRef;
                    _emitChange();
                  },
                ),
              ),
            ],
          ),

        // Map key dropdown (shown only when source is a Map type)
        if (isMapType && mapKeys.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: <Widget>[
                const Text('key: ',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                Expanded(
                  child: DropdownButton<String>(
                    value: _getValidMapKey(sourceRef.mapKey, mapKeys),
                    isExpanded: true,
                    items: <DropdownMenuItem<String>>[
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('(whole Map)',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      ...mapKeys.map(
                        (String key) => DropdownMenuItem<String>(
                          value: key,
                          child: Text(key,
                              style: const TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                    onChanged: (String? value) {
                      sourceRef.mapKey = value ?? '';
                      widget.property.value = sourceRef;
                      _emitChange();
                    },
                  ),
                ),
              ],
            ),
          ),

        // Nullable checkbox
        Row(
          children: <Widget>[
            const Text('nullable: ',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
            Checkbox(
              value: sourceRef.nullable,
              onChanged: (bool? value) {
                sourceRef.nullable = value ?? true;
                widget.property.value = sourceRef;
                _emitChange();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreadcrumbRow() {
    final List<_BreadcrumbEntry> crumbs = _buildBreadcrumbs();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          for (int i = 0; i < crumbs.length; i++) ...<Widget>[
            if (i > 0)
              const Text(' › ',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            InkWell(
              onTap: () {
                setState(() {
                  // Navigate to this breadcrumb level
                  final int targetDepth = crumbs[i].depth;
                  if (targetDepth < 0) {
                    _path.clear();
                  } else {
                    while (_path.length > targetDepth + 1) {
                      _path.removeLast();
                    }
                  }
                });
              },
              child: Text(
                crumbs[i].label,
                style: TextStyle(
                  fontSize: 11,
                  color: i < crumbs.length - 1 ? Colors.blue : Colors.black87,
                  decoration: i < crumbs.length - 1
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _getMapKeys(SourceVariable variable) {
    return variable.items
        .whereType<SourceVariable>()
        .map((SourceVariable child) =>
            child.properties['name']?.value?.toString() ?? '')
        .where((String name) => name.isNotEmpty)
        .toList();
  }

  String _getValidMapKey(String mapKey, List<String> keys) {
    if (mapKey.isEmpty) return '';
    return keys.contains(mapKey) ? mapKey : '';
  }
}

class _BreadcrumbEntry {
  final String label;
  final int depth; // -1 for root

  const _BreadcrumbEntry(this.label, this.depth);
}
