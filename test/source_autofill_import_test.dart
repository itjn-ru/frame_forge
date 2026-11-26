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

    // Phrase binding with no candidate variable: cleared, stays empty.
    noMatchComponent = ComponentText('nomatch');
    noMatchComponent.properties['source']?.value = 'Полная высота кабины';
    noMatchComponent.properties['sourceV2']?.value = SourceReference(
      variableName: 'Полная высота кабины',
    );
    layoutModel.addItem(page, noMatchComponent);

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
}
