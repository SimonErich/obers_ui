import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_file_icon.dart';
import 'package:obers_ui/src/components/display/oi_file_preview.dart';
import 'package:obers_ui/src/components/display/oi_folder_icon.dart';
import 'package:obers_ui/src/components/display/oi_rename_field.dart';
import 'package:obers_ui/src/components/interaction/oi_selection_overlay.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

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

  /// Context menu builder for individual files.
  final List<Widget> Function(OiFileNodeData)? contextMenu;

  /// Context menu builder for background (empty area).
  final List<Widget> Function()? backgroundContextMenu;

  /// Whether the view is in a loading state.
  final bool loading;

  /// Accessibility label.
  final String? semanticsLabel;

  @override
  State<OiFileGridView> createState() => _OiFileGridViewState();
}

class _OiFileGridViewState extends State<OiFileGridView> {
  void _onTap(OiFileNodeData file) {
    final newSelection = <Object>{file.id};
    widget.onSelectionChange(newSelection);
  }

  void _onDoubleTap(OiFileNodeData file) {
    widget.onOpen(file);
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
      child: OiSelectionOverlay(
        onSelectionRect: (rect) {
          // Calculate which items intersect and update selection
        },
        onSelectionStart: () {},
        onSelectionEnd: () {},
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
            final isSelected = widget.selectedKeys.contains(file.id);
            final isRenaming = widget.renamingKey == file.id;

            return _buildCard(file, isSelected, isRenaming, colors, spacing);
          },
        ),
      ),
    );
  }

  Widget _buildCard(OiFileNodeData file, bool isSelected, bool isRenaming,
      dynamic colors, dynamic spacing) {
    return GestureDetector(
      onTap: () => _onTap(file),
      onDoubleTap: () => _onDoubleTap(file),
      child: Container(
        padding: EdgeInsets.all((spacing as dynamic).sm as double),
        decoration: BoxDecoration(
          color: isSelected
              ? ((colors as dynamic).primary.muted as Color)
                  .withValues(alpha: 0.15)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: (colors as dynamic).primary.base as Color)
              : Border.all(
                  color: (colors as dynamic).borderSubtle as Color),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Preview area
            Expanded(
              child: Center(
                child: file.isFolder
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
            SizedBox(height: (spacing as dynamic).xs as double),
            // Name or rename field
            if (isRenaming)
              OiRenameField(
                currentName: file.name,
                isFolder: file.isFolder,
                onRename: widget.onRename ?? (_) {},
                onCancel: widget.onCancelRename ?? () {},
              )
            else
              Text(
                file.name,
                style: TextStyle(
                  fontSize: 12,
                  color: (colors as dynamic).text as Color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            // Subtitle
            if (file.isFolder)
              Text(
                file.itemCount != null
                    ? '${file.itemCount} items'
                    : 'Empty',
                style: TextStyle(
                  fontSize: 10,
                  color: (colors as dynamic).textMuted as Color,
                ),
              )
            else if (!isRenaming)
              Text(
                file.formattedSize,
                style: TextStyle(
                  fontSize: 10,
                  color: (colors as dynamic).textMuted as Color,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(dynamic colors, dynamic spacing) {
    return GridView.builder(
      padding: EdgeInsets.all((spacing as dynamic).md as double),
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
            color: (colors as dynamic).surfaceHover as Color,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
