
import 'package:flutter/material.dart';
import 'component_and_source.dart';
import 'constants.dart';

class LayoutStyle extends LayoutComponentAndSource {
  LayoutStyle(super.type, super.name);
}

class Style {
  String id;
  String name;

  static Style basic = Style(UuidNil, 'базовый стиль');

  Style(this.id, this.name);

  @override
  bool operator ==(Object other) => other is Style && id == other.id;

  @override
  int get hashCode => Object.hash(id, name);
}

class CustomBorderStyle {
  double width;
  Color color;
  CustomBorderSide side;

  BorderSide get value =>  BorderSide(width: width, color: color, style: side.borderStyle
      );

  static CustomBorderStyle basic =
      CustomBorderStyle(1.0, Colors.black, CustomBorderSide.solid);

  factory CustomBorderStyle.init() {
    return CustomBorderStyle(0.0, Colors.transparent, CustomBorderSide.none);
  }

  CustomBorderStyle(this.width, this.color, this.side);

  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'color': color.value.toRadixString(16).toUpperCase(),
      'side': side,
    };
  }
      

  factory CustomBorderStyle.fromMap(Map<String, dynamic> map) {
    return CustomBorderStyle(
      double.parse(map['width']),
      Color(int.tryParse(map['color'], radix: 16) ?? 0),
      CustomBorderSide.values.firstWhere((e) => e.toString() == map['side'],
          orElse: () => CustomBorderSide.none),
    );
  }
}

enum CustomBorderSide {
  none('Нет'),
  solid('Сплошная'),
  dash('Тире'),
  dot('Точка');

  final String title;

  const CustomBorderSide(this.title);

  CustomBorderSide side(String value) {
    return CustomBorderSide.values
        .firstWhere((e) => e.toString() == value.split('.').last);
  }

  BorderStyle  get borderStyle {

    switch (this) {
      case CustomBorderSide.none:
        return BorderStyle.none;
      case CustomBorderSide.solid:
        return BorderStyle.solid;
      case CustomBorderSide.dash:
        return BorderStyle.solid;
      case CustomBorderSide.dot:
        return BorderStyle.solid;
    }
  }
}
