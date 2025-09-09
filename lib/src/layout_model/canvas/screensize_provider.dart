import '../screen_size_enum.dart';
import 'package:flutter/material.dart';

class ScreenSizeProvider extends InheritedWidget {
  final ScreenSizeEnum screenSize;

  const ScreenSizeProvider({
    super.key,
    required this.screenSize,
    required super.child,
  });

  static ScreenSizeEnum of(BuildContext context) {
    final ScreenSizeProvider? provider = context
        .dependOnInheritedWidgetOfExactType<ScreenSizeProvider>();
    assert(provider != null, 'No ScreenSizeProvider found in context');
    return provider!.screenSize;
  }

  @override
  bool updateShouldNotify(covariant ScreenSizeProvider oldWidget) {
    return screenSize != oldWidget.screenSize;
  }
}
