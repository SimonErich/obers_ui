import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// Source of media items.
///
/// {@category Modules}
enum OiMediaSource {
  /// Browse from an existing gallery of items.
  gallery,

  /// Browse or upload files from the local file system.
  files,
}

/// Type filter for media.
///
/// {@category Modules}
enum OiMediaType {
  /// Only images.
  image,

  /// Only videos.
  video,

  /// Only documents.
  document,

  /// Any media type (no filter).
  any,
}

/// A media item in the picker.
///
/// {@category Modules}
@immutable
class OiMediaItem {
  /// Creates an [OiMediaItem].
  const OiMediaItem({
    required this.key,
    required this.name,
    this.thumbnailUrl,
    this.thumbnail,
    this.mimeType,
    this.sizeBytes,
  });

  /// A unique identifier for this item.
  final Object key;

  /// The display name of the item (e.g. file name).
  final String name;

  /// An optional URL for a thumbnail image preview.
  final String? thumbnailUrl;

  /// An optional widget to render as a thumbnail preview.
  final Widget? thumbnail;

  /// The MIME type of the item (e.g. `'image/png'`).
  final String? mimeType;

  /// The size of the item in bytes.
  final int? sizeBytes;
}

/// Upload progress for a media item.
///
/// {@category Modules}
@immutable
class OiMediaUploadProgress {
  /// Creates an [OiMediaUploadProgress].
  const OiMediaUploadProgress({
    required this.itemKey,
    required this.progress,
    this.error,
  });

  /// The key of the [OiMediaItem] this progress belongs to.
  final Object itemKey;

  /// Upload progress from 0.0 (not started) to 1.0 (complete).
  final double progress;

  /// An optional error message if the upload failed.
  final String? error;
}

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------

/// A media picker with gallery browsing, file selection, multi-select,
/// and upload progress indicators.
///
/// {@category Modules}
class OiMediaPicker extends StatefulWidget {
  /// Creates an [OiMediaPicker].
  const OiMediaPicker({
    required this.label,
    this.sources = const [OiMediaSource.gallery, OiMediaSource.files],
    this.allowedTypes = OiMediaType.any,
    this.maxItems = 10,
    this.maxFileSize,
    this.selected = const [],
    this.onSelect,
    this.onRemove,
    this.uploadProgress = const [],
    this.galleryItems = const [],
    this.onLoadMoreGallery,
    this.moreGalleryAvailable = false,
    super.key,
  });

  /// The semantic label for the entire picker.
  final String label;

  /// The available media sources. Defaults to both gallery and files.
  final List<OiMediaSource> sources;

  /// The type filter applied to selectable media. Defaults to [OiMediaType.any].
  final OiMediaType allowedTypes;

  /// The maximum number of items that can be selected. Defaults to 10.
  final int maxItems;

  /// Optional maximum file size in bytes.
  final int? maxFileSize;

  /// The currently selected items.
  final List<OiMediaItem> selected;

  /// Called with the full list of selected items after each selection change.
  final void Function(List<OiMediaItem>)? onSelect;

  /// Called when an item is removed from the selection strip.
  final void Function(OiMediaItem)? onRemove;

  /// Upload progress for items currently being uploaded.
  final List<OiMediaUploadProgress> uploadProgress;

  /// Gallery items available for selection.
  final List<OiMediaItem> galleryItems;

  /// Called when the user requests more gallery items.
  final Future<void> Function()? onLoadMoreGallery;

  /// Whether more gallery items are available to load.
  final bool moreGalleryAvailable;

  @override
  State<OiMediaPicker> createState() => _OiMediaPickerState();
}

class _OiMediaPickerState extends State<OiMediaPicker> {
  int _activeSource = 0;
  Set<Object> _selectedKeys = {};

  @override
  void initState() {
    super.initState();
    _selectedKeys = widget.selected.map((item) => item.key).toSet();
  }

  @override
  void didUpdateWidget(OiMediaPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _selectedKeys = widget.selected.map((item) => item.key).toSet();
    }
  }

  void _toggleItem(OiMediaItem item) {
    setState(() {
      if (_selectedKeys.contains(item.key)) {
        _selectedKeys.remove(item.key);
      } else {
        if (_selectedKeys.length >= widget.maxItems) return;
        _selectedKeys.add(item.key);
      }
    });

    final selectedItems = widget.galleryItems
        .where((gi) => _selectedKeys.contains(gi.key))
        .toList();
    widget.onSelect?.call(selectedItems);
  }

  void _removeItem(OiMediaItem item) {
    setState(() {
      _selectedKeys.remove(item.key);
    });
    widget.onRemove?.call(item);
  }

  bool get _atMax => _selectedKeys.length >= widget.maxItems;

  OiMediaUploadProgress? _progressFor(Object key) {
    for (final p in widget.uploadProgress) {
      if (p.itemKey == key) return p;
    }
    return null;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.sources.length > 1) ...[
            _buildSourceTabs(context),
            SizedBox(height: context.spacing.xs),
          ],
          Expanded(child: _buildActiveContent(context)),
          if (_selectedKeys.isNotEmpty) ...[
            const OiDivider(),
            _buildSelectionStrip(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSourceTabs(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      child: Row(
        children: [
          for (int i = 0; i < widget.sources.length; i++)
            Padding(
              padding: EdgeInsets.only(left: i > 0 ? spacing.sm : 0),
              child: OiTappable(
                semanticLabel: _sourceLabel(widget.sources[i]),
                onTap: () => setState(() => _activeSource = i),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: i == _activeSource
                        ? colors.primary.base
                        : colors.surfaceHover,
                    borderRadius: radius.sm,
                  ),
                  child: OiLabel.bodyStrong(
                    _sourceLabel(widget.sources[i]),
                    color: i == _activeSource
                        ? colors.textOnPrimary
                        : colors.textMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _sourceLabel(OiMediaSource source) {
    return switch (source) {
      OiMediaSource.gallery => 'Gallery',
      OiMediaSource.files => 'Files',
    };
  }

  Widget _buildActiveContent(BuildContext context) {
    if (_activeSource >= widget.sources.length) return const SizedBox.shrink();
    final source = widget.sources[_activeSource];
    return switch (source) {
      OiMediaSource.gallery => _buildGalleryTab(context),
      OiMediaSource.files => _buildFilesTab(context),
    };
  }

  // ── Gallery tab ───────────────────────────────────────────────────────────

  Widget _buildGalleryTab(BuildContext context) {
    final spacing = context.spacing;

    if (widget.galleryItems.isEmpty) {
      return const OiEmptyState(
        title: 'No media available',
        icon: OiIcons.images,
        description: 'There are no gallery items to display.',
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(spacing.sm),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: spacing.sm,
              crossAxisSpacing: spacing.sm,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildGalleryItem(context, widget.galleryItems[index]),
              childCount: widget.galleryItems.length,
            ),
          ),
        ),
        if (widget.moreGalleryAvailable)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.md),
              child: OiButton.ghost(
                label: 'Load more',
                icon: OiIcons.plus,
                semanticLabel: 'Load more gallery items',
                onTap: widget.onLoadMoreGallery != null
                    ? () => widget.onLoadMoreGallery!()
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGalleryItem(BuildContext context, OiMediaItem item) {
    final colors = context.colors;
    final radius = context.radius;
    final isSelected = _selectedKeys.contains(item.key);
    final disabled = _atMax && !isSelected;

    return OiTappable(
      semanticLabel: '${item.name}${isSelected ? ", selected" : ""}',
      enabled: !disabled,
      onTap: () => _toggleItem(item),
      child: Opacity(
        opacity: disabled ? 0.4 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius.md,
            border: Border.all(
              color: isSelected ? colors.primary.base : colors.border,
              width: isSelected ? 2 : 1,
            ),
            color: colors.surface,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail or placeholder
              if (item.thumbnail != null)
                item.thumbnail!
              else
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(OiIcons.image, size: 28, color: colors.textMuted),
                      SizedBox(height: context.spacing.xs),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.xs,
                        ),
                        child: OiLabel.caption(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

              // Selection check overlay
              if (isSelected)
                Positioned(
                  top: context.spacing.xs,
                  right: context.spacing.xs,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colors.primary.base,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      OiIcons.check,
                      size: 14,
                      color: colors.textOnPrimary,
                    ),
                  ),
                ),

              // File size badge
              if (item.sizeBytes != null)
                Positioned(
                  bottom: context.spacing.xs,
                  left: context.spacing.xs,
                  child: OiBadge.soft(label: _formatBytes(item.sizeBytes!)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Files tab ─────────────────────────────────────────────────────────────

  Widget _buildFilesTab(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(OiIcons.upload, size: 48, color: colors.textMuted),
          SizedBox(height: spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OiButton.primary(
                label: 'Browse Files',
                icon: OiIcons.file,
                semanticLabel: 'Browse files to upload',
                onTap: widget.onSelect != null ? () {} : null,
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          OiLabel.small('or drag and drop files here', color: colors.textMuted),
          if (widget.maxFileSize != null) ...[
            SizedBox(height: spacing.xs),
            OiLabel.caption(
              'Max file size: ${_formatBytes(widget.maxFileSize!)}',
              color: colors.textMuted,
            ),
          ],
        ],
      ),
    );
  }

  // ── Selection strip ───────────────────────────────────────────────────────

  Widget _buildSelectionStrip(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    final selectedItems = widget.galleryItems
        .where((item) => _selectedKeys.contains(item.key))
        .toList();

    return Padding(
      padding: EdgeInsets.all(spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: spacing.xs),
            child: OiLabel.small(
              '${selectedItems.length}/${widget.maxItems} selected',
              color: colors.textMuted,
            ),
          ),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: selectedItems.length,
              separatorBuilder: (_, _) => SizedBox(width: spacing.xs),
              itemBuilder: (context, index) {
                final item = selectedItems[index];
                final progress = _progressFor(item.key);

                return SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Thumbnail
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: radius.sm,
                          border: Border.all(color: colors.border),
                          color: colors.surface,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: item.thumbnail != null
                            ? SizedBox.expand(child: item.thumbnail)
                            : Center(
                                child: Icon(
                                  OiIcons.image,
                                  size: 20,
                                  color: colors.textMuted,
                                ),
                              ),
                      ),

                      // Remove button
                      Positioned(
                        top: 0,
                        right: 0,
                        child: OiTappable(
                          semanticLabel: 'Remove ${item.name}',
                          onTap: () => _removeItem(item),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: colors.error.base,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              OiIcons.x,
                              size: 12,
                              color: colors.textOnPrimary,
                            ),
                          ),
                        ),
                      ),

                      // Upload progress overlay
                      if (progress != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: _buildUploadIndicator(context, progress),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadIndicator(
    BuildContext context,
    OiMediaUploadProgress progress,
  ) {
    final colors = context.colors;
    final radius = context.radius;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.only(
          bottomLeft: radius.sm.bottomLeft,
          bottomRight: radius.sm.bottomRight,
        ),
      ),
      child: progress.error != null
          ? Icon(OiIcons.x, size: 12, color: colors.error.base)
          : OiProgress.linear(value: progress.progress, strokeWidth: 3),
    );
  }
}
