import 'component.dart';
import 'property.dart';
import 'package:uuid/uuid.dart';

class FormHiddenField extends LayoutComponent {
  FormHiddenField(String name) : super("hiddenField", name) {
    properties["caption"] = Property("caption", "");
    properties["id"] = Property("id", const Uuid().v4, type: String);
    properties["source"] = Property("source", "");
  }
}
