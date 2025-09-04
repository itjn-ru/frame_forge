// import 'package:flutter/material.dart';

// import '../di/item_inherited_model.dart';
// import 'controller/events.dart';
// import 'controller/layout_model_controller.dart';
// import 'item.dart';
// import 'property.dart';

// class ItemListWrapper extends StatefulWidget {
//   final List<Item> initialItems;
//   final LayoutModelController controller;
//   const ItemListWrapper({required this.initialItems, required this.controller});

//   @override
//   State<ItemListWrapper> createState() => _ItemListWrapperState();
// }

// class _ItemListWrapperState extends State<ItemListWrapper> {
//   late Map<String, Item> itemsMap;

//   @override
//   void initState() {
//     super.initState();
//     itemsMap = {
//       for (var item in widget.initialItems) item.id: item,
//     };
//     widget.controller.eventBus.events.listen((event) {
//       if (event is ChangeItem) {
//         setState(() {
//           final old = itemsMap[event.itemId];
//           if (old != null) {
//             final updated = old.copyWith(properties: {
//               ...old.properties,
//               ...event.updatedValues.map((k, v) => MapEntry(k, Property(k, v))),
//             });
//             itemsMap[event.itemId] = updated;
//           }
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ItemInheritedModel(
//       items: itemsMap,
//       child: ListView.builder(
//         itemCount: itemsMap.length,
//         itemBuilder: (_, index) {
//           final id = itemsMap.keys.elementAt(index);
//           return Item(itemId: id);
//         },
//       ),
//     );
//   }
// }
