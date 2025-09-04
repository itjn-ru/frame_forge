import 'item.dart';
import 'source.dart';

class SourceTable extends LayoutSource {
  SourceTable(name, [values]) : super('table', name) {
    if(values==null) {
      items.add(SourceTableColumn('колонка'));
    }else{
      for(final value in values){
        items.add(SourceTableColumn(value.toString()));
      }
    }

  }
}

class SourceTableColumn extends Item {
  SourceTableColumn(name) : super('column', name) {
    //properties["width"] = Property("ширина", 20, type: double);
  }
}