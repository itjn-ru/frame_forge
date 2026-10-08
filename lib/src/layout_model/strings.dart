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
}