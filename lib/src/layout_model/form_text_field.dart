import 'component.dart';
import 'property.dart';

class FormTextField extends LayoutComponent {
  FormTextField(name) : super("textField", name) {
    properties["text"] = Property("текст", "");
    properties["text_button"] = Property("текст кнопки", "");
    properties["caption"] = Property("подпись", "");
    properties["source"] = Property("источник", "");
  }
}
