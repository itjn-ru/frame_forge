import 'package:flutter_test/flutter_test.dart';
import 'package:frame_forge/src/layout_model/source_matcher.dart';

void main() {
  group('sourceTextWords', () {
    test('splits CamelCase variable names', () {
      expect(
        sourceTextWords('ТягачДвигательСостояние'),
        <String>['тягач', 'двигатель', 'состояние'],
      );
    });

    test('splits spaced names and keeps brace words', () {
      expect(
        sourceTextWords('Состояние кабины тягача {комментарий}'),
        <String>['состояние', 'кабины', 'тягача', 'комментарий'],
      );
    });

    test('splits digits-adjacent case boundaries', () {
      expect(
        sourceTextWords('ДатчикTemperature1'),
        <String>['датчик', 'temperature1'],
      );
    });

    test('empty input gives no words', () {
      expect(sourceTextWords('   {}'), isEmpty);
    });
  });

  group('sourceWordsMatch', () {
    test('exact words match', () {
      expect(sourceWordsMatch('двигатель', 'двигатель'), isTrue);
    });

    test('case endings match through prefixes', () {
      expect(sourceWordsMatch('тягача', 'тягач'), isTrue);
      expect(sourceWordsMatch('тягач', 'тягача'), isTrue);
    });

    test('short prefixes do not match', () {
      expect(sourceWordsMatch('тяг', 'тягач'), isFalse);
    });

    test('different words do not match', () {
      expect(sourceWordsMatch('кабина', 'двигатель'), isFalse);
    });
  });

  group('findBestSourceVariableMatch', () {
    const List<String> variables = <String>[
      'ТягачДвигательСостояние',
      'КабинаДверь',
      'Состояние кабины тягача {комментарий}',
    ];

    test('matches when every non-brace word hits the variable', () {
      // The user case: both meaningful words hit the variable, the
      // {радиокнопка} hint is excluded from the threshold.
      final String? match = findBestSourceVariableMatch(
        'Двигатель тягача {радиокнопка}',
        variables,
      );
      expect(match, 'ТягачДвигательСостояние');
    });

    test('exact full match wins immediately', () {
      final String? match = findBestSourceVariableMatch(
        'Состояние кабины тягача {комментарий}',
        variables,
      );
      expect(match, 'Состояние кабины тягача {комментарий}');
    });

    test('one-word text binds to a variable containing the word', () {
      // Threshold = the number of text words (here: 1).
      expect(
        findBestSourceVariableMatch('Насос', <String>['НасосДатчик']),
        'НасосДатчик',
      );
    });

    test('a word missing from the variable fails the all-words threshold',
        () {
      // 'насос' matches, 'труба' does not: not every word is covered.
      expect(
        findBestSourceVariableMatch('НасосТруба', <String>['НасосДатчик']),
        isNull,
      );
    });

    test('text made only of a brace hint never binds', () {
      expect(
        findBestSourceVariableMatch('{радиокнопка}', variables),
        isNull,
      );
    });

    test('unit segments are ignored when matching', () {
      // (км)/(л) annotations do not count as words of the text.
      expect(
        findBestSourceVariableMatch('Пробег (км)', <String>['Пробег']),
        'Пробег',
      );
      expect(
        findBestSourceVariableMatch(
          'Остаток топлива в баке (л)',
          <String>['ОстатокТопливаВБаке'],
        ),
        'ОстатокТопливаВБаке',
      );
    });

    test('brace hint disambiguates same-prefix variables (tractor)', () {
      const List<String> variables = <String>[
        'ТягачСостояниеКабиныСостояние',
        'ТягачСостояниеКабиныФайл',
        'ТягачСостояниеКабиныКомментарий',
      ];
      expect(
        findBestSourceVariableMatch(
          'Состояние кабины тягача {радиокнопка}',
          variables,
        ),
        'ТягачСостояниеКабиныСостояние',
      );
      expect(
        findBestSourceVariableMatch(
          'Состояние кабины тягача {вложение}',
          variables,
        ),
        'ТягачСостояниеКабиныФайл',
      );
      expect(
        findBestSourceVariableMatch(
          'Состояние кабины тягача {комментарий}',
          variables,
        ),
        'ТягачСостояниеКабиныКомментарий',
      );
    });

    test('brace hint disambiguates same-prefix variables (trailer)', () {
      const List<String> variables = <String>[
        'ПрицепСостояниеКабиныСостояние',
        'ПрицепСостояниеКабиныФайл',
        'ПрицепСостояниеКабиныКомментарий',
      ];
      // The vehicle word stands at the end of the text with a case ending
      // and at the beginning of the variable name — order is irrelevant.
      expect(
        findBestSourceVariableMatch(
          'Состояние кабины прицепа {вложение}',
          variables,
        ),
        'ПрицепСостояниеКабиныФайл',
      );
    });

    test('covering candidate with a wrong hint suffix never binds', () {
      // Only the radio-button variable exists (as after the first import
      // pass): sibling fields with other hints must NOT latch onto it.
      const List<String> variables = <String>[
        'ТягачСостояниеКабиныСостояние',
      ];
      expect(
        findBestSourceVariableMatch(
          'Состояние кабины тягача {комментарий}',
          variables,
        ),
        isNull,
      );
      expect(
        findBestSourceVariableMatch(
          'Состояние кабины тягача {вложение}',
          variables,
        ),
        isNull,
      );
      // The matching hint still binds.
      expect(
        findBestSourceVariableMatch(
          'Состояние кабины тягача {радиокнопка}',
          variables,
        ),
        'ТягачСостояниеКабиныСостояние',
      );
    });

    test('no match at all returns null', () {
      expect(
        findBestSourceVariableMatch('СовсемДругоеБессмысленно', variables),
        isNull,
      );
    });

    test('empty legacy text returns null', () {
      expect(findBestSourceVariableMatch('   ', variables), isNull);
    });
  });

  group('generateSourceVariableName', () {
    test('vehicle word goes first, hint synonym goes last', () {
      expect(
        generateSourceVariableName('Состояние ходовой тягача {радиокнопка}'),
        'ТягачСостояниеХодовойСостояние',
      );
      expect(
        generateSourceVariableName('Состояние кабины тягача {радиокнопка}'),
        'ТягачСостояниеКабиныСостояние',
      );
      expect(
        generateSourceVariableName('Состояние кабины тягача {вложение}'),
        'ТягачСостояниеКабиныФайл',
      );
    });

    test('trailer word goes first too', () {
      expect(
        generateSourceVariableName('Состояние кабины прицепа {комментарий}'),
        'ПрицепСостояниеКабиныКомментарий',
      );
    });

    test('no vehicle word: words in original order plus hint', () {
      expect(
        generateSourceVariableName('Полная высота кабины {комментарий}'),
        'ПолнаяВысотаКабиныКомментарий',
      );
    });

    test('no hint: just the words', () {
      expect(
        generateSourceVariableName('Двигатель тягача'),
        'ТягачДвигатель',
      );
    });

    test('plain phrases concatenate into CamelCase', () {
      expect(
        generateSourceVariableName('Показание моточасов фактическое'),
        'ПоказаниеМоточасовФактическое',
      );
    });

    test('unit segments are dropped', () {
      expect(
        generateSourceVariableName('Пробег (км)'),
        'Пробег',
      );
      expect(
        generateSourceVariableName('Остаток топлива в баке (л)'),
        'ОстатокТопливаВБаке',
      );
    });

    test('empty and hint-only texts generate nothing', () {
      expect(generateSourceVariableName('   '), isEmpty);
      expect(generateSourceVariableName('{радиокнопка}'), isEmpty);
    });
  });

  group('isPascalCaseVariableName', () {
    test('accepts concatenated PascalCase names', () {
      expect(isPascalCaseVariableName('ТягачСостояниеКабиныСостояние'), isTrue);
      expect(isPascalCaseVariableName('Пробег'), isTrue);
      expect(isPascalCaseVariableName('ОстатокТопливаВБаке'), isTrue);
      expect(isPascalCaseVariableName('Тягач2Двигатель'), isTrue);
      expect(isPascalCaseVariableName('ТягачGPSКоординаты'), isTrue);
    });

    test('rejects phrases and other conventions', () {
      expect(isPascalCaseVariableName(''), isFalse);
      expect(isPascalCaseVariableName('Состояние кабины'), isFalse);
      expect(isPascalCaseVariableName('Состояние {вложение}'), isFalse);
      expect(isPascalCaseVariableName('состояниеКабины'), isFalse);
      expect(isPascalCaseVariableName('состояние_кабины'), isFalse);
      expect(isPascalCaseVariableName('состояние-кабины'), isFalse);
      expect(isPascalCaseVariableName('Config.ключ'), isFalse);
      expect(isPascalCaseVariableName('2Пробег'), isFalse);
    });
  });
}
