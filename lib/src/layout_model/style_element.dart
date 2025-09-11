import 'package:frame_forge/src/layout_model/custom_margin.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/material.dart';
import 'custom_border_radius.dart';
import 'property.dart';
import 'style.dart';

class StyleElement extends LayoutStyle {
  StyleElement(String name) : super("styleElement", name) {
    if (kDebugMode) {
      properties['id'] = Property(
        "Id",
        const Uuid().v4(),
        type: String,
      );
    }
    properties['color'] = Property("Color", Colors.black, type: Color);
    properties['backgroundColor'] = Property(
      "Background Color",
      Colors.transparent,
      type: Color,
    );
    properties['alignment'] = Property(
      "Alignment",
      Alignment.centerLeft,
      type: Alignment,
    );
    properties['fontSize'] = Property("Font Size", 11, type: double);
    properties['fontWeight'] = Property(
      "Font Weight",
      FontWeight.normal,
      type: FontWeight,
    );

    properties['borderRadius'] = Property(
      'Border Radius',
      const BorderRadiusNone(),
      type: CustomBorderRadius,
    );
    properties['padding'] = Property('Padding', [0, 0, 0, 0], type: List<int>);
    properties['margin'] = Property('Margin', [
      0,
      0,
      0,
      0,
    ], type: CustomMargin);
    properties["topBorder"] = Property(
      "Top Border",
      CustomBorderStyle.init(),
      type: CustomBorderStyle,
    );
    properties["bottomBorder"] = Property(
      "Bottom Border",
      CustomBorderStyle.init(),
      type: CustomBorderStyle,
    );
    properties["leftBorder"] = Property(
      "Left Border",
      CustomBorderStyle.init(),
      type: CustomBorderStyle,
    );
    properties["rightBorder"] = Property(
      "Right Border",
      CustomBorderStyle.init(),
      type: CustomBorderStyle,
    );
  // removed duplicate borderRadius property that mistakenly stored a Type
  }
}
