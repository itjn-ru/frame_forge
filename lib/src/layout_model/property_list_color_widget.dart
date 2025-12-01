import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../color_picker/color_picker.dart';
import 'controller/events.dart';
import 'property.dart';
import 'property_widget.dart';

class PropertyListColorWidget extends PropertyWidget {
  const PropertyListColorWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final Property? property = controller.getCurrentItem()?.properties[propertyKey]!;
    final List<Color> colors = _normalizeToColorList(property?.value);

    return _DropdownWithAdd(
      colors: colors,
      onAddColor: (Color newColor) {
        final List<Color> updated = <Color>[...colors, newColor];
        property?.value = updated;
        controller.eventBus.emit(
          ChangeItem(
            id: const Uuid().v4(),
            itemId: controller.layoutModel.curItem.id,
          ),
        );
        return updated;
      },
      onRemoveAt: (int index) {
        if (index < 0 || index >= colors.length) return colors;
        final List<Color> updated = <Color>[...colors]..removeAt(index);
        property?.value = updated;
        controller.eventBus.emit(
          ChangeItem(
            id: const Uuid().v4(),
            itemId: controller.layoutModel.curItem.id,
          ),
        );
        return updated;
      },
      onReorder: (int oldIndex, int newIndex) {
        final List<Color> updated = <Color>[...colors];
        if (newIndex > oldIndex) newIndex -= 1;
        final Color c = updated.removeAt(oldIndex);
        updated.insert(newIndex, c);
        property?.value = updated;
        controller.eventBus.emit(
          ChangeItem(
            id: const Uuid().v4(),
            itemId: controller.layoutModel.curItem.id,
          ),
        );
        return updated;
      },
    );
  }
}

class _DropdownWithAdd extends StatefulWidget {
  final List<Color> colors;
  final List<Color> Function(Color newColor) onAddColor;
  final List<Color> Function(int index) onRemoveAt;
  final List<Color> Function(int oldIndex, int newIndex) onReorder;

  const _DropdownWithAdd({
    required this.colors,
    required this.onAddColor,
    required this.onRemoveAt,
    required this.onReorder,
  });

  @override
  State<_DropdownWithAdd> createState() => _DropdownWithAddState();
}

class _DropdownWithAddState extends State<_DropdownWithAdd> {
  int _selectedIndex = -1;
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _colors = List<Color>.from(widget.colors);
    _selectedIndex = _colors.isNotEmpty ? 0 : -1;
  }

  @override
  void didUpdateWidget(covariant _DropdownWithAdd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.colors != widget.colors) {
      _colors = List<Color>.from(widget.colors);
      if (_colors.isEmpty) {
        _selectedIndex = -1;
      } else {
        _selectedIndex = _selectedIndex.clamp(0, _colors.length - 1);
      }
    }
  }

  Future<void> _pickAndAddColor(BuildContext context) async {
    Color current = _selectedIndex >= 0 && _selectedIndex < _colors.length
        ? _colors[_selectedIndex]
        : const Color(0xFF6200EE);

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Choose a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: current,
            onColorChanged: (Color color) {
              final List<Color> updated = widget.onAddColor(color);
              setState(() {
                _colors = updated;
                _selectedIndex = _colors.length - 1;
              });
              Navigator.of(ctx).pop();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: DropdownButton<int>(
            isExpanded: true,
            value: _selectedIndex >= 0 && _selectedIndex < _colors.length
                ? _selectedIndex
                : null,
            hint: const Text('Select color'),
            items: <DropdownMenuItem<int>>[
              ...List<DropdownMenuItem<int>>.generate(_colors.length, (int i) {
                final Color c = _colors[i];
                return DropdownMenuItem<int>(
                  value: i,
                  child: Row(
                    children: <Widget>[
                      _ColorDot(color: c),
                      const SizedBox(width: 8),
                      Text(_hex(c)),
                    ],
                  ),
                );
              }),
              const DropdownMenuItem<int>(
                value: -1,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 8),
                    Text('Add color'),
                  ],
                ),
              ),
            ],
            onChanged: (int? value) async {
              if (value == null) return;
              if (value == -1) {
                await _pickAndAddColor(context);
              } else {
                setState(() => _selectedIndex = value);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Remove selected',
          icon: const Icon(Icons.delete_outline),
          onPressed: _selectedIndex >= 0 && _selectedIndex < _colors.length
              ? () {
                  final List<Color> updated = widget.onRemoveAt(_selectedIndex);
                  setState(() {
                    _colors = updated;
                    _selectedIndex = _colors.isEmpty
                        ? -1
                        : _selectedIndex.clamp(0, _colors.length - 1);
                  });
                }
              : null,
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}

String _hex(Color c) => c.value.toRadixString(16).padLeft(8, '0').toUpperCase();

List<Color> _normalizeToColorList(dynamic value) {
  if (value == null) return <Color>[];
  if (value is List<Color>) return List<Color>.from(value);
  if (value is List) {
    final List<Color> out = <Color>[];
    for (final dynamic v in value) {
      if (v is Color) out.add(v);
      if (v is int) out.add(Color(v));
      if (v is String) {
        String s = v.trim();
        if (s.startsWith('#')) s = s.substring(1);
        if (s.startsWith('0x')) s = s.substring(2);
        if (s.length == 6) s = 'FF$s';
        final int? val = int.tryParse(s, radix: 16);
        if (val != null) out.add(Color(val));
      }
    }
    return out;
  }
  if (value is String) {
    final List<Color> out = <Color>[];
    for (String s in value.split(',')) {
      s = s.trim();
      if (s.isEmpty) continue;
      if (s.startsWith('#')) s = s.substring(1);
      if (s.startsWith('0x')) s = s.substring(2);
      if (s.length == 6) s = 'FF$s';
      final int? val = int.tryParse(s, radix: 16);
      if (val != null) out.add(Color(val));
    }
    return out;
  }
  return <Color>[];
}
