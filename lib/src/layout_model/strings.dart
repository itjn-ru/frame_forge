/// Centralized user-facing strings for Frame Forge widgets.
///
/// New editor widgets take their labels from here so the wording stays
/// consistent and can later be swapped for a full localization delegate
/// (see doc/ux_audit.md, P0-5).
class FrameForgeStrings {
  FrameForgeStrings._();

  // Page list (master-detail navigation)
  static const String pageSearchHint = 'Search pages';
  static const String pageSearchClear = 'Clear search';
  static const String newPageTooltip = 'New page';
  static const String quickSwitcherTooltip = 'Quick page switcher (Ctrl+K)';
  static const String noPages = 'No pages yet';
  static const String noPagesFound = 'No pages found';
  static const String currentPageBadge = 'Current page';

  // Page context menu
  static const String pageMenuRename = 'Rename';
  static const String pageMenuDuplicate = 'Duplicate';
  static const String pageMenuDelete = 'Delete';

  // Rename dialog
  static const String renameDialogTitle = 'Rename page';
  static const String renameDialogLabel = 'Page name';
  static const String renameDialogCancel = 'Cancel';
  static const String renameDialogSave = 'Save';

  // Quick switcher
  static const String quickSwitcherTitle = 'Go to page';
  static const String quickSwitcherHint = 'Type a page name...';
  static const String quickSwitcherEmpty = 'No matching pages';
}