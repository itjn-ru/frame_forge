import 'item.dart';
import 'source.dart';

/// A table data source in the layout model
///
/// Represents a table-like data structure with columns and rows
/// for use in layout components. Extends [LayoutSource] to provide
/// table-specific functionality.
class SourceTable extends LayoutSource {
  /// Creates a new source table
  ///
  /// [name] The name/identifier for this table
  /// [values] Optional list of initial column names.
  /// If null, creates a single default column named 'колонка'.
  SourceTable(name, [values]) : super('table', name) {
    if (values == null) {
      items.add(SourceTableColumn('колонка'));
    } else {
      for (final value in values) {
        items.add(SourceTableColumn(value.toString()));
      }
    }
  }
}

/// A column in a source table
///
/// Represents a single column within a [SourceTable], containing
/// metadata and configuration for that column.
class SourceTableColumn extends Item {
  /// Creates a new table column
  ///
  /// [name] The display name of the column
  SourceTableColumn(name) : super('column', name) {
    //properties["width"] = Property("ширина", 20, type: double);
  }
}
