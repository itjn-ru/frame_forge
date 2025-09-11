import 'component.dart';
import 'property.dart';
import 'style.dart';
import 'item.dart';

class ComponentTable extends LayoutComponent {
  ComponentTable(String name) : super("table", name) {
    properties['source'] = Property('source', '');
    items.add(ComponentTableColumn("column"));

    final ComponentTableRow row = ComponentTableRow("row");
    row.items.add(ComponentTableCell("cell"));

    final ComponentTableRowGroup rowGroup = ComponentTableRowGroup("row group");
    rowGroup.items.add(row);

    items.add(rowGroup);
  }
}

class ComponentTableHeader extends Item {
  ComponentTableHeader(String name) : super("column", name) {
    properties["width"] = Property("width", 20, type: double);
  }
}

class ComponentTableColumn extends Item {
  ComponentTableColumn(String name) : super("column", name) {
    properties["width"] = Property("width", 20, type: double);
  }
}

class ComponentTableRowGroup extends Item {
  ComponentTableRowGroup(String name) : super("rowGroup", name) {
    properties["style"] = Property("style", Style.basic, type: Style);
  }
}

class ComponentTableRow extends Item {
  ComponentTableRow(String name) : super("row", name) {
    properties["style"] = Property("style", Style.basic, type: Style);
  }
}

class ComponentTableCell extends Item {
  ComponentTableCell(String name) : super("cell", name) {
    properties["text"] = Property("text", "");
    properties["source"] = Property("source", "");
    properties["style"] = Property("style", Style.basic, type: Style);
  }
}
