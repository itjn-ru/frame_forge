import 'component.dart';
import 'property.dart';
import 'style.dart';


class FormCheckbox extends LayoutComponent {
  FormCheckbox(name) : super("checkbox", name) {
    properties["text"] = Property("текст", "");
    properties["source"] = Property("источник", "");
    properties["caption"] = Property("подпись", "");
    properties["style"] = Property("стиль", Style.basic, type: Style);
  }



}
