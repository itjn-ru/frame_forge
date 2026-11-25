/// Centralized user-facing strings for Frame Forge widgets.
///
/// New editor widgets take their labels from here so the wording stays
/// consistent in one place. The fields are intentionally mutable so a
/// host app can localize the built-in editor widgets once at startup:
///
/// ```dart
/// FrameForgeStrings.pageSearchHint = 'Поиск страницы';
/// ```
///
/// See doc/ux_audit.md (P0-5) for the full localization roadmap.
class FrameForgeStrings {
  FrameForgeStrings._();

  // Page list (master-detail navigation)
  static String pageSearchHint = 'Search pages';
  static String pageSearchClear = 'Clear search';
  static String newPageTooltip = 'New page';
  static String quickSwitcherTooltip =
      'Quick page switcher (Ctrl+K)';
  static String noPages = 'No pages yet';
  static String noPagesFound = 'No pages found';
  static String currentPageBadge = 'Current page';

  // Page context menu
  static String pageMenuRename = 'Rename';
  static String pageMenuDuplicate = 'Duplicate';
  static String pageMenuDelete = 'Delete';

  // Rename dialog
  static String renameDialogTitle = 'Rename page';
  static String renameDialogLabel = 'Page name';
  static String renameDialogCancel = 'Cancel';
  static String renameDialogSave = 'Save';

  // Quick switcher
  static String quickSwitcherTitle = 'Go to page';
  static String quickSwitcherHint = 'Type a page name...';
  static String quickSwitcherEmpty = 'No matching pages';

  // Items tree (collapsible component navigation)
  static String itemsSearchHint = 'Search items';
  static String itemsSearchClear = 'Clear search';
  static String itemsExpandAllTooltip = 'Expand all';
  static String itemsCollapseAllTooltip = 'Collapse all';
  static String itemsNoMatch = 'No matching items';
  static String itemsEmpty = 'No items';

  // Source page table editor (fullscreen spreadsheet view)
  static String sourceTableOpenTooltip = 'Open as table (fullscreen)';
  static String sourceTableCloseTooltip = 'Close (Esc)';
  static String sourceTableTitle = 'Data sources';
  static String sourceTableSearchHint = 'Search variables';
  static String sourceTableTypeAll = 'All types';
  static String sourceTableTypeFilterTooltip = 'Filter by type';
  static String sourceTableExpandAllTooltip = 'Expand all groups';
  static String sourceTableCollapseAllTooltip = 'Collapse all groups';
  static String sourceTableCopyTooltip =
      'Copy visible rows for Excel (TSV)';
  static String sourceTablePasteTooltip =
      'Paste rows from Excel (TSV: name, type, nullable, possible values)';
  static String sourceTableAddVariableTooltip = 'Add variable';
  static String sourceTableAddGroupTooltip = 'Add group';
  static String sourceTableAddVariableToGroupTooltip =
      'Add variable to this group';
  static String sourceTableDeleteTooltip = 'Delete';
  static String sourceTableDeleteGroupTooltip = 'Delete group';
  static String sourceTableRenameTooltip = 'Click to rename';
  static String sourceTableUngrouped = 'Ungrouped';
  static String sourceTableColumnName = 'Name';
  static String sourceTableColumnType = 'Type';
  static String sourceTableColumnNullable = 'Nullable';
  static String sourceTableColumnPossibleValues = 'Possible values';
  static String sourceTableEmpty = 'No variables yet';
  static String sourceTableEmptyHint =
      'Use the + buttons or paste rows from Excel';
  static String sourceTableNoMatch = 'No variables match the search';
  static String sourceTableVariableCount(int count) =>
      '$count ${count == 1 ? 'variable' : 'variables'}';
  static String sourceTableCopied(int count) =>
      'Copied $count ${count == 1 ? 'row' : 'rows'}';
  static String sourceTablePasteEmpty =
      'Clipboard has no table rows (expected TSV columns: name, type, nullable, possible values)';
  static String sourceTablePasteResult(int added, int skipped) =>
      'Added $added, skipped $skipped (duplicate or empty names)';
  static String sourceTableDuplicateName = 'A variable with this name already exists';

  // Mass selection in the source table
  static String sourceTableDeleteSelectedTooltip = 'Delete selected';
  static String sourceTableDeleteSelected(int count) =>
      'Delete selected ($count)';
  static String sourceTableDeleteSelectedTitle(int count) =>
      'Delete $count ${count == 1 ? 'variable' : 'variables'}?';
  static String sourceTableDeleteSelectedBody =
      'The variables are removed together with their values. '
      'Ctrl+Z restores everything.';
  static String sourceTableConfirmDelete = 'Delete';
  static String sourceTableConfirmCancel = 'Cancel';
  static String sourceTableDeletedBatch(int count) =>
      'Deleted $count ${count == 1 ? 'variable' : 'variables'} (Ctrl+Z restores)';

  // Auto-fill of empty sourceV2 references from legacy source texts
  static String sourceTableAutoFillTooltip =
      'Fill empty sourceV2 bindings from source text (match by words)';
  static String sourceTableAutoFillResult(int count) =>
      'Updated $count ${count == 1 ? 'binding' : 'bindings'}';
  static String sourceTableAutoFillEmpty =
      'No empty sourceV2 bindings to fill';

  // Autocomplete field of the source property editor
  static String sourceAutocompleteHint = 'Find variable…';
}