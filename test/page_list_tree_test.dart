import 'package:flutter/gestures.dart' show kDoubleTapMinTime, kDoubleTapTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frame_forge/frame_forge.dart';

/// Taps a row and waits past the double-tap disambiguation window: page rows
/// have an onDoubleTap handler, which delays the plain onTap by kDoubleTapTimeout.
Future<void> tapRow(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(kDoubleTapTimeout);
  await tester.pumpAndSettle();
}

/// Performs a double tap on [finder]: two quick taps separated by
/// kDoubleTapMinTime (WidgetTester has no doubleTap helper).
Future<void> doubleTapRow(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(kDoubleTapMinTime);
  await tester.tap(finder);
  await tester.pump(kDoubleTapTimeout);
  await tester.pumpAndSettle();
}

void main() {
  late LayoutModel layoutModel;
  late LayoutModelController controller;
  late ComponentPage page;
  late ComponentPage secondPage;
  late LayoutComponent parentGroup;
  late LayoutComponent childText;
  late LayoutComponent secondPageText;

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
    secondPage = ComponentPage('second');
    layoutModel.addItem(layoutModel.root, secondPage);
    parentGroup = LayoutComponent('group', 'group1');
    childText = LayoutComponent('text', 'text1');
    layoutModel.addItem(page, parentGroup);
    layoutModel.addItem(parentGroup, childText);
    secondPageText = LayoutComponent('text', 'text2');
    layoutModel.addItem(secondPage, secondPageText);
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

  group('PageList unified tree', () {
    testWidgets('starts fully collapsed: only page rows are visible',
        (WidgetTester tester) async {
      await pumpTree(tester);

      expect(find.text('page'), findsOneWidget);
      expect(find.text('second'), findsOneWidget);
      expect(find.text('group1'), findsNothing);
      expect(find.text('text1'), findsNothing);
    });

    testWidgets('expands a page branch on chevron tap',
        (WidgetTester tester) async {
      await pumpTree(tester);

      // Both pages are collapsed: two right-pointing chevrons.
      expect(find.byIcon(Icons.keyboard_arrow_right), findsNWidgets(2));
      await tapRow(tester, find.byIcon(Icons.keyboard_arrow_right).first);

      expect(find.text('group1'), findsOneWidget);
      // Deeper levels stay collapsed until their own chevron is tapped.
      expect(find.text('text1'), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('tapping a page row switches the editor page',
        (WidgetTester tester) async {
      await pumpTree(tester);

      await tapRow(tester, find.text('second'));

      expect(controller.currentComponentPage, secondPage);
      expect(controller.selectedId, secondPage.id);
    });

    testWidgets(
        'tapping a component of another page switches to that page and selects it',
        (WidgetTester tester) async {
      await pumpTree(tester);

      // Expand the second page, then tap its component.
      await tapRow(tester, find.byIcon(Icons.keyboard_arrow_right).at(1));
      await tapRow(tester, find.text('text2'));

      expect(controller.currentComponentPage, secondPage);
      expect(controller.selectedId, secondPageText.id);
    });

    testWidgets('expand all reveals every level', (WidgetTester tester) async {
      await pumpTree(tester);
      expect(find.text('text1'), findsNothing);

      await tapRow(tester, find.byIcon(Icons.unfold_more));

      expect(find.text('group1'), findsOneWidget);
      expect(find.text('text1'), findsOneWidget);
      expect(find.text('text2'), findsOneWidget);
    });

    testWidgets('collapse all hides all component rows',
        (WidgetTester tester) async {
      await pumpTree(tester);
      await tapRow(tester, find.byIcon(Icons.unfold_more));
      expect(find.text('text1'), findsOneWidget);

      await tapRow(tester, find.byIcon(Icons.unfold_less));

      expect(find.text('page'), findsOneWidget);
      expect(find.text('second'), findsOneWidget);
      expect(find.text('group1'), findsNothing);
      expect(find.text('text1'), findsNothing);
    });

    testWidgets('search shows matches and their ancestors',
        (WidgetTester tester) async {
      await pumpTree(tester);

      await tester.enterText(find.byType(TextField), 'text1');
      await tester.pumpAndSettle();

      // The page and the ancestor chain of the match stay visible...
      expect(
        find.descendant(
            of: find.byType(ListView), matching: find.text('page')),
        findsOneWidget,
      );
      expect(
        find.descendant(
            of: find.byType(ListView), matching: find.text('group1')),
        findsOneWidget,
      );
      expect(
        find.descendant(
            of: find.byType(ListView), matching: find.text('text1')),
        findsOneWidget,
      );
      // ...while the non-matching page is filtered out.
      expect(
        find.descendant(
            of: find.byType(ListView), matching: find.text('second')),
        findsNothing,
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

      expect(find.text(FrameForgeStrings.noPagesFound), findsOneWidget);
      expect(find.text('group1'), findsNothing);
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

    testWidgets('expansion survives widget rebuilds (session memory)',
        (WidgetTester tester) async {
      await pumpTree(tester);
      await tapRow(tester, find.byIcon(Icons.keyboard_arrow_right).first);
      expect(find.text('group1'), findsOneWidget);

      // Recreate the widget from scratch: expanded nodes are remembered.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageList(controller, showQuickSwitcher: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('group1'), findsOneWidget);
    });

    testWidgets('double-tap on a page row opens the rename dialog',
        (WidgetTester tester) async {
      await pumpTree(tester);

      await doubleTapRow(tester, find.text('page'));
      await tester.pumpAndSettle();

      expect(find.text(FrameForgeStrings.renameDialogTitle), findsOneWidget);
      // Close the dialog without renaming.
      await tapRow(tester, find.text(FrameForgeStrings.renameDialogCancel));
      expect(find.text(FrameForgeStrings.renameDialogTitle), findsNothing);
    });
  });
}
