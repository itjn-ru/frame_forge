import 'package:flutter_test/flutter_test.dart';
import 'package:frame_forge/frame_forge.dart';
import 'package:frame_forge/src/layout_model/component_text.dart';

/// Import pipeline tests: the fromMap flow must bind empty sourceV2
/// references by word matching BEFORE the sync step, so components that
/// just got bound do not spawn text-named duplicates in the source page.
void main() {
  late LayoutModel layoutModel;
  late SourcePage sourcePage;
  late ComponentText legacyComponent;
  late SourceVariable engine;

  setUp(() {
    layoutModel = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    sourcePage = layoutModel.root.items.whereType<SourcePage>().first;

    legacyComponent = ComponentText('legacy');
    legacyComponent.properties['source']?.value =
        'Двигатель тягача {радиокнопка}';
    // sourceV2 stays empty (the default new reference).
    layoutModel.addItem(
      layoutModel.componentPages.first,
      legacyComponent,
    );

    engine = SourceVariable('ТягачДвигательСостояние');
    layoutModel.addItem(sourcePage, engine);
  });

  LayoutModel reloadFromMap() {
    final Map<dynamic, dynamic> map = layoutModel.toMap();
    final LayoutModel fresh = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    fresh.fromMap(map);
    return fresh;
  }

  ComponentText findLegacyComponent(LayoutModel model) {
    return model.root.items
        .whereType<ComponentPage>()
        .expand((ComponentPage page) => page.items)
        .whereType<ComponentText>()
        .first;
  }

  List<String> sourceVariableNames(LayoutModel model) {
    return model.root.items
        .whereType<SourcePage>()
        .expand((SourcePage page) => page.items)
        .whereType<SourceVariable>()
        .map((SourceVariable v) => v.properties['name']?.value?.toString() ?? '')
        .toList();
  }

  test('import binds sourceV2 and does not spawn the text-named variable',
      () {
    final LayoutModel fresh = reloadFromMap();

    final ComponentText component = findLegacyComponent(fresh);
    final SourceReference reference =
        component.properties['sourceV2']!.value as SourceReference;
    expect(reference.variableName, 'ТягачДвигательСостояние');

    // The legacy text must not become a variable: the component is bound
    // through sourceV2 now, the text is just a label.
    expect(
      sourceVariableNames(fresh),
      isNot(contains('Двигатель тягача {радиокнопка}')),
    );
    expect(sourceVariableNames(fresh), contains('ТягачДвигательСостояние'));
  });

  test('import keeps the legacy fallback when no variable matches', () {
    // A text no variable can match: all three words are unrelated.
    legacyComponent.properties['source']?.value = 'ПолнаяВысотаКабины';
    legacyComponent.properties['sourceV2']?.value = SourceReference();

    final LayoutModel fresh = reloadFromMap();

    final ComponentText component = findLegacyComponent(fresh);
    final SourceReference reference =
        component.properties['sourceV2']!.value as SourceReference;
    expect(reference.variableName, isEmpty);

    // The legacy binding stays effective, so the matching text-named
    // variable is still created for it.
    expect(sourceVariableNames(fresh), contains('ПолнаяВысотаКабины'));
  });

  test('import does not re-add text variables for already bound components',
      () {
    // The component was bound earlier and saved: sourceV2 is filled while
    // the legacy text is still present.
    legacyComponent.properties['sourceV2']?.value = SourceReference(
      variableName: 'ТягачДвигательСостояние',
    );

    final LayoutModel fresh = reloadFromMap();

    // Bound component: no text-named variable appears.
    expect(
      sourceVariableNames(fresh),
      isNot(contains('Двигатель тягача {радиокнопка}')),
    );
  });
}
