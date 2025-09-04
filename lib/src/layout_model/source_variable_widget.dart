import 'package:flutter/widgets.dart';
import 'source_widget.dart';

class SourceVariableWidget extends SourceWidget {
  const SourceVariableWidget(super.source, {super.key});

  @override
  Widget buildWidget(BuildContext context) {
    var cellText = source['name'] ?? '';

    return Text(
          cellText,
          //style: TextStyle(
          //fontSize: column["fontSize"],
          //fontWeight: column["fontWeight"],
          //)
        );

    /*var columns = source.items.whereType<SourceTableColumn>();




    return Column(children: List.generate(columns.length, (index) {
      var column = columns.elementAt(index);
      return Text(column.properties["name"]?.value as String);
    }),);*/
  }
}
