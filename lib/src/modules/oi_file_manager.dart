import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/modules/oi_chat.dart';

/// A file or folder node in the [OiFileManager].
///
/// Represents a single file system entry with metadata.
class OiFileNode {
  /// Creates an [OiFileNode].
  const OiFileNode({
    required this.key,
    required this.name,
    required this.folder,
    this.size,
    this.modified,
    this.thumbnailUrl,
  });

  /// Unique identifier for this node.
  final Object key;

  /// The display name of the file or folder.
  final String name;

  /// Whether this node is a folder.
  final bool folder;

  /// The file size in bytes. Null for folders.
  final int? size;

  /// The last modified date.
  final DateTime? modified;

  /// Optional thumbnail URL for image previews.
  final String? thumbnailUrl;
}

/// The layout mode for the file manager.
///
/// {@category Modules}
enum OiFileManagerLayout {
  /// A vertical list with detailed rows.
  list,

  /// A grid of icon tiles.
  grid,
}

/// The selection mode for the file manager.
///
/// {@category Modules}
enum OiFileManagerSelectionMode {
  /// No selection allowed.
  none,

  /// Only one item can be selected at a time.
  single,

  /// Multiple items can be selected.
  multi,
}

/// A file browser with folder navigation, grid/list view, and selection.
///
/// Displays a list of [OiFileNode] items in either a grid or list layout.
/// Supports breadcrumb navigation, opening files/folders, and multi-select.
///
/// {@category Modules}
class OiFileManager extends StatefulWidget {
  /// Creates an [OiFileManager].
  const OiFileManager({
    super.key,
    required this.items,
    required this.label,
    this.onOpen,
    this.onRename,
    this.onDelete,
    this.onMove,
    this.onUpload,
    this.layout = OiFileManagerLayout.grid,
    this.selectionMode = OiFileManagerSelectionMode.multi,
    this.currentPath,
    this.onNavigate,
  });

  /// The list of files and folders to display.
  final List<OiFileNode> items;

  /// Accessibility label for the file manager.
  final String label;

  /// Called when a file or folder is opened (double-tap).
  final ValueChanged<OiFileNode>? onOpen;

  /// Called when a file is renamed.
  final ValueChanged<OiFileNode>? onRename;

  /// Called when a file is deleted.
  final ValueChanged<OiFileNode>? onDelete;

  /// Called when a file is moved to a folder.
  final void Function(OiFileNode file, OiFileNode folder)? onMove;

  /// Called when files are uploaded.
  final ValueChanged<List<OiFileData>>? onUpload;

  /// The layout mode (grid or list).
  final OiFileManagerLayout layout;

  /// The selection mode.
  final OiFileManagerSelectionMode selectionMode;

  /// The current folder path as a list of path segments.
  final List<String>? currentPath;

  /// Called when the user navigates to a different path.
  final ValueChanged<List<String>>? onNavigate;

  @override
  State<OiFileManager> createState() => _OiFileManagerState();
}

class _OiFileManagerState extends State<OiFileManager> {
  final Set<Object> _selected = {};

  void _handleTap(OiFileNode node) {
    if (widget.selectionMode == OiFileManagerSelectionMode.none) return;
    setState(() {
      if (widget.selectionMode == OiFileManagerSelectionMode.single) {
        _selected.clear();
        _selected.add(node.key);
      } else {
        if (_selected.contains(node.key)) {
          _selected.remove(node.key);
        } else {
          _selected.add(node.key);
        }
      }
    });
  }

  void _handleDoubleTap(OiFileNode node) {
    widget.onOpen?.call(node);
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Breadcrumb navigation
          if (widget.currentPath != null && widget.currentPath!.isNotEmpty)
            _buildBreadcrumbs(context),

          // Content area
          Expanded(
            child: widget.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          const IconData(0xe2c7, fontFamily: 'MaterialIcons'),
                          size: 48,
                          color: colors.textMuted,
                        ),
                        SizedBox(height: spacing.sm),
                        Text(
                          'This folder is empty',
                          style: TextStyle(color: colors.textMuted),
                        ),
                      ],
                    ),
                  )
                : widget.layout == OiFileManagerLayout.grid
                ? _buildGrid(context)
                : _buildList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final path = widget.currentPath!;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.onNavigate?.call(const []),
            child: Text(
              'Home',
              style: TextStyle(color: colors.primary.base, fontSize: 14),
            ),
          ),
          for (var i = 0; i < path.length; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.xs),
              child: Text(
                '/',
                style: TextStyle(color: colors.textMuted, fontSize: 14),
              ),
            ),
            GestureDetector(
              onTap: () => widget.onNavigate?.call(path.sublist(0, i + 1)),
              child: Text(
                path[i],
                style: TextStyle(
                  color: i == path.length - 1
                      ? colors.text
                      : colors.primary.base,
                  fontSize: 14,
                  fontWeight: i == path.length - 1
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final spacing = context.spacing;

    return GridView.builder(
      padding: EdgeInsets.all(spacing.md),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        mainAxisSpacing: spacing.sm,
        crossAxisSpacing: spacing.sm,
        childAspectRatio: 0.85,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) =>
          _buildGridTile(context, widget.items[index]),
    );
  }

  Widget _buildGridTile(BuildContext context, OiFileNode node) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isSelected = _selected.contains(node.key);

    return GestureDetector(
      onTap: () => _handleTap(node),
      onDoubleTap: () => _handleDoubleTap(node),
      child: Container(
        padding: EdgeInsets.all(spacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.muted.withValues(alpha: 0.15)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: colors.primary.base) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              node.folder
                  ? const IconData(0xe2c7, fontFamily: 'MaterialIcons')
                  : const IconData(0xe24d, fontFamily: 'MaterialIcons'),
              size: 40,
              color: node.folder ? colors.warning.base : colors.textSubtle,
            ),
            SizedBox(height: spacing.xs),
            Text(
              node.name,
              style: TextStyle(color: colors.text, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.items.length,
      itemBuilder: (context, index) =>
          _buildListRow(context, widget.items[index]),
    );
  }

  Widget _buildListRow(BuildContext context, OiFileNode node) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isSelected = _selected.contains(node.key);

    return GestureDetector(
      onTap: () => _handleTap(node),
      onDoubleTap: () => _handleDoubleTap(node),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.muted.withValues(alpha: 0.15)
              : null,
          border: Border(bottom: BorderSide(color: colors.borderSubtle)),
        ),
        child: Row(
          children: [
            Icon(
              node.folder
                  ? const IconData(0xe2c7, fontFamily: 'MaterialIcons')
                  : const IconData(0xe24d, fontFamily: 'MaterialIcons'),
              size: 24,
              color: node.folder ? colors.warning.base : colors.textSubtle,
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(
                node.name,
                style: TextStyle(color: colors.text, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (node.size != null)
              Text(
                _formatSize(node.size!),
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
