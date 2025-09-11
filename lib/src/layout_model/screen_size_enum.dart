/// Enumeration of supported screen sizes for responsive layout design
///
/// Defines different screen size configurations with their dimensions
/// and characteristics. Used by the layout system to provide responsive
/// design capabilities.
enum ScreenSizeEnum {
  /// Mobile screen configuration (360x720)
  ///
  /// Optimized for mobile devices with portrait orientation.
  mobile(width: 360, height: 720, title: 'mobile', value: true),

  /// Desktop screen configuration (720x720)
  ///
  /// Optimized for desktop displays with square aspect ratio.
  desktop(width: 720, height: 720, title: 'desktop', value: false);

  /// The width of this screen size in logical pixels
  final double width;

  /// The height of this screen size in logical pixels
  final double height;

  /// The human-readable title for this screen size
  final String title;

  /// Boolean value associated with this screen size
  final bool value;

  /// Creates a screen size enum value
  ///
  /// [height] The screen height in logical pixels
  /// [width] The screen width in logical pixels
  /// [title] The display title for this screen size
  /// [value] A boolean value associated with this screen size
  const ScreenSizeEnum({
    required this.height,
    required this.width,
    required this.title,
    required this.value,
  });
}
