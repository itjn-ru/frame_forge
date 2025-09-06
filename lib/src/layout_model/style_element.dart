import 'package:frame_forge/src/layout_model/custom_margin.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/material.dart';
import 'custom_border_radius.dart';
import 'property.dart';
import 'style.dart';

class StyleElement extends LayoutStyle {
  StyleElement(name) : super("styleElement", name) {
    if (kDebugMode) {
      properties['id'] = Property(
        "идентификатор",
        const Uuid().v4(),
        type: String,
      );
    }
    properties['color'] = Property("цвет", Colors.black, type: Color);
    properties['backgroundColor'] = Property(
      "цвет фона",
      Colors.transparent,
      type: Color,
    );
    properties['alignment'] = Property(
      "выравнивание",
      Alignment.centerLeft,
      type: Alignment,
    );
    properties['fontSize'] = Property("размер шрифта", 11, type: double);
    properties['fontWeight'] = Property(
      "насыщенность шрифта",
      FontWeight.normal,
      type: FontWeight,
    );

    properties['borderRadius'] = Property(
      'закругление',
      BorderRadiusNone.fromJson({'borderRadius': 'BorderRadiusNone'}),
      type: CustomBorderRadius,
    );
    properties['padding'] = Property('отступ', [0, 0, 0, 0], type: List<int>);
    properties['margin'] = Property('Внешний отступ', [
      0,
      0,
      0,
      0,
    ], type: CustomMargin);
    properties["topBorder"] = Property(
      "верхняя граница",
      CustomBorderStyle.init(),
      type: CustomBorderStyle,
    );
    properties["bottomBorder"] = Property(
      "нижняя граница",
      CustomBorderStyle.init(),
      type: CustomBorderStyle,
    );
    properties["leftBorder"] = Property(
      "левая граница",
      CustomBorderStyle.init(),
      type: CustomBorderStyle,
    );
    properties["rightBorder"] = Property(
      "правая граница",
      CustomBorderStyle.init(),
      type: CustomBorderStyle,
    );
    properties["borderRadius"] = Property(
      "радиус",
      BorderRadiusNone,
      type: CustomBorderRadius,
    );
  }
}
