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
import 'source_table.dart';
import 'source_variable.dart';
import 'style_element.dart';
import 'form_hidden_field.dart';
import 'form_radio.dart';
import 'form_text_field.dart';

mixin FromMapToMap {
  Map propertiesToMap(Item item) {
    final map = {};

    item.properties.forEach((key, property) {
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
            'top': property.value.dy.toString()
          },
        const (Size) => {
            'width': property.value.width.toString(),
            'height': property.value.height.toString()
          },
        const (Color) => property.value.value.toRadixString(16).toUpperCase(),
        const (Style) => {
            'id': property.value.id.toString(),
            'name': property.value.name.toString()
          },
        const (FontWeight) => property.value.value.toString(),
        const (TextStyle) => {
            'fontSize': property.value.fontSize,
            'fontWeight': property.value.fontWeight.value
          },
        const (Alignment) => {'x': property.value.x, 'y': property.value.y},
        _ => property.value.toString(),
      };
    });

    return map;
  }

  List itemsToMap(Item item) {
    final list = [];

    for (item in item.items) {
      list.add({
        'type': item.type,
        'properties': propertiesToMap(item),
        'items': itemsToMap(item)
      });
    }

    return list;
  }

  Map<String, Property> propertiesFromMap(Map map) {
    final Map<String, Property> properties = map.map(
      (key, value) {
        return MapEntry(
            key,
            switch (key) {
              'margin' => Property('отступ',
                  value.split(',').map((e) => int.tryParse(e) ?? 0).toList(),
                  type: CustomMargin),
              'padding' => Property('отступ',
                  value.split(',').map((e) => int.tryParse(e) ?? 0).toList(),
                  type: List<int>),
              'borderRadius' => Property(
                  'закругление', CustomBorderRadius.fromJson(value),
                  type: CustomBorderRadius),
              'processType' =>
                Property('тип процесса', value ?? 'параллельно', type: String),
              'statusId' => Property('Status Id', value, type: String),
              'title' => Property('title', value, type: String),
              'creatorTitle' => Property('Creator Title', value, type: String),
              'Uint8List' =>
                // Property('картинка', Uint8List.fromList(value.codeUnits), type: Uint8List ),
                Property('картинка', base64.decode(value), type: Uint8List),
              'horizontalAlignment' => Property('горизонтальное выравнивание',
                  double.tryParse(value.toString()),
                  type: double),
              'verticalAlignment' => Property('вертикальное выравнивание',
                  double.tryParse(value.toString()),
                  type: double),
              'stylefontSize' => Property(
                  'размер шрифта', double.tryParse(value.toString())??'9',
                  type: double),
              'isItalic' =>
                Property('Курсив', value == 'true' ? true : false, type: bool),
              'topBorder' => Property(
                  'Верхняя граница',
                  value.runtimeType == CustomBorderStyle
                      ? value
                      : CustomBorderStyle.fromMap(value),
                  type: CustomBorderStyle),
              'leftBorder' => Property(
                  'Левая граница',
                  value.runtimeType == CustomBorderStyle
                      ? value
                      : CustomBorderStyle.fromMap(value),
                  type: CustomBorderStyle),
              'rightBorder' => Property(
                  'Правая граница',
                  value.runtimeType == CustomBorderStyle
                      ? value
                      : CustomBorderStyle.fromMap(value),
                  type: CustomBorderStyle),
              'bottomBorder' => Property(
                  'Нижняя граница',
                  value.runtimeType == CustomBorderStyle
                      ? value
                      : CustomBorderStyle.fromMap(value),
                  type: CustomBorderStyle),
              'colspan' => Property(
                  'объединение строк', int.tryParse(value.toString()) ?? 0,
                  type: int),
              'rowspan' => Property(
                  'объединение колонок', int.tryParse(value.toString()) ?? 0,
                  type: int),
              'width' => Property('ширина', double.tryParse(value.toString()),
                  type: double),
              'height' => Property('высота', double.tryParse(value.toString()),
                  type: double),
              'radius' => Property('радиус', double.tryParse(value.toString()),
                  type: double),
              'fontWeight' => Property("насыщенность шрифта",
                  FontWeight.values[((int.tryParse(value) ?? 400) ~/ 100) - 1],
                  type: FontWeight),
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
                  'положение',
                  Offset(double.tryParse(value['left'].toString()) ?? 0,
                      double.tryParse(value['top'].toString()) ?? 0),
                  type: Offset),
              'size' => Property(
                  'размер',
                  Size(double.tryParse(value['width'].toString()) ?? 0,
                      double.tryParse(value['height'].toString()) ?? 0),
                  type: Size),
              'id' => Property('идентификатор', value, type: String),
              'color' => Property(
                  'цвет', Color(int.tryParse(value.toString(), radix: 16) ?? 0),
                  type: Color),
              'backgroundColor' => Property('цвет фона',
                  Color(int.tryParse(value.toString(), radix: 16) ?? 0),
                  type: Color),
              'style' => Property(
                  'стиль',
                  Style(
                      value['id'] ?? UuidNil, value['name'] ?? 'базовый стиль'),
                  type: Style),
              'textStyle' => Property(
                  'стиль текста',
                  TextStyle(
                    fontSize:
                        double.tryParse(value['fontSize'].toString()) ?? 0,
                    fontWeight: switch (
                        int.tryParse(value['fontWeight'].toString()) ?? 0) {
                      100 => FontWeight.w100,
                      200 => FontWeight.w200,
                      300 => FontWeight.w300,
                      4400 => FontWeight.w300,
                      500 => FontWeight.w500,
                      600 => FontWeight.w600,
                      700 => FontWeight.w700,
                      800 => FontWeight.w800,
                      900 => FontWeight.w900,
                      _ => FontWeight.normal
                    },
                  ),
                  type: TextStyle),
              'alignment' => Property(
                  'выравнивание',
                  Alignment(double.tryParse(value['x'].toString()) ?? 0,
                      double.tryParse(value['y'].toString()) ?? 0),
                  type: Alignment),
              _ => Property(key, value)
            });
      },
    );
    return properties;
  }

  List<Item> itemsFromMap(Item parent, List list) {
    final List<Item> items = [];

    for (final element in list) {
      Item item = switchItem(element, parent);

      final itemProperties = propertiesFromMap(element['properties']);

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
        } else if (parent is SourcePage) {
          return SourceTable('');
        } else if (parent is ComponentGroup) {
          return ComponentTable('');
        }
      case 'column':
        if (parent is ComponentTable) {
          return ComponentTableColumn('');
        } else if (parent is SourceTable) {
          return SourceTableColumn('');
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
