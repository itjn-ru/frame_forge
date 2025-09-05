import 'package:flutter/widgets.dart';
import 'source.dart';
import 'source_table.dart';
import 'source_table_widget.dart';
import 'source_variable.dart';
import 'source_variable_widget.dart';

class SourceWidget extends StatelessWidget {
  final LayoutSource source;

  const SourceWidget(this.source, {super.key});

  factory SourceWidget.create(LayoutSource source) {
    switch (source.runtimeType) {
      case SourceVariable _:
        return SourceVariableWidget(source as SourceVariable);
      case SourceTable _:
        return SourceTableWidget(source as SourceTable);

      default:
        return SourceWidget(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: buildWidget(context));
  }

  Widget buildWidget(BuildContext context) {
    return Text(source.type);
  }
}
