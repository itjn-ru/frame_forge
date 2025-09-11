# Frame Forge

[![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/itjn-ru/frame_forge/blob/main/README.md)
[![ru](https://img.shields.io/badge/lang-ru-blue.svg)](https://github.com/itjn-ru/frame_forge/blob/main/README.ru.md)

## Description

This package offers a visual editor for designing and rendering user interfaces.  
At its core, it uses XML to define the UI structure, making it ideal for applications that rely on structured documents. Originally developed for document-centric workflows, it seamlessly supports Backend-Driven UI (BDUI) architectures, enabling dynamic UI generation from backend data.

## Demo
[Check it out here](https://itjn-ru.github.io/frame_forge/)

## Features

### Visual UI Designer
- **Drag & Drop Interface** - Intuitive visual editor for composing layouts
- **Real-time Preview** - See changes instantly as you design
- **Multi-screen Support** - Design for mobile, tablet, and desktop simultaneously
- **Grid-based Layout** - Precise positioning with snap-to-grid functionality

### Architecture & Integration
- **XML-based Structure** - Clean, readable markup defines UI components and properties
- **BDUI (Backend-Driven UI)** - Server controls the UI without client app updates
- **Dynamic Rendering** - Interface generated from server-provided data at runtime
- **Service-oriented Architecture** - Modular design with dependency injection

### Developer Experience
- **Undo/Redo System** - Full history management with keyboard shortcuts (Ctrl+Z/Ctrl+Y)
- **Copy/Paste Operations** - Duplicate components and layouts efficiently
- **Global Keyboard Handlers** - International keyboard layout support
- **Project Management** - Save/load projects with custom serialization

### Advanced Features
- **Component Library** - Rich set of pre-built UI components achieved through flexible style application system
- **Data Binding** - Connect UI elements to dynamic data sources
- **Style Management** - Centralized styling with theme support
- **Process Workflows** - Define complex UI interactions and flows
- **Responsive Design** - Adaptive layouts for different screen sizes

### Performance & Reliability
- **Efficient Rendering** - Optimized widget tree updates
- **Memory Management** - Smart cleanup and resource management  
- **Error Handling** - Robust error recovery and validation
- **Cross-platform** - Works seamlessly on Web, Mobile, and Desktop

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

If you want to use copy/past/undo/redo from keyboard initialize HardwareKeyboard instance

```dart
void initState() {
    //listen to controller events to update UI
    _layoutModelController.eventBus.events.listen(_handleControllerEvents);
    // Register global keyboard handler
    HardwareKeyboard.instance.addHandler(_layoutModelController.keyboardHandler.handleKeyEvent);
    super.initState();
  }
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
Make sure to specify screen size from [ScreenSizeEnum]
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
