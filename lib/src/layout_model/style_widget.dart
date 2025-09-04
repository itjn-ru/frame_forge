import 'package:flutter/widgets.dart';
import 'style.dart';
import 'style_element.dart';
import 'style_element_widget.dart';


class StyleWidget extends StatelessWidget {
  final LayoutStyle style;

  const StyleWidget(this.style, {super.key});

  factory StyleWidget.create(LayoutStyle style) {
    switch (style.runtimeType) {
      case const (StyleElement):
        return StyleElementWidget(style as StyleElement);

      default:
        return StyleElementWidget(style);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildWidget(context),
    );
  }

  Widget buildWidget(BuildContext context) {
    return Text(style.type);
  }
  
}
