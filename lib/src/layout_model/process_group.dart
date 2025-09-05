import 'component.dart';
import 'property.dart';
import 'style.dart';

class ProcessGroup extends LayoutComponent {
  ProcessGroup(name) : super("processGroup", name) {
    properties["processType"] = Property(
      "тип процесса",
      'параллельно',
      type: String,
    );
    properties["style"] = Property("стиль", Style.basic, type: Style);
  }
}
