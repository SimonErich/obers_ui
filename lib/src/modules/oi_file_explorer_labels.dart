import 'package:obers_ui/src/components/dialogs/oi_delete_dialog.dart';
import 'package:obers_ui/src/components/dialogs/oi_move_dialog.dart';
import 'package:obers_ui/src/components/dialogs/oi_upload_dialog.dart';
import 'package:obers_ui/src/composites/files/oi_file_grid_view.dart';
import 'package:obers_ui/src/composites/files/oi_file_list_view.dart';
import 'package:obers_ui/src/composites/files/oi_file_sidebar.dart';
import 'package:obers_ui/src/modules/oi_file_explorer.dart';

/// The texts of an [OiFileExplorer], in English by default; pass
/// translations to localize the explorer.
///
/// Holds the explorer's own texts, the texts of the views and dialogs it
/// shows ([gridView], [listView], [sidebar], [deleteDialog], [moveDialog],
/// [uploadDialog]), its keyboard shortcuts ([shortcuts]) and what it
/// announces to screen readers ([announcements]).
///
/// {@category Modules}
class OiFileExplorerLabels {
  /// Creates an [OiFileExplorerLabels].
  const OiFileExplorerLabels({
    this.rootFolder = 'Home',
    this.newFolderName = 'New Folder',
    this.toolbar = 'File explorer toolbar',
    this.searchFiles = 'Search files',
    this.search = 'Search',
    this.closeSearch = 'Close search',
    this.viewMode = 'View mode',
    this.listView = 'List view',
    this.gridView = 'Grid view',
    this.uploadFile = 'Upload File',
    this.uploadFiles = 'Upload files',
    this.addNewFolder = 'Add New Folder',
    this.newFolder = 'New folder',
    this.selectedCount = englishSelectedCount,
    this.move = 'Move',
    this.copy = 'Copy',
    this.delete = 'Delete',
    this.clear = 'Clear',
    this.open = 'Open',
    this.preview = 'Preview',
    this.rename = 'Rename',
    this.moveTo = 'Move to...',
    this.copyTo = 'Copy to...',
    this.download = 'Download',
    this.share = 'Share',
    this.selectAll = 'Select all',
    this.clearSelection = 'Clear selection',
    this.noMatches = englishNoMatches,
    this.clearSearch = 'Clear search',
    this.emptyFolder = 'This folder is empty',
    this.emptyFolderMenu = 'Empty folder context menu',
    this.sidebarLabel = 'File explorer sidebar',
    this.listWithCount = englishListWithCount,
    this.gridWithCount = englishGridWithCount,
    this.deleteConfirmation = 'Delete confirmation',
    this.moveDialogLabel = 'Move dialog',
    this.copyDialogLabel = 'Copy dialog',
    this.uploadDialogLabel = 'Upload dialog',
    this.newFolderTitle = 'New Folder',
    this.folderName = 'Folder name',
    this.cancel = 'Cancel',
    this.apply = 'Apply',
    this.gridViewLabels = const OiFileGridViewLabels(),
    this.listViewLabels = const OiFileListViewLabels(),
    this.sidebar = const OiFileSidebarLabels(),
    this.deleteDialog = const OiDeleteDialogLabels(),
    this.moveDialog = const OiMoveDialogLabels(),
    this.uploadDialog = const OiUploadDialogLabels(),
    this.shortcuts = const OiFileExplorerShortcutLabels(),
    this.announcements = const OiFileExplorerAnnouncements(),
  });

  /// "3 selected": the default [selectedCount].
  static String englishSelectedCount(int count) => '$count selected';

  /// "No files match 'report'": the default [noMatches].
  static String englishNoMatches(String query) => "No files match '$query'";

  /// "File list with 12 items": the default [listWithCount].
  static String englishListWithCount(int count) =>
      'File list with $count items';

  /// "File grid with 12 items": the default [gridWithCount].
  static String englishGridWithCount(int count) =>
      'File grid with $count items';

  /// Name of the top folder, shown first in the path bar.
  final String rootFolder;

  /// Name a new folder gets before the user renames it.
  final String newFolderName;

  /// Screen-reader label of the toolbar.
  final String toolbar;

  /// Placeholder of the search input.
  final String searchFiles;

  /// Screen-reader label of the search button.
  final String search;

  /// Screen-reader label of the search button while the search is open.
  final String closeSearch;

  /// Screen-reader label of the list/grid switch.
  final String viewMode;

  /// Label of the list option of the view switch.
  final String listView;

  /// Label of the grid option of the view switch.
  final String gridView;

  /// Tooltip of the toolbar's upload button.
  final String uploadFile;

  /// Screen-reader label of the upload buttons and menu entries.
  final String uploadFiles;

  /// Tooltip of the toolbar's new folder button.
  final String addNewFolder;

  /// Screen-reader label of the new folder button and menu entry.
  final String newFolder;

  /// Shown in the toolbar while files are selected, by their number.
  final String Function(int count) selectedCount;

  /// Label of the bulk move action.
  final String move;

  /// Label of the bulk copy action.
  final String copy;

  /// Label of the delete action and menu entry.
  final String delete;

  /// Label of the action that clears the selection.
  final String clear;

  /// Label of the menu entry that opens a file or folder.
  final String open;

  /// Label of the menu entry that previews a file.
  final String preview;

  /// Label of the menu entry that renames a file.
  final String rename;

  /// Label of the menu entry that moves files.
  final String moveTo;

  /// Label of the menu entry that copies files.
  final String copyTo;

  /// Label of the menu entry that downloads files.
  final String download;

  /// Label of the menu entry that shares files.
  final String share;

  /// Label of the menu entry that selects all files.
  final String selectAll;

  /// Label of the menu entry that clears the selection.
  final String clearSelection;

  /// Title of the empty state when the search, the argument, finds nothing.
  final String Function(String query) noMatches;

  /// Label of the button that clears the search.
  final String clearSearch;

  /// Title of the empty state of an empty folder.
  final String emptyFolder;

  /// Screen-reader label of the context menu of an empty folder.
  final String emptyFolderMenu;

  /// Screen-reader label of the sidebar.
  final String sidebarLabel;

  /// Screen-reader label of the list view, by the number of files.
  final String Function(int count) listWithCount;

  /// Screen-reader label of the grid view, by the number of files.
  final String Function(int count) gridWithCount;

  /// Screen-reader label of the delete dialog.
  final String deleteConfirmation;

  /// Screen-reader label of the move dialog.
  final String moveDialogLabel;

  /// Screen-reader label of the copy dialog.
  final String copyDialogLabel;

  /// Screen-reader label of the upload dialog.
  final String uploadDialogLabel;

  /// Title of the new folder dialog.
  final String newFolderTitle;

  /// Label of the new folder dialog's name input.
  final String folderName;

  /// Label of the new folder dialog's cancel button.
  final String cancel;

  /// Label of the new folder dialog's apply button.
  final String apply;

  /// The texts of the grid view.
  final OiFileGridViewLabels gridViewLabels;

  /// The texts of the list view.
  final OiFileListViewLabels listViewLabels;

  /// The texts of the sidebar.
  final OiFileSidebarLabels sidebar;

  /// The texts of the delete dialog.
  final OiDeleteDialogLabels deleteDialog;

  /// The texts of the move and copy dialog.
  final OiMoveDialogLabels moveDialog;

  /// The texts of the upload dialog.
  final OiUploadDialogLabels uploadDialog;

  /// The names and categories of the keyboard shortcuts.
  final OiFileExplorerShortcutLabels shortcuts;

  /// What the explorer announces to screen readers.
  final OiFileExplorerAnnouncements announcements;
}

/// The names and categories of an [OiFileExplorer]'s keyboard shortcuts, as
/// listed in the shortcut help, in English by default.
///
/// {@category Modules}
class OiFileExplorerShortcutLabels {
  /// Creates an [OiFileExplorerShortcutLabels].
  const OiFileExplorerShortcutLabels({
    this.selectAll = 'Select all',
    this.delete = 'Delete',
    this.rename = 'Rename',
    this.search = 'Search',
    this.closeSearch = 'Cancel / close search',
    this.cut = 'Cut (for keyboard move)',
    this.copy = 'Copy (for keyboard copy)',
    this.paste = 'Paste (move/copy here)',
    this.upload = 'Upload',
    this.newFolder = 'New folder',
    this.goBack = 'Go back',
    this.goForward = 'Go forward',
    this.selection = 'Selection',
    this.actions = 'Actions',
    this.navigation = 'Navigation',
    this.clipboard = 'Clipboard',
  });

  /// Shortcut that selects all files.
  final String selectAll;

  /// Shortcut that deletes the selected files.
  final String delete;

  /// Shortcut that renames the selected file.
  final String rename;

  /// Shortcut that opens the search.
  final String search;

  /// Shortcut that cancels the current action or closes the search.
  final String closeSearch;

  /// Shortcut that cuts the selected files.
  final String cut;

  /// Shortcut that copies the selected files.
  final String copy;

  /// Shortcut that pastes cut or copied files.
  final String paste;

  /// Shortcut that opens the upload dialog.
  final String upload;

  /// Shortcut that creates a folder.
  final String newFolder;

  /// Shortcut that goes back in the history.
  final String goBack;

  /// Shortcut that goes forward in the history.
  final String goForward;

  /// Category of the selection shortcuts.
  final String selection;

  /// Category of the file action shortcuts.
  final String actions;

  /// Category of the navigation shortcuts.
  final String navigation;

  /// Category of the clipboard shortcuts.
  final String clipboard;
}

/// What an [OiFileExplorer] announces to screen readers after an action, in
/// English by default.
///
/// {@category Modules}
class OiFileExplorerAnnouncements {
  /// Creates an [OiFileExplorerAnnouncements].
  const OiFileExplorerAnnouncements({
    this.renamedTo = englishRenamedTo,
    this.movedTo = englishMovedTo,
    this.copiedTo = englishCopiedTo,
    this.uploaded = englishUploaded,
    this.deleted = englishDeleted,
    this.folderCreated = englishFolderCreated,
    this.newFolderCreated = 'New folder created',
    this.allSelected = 'All items selected',
    this.selectionCleared = 'Selection cleared',
    this.cut = englishCut,
    this.copiedToClipboard = englishCopiedToClipboard,
    this.movedHere = englishMovedHere,
    this.copiedHere = englishCopiedHere,
  });

  static String _items(int count) => '$count item${count == 1 ? '' : 's'}';

  /// "Renamed to report.pdf": the default [renamedTo].
  static String englishRenamedTo(String name) => 'Renamed to $name';

  /// "3 items moved to Documents": the default [movedTo].
  static String englishMovedTo(int count, String folder) =>
      '${_items(count)} moved to $folder';

  /// "3 items copied to Documents": the default [copiedTo].
  static String englishCopiedTo(int count, String folder) =>
      '${_items(count)} copied to $folder';

  /// "3 files uploaded": the default [uploaded].
  static String englishUploaded(int count) =>
      '$count file${count == 1 ? '' : 's'} uploaded';

  /// "3 items deleted": the default [deleted].
  static String englishDeleted(int count) => '${_items(count)} deleted';

  /// 'Folder "Reports" created': the default [folderCreated].
  static String englishFolderCreated(String name) => 'Folder "$name" created';

  /// "3 items cut": the default [cut].
  static String englishCut(int count) => '${_items(count)} cut';

  /// "3 items copied to clipboard": the default [copiedToClipboard].
  static String englishCopiedToClipboard(int count) =>
      '${_items(count)} copied to clipboard';

  /// "3 items moved here": the default [movedHere].
  static String englishMovedHere(int count) => '${_items(count)} moved here';

  /// "3 items copied here": the default [copiedHere].
  static String englishCopiedHere(int count) => '${_items(count)} copied here';

  /// After a file was renamed to the argument.
  final String Function(String name) renamedTo;

  /// After files, counted by the first argument, were moved to the named
  /// folder.
  final String Function(int count, String folder) movedTo;

  /// After files, counted by the first argument, were copied to the named
  /// folder.
  final String Function(int count, String folder) copiedTo;

  /// After files, counted by the argument, were uploaded.
  final String Function(int count) uploaded;

  /// After files, counted by the argument, were deleted.
  final String Function(int count) deleted;

  /// After the named folder was created.
  final String Function(String name) folderCreated;

  /// After a folder was created with the keyboard shortcut.
  final String newFolderCreated;

  /// After all files were selected.
  final String allSelected;

  /// After the selection was cleared.
  final String selectionCleared;

  /// After files, counted by the argument, were cut.
  final String Function(int count) cut;

  /// After files, counted by the argument, were copied.
  final String Function(int count) copiedToClipboard;

  /// After cut files, counted by the argument, were pasted.
  final String Function(int count) movedHere;

  /// After copied files, counted by the argument, were pasted.
  final String Function(int count) copiedHere;
}
