import 'dart:math';

import 'package:flutter/material.dart';

const List<Color> _defaultColors = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
  Colors.black,
  Color(0xffF2F5F7),
  Color(0xFF416AF0),
  Colors.white,
];

class BlockPicker extends StatefulWidget {
  const BlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
    this.availableColors = _defaultColors,
    this.useInShowDialog = true,
  });

  final Color? pickerColor;
  final ValueChanged<Color> onColorChanged;
  final List<Color> availableColors;
  final bool useInShowDialog;

  @override
  State<StatefulWidget> createState() => _BlockPickerState();
}

class _BlockPickerState extends State<BlockPicker> {
  Color? _currentColor;
  final TextEditingController controller = TextEditingController();
  @override
  void initState() {
    _currentColor = widget.pickerColor;
    super.initState();
  }

  void changeColor(Color color) {
    setState(() => _currentColor = color);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return SizedBox(
      width: 310,
      child: Column(
        children: [
          SizedBox(
            height: orientation == Orientation.portrait ? 360 : 200,
            child: GridView.count(
              crossAxisCount: orientation == Orientation.portrait ? 4 : 6,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              children: [
                for (Color color in widget.availableColors)
                  Container(
                    margin: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(80),
                          offset: const Offset(1, 2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => changeColor(color),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Цвет: '),
              SizedBox.fromSize(
                size: const Size(60, 60),
                child: DecoratedBox(
                  decoration: BoxDecoration(color: _currentColor),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                const Text('HEX формат'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 5),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.check),
                        onPressed: () => setState(() {
                          _currentColor = Color(
                            int.tryParse(controller.text.trim(), radix: 16) ??
                                0,
                          );
                        }),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      hintText: 'FFFFFFFF',
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _currentColor != null
                ? () => widget.onColorChanged(_currentColor!)
                : null,
            child: const Text('Выбрать'),
          ),
        ],
      ),
    );
  }

  bool useWhiteForeground(Color backgroundColor, {double bias = 0.0}) {
    int v = sqrt(
      pow(backgroundColor.r, 2) * 0.299 +
          pow(backgroundColor.g, 2) * 0.587 +
          pow(backgroundColor.b, 2) * 0.114,
    ).round();
    return v < 130 + bias ? true : false;
  }
}
