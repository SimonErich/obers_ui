import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiFileListView;
import 'package:obers_ui/src/components/display/oi_file_icon.dart';
import 'package:obers_ui/src/components/display/oi_file_preview.dart';
import 'package:obers_ui/src/components/display/oi_folder_icon.dart';
import 'package:obers_ui/src/components/display/oi_rename_field.dart';
import 'package:obers_ui/src/components/interaction/oi_selection_overlay.dart';
import 'package:obers_ui/src/components/overlays/oi_context_menu.dart';
import 'package:obers_ui/src/composites/files/oi_file_list_view.dart'
    show OiFileListView;
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_draggable.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_drop_zone.dart';

/// The grid view of files.
///
/// Renders a virtualized grid of file cards. Same selection, drag-and-drop,
/// and rename behavior as [OiFileListView].
///
/// {@category Composites}
class OiFileGridView extends StatefulWidget {
  /// Creates an [OiFileGridView].
  const OiFileGridView({
    required this.files,
    required this.selectedKeys,
    required this.onSelectionChange,
    required this.onOpen,
    this.cardWidth = 160,
    this.cardHeight = 180,
    this.gap = 12,
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

  /// Card width.
  final double cardWidth;

  /// Card height.
  final double cardHeight;

  /// Gap between cards.
  final double gap;

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
  State<OiFileGridView> createState() => _OiFileGridViewState();
}

class _OiFileGridViewState extends State<OiFileGridView> {
  int? _lastTappedIndex;
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

    final isShift = HardwareKeyboard.instance.logicalKeysPressed.any(
      (k) =>
          k == LogicalKeyboardKey.shiftLeft ||
          k == LogicalKeyboardKey.shiftRight,
    );
    final isCtrl = HardwareKeyboard.instance.logicalKeysPressed.any(
      (k) =>
          k == LogicalKeyboardKey.controlLeft ||
          k == LogicalKeyboardKey.controlRight ||
          k == LogicalKeyboardKey.metaLeft ||
          k == LogicalKeyboardKey.metaRight,
    );

    if (isShift && _lastTappedIndex != null) {
      final start = _lastTappedIndex! < index ? _lastTappedIndex! : index;
      final end = _lastTappedIndex! < index ? index : _lastTappedIndex!;
      final newSelection = Set<Object>.from(widget.selectedKeys);
      for (var i = start; i <= end; i++) {
        newSelection.add(widget.files[i].id);
      }
      widget.onSelectionChange(newSelection);
    } else if (isCtrl) {
      final newSelection = Set<Object>.from(widget.selectedKeys);
      if (newSelection.contains(file.id)) {
        newSelection.remove(file.id);
      } else {
        newSelection.add(file.id);
      }
      widget.onSelectionChange(newSelection);
      _lastTappedIndex = index;
    } else {
      widget.onSelectionChange({file.id});
      _lastTappedIndex = index;
    }

    setState(() => _focusedIndex = index);
  }

  void _onDoubleTap(OiFileNodeData file) {
    widget.onOpen(file);
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowRight) {
      _moveFocus(1);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _moveFocus(-1);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      // Move to next row (estimate columns from layout)
      _moveFocus(_estimateColumns());
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _moveFocus(-_estimateColumns());
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

  int _estimateColumns() {
    final viewWidth =
        (context.findRenderObject() as RenderBox?)?.size.width ?? 800;
    return (viewWidth / (widget.cardWidth + widget.gap)).floor().clamp(1, 20);
  }

  void _moveFocus(int delta) {
    if (widget.files.isEmpty) return;
    final next = (_focusedIndex + delta).clamp(0, widget.files.length - 1);
    setState(() => _focusedIndex = next);

    final isShift = HardwareKeyboard.instance.logicalKeysPressed.any(
      (k) =>
          k == LogicalKeyboardKey.shiftLeft ||
          k == LogicalKeyboardKey.shiftRight,
    );

    if (isShift && widget.enableMultiSelect) {
      final newSelection = Set<Object>.from(widget.selectedKeys)
        ..add(widget.files[next].id);
      widget.onSelectionChange(newSelection);
    } else {
      widget.onSelectionChange({widget.files[next].id});
    }
    _lastTappedIndex = next;
  }

  void _handleRubberBandSelection(Rect rect) {
    if (widget.files.isEmpty) return;

    final spacing = context.spacing;
    final padding = (spacing as dynamic).md as double;
    final cols = _estimateColumns();
    final cellWidth = widget.cardWidth + widget.gap;
    final cellHeight = widget.cardHeight + widget.gap;

    final selected = <Object>{};
    for (var i = 0; i < widget.files.length; i++) {
      final row = i ~/ cols;
      final col = i % cols;
      final itemRect = Rect.fromLTWH(
        padding + col * cellWidth,
        padding + row * cellHeight,
        widget.cardWidth,
        widget.cardHeight,
      );
      if (rect.overlaps(itemRect)) {
        selected.add(widget.files[i].id);
      }
    }
    widget.onSelectionChange(selected);
  }

  void _moveFocusTo(int index) {
    if (widget.files.isEmpty) return;
    final clamped = index.clamp(0, widget.files.length - 1);
    setState(() => _focusedIndex = clamped);
    widget.onSelectionChange({widget.files[clamped].id});
    _lastTappedIndex = clamped;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    if (widget.loading) {
      return _buildLoading(colors, spacing);
    }

    return Semantics(
      label: widget.semanticsLabel ?? 'File grid',
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: OiSelectionOverlay(
          onSelectionRect: _handleRubberBandSelection,
          onSelectionStart: () {},
          onSelectionEnd: () {},
          child: OiContextMenu(
            label: 'File grid background menu',
            items: widget.backgroundContextMenu?.call() ?? [],
            enabled: widget.backgroundContextMenu != null,
            child: GridView.builder(
              padding: EdgeInsets.all(spacing.md),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: widget.cardWidth,
                mainAxisSpacing: widget.gap,
                crossAxisSpacing: widget.gap,
                mainAxisExtent: widget.cardHeight,
              ),
              itemCount: widget.files.length,
              itemBuilder: (context, index) {
                final file = widget.files[index];
                final selected = widget.selectedKeys.contains(file.id);
                final renaming = widget.renamingKey == file.id;

                return _buildCard(
                  file,
                  index,
                  selected,
                  renaming,
                  colors,
                  spacing,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    OiFileNodeData file,
    int index,
    bool selected,
    bool renaming,
    OiColorScheme colors,
    OiSpacingScale spacing,
  ) {
    final fileType = file.folder ? 'folder' : file.resolvedExtension;
    final semanticLabel =
        '${file.name}, $fileType${selected ? ', selected' : ''}';

    Widget card = Semantics(
      label: semanticLabel,
      selected: selected,
      child: GestureDetector(
        onTap: () => _onTap(file, index),
        onDoubleTap: () => _onDoubleTap(file),
        child: Container(
          padding: EdgeInsets.all(spacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.muted.withValues(alpha: 0.15)
                : null,
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(color: colors.primary.base)
                : Border.all(color: colors.borderSubtle),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Preview area
              Expanded(
                child: Center(
                  child: file.folder
                      ? const OiFolderIcon(size: OiFolderIconSize.xl)
                      : (file.thumbnailUrl != null
                            ? OiFilePreview(
                                file: file,
                                width: widget.cardWidth - 24,
                                height: widget.cardHeight - 60,
                              )
                            : OiFileIcon(
                                fileName: file.name,
                                mimeType: file.mimeType,
                                size: OiFileIconSize.lg,
                              )),
                ),
              ),
              SizedBox(height: spacing.xs),
              // Name or rename field
              if (renaming)
                OiRenameField(
                  currentName: file.name,
                  folder: file.folder,
                  onRename: widget.onRename ?? (_) {},
                  onCancel: widget.onCancelRename ?? () {},
                  semanticsLabel: 'Rename ${file.name}',
                )
              else
                _buildName(file, colors),
              // Subtitle
              if (file.folder)
                Text(
                  file.itemCount != null ? '${file.itemCount} items' : 'Empty',
                  style: TextStyle(fontSize: 10, color: colors.textMuted),
                )
              else if (!renaming)
                Text(
                  file.formattedSize,
                  style: TextStyle(fontSize: 10, color: colors.textMuted),
                ),
            ],
          ),
        ),
      ),
    );

    // Wrap with context menu
    if (widget.contextMenuBuilder != null) {
      card = OiContextMenu(
        label: 'Context menu for ${file.name}',
        items: widget.contextMenuBuilder!(file),
        child: card,
      );
    }

    // Wrap with drag-and-drop
    if (widget.enableDragDrop) {
      // If folder, make it a drop target
      if (file.folder && widget.onMoveToFolder != null) {
        // Capture current card value to avoid circular reference in the
        // closure — `card` is reassigned to OiDraggable below.
        final innerCard = card;
        card = OiDropZone<List<OiFileNodeData>>(
          onWillAccept: (data) {
            if (data == null) return false;
            return !data.any((f) => f.id == file.id);
          },
          onAccept: (droppedFiles) {
            widget.onMoveToFolder!(droppedFiles, file);
          },
          builder: (context, state) {
            return DecoratedBox(
              decoration: state == OiDropState.hovering
                  ? BoxDecoration(
                      border: Border.all(color: colors.primary.base, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : const BoxDecoration(),
              child: innerCard,
            );
          },
        );
      }

      final dragData = selected
          ? widget.files
                .where((f) => widget.selectedKeys.contains(f.id))
                .toList()
          : [file];

      card = OiDraggable<List<OiFileNodeData>>(
        data: dragData,
        feedback: _buildDragFeedback(dragData, colors),
        child: card,
      );
    }

    return card;
  }

  Widget _buildName(OiFileNodeData file, OiColorScheme colors) {
    final normalStyle = TextStyle(fontSize: 12, color: colors.text);

    final query = widget.searchQuery;
    if (query == null || query.isEmpty) {
      return Text(
        file.name,
        style: normalStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      );
    }

    final spans = _highlightSpans(
      file.name,
      query,
      normalStyle,
      normalStyle.copyWith(
        fontWeight: FontWeight.w700,
        color: colors.primary.base,
      ),
    );

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDragFeedback(List<OiFileNodeData> files, OiColorScheme colors) {
    final label = files.length == 1
        ? files.first.name
        : '${files.length} items';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (files.length == 1 && files.first.folder)
            const OiFolderIcon(size: OiFolderIconSize.sm)
          else if (files.length == 1)
            OiFileIcon(fileName: files.first.name, size: OiFileIconSize.sm)
          else
            Text(
              '${files.length}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.primary.base,
              ),
            ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: colors.text)),
        ],
      ),
    );
  }

  Widget _buildLoading(OiColorScheme colors, OiSpacingScale spacing) {
    return GridView.builder(
      padding: EdgeInsets.all(spacing.md),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: widget.cardWidth,
        mainAxisSpacing: widget.gap,
        crossAxisSpacing: widget.gap,
        mainAxisExtent: widget.cardHeight,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceHover,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
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
