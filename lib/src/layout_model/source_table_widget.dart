import 'package:flutter/widgets.dart';
import 'source_table.dart';
import 'source_widget.dart';

class SourceTableWidget extends SourceWidget {
  const SourceTableWidget(super.source, {super.key});

  @override
  Widget buildWidget(BuildContext context) {
    var columns = source.items.whereType<SourceTableColumn>();

    List<TableRow> tableRows = [];

    for (var column in columns) {
      List<TableCell> tableCells = [];

      var cellText = column['name'] ?? '';

      tableCells.add(
        TableCell(
          child: Text(
            cellText,
            //style: TextStyle(
            //fontSize: column["fontSize"],
            //fontWeight: column["fontWeight"],
            //)
          ),
        ),
      );

      tableRows.add(TableRow(children: tableCells));
    }
    return Table(children: tableRows);

    /*var columns = source.items.whereType<SourceTableColumn>();




    return Column(children: List.generate(columns.length, (index) {
      var column = columns.elementAt(index);
      return Text(column.properties["name"]?.value as String);
    }),);*/
  }
}
