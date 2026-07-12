import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_page_indicator.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A horizontally-paged content slider for banners, feature tours, and
/// image galleries.
///
/// Each entry in [items] becomes a full-width page the user can swipe
/// between. Optional [autoplay] advances pages on a timer that pauses while
/// the pointer hovers the carousel and resets after any manual navigation.
/// Previous/next [showArrows] and a dot [showIndicator] (built from
/// [OiPageIndicator]) provide explicit controls, and [loop] wraps around at
/// the ends.
///
/// The paging area expands to fill the available height unless a fixed
/// [height] is given, so place the carousel inside a bounded parent (or set
/// [height]).
///
/// ```dart
/// OiCarousel(
///   label: 'Featured products',
///   height: 240,
///   autoplay: true,
///   loop: true,
///   items: [for (final p in products) ProductBanner(p)],
///   onPageChanged: (index) => trackView(index),
/// )
/// ```
///
/// {@category Components}
class OiCarousel extends StatefulWidget {
  /// Creates an [OiCarousel].
  const OiCarousel({
    required this.label,
    required this.items,
    this.initialPage = 0,
    this.height,
    this.autoplay = false,
    this.autoplayInterval = const Duration(seconds: 5),
    this.pauseOnHover = true,
    this.loop = false,
    this.showArrows = true,
    this.showIndicator = true,
    this.viewportFraction = 1.0,
    this.onPageChanged,
    super.key,
  });

  /// Accessibility label describing the carousel's content.
  final String label;

  /// The pages rendered by the carousel, one per entry.
  final List<Widget> items;

  /// The page shown first (zero-based, clamped to a valid index).
  final int initialPage;

  /// A fixed height for the paging area. When `null`, the area expands to
  /// fill the available height of a bounded parent.
  final double? height;

  /// Whether to advance pages automatically on a timer.
  final bool autoplay;

  /// The delay between automatic page advances when [autoplay] is `true`.
  final Duration autoplayInterval;

  /// Whether hovering the carousel pauses [autoplay].
  final bool pauseOnHover;

  /// Whether navigation wraps around at the first and last pages.
  final bool loop;

  /// Whether to show previous/next arrow controls.
  final bool showArrows;

  /// Whether to show the dot page indicator.
  final bool showIndicator;

  /// The fraction of the viewport each page occupies. Values below `1.0`
  /// reveal a sliver of the adjacent pages.
  final double viewportFraction;

  /// Called with the new page index whenever the current page changes.
  final ValueChanged<int>? onPageChanged;

  @override
  State<OiCarousel> createState() => _OiCarouselState();
}

class _OiCarouselState extends State<OiCarousel> {
  late final PageController _controller;
  Timer? _autoplayTimer;
  int _currentPage = 0;
  bool _hovering = false;

  int get _pageCount => widget.items.length;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(0, _maxIndex);
    _controller = PageController(
      initialPage: _currentPage,
      viewportFraction: widget.viewportFraction,
    );
    _restartAutoplay();
  }

  @override
  void didUpdateWidget(OiCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoplay != oldWidget.autoplay ||
        widget.autoplayInterval != oldWidget.autoplayInterval ||
        widget.items.length != oldWidget.items.length) {
      if (_currentPage > _maxIndex) _currentPage = _maxIndex;
      _restartAutoplay();
    }
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  int get _maxIndex => _pageCount == 0 ? 0 : _pageCount - 1;

  bool get _canAutoplay =>
      widget.autoplay && _pageCount > 1 && !(widget.pauseOnHover && _hovering);

  // ── Autoplay ────────────────────────────────────────────────────────────────

  void _restartAutoplay() {
    _autoplayTimer?.cancel();
    if (!_canAutoplay) return;
    _autoplayTimer = Timer.periodic(widget.autoplayInterval, (_) {
      _goTo(_nextIndex(), animate: true, resetTimer: false);
    });
  }

  int _nextIndex() {
    if (_currentPage >= _maxIndex) return widget.loop ? 0 : _currentPage;
    return _currentPage + 1;
  }

  int _previousIndex() {
    if (_currentPage <= 0) return widget.loop ? _maxIndex : 0;
    return _currentPage - 1;
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _goTo(int index, {required bool animate, bool resetTimer = true}) {
    if (index < 0 || index > _maxIndex || !_controller.hasClients) return;
    final reduceMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    if (animate && !reduceMotion) {
      unawaited(
        _controller.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      );
    } else {
      _controller.jumpToPage(index);
    }
    if (resetTimer) _restartAutoplay();
  }

  void _onPageChanged(int index) {
    if (index == _currentPage) return;
    setState(() => _currentPage = index);
    widget.onPageChanged?.call(index);
  }

  void _setHovering({required bool hovering}) {
    if (_hovering == hovering) return;
    _hovering = hovering;
    _restartAutoplay();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_pageCount == 0) {
      return Semantics(
        label: widget.label,
        child: const SizedBox.shrink(key: Key('oi_carousel_empty')),
      );
    }

    final multiPage = _pageCount > 1;
    final viewport = MouseRegion(
      onEnter: (_) => _setHovering(hovering: true),
      onExit: (_) => _setHovering(hovering: false),
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              key: const Key('oi_carousel_pageview'),
              controller: _controller,
              itemCount: _pageCount,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => KeyedSubtree(
                key: Key('oi_carousel_item_$index'),
                child: widget.items[index],
              ),
            ),
          ),
          if (widget.showArrows && multiPage) ...[
            _Arrow(
              alignment: Alignment.centerLeft,
              icon: OiIcons.chevronLeft,
              semanticLabel: 'Previous',
              buttonKey: const Key('oi_carousel_prev'),
              onTap: _currentPage > 0 || widget.loop
                  ? () => _goTo(_previousIndex(), animate: true)
                  : null,
            ),
            _Arrow(
              alignment: Alignment.centerRight,
              icon: OiIcons.chevronRight,
              semanticLabel: 'Next',
              buttonKey: const Key('oi_carousel_next'),
              onTap: _currentPage < _maxIndex || widget.loop
                  ? () => _goTo(_nextIndex(), animate: true)
                  : null,
            ),
          ],
        ],
      ),
    );

    final sp = context.spacing;
    return Semantics(
      label: widget.label,
      container: true,
      child: Column(
        key: const Key('oi_carousel'),
        mainAxisSize: widget.height != null
            ? MainAxisSize.min
            : MainAxisSize.max,
        children: [
          if (widget.height != null)
            SizedBox(height: widget.height, child: viewport)
          else
            Expanded(child: viewport),
          if (widget.showIndicator && multiPage) ...[
            SizedBox(height: sp.sm),
            OiPageIndicator(
              count: _pageCount,
              current: _currentPage,
              semanticLabel: '${widget.label} page indicator',
              onDotTap: (index) => _goTo(index, animate: true),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Arrow control
// ─────────────────────────────────────────────────────────────────────────────

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.alignment,
    required this.icon,
    required this.semanticLabel,
    required this.buttonKey,
    required this.onTap,
  });

  final Alignment alignment;
  final IconData icon;
  final String semanticLabel;
  final Key buttonKey;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.xs),
          child: OiButton.icon(
            key: buttonKey,
            icon: icon,
            label: semanticLabel,
            variant: OiButtonVariant.soft,
            enabled: onTap != null,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
