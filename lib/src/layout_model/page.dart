import 'item.dart';
import 'screen_size_enum.dart';

/// Abstract base class for pages that contain components and sources
///
/// Represents a page in the layout model that can contain both UI components
/// and data sources. Extends [Item] to inherit base functionality.
class ComponentAndSourcePage extends Item {
  /// Creates a new component and source page
  ///
  /// [type] The type identifier for this page
  /// [name] The display name of the page
  ComponentAndSourcePage(super.type, super.name);
}

// class ScreenSizeLayout extends ComponentAndSourcePage{
//   final ScreenSizeEnum? screenSize;
//   ScreenSizeLayout(super.type, super.name, [this.screenSize = ScreenSizeEnum.mobile]){
//     properties['screenSize']=Property('размер экрана', screenSize, type: ScreenSizeEnum);
//   }
//   @override
//   String toString() {
//     return properties['screenSize']?.value.title??'null';
//   }
// }

/// A page containing UI components for a specific screen size
///
/// Represents a page in the layout model that holds UI components
/// optimized for a particular screen size configuration.
class ComponentPage extends ComponentAndSourcePage {
  /// The screen size this page is optimized for
  final ScreenSizeEnum? screenSize;

  /// Creates a new component page
  ///
  /// [name] The display name of the page
  /// [screenSize] The target screen size (defaults to mobile)
  ComponentPage(String name, [this.screenSize = ScreenSizeEnum.mobile])
    : super("componentPage", name);
}

/// A page containing data sources and variables
///
/// Represents a page in the layout model dedicated to managing
/// data sources, variables, and backend connections.
class SourcePage extends ComponentAndSourcePage {
  /// Creates a new source page
  ///
  /// [name] The display name of the page
  SourcePage(String name) : super("sourcePage", name);
}

/// A page containing style definitions
///
/// Represents a page in the layout model that manages style
/// definitions and theming configurations.
class StylePage extends ComponentAndSourcePage {
  /// Creates a new style page
  ///
  /// [name] The display name of the page
  StylePage(String name) : super("stylePage", name);
}

/// A page containing process definitions and workflows
///
/// Represents a page in the layout model that manages business
/// logic processes and user interaction workflows.
class ProcessPage extends ComponentAndSourcePage {
  /// Creates a new process page
  ///
  /// [name] The display name of the page
  /// [viewport] Optional viewport configuration for the process canvas
  ProcessPage(String name, {this.viewport}) : super("processPage", name);

  /// Viewport configuration for the process canvas
  ///
  /// Contains offset and zoom settings for the process editor view.
  Map<String, dynamic>? viewport = {
    "offset": <double>[0.0, 0.0],
    "zoom": 1.0,
  };
}
