import 'component.dart';
import 'property.dart';
import 'style.dart';
import 'item.dart';

class ComponentTable extends LayoutComponent {
  ComponentTable(name) : super("table", name) {
    properties['source'] = Property('источник', '');
    items.add(ComponentTableColumn("колонка"));

    var row = ComponentTableRow("строка");
    row.items.add(ComponentTableCell("ячейка"));

    var rowGroup = ComponentTableRowGroup("группа строк");
    rowGroup.items.add(row);

    items.add(rowGroup);
  }
}

class ComponentTableHeader extends Item {
  ComponentTableHeader(name) : super("column", name) {
    properties["width"] = Property("ширина", 20, type: double);
  }
}

class ComponentTableColumn extends Item {
  ComponentTableColumn(name) : super("column", name) {
    properties["width"] = Property("ширина", 20, type: double);
  }
}

class ComponentTableRowGroup extends Item {
  ComponentTableRowGroup(name) : super("rowGroup", name) {
    properties["style"] = Property("стиль", Style.basic, type: Style);
  }
}

class ComponentTableRow extends Item {
  ComponentTableRow(name) : super("row", name) {
    properties["style"] = Property("стиль", Style.basic, type: Style);
  }
}

class ComponentTableCell extends Item {
  ComponentTableCell(name) : super("cell", name) {
    properties["text"] = Property("текст", "");
    properties["source"] = Property("источник", "");
    properties["style"] = Property("стиль", Style.basic, type: Style);
  }
}
