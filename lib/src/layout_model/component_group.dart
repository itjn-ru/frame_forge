import 'component.dart';
import 'property.dart';
import 'style.dart';

class ComponentGroup extends LayoutComponent {
  ComponentGroup(String name) : super('group', name) {
    properties['style'] = Property('style', Style.basic, type: Style);
    properties['source'] = Property('источник', '');
  }
}
