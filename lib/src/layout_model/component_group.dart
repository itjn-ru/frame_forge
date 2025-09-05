import 'component.dart';
import 'custom_border_radius.dart';
import 'property.dart';
import 'style.dart';

class ComponentGroup extends LayoutComponent {
  ComponentGroup(name) : super("group", name) {
    properties["style"] = Property("стиль", Style.basic, type: Style);
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
