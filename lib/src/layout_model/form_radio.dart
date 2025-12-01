import 'component.dart';
import 'property.dart';

class FormRadio extends LayoutComponent {
  FormRadio(String name) : super('radio', name) {
    properties['text'] = Property('text', '');
    properties['source'] = Property('source', '');
  }
}
