import 'process.dart';
import 'process_status_id_enum.dart';
import 'property.dart';

class ProcessElement extends LayoutProcess {
  ProcessElement(name) : super("processElement", name) {
    properties['statusId'] =
    Property("Status Id", ProcessStatusIdEnum.created.value, type: String);
    properties['title'] = Property("title", '', type: String);
    properties['creatorTitle'] = Property("Creator Title", '', type: String);
  }

}