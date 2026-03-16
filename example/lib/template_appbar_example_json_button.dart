import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frame_forge/frame_forge.dart';

class TemplateAppbarExampleJsonButton extends StatelessWidget {
  final LayoutModelController controller;
  const TemplateAppbarExampleJsonButton(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: () => _showExampleJson(context),
        child: const Text('Пример json', style: TextStyle(color: Colors.black)),
      ),
    );
  }

  void _showExampleJson(BuildContext context) {
    final Map<String, dynamic> exampleMap = _buildExampleMap();
    final String prettyJson =
        const JsonEncoder.withIndent('  ').convert(exampleMap);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Пример JSON'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: SelectableText(
                prettyJson,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: prettyJson));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('JSON скопирован в буфер обмена'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Копировать'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> _buildExampleMap() {
    final SourcePage sourcePage =
        controller.layoutModel.root.items.whereType<SourcePage>().first;

    final Map<String, dynamic> result = <String, dynamic>{};

    for (final SourceVariable variable
        in sourcePage.items.whereType<SourceVariable>()) {
      final String name = variable['name'] ?? '';
      if (name.isEmpty) continue;

      final String typeName =
          variable.properties['type']?.value?.toString() ?? 'String';
      final bool nullable = variable.properties['nullable']?.value == true;

      result[name] = _defaultValue(typeName, nullable, variable);
    }

    return result;
  }

  dynamic _defaultValue(
      String typeName, bool nullable, SourceVariable variable) {
    if (nullable && typeName != 'Map') return null;

    switch (typeName) {
      case 'String':
        return nullable ? null : '';
      case 'int':
        return nullable ? null : 0;
      case 'double':
        return nullable ? null : 0.0;
      case 'bool':
        return nullable ? null : false;
      case 'List':
        return nullable ? null : <dynamic>[];
      case 'Map':
        final List<SourceVariable> children =
            variable.items.whereType<SourceVariable>().toList();
        if (children.isNotEmpty) {
          return <String, dynamic>{
            for (final SourceVariable child in children)
              if ((child['name'] ?? '').toString().isNotEmpty)
                child['name'] as String: _defaultValue(
                  child.properties['type']?.value?.toString() ?? 'String',
                  child.properties['nullable']?.value == true,
                  child,
                ),
          };
        }
        return <String, dynamic>{};
      default:
        return nullable ? null : '';
    }
  }
}
