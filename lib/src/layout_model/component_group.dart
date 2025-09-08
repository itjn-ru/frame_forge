import 'component.dart';
import 'property.dart';
import 'style.dart';

class ComponentGroup extends LayoutComponent {
  ComponentGroup(name) : super("group", name) {
    properties["style"] = Property("стиль", Style.basic, type: Style);
  }
}
