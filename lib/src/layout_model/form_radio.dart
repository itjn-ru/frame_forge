import 'component.dart';
import 'property.dart';
import 'source_reference.dart';

class FormRadio extends LayoutComponent {
  FormRadio(String name) : super('radio', name) {
    properties['text'] = Property('text', '');
    properties['source'] =
        Property('source', SourceReference(), type: SourceReference);
  }
}
