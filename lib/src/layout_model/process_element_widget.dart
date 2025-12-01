import 'package:flutter/widgets.dart';

import 'process_widget.dart';

class ProcessElementWidget extends ProcessWidget {
  const ProcessElementWidget(super.process, {super.key});

  @override
  Widget buildWidget(BuildContext context) {
    final String cellText = process['name'] ?? '';

    return Text(cellText);
  }
}
