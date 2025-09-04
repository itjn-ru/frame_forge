import 'dart:math';

import 'component.dart';
import 'style_element.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'component_widget.dart';

class FormTextFieldWidget extends ComponentWidget {
  const FormTextFieldWidget({required super.component, super.key});

  @override
  Widget buildWidget(BuildContext context) {
    if (component['style']?.name == 'counter') {
      return CounterWidget(component: component);
    } else if (component['style']?.name == 'dropdownmenu') {
      return DropDownWidget(component: component);
    }
    return TextFieldPropertie(component: component);
  }
}

class TextFieldPropertie extends StatefulWidget {
  final LayoutComponent component;

  const TextFieldPropertie({super.key, required this.component});

  @override
  State<TextFieldPropertie> createState() => _TextFieldPropertieState();
}

class _TextFieldPropertieState extends State<TextFieldPropertie> {
  TextEditingController textControllers = TextEditingController();
  late StyleElement style;
  late final bool isTime;
  TimeOfDay selectedTime24Hour = TimeOfDay.now();
  late final bool isDate;
  List<String> parts = [];

  @override
  void initState() {
    isDate = widget.component['style']?.name == 'дата';
    isTime = widget.component['style']?.name == 'время';
    textControllers.text = '';
    style = StyleElement('стиль');
    super.initState();
  }

  @override
  void dispose() {
    textControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.component['size']?.height + 5,
      child: Stack(
        children: [
          Row(
            children: [
              if (widget.component['text'] != '')
                SizedBox(
                  width: 40,
                  child: Text(
                    widget.component['text'],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              Expanded(
                child: TextField(
                  maxLines: null,
                  expands: true,
                  readOnly: true,
                  controller: textControllers,
                  onTap: null,
                  onChanged: null,
                  decoration: InputDecoration(
                    isDense: true,
                    label: Text(
                      widget.component['caption'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).inputDecorationTheme.hoverColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(decoration: const BoxDecoration(color: Colors.transparent)),
        ],
      ),
    );
  }

  onTapDateFunction() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime(2040),
      firstDate: DateTime(2020),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    textControllers.text = DateFormat('dd MMMM yyyy', 'ru').format(pickedDate);
  }

  onTapTimeFunction() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: Duration(
              hours: int.tryParse(parts[0]) ?? 0,
              minutes: int.tryParse(parts[1]) ?? 0,
            ),
            //Duration(hours: selectedTime24Hour.hour, minutes: selectedTime24Hour.minute),
            // This is called when the user changes the timer's
            // duration.
            onTimerDurationChanged: (Duration newDuration) {},
          ),
        );
      },
    );
  }
}

class DropDownWidget extends StatefulWidget {
  final LayoutComponent component;

  const DropDownWidget({super.key, required this.component});

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  String selectedItem = '';
  late List<String> menuItems;
  late StyleElement style;

  @override
  void initState() {
    menuItems = widget.component['caption'].split(',');
    menuItems.map((e) => e.trim());
    selectedItem = menuItems.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedItem,
      //width: constraints.maxWidth,
      onChanged: (value) {
        setState(() {
          selectedItem = value!;
        });
      },
      items: menuItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key, required this.component});

  final LayoutComponent component;

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int selectedQuantitie = 1;
  late StyleElement style;
  bool readOnly = false;

  void _incrementCounter() {
    setState(() {
      selectedQuantitie += 1;
    });
  }

  void _decrementCounter() {
    setState(() {
      selectedQuantitie = max(selectedQuantitie -= 1, 0);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    style = StyleElement('стиль');

    final double fontSizeText =
        Theme.of(context).textTheme.titleSmall?.fontSize ??
        style['fontSize'].toDouble();
    final double fontSizeButton =
        Theme.of(context).textTheme.titleMedium?.fontSize ??
        style['fontSize'].toDouble();
    return SizedBox(
      height: widget.component["size"].height ?? 30,
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).disabledColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _createIncrementDicrementButton(
              Icons.remove,
              () => readOnly ? null : _decrementCounter(),
              fontSizeButton,
            ),
            SizedBox(
              width: widget.component["size"].height,
              child: Center(
                child: Text(
                  '$selectedQuantitie',
                  style: TextStyle(
                    fontSize: fontSizeButton,
                    color: Theme.of(context).tabBarTheme.indicatorColor,
                  ),
                ),
              ),
            ),
            _createIncrementDicrementButton(
              Icons.add,
              () => readOnly ? null : _incrementCounter(),
              fontSizeButton,
            ),
          ],
        ),
      ),
    );
  }

  Widget _createIncrementDicrementButton(
    IconData icon,
    VoidCallback onPressed,
    double fontSizeButton,
  ) {
    return RawMaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      constraints: BoxConstraints(
        minWidth: widget.component["size"].height,
        minHeight: widget.component["size"].height,
      ),
      onPressed: onPressed,
      focusElevation: 0,
      hoverElevation: 2,
      highlightElevation: 3,
      elevation: 0.0,
      fillColor: Theme.of(context).disabledColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Icon(
        icon,
        color: Theme.of(context).tabBarTheme.indicatorColor,
        size: fontSizeButton,
      ),
    );
  }
}
