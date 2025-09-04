import 'component.dart';
import 'property.dart';


class FormRadio extends LayoutComponent {
  FormRadio(name) : super("radio", name) {
    properties["text"] = Property("текст", "");
    properties["source"] = Property("источник", "");
  }



}