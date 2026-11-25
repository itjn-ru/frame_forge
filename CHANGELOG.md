# Changelog

## [Unreleased]

### Added

- Autocomplete field in the source property editor (`sourceV2`): typing a
  part of a variable name filters every variable — including those nested
  in groups — with a `%query%` substring match. The suggestions render as
  an inline list right below the field inside the properties panel (no
  overlay), so they stay visible in a narrow panel at any window size.
  Enter picks the first match; Enter with no matching options binds the
  typed name as a new reference; losing focus collapses the list and
  restores the field to the current selection.
- Auto-fill of empty `sourceV2` bindings from the legacy `source` text:
  `LayoutModel.autoFillSourceReferences()` runs on project load and a new
  "fill empty sourceV2" toolbar button in the source table runs it on
  demand. Matching splits both texts into words (CamelCase names split on
  uppercase boundaries), ignores case, tolerates case endings through
  4+ character prefixes (`тягач` ↔ `тягача`) and requires at least two
  matched words; an exact full-text match always wins
  (`source_matcher.dart`, `findBestSourceVariableMatch`).
- `_syncSourceVariables()` removed entirely: importing no longer creates
  variables named after legacy `source` texts. The source page now only
  contains the variables the author actually created; a component whose
  `sourceV2` stays empty keeps the legacy runtime binding
  (`json[source]`) without a matching editor variable. Note: the side
  effect of the removed sync — de-duplicating root-level variables that
  also exist inside groups — is gone too.
- The sourceV2 match threshold is now `source.split(' ').length` — every
  word of the legacy text (case-ending prefixes of 4+ letters still count)
  must be covered by the variable name; the `{…}` hint segment is excluded
  from the word count. The previous fixed threshold of two words is gone.
- Mass deletion in the source table: a checkbox column with a select-all
  header checkbox (respecting the current search/type filter) and a
  "Delete selected (N)" toolbar button with a confirmation dialog; the
  whole batch is one undo step (`MultiDeleteAction`,
  `LayoutModelController.deleteItemsUndoable`).
- Fullscreen spreadsheet-style editor for the data (source) page, opened
  with a new table button in the Data tab toolbar (`Items` tree of a
  `SourcePage`) or programmatically via `showSourceTableEditor`:
  - inline cell editing of name, type, nullable and possible values, the
    same model properties the properties panel edits,
  - collapsible group sections (nested groups are indented), per-section
    add-variable and delete-group buttons, add-variable / add-group in the
    toolbar — all structural changes are undoable (Ctrl+Z),
  - search by name and type filter, group expand-all / collapse-all,
  - Excel-style TSV copy of the visible rows and paste back into new
    variables (columns: name, type, nullable, possible values),
  - renaming a variable updates every component source reference pointing
    at the old name (`LayoutModel.renameSourceVariable`); duplicate names
    are rejected with a snackbar,
  - new undoable controller helpers `insertItemUndoable` and
    `deleteItemUndoable` for arbitrary items.
- `PropertyTextField` gained optional `style` and `onFocusGained` params.

### Fixed

- Editing the `source` property of components: long variable names no
  longer get cut off. The current selection is now a wrapped two-line
  selectable chip with a full-text tooltip, dropdown items wrap their name
  to two lines with the type on a separate line, both dropdowns render as
  compact bordered fields with a height-limited menu, and the map key
  items wrap the same way.
- Source dropdown no longer throws `RenderFlex overflowed by N pixels on
  the bottom` when a long variable name wraps inside the menu: the two
  dropdowns now use `itemHeight: null` so menu items size themselves to
  their content, and the closed field renders a compact one-line selected
  entry via `selectedItemBuilder`.
- The properties panel no longer squeezes widgets into a 100px column:
  `Properties` now uses flexible column widths (label ~40% / widget ~60%)
  with a subtle grid and small grey labels.

### Changed

- `PageList` is now a unified expandable tree of component pages and their
  items, replacing the previous master-detail pair (pages-only list plus a
  separate `Items` tree of the current page):
  - the top level lists the component pages, every page starts collapsed,
  - tapping a page chevron reveals its component tree (nested groups expand
    the same way),
  - tapping a page row makes it current; tapping a component row selects it —
    when the component lives on another page, the editor first switches to
    that page,
  - search filters pages and items by name and auto-reveals matching branches,
  - expand-all / collapse-all toolbar buttons (`showToolbar`, on by default);
    collapse-all restores the default all-collapsed view,
  - selecting an item on the canvas auto-expands the branch up to it,
    highlights the row and scrolls it into view,
  - page rows keep double-tap rename and the right-click page menu
    (rename / duplicate / delete); component rows keep the standard component
    context menu,
  - expanded nodes are remembered per session and survive page switches and
    tab changes; new params `showToolbar` alongside the existing
    `showSearchBar` and `showQuickSwitcher`.

## [1.4.0] - 2026-11-17

### Added

- Collapsible component/item navigation tree — `Items` now renders the
  hierarchy as an expandable list instead of the always-expanded nested tree:
  - per-node expand/collapse chevrons; the first level is visible by default,
  - search field filters items by name and auto-reveals matching branches
    (`showSearchBar`, on by default),
  - expand-all / collapse-all toolbar buttons (`showToolbar`, on by default);
    collapse-all restores the default first-level view,
  - expansion state is remembered per session and survives page switches and
    tab changes,
  - selecting an item on the canvas auto-expands the branch up to it,
    highlights the row and scrolls it into view,
  - the visible tree is flattened into a virtualized fixed-extent list,
  - the tree refreshes on structural events, including undo/redo,
  - tap selects a row, right-click opens the context menu (unchanged),
  - `ItemWidget` is kept unchanged for API compatibility.
- `FrameForgeStrings.itemsSearchHint`, `itemsSearchClear`,
  `itemsExpandAllTooltip`, `itemsCollapseAllTooltip`, `itemsNoMatch`,
  `itemsEmpty` — user-facing strings of the new tree UI (mutable for
  localization like the rest).
- Example app: Pages/Data/Styles tabs use the built-in collapsible tree
  (outer `ListView(shrinkWrap)` wrappers removed — `Items` scrolls itself).
- Widget tests for the collapsible tree (`test/items_tree_test.dart`).

## [1.3.0] - 2026-10-08

### Added

- `FrameForgeStrings` fields are now mutable so a host app can localize the
  built-in editor widgets (`PageList`, quick switcher, rename dialog) once
  at startup — e.g. assigning Russian labels in an admin app.

## [1.2.0] - 2026-10-08

### Added

- Master-detail page navigation for layouts with many component pages (50+):
  - `PageList` widget — searchable, virtualized list of pages with the current page highlighted (theme-aware Material 3 colors), add-page toolbar button, double-tap rename and a context menu (rename / duplicate / delete).
  - `PageQuickSwitcher` + `showPageQuickSwitcher()` — quick page switcher dialog (Ctrl+K) with keyboard navigation over `RawAutocomplete`.
  - `GlobalKeyboardHandler` now opens the quick switcher on Ctrl+K (requires the editor Scaffold to keep `kNodeEditorWidgetKey`).
  - `FrameForgeStrings` — centralized user-facing strings for the new widgets; fields are mutable so a host app can localize the built-in editor widgets once at startup, e.g. assigning Russian labels in the admin app (first step towards full localization, see `doc/ux_audit.md`).
- `LayoutModel.componentPages` — all component pages in order.
- `LayoutModel.nextPageName()` — unique auto-generated page names (`page`, `page 2`, ...).
- `LayoutModel.copyPage()` — deep copy of a page with fresh unique ids.
- `LayoutModelController.switchPage()` — single entry point for switching the current page (updates `curPage`, `curPageType` and selection).
- `LayoutModelController.currentComponentPage` — the component page currently open, with fallbacks when the selection lives outside component pages.
- `LayoutModelController.addPage()` / `duplicatePage()` / `renamePage()` / `deletePage()` — undoable page operations (delete keeps at least one page and selects the neighbour).
- Example app: the Pages tab is now master-detail (`PageList` + component tree of the current page only) instead of the full tree of all pages.
- Tests for page management (`test/page_management_test.dart`).

### Fixed

- `items.dart`: tapping a page row in the tree now switches the editor to that page via `switchPage` (the previous `curPageType is ComponentPage` check was always false).
- `items.dart` / `process_items.dart`: context menu no longer crashes with a null position when opened without a prior mouse hover (menu key / keyboard).

## [1.1.6] - 2026-03-16

### Added

- `SourceReference` class — typed reference to source variables, replacing plain string `source` properties on components. Supports `variableName`, `mapKey`, and `nullable` fields.
- `SourceVariableGroup` — a container for organizing source variables into logical groups within a `SourcePage`. Groups can be nested.
- `SourceVariableType` marker class with a predefined list of supported types (`String`, `int`, `double`, `bool`, `List`, `Map`).
- `nullable` and `possibleValues` properties on `SourceVariable`.
- `PropertySourceWidget` — hierarchical navigator for selecting source variables, with breadcrumb navigation, group drill-down, Map key selection, and nullable toggle.
- `PropertySourceVariableTypeWidget` — dropdown widget for selecting `SourceVariable` type.
- `SourceVariableGroupMenu` — context menu for adding variables and sub-groups inside a group.
- Auto-sync: `LayoutModel` now automatically creates missing `SourceVariable` entries from component source references and removes root-level duplicates that exist inside groups.
- Example JSON button (`TemplateAppbarExampleJsonButton`) — generates and displays a sample JSON based on the current source variable definitions.

### Changed

- All component `source` properties (`ComponentGroup`, `ComponentTable`, `ComponentText`, `FormCheckbox`, `FormExpandbleList`, `FormHiddenField`, `FormRadio`, `FormSliderButton`, `FormTextField`) now use `SourceReference` instead of plain `String`.
- `Item.operator[]` returns `SourceReference.toString()` for source properties to maintain backward compatibility.
- Library exports sorted alphabetically; added exports for `SourceReference`, `SourceVariableGroup`, and `SourceVariableType`.
- `library frame_forge;` changed to `library;` (unnamed library).
- Serialization (`FromMapToMap`) updated to handle `SourceReference` and `SourceVariableType` round-trip.

### Fixed

- Fixed `source` import from XML: when `<source>` has attributes (`variableName`, `mapKey`, `nullable`), correctly extract variable name instead of dumping the raw map
- Fallback: if `sourceV2` is absent, automatically create it from `source` (supports both plain string and Map with attributes)

## [1.1.5] - 2026-01-25

### Added

- image widget with property: fitbox and data as Uint8List

### Changed

- Improved label rendering in FormSliderButtonWidget: the selected label now appears above others, with full width and animation, while other labels dynamically calculate their width and do not overlap. UX is improved for both long and short label lists.

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
