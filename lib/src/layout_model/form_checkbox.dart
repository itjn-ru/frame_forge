import 'component.dart';
import 'property.dart';
import 'source_reference.dart';
import 'style.dart';

class FormCheckbox extends LayoutComponent {
  FormCheckbox(String name) : super('checkbox', name) {
    properties['text'] = Property('text', '');
    properties['source'] =
        Property('source', SourceReference(), type: SourceReference);
    properties['caption'] = Property('caption', '');
    properties['style'] = Property('style', Style.basic, type: Style);
  }
}
