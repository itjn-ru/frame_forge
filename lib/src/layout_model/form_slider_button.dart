import 'component.dart';
import 'property.dart';


class FormSliderButton extends LayoutComponent {
  FormSliderButton(name) : super("sliderButton", name) {
    properties["text"] = Property("текст", "");
    properties["source"] = Property("источник", "");
  }
}