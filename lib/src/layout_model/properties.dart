import 'package:flutter/material.dart';

import 'controller/layout_model_controller.dart';
import 'item.dart';
import 'property_widget.dart';

class Properties extends StatelessWidget {
  final LayoutModelController controller;

  const Properties(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: controller.selectedIdNotifier,
      builder: (BuildContext context, String? selectedId, _) {
        final Item? curItem = controller.getItemById(selectedId);
        if (curItem == null) {
          return const Center(child: Text('No selection'));
        }

        return ValueListenableBuilder<Map<String, dynamic>>(
          valueListenable: controller.propertiesNotifier,
          builder: (BuildContext context, Map<String, dynamic> properties, _) {
            final List<String> keys = properties.keys.toList();

            return Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(50),
                1: FixedColumnWidth(100),
              },
              children: List<TableRow>.generate(keys.length, (int index) {
                final String key = keys[index];
                final dynamic prop = properties[key];

                return TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  children: <Widget>[
                    Text("${prop?.title ?? ""}:"),
                    PropertyWidget.create(controller, key),
                  ],
                );
              }),
            );
          },
        );
      },
    );
  }
}
