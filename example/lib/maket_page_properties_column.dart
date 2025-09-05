import 'package:flutter/material.dart';
import 'package:frame_forge/frame_forge.dart';

class MaketPagePropertiesColumn extends StatelessWidget {
  final LayoutModelController controller;

  const MaketPagePropertiesColumn(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(
            height: 25,
            child: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text('cвойства'),
            ),
          ),
          Expanded(child: ListView(children: [Properties(controller)])),
        ],
      ),
    );
  }
}
