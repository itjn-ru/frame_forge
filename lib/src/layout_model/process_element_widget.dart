import 'package:flutter/widgets.dart';

import 'process_widget.dart';

class ProcessElementWidget extends ProcessWidget {
  const ProcessElementWidget(super.process, {super.key});

  @override
  Widget buildWidget(BuildContext context) {
    var cellText = process["name"] ?? "";

    return Container(
      //height: row.height,
      //decoration: BoxDecoration(
      //  border: Border.all(),
      //  color: column["color"],
      //),
      //alignment: column["alignment"],
      child: Text(cellText),
    );

    /*var columns = source.items.whereType<SourceTableColumn>();




    return Column(children: List.generate(columns.length, (index) {
      var column = columns.elementAt(index);
      return Text(column.properties["name"]?.value as String);
    }),);*/
  }
}
