import 'package:frame_forge/src/expandble_widget/expandble_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../expandble_widget/expandble_widget_content.dart';
import '../expandble_widget/expandble_widget_controller.dart';
import '../canvas/layout_model_provider.dart';
import 'component.dart';
import 'component_group.dart';
import 'component_widget.dart';
import 'controller/events.dart';
import 'controller/layout_model_controller.dart';
import 'layout_model.dart';
import 'style_element.dart';

class FormExpandbleListWidget extends ComponentWidget {
  final double scaleFactor;
  const FormExpandbleListWidget({
    required super.component,
    required this.scaleFactor,
    super.key,
  });

  @override
  Widget buildWidget(BuildContext context) {
    return ExpandbleComponent(component: component, scale: scaleFactor);
  }
}

class ExpandbleComponent extends StatefulWidget {
  final LayoutComponent component;
  final double scale;
  const ExpandbleComponent({
    super.key,
    required this.component,
    required this.scale,
  });
  @override
  State<ExpandbleComponent> createState() => _ExpandbleComponentState();
}

class _ExpandbleComponentState extends State<ExpandbleComponent> {
  final ExpandableController controller = ExpandableControllerImpl();
  double? expandedHeight;
  late final Size size = widget.component['size'] ?? const Size(360, 30);

  final NumberFormat numberFormat = NumberFormat(',##0.00', 'ru_RU');

  late final LayoutModelController modelController = LayoutModelControllerProvider.of(context);
  late final LayoutModel layoutModel = modelController.layoutModel;
  late StyleElement style =
      layoutModel.getStyleElementById(widget.component['style'].id) ??
      StyleElement("style");
  late final  border = style['borderRadius'];
  late final List<Widget> items = List<Widget>.generate(
    widget.component.items.length - 1,
    (int index) => SizedBox(
      height: widget.component.items[index + 1]['size'].height,
      child: ComponentWidget(
        component: widget.component.items[index + 1] as LayoutComponent,
      ),
    ),
  );
  late final ComponentGroup header = widget.component.items.whereType<ComponentGroup>().first;
  late final StyleElement headerStyle =
      layoutModel.getStyleElementById(header['style'].id) ??
      StyleElement("style");
  late final TextStyle textStyle = TextStyle(
    color: style['color'],
    fontSize: style['fontSize'],
    fontWeight: style['fontWeight'],
  );

  @override
  void initState() {
    if (widget.component.properties['expandble']?.value) {
      controller.expand();
    } else {
      controller.collapse();
    }
    super.initState();

    controller.stateChanges.listen((value) {
      if (expandedHeight != null && value && size.height != expandedHeight) {
        widget.component.properties['expandble']?.value = value;
        widget.component.properties['expandedSize']?.value = size;
        widget.component.properties['size']?.value = Size(
          size.width,
          expandedHeight!,
        );
        modelController.eventBus.emit(
          ChangeItem(id: const Uuid().v4(), itemId: layoutModel.curItem.id),
        );
      } else if (expandedHeight != null) {
        widget.component.properties['expandble']?.value = value;
        final Size? collapsedSize =
            widget.component.properties['expandedSize']?.value;
        widget.component.properties['expandedSize']?.value = size;
        widget.component.properties['size']?.value = collapsedSize;
        modelController.eventBus.emit(
          ChangeItem(id: const Uuid().v4(), itemId: layoutModel.curItem.id),
        );
      }
    });
    controller.heightChanges.listen((height) {
      if (height != null && height != expandedHeight) {
        setState(() => expandedHeight = height);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpandableWidget(
          style: ExpandableStyle(
            marginTop: style['margin'][1],
            contentDecoration: BoxDecoration(
              color: style['backgroundColor'],
              borderRadius: border?.borderRadius(widget.scale),
            ),
            title: ComponentWidget.create(
              header as LayoutComponent,
              scaleFactor: widget.scale,
            ),
            buttonIconColor: headerStyle['color'],
            buttonBorderRadius: headerStyle['borderRadius']?.borderRadius(
              widget.scale,
            ),
            buttonColor: style['backgroundColor'],
          ),
          controller: controller,
          child: Column(children: items),
        ),
      ],
    );
  }
}
