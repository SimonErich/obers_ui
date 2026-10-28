import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/composites/data/oi_tree.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

/// The texts of an [OiMoveDialog], in English by default; pass translations
/// to localize the dialog.
///
/// Texts come in pairs, one for moving and one for copying
/// ([OiMoveDialog.copyMode]).
///
/// {@category Components}
class OiMoveDialogLabels {
  /// Creates an [OiMoveDialogLabels].
  const OiMoveDialogLabels({
    this.moveOne = englishMoveOne,
    this.moveMany = englishMoveMany,
    this.copyOne = englishCopyOne,
    this.copyMany = englishCopyMany,
    this.movingTo = englishMovingTo,
    this.copyingTo = englishCopyingTo,
    this.moveHere = 'Move here',
    this.copyHere = 'Copy here',
    this.moveDialog = 'Move dialog',
    this.copyDialog = 'Copy dialog',
    this.folderTree = 'Folder tree',
    this.newFolder = '+ New Folder',
    this.cancel = 'Cancel',
  });

  /// "Move report.pdf to...": the default [moveOne].
  static String englishMoveOne(String name) => 'Move $name to...';

  /// "Move 3 items to...": the default [moveMany].
  static String englishMoveMany(int count) => 'Move $count items to...';

  /// "Copy report.pdf to...": the default [copyOne].
  static String englishCopyOne(String name) => 'Copy $name to...';

  /// "Copy 3 items to...": the default [copyMany].
  static String englishCopyMany(int count) => 'Copy $count items to...';

  /// "Moving to: Documents": the default [movingTo].
  static String englishMovingTo(String folder) => 'Moving to: $folder';

  /// "Copying to: Documents": the default [copyingTo].
  static String englishCopyingTo(String folder) => 'Copying to: $folder';

  /// Title when a single file, named by the argument, is moved.
  final String Function(String name) moveOne;

  /// Title when several files, counted by the argument, are moved.
  final String Function(int count) moveMany;

  /// Title when a single file, named by the argument, is copied.
  final String Function(String name) copyOne;

  /// Title when several files, counted by the argument, are copied.
  final String Function(int count) copyMany;

  /// Names the selected destination folder when moving.
  final String Function(String folder) movingTo;

  /// Names the selected destination folder when copying.
  final String Function(String folder) copyingTo;

  /// Label of the confirm button when moving.
  final String moveHere;

  /// Label of the confirm button when copying.
  final String copyHere;

  /// Screen-reader label of the dialog when moving.
  final String moveDialog;

  /// Screen-reader label of the dialog when copying.
  final String copyDialog;

  /// Screen-reader label of the folder tree.
  final String folderTree;

  /// Label of the button shown when [OiMoveDialog.onCreateFolder] is set.
  final String newFolder;

  /// Label of the cancel button.
  final String cancel;
}

/// A dialog for moving/copying files to a different folder.
///
/// Shows a folder tree for destination selection.
///
/// {@category Components}
class OiMoveDialog extends StatefulWidget {
  /// Creates an [OiMoveDialog].
  const OiMoveDialog({
    required this.files,
    required this.folderTree,
    required this.onMove,
    this.onCancel,
    this.copyMode = false,
    this.loadChildren,
    this.onCreateFolder,
    this.labels = const OiMoveDialogLabels(),
    super.key,
  });

  /// Files being moved/copied.
  final List<OiFileNodeData> files;

  /// Folder tree for destination selection.
  final List<OiTreeNode<OiFileNodeData>> folderTree;

  /// Called with the destination folder when confirmed.
  final void Function(OiFileNodeData destination) onMove;

  /// Called when cancelled.
  final VoidCallback? onCancel;

  /// Whether this is a copy operation instead of move.
  final bool copyMode;

  /// Lazy loader for child folders.
  final Future<List<OiTreeNode<OiFileNodeData>>> Function(
    OiTreeNode<OiFileNodeData>,
  )?
  loadChildren;

  /// Called when the user creates a new folder in the dialog.
  final ValueChanged<String>? onCreateFolder;

  /// The dialog's texts; pass translations to localize it.
  final OiMoveDialogLabels labels;

  @override
  State<OiMoveDialog> createState() => _OiMoveDialogState();
}

class _OiMoveDialogState extends State<OiMoveDialog> {
  String? _selectedFolderId;
  OiFileNodeData? _selectedFolder;
  String _searchQuery = '';
  late OiTreeController _treeController;
  late final FocusNode _escapeFocusNode;

  @override
  void initState() {
    super.initState();
    _treeController = OiTreeController();
    _escapeFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _treeController.dispose();
    _escapeFocusNode.dispose();
    super.dispose();
  }

  String get _title {
    final labels = widget.labels;
    if (widget.files.length == 1) {
      final name = widget.files.first.name;
      return widget.copyMode ? labels.copyOne(name) : labels.moveOne(name);
    }
    final count = widget.files.length;
    return widget.copyMode ? labels.copyMany(count) : labels.moveMany(count);
  }

  String get _actionLabel =>
      widget.copyMode ? widget.labels.copyHere : widget.labels.moveHere;

  bool _isSelfOrDescendant(OiTreeNode<OiFileNodeData> node) {
    // Prevent moving a folder into itself or its descendants
    for (final file in widget.files) {
      if (file.folder && file.id == node.id) return true;
    }
    return false;
  }

  void _onFolderSelect(String id) {
    setState(() {
      _selectedFolderId = id;
      _selectedFolder = _findFolder(widget.folderTree, id);
    });
  }

  OiFileNodeData? _findFolder(
    List<OiTreeNode<OiFileNodeData>> nodes,
    String id,
  ) {
    for (final node in nodes) {
      if (node.id == id) return node.data;
      final found = _findFolder(node.children, id);
      if (found != null) return found;
    }
    return null;
  }

  void _submit() {
    if (_selectedFolder != null) {
      widget.onMove(_selectedFolder!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      label: widget.copyMode
          ? widget.labels.copyDialog
          : widget.labels.moveDialog,
      child: KeyboardListener(
        focusNode: _escapeFocusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onCancel?.call();
          }
        },
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                _title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              SizedBox(height: spacing.md),
              // Search
              OiTextInput.search(
                onChanged: (q) => setState(() => _searchQuery = q),
              ),
              SizedBox(height: spacing.sm),
              // Folder tree
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: OiTree<OiFileNodeData>(
                  label: widget.labels.folderTree,
                  nodes: widget.folderTree,
                  controller: _treeController,
                  onSelectionChanged: (ids) {
                    if (ids.isNotEmpty) _onFolderSelect(ids.first);
                  },
                  nodeBuilder:
                      (
                        context,
                        node,
                        depth, {
                        required expanded,
                        required selected,
                      }) {
                        final disabled = _isSelfOrDescendant(node);
                        final isMatch =
                            _searchQuery.isEmpty ||
                            node.label.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                        if (!isMatch && _searchQuery.isNotEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Opacity(
                          opacity: disabled ? 0.4 : 1.0,
                          child: GestureDetector(
                            onTap: disabled
                                ? null
                                : () => _onFolderSelect(node.id),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.sm,
                                vertical: spacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedFolderId == node.id
                                    ? colors.primary.muted.withValues(
                                        alpha: 0.15,
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    OiIcons.folder,
                                    size: 16,
                                    color: colors.warning.base,
                                  ),
                                  SizedBox(width: spacing.xs),
                                  Expanded(
                                    child: Text(
                                      node.label,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colors.text,
                                        fontWeight: _selectedFolderId == node.id
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                ),
              ),
              // New Folder button
              if (widget.onCreateFolder != null) ...[
                SizedBox(height: spacing.sm),
                OiButton.ghost(
                  label: widget.labels.newFolder,
                  onTap: () =>
                      widget.onCreateFolder?.call(_selectedFolderId ?? ''),
                ),
              ],
              // Destination label
              if (_selectedFolder != null) ...[
                SizedBox(height: spacing.sm),
                Text(
                  widget.copyMode
                      ? widget.labels.copyingTo(_selectedFolder!.name)
                      : widget.labels.movingTo(_selectedFolder!.name),
                  style: TextStyle(fontSize: 12, color: colors.textSubtle),
                ),
              ],
              SizedBox(height: spacing.lg),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OiButton.ghost(
                    label: widget.labels.cancel,
                    onTap: widget.onCancel,
                  ),
                  SizedBox(width: spacing.sm),
                  OiButton.primary(
                    label: _actionLabel,
                    onTap: _selectedFolder != null ? _submit : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
