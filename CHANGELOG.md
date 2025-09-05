# Changelog

## [1.0.2] - 2025-09-05
### Documentation
- Enhanced API documentation coverage with comprehensive dartdoc comments
- Improved public API documentation for better pub.dev compliance
- Added detailed class descriptions and parameter documentation

### Technical
- Fixed vector_math dependency constraint to be more flexible
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
