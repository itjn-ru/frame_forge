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
}
