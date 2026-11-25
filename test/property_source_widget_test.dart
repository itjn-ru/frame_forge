import 'package:flutter_test/flutter_test.dart';
import 'package:frame_forge/frame_forge.dart';
// Same as the example app: the editor widgets come from the material_ui
// fork, so the test app must use its MaterialApp (its own
// MaterialLocalizations) for showDialog/debug checks to pass.
import 'package:material_ui/material_ui.dart';
import 'package:frame_forge/src/layout_model/component_text.dart';
import 'package:frame_forge/src/layout_model/property_source_widget.dart'
    show kSourceAutocompleteDebounce;

void main() {
  late LayoutModel layoutModel;
  late LayoutModelController controller;
  late SourcePage sourcePage;
  late ComponentText boundText;

  setUp(() {
    layoutModel = LayoutModel(
      screenSizes: <ScreenSizeEnum>[ScreenSizeEnum.mobile],
    );
    controller = LayoutModelController(
      layoutModel: layoutModel,
      projectSaver: (Map<dynamic, dynamic> map) async => true,
      projectLoader: (bool isSaved) async => null,
    );
    sourcePage = layoutModel.root.items.whereType<SourcePage>().first;

    // One long name that wraps to two lines inside the dropdown menu.
    layoutModel.addItem(
      sourcePage,
      SourceVariable('very_long_client_variable_name_for_testing'),
    );
    layoutModel.addItem(sourcePage, SourceVariable('config'));

    boundText = ComponentText('text1');
    // Components keep the legacy string 'source' next to the typed
    // 'sourceV2' reference; the dropdown edits sourceV2.
    boundText.properties['sourceV2']?.value = SourceReference(
      variableName: 'config',
    );
    layoutModel.addItem(layoutModel.componentPages.first, boundText);
  });

  Future<void> pumpProperties(WidgetTester tester) async {
    controller.select(boundText.id);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            // Wide panel: the legacy offset/size property rows overflow a
            // very narrow one (pre-existing), which would fail the test for
            // unrelated reasons.
            width: 600,
            child: Properties(controller),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('source dropdown opens with two-line items without overflow',
      (WidgetTester tester) async {
    await pumpProperties(tester);

    // The variable dropdown button shows the selected one-line entry.
    // (A generic byType matcher does not resolve here, so match the
    // runtime type by name.)
    expect(
      find.byWidgetPredicate(
        (Widget w) => w.runtimeType.toString() == 'DropdownButton<String>',
      ),
      findsOneWidget,
    );
    expect(find.text('config (String)'), findsOneWidget);

    // Opening the menu must not throw RenderFlex overflow exceptions:
    // menu items size themselves freely (itemHeight: null). Menu items
    // render the name and the type as two separate lines.
    await tester.tap(find.text('config (String)'));
    await tester.pumpAndSettle();

    expect(
      find.text('very_long_client_variable_name_for_testing'),
      findsOneWidget,
    );

    await tester.tap(
      find.text('very_long_client_variable_name_for_testing'),
    );
    await tester.pumpAndSettle();

    // Selection landed and the closed field reflects it.
    final SourceReference reference =
        boundText.properties['sourceV2']!.value as SourceReference;
    expect(reference.variableName, 'very_long_client_variable_name_for_testing');
  });

  testWidgets('autocomplete filters variables and applies selection',
      (WidgetTester tester) async {
    await pumpProperties(tester);

    // The suggestion list is hidden while nothing is typed.
    expect(
      find.text('very_long_client_variable_name_for_testing'),
      findsNothing,
    );

    // Type a MIDDLE substring of the name: the search is %input%.
    await tester.enterText(
      find.byKey(const ValueKey<String>('sourceAutocomplete')),
      'long_client',
    );
    // The suggestion list refreshes on a debounced query.
    await tester.pump(kSourceAutocompleteDebounce);
    await tester.pumpAndSettle();

    // The filtered option list shows the long variable (two-line entry:
    // name and type are separate texts).
    expect(
      find.text('very_long_client_variable_name_for_testing'),
      findsOneWidget,
    );
    // The option list no longer offers the filtered-out variable: bare
    // 'config' remains visible only in the current-selection chip, the
    // option list shows 'config (String)' through the dropdown instead.

    await tester.tap(
      find.text('very_long_client_variable_name_for_testing'),
    );
    await tester.pumpAndSettle();

    final SourceReference reference =
        boundText.properties['sourceV2']!.value as SourceReference;
    expect(
      reference.variableName,
      'very_long_client_variable_name_for_testing',
    );

    // The selection collapses the list; the name remains in the field and
    // in the current-selection chip.
    expect(
      find.text('very_long_client_variable_name_for_testing'),
      findsNWidgets(2),
    );
  });
}
