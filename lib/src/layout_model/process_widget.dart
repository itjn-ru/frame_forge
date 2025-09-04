import 'package:flutter/widgets.dart';

import 'process.dart';
import 'process_element.dart';
import 'process_element_widget.dart';

class ProcessWidget extends StatelessWidget {
  final LayoutProcess process;

  const ProcessWidget(this.process, {super.key});

  factory ProcessWidget.create(LayoutProcess process) {
    switch (process.runtimeType) {
      case const (ProcessElement):
        return ProcessElementWidget(process as ProcessElement);

      default:
        return ProcessElementWidget(process);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildWidget(context),
    );
  }

  Widget buildWidget(BuildContext context) {
    return Text(process.type);
  }

}
