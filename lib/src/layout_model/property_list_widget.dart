import 'package:flutter/material.dart';
import 'package:frame_forge/src/layout_model/property.dart';
import 'package:uuid/uuid.dart';

import 'controller/events.dart';
import 'property_widget.dart';

class PropertyListWidget extends PropertyWidget {
  const PropertyListWidget(super.controller, super.propertyKey, {super.key});

  @override
  Widget build(BuildContext context) {
    final Property? property =
        controller.getCurrentItem()?.properties[propertyKey]!;

    final List<String> initialValue =
        property?.value as List<String>? ?? <String>[];
    return EditableStringList(
      initialItems: initialValue,
      onChanged: (List<String> newValue) {
        property?.value = newValue;
        controller.eventBus.emit(ChangeItem(
            id: const Uuid().v4(), itemId: controller.getCurrentItem()?.id));
      },
    );
  }
}

class EditableStringList extends StatefulWidget {
  final List<String> initialItems;
  final ValueChanged<List<String>>? onChanged;
  final String emptyPlaceholder;

  const EditableStringList({
    super.key,
    this.initialItems = const <String>[],
    this.onChanged,
    this.emptyPlaceholder = 'List is empty. Press + to add.',
  });

  @override
  _EditableStringListState createState() => _EditableStringListState();
}

class _EditableStringListState extends State<EditableStringList> {
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.initialItems);
  }

  void _notify() {
    widget.onChanged?.call(List.of(_items));
  }

  @override
  void didUpdateWidget(covariant EditableStringList oldWidget) {
    if (oldWidget.initialItems != widget.initialItems) {
      _items = List.of(widget.initialItems);
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _showEditDialog({String? initial, int? index}) async {
    final TextEditingController controller =
        TextEditingController(text: initial ?? '');
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(index == null ? 'Add item' : 'Edit item'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter text',
            ),
            validator: (String? v) {
              if (v == null || v.trim().isEmpty) return 'Cannot be empty';
              return null;
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false)
                Navigator.of(ctx).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final String text = controller.text.trim();
      setState(() {
        if (index == null) {
          _items.add(text);
        } else {
          _items[index] = text;
        }
      });
      _notify();
    }
  }

  void _removeAt(int index) {
    final String removed = _items[index];
    setState(() {
      _items.removeAt(index);
    });
    _notify();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed: "$removed"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _items.insert(index, removed);
            });
            _notify();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Using a Column with mainAxisSize.min and a shrink-wrapped ListView
    // avoids Expanded inside an unconstrained Table cell (previously caused
    // RenderFlex and Table layout assertions). Height is capped for usability.
    const double maxListHeight = 240;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: IconButton(
            tooltip: 'Add',
            onPressed: () => _showEditDialog(index: null),
            icon: const Icon(Icons.add),
          ),
        ),
        if (_items.isEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              widget.emptyPlaceholder,
              textAlign: TextAlign.center,
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: maxListHeight),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (BuildContext context, int index) {
                final String item = _items[index];
                return Dismissible(
                  key: ValueKey('item_${index}_${item.hashCode}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child:
                        const Icon(Icons.delete_forever, color: Colors.white),
                  ),
                  onDismissed: (_) => _removeAt(index),
                  child: ListTile(
                    title: Text(item),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: () =>
                          _showEditDialog(initial: item, index: index),
                    ),
                    onLongPress: () =>
                        _showEditDialog(initial: item, index: index),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

List<String> _normalizeToStringList(dynamic value) {
  if (value == null) return <String>[];
  if (value is String) return <String>[value];
  if (value is List<String>) return List<String>.from(value);
  if (value is List) {
    final List<String> result = <String>[];
    for (final dynamic e in value) {
      if (e is String) {
        result.add(e);
      } else if (e is List) {
        for (final dynamic inner in e) {
          if (inner is String) result.add(inner);
        }
      }
    }
    return result;
  }
  return <String>[];
}
