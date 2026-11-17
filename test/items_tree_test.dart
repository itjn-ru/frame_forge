import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frame_forge/frame_forge.dart';

void main() {
  late LayoutModel layoutModel;
  late LayoutModelController controller;
  late ComponentPage page;
  late LayoutComponent parentGroup;
  late LayoutComponent childText;

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
    parentGroup = LayoutComponent('group', 'group1');
    childText = LayoutComponent('text', 'text1');
    layoutModel.addItem(page, parentGroup);
    layoutModel.addItem(parentGroup, childText);
  });

  Future<void> pumpTree(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Items(page, controller)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Items collapsible tree', () {
    testWidgets('shows only the first level by default', (WidgetTester tester) async {
      await pumpTree(tester);

      expect(find.text('page'), findsOneWidget);
      expect(find.text('group1'), findsOneWidget);
      // Second level is hidden until the parent is expanded.
      expect(find.text('text1'), findsNothing);
    });

    testWidgets('expands a branch when its chevron is tapped',
        (WidgetTester tester) async {
      await pumpTree(tester);

      // The collapsed 'group1' node is the only right-pointing chevron:
      // the page root starts expanded (down chevron).
      expect(find.byIcon(Icons.keyboard_arrow_right), findsOneWidget);
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right));
      await tester.pumpAndSettle();

      expect(find.text('text1'), findsOneWidget);
      // Expanded node switches its chevron to the down state.
      expect(find.byIcon(Icons.keyboard_arrow_right), findsNothing);
    });

    testWidgets('collapses an expanded branch on chevron tap',
        (WidgetTester tester) async {
      await pumpTree(tester);
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right));
      await tester.pumpAndSettle();
      expect(find.text('text1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down).last);
      await tester.pumpAndSettle();

      expect(find.text('text1'), findsNothing);
    });

    testWidgets('expand all reveals the whole tree', (WidgetTester tester) async {
      await pumpTree(tester);
      expect(find.text('text1'), findsNothing);

      await tester.tap(find.byIcon(Icons.unfold_more));
      await tester.pumpAndSettle();

      expect(find.text('page'), findsOneWidget);
      expect(find.text('group1'), findsOneWidget);
      expect(find.text('text1'), findsOneWidget);
    });

    testWidgets('collapse all returns to the first level', (WidgetTester tester) async {
      await pumpTree(tester);
      await tester.tap(find.byIcon(Icons.unfold_more));
      await tester.pumpAndSettle();
      expect(find.text('text1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.unfold_less));
      await tester.pumpAndSettle();

      expect(find.text('group1'), findsOneWidget);
      expect(find.text('text1'), findsNothing);
    });

    testWidgets('search shows matches and their ancestors', (WidgetTester tester) async {
      await pumpTree(tester);
      expect(find.text('text1'), findsNothing);

      await tester.enterText(find.byType(TextField), 'text1');
      await tester.pumpAndSettle();

      // The match and its ancestor chain become visible even though the
      // branch is collapsed. The typed query itself lives in the search
      // field, so look for the tree rows inside the list only.
      expect(
        find.descendant(
            of: find.byType(ListView), matching: find.text('text1')),
        findsOneWidget,
      );
      expect(
        find.descendant(
            of: find.byType(ListView), matching: find.text('group1')),
        findsOneWidget,
      );
      // Chevrons are hidden while filtering.
      expect(find.byIcon(Icons.keyboard_arrow_right), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });

    testWidgets('search without matches shows an empty state',
        (WidgetTester tester) async {
      await pumpTree(tester);

      await tester.enterText(find.byType(TextField), 'does-not-exist');
      await tester.pumpAndSettle();

      expect(find.text(FrameForgeStrings.itemsNoMatch), findsOneWidget);
      expect(find.text('group1'), findsNothing);
    });

    testWidgets('clearing search restores the filtered-out tree',
        (WidgetTester tester) async {
      await pumpTree(tester);

      await tester.enterText(find.byType(TextField), 'text1');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Back to the default state: first level only.
      expect(find.text('group1'), findsOneWidget);
      expect(find.text('text1'), findsNothing);
    });

    testWidgets('selecting a nested item on the canvas reveals its branch',
        (WidgetTester tester) async {
      await pumpTree(tester);
      expect(find.text('text1'), findsNothing);

      controller.select(childText.id);
      await tester.pumpAndSettle();

      // The branch expanded automatically and the item is visible.
      expect(find.text('text1'), findsOneWidget);
      expect(controller.selectedId, childText.id);
    });

    testWidgets('tapping a row selects the item', (WidgetTester tester) async {
      await pumpTree(tester);
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right));
      await tester.pumpAndSettle();

      await tester.tap(find.text('text1'));
      await tester.pumpAndSettle();

      expect(controller.selectedId, childText.id);
    });

    testWidgets('tapping a page row switches the editor page',
        (WidgetTester tester) async {
      await pumpTree(tester);
      controller.addPage(name: 'second');
      await tester.pumpAndSettle();

      await tester.tap(find.text('page'));
      await tester.pumpAndSettle();

      expect(controller.selectedId, page.id);
      expect(controller.currentComponentPage, page);
    });

    testWidgets('expansion survives widget rebuilds (session memory)',
        (WidgetTester tester) async {
      await pumpTree(tester);
      await tester.tap(find.byIcon(Icons.keyboard_arrow_right));
      await tester.pumpAndSettle();
      expect(find.text('text1'), findsOneWidget);

      // Recreate the widget from scratch: expanded nodes are remembered.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Items(page, controller)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('text1'), findsOneWidget);
    });
  });
}
