import 'item.dart';

/// The root item of a layout model
///
/// Represents the top-level container in the layout hierarchy.
/// All other items in the layout model are children of this root item.
class Root extends Item {
  /// Creates a new root item
  ///
  /// [name] The display name of the root item
  Root( name) : super("root", name);
}
