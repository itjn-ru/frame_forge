import 'package:flutter/material.dart';
import 'component_and_source.dart';
import 'constants.dart';

/// A layout component that represents a style definition
///
/// Extends [LayoutComponentAndSource] to provide style-specific
/// functionality in the layout editor.
class LayoutStyle extends LayoutComponentAndSource {
  /// Creates a new layout style
  ///
  /// [type] The type identifier for this style
  /// [name] The display name of the style
  LayoutStyle(super.type, super.name);
}

/// Represents a style with identifier and display name
///
/// Used to define and apply consistent styling across layout components.
/// Each style has a unique ID for reference and a human-readable name.
class Style {
  /// Unique identifier for the style
  String id;

  /// Human-readable name for the style
  String name;

  /// The default basic style used as fallback
  static Style basic = Style(UuidNil, 'базовый стиль');

  /// Creates a new style
  ///
  /// [id] The unique identifier for the style
  /// [name] The display name for the style
  Style(this.id, this.name);

  /// Compares two styles for equality based on their IDs
  @override
  bool operator ==(Object other) => other is Style && id == other.id;

  /// Generates hash code based on ID and name
  @override
  int get hashCode => Object.hash(id, name);
}

/// Represents a custom border style configuration
///
/// Defines border appearance with width, color, and side styling.
/// Can be converted to Flutter's [BorderSide] for rendering.
class CustomBorderStyle {
  /// The width of the border
  double width;

  /// The color of the border
  Color color;

  /// The side configuration for the border
  CustomBorderSide side;

  /// Converts to Flutter's BorderSide for rendering
  BorderSide get borderSide =>
      BorderSide(width: width, color: color, style: side.borderStyle);

  static CustomBorderStyle basic = CustomBorderStyle(
    1.0,
    Colors.black,
    CustomBorderSide.solid,
  );

  factory CustomBorderStyle.init() {
    return CustomBorderStyle(0.0, Colors.transparent, CustomBorderSide.none);
  }

  CustomBorderStyle(this.width, this.color, this.side);

  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'color': color.toARGB32().toRadixString(16).toUpperCase(),
      'side': side,
    };
  }

  factory CustomBorderStyle.fromMap(Map<String, dynamic> map) {
    return CustomBorderStyle(
      double.parse(map['width']),
      Color(int.tryParse(map['color'], radix: 16) ?? 0),
      CustomBorderSide.values.firstWhere(
        (e) => e.toString() == map['side'],
        orElse: () => CustomBorderSide.none,
      ),
    );
  }
}

enum CustomBorderSide {
  none('Нет'),
  solid('Сплошная'),
  dash('Тире'),
  dot('Точка');

  final String title;

  const CustomBorderSide(this.title);

  CustomBorderSide side(String value) {
    return CustomBorderSide.values.firstWhere(
      (e) => e.toString() == value.split('.').last,
    );
  }

  BorderStyle get borderStyle {
    switch (this) {
      case CustomBorderSide.none:
        return BorderStyle.none;
      case CustomBorderSide.solid:
        return BorderStyle.solid;
      case CustomBorderSide.dash:
        return BorderStyle.solid;
      case CustomBorderSide.dot:
        return BorderStyle.solid;
    }
  }
}
