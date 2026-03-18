import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/models/settings/oi_file_explorer_settings.dart';

/// Controls the interactive state of an [OiFileExplorer].
///
/// Manages navigation history, selection, view mode, sort, search, and actions.
///
/// {@category Models}
class OiFileExplorerController extends ChangeNotifier {
  /// Creates an [OiFileExplorerController].
  OiFileExplorerController({
    OiFileViewMode viewMode = OiFileViewMode.list,
    OiFileSortField sortField = OiFileSortField.name,
    OiSortDirection sortDirection = OiSortDirection.ascending,
  })  : _viewMode = viewMode,
        _sortField = sortField,
        _sortDirection = sortDirection;

  // ── State ──────────────────────────────────────────────────────────────────

  OiFileNodeData? _currentFolder;
  final List<OiFileNodeData> _navigationHistory = [];
  int _historyIndex = -1;

  OiFileViewMode _viewMode;
  OiFileSortField _sortField;
  OiSortDirection _sortDirection;
  final Set<Object> _selectedKeys = {};
  String _searchQuery = '';
  Object? _renamingKey;

  List<OiFileNodeData> _files = [];
  bool _loading = false;
  String? _error;

  // ── Data callbacks (set by OiFileExplorer) ─────────────────────────────────

  /// Callback to load files for a folder.
  Future<List<OiFileNodeData>> Function(String folderId)? loadFolder;

  // ── Getters ────────────────────────────────────────────────────────────────

  /// Current folder being displayed.
  OiFileNodeData? get currentFolder => _currentFolder;

  /// Navigation history stack.
  List<OiFileNodeData> get navigationHistory =>
      List.unmodifiable(_navigationHistory);

  /// Current position in history.
  int get historyIndex => _historyIndex;

  /// Whether we can navigate back.
  bool get canGoBack => _historyIndex > 0;

  /// Whether we can navigate forward.
  bool get canGoForward => _historyIndex < _navigationHistory.length - 1;

  /// Current view mode.
  OiFileViewMode get viewMode => _viewMode;

  /// Current sort field.
  OiFileSortField get sortField => _sortField;

  /// Current sort direction.
  OiSortDirection get sortDirection => _sortDirection;

  /// Currently selected file keys.
  Set<Object> get selectedKeys => Set.unmodifiable(_selectedKeys);

  /// Current search query.
  String get searchQuery => _searchQuery;

  /// Key of the file currently being renamed.
  Object? get renamingKey => _renamingKey;

  /// Current files in the view.
  List<OiFileNodeData> get files => List.unmodifiable(_files);

  /// Whether the view is loading.
  bool get loading => _loading;

  /// Error message, if any.
  String? get error => _error;

  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Navigates to a folder by ID.
  Future<void> navigateTo(String folderId, {OiFileNodeData? folder}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final loadedFiles = await loadFolder?.call(folderId) ?? [];
      _files = loadedFiles;

      if (folder != null) {
        _currentFolder = folder;
      }

      // Update history
      if (_historyIndex < _navigationHistory.length - 1) {
        _navigationHistory.removeRange(
            _historyIndex + 1, _navigationHistory.length);
      }
      if (_currentFolder != null) {
        _navigationHistory.add(_currentFolder!);
        _historyIndex = _navigationHistory.length - 1;
      }

      _selectedKeys.clear();
      _searchQuery = '';
      _renamingKey = null;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  /// Goes back in navigation history.
  void goBack() {
    if (!canGoBack) return;
    _historyIndex--;
    _currentFolder = _navigationHistory[_historyIndex];
    navigateTo(_currentFolder!.id.toString(), folder: _currentFolder);
  }

  /// Goes forward in navigation history.
  void goForward() {
    if (!canGoForward) return;
    _historyIndex++;
    _currentFolder = _navigationHistory[_historyIndex];
    navigateTo(_currentFolder!.id.toString(), folder: _currentFolder);
  }

  /// Navigates up to the parent folder.
  void goUp() {
    if (_currentFolder?.parentId != null) {
      navigateTo(_currentFolder!.parentId!);
    }
  }

  // ── Selection ──────────────────────────────────────────────────────────────

  /// Selects a single file.
  void select(Object key) {
    _selectedKeys.clear();
    _selectedKeys.add(key);
    notifyListeners();
  }

  /// Deselects a file.
  void deselect(Object key) {
    _selectedKeys.remove(key);
    notifyListeners();
  }

  /// Selects all files.
  void selectAll() {
    _selectedKeys.clear();
    for (final file in _files) {
      _selectedKeys.add(file.id);
    }
    notifyListeners();
  }

  /// Clears all selection.
  void clearSelection() {
    _selectedKeys.clear();
    notifyListeners();
  }

  /// Toggles selection of a file.
  void toggleSelection(Object key) {
    if (_selectedKeys.contains(key)) {
      _selectedKeys.remove(key);
    } else {
      _selectedKeys.add(key);
    }
    notifyListeners();
  }

  /// Range-selects from one key to another.
  void rangeSelect(Object fromKey, Object toKey) {
    final fromIndex = _files.indexWhere((f) => f.id == fromKey);
    final toIndex = _files.indexWhere((f) => f.id == toKey);
    if (fromIndex < 0 || toIndex < 0) return;

    final start = fromIndex < toIndex ? fromIndex : toIndex;
    final end = fromIndex < toIndex ? toIndex : fromIndex;

    for (var i = start; i <= end; i++) {
      _selectedKeys.add(_files[i].id);
    }
    notifyListeners();
  }

  /// Updates the full selection set.
  void setSelection(Set<Object> keys) {
    _selectedKeys
      ..clear()
      ..addAll(keys);
    notifyListeners();
  }

  // ── View ───────────────────────────────────────────────────────────────────

  /// Sets the view mode.
  void setViewMode(OiFileViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  /// Sets the sort field.
  void setSortField(OiFileSortField field) {
    _sortField = field;
    notifyListeners();
  }

  /// Sets the sort direction.
  void setSortDirection(OiSortDirection direction) {
    _sortDirection = direction;
    notifyListeners();
  }

  /// Sets the search query.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Starts rename mode for the given file key.
  void startRename(Object fileKey) {
    _renamingKey = fileKey;
    notifyListeners();
  }

  /// Cancels rename mode.
  void cancelRename() {
    _renamingKey = null;
    notifyListeners();
  }

  /// Refreshes the current folder.
  Future<void> refresh() async {
    if (_currentFolder != null) {
      await navigateTo(
        _currentFolder!.id.toString(),
        folder: _currentFolder,
      );
    }
  }

  /// Updates the file list directly (e.g., after a CRUD operation).
  void updateFiles(List<OiFileNodeData> files) {
    _files = files;
    notifyListeners();
  }

  /// Returns selected files.
  List<OiFileNodeData> get selectedFiles =>
      _files.where((f) => _selectedKeys.contains(f.id)).toList();

  /// Returns `true` if a file or folder with the given [key] exists
  /// in the current file list.
  bool exist(Object key) => _files.any((f) => f.id == key);
}
