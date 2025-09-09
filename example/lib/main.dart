import 'dart:convert';

import 'package:example/local/web_download_service.dart';
import 'package:example/maket_page_components_column.dart';
import 'package:example/maket_page_example_view.dart';
import 'package:example/maket_page_properties_column.dart';
import 'package:example/template_appbar_export_button.dart';
import 'package:example/template_appbar_import_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:frame_forge/frame_forge.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    BrowserContextMenu.disableContextMenu();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DSL Editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'DSL Editor Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScreenSizeEnum screenSize = ScreenSizeEnum.mobile;
  final LayoutModel layoutModel = LayoutModel(
    screenSizes: [ScreenSizeEnum.mobile, ScreenSizeEnum.desktop],
  );
  late final LayoutModelController _layoutModelController =
      LayoutModelController(
        layoutModel: layoutModel,
        projectSaver: (map) async {
          await WebDownloadService.save(
            body: saveMap(map),
            filename: '${layoutModel.root["name"]} - ${screenSize.title}',
          );
          return true;
        },
        projectLoader: (isSaved) async {
          final FilePickerResult? result = await FilePicker.platform
              .pickFiles();
          if (result == null) {
            return null;
          }
          final PlatformFile file = result.files.first;
          return utf8.decode(file.bytes! as List<int>);
        },
      );
  @override
  void initState() {
    //listen to controller events to update UI
    _layoutModelController.eventBus.events.listen(_handleControllerEvents);
    // Register global keyboard handler
    HardwareKeyboard.instance.addHandler(_layoutModelController.keyboardHandler.handleKeyEvent);
    super.initState();
  }

  void _handleControllerEvents(event) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Remove global keyboard handler
    HardwareKeyboard.instance.removeHandler(_layoutModelController.keyboardHandler.handleKeyEvent);
    _layoutModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: kNodeEditorWidgetKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          TemplateAppbarImportButtonExample(_layoutModelController),
          TemplateAppbarImportButton(_layoutModelController),
          TemplateAppbarExportButton(_layoutModelController),
        ],
      ),
      body: Row(
        children: [
          Flexible(
            flex: 2,
            child: MaketPageComponentsColumn(_layoutModelController),
          ),
          Flexible(
            flex: 2,
            child: MaketPagePropertiesColumn(_layoutModelController),
          ),
          Flexible(
            flex: 2,
            child: MaketPageExampleView(_layoutModelController, screenSize),
          ),
        ],
      ),
    );
  }
}
