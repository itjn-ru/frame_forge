import 'package:flutter_test/flutter_test.dart';
import 'package:frame_forge/frame_forge.dart';
import 'package:frame_forge/src/layout_model/component_text.dart';
// The editor widgets come from the material_ui fork, which ships its own
// MaterialLocalizations — build the test app with the same fork.
import 'package:material_ui/material_ui.dart';

/// Components with an empty sourceV2 binding (but a legacy source text)
/// render orange in the PageList tree, together with all their ancestors.
void main() {
  late LayoutModel layoutModel;
  late LayoutModelController controller;
  late ComponentPage page;
  late LayoutComponent boundGroup;
  late ComponentText unboundText;
  late ComponentText boundText;
  late ComponentText plainText;

  setUp(() {
    layoutModel = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    controller = LayoutModelController(
      layoutModel: layoutModel,
      projectSaver: (Map<dynamic, dynamic> map) async => true,
      projectLoader: (bool isSaved) async => null,
    );
    page = layoutModel.componentPages.first;

    boundGroup = LayoutComponent('group', 'group1');
    layoutModel.addItem(page, boundGroup);

    // Has a legacy source text but no typed binding yet: orange.
    unboundText = ComponentText('unbound');
    unboundText.properties['source']?.value = 'Двигатель тягача';
    layoutModel.addItem(boundGroup, unboundText);

    // Bound through sourceV2: not orange.
    boundText = ComponentText('bound');
    boundText.properties['sourceV2']?.value = SourceReference(
      variableName: 'ТягачДвигательСостояние',
    );
    layoutModel.addItem(boundGroup, boundText);

    // No source at all: not orange.
    plainText = ComponentText('plain');
    layoutModel.addItem(page, plainText);
  });

  Future<void> pumpTree(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageList(controller, showQuickSwitcher: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Color rowTextColor(WidgetTester tester, String label) {
    final Text text = tester.widget<Text>(find.text(label));
    return text.style?.color ?? const Color(0x00000000);
  }

  Future<void> expandAllRows(WidgetTester tester) async {
    // Selecting a row reveals (expands) its ancestor chain, so selecting
    // the page first and then the group expands the whole branch.
    controller.select(page.id);
    await tester.pumpAndSettle();
    controller.select(boundGroup.id);
    await tester.pumpAndSettle();
  }

  testWidgets('unbound components and their ancestors are orange',
      (WidgetTester tester) async {
    await pumpTree(tester);
    await expandAllRows(tester);

    // The unbound component itself is orange.
    expect(rowTextColor(tester, 'unbound'), kUnboundSourceColor);
    // Its parent group carries the orange flag too.
    expect(rowTextColor(tester, 'group1'), kUnboundSourceColor);
    // The page row carries it as well (ancestor of the unbound branch).
    expect(rowTextColor(tester, 'page'), kUnboundSourceColor);

    // A bound component and a component without any source stay default.
    expect(rowTextColor(tester, 'bound'), isNot(kUnboundSourceColor));
    expect(rowTextColor(tester, 'plain'), isNot(kUnboundSourceColor));
  });

  testWidgets('binding the component clears the orange flag',
      (WidgetTester tester) async {
    await pumpTree(tester);
    await expandAllRows(tester);
    expect(rowTextColor(tester, 'unbound'), kUnboundSourceColor);

    // Simulate an auto-fill / manual binding through the model.
    unboundText.properties['sourceV2']?.value = SourceReference(
      variableName: 'ТягачДвигательСостояние',
    );
    controller.eventBus.emit(
      AttributeChangeEvent(id: 't', itemId: unboundText.id),
    );
    await tester.pumpAndSettle();

    expect(rowTextColor(tester, 'unbound'), isNot(kUnboundSourceColor));
    expect(rowTextColor(tester, 'group1'), isNot(kUnboundSourceColor));
    expect(rowTextColor(tester, 'page'), isNot(kUnboundSourceColor));
  });
}
