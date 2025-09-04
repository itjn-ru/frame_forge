import 'package:flutter/widgets.dart';
import 'style_widget.dart';

class StyleElementWidget extends StyleWidget {
  const StyleElementWidget(super.style, {super.key});

  @override
  Widget buildWidget(BuildContext context) {
    var cellText = style["name"] ?? "";

    return Container(
        //height: row.height,
        //decoration: BoxDecoration(
        //  border: Border.all(),
        //  color: column["color"],
        //),
        //alignment: column["alignment"],
        child: Text(
      cellText,
      style: TextStyle(
      fontSize: style["fontSize"],
      fontWeight: style["fontWeight"],
      )
    ));

    /*var columns = source.items.whereType<SourceTableColumn>();




    return Column(children: List.generate(columns.length, (index) {
      var column = columns.elementAt(index);
      return Text(column.properties["name"]?.value as String);
    }),);*/
  }
}
