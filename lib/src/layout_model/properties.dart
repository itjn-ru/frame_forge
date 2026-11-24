import 'package:material_ui/material_ui.dart';

import 'controller/layout_model_controller.dart';
import 'item.dart';
import 'property_widget.dart';

class Properties extends StatelessWidget {
  final LayoutModelController controller;

  const Properties(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
              // Flexible widths: the label column takes about a third of the
              // panel, the rest goes to the property widget itself. Long
              // source names and dropdowns finally get enough space.
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: List<TableRow>.generate(keys.length, (int index) {
                final String key = keys[index];
                final dynamic prop = properties[key];

                return TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 0.5,
                      ),
                    ),
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 2,
                        right: 6,
                        top: 4,
                        bottom: 4,
                      ),
                      child: Text(
                        "${prop?.title ?? ""}:",
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: PropertyWidget.create(controller, key),
                    ),
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
