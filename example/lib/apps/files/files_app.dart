import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
// OiFileData is hidden from the barrel; import directly for onUpload callback.
// ignore: implementation_imports
import 'package:obers_ui/src/modules/oi_chat.dart' show OiFileData;

import 'package:obers_ui_example/data/mock_files.dart';
import 'package:obers_ui_example/shell/showcase_shell.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// File explorer mini-app demonstrating OiFileExplorer.
class FilesApp extends StatefulWidget {
  const FilesApp({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  State<FilesApp> createState() => _FilesAppState();
}

class _FilesAppState extends State<FilesApp> {
  late OiFileExplorerController _controller;
  late List<OiFileNodeData> _localFileTree;
  int _idCounter = 1000;

  @override
  void initState() {
    super.initState();
    _controller = OiFileExplorerController();
    // Create a mutable copy of the mock file tree.
    _localFileTree = List<OiFileNodeData>.from(kFileTree);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Data callbacks ──────────────────────────────────────────────────────

  Future<List<OiFileNodeData>> _loadFolder(String folderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _localFileTree.where((f) => f.parentId == folderId).toList();
  }

  Future<List<OiTreeNode<OiFileNodeData>>> _loadFolderTree(
    String parentId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _buildFolderTreeFromLocal(parentId);
  }

  List<OiTreeNode<OiFileNodeData>> _buildFolderTreeFromLocal(String parentId) {
    final folders = _localFileTree
        .where((f) => f.parentId == parentId && f.isFolder)
        .toList();
    return folders.map((folder) {
      return OiTreeNode<OiFileNodeData>(
        id: folder.id.toString(),
        label: folder.name,
        data: folder,
        children: _buildFolderTreeFromLocal(folder.id.toString()),
        leaf: !_localFileTree
            .any((f) => f.parentId == folder.id.toString() && f.isFolder),
      );
    }).toList();
  }

  Future<OiFileNodeData> _onCreateFolder(String parentId, String name) async {
    _idCounter++;
    final newFolder = OiFileNodeData(
      id: 'folder-$_idCounter',
      name: name,
      isFolder: true,
      parentId: parentId,
      modified: DateTime.now(),
      itemCount: 0,
    );
    setState(() => _localFileTree.add(newFolder));
    return newFolder;
  }

  Future<void> _onRename(OiFileNodeData file, String newName) async {
    setState(() {
      final index = _localFileTree.indexWhere((f) => f.id == file.id);
      if (index >= 0) {
        _localFileTree[index] = _localFileTree[index].copyWith(name: newName);
      }
    });
  }

  Future<void> _onDelete(List<OiFileNodeData> files) async {
    setState(() {
      final idsToRemove = files.map((f) => f.id).toSet();
      _localFileTree.removeWhere((f) => idsToRemove.contains(f.id));
    });
  }

  Future<void> _onMove(
    List<OiFileNodeData> files,
    OiFileNodeData destination,
  ) async {
    setState(() {
      for (final file in files) {
        final index = _localFileTree.indexWhere((f) => f.id == file.id);
        if (index >= 0) {
          _localFileTree[index] = _localFileTree[index].copyWith(
            parentId: destination.id.toString(),
          );
        }
      }
    });
  }

  Future<void> _onUpload(List<OiFileData> files, String folderId) async {
    setState(() {
      for (final file in files) {
        _idCounter++;
        _localFileTree.add(
          OiFileNodeData(
            id: 'upload-$_idCounter',
            name: file.name,
            isFolder: false,
            parentId: folderId,
            size: file.size,
            mimeType: file.mimeType,
            modified: DateTime.now(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Files',
      themeState: widget.themeState,
      child: OiFileExplorer(
        controller: _controller,
        label: 'File explorer',
        loadFolder: _loadFolder,
        loadFolderTree: _loadFolderTree,
        onCreateFolder: _onCreateFolder,
        onRename: _onRename,
        onDelete: _onDelete,
        onMove: _onMove,
        onUpload: _onUpload,
        storage: OiStorageData(
          usedBytes: (kStorageUsed * 1024 * 1024 * 1024).round(),
          totalBytes: (kStorageTotal * 1024 * 1024 * 1024).round(),
        ),
      ),
    );
  }
}
