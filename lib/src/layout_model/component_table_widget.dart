import '../canvas/layout_model_provider.dart';
import 'controller/layout_model_controller.dart';
import 'layout_model.dart';
import 'style_element.dart';
import 'package:flutter/material.dart';
import 'component_widget.dart';

import 'component_table.dart';

class ComponentTableWidget extends ComponentWidget {
  const ComponentTableWidget({required super.component, super.key});

  @override
  Widget buildWidget(BuildContext context) {
    Map<int, TableColumnWidth> columnWidths = {};
    int columnWidthIndex = 0;

    // Headers are available but not currently used in this implementation
    // var headers = component.items.whereType<ComponentTableHeader>();

    final Iterable<ComponentTableColumn> columns = component.items.whereType<ComponentTableColumn>();

    for (final ComponentTableColumn column in columns) {
      columnWidths[columnWidthIndex] = FlexColumnWidth(
        column["width"] as double,
      );
      columnWidthIndex++;
    }

    List<TableRow> tableRows = [];

    final Iterable<ComponentTableRowGroup> rowGroups = component.items.whereType<ComponentTableRowGroup>();

    for (final ComponentTableRowGroup rowGroup in rowGroups) {
      final Iterable<ComponentTableRow> rows = rowGroup.items.whereType<ComponentTableRow>();

      for (final ComponentTableRow row in rows) {
        List<TableCell> tableCells = [];

        final Iterable<ComponentTableCell> cells = row.items.whereType<ComponentTableCell>();

        for (final ComponentTableCell cell in cells) {
          String cellText = cell["source"]?.isNotEmpty ?? false
              ? "\$${cell["source"]}"
              : "";
          if (cellText.isEmpty) {
            cellText = cell["text"] ?? "";
          }
          final LayoutModelController controller = LayoutModelControllerProvider.of(context);
          final LayoutModel layoutModel = controller.layoutModel;
         final  StyleElement style =
              layoutModel.getStyleElementById(cell['style'].id) ??
              StyleElement("style");

          tableCells.add(
            TableCell(
              child: Container(
                //height: row.height,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: style["backgroundColor"],
                ),
                alignment: cell["alignment"],
                child: Text(
                  cellText,
                  overflow: TextOverflow.fade,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: style["fontSize"],
                    fontWeight: style["fontWeight"],
                  ),
                ),
              ),
            ),
          );
        }

        tableRows.add(TableRow(children: tableCells));
      }
    }
    return Table(columnWidths: columnWidths, children: tableRows);
  }
}