import 'package:flutter/material.dart';
import 'controller/layout_model_controller.dart';
import 'property_widget.dart';

// class Properties extends StatefulWidget {
//   //final Map<String, Property> _properties;
//   final LayoutModelController controller;

//   const Properties(this.controller, {super.key});

//   @override
//   State<StatefulWidget> createState() {
//     return PropertiesState();
//   }
// }

// class PropertiesState extends State<Properties> {
//   bool dragging = false;
// late Map<String, Property> _properties;
//  @override
//   void initState() {
//    _properties=widget.controller.layoutModel.curItem.properties;
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//    // var keys = widget.layoutModel.curItem.properties.keys;
//     _properties=widget.controller.layoutModel.curItem.properties;
//    var keys = _properties.keys;

//     return Table(
//       columnWidths: const {0: FixedColumnWidth(50), 1: FixedColumnWidth(100)},
//       children: List.generate(
//         keys.length,
//         (index) => TableRow(
//             decoration: BoxDecoration(
//                 color: dragging ? Colors.greenAccent : Colors.transparent,
//                 border: const Border(
//                     bottom: BorderSide(color: Colors.black, width: 1))),
//             children: [
//               Text(
//                   "${_properties[keys.elementAt(index)]?.title ?? ""}:"),
//                 PropertyWidget.create(
//                     widget.controller,keys.elementAt(index)),
//                     //_properties[keys.elementAt(index)]!,widget.controller),
//             ]),
//       ),
//     );
//   }
// }
class Properties extends StatelessWidget {
  final LayoutModelController controller;

  const Properties(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: controller.selectedIdNotifier,
      builder: (context, selectedId, _) {
        final curItem = controller.getItemById(selectedId);
        if (curItem == null) {
          return const Center(child: Text("Ничего не выбрано"));
        }

        return ValueListenableBuilder<Map<String, dynamic>>(
          valueListenable: controller.propertiesNotifier,
          builder: (context, properties, _) {
            final keys = properties.keys.toList();

            return Table(
              columnWidths: const {
                0: FixedColumnWidth(50),
                1: FixedColumnWidth(100),
              },
              children: List.generate(keys.length, (index) {
                final key = keys[index];
                final prop = properties[key];

                return TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  children: [
                    Text("${prop?.title ?? ""}:"),
                    PropertyWidget.create(controller, key),
                  ],
                );
              }),
            );
          },
        );
      },
    );
  }
}
