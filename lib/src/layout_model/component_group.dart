import 'component.dart';
import 'property.dart';
import 'source_reference.dart';
import 'style.dart';

class ComponentGroup extends LayoutComponent {
  ComponentGroup(String name) : super('group', name) {
    properties['style'] = Property('style', Style.basic, type: Style);
    properties['source'] = Property('source', '');
    properties['sourceV2'] = Property('source', SourceReference(), type: SourceReference);
  }
}
