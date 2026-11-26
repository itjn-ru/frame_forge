import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frame_forge/frame_forge.dart';
// The editor dialogs come from the material_ui fork, which ships its own
// MaterialLocalizations — the test app must be built with the same fork
// (the same way the example app does) or showDialog fails its debug check.
import 'package:material_ui/material_ui.dart';
import 'package:frame_forge/src/layout_model/component_text.dart';
import 'package:frame_forge/src/layout_model/property_source_widget.dart'
    show kSourceAutocompleteDebounce;

void main() {
  late LayoutModel layoutModel;
  late LayoutModelController controller;
  late SourcePage sourcePage;
  late ComponentPage componentPage;
  late ComponentText boundText;
  late SourceVariable clientName;
  late SourceVariable config;
  late SourceVariable apiUrl;
  late SourceVariableGroup profileGroup;
  late SourceVariable email;

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
    componentPage = layoutModel.componentPages.first;

    clientName = SourceVariable('client_name');
    config = SourceVariable('config');
    config.properties['type']?.value = const SourceVariableType('Map');
    apiUrl = SourceVariable('api_url');
    layoutModel.addItem(sourcePage, clientName);
    layoutModel.addItem(sourcePage, config);
    layoutModel.addItem(config, apiUrl);

    profileGroup = SourceVariableGroup('Profile group');
    layoutModel.addItem(sourcePage, profileGroup);
    email = SourceVariable('email');
    layoutModel.addItem(profileGroup, email);

    // A component bound to client_name through the built-in source property.
    boundText = ComponentText('text1');
    // Components keep the typed reference in 'sourceV2' — the legacy
    // 'source' property is a plain String label.
    boundText.properties['sourceV2']?.value = SourceReference(
      variableName: 'client_name',
    );
    layoutModel.addItem(componentPage, boundText);
  });

  SourceReference boundReference() =>
      boundText.properties['sourceV2']!.value as SourceReference;

  group('LayoutModel.renameSourceVariable', () {
    test('updates component source references', () {
      clientName.properties['name']?.value = 'client_full_name';
      layoutModel.renameSourceVariable('client_name', 'client_full_name');

      expect(boundReference().variableName, 'client_full_name');
      expect(boundReference().mapKey, '');
    });

    test('updates map keys of Map children', () {
      boundText.properties['sourceV2']?.value = SourceReference(
        variableName: 'config',
        mapKey: 'api_url',
      );
      apiUrl.properties['name']?.value = 'api_endpoint';
      layoutModel.renameSourceVariable(
        'api_url',
        'api_endpoint',
        parentName: 'config',
      );
      expect(boundReference().variableName, 'config');
      expect(boundReference().mapKey, 'api_endpoint');
    });

    test('ignores empty and identical names', () {
      layoutModel.renameSourceVariable('', 'other');
      layoutModel.renameSourceVariable('client_name', 'client_name');

      expect(boundReference().variableName, 'client_name');
    });
  });

  group('SourceTableEditor', () {
    Future<void> openEditor(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => Center(
                child: ElevatedButton(
                  onPressed: () => showSourceTableEditor(context, controller),
                  child: const Text('open-editor'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open-editor'));
      await tester.pumpAndSettle();
    }

    void unfocus(WidgetTester tester) {
      tester.binding.focusManager.primaryFocus?.unfocus();
    }

    testWidgets('shows sections and root variables',
        (WidgetTester tester) async {
      await openEditor(tester);

      // Sections start expanded so the table shows all data immediately.
      expect(find.text(FrameForgeStrings.sourceTableUngrouped),
          findsOneWidget);
      expect(find.text('Profile group'), findsOneWidget);
      expect(find.text('client_name'), findsOneWidget);
      expect(find.text('email'), findsOneWidget);
    });

    testWidgets('collapses and expands a group section',
        (WidgetTester tester) async {
      await openEditor(tester);

      final Finder section = find.byKey(
        ValueKey<String>('section:${profileGroup.id}'),
      );

      await tester.tap(
        find.descendant(
          of: section,
          matching: find.byIcon(Icons.keyboard_arrow_down),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('email'), findsNothing);

      await tester.tap(
        find.descendant(
          of: section,
          matching: find.byIcon(Icons.keyboard_arrow_right),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('email'), findsOneWidget);
    });

    testWidgets('renames a variable and syncs component references',
        (WidgetTester tester) async {
      await openEditor(tester);

      await tester.enterText(find.text('client_name'), 'client_full_name');
      unfocus(tester);
      await tester.pumpAndSettle();

      expect(clientName.properties['name']?.value, 'client_full_name');
      expect(boundReference().variableName, 'client_full_name');
    });

    testWidgets('rejects duplicate variable names', (WidgetTester tester) async {
      await openEditor(tester);

      await tester.enterText(find.text('client_name'), 'config');
      unfocus(tester);
      await tester.pumpAndSettle();

      // Reverted to the old name with a snackbar explanation.
      expect(clientName.properties['name']?.value, 'client_name');
      expect(
        find.text(FrameForgeStrings.sourceTableDuplicateName),
        findsOneWidget,
      );
    });

    testWidgets('adds a variable undoable', (WidgetTester tester) async {
      await openEditor(tester);

      await tester.tap(
        find.byTooltip(FrameForgeStrings.sourceTableAddVariableTooltip).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('variable'), findsOneWidget);

      controller.undo();
      await tester.pumpAndSettle();
      expect(find.text('variable'), findsNothing);
    });

    testWidgets('changes variable type from the cell dropdown',
        (WidgetTester tester) async {
      await openEditor(tester);

      await tester.tap(find.text('String').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('int').last);
      await tester.pumpAndSettle();

      expect(
        (clientName.properties['type']?.value as SourceVariableType).value,
        'int',
      );
    });

    testWidgets('search filters variables', (WidgetTester tester) async {
      await openEditor(tester);

      await tester.enterText(
        find.byKey(const ValueKey<String>('sourceTableSearch')),
        'client',
      );
      // The list refreshes on a debounced query.
      await tester.pump(kSourceAutocompleteDebounce);
      await tester.pumpAndSettle();

      expect(find.text('client_name'), findsOneWidget);
      expect(find.text('config'), findsNothing);
      expect(find.text('Profile group'), findsNothing);
    });

    testWidgets('copies visible rows as TSV', (WidgetTester tester) async {
      // Intercept the platform clipboard channel: reading the real channel
      // from inside the fake-async test zone never completes.
      String? copied;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (
        MethodCall call,
      ) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      await openEditor(tester);

      await tester.tap(
        find.byTooltip(FrameForgeStrings.sourceTableCopyTooltip),
      );
      await tester.pumpAndSettle();

      expect(copied, isNotNull);
      expect(copied, contains('client_name\tString\ttrue'));
      expect(copied, contains('config\tMap\ttrue'));
    });

    testWidgets('deletes a row and restores it with undo',
        (WidgetTester tester) async {
      await openEditor(tester);

      await tester.tap(
        find.byTooltip(FrameForgeStrings.sourceTableDeleteTooltip).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('client_name'), findsNothing);
      expect(sourcePage.items, isNot(contains(clientName)));

      controller.undo();
      await tester.pumpAndSettle();
      expect(find.text('client_name'), findsOneWidget);
      expect(sourcePage.items, contains(clientName));
    });

    testWidgets('mass deletes checked variables with a single undo',
        (WidgetTester tester) async {
      await openEditor(tester);

      // Check two of the three visible variables (email is collapsed).
      await tester.tap(find.byKey(ValueKey<String>('check:${clientName.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey<String>('check:${config.id}')));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byTooltip(
          FrameForgeStrings.sourceTableDeleteSelected(2),
        ),
      );
      await tester.pumpAndSettle();

      // Confirmation dialog.
      expect(
        find.text(FrameForgeStrings.sourceTableDeleteSelectedTitle(2)),
        findsOneWidget,
      );
      await tester.tap(
        find.text(FrameForgeStrings.sourceTableConfirmDelete).last,
      );
      await tester.pumpAndSettle();

      expect(sourcePage.items, isNot(contains(clientName)));
      expect(sourcePage.items, isNot(contains(config)));

      // One Ctrl+Z restores the whole batch.
      controller.undo();
      await tester.pumpAndSettle();
      expect(sourcePage.items, contains(clientName));
      expect(sourcePage.items, contains(config));
    });

    testWidgets('select-all checkbox checks every visible row',
        (WidgetTester tester) async {
      await openEditor(tester);

      await tester.tap(
        find.byKey(const ValueKey<String>('sourceTableSelectAll')),
      );
      await tester.pumpAndSettle();

      // Sections start expanded, so all three variables are visible and
      // the delete button shows the full count.
      expect(
        find.byTooltip(FrameForgeStrings.sourceTableDeleteSelected(3)),
        findsOneWidget,
      );
    });

    testWidgets('auto-fill binds empty sourceV2 from legacy source text',
        (WidgetTester tester) async {
      // A component with a legacy source text and an empty typed binding.
      final ComponentText legacyText = ComponentText('legacy');
      legacyText.properties['source']?.value =
          'Двигатель тягача {радиокнопка}';
      layoutModel.addItem(componentPage, legacyText);
      final SourceVariable engine =
          SourceVariable('ТягачДвигательСостояние');
      layoutModel.addItem(sourcePage, engine);

      await openEditor(tester);

      await tester.tap(
        find.byTooltip(FrameForgeStrings.sourceTableAutoFillTooltip),
      );
      await tester.pumpAndSettle();

      final SourceReference reference =
          legacyText.properties['sourceV2']!.value as SourceReference;
      expect(reference.variableName, 'ТягачДвигательСостояние');
    });
  });
}
