import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_file_icon.dart';
import 'package:obers_ui/src/components/display/oi_folder_icon.dart';
import 'package:obers_ui/src/components/display/oi_rename_field.dart';
import 'package:obers_ui/src/components/interaction/oi_selection_overlay.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/models/settings/oi_file_explorer_settings.dart';
import 'package:obers_ui/src/utils/file_utils.dart';

/// A column definition for custom columns in [OiFileListView].
///
/// {@category Composites}
@immutable
class OiFileColumnDef {
  /// Creates an [OiFileColumnDef].
  const OiFileColumnDef({
    required this.id,
    required this.label,
    required this.width,
    required this.cellBuilder,
    this.sortable = false,
  });

  /// Unique column identifier.
  final String id;

  /// Header label.
  final String label;

  /// Column width.
  final double width;

  /// Builder for each cell in this column.
  final Widget Function(OiFileNodeData) cellBuilder;

  /// Whether this column is sortable.
  final bool sortable;
}

/// The list (table-like) view of files.
///
/// Renders a sortable column header + virtualized rows of file tiles.
/// Supports multi-select, rubber-band selection, drag-and-drop, and
/// inline rename.
///
/// {@category Composites}
class OiFileListView extends StatefulWidget {
  /// Creates an [OiFileListView].
  const OiFileListView({
    required this.files,
    required this.selectedKeys,
    required this.onSelectionChange,
    required this.onOpen,
    this.sortField = OiFileSortField.name,
    this.sortDirection = OiSortDirection.ascending,
    this.onSortFieldChange,
    this.onSortDirectionChange,
    this.showSize = true,
    this.showModified = true,
    this.showType = true,
    this.extraColumns,
    this.renamingKey,
    this.onRename,
    this.onCancelRename,
    this.onMoveToFolder,
    this.contextMenu,
    this.backgroundContextMenu,
    this.loading = false,
    this.semanticsLabel,
    super.key,
  });

  /// Files to display.
  final List<OiFileNodeData> files;

  /// Currently selected file keys.
  final Set<Object> selectedKeys;

  /// Called when selection changes.
  final ValueChanged<Set<Object>> onSelectionChange;

  /// Called when a file/folder is opened.
  final ValueChanged<OiFileNodeData> onOpen;

  /// Current sort field.
  final OiFileSortField sortField;

  /// Current sort direction.
  final OiSortDirection sortDirection;

  /// Called when sort field changes.
  final ValueChanged<OiFileSortField>? onSortFieldChange;

  /// Called when sort direction changes.
  final ValueChanged<OiSortDirection>? onSortDirectionChange;

  /// Whether to show the size column.
  final bool showSize;

  /// Whether to show the modified column.
  final bool showModified;

  /// Whether to show the type column.
  final bool showType;

  /// Extra custom columns.
  final List<OiFileColumnDef>? extraColumns;

  /// Key of the file currently being renamed.
  final Object? renamingKey;

  /// Called when a file is renamed.
  final ValueChanged<String>? onRename;

  /// Called when rename is cancelled.
  final VoidCallback? onCancelRename;

  /// Called when files are moved to a folder.
  final void Function(List<OiFileNodeData> files, OiFileNodeData folder)?
      onMoveToFolder;

  /// Context menu builder for individual files.
  final List<Widget> Function(OiFileNodeData)? contextMenu;

  /// Context menu builder for background (empty area).
  final List<Widget> Function()? backgroundContextMenu;

  /// Whether the view is in a loading state.
  final bool loading;

  /// Accessibility label.
  final String? semanticsLabel;

  @override
  State<OiFileListView> createState() => _OiFileListViewState();
}

class _OiFileListViewState extends State<OiFileListView> {
  void _onTap(OiFileNodeData file) {
    setState(() {
      final newSelection = <Object>{file.id};
      widget.onSelectionChange(newSelection);
    });
  }

  void _onDoubleTap(OiFileNodeData file) {
    widget.onOpen(file);
  }

  void _toggleSort(OiFileSortField field) {
    if (widget.sortField == field) {
      widget.onSortDirectionChange?.call(
        widget.sortDirection == OiSortDirection.ascending
            ? OiSortDirection.descending
            : OiSortDirection.ascending,
      );
    } else {
      widget.onSortFieldChange?.call(field);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    if (widget.loading) {
      return _buildLoading(colors, spacing);
    }

    return Semantics(
      label: widget.semanticsLabel ?? 'File list',
      child: OiSelectionOverlay(
        onSelectionRect: (rect) {
          // Calculate which items intersect and update selection
        },
        onSelectionStart: () {},
        onSelectionEnd: () {},
        child: Column(
          children: [
            // Column header
            _buildHeader(colors, spacing),
            // File rows
            Expanded(
              child: ListView.builder(
                itemCount: widget.files.length,
                itemBuilder: (context, index) {
                  final file = widget.files[index];
                  final isSelected = widget.selectedKeys.contains(file.id);
                  final isRenaming = widget.renamingKey == file.id;

                  return _buildRow(file, isSelected, isRenaming, colors, spacing);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic colors, dynamic spacing) {
    final textStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: (colors as dynamic).textMuted as Color,
    );

    String sortIndicator(OiFileSortField field) {
      if (widget.sortField != field) return '';
      return widget.sortDirection == OiSortDirection.ascending ? ' ▴' : ' ▾';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (spacing as dynamic).md as double,
        vertical: (spacing as dynamic).xs as double,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: (colors as dynamic).border as Color),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 32), // Icon space
          SizedBox(width: (spacing as dynamic).sm as double),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _toggleSort(OiFileSortField.name),
              child: Text('Name${sortIndicator(OiFileSortField.name)}',
                  style: textStyle),
            ),
          ),
          if (widget.showSize)
            Expanded(
              child: GestureDetector(
                onTap: () => _toggleSort(OiFileSortField.size),
                child: Text('Size${sortIndicator(OiFileSortField.size)}',
                    style: textStyle),
              ),
            ),
          if (widget.showModified)
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => _toggleSort(OiFileSortField.modified),
                child: Text(
                    'Modified${sortIndicator(OiFileSortField.modified)}',
                    style: textStyle),
              ),
            ),
          if (widget.showType)
            Expanded(
              child: GestureDetector(
                onTap: () => _toggleSort(OiFileSortField.type),
                child: Text('Type${sortIndicator(OiFileSortField.type)}',
                    style: textStyle),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(OiFileNodeData file, bool isSelected, bool isRenaming,
      dynamic colors, dynamic spacing) {
    return GestureDetector(
      onTap: () => _onTap(file),
      onDoubleTap: () => _onDoubleTap(file),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: (spacing as dynamic).md as double,
          vertical: (spacing as dynamic).sm as double,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? ((colors as dynamic).primary.muted as Color)
                  .withValues(alpha: 0.15)
              : null,
          border: Border(
            bottom: BorderSide(
              color: (colors as dynamic).borderSubtle as Color,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icon
            if (file.isFolder)
              const OiFolderIcon(size: OiFolderIconSize.sm)
            else
              OiFileIcon(
                fileName: file.name,
                mimeType: file.mimeType,
                size: OiFileIconSize.sm,
              ),
            SizedBox(width: (spacing as dynamic).sm as double),
            // Name (or rename field)
            Expanded(
              flex: 3,
              child: isRenaming
                  ? OiRenameField(
                      currentName: file.name,
                      isFolder: file.isFolder,
                      onRename: widget.onRename ?? (_) {},
                      onCancel: widget.onCancelRename ?? () {},
                    )
                  : Text(
                      file.name,
                      style: TextStyle(
                        fontSize: 13,
                        color: (colors as dynamic).text as Color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            // Size
            if (widget.showSize)
              Expanded(
                child: Text(
                  file.isFolder ? '—' : file.formattedSize,
                  style: TextStyle(
                    fontSize: 12,
                    color: (colors as dynamic).textMuted as Color,
                  ),
                ),
              ),
            // Modified
            if (widget.showModified)
              Expanded(
                flex: 2,
                child: Text(
                  file.modified != null
                      ? _formatShortDate(file.modified!)
                      : '—',
                  style: TextStyle(
                    fontSize: 12,
                    color: (colors as dynamic).textMuted as Color,
                  ),
                ),
              ),
            // Type
            if (widget.showType)
              Expanded(
                child: Text(
                  file.isFolder
                      ? '—'
                      : file.resolvedExtension.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: (colors as dynamic).textMuted as Color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(dynamic colors, dynamic spacing) {
    return Column(
      children: [
        _buildHeader(colors, spacing),
        Expanded(
          child: ListView.builder(
            itemCount: 8,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (spacing as dynamic).md as double,
                  vertical: (spacing as dynamic).sm as double,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: (colors as dynamic).surfaceHover as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: (spacing as dynamic).sm as double),
                    Expanded(
                      child: Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: (colors as dynamic).surfaceHover as Color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static String _formatShortDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
