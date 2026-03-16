import 'property.dart';
import 'source.dart';

/// Marker type for SourceVariable's type property,
/// so the PropertyWidget factory can route it to a dropdown widget.
class SourceVariableType {
  final String value;
  const SourceVariableType(this.value);

  @override
  String toString() => value;
}

/// Supported variable types for source variables
const List<String> sourceVariableTypes = <String>[
  'String',
  'int',
  'double',
  'bool',
  'List',
  'Map',
];

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
    properties['type'] = Property(
      'type',
      const SourceVariableType('String'),
      type: SourceVariableType,
    );
    properties['nullable'] = Property('nullable', true, type: bool);
    properties['possibleValues'] = Property('возможные значения', '', type: String);
  }
}
