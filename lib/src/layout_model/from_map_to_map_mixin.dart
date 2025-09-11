import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'constants.dart';
import 'custom_border_radius.dart';
import 'custom_margin.dart';
import 'form_expandble_list.dart';
import 'item.dart';
import 'process_group.dart';
import 'property.dart';
import 'screen_size_enum.dart';
import 'style.dart';
import 'package:flutter/widgets.dart';
import 'component_group.dart';
import 'component_table.dart';
import 'component_text.dart';
import 'form_checkbox.dart';
import 'form_image.dart';
import 'form_slider_button.dart';
import 'page.dart';
import 'process_element.dart';
import 'source_variable.dart';
import 'style_element.dart';
import 'form_hidden_field.dart';
import 'form_radio.dart';
import 'form_text_field.dart';

mixin FromMapToMap {
  Map propertiesToMap(Item item) {
    final map = {};

    item.properties.forEach((key, property) {
      try {
        map[key] = switch (property.type) {
          const (String) => property.value,
          const (CustomMargin) => property.value.join(','),
          const (List<int>) => property.value.join(','),
          const (CustomBorderRadius) => property.value.toJson(),
          const (ScreenSizeEnum) => property.value.index,
          const (Uint8List) => base64.encode(property.value),
          const (CustomBorderStyle) => property.value.toMap(),
          const (Offset) => {
              'left': property.value.dx.toString(),
              'top': property.value.dy.toString(),
            },
          const (Size) => {
              'width': property.value.width.toString(),
              'height': property.value.height.toString(),
            },
          const (Color) => property.value.value.toRadixString(16).toUpperCase(),
          const (Style) => {
              'id': property.value.id.toString(),
              'name': property.value.name.toString(),
            },
          const (FontWeight) => property.value.value.toString(),
          const (TextStyle) => {
              'fontSize': property.value.fontSize,
              'fontWeight': property.value.fontWeight.value,
            },
          const (Alignment) => {'x': property.value.x, 'y': property.value.y},
          _ => property.value.toString(),
        };
      } catch (e) {
        debugPrint('Error serializing property $key: $e');
      }
    });

    return map;
  }

  List<Map<String, dynamic>> itemsToMap(Item item) {
    final List<Map<String, dynamic>> list = [];

    for (item in item.items) {
      list.add(<String, dynamic>{
        'type': item.type,
        'properties': propertiesToMap(item),
        'items': itemsToMap(item),
      });
    }

    return list;
  }

  Map<String, Property> propertiesFromMap(Map map) {
    final Map<String, Property> properties = map.map((key, value) {
      return MapEntry(
          key,
          switch (key) {
            'margin' => Property(
                'Margin',
                value.split(',').map((e) => int.tryParse(e) ?? 0).toList(),
                type: CustomMargin,
              ),
            'padding' => Property(
                'Padding',
                value.split(',').map((e) => int.tryParse(e) ?? 0).toList(),
                type: List<int>,
              ),
            'borderRadius' => Property(
                'Border Radius',
                CustomBorderRadius.fromJson(value),
                type: CustomBorderRadius,
              ),
            'processType' => Property(
                'Process Type',
                value ?? 'Parallelly',
                type: String,
              ),
            'statusId' => Property('Status Id', value, type: String),
            'title' => Property('Title', value, type: String),
            'creatorTitle' => Property('Creator Title', value, type: String),
            'Uint8List' =>
              // Property('картинка', Uint8List.fromList(value.codeUnits), type: Uint8List ),
              Property('Image', base64.decode(value), type: Uint8List),
            'horizontalAlignment' => Property(
                'Horizontal Alignment',
                double.tryParse(value.toString()),
                type: double,
              ),
            'verticalAlignment' => Property(
                'Vertical Alignment',
                double.tryParse(value.toString()),
                type: double,
              ),
            'stylefontSize' => Property(
                'Font Size',
                double.tryParse(value.toString()) ?? '9',
                type: double,
              ),
            'isItalic' => Property(
                'Italic',
                value == 'true' ? true : false,
                type: bool,
              ),
            'topBorder' => Property(
                'Top border',
                value.runtimeType == CustomBorderStyle
                    ? value
                    : CustomBorderStyle.fromMap(value),
                type: CustomBorderStyle,
              ),
            'leftBorder' => Property(
                'Left Border',
                value.runtimeType == CustomBorderStyle
                    ? value
                    : CustomBorderStyle.fromMap(value),
                type: CustomBorderStyle,
              ),
            'rightBorder' => Property(
                'Right Border',
                value.runtimeType == CustomBorderStyle
                    ? value
                    : CustomBorderStyle.fromMap(value),
                type: CustomBorderStyle,
              ),
            'bottomBorder' => Property(
                'Bottom Border',
                value.runtimeType == CustomBorderStyle
                    ? value
                    : CustomBorderStyle.fromMap(value),
                type: CustomBorderStyle,
              ),
            'colspan' => Property(
                'Column Span',
                int.tryParse(value.toString()) ?? 0,
                type: int,
              ),
            'rowspan' => Property(
                'Row Span',
                int.tryParse(value.toString()) ?? 0,
                type: int,
              ),
            'width' => Property(
                'Width',
                double.tryParse(value.toString()),
                type: double,
              ),
            'height' => Property(
                'Height',
                double.tryParse(value.toString()),
                type: double,
              ),
            'radius' => Property(
                'Radius',
                double.tryParse(value.toString()),
                type: double,
              ),
            'fontWeight' => Property(
                "Font Weight",
                FontWeight.values[((int.tryParse(value) ?? 400) ~/ 100) - 1],
                type: FontWeight,
              ),
            /*
              'rowMergeStart' =>
                  Property('начало объединения строк', int.tryParse(value)??-1, type: int),
              'rowMergeSpan' =>
                  Property('кол-во объединения строк', int.tryParse(value)??-1, type: int),
              'columnMergestart' =>
                  Property('начало объединения колонок', int.tryParse(value)??-1, type: int),
              'columnMergeSpan' =>
                  Property('кол-во объединения колонок', int.tryParse(value)??-1, type: int),
*/
            'position' => Property(
                'Position',
                Offset(
                  double.tryParse(value['left'].toString()) ?? 0,
                  double.tryParse(value['top'].toString()) ?? 0,
                ),
                type: Offset,
              ),
            'size' => Property(
                'Size',
                Size(
                  double.tryParse(value['width'].toString()) ?? 0,
                  double.tryParse(value['height'].toString()) ?? 0,
                ),
                type: Size,
              ),
            'id' => Property('Id', value, type: String),
            'color' => Property(
                'Color',
                Color(int.tryParse(value.toString(), radix: 16) ?? 0),
                type: Color,
              ),
            'activeColor' => Property(
                'Active Color',
                Color(int.tryParse(value.toString(), radix: 16) ?? 1),
                type: Color,
              ),
            'inactiveColor' => Property(
                'Inactive Color',
                Color(int.tryParse(value.toString(), radix: 16) ?? 1),
                type: Color,
              ),
            'thumbColor' => Property(
                'Thumb Color',
                Color(int.tryParse(value.toString(), radix: 16) ?? 1),
                type: Color,
              ),
            'backgroundColor' => Property(
                'Background Color',
                Color(int.tryParse(value.toString(), radix: 16) ?? 0),
                type: Color,
              ),
            'style' => Property(
                'Style',
                Style(value['id'] ?? UuidNil, value['name'] ?? 'basic style'),
                type: Style,
              ),
            'textStyle' => Property(
                'Text Style',
                TextStyle(
                  fontSize: double.tryParse(value['fontSize'].toString()) ?? 0,
                  fontWeight: switch (
                      int.tryParse(value['fontWeight'].toString()) ?? 0) {
                    100 => FontWeight.w100,
                    200 => FontWeight.w200,
                    300 => FontWeight.w300,
                    400 => FontWeight.w400,
                    500 => FontWeight.w500,
                    600 => FontWeight.w600,
                    700 => FontWeight.w700,
                    800 => FontWeight.w800,
                    900 => FontWeight.w900,
                    _ => FontWeight.normal,
                  },
                ),
                type: TextStyle,
              ),
            'alignment' => Property(
                'Alignment',
                Alignment(
                  double.tryParse(value['x'].toString()) ?? 0,
                  double.tryParse(value['y'].toString()) ?? 0,
                ),
                type: Alignment,
              ),
            _ => Property(key, value),
          });
    });
    return properties;
  }

  List<Item> itemsFromMap(Item parent, List<Map<String, dynamic>> list) {
    final List<Item> items = [];

    for (final Map<String, dynamic> element in list) {
      Item item = switchItem(element, parent);

      final Map<String, Property> itemProperties = propertiesFromMap(element['properties']);

      item.properties.forEach((key, value) {
        if (itemProperties.containsKey(key)) {
          if (key == 'fontSize') {
            item.properties[key]!.value =
                double.tryParse(itemProperties[key]?.value) ?? '11';
          }
          if (item.properties[key]?.type == itemProperties[key]?.type) {
            itemProperties[key]!.title = item.properties[key]!.title;
            item.properties[key] = itemProperties[key]!;
          }
        }
      });

      item.items = itemsFromMap(item, element['items']);

      items.add(item);
    }

    return items;
  }

  Item switchItem(Map<String, dynamic> element, Item parent) {
    switch (element['type']) {
      case 'componentPage':
        return ComponentPage('');
      case 'sourcePage':
        return SourcePage('');
      case 'stylePage':
        return StylePage('');
      case 'processPage':
        return ProcessPage('');
      case 'group':
        return ComponentGroup('');
      case 'table':
        if (parent is ComponentPage) {
          return ComponentTable('');
        } else if (parent is ComponentGroup) {
          return ComponentTable('');
        }
      case 'column':
        if (parent is ComponentTable) {
          return ComponentTableColumn('');
        }
      case 'rowGroup':
        return ComponentTableRowGroup('');
      case 'row':
        return ComponentTableRow('');
      case 'cell':
        return ComponentTableCell('');
      case 'text':
        return ComponentText('');
      case 'variable':
        return SourceVariable('');
      case 'textField':
        return FormTextField('');
      case 'radio':
        return FormRadio('');
      case 'image':
        return FormImage('');
      case "sliderButton":
        return FormSliderButton('');
      case 'checkbox':
        return FormCheckbox('');
      case 'hiddenField':
        return FormHiddenField('');
      case 'styleElement':
        return StyleElement('');
      case 'processElement':
        return ProcessElement('');
      case 'processGroup':
        return ProcessGroup('');
      case 'expandblelist':
        return FormExpandbleList('');
    }
    return Item('item', 'item');
  }
}
