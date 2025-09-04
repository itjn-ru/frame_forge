import 'package:flutter/material.dart';
import 'canvas/layout_model_provider.dart';
import 'canvas/screensize_provider.dart';
import 'component_widget.dart';
import 'style_element.dart';

class ComponentTextWidget extends ComponentWidget {
  const ComponentTextWidget(
      {required super.component, super.key});

  @override
  Widget buildWidget(BuildContext context) {
    // String text="";
    // final subscription = controller.eventBus.events.listen((event) {
    //   if (event is ChangeItem && event.itemId == component.id) {
    //         text = component["text"] ?? component["source"] ?? "";
    //     text += component["source"] ?? "";

    //   }
    // });
    final screenSize = ScreenSizeProvider.of(context);
    String text = component["text"] ?? component["source"] ?? "";
    text += component["source"] ?? "";
    final controller = LayoutModelControllerProvider.of(context);
    final layoutModel = controller.layoutModel;
    var style = layoutModel.getStyleElementById(component['style'].id) ??
        StyleElement("стиль");
    final border = style['borderRadius'];
    final TextStyle textStyle = TextStyle(
      color: style['color'],
      fontSize: style['fontSize'],
      fontWeight: style['fontWeight'],
    );
    final padding = style['padding'] ?? [0, 0, 0, 0];
    return LayoutBuilder(builder: (context, constraints) {
      final scale = screenSize.width / constraints.maxWidth;
      return Container(
        decoration: BoxDecoration(
          color: style['backgroundColor'],
          borderRadius: border?.borderRadius(scale),
        ),
        padding: EdgeInsets.fromLTRB(padding[0] / scale, padding[1] / scale,
            padding[2] / scale, padding[3] / scale),
        alignment: component['alignment'],
        child: Text(
          text,
          style: textStyle,
        ),
      );
    });
  }
}

// class ComponentTextWidget extends StatelessWidget {
//   const ComponentTextWidget(
//       {required this.component,
//       required this.controller,
//       super.key,
//       this.screenSize});
// final LayoutComponent component;
//   final LayoutModelController controller;
//   final ScreenSizeEnum? screenSize;

//  @override
//   Widget build(BuildContext context) {
//     // String text="";
//     // final subscription = controller.eventBus.events.listen((event) {
//     //   if (event is ChangeItem && event.itemId == component.id) {
//     //         text = component["text"] ?? component["source"] ?? "";
//     //     text += component["source"] ?? "";
        
//     //   }
//     // });
//     String text = component["text"] ?? component["source"] ?? "";
//     text += component["source"] ?? "";
//     final layoutModel = LayoutModelProvider.of(context);
//     // final layoutModel = controller.layoutModel;
//     var style = layoutModel.getStyleElementById(component['style'].id) ??
//         StyleElement("стиль");
//     final border = style['borderRadius'];
//     final TextStyle textStyle = TextStyle(
//       color: style['color'],
//       fontSize: style['fontSize'],
//       fontWeight: style['fontWeight'],
//     );
//     final padding = style['padding'] ?? [0, 0, 0, 0];
//     return LayoutBuilder(builder: (context, constraints) {
//       final scale = ScreenSizeEnum.mobile.width / constraints.maxWidth;
//         return Container(
//           decoration: BoxDecoration(
//             color: style['backgroundColor'],
//             borderRadius: border?.borderRadius(scale),
//           ),
//           padding:
//               EdgeInsets.fromLTRB(padding[0]/scale, padding[1]/scale, padding[2]/scale, padding[3]/scale),
//           alignment: component['alignment'],
//           child: Text(
//             text,
//             style: textStyle,
//           ),
//         );
//       }
//     );
//   }
// }