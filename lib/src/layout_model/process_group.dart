import 'component.dart';
import 'property.dart';
import 'style.dart';

class ProcessGroup extends LayoutComponent {
  ProcessGroup(String name) : super('processGroup', name) {
    properties['processType'] = Property(
      'process type',
      'parallelly',
      type: String,
    );
    properties['style'] = Property('style', Style.basic, type: Style);
  }
}
