import 'package:flutter/widgets.dart';

import 'component_and_source.dart';
import 'property.dart';
import 'style.dart';

/// A layout component with position, size, and style properties
///
/// Extends [LayoutComponentAndSource] to provide basic layout functionality
/// for UI components. Each component has position, size, and style properties
/// that control its appearance and placement in the layout.
class LayoutComponent extends LayoutComponentAndSource {
  /// Creates a new layout component
  ///
  /// [type] The type identifier for this component
  /// [name] The display name of the component
  ///
  /// Automatically initializes default properties:
  /// - position: (0, 0) offset
  /// - size: 360x30 pixels
  /// - style: basic style
  LayoutComponent(super.type, super.name) {
    properties['position'] = Property(
      'position',
      const Offset(0, 0),
      type: Offset,
    );
    properties['size'] = Property('size', const Size(360, 30), type: Size);
    properties['style'] = Property('style', Style.basic, type: Style);
  }
}
