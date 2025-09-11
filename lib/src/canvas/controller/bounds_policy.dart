class BoundsPolicy {
  final double minWidth;
  final double minHeight;
  final double maxRight;
  final double maxBottom;

  const BoundsPolicy({
    required this.minWidth,
    required this.minHeight,
    required this.maxRight,
    required this.maxBottom,
  });

  double clampLeft(double left) => left.clamp(0.0, maxRight - minWidth);
  double clampTop(double top) => top.clamp(0.0, maxBottom - minHeight);
  double clampRight(double left, double right) => right.clamp(left + minWidth, maxRight);
  double clampBottom(double top, double bottom) => bottom.clamp(top + minHeight, maxBottom);

  // Clamp top-left during move, keeping current width/height intact
  double clampLeftForWidth(double left, double width) => left.clamp(0.0, maxRight - width);
  double clampTopForHeight(double top, double height) => top.clamp(0.0, maxBottom - height);
}
