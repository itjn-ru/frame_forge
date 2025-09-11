import 'property.dart';
import 'source.dart';

/// A variable data source in the layout model
///
/// Represents a simple variable that can hold data values
/// for use in layout components. Extends [LayoutSource] to
/// provide variable-specific functionality.
class SourceVariable extends LayoutSource {
  /// Creates a new source variable
  ///
  /// [name] The name/identifier for this variable
  SourceVariable(String name) : super('variable', name) {
    properties["type"] = Property("type", '');
  }
}
