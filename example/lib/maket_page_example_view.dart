import 'package:flutter/material.dart';
import 'package:frame_forge/frame_forge.dart';

class MaketPageExampleView extends StatelessWidget {
  final ScreenSizeEnum screenSize;
  final LayoutModelController controller;
  const MaketPageExampleView(this.controller, this.screenSize, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ComponentsAndSources(
            constraints,
            controller: controller,
            screenSize: screenSize,
          );
        },
      ),
    );
  }
}
