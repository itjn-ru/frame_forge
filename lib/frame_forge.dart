/// A Flutter package for creating dynamic UI layouts with a visual editor.
///
/// Frame Forge provides tools to build and modify app interfaces using
/// drag-and-drop components without requiring code changes. Perfect for
/// creating dynamic layouts that can be modified at runtime.
///
/// ## Main Components
///
/// - [LayoutModel] - Core model for managing UI components
/// - [LayoutModelController] - Controller for handling layout operations
/// - [ComponentWidget] - Base widget for rendering components
/// - [LayoutModelEvent] - Events system for component interactions
///
/// ## Example Usage
///
/// ```dart
/// final layoutModel = LayoutModel(
///   screenSizes: [ScreenSizeEnum.mobile, ScreenSizeEnum.desktop],
/// );
///
/// final controller = LayoutModelController(
///   layoutModel: layoutModel,
///   projectSaver: (map) async => true,
///   projectLoader: (isSaved) async => null,
/// );
/// ```
library frame_forge;

export 'src/layout_model/layout_model.dart';
export 'src/layout_model/file.dart';
export 'src/layout_model/component.dart';
export 'src/layout_model/component_table.dart';
export 'src/layout_model/style.dart';
export 'src/layout_model/item.dart';
export 'src/layout_model/items.dart';
export 'src/layout_model/page.dart';
export 'src/layout_model/components_and_sources.dart';
export 'src/layout_model/component_widget.dart';
export 'src/layout_model/source_table.dart';
export 'src/layout_model/source_variable.dart';
export 'src/layout_model/properties.dart';
export 'src/layout_model/menu.dart';
export 'src/layout_model/process_items.dart';
export 'src/layout_model/controller/layout_model_controller.dart';
export 'src/layout_model/controller/project.dart';
export 'src/layout_model/controller/helpers/constants.dart';
export 'src/layout_model/controller/events.dart';
export 'src/layout_model/screen_size_enum.dart';
