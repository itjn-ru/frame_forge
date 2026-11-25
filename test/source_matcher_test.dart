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
}
