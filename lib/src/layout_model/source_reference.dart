/// Represents a reference to a source variable in a SourcePage.
///
/// Used as the value type for 'source' properties on components.
/// Stores the variable name and optionally a map key if the
/// source variable is of type Map.
class SourceReference {
  /// The name of the source variable being referenced.
  String variableName;

  /// The map key to use when the source variable is a Map.
  /// Empty string means the whole Map is used.
  String mapKey;

  /// Whether this source reference allows null values.
  bool nullable;

  SourceReference({
    this.variableName = '',
    this.mapKey = '',
    this.nullable = true,
  });

  /// Whether the source reference has a non-empty variable name.
  bool get isNotEmpty => variableName.isNotEmpty;

  /// Whether the source reference has no variable name.
  bool get isEmpty => variableName.isEmpty;

  @override
  String toString() {
    if (variableName.isEmpty) return '';
    if (mapKey.isNotEmpty) return '$variableName.$mapKey';
    return variableName;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is String) return toString() == other;
    if (other is SourceReference) {
      return variableName == other.variableName &&
          mapKey == other.mapKey &&
          nullable == other.nullable;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(variableName, mapKey, nullable);

  /// Parses a source reference string like 'varName' or 'varName.key'.
  factory SourceReference.fromString(String value, {bool nullable = true}) {
    if (value.isEmpty) {
      return SourceReference(nullable: nullable);
    }
    final int dotIndex = value.indexOf('.');
    if (dotIndex >= 0) {
      return SourceReference(
        variableName: value.substring(0, dotIndex),
        mapKey: value.substring(dotIndex + 1),
        nullable: nullable,
      );
    }
    return SourceReference(variableName: value, nullable: nullable);
  }
}
