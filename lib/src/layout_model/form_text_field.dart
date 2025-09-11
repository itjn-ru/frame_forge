import 'component.dart';
import 'property.dart';

class FormTextField extends LayoutComponent {
  FormTextField(String name) : super("textField", name) {
    properties["text"] = Property("text", "");
    properties["caption"] = Property("caption", "");
    properties["source"] = Property("source", "");
  }
}
