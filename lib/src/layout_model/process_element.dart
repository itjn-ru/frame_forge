import 'process.dart';
import 'property.dart';

class ProcessElement extends LayoutProcess {
  ProcessElement(String name) : super('processElement', name) {
    properties['statusId'] = Property(
      'Status Id',
      'created',
      type: String,
    );
    properties['title'] = Property('title', '', type: String);
    properties['creatorTitle'] = Property('Creator Title', '', type: String);
  }
}
