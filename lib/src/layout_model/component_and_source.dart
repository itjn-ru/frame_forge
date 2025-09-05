import 'item.dart';

/// Base class for layout components and data sources in Frame Forge.
///
/// [LayoutComponentAndSource] serves as the foundation for all interactive
/// elements that can be placed in a layout, including UI components and
/// data source connections.
class LayoutComponentAndSource extends Item {
  /// Creates a new layout component or source with the specified [type] and [name].
  LayoutComponentAndSource(super.type, super.name);
}
