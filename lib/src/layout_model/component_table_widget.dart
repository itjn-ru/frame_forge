import '../canvas/layout_model_provider.dart';
import 'style_element.dart';
import 'package:flutter/material.dart';
import 'component_widget.dart';

import 'component_table.dart';
import 'item.dart';

class ComponentTableWidget extends ComponentWidget {
  const ComponentTableWidget({required super.component, super.key});

  @override
  Widget buildWidget(BuildContext context) {
    Map<int, TableColumnWidth> columnWidths = {};
    int columnWidthIndex = 0;

    // Headers are available but not currently used in this implementation
    // var headers = component.items.whereType<ComponentTableHeader>();

    var columns = component.items.whereType<ComponentTableColumn>();

    for (var column in columns) {
      columnWidths[columnWidthIndex] = FlexColumnWidth(
        column["width"] as double,
      );
      columnWidthIndex++;
    }

    List<TableRow> tableRows = [];

    var rowGroups = component.items.whereType<ComponentTableRowGroup>();

    for (var rowGroup in rowGroups) {
      var rows = rowGroup.items.whereType<ComponentTableRow>();

      for (var row in rows) {
        List<TableCell> tableCells = [];

        var cells = row.items.whereType<ComponentTableCell>();

        for (Item cell in cells) {
          String cellText = cell["source"]?.isNotEmpty ?? false
              ? "\$" + cell["source"]
              : "";
          if (cellText.isEmpty) {
            cellText = cell["text"] ?? "";
          }
          final controller = LayoutModelControllerProvider.of(context);
          final layoutModel = controller.layoutModel;
          StyleElement style =
              layoutModel.getStyleElementById(cell['style'].id) ??
              StyleElement("стиль");

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

/*class ComponentTableWidget extends ComponentWidget {
  const ComponentTableWidget(component, {super.key}) : super(component);

  @override
  Widget buildWidget(BuildContext context) {
    final LayoutModel layoutModel = context.read<LayoutModel>();
    return PdfPreview(
      build: (context) async => await generateTable(
          PdfPageFormat.a4,component,layoutModel,
      ),
    );

  }*/
/*  Future makePdf(LayoutModel layoutModel) async {
    final pdf = pw.Document();
    */ /*   final ByteData bytes = await rootBundle.load('assets/phone.png');
    final Uint8List byteList = bytes.buffer.asUint8List();*/ /*
    pdf.addPage(
        pw.Page(
            margin: const pw.EdgeInsets.all(10),
            pageFormat: PdfPageFormat.a4,
            build: (context) {
              return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Header(text: "About Cat", level: 1),
                          //   pw.Image(pw.MemoryImage(byteList), fit: pw.BoxFit.fitHeight, height: 100, width: 100)
                        ]
                    ),
                    pw.Divider(borderStyle: pw.BorderStyle.dashed),
                    pw.Paragraph(text: 'text'),
                    createTable(layoutModel),
                  ]
              );
            }
        ));
    return pdf.save();
  }

  pw.ListView createTable(LayoutModel layoutModel){
    Map<int, TableColumnWidth> getWidths = {};
    int columnWidthIndex = 0;

    var columns = component.items.whereType<ComponentTableColumn>();

    for (var column in columns) {
      getWidths[columnWidthIndex] = FixedColumnWidth(column["width"] as double);
      columnWidthIndex++;
    }


    List<pw.Table> tables = [];
    List<TableRow> tableRows = [];

    var rowGroups = component.items.whereType<ComponentTableRowGroup>();

    for (var rowGroup in rowGroups) {
      Map<int, TableColumnWidth> columnWidths = {};
      var rows = rowGroup.items.whereType<ComponentTableRow>();

      for (var row in rows) {
        List<pw.Widget> tableCells = [];

        var cells = row.items.whereType<ComponentTableCell>();
        int cellIndex = 0;
        for (Item cell in cells) {
          if (cell['colspan']) {
          } else {
            columnWidths[cellIndex] = getWidths[cellIndex]!;
          }
          cellIndex++;
          String cellText = cell["source"]?.isNotEmpty ?? false
              ? "\$" + cell["source"] ?? ""
              : "";
          if (cellText.isEmpty) {
            cellText = cell["text"] ?? "";
          }

          StyleElement style = layoutModel.getStyleElementById(cell['style'].id) ??
              StyleElement("стиль");

          tableCells.add(pw.TableCellVerticalAlignment(
            Container(
              //height: row.height,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: style["backgroundColor"],
                ),
                alignment: cell["alignment"],
                child: Text(cellText,
                    style: TextStyle(
                      fontSize: style["fontSize"],
                      fontWeight: style["fontWeight"],
                    ))),
          ));
        }
        tables.add(pw.Table(
            columnWidths: columnWidths,
            children: [pw.TableRow(children: tableCells)]));
        // tableRows.add(TableRow(children: tableCells));
      }
    }
    return pw.ListView( children: tables);
  }*/

/*
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'component_table.dart';
import 'component_widget.dart';
import 'item.dart';
import 'layout_model.dart';
import 'style.dart';
import 'style_element.dart';
import 'package:provider/provider.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class ComponentTableWidget extends ComponentWidget {
  ComponentTableWidget(component) : super(component);

  @override
  Widget buildWidget(BuildContext context) {
    Map<int, double> columnWidths = {};
    int columnWidthIndex = 0;

    final Map<int, double> rowHeights = {};

    var columns = component.items.whereType<ComponentTableColumn>();

    for (var column in columns) {
      columnWidths[columnWidthIndex] = column["width"] as double;
      columnWidthIndex++;
    }

    LayoutModel layoutModel = context.read<LayoutModel>();

    int rowIndex = 0;
    List<List<TableViewCell>> tableRows = [];
    int rowCount = 0;
    var rowGroups = component.items.whereType<ComponentTableRowGroup>();

    for (var rowGroup in rowGroups) {
      var rows = rowGroup.items.whereType<ComponentTableRow>();
      rowCount += rows.length;
      for (var row in rows) {
        List<TableViewCell> tableViewCells = [];
        List<TableCell> tableCells = [];
        rowHeights[rowIndex] = row["height"] as double;

        var cells = row.items.whereType<ComponentTableCell>();
        int columnIndex = 0;
        for (Item cell in cells) {
          String cellText = cell["source"]?.isNotEmpty ?? false
              ? "\$" + cell["source"] ?? ""
              : "";
          if (cellText.isEmpty) {
            cellText = cell["text"] ?? "";
          }
          StyleElement style = layoutModel.getStyleElementById(cell['style'].id) ??
              StyleElement("стиль");
          final double fontSize= style['fontSize'];
          late bool softWrap;
          if(columnIndex +1 == columns.length){
            softWrap=true;
          }else if(cell["colspan"] != 0
              ){
            softWrap=true;
          }
          else{
            if(  borderSide(cell["rightBorder"]).style != BorderStyle.none){
              softWrap=true;
            }else {
              softWrap=false;
            }
          }
          tableViewCells.add(
            TableViewCell(
              rowMergeStart: cell["rowspan"] != 0 ? rowIndex : null,
              rowMergeSpan: cell["rowspan"] != 0 ? cell["rowspan"] + 1 : null,
              columnMergeStart: cell["colspan"] != 0 ? columnIndex : null,
              columnMergeSpan:
                  cell["colspan"] != 0 ? cell["colspan"] + 1 : null,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    border: Border(
                  top: borderSide(cell["topBorder"]),
                  left: borderSide(cell["leftBorder"]),
                  right: borderSide(cell["rightBorder"]),
                  bottom: borderSide(cell["bottomBorder"]),
                )),
                child: Text(
                  cellText,
                  textAlign: cell["alignment"],
                  softWrap:softWrap,
                  style: TextStyle(
                    fontSize: fontSize.sp/3,
                    fontWeight: style["fontWeight"],
                    fontStyle: cell["isItalic"]
                        ? FontStyle.italic
                        :FontStyle.normal,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ),
          );

          columnIndex++;
        }
        rowIndex++;

        tableRows.add(tableViewCells);
      }
    }
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: LayoutBuilder(builder: (context, constraints) {
          double sum = 0;
          columnWidths.entries.forEach((e) => sum += e.value);
          final double ratio = constraints.maxWidth / sum;
          return TableView.builder(
            cellBuilder: (BuildContext context, TableVicinity vicinity) {
              return tableRows[vicinity.row][vicinity.column];
            },
            columnBuilder: (int column) {
              return TableSpan(
                extent: FixedSpanExtent(columnWidths[column]! * ratio),
                backgroundDecoration:
                    const TableSpanDecoration(color: Colors.white),
              );
            },
            columnCount: columnWidths.entries.length,
            rowCount: rowCount,
            rowBuilder: (int indexrow) {
              return TableSpan(
                extent: FixedTableSpanExtent(
                    (rowHeights[indexrow] ?? rowHeights[indexrow - 1] ?? 10) *
                        1.4142),
                backgroundDecoration: const TableSpanDecoration(
                  color: Colors.white,
                ),
              );
            },
          );
        }));
  }

//Table(columnWidths: columnWidths, children: tableRows);
  BorderSide borderSide(CustomBorderStyle customBorderStyle) {
    return customBorderStyle.side == CustomBorderSide.none
        ? BorderSide.none
        : BorderSide(
            color: customBorderStyle.color,
            width: customBorderStyle.width,
            style: BorderStyle.solid);
  }
}
*/
