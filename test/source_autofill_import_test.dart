import 'package:flutter_test/flutter_test.dart';
import 'package:frame_forge/frame_forge.dart';
import 'package:frame_forge/src/layout_model/component_text.dart';

/// Import pipeline for sourceV2 bindings: a variableName written as a
/// human phrase (spaces / `{hint}`) is not a real variable — it is cleared
/// and the word-matching auto-fill binds the component to the actual
/// variable. Proper CamelCase bindings stay untouched.
void main() {
  late LayoutModel layoutModel;
  late SourcePage sourcePage;
  late ComponentPage page;
  late ComponentText phraseComponent;
  late ComponentText camelComponent;
  late ComponentText noMatchComponent;
  late ComponentText unitComponent;
  late ComponentText camelCaseComponent;

  setUp(() {
    layoutModel = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    sourcePage = layoutModel.root.items.whereType<SourcePage>().first;
    page = layoutModel.componentPages.first;

    // Human-phrase binding: cleared on import, then re-bound by words.
    phraseComponent = ComponentText('phrase');
    phraseComponent.properties['source']?.value =
        'Состояние кабины тягача {вложение}';
    phraseComponent.properties['sourceV2']?.value = SourceReference(
      variableName: 'Состояние кабины тягача {вложение}',
    );
    layoutModel.addItem(page, phraseComponent);

    // Proper CamelCase binding: must survive the import untouched.
    camelComponent = ComponentText('camel');
    camelComponent.properties['sourceV2']?.value = SourceReference(
      variableName: 'ТягачДвигательСостояние',
    );
    layoutModel.addItem(page, camelComponent);

    // Phrase binding with no candidate variable: cleared, then the
    // conventional variable is created and bound.
    noMatchComponent = ComponentText('nomatch');
    noMatchComponent.properties['source']?.value = 'Полная высота кабины';
    noMatchComponent.properties['sourceV2']?.value = SourceReference(
      variableName: 'Полная высота кабины',
    );
    layoutModel.addItem(page, noMatchComponent);

    // sourceV2 written with spaces (or &#x20;) plus a unit in the text:
    // normalized to the concatenated CamelCase name.
    unitComponent = ComponentText('unit');
    unitComponent.properties['source']?.value =
        'Показание моточасов фактическое';
    unitComponent.properties['sourceV2']?.value = SourceReference(
      variableName: 'Показание моточасов фактическое',
    );
    layoutModel.addItem(page, unitComponent);

    // camelCase binding (lowercase first letter): not PascalCase —
    // cleared and re-bound by words.
    camelCaseComponent = ComponentText('camelcase');
    camelCaseComponent.properties['source']?.value =
        'Показание моточасов фактическое';
    camelCaseComponent.properties['sourceV2']?.value = SourceReference(
      variableName: 'показаниеМоточасов',
    );
    layoutModel.addItem(page, camelCaseComponent);

    // The real variables of the data page.
    layoutModel.addItem(
      sourcePage,
      SourceVariable('СостояниеКабиныТягачаВложение'),
    );
    layoutModel.addItem(sourcePage, SourceVariable('ТягачДвигательСостояние'));
  });

  LayoutModel reloadFromMap() {
    final Map<dynamic, dynamic> map = layoutModel.toMap();
    final LayoutModel fresh = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    fresh.fromMap(map);
    return fresh;
  }

  SourceReference reloadedReference(ComponentText component) {
    return component.properties['sourceV2']!.value as SourceReference;
  }

  test('import clears the phrase binding and re-binds by words', () {
    final LayoutModel fresh = reloadFromMap();
    final ComponentText component = fresh.root.items
        .whereType<ComponentPage>()
        .expand((ComponentPage p) => p.items)
        .whereType<ComponentText>()
        .first;
    // The first ComponentText is 'phrase' in insertion order.

    final SourceReference reference = reloadedReference(component);
    expect(reference.variableName, 'СостояниеКабиныТягачаВложение');
  });

  test('proper CamelCase bindings survive the import', () {
    final LayoutModel fresh = reloadFromMap();
    final List<ComponentText> texts = fresh.root.items
        .whereType<ComponentPage>()
        .expand((ComponentPage p) => p.items)
        .whereType<ComponentText>()
        .toList();
    final ComponentText camel =
        texts.firstWhere((ComponentText t) => t['name'] == 'camel');

    final SourceReference reference = reloadedReference(camel);
    expect(reference.variableName, 'ТягачДвигательСостояние');
  });

  test('import creates the missing variable and binds the component', () {
    final LayoutModel fresh = reloadFromMap();
    final List<ComponentText> texts = fresh.root.items
        .whereType<ComponentPage>()
        .expand((ComponentPage p) => p.items)
        .whereType<ComponentText>()
        .toList();
    final ComponentText noMatch =
        texts.firstWhere((ComponentText t) => t['name'] == 'nomatch');

    // No variable covered the words, so the conventional name was
    // generated, the variable was created in the source page root and the
    // component got bound to it.
    final SourceReference reference = reloadedReference(noMatch);
    expect(reference.variableName, 'ПолнаяВысотаКабины');

    final List<String> names = fresh.root.items
        .whereType<SourcePage>()
        .expand((SourcePage p) => p.items)
        .whereType<SourceVariable>()
        .map((SourceVariable v) => v.properties['name']?.value?.toString() ?? '')
        .toList();
    expect(names, contains('ПолнаяВысотаКабины'));
  });

  test('import normalizes phrase bindings to concatenated CamelCase', () {
    final LayoutModel fresh = reloadFromMap();
    final List<ComponentText> texts = fresh.root.items
        .whereType<ComponentPage>()
        .expand((ComponentPage p) => p.items)
        .whereType<ComponentText>()
        .toList();
    final ComponentText unit =
        texts.firstWhere((ComponentText t) => t['name'] == 'unit');

    // The phrase binding (spaces / &#x20;) was cleared and re-bound to the
    // conventional concatenated name.
    final SourceReference reference = reloadedReference(unit);
    expect(reference.variableName, 'ПоказаниеМоточасовФактическое');

    final List<String> names = fresh.root.items
        .whereType<SourcePage>()
        .expand((SourcePage p) => p.items)
        .whereType<SourceVariable>()
        .map((SourceVariable v) => v.properties['name']?.value?.toString() ?? '')
        .toList();
    expect(names, contains('ПоказаниеМоточасовФактическое'));
  });

  test('import creates a distinct variable per hint suffix', () {
    // The user scenario: one field in three widget variants — the hint
    // alone distinguishes them; the data page starts empty.
    final LayoutModel model = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    final ComponentPage modelPage = model.componentPages.first;
    final Map<String, String> components = <String, String>{
      'radio': 'Состояние кабины тягача {радиокнопка}',
      'attach': 'Состояние кабины тягача {вложение}',
      'comment': 'Состояние кабины тягача {комментарий}',
    };
    for (final MapEntry<String, String> entry in components.entries) {
      final ComponentText component = ComponentText(entry.key);
      component.properties['source']?.value = entry.value;
      model.addItem(modelPage, component);
    }

    final Map<dynamic, dynamic> map = model.toMap();
    final LayoutModel fresh = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    fresh.fromMap(map);

    // One variable per hinted field word.
    final List<String> names = fresh.root.items
        .whereType<SourcePage>()
        .expand((SourcePage p) => p.items)
        .whereType<SourceVariable>()
        .map((SourceVariable v) => v.properties['name']?.value?.toString() ?? '')
        .toList();
    expect(names, contains('ТягачСостояниеКабиныСостояние'));
    expect(names, contains('ТягачСостояниеКабиныФайл'));
    expect(names, contains('ТягачСостояниеКабиныКомментарий'));

    // Every component is bound to its own variable.
    final Map<String, String> bindings = <String, String>{
      for (final ComponentText t in fresh.root.items
          .whereType<ComponentPage>()
          .expand((ComponentPage p) => p.items)
          .whereType<ComponentText>())
        t['name']?.toString() ?? '':
            (t.properties['sourceV2']!.value as SourceReference).variableName,
    };
    expect(bindings['radio'], 'ТягачСостояниеКабиныСостояние');
    expect(bindings['attach'], 'ТягачСостояниеКабиныФайл');
    expect(bindings['comment'], 'ТягачСостояниеКабиныКомментарий');
  });

  test('import clears non-PascalCase bindings and re-binds them', () {
    // 'camelcase' has a camelCase (lowercase first) variableName — not
    // strict PascalCase, so the import clears it; the component shares
    // the source text with 'unit', whose conventional variable was
    // created first, so the binding lands on it.
    final LayoutModel fresh = reloadFromMap();
    final List<ComponentText> texts = fresh.root.items
        .whereType<ComponentPage>()
        .expand((ComponentPage p) => p.items)
        .whereType<ComponentText>()
        .toList();
    final ComponentText camelCase =
        texts.firstWhere((ComponentText t) => t['name'] == 'camelcase');

    final SourceReference reference = reloadedReference(camelCase);
    expect(reference.variableName, 'ПоказаниеМоточасовФактическое');
  });

  test('import renames phrase-named variables and moves the bindings', () {
    // The legacy-file scenario: the data page itself carries variables
    // named by the old auto-creation with whole phrases, and the
    // components are bound to those phrases. Clearing the bindings alone
    // changes nothing (the auto-fill finds the same phrase variable and
    // binds it back), so the variables are renamed by the convention and
    // the bindings follow.
    final LayoutModel model = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    final SourcePage modelSourcePage =
        model.root.items.whereType<SourcePage>().first;
    final ComponentPage modelPage = model.componentPages.first;

    final ComponentText radio = ComponentText('radio');
    radio.properties['source']?.value =
        'Состояние кабины тягача {радиокнопка}';
    radio.properties['sourceV2']?.value = SourceReference(
      variableName: 'Состояние кабины тягача {радиокнопка}',
    );
    model.addItem(modelPage, radio);

    final ComponentText date = ComponentText('date');
    date.properties['source']?.value = 'дата';
    date.properties['sourceV2']?.value = SourceReference(
      variableName: 'дата',
    );
    model.addItem(modelPage, date);

    model.addItem(
      modelSourcePage,
      SourceVariable('Состояние кабины тягача {радиокнопка}'),
    );
    model.addItem(modelSourcePage, SourceVariable('дата'));
    model.addItem(modelSourcePage, SourceVariable('ФИО'));

    final Map<dynamic, dynamic> map = model.toMap();
    final LayoutModel fresh = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    fresh.fromMap(map);

    // The phrase variables are renamed by the convention; the proper
    // PascalCase one is untouched.
    final List<String> names = fresh.root.items
        .whereType<SourcePage>()
        .expand((SourcePage p) => p.items)
        .whereType<SourceVariable>()
        .map((SourceVariable v) => v.properties['name']?.value?.toString() ?? '')
        .toList();
    expect(names, contains('ТягачСостояниеКабиныСостояние'));
    expect(names, contains('Дата'));
    expect(names, contains('ФИО'));
    expect(names, isNot(contains('Состояние кабины тягача {радиокнопка}')));
    expect(names, isNot(contains('дата')));

    // The bindings follow the renamed variables.
    final Map<String, String> bindings = <String, String>{
      for (final ComponentText t in fresh.root.items
          .whereType<ComponentPage>()
          .expand((ComponentPage p) => p.items)
          .whereType<ComponentText>())
        t['name']?.toString() ?? '':
            (t.properties['sourceV2']!.value as SourceReference).variableName,
    };
    expect(bindings['radio'], 'ТягачСостояниеКабиныСостояние');
    expect(bindings['date'], 'Дата');
  });

  test('import suffixes a phrase rename that collides with a proper name',
      () {
    // The conventional name for 'Пробег (км)' is 'Пробег', which is
    // already taken by a proper variable: the renamed one gets a numeric
    // suffix instead of shadowing it.
    final LayoutModel model = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    final SourcePage modelSourcePage =
        model.root.items.whereType<SourcePage>().first;
    final ComponentPage modelPage = model.componentPages.first;

    final ComponentText mileage = ComponentText('mileage');
    mileage.properties['source']?.value = 'Пробег (км)';
    mileage.properties['sourceV2']?.value = SourceReference(
      variableName: 'Пробег (км)',
    );
    model.addItem(modelPage, mileage);

    model.addItem(modelSourcePage, SourceVariable('Пробег'));
    model.addItem(modelSourcePage, SourceVariable('Пробег (км)'));

    final Map<dynamic, dynamic> map = model.toMap();
    final LayoutModel fresh = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    fresh.fromMap(map);

    final List<String> names = fresh.root.items
        .whereType<SourcePage>()
        .expand((SourcePage p) => p.items)
        .whereType<SourceVariable>()
        .map((SourceVariable v) => v.properties['name']?.value?.toString() ?? '')
        .toList();
    expect(names, contains('Пробег'));
    expect(names, contains('Пробег2'));
    expect(names, isNot(contains('Пробег (км)')));

    final ComponentText reloaded = fresh.root.items
        .whereType<ComponentPage>()
        .expand((ComponentPage p) => p.items)
        .whereType<ComponentText>()
        .firstWhere((ComponentText t) => t['name'] == 'mileage');
    expect(reloadedReference(reloaded).variableName, 'Пробег2');
  });

  test('import leaves map keys of a Map variable as is', () {
    // Children of a Map variable are map keys, not standalone variables:
    // a phrase-shaped key is not renamed on import.
    final LayoutModel model = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    final SourcePage modelSourcePage =
        model.root.items.whereType<SourcePage>().first;

    final SourceVariable mapVariable = SourceVariable('Настройки');
    mapVariable.properties['type']?.value =
        const SourceVariableType('Map');
    final SourceVariable key = SourceVariable('ключ фраза');
    model.addItem(modelSourcePage, mapVariable);
    model.addItem(mapVariable, key);

    final Map<dynamic, dynamic> map = model.toMap();
    final LayoutModel fresh = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    fresh.fromMap(map);

    final SourceVariable reloadedMap = fresh.root.items
        .whereType<SourcePage>()
        .expand((SourcePage p) => p.items)
        .whereType<SourceVariable>()
        .firstWhere(
          (SourceVariable v) => v['name'] == 'Настройки',
        );
    expect(reloadedMap.items, hasLength(1));
    expect(reloadedMap.items.first['name'], 'ключ фраза');
  });
}
