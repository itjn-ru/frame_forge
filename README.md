# Frame Forge

[![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/itjn-ru/layout_editor/blob/frame_forge/README.md)
[![ru](https://img.shields.io/badge/lang-ru-blue.svg)](https://github.com/itjn-ru/layout_editor/blob/frame_forge/README.ru.md)

## Description

This package provides a visual editor for designing and rendering user interfaces.
Its core concept is using XML as the structure definition for UI. Originally built for documents and structured data, it is well suited for applications following the BDUI (Backend-Driven UI) architecture.

Features:
📌 XML markup defines UI components and their properties.
📌 UI designer to visually compose UI and export it as XML.
📌 Dynamic rendering — the interface is generated from server-provided data without updating the client app.
📌 Ideal for applications where the UI changes frequently and must be controlled by the server.

## Motivation

Change UI and data exchange with the client application server without code changes or app store updates.
![admin-layout-photo](./doc/images/admin-layout-photo.png)

## Installation

Add dependency to your `pubspec.yaml`:

```yaml
dependencies:
  frame_forge: ^1.0.0
```

## Usage

### Create DSL Model
- Add required screen sizes for LayoutModel.
- Create controller

```dart
  final LayoutModel layoutModel = LayoutModel(
    screenSizes: [ScreenSizeEnum.mobile, ScreenSizeEnum.desktop],
  );
  
  late final LayoutModelController _layoutModelController =
      LayoutModelController(
        layoutModel: layoutModel,
        projectSaver: (map) async {
          // Configure project saving here
          return true;
        },
        projectLoader: (isSaved) async {
          /// Load model from file
          final FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result == null) return null;
          final PlatformFile file = result.files.first;
          return utf8.decode(file.bytes! as List<int>);
        },
      );
```

### Main Components

Output layout components:
```dart
Column(
  children: [
    Items(layoutModel.root, layoutModel),
  ],
),
```

Output layout data sources/variables:
```dart
Column(
  children: [
    Items(
        layoutModel.root.items
            .whereType<SourcePage>()
            .first, layoutModel,
    ),
  ],
),
```

Output layout styles:
```dart
Column(
  children: [
    Items(
        layoutModel.root.items
            .whereType<StylePage>()
            .first, layoutModel, 
    ),
  ],
),
```

Output layout processes:
```dart
Column(
  children: [
    ProcessItems(
        layoutModel.root.items
            .whereType<ProcessPage>()
            .first,layoutModel,
    ),
  ],
),
```

Output preview - how the page looks
Make sure to specify screen size from [enum ScreenSizeEnum]
```dart
LayoutBuilder(
    builder: (context, constraints) {
        return Consumer<LayoutModel>(
            builder: (context, value, child) {
                return ComponentsAndSources(value,constraints, screenSize);
            },
        );
    }
),
```
