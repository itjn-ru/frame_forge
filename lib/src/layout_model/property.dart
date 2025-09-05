/// Represents a configurable property of a layout item.
///
/// [Property] holds a value with metadata including its display title and type.
/// Properties are used to configure various aspects of layout items like
/// position, size, color, and behavior.
class Property {
  /// The human-readable title for this property (used in UI).
  String title;

  /// The current value of the property.
  dynamic value;

  /// The expected type of the property value.
  Type type;

  /// Creates a new property with the specified [title] and [value].
  ///
  /// - [type]: The expected type (defaults to String)
  Property(this.title, this.value, {this.type = String});
}
