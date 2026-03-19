import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_file_icon.dart';
import 'package:obers_ui/src/components/display/oi_folder_icon.dart';
import 'package:obers_ui/src/components/display/oi_rename_field.dart';
import 'package:obers_ui/src/components/interaction/oi_selection_overlay.dart';
import 'package:obers_ui/src/components/overlays/oi_context_menu.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/models/settings/oi_file_explorer_settings.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_draggable.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_drop_zone.dart';

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
    this.contextMenuBuilder,
    this.enableDragDrop = true,
    this.enableMultiSelect = true,
    this.searchQuery,
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

  /// Context menu builder for individual files (legacy widget-based).
  final List<Widget> Function(OiFileNodeData)? contextMenu;

  /// Context menu items builder for individual files (OiMenuItem-based).
  final List<OiMenuItem> Function(OiFileNodeData)? contextMenuBuilder;

  /// Context menu items builder for background (empty area).
  final List<OiMenuItem> Function()? backgroundContextMenu;

  /// Whether drag-and-drop is enabled.
  final bool enableDragDrop;

  /// Whether multi-select (Ctrl/Shift click) is enabled.
  final bool enableMultiSelect;

  /// Current search query for highlighting.
  final String? searchQuery;

  /// Whether the view is in a loading state.
  final bool loading;

  /// Accessibility label.
  final String? semanticsLabel;

  @override
  State<OiFileListView> createState() => _OiFileListViewState();
}

class _OiFileListViewState extends State<OiFileListView> {
  /// Last tapped index for shift-range selection.
  int? _lastTappedIndex;

  /// Focus node for keyboard navigation within the list.
  final FocusNode _focusNode = FocusNode();
  int _focusedIndex = -1;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onTap(OiFileNodeData file, int index) {
    if (!widget.enableMultiSelect) {
      widget.onSelectionChange({file.id});
      _lastTappedIndex = index;
      return;
    }

    final isShift = HardwareKeyboard.instance.logicalKeysPressed
        .any((k) =>
            k == LogicalKeyboardKey.shiftLeft ||
            k == LogicalKeyboardKey.shiftRight);
    final isCtrl = HardwareKeyboard.instance.logicalKeysPressed.any((k) =>
        k == LogicalKeyboardKey.controlLeft ||
        k == LogicalKeyboardKey.controlRight ||
        k == LogicalKeyboardKey.metaLeft ||
        k == LogicalKeyboardKey.metaRight);

    if (isShift && _lastTappedIndex != null) {
      // Range select
      final start =
          _lastTappedIndex! < index ? _lastTappedIndex! : index;
      final end = _lastTappedIndex! < index ? index : _lastTappedIndex!;
      final newSelection = Set<Object>.from(widget.selectedKeys);
      for (var i = start; i <= end; i++) {
        newSelection.add(widget.files[i].id);
      }
      widget.onSelectionChange(newSelection);
    } else if (isCtrl) {
      // Toggle selection
      final newSelection = Set<Object>.from(widget.selectedKeys);
      if (newSelection.contains(file.id)) {
        newSelection.remove(file.id);
      } else {
        newSelection.add(file.id);
      }
      widget.onSelectionChange(newSelection);
      _lastTappedIndex = index;
    } else {
      // Single select
      widget.onSelectionChange({file.id});
      _lastTappedIndex = index;
    }

    setState(() => _focusedIndex = index);
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

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      _moveFocus(1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _moveFocus(-1);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      if (_focusedIndex >= 0 && _focusedIndex < widget.files.length) {
        _onDoubleTap(widget.files[_focusedIndex]);
      }
    } else if (key == LogicalKeyboardKey.home) {
      _moveFocusTo(0);
    } else if (key == LogicalKeyboardKey.end) {
      _moveFocusTo(widget.files.length - 1);
    }
  }

  void _moveFocus(int delta) {
    if (widget.files.isEmpty) return;
    final next = (_focusedIndex + delta).clamp(0, widget.files.length - 1);
    setState(() => _focusedIndex = next);

    final isShift = HardwareKeyboard.instance.logicalKeysPressed
        .any((k) =>
            k == LogicalKeyboardKey.shiftLeft ||
            k == LogicalKeyboardKey.shiftRight);

    if (isShift && widget.enableMultiSelect) {
      final newSelection = Set<Object>.from(widget.selectedKeys);
      newSelection.add(widget.files[next].id);
      widget.onSelectionChange(newSelection);
    } else {
      widget.onSelectionChange({widget.files[next].id});
    }
    _lastTappedIndex = next;
  }

  void _moveFocusTo(int index) {
    if (widget.files.isEmpty) return;
    final clamped = index.clamp(0, widget.files.length - 1);
    setState(() => _focusedIndex = clamped);
    widget.onSelectionChange({widget.files[clamped].id});
    _lastTappedIndex = clamped;
  }

  void _handleRubberBandSelection(Rect rect) {
    if (widget.files.isEmpty) return;

    final spacing = context.spacing;
    final headerHeight = ((spacing as dynamic).xs as double) * 2 + 16;
    final rowPaddingV = (spacing as dynamic).sm as double;
    const iconHeight = 24.0;
    final rowHeight = rowPaddingV * 2 + iconHeight;

    final selected = <Object>{};
    for (var i = 0; i < widget.files.length; i++) {
      final rowTop = headerHeight + i * rowHeight;
      final rowBottom = rowTop + rowHeight;
      if (rect.bottom > rowTop && rect.top < rowBottom) {
        selected.add(widget.files[i].id);
      }
    }
    widget.onSelectionChange(selected);
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
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: OiSelectionOverlay(
          onSelectionRect: _handleRubberBandSelection,
          onSelectionStart: () {},
          onSelectionEnd: () {},
          child: OiContextMenu(
            label: 'File list background menu',
            items: widget.backgroundContextMenu?.call() ?? [],
            enabled: widget.backgroundContextMenu != null,
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
                      final isSelected =
                          widget.selectedKeys.contains(file.id);
                      final isRenaming = widget.renamingKey == file.id;
                      final isFocused = _focusedIndex == index;

                      return _buildRow(
                        file,
                        index,
                        isSelected,
                        isRenaming,
                        isFocused,
                        colors,
                        spacing,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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

    return Semantics(
      label: 'Column headers',
      child: Container(
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
                child: Semantics(
                  button: true,
                  label: 'Sort by name',
                  child: Text(
                    'Name${sortIndicator(OiFileSortField.name)}',
                    style: textStyle,
                  ),
                ),
              ),
            ),
            if (widget.showSize)
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleSort(OiFileSortField.size),
                  child: Semantics(
                    button: true,
                    label: 'Sort by size',
                    child: Text(
                      'Size${sortIndicator(OiFileSortField.size)}',
                      style: textStyle,
                    ),
                  ),
                ),
              ),
            if (widget.showModified)
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _toggleSort(OiFileSortField.modified),
                  child: Semantics(
                    button: true,
                    label: 'Sort by modified date',
                    child: Text(
                      'Modified${sortIndicator(OiFileSortField.modified)}',
                      style: textStyle,
                    ),
                  ),
                ),
              ),
            if (widget.showType)
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleSort(OiFileSortField.type),
                  child: Semantics(
                    button: true,
                    label: 'Sort by type',
                    child: Text(
                      'Type${sortIndicator(OiFileSortField.type)}',
                      style: textStyle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    OiFileNodeData file,
    int index,
    bool isSelected,
    bool isRenaming,
    bool isFocused,
    dynamic colors,
    dynamic spacing,
  ) {
    final fileType = file.isFolder ? 'folder' : file.resolvedExtension;
    final semanticLabel =
        '${file.name}, $fileType${isSelected ? ', selected' : ''}';

    Widget row = Semantics(
      label: semanticLabel,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => _onTap(file, index),
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
                        semanticsLabel: 'Rename ${file.name}',
                      )
                    : _buildName(file, colors),
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
      ),
    );

    // Wrap with context menu
    if (widget.contextMenuBuilder != null) {
      row = OiContextMenu(
        label: 'Context menu for ${file.name}',
        items: widget.contextMenuBuilder!(file),
        child: row,
      );
    }

    // Wrap with drag-and-drop
    if (widget.enableDragDrop) {
      // If this is a folder, make it a drop target too
      if (file.isFolder && widget.onMoveToFolder != null) {
        row = OiDropZone<List<OiFileNodeData>>(
          onWillAccept: (data) {
            if (data == null) return false;
            // Don't accept a folder onto itself
            return !data.any((f) => f.id == file.id);
          },
          onAccept: (droppedFiles) {
            widget.onMoveToFolder!(droppedFiles, file);
          },
          builder: (context, state) {
            return Container(
              decoration: state == OiDropState.hovering
                  ? BoxDecoration(
                      border: Border.all(
                        color: (colors as dynamic).primary.base as Color,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: row,
            );
          },
        );
      }

      // Make selected items draggable
      final dragData = isSelected
          ? widget.files
              .where((f) => widget.selectedKeys.contains(f.id))
              .toList()
          : [file];

      row = OiDraggable<List<OiFileNodeData>>(
        data: dragData,
        feedback: _buildDragFeedback(dragData, colors),
        child: row,
      );
    }

    return row;
  }

  Widget _buildName(OiFileNodeData file, dynamic colors) {
    final normalStyle = TextStyle(
      fontSize: 13,
      color: (colors as dynamic).text as Color,
    );

    final query = widget.searchQuery;
    if (query == null || query.isEmpty) {
      return Text(
        file.name,
        style: normalStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final spans = _highlightSpans(
      file.name,
      query,
      normalStyle,
      normalStyle.copyWith(
        fontWeight: FontWeight.w700,
        color: (colors as dynamic).primary.base as Color,
      ),
    );

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDragFeedback(List<OiFileNodeData> files, dynamic colors) {
    final label = files.length == 1
        ? files.first.name
        : '${files.length} items';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (colors as dynamic).surface as Color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: ((colors as dynamic).overlay as Color)
                .withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (files.length == 1 && files.first.isFolder)
            const OiFolderIcon(size: OiFolderIconSize.sm)
          else if (files.length == 1)
            OiFileIcon(
              fileName: files.first.name,
              size: OiFileIconSize.sm,
            )
          else
            Text(
              '${files.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: (colors as dynamic).primary.base as Color,
              ),
            ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: (colors as dynamic).text as Color,
            ),
          ),
        ],
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
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

List<TextSpan> _highlightSpans(
  String text,
  String query,
  TextStyle normal,
  TextStyle highlighted,
) {
  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();
  final index = lowerText.indexOf(lowerQuery);

  if (index < 0) {
    return [TextSpan(text: text, style: normal)];
  }

  final before = text.substring(0, index);
  final match = text.substring(index, index + query.length);
  final after = text.substring(index + query.length);

  return [
    if (before.isNotEmpty) TextSpan(text: before, style: normal),
    TextSpan(text: match, style: highlighted),
    if (after.isNotEmpty) TextSpan(text: after, style: normal),
  ];
}
