import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_image.dart';

// ── Selection mode ────────────────────────────────────────────────────────────

/// Selection behaviour for list / grid widgets.
///
/// {@category Composites}
enum OiSelectionMode {
  /// No selection is allowed.
  none,

  /// Only a single item can be selected at a time.
  single,

  /// Multiple items can be selected simultaneously.
  multi,
}

// ── Gallery item ──────────────────────────────────────────────────────────────

/// An item in the gallery.
///
/// {@category Composites}
class OiGalleryItem {
  /// Creates an [OiGalleryItem].
  const OiGalleryItem({
    required this.key,
    required this.src,
    required this.alt,
    this.thumbnailUrl,
  });

  /// Unique identifier for this gallery item.
  final Object key;

  /// The image source URL or asset path.
  final String src;

  /// Accessibility description for the image.
  final String alt;

  /// An optional smaller thumbnail URL used in the grid.
  final String? thumbnailUrl;
}

// ── Gallery widget ────────────────────────────────────────────────────────────

/// Image / media gallery grid with selection and lightbox preview.
///
/// Displays [items] in a grid with [columns] columns. Items can be tapped
/// individually via [onItemTap]. When [selectionMode] is not
/// [OiSelectionMode.none], tapping toggles selection and [onSelectionChange]
/// reports the updated [selectedKeys].
///
/// {@category Composites}
class OiGallery extends StatelessWidget {
  /// Creates an [OiGallery].
  const OiGallery({
    required this.items,
    required this.label,
    this.columns = 4,
    super.key,
    this.selectionMode = OiSelectionMode.none,
    this.selectedKeys = const {},
    this.onSelectionChange,
    this.onItemTap,
    this.showUpload = false,
    this.onUpload,
    this.gap = 8,
  });

  /// The list of gallery items.
  final List<OiGalleryItem> items;

  /// Semantic label for the gallery.
  final String label;

  /// Number of columns in the grid.
  final int columns;

  /// The selection behaviour.
  final OiSelectionMode selectionMode;

  /// The set of currently selected item keys.
  final Set<Object> selectedKeys;

  /// Called when the selection changes.
  final ValueChanged<Set<Object>>? onSelectionChange;

  /// Called when an item is tapped (regardless of selection mode).
  final ValueChanged<OiGalleryItem>? onItemTap;

  /// Whether an upload placeholder tile is shown at the end.
  final bool showUpload;

  /// Called when the upload tile is tapped. The list parameter can carry
  /// platform-specific file references.
  final ValueChanged<List<Object>>? onUpload;

  /// The gap in logical pixels between grid cells.
  final double gap;

  void _handleTap(OiGalleryItem item) {
    onItemTap?.call(item);

    if (selectionMode == OiSelectionMode.none) return;

    final newSelection = Set<Object>.from(selectedKeys);
    if (selectionMode == OiSelectionMode.single) {
      if (newSelection.contains(item.key)) {
        newSelection.remove(item.key);
      } else {
        newSelection
          ..clear()
          ..add(item.key);
      }
    } else {
      // multi
      if (newSelection.contains(item.key)) {
        newSelection.remove(item.key);
      } else {
        newSelection.add(item.key);
      }
    }
    onSelectionChange?.call(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    if (items.isEmpty && !showUpload) {
      return Semantics(
        container: true,
        label: label,
        child: const SizedBox.shrink(key: Key('oi_gallery_empty')),
      );
    }

    final totalCount = items.length + (showUpload ? 1 : 0);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: GridView.builder(
        key: const Key('oi_gallery'),
        shrinkWrap: true,
        itemCount: totalCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
        ),
        itemBuilder: (context, index) {
          // Upload tile
          if (showUpload && index == items.length) {
            return GestureDetector(
              key: const Key('oi_gallery_upload'),
              onTap: () => onUpload?.call(const []),
              child: Semantics(
                label: 'Upload media',
                button: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceHover,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border),
                  ),
                  child: Center(
                    child: Text(
                      '+',
                      style: textTheme.h2.copyWith(color: colors.textMuted),
                    ),
                  ),
                ),
              ),
            );
          }

          final item = items[index];
          final isSelected = selectedKeys.contains(item.key);
          final imgSrc = item.thumbnailUrl ?? item.src;

          return GestureDetector(
            onTap: () => _handleTap(item),
            child: Semantics(
              label: item.alt,
              selected: isSelected,
              child: DecoratedBox(
                key: ValueKey('oi_gallery_item_${item.key}'),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? colors.primary.base
                        : colors.borderSubtle,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      OiImage.decorative(
                        src: imgSrc,
                        fit: BoxFit.cover,
                        errorWidget: const SizedBox.shrink(),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: colors.primary.base,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '\u2713',
                                style: TextStyle(
                                  color: colors.textOnPrimary,
                                  fontSize: 14,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
