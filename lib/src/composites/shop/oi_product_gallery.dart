import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';

// Material Icons codepoint.
const IconData _kImagePlaceholder = IconData(
  0xe3f4,
  fontFamily: 'MaterialIcons',
); // image

/// An image gallery with an optional thumbnail strip for product detail pages.
///
/// Coverage: REQ-0071
///
/// Displays a large main image with a horizontal thumbnail strip below.
/// Tapping a thumbnail changes the selected image. When the image list is
/// empty a placeholder icon is shown.
///
/// {@category Composites}
class OiProductGallery extends StatefulWidget {
  /// Creates an [OiProductGallery].
  const OiProductGallery({
    required this.imageUrls,
    required this.label,
    this.initialIndex = 0,
    this.onIndexChanged,
    this.showThumbnails = true,
    super.key,
  });

  /// The list of image URLs to display.
  final List<String> imageUrls;

  /// Accessibility label announced by screen readers.
  final String label;

  /// The initially selected image index. Defaults to `0`.
  final int initialIndex;

  /// Called when the selected image index changes.
  final ValueChanged<int>? onIndexChanged;

  /// Whether to show the thumbnail strip. Defaults to `true`.
  final bool showThumbnails;

  @override
  State<OiProductGallery> createState() => _OiProductGalleryState();
}

class _OiProductGalleryState extends State<OiProductGallery> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(
      0,
      widget.imageUrls.isEmpty ? 0 : widget.imageUrls.length - 1,
    );
  }

  @override
  void didUpdateWidget(OiProductGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrls.length != oldWidget.imageUrls.length) {
      _currentIndex = _currentIndex.clamp(
        0,
        widget.imageUrls.isEmpty ? 0 : widget.imageUrls.length - 1,
      );
    }
  }

  void _selectIndex(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    widget.onIndexChanged?.call(index);
  }

  Widget _buildMainImage(BuildContext context) {
    final colors = context.colors;

    if (widget.imageUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: OiSurface(
          color: colors.surfaceSubtle,
          borderRadius: context.radius.md,
          child: Center(
            child: Icon(_kImagePlaceholder, size: 48, color: colors.textMuted),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(context.radius.md),
      child: AspectRatio(
        aspectRatio: 1,
        child: OiImage(
          src: widget.imageUrls[_currentIndex],
          alt: '${widget.label} image ${_currentIndex + 1}',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildThumbnailStrip(BuildContext context) {
    if (!widget.showThumbnails || widget.imageUrls.length <= 1) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final sp = context.spacing;

    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.imageUrls.length,
        separatorBuilder: (_, __) => SizedBox(width: sp.xs),
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          final borderColor = isSelected
              ? colors.primary.base
              : colors.borderSubtle;

          return OiTappable(
            onTap: () => _selectIndex(index),
            child: OiSurface(
              borderRadius: context.radius.sm,
              border: OiBorderStyle.solid(borderColor, isSelected ? 2 : 1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.radius.sm),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: OiImage(
                    src: widget.imageUrls[index],
                    alt: 'Thumbnail ${index + 1}',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    return Semantics(
      label: widget.label,
      child: ExcludeSemantics(
        child: OiColumn(
          breakpoint: breakpoint,
          gap: OiResponsive(sp.sm),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildMainImage(context), _buildThumbnailStrip(context)],
        ),
      ),
    );
  }
}
