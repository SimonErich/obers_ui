import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/composites/data/oi_tree.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

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
    final action = widget.copyMode ? 'Copy' : 'Move';
    if (widget.files.length == 1) {
      return '$action ${widget.files.first.name} to...';
    }
    return '$action ${widget.files.length} items to...';
  }

  String get _actionLabel => widget.copyMode ? 'Copy here' : 'Move here';

  bool _isSelfOrDescendant(OiTreeNode<OiFileNodeData> node) {
    // Prevent moving a folder into itself or its descendants
    for (final file in widget.files) {
      if (file.isFolder && file.id == node.id) return true;
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
      label: '${widget.copyMode ? "Copy" : "Move"} dialog',
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
                  label: 'Folder tree',
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
                        required bool expanded,
                        required bool selected,
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
                                    const IconData(
                                      0xe2c7,
                                      fontFamily: 'MaterialIcons',
                                    ),
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
                  label: '+ New Folder',
                  onTap: () =>
                      widget.onCreateFolder?.call(_selectedFolderId ?? ''),
                ),
              ],
              // Destination label
              if (_selectedFolder != null) ...[
                SizedBox(height: spacing.sm),
                Text(
                  '${widget.copyMode ? "Copying" : "Moving"} to: ${_selectedFolder!.name}',
                  style: TextStyle(fontSize: 12, color: colors.textSubtle),
                ),
              ],
              SizedBox(height: spacing.lg),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OiButton.ghost(label: 'Cancel', onTap: widget.onCancel),
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
