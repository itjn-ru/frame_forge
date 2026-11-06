import 'package:flutter_test/flutter_test.dart';
import 'package:frame_forge/frame_forge.dart';
import 'package:frame_forge/src/layout_model/form_checkbox.dart';
import 'package:frame_forge/src/layout_model/form_radio.dart';
import 'package:frame_forge/src/layout_model/form_slider_button.dart';
import 'package:frame_forge/src/layout_model/form_text_field.dart';
import 'package:frame_forge/src/layout_model/property.dart';

void main() {
  group('required property declaration', () {
    test('input components declare a bool required property', () {
      final List<Item> components = <Item>[
        FormTextField('f'),
        FormRadio('f'),
        FormCheckbox('f'),
        FormSliderButton('f'),
      ];
      for (final Item component in components) {
        final Property? property = component.properties['required'];
        expect(
          property,
          isNotNull,
          reason: '${component.type} must declare required',
        );
        expect(property!.value, isFalse);
        expect(property.type, bool);
      }
    });

    test('required flag survives the map round trip', () {
      final FormTextField field = FormTextField('f')
        ..properties['required']?.value = true;
      final Map<dynamic, dynamic> serialized = field.propertiesToMap(field);
      expect(serialized['required'], 'true');

      final Map<String, Property> restored = field.propertiesFromMap(
        serialized,
      );
      expect(restored['required']?.value, isTrue);
    });

    test('parsing accepts only lowercase true', () {
      final Map<String, Property> restored = FormTextField(
        'f',
      ).propertiesFromMap(<String, dynamic>{'name': 'f', 'required': 'TRUE'});
      expect(restored['required']?.value, isFalse);
    });
  });

  group('isRequiredField', () {
    test('true only for capable components with the flag set', () {
      final FormRadio radio = FormRadio('r')
        ..properties['required']?.value = true;
      expect(isRequiredField(radio), isTrue);

      final FormCheckbox checkbox = FormCheckbox('c');
      expect(isRequiredField(checkbox), isFalse);

      final Item plain = Item('text', 't')
        ..properties['required'] = Property('isRequired', true, type: bool);
      expect(isRequiredField(plain), isFalse);
    });
  });

  group('collectMissingRequiredFields', () {
    late FormTextField field;

    setUp(() {
      field =
          FormTextField('ФИО')
            ..properties['caption']?.value = 'Сотрудник'
            ..properties['required']?.value = true
            ..properties['source']?.value = 'employee';
    });

    Item page(String name, List<Item> children) {
      final Item result = Item('page', name);
      result.items.addAll(children);
      return result;
    }

    test('filled value is not missing', () {
      final List<MissingRequiredField> missing = collectMissingRequiredFields(
        pages: <Item>[page('p', <Item>[field])],
        json: <String, dynamic>{'employee': 'Иванов'},
      );
      expect(missing, isEmpty);
    });

    test('null, empty and blank values are missing', () {
      final List<Map<String, dynamic>> cases = <Map<String, dynamic>>[
        <String, dynamic>{'employee': null},
        <String, dynamic>{'employee': ''},
        <String, dynamic>{'employee': '   '},
      ];
      for (final Map<String, dynamic> json in cases) {
        final List<MissingRequiredField> missing =
            collectMissingRequiredFields(
              pages: <Item>[page('p', <Item>[field])],
              json: json,
            );
        expect(missing, hasLength(1), reason: 'json: $json');
        expect(missing.single.label, 'Сотрудник');
        expect(missing.single.key, 'employee');
        expect(missing.single.pageIndex, 0);
        expect(missing.single.pageName, 'p');
      }
    });

    test('missing document counts as unfilled', () {
      final List<MissingRequiredField> missing = collectMissingRequiredFields(
        pages: <Item>[page('p', <Item>[field])],
        json: null,
      );
      expect(missing, hasLength(1));
    });

    test('fields without a source are skipped', () {
      field.properties['source']?.value = '';
      final List<MissingRequiredField> missing = collectMissingRequiredFields(
        pages: <Item>[page('p', <Item>[field])],
        json: <String, dynamic>{},
      );
      expect(missing, isEmpty);
    });

    test('not required fields are skipped', () {
      field.properties['required']?.value = false;
      final List<MissingRequiredField> missing = collectMissingRequiredFields(
        pages: <Item>[page('p', <Item>[field])],
        json: <String, dynamic>{},
      );
      expect(missing, isEmpty);
    });

    test('sourceV2 map key resolves nested values', () {
      field
        ..properties['source']?.value = ''
        ..properties['sourceV2']?.value = SourceReference(
          variableName: 'employee',
          mapKey: 'name',
        );

      final List<MissingRequiredField> filled = collectMissingRequiredFields(
        pages: <Item>[page('p', <Item>[field])],
        json: <String, dynamic>{
          'employee': <String, dynamic>{'name': 'Иванов'},
        },
      );
      expect(filled, isEmpty);

      final List<MissingRequiredField> empty = collectMissingRequiredFields(
        pages: <Item>[page('p', <Item>[field])],
        json: <String, dynamic>{
          'employee': <String, dynamic>{'name': ''},
        },
      );
      expect(empty, hasLength(1));
    });

    test('nested components are collected with the owning page index', () {
      final Item group = Item('group', 'g')..items.add(field);
      final FormCheckbox second =
          FormCheckbox('c')
            ..properties['required']?.value = true
            ..properties['source']?.value = 'check';

      final List<MissingRequiredField> missing = collectMissingRequiredFields(
        pages: <Item>[page('p1', <Item>[group]), page('p2', <Item>[second])],
        json: <String, dynamic>{},
      );
      expect(missing, hasLength(2));
      expect(missing[0].pageIndex, 0);
      expect(missing[1].pageIndex, 1);
    });

    test('onlyPageIndex restricts the check to one page', () {
      final FormCheckbox second =
          FormCheckbox('c')
            ..properties['required']?.value = true
            ..properties['source']?.value = 'check';

      final List<MissingRequiredField> missing = collectMissingRequiredFields(
        pages: <Item>[page('p1', <Item>[field]), page('p2', <Item>[second])],
        json: <String, dynamic>{},
        onlyPageIndex: 1,
      );
      expect(missing, hasLength(1));
      expect(missing.single.key, 'check');
    });

    test('custom fill predicate replaces the default rule', () {
      bool twoWords(Item item, Map<String, dynamic>? json) {
        final dynamic value = item.readSourceValue(json);
        if (value == null) return false;
        return value.toString().trim().split(RegExp(r'\s+')).length >= 2;
      }

      final List<MissingRequiredField> single = collectMissingRequiredFields(
        pages: <Item>[page('p', <Item>[field])],
        json: <String, dynamic>{'employee': 'Иванов'},
        isFilled: twoWords,
      );
      expect(single, hasLength(1));

      final List<MissingRequiredField> full = collectMissingRequiredFields(
        pages: <Item>[page('p', <Item>[field])],
        json: <String, dynamic>{'employee': 'Иванов Иван'},
        isFilled: twoWords,
      );
      expect(full, isEmpty);
    });
  });

  group('fieldLabel', () {
    test('prefers caption over text and source', () {
      final FormTextField field =
          FormTextField('f')
            ..properties['caption']?.value = ' Подпись '
            ..properties['text']?.value = 'Текст';
      expect(fieldLabel(field), 'Подпись');

      field.properties['caption']?.value = '';
      expect(fieldLabel(field), 'Текст');

      field.properties['text']?.value = '';
      field.properties['source']?.value = 'employee';
      expect(fieldLabel(field), 'employee');
    });
  });

  group('LayoutComponentSource', () {
    test('writeSourceValue writes legacy and nested map bindings', () {
      final FormTextField legacy =
          FormTextField('a')..properties['source']?.value = 'plain';
      final Map<String, dynamic> json = <String, dynamic>{};
      legacy.writeSourceValue(json, 'value');
      expect(json['plain'], 'value');
      expect(legacy.readSourceValue(json), 'value');

      final FormTextField nested =
          FormTextField('b')
            ..properties['source']?.value = ''
            ..properties['sourceV2']?.value = SourceReference(
              variableName: 'employee',
              mapKey: 'name',
            );
      nested.writeSourceValue(json, 'Иванов');
      expect(json, <String, dynamic>{
        'plain': 'value',
        'employee': <String, dynamic>{'name': 'Иванов'},
      });
      expect(nested.readSourceValue(json), 'Иванов');
    });

    test('sourceSignature follows the effective binding', () {
      final FormTextField field =
          FormTextField('f')..properties['source']?.value = 'a';
      expect(field.sourceSignature, 'a');
      expect(field.hasSource, isTrue);

      field.properties['source']?.value = '';
      expect(field.hasSource, isFalse);

      field.properties['sourceV2']?.value = SourceReference(
        variableName: 'employee',
      );
      expect(field.sourceSignature, 'employee');
      expect(field.hasSource, isTrue);
    });
  });
}
