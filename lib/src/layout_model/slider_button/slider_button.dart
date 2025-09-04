import 'package:flutter/material.dart';
import 'animated_toggle_switch.dart';
import 'properties.dart';

class SliderButton extends StatefulWidget {
  final double height;
  final double width;
  final int? value;
  final List<String>? activeText;
  final List<String>? inactiveText;

  const SliderButton({
    super.key,
    required this.width,
    required this.height,
    this.activeText = const ['В наличии', 'Исправно', 'Неисправно'],
    this.inactiveText = const ['Нет в наличи', 'Исправно', 'Неисправно'],
    this.value = 1,
  });

  @override
  State<SliderButton> createState() => _SliderButtonState();
}

class _SliderButtonState extends State<SliderButton> {
  int? value;
  final Color badColor = Colors.red;
  final Color goodColor = Colors.green;
  late Color indicatorColor;
  Color textColor = Colors.white;
  List<String> switcherText = [];
  bool available = true;
  late Color firstTabBackgroundColor;

  @override
  void initState() {
    switcherText = widget.activeText!;
    value = widget.value;
    firstTabBackgroundColor = goodColor;
    indicatorColor = Colors.green;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedToggleSwitch<int?>.size(
      allowUnlistedValues: true,
      onTap: (TapProperties<int?> prop) {
        if (prop.tapped?.value == 0 && available) {
          switcherText = widget.inactiveText!;
          firstTabBackgroundColor = badColor;
          value = null;
          available = !available;
          setState(() {});
        } else if (!available && prop.tapped?.value != 0) {
          switcherText = widget.activeText!;
          firstTabBackgroundColor = goodColor;
          available = !available;
          setState(() {});
        }
      },
      height: widget.height,
      animationDuration: const Duration(milliseconds: 200),
      current: value,
      foregroundIndicatorIconBuilder:
          (BuildContext contex, DetailedGlobalToggleProperties<int?> global) {
        double pos = global.position;
        double transitionValue = pos - pos.floorToDouble();
        final text = switcherText[pos.floor()];
        return Stack(children: [
          Opacity(
            opacity: 1 - transitionValue,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: pos.floor()==1? goodColor : badColor,
              ),
              child: Center(
                  child: Text(text, style: const TextStyle(color: Colors.white))),
            ),
          ),
          Opacity(
            opacity: transitionValue,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: pos.ceil()==1? goodColor : badColor,
              ),
              child: Center(
                  child: Text(switcherText[pos.ceil()],
                      style: const TextStyle(color: Colors.white))),
            ),
          )
        ]);
      },
      style: ToggleStyle(
        backgroundColor: const Color(0xFF919191),
        // indicatorColor: indicatorColor,
        borderColor: Colors.transparent,
        borderRadius: BorderRadius.circular(20.0),
        indicatorBorderRadius: BorderRadius.zero,
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      values: const [0, 1, 2],
      iconOpacity: 1.0,
      selectedIconScale: 1.0,
      //indicatorSize: Size.fromWidth(widget.width/3-1),
      spacing: 1.0,
      customSeparatorBuilder: (context, local, global) {
        return const VerticalDivider(
            indent: 7.0,
            endIndent: 7.0,
            color: Colors.white38);
      },
      customIconBuilder: (context, local, global) {
        final text = switcherText[local.index];
        return local.index == 0
            ? DecoratedBox(
          decoration: BoxDecoration(
            color: firstTabBackgroundColor,
          ),
          child: Center(
              child: Text(text,
                  style: TextStyle(
                      color: Color.lerp(Colors.white, Colors.white,
                          local.animationValue)))),
        )
            : Center(
            child: Text(text,
                style: TextStyle(
                    color: Color.lerp(Colors.black, Colors.white,
                        local.animationValue))));
      },
      borderWidth: 1.0,
      onChanged: (i) {
        switch (i) {
          case(0):
            firstTabBackgroundColor = badColor;
            switcherText = widget.inactiveText!;
          case (1):
          case (2):
            firstTabBackgroundColor = goodColor;
            available = !available;
            switcherText = widget.activeText!;
            break;
        }
        setState(() => value = i);
      },
    );
  }
}