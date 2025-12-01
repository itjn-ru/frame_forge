# Changelog

## [1.1.4] - 2025-12-01

### Added

- active colors for thumb for slider button

## [1.1.3] - 2025-12-01

### Added

- `hintText` and `initialValue` for FormSliderButton
- `isRequired` (boolean) property for `FormTextField` to mark fields as required.
- `function` and `inputId` properties in `Root` for handle template data via a user-defined function.

### Changed

- `inputId` property now supports multiple IDs (`List<String>`) with graceful backward compatibility for legacy single `String` values.

### Fixed

- Normalized dynamic list values in `PropertyListWidget` to avoid type cast errors when legacy data provides a single `String` or nested list structure.
- Fixed `fromMap` deserialization to preserve constructor default properties (`textFunction`, `link`, `inputId`) when loading legacy data without these fields. Properties from constructors now merge with loaded data instead of being discarded.

## [1.1.2] - 2025-11-19

### Added

- `PropertyBoolWidget` — a new property editor widget for boolean attributes.
- `isRequired` (boolean) property for `FormTextField` to mark fields as required.
- `textFunction` property in `ComponentText` for generating text via a user-defined function.
- `inputId` property in `ComponentText` to link a text component to an input field.
- `source` property and unified property keys (`text`, `source`, `alignment`).
- `alignment` property added to `FormTextField` (text alignment).

### Changed

- Interface property keys and labels migrated to English (`lang change to en`).
- Updated example `example/web/index.html` (metadata/structure updates).

### Removed

- `lib/src/layout_model/item_list_wrapper.dart` removed.
- `lib/src/layout_model/mobile_download_service.dart` removed.

### Refactor

- Consolidated and standardized text and form component properties (consistent keys and naming).

## [1.1.1] - 2025-09-11

- Fixed text alignment in components
- Fixed keyboard handler to avoid conflicts with text field editing
- Сhanged source component

## [1.1.0] - 2025-09-10

- fix borderRadius error in new stylePage
- remove border attributes from componentGroup
- fix menu actions: copy, cut
- add controller for resize and move
- add show the selected item on top
- add service-oriented architecture with dependency injection
- implement global keyboard handler with international layout support
- add undo/redo system
- add comprehensive interface abstractions
- update documentation with detailed features
- fix Russian keyboard layout compatibility (Ctrl+Z -> Ctrl+Я)

## [1.0.2] - 2025-09-08

- fix switch between ComponentPage
- fix textAlignt in ComponentText
- add to Style "BorderSide" (LTRB)
- fix view of TextComponent
- add a decoration widget as a wrapper for components and implement it in ComponentTextWidget, ComponentGroup, SliderButton
- add attributes for SliderButton: activeColor, inactiveColor, thumbColor
- fix resize and move events to register in controller only on end
- enhanced API documentation coverage with comprehensive dartdoc comments
- canvas rendering optimization
- add to controller: move/moveById/resize/resizeById methods and sealed ChangeItem with ChangeEvent, MoveEvent, ResizeEvent, AttributeChangeEvent. Move business logic out of UI.
- refactor new event type of properties, add reusable textfield like size, offset, padding, marging, border, borderRadius and InputTextPropertyWidget
- add compatibility for border radius values from older versions
- improved public API documentation for better pub.dev compliance
- added detailed class descriptions and parameter documentation

### Technical

- Code formatting improvements across all files

## [1.0.1] - 2025-09-05

- Multi-language documentation (English and Russian)
- MIT license

### Changed

- Migrated from deprecated `dart:html` to modern `package:web` for web compatibility
- Improved static analysis compliance
- Enhanced cross-platform file operations with conditional imports

### Technical

- Universal file picker service with platform-specific implementations:
  - Web: HTML5 File API with modern web standards
  - Mobile/Desktop: file_picker package for native functionality
- Event bus system for component communication
- Controller-based architecture for better separation of concerns
- Comprehensive static analysis fixes

### Repository

- Migrated from `layout_editor` to dedicated `frame_forge` repository
- Updated package configuration and dependencies
- Added proper pub.dev compliance

## 1.0.0

- Initial release of Frame Forge - DSL Model with UI editor
- Added layout model controller and components
- Support for mobile and desktop screen sizes
- File import/export functionality
- Canvas with drag and drop support
- Component styling and theming
- Form field components (text fields, checkboxes, radio buttons, etc.)
- Expandable widget implementation without rxdart dependency
- Removed heavy dependencies (rxdart, dio, permission_handler) for lighter package

## [0.0.1] - Initial Development

### Added

- Initial development version
- Basic project structure
- Core components foundation
