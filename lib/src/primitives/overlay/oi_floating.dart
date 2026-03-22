import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// Alignment options for floating overlays.
///
/// Specifies on which side and at which position along that side the floating
/// content appears relative to its anchor widget.
///
/// {@category Primitives}
enum OiFloatingAlignment {
  /// Above the anchor, aligned to its start (left) edge.
  topStart,

  /// Above the anchor, centered horizontally.
  topCenter,

  /// Above the anchor, aligned to its end (right) edge.
  topEnd,

  /// Below the anchor, aligned to its start (left) edge.
  bottomStart,

  /// Below the anchor, centered horizontally.
  bottomCenter,

  /// Below the anchor, aligned to its end (right) edge.
  bottomEnd,

  /// To the left of the anchor, aligned to its start (top) edge.
  leftStart,

  /// To the left of the anchor, centered vertically.
  leftCenter,

  /// To the left of the anchor, aligned to its end (bottom) edge.
  leftEnd,

  /// To the right of the anchor, aligned to its start (top) edge.
  rightStart,

  /// To the right of the anchor, centered vertically.
  rightCenter,

  /// To the right of the anchor, aligned to its end (bottom) edge.
  rightEnd,
}

/// Positions a floating overlay relative to an anchor widget.
///
/// Uses [OverlayPortal] to render the floating content in the nearest
/// [Overlay], ensuring it paints above sibling widgets. The floating child
/// tracks the anchor via [CompositedTransformFollower].
///
/// Use [visible] to show or hide the floating content. Use [alignment] to
/// control which side of the anchor the floating content appears on. Use [gap]
/// to add spacing between the anchor and the floating content. When
/// [autoFlip] is true the widget attempts to flip to the opposite side if the
/// floating content would overflow the viewport. On compact breakpoints, set
/// [bottomSheetOnCompact] to render the child as a full-width panel at the
/// bottom of the screen instead.
///
/// {@category Primitives}
class OiFloating extends StatefulWidget {
  /// Creates an [OiFloating] widget.
  const OiFloating({
    required this.anchor,
    required this.child,
    this.visible = false,
    this.alignment = OiFloatingAlignment.bottomStart,
    this.gap = 4,
    this.autoFlip = true,
    this.bottomSheetOnCompact = false,
    this.offset,
    super.key,
  });

  /// The widget that serves as the anchor for positioning.
  final Widget anchor;

  /// The floating content to display.
  final Widget child;

  /// Whether the floating content is visible.
  final bool visible;

  /// Alignment of the floating content relative to the anchor.
  final OiFloatingAlignment alignment;

  /// Gap in logical pixels between the anchor and the floating content.
  final double gap;

  /// Whether to flip to the opposite side if the content would overflow the
  /// viewport.
  final bool autoFlip;

  /// On compact breakpoints, render [child] as a bottom sheet instead of
  /// using anchor-relative positioning.
  final bool bottomSheetOnCompact;

  /// Additional offset adjustments applied on top of the computed position.
  final Offset? offset;

  @override
  State<OiFloating> createState() => _OiFloatingState();
}

class _OiFloatingState extends State<OiFloating> {
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _portalController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    // Always show the portal — visibility is controlled by the builder
    // returning SizedBox.shrink() when not visible. This avoids calling
    // show()/hide() during build phases which can trigger assertions.
    _portalController.show();
  }

  bool get _useBottomSheet => widget.bottomSheetOnCompact && context.isCompact;

  /// Returns the targetAnchor, followerAnchor, and linkedOffset for the
  /// given [alignment] and [gap].
  ({Alignment targetAnchor, Alignment followerAnchor, Offset linkedOffset})
  _anchorsFor(OiFloatingAlignment alignment, double gap) {
    switch (alignment) {
      case OiFloatingAlignment.topStart:
        return (
          targetAnchor: Alignment.topLeft,
          followerAnchor: Alignment.bottomLeft,
          linkedOffset: Offset(0, -gap),
        );
      case OiFloatingAlignment.topCenter:
        return (
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          linkedOffset: Offset(0, -gap),
        );
      case OiFloatingAlignment.topEnd:
        return (
          targetAnchor: Alignment.topRight,
          followerAnchor: Alignment.bottomRight,
          linkedOffset: Offset(0, -gap),
        );
      case OiFloatingAlignment.bottomStart:
        return (
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          linkedOffset: Offset(0, gap),
        );
      case OiFloatingAlignment.bottomCenter:
        return (
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.topCenter,
          linkedOffset: Offset(0, gap),
        );
      case OiFloatingAlignment.bottomEnd:
        return (
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          linkedOffset: Offset(0, gap),
        );
      case OiFloatingAlignment.leftStart:
        return (
          targetAnchor: Alignment.topLeft,
          followerAnchor: Alignment.topRight,
          linkedOffset: Offset(-gap, 0),
        );
      case OiFloatingAlignment.leftCenter:
        return (
          targetAnchor: Alignment.centerLeft,
          followerAnchor: Alignment.centerRight,
          linkedOffset: Offset(-gap, 0),
        );
      case OiFloatingAlignment.leftEnd:
        return (
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.bottomRight,
          linkedOffset: Offset(-gap, 0),
        );
      case OiFloatingAlignment.rightStart:
        return (
          targetAnchor: Alignment.topRight,
          followerAnchor: Alignment.topLeft,
          linkedOffset: Offset(gap, 0),
        );
      case OiFloatingAlignment.rightCenter:
        return (
          targetAnchor: Alignment.centerRight,
          followerAnchor: Alignment.centerLeft,
          linkedOffset: Offset(gap, 0),
        );
      case OiFloatingAlignment.rightEnd:
        return (
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.bottomLeft,
          linkedOffset: Offset(gap, 0),
        );
    }
  }

  /// Returns the opposite alignment used for auto-flip.
  OiFloatingAlignment _flippedAlignment(OiFloatingAlignment alignment) {
    switch (alignment) {
      case OiFloatingAlignment.topStart:
        return OiFloatingAlignment.bottomStart;
      case OiFloatingAlignment.topCenter:
        return OiFloatingAlignment.bottomCenter;
      case OiFloatingAlignment.topEnd:
        return OiFloatingAlignment.bottomEnd;
      case OiFloatingAlignment.bottomStart:
        return OiFloatingAlignment.topStart;
      case OiFloatingAlignment.bottomCenter:
        return OiFloatingAlignment.topCenter;
      case OiFloatingAlignment.bottomEnd:
        return OiFloatingAlignment.topEnd;
      case OiFloatingAlignment.leftStart:
        return OiFloatingAlignment.rightStart;
      case OiFloatingAlignment.leftCenter:
        return OiFloatingAlignment.rightCenter;
      case OiFloatingAlignment.leftEnd:
        return OiFloatingAlignment.rightEnd;
      case OiFloatingAlignment.rightStart:
        return OiFloatingAlignment.leftStart;
      case OiFloatingAlignment.rightCenter:
        return OiFloatingAlignment.leftCenter;
      case OiFloatingAlignment.rightEnd:
        return OiFloatingAlignment.leftEnd;
    }
  }

  OiFloatingAlignment _resolvedAlignment() {
    if (!widget.autoFlip) return widget.alignment;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return widget.alignment;

    final viewportSize = MediaQuery.sizeOf(context);
    final globalPosition = renderBox.localToGlobal(Offset.zero);

    switch (widget.alignment) {
      case OiFloatingAlignment.topStart:
      case OiFloatingAlignment.topCenter:
      case OiFloatingAlignment.topEnd:
        if (globalPosition.dy < 100) {
          return _flippedAlignment(widget.alignment);
        }
      case OiFloatingAlignment.bottomStart:
      case OiFloatingAlignment.bottomCenter:
      case OiFloatingAlignment.bottomEnd:
        if (globalPosition.dy + renderBox.size.height + 100 >
            viewportSize.height) {
          return _flippedAlignment(widget.alignment);
        }
      case OiFloatingAlignment.leftStart:
      case OiFloatingAlignment.leftCenter:
      case OiFloatingAlignment.leftEnd:
        if (globalPosition.dx < 100) {
          return _flippedAlignment(widget.alignment);
        }
      case OiFloatingAlignment.rightStart:
      case OiFloatingAlignment.rightCenter:
      case OiFloatingAlignment.rightEnd:
        if (globalPosition.dx + renderBox.size.width + 100 >
            viewportSize.width) {
          return _flippedAlignment(widget.alignment);
        }
    }
    return widget.alignment;
  }

  Widget _buildOverlayChild(BuildContext context) {
    // When not visible, return an empty widget so the portal can stay
    // "shown" without rendering anything.
    if (!widget.visible) return const SizedBox.shrink();

    if (_useBottomSheet) {
      return Positioned(left: 0, right: 0, bottom: 0, child: widget.child);
    }

    final resolvedAlignment = _resolvedAlignment();
    final anchors = _anchorsFor(resolvedAlignment, widget.gap);
    final extraOffset = widget.offset ?? Offset.zero;
    final linkedOffset = anchors.linkedOffset + extraOffset;

    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      targetAnchor: anchors.targetAnchor,
      followerAnchor: anchors.followerAnchor,
      offset: linkedOffset,
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: _buildOverlayChild,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: widget.anchor,
      ),
    );
  }
}
