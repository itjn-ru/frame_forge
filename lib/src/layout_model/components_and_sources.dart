import 'package:frame_forge/src/layout_model/canvas/screensize_provider.dart';

import '../../frame_forge.dart';
import 'canvas/layout_model_provider.dart';
import 'canvas/main_canvas.dart';
import 'package:flutter/material.dart';
import 'style_widget.dart';

class ComponentsAndSources extends StatelessWidget {
  final BoxConstraints constraints;
  final LayoutModelController controller;
  final ScreenSizeEnum screenSize;
  const ComponentsAndSources(
    this.constraints, {
    super.key,
    required this.controller,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenSizeProvider(
      screenSize: screenSize,
      child: LayoutModelControllerProvider(
        controller: controller,
        child: Builder(
          builder: (context) {
            final ComponentAndSourcePage curPage =
                controller.layoutModel.getCurPage;
            if (curPage is StylePage) {
              return Column(
                children: List.generate(
                  curPage.items.length, //widget._items.length,
                  (index) =>
                      StyleWidget.create(curPage.items[index] as LayoutStyle),
                ),
              );
            } else if (curPage is ComponentPage) {
              return curPage.items.isNotEmpty
                  ? MainCanvas(constraints: constraints)
                  : Container();
            } else {
              return ProcessItems(
                controller.layoutModel.root.items
                    .whereType<ProcessPage>()
                    .first,
                controller,
              );
            }
          },
        ),
      ),
    );
  }
}
