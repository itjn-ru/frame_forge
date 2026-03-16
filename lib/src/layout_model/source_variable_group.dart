import 'source.dart';

/// A group container for organizing source variables
///
/// Represents a logical grouping of [SourceVariable] items within a [SourcePage].
/// Groups are purely organizational and do not affect variable values or references.
/// Groups can be nested (a group can contain other groups).
class SourceVariableGroup extends LayoutSource {
  /// Creates a new source variable group
  ///
  /// [name] The display name of the group
  SourceVariableGroup(String name) : super('variableGroup', name);
}
