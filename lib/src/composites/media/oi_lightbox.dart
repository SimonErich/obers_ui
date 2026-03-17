import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_image.dart';

/// An item in the lightbox gallery.
///
/// {@category Composites}
class OiLightboxItem {
  /// Creates an [OiLightboxItem].
  const OiLightboxItem({required this.src, required this.alt, this.caption});

  /// The image source URL or asset path.
  final String src;

  /// Accessibility description for the image.
  final String alt;

  /// Optional caption displayed below the image.
  final String? caption;
}

/// Full-screen image viewer with gallery navigation, zoom, and thumbnails.
///
/// Displays images in a full-screen overlay with swipe navigation,
/// pinch-to-zoom, thumbnail strip, and captions.
///
/// {@category Composites}
class OiLightbox extends StatefulWidget {
  /// Creates an [OiLightbox].
  const OiLightbox({
    required this.items,
    required this.initialIndex,
    required this.label,
    this.onDismiss,
    this.showThumbnails = true,
    this.enableZoom = true,
    this.enableSwipe = true,
    super.key,
  });

  /// The list of images to display in the lightbox.
  final List<OiLightboxItem> items;

  /// The index of the initially displayed image.
  final int initialIndex;

  /// Called when the lightbox is dismissed (close button or background tap).
  final VoidCallback? onDismiss;

  /// Whether to show the thumbnail strip at the bottom.
  final bool showThumbnails;

  /// Whether pinch-to-zoom is enabled on the displayed image.
  final bool enableZoom;

  /// Whether horizontal swipe navigation between images is enabled.
  final bool enableSwipe;

  /// Semantic label for the lightbox widget.
  final String label;

  @override
  State<OiLightbox> createState() => _OiLightboxState();
}

class _OiLightboxState extends State<OiLightbox> {
  late int _currentIndex;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _maxIndex);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  int get _maxIndex => widget.items.isEmpty ? 0 : widget.items.length - 1;

  /// Whether navigation to the previous image is possible.
  bool get _hasPrevious => _currentIndex > 0;

  /// Whether navigation to the next image is possible.
  bool get _hasNext => _currentIndex < _maxIndex;

  void _goTo(int index) {
    if (index < 0 || index > _maxIndex) return;
    setState(() => _currentIndex = index);
  }

  void _previous() {
    if (_hasPrevious) _goTo(_currentIndex - 1);
  }

  void _next() {
    if (_hasNext) _goTo(_currentIndex + 1);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      _previous();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      _next();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onDismiss?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final textTheme = context.textTheme;
    final item = widget.items[_currentIndex];

    Widget image = OiImage(
      key: ValueKey('oi_lightbox_image_$_currentIndex'),
      src: item.src,
      alt: item.alt,
      fit: BoxFit.contain,
      errorWidget: const SizedBox.shrink(),
    );

    if (widget.enableZoom) {
      image = InteractiveViewer(
        key: const Key('oi_lightbox_zoom'),
        minScale: 0.5,
        maxScale: 4,
        child: image,
      );
    }

    if (widget.enableSwipe) {
      image = GestureDetector(
        key: const Key('oi_lightbox_swipe'),
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 200) {
            _previous();
          } else if (velocity < -200) {
            _next();
          }
        },
        child: image,
      );
    }

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: widget.label,
        child: Stack(
          key: const Key('oi_lightbox'),
          children: [
            // Scrim
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onDismiss,
                child: ColoredBox(color: colors.overlay),
              ),
            ),

            // Main image area
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 56,
                  vertical: 72,
                ),
                child: image,
              ),
            ),

            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                key: const Key('oi_lightbox_close'),
                onTap: widget.onDismiss,
                child: Semantics(
                  label: 'Close lightbox',
                  button: true,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '\u00D7',
                        style: TextStyle(
                          fontSize: 24,
                          color: colors.text,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Previous arrow
            if (_hasPrevious)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    key: const Key('oi_lightbox_previous'),
                    onTap: _previous,
                    child: Semantics(
                      label: 'Previous image',
                      button: true,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '\u2039',
                            style: TextStyle(
                              fontSize: 24,
                              color: colors.text,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Next arrow
            if (_hasNext)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    key: const Key('oi_lightbox_next'),
                    onTap: _next,
                    child: Semantics(
                      label: 'Next image',
                      button: true,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '\u203A',
                            style: TextStyle(
                              fontSize: 24,
                              color: colors.text,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Caption
            if (item.caption != null)
              Positioned(
                left: 56,
                right: 56,
                bottom: widget.showThumbnails ? 88 : 16,
                child: Center(
                  child: Text(
                    item.caption!,
                    key: const Key('oi_lightbox_caption'),
                    style: textTheme.body.copyWith(color: colors.textInverse),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Thumbnail strip
            if (widget.showThumbnails && widget.items.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: SizedBox(
                  height: 56,
                  child: Center(
                    child: ListView.separated(
                      key: const Key('oi_lightbox_thumbnails'),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final thumbItem = widget.items[index];
                        final isSelected = index == _currentIndex;
                        return GestureDetector(
                          onTap: () => _goTo(index),
                          child: Semantics(
                            label: thumbItem.alt,
                            selected: isSelected,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? colors.primary.base
                                      : colors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: OiImage.decorative(
                                  src: thumbItem.src,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorWidget: const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
