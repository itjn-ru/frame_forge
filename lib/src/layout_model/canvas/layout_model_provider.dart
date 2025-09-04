import 'package:flutter/material.dart';

import '../controller/layout_model_controller.dart';

class LayoutModelControllerProvider extends InheritedWidget {
  final LayoutModelController controller;

  const LayoutModelControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  static LayoutModelController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<LayoutModelControllerProvider>();
    assert(provider != null, 'No LayoutModelControllerProvider found in context');
    return provider!.controller;
  }

  @override
  bool updateShouldNotify(covariant LayoutModelControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}