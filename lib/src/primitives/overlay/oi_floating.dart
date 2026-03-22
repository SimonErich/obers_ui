import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// Controls what happens when a floating overlay would extend beyond the
/// screen boundary.
///
/// {@category Primitives}
enum OiFloatingOverflow {
  /// Flip to the opposite side when the content would overflow.
  ///
  /// Uses the actual measured child size to detect overflow, so there is no
  /// fixed-pixel approximation.
  flip,

  /// Keep the floating content on the same side of the anchor, but slide it
  /// along the cross-axis so it stays within screen bounds.
  shift,

  /// Do not adjust the position — the overlay may be clipped by screen edges.
  none,
}

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
/// is positioned using [CustomSingleChildLayout] so that the actual measured
/// child size is available when computing the final screen position — no
/// two-frame flicker and no fixed-pixel approximations.
///
/// Use [visible] to show or hide the floating content. Use [alignment] to
/// control which side of the anchor the floating content appears on. Use [gap]
/// to add spacing between the anchor and the floating content.
///
/// Set [overflow] to control what happens when the floating content would
/// extend beyond the screen boundary:
/// - [OiFloatingOverflow.flip] (default) flips to the opposite side.
/// - [OiFloatingOverflow.shift] keeps the same side but slides the content
///   along the cross-axis to stay within bounds.
/// - [OiFloatingOverflow.none] does nothing (the overlay may clip).
///
/// Use [screenPadding] to keep a minimum distance from each screen edge.
///
/// On compact breakpoints, set [bottomSheetOnCompact] to render the child as
/// a full-width panel at the bottom of the screen instead.
///
/// When [onDismiss] is provided, a transparent barrier is placed behind the
/// floating content. Tapping the barrier calls [onDismiss], enabling
/// click-outside-to-close behaviour.
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
    this.overflow = OiFloatingOverflow.flip,
    this.bottomSheetOnCompact = false,
    this.offset,
    this.screenPadding = const EdgeInsets.all(8),
    this.onDismiss,
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
  ///
  /// When `false`, acts as [OiFloatingOverflow.none] regardless of [overflow].
  /// Kept for backward compatibility.
  final bool autoFlip;

  /// Controls what happens when the floating content would overflow the screen.
  ///
  /// Only used when [autoFlip] is `true` (the default). Defaults to
  /// [OiFloatingOverflow.flip].
  final OiFloatingOverflow overflow;

  /// On compact breakpoints, render [child] as a bottom sheet instead of
  /// using anchor-relative positioning.
  final bool bottomSheetOnCompact;

  /// Additional offset adjustments applied on top of the computed position.
  final Offset? offset;

  /// Minimum distance in logical pixels to keep between the floating content
  /// and each screen edge.
  ///
  /// Defaults to `EdgeInsets.all(8)` for a small visual margin. Set to
  /// [EdgeInsets.zero] if the overlay should be allowed to touch screen edges.
  final EdgeInsets screenPadding;

  /// Called when the user taps outside the floating content.
  ///
  /// When non-null, a transparent barrier is placed behind the floating
  /// content. Tapping the barrier calls this callback.
  final VoidCallback? onDismiss;

  @override
  State<OiFloating> createState() => _OiFloatingState();
}

class _OiFloatingState extends State<OiFloating> {
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

  /// Returns the anchor widget's rect in global (overlay) coordinates.
  Rect _getAnchorRect() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return Rect.zero;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Widget _buildOverlayChild(BuildContext context) {
    // When not visible, return an empty widget so the portal can stay
    // "shown" without rendering anything.
    if (!widget.visible) return const SizedBox.shrink();

    Widget content;

    if (_useBottomSheet) {
      content = Positioned(left: 0, right: 0, bottom: 0, child: widget.child);
    } else {
      final effectiveOverflow =
          widget.autoFlip ? widget.overflow : OiFloatingOverflow.none;

      content = CustomSingleChildLayout(
        delegate: _FloatingLayoutDelegate(
          anchorRect: _getAnchorRect(),
          alignment: widget.alignment,
          gap: widget.gap,
          overflow: effectiveOverflow,
          screenPadding: widget.screenPadding,
          offset: widget.offset ?? Offset.zero,
        ),
        child: widget.child,
      );
    }

    if (widget.onDismiss != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: widget.onDismiss,
            ),
          ),
          content,
        ],
      );
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: _buildOverlayChild,
      child: widget.anchor,
    );
  }
}

/// Layout delegate that positions a floating child relative to an anchor rect.
///
/// Computes the ideal position from [alignment] and [gap], then adjusts for
/// screen overflow according to [overflow], respecting [screenPadding].
/// Because [SingleChildLayoutDelegate.getPositionForChild] receives the actual
/// measured child size, there are no fixed-pixel approximations.
class _FloatingLayoutDelegate extends SingleChildLayoutDelegate {
  const _FloatingLayoutDelegate({
    required this.anchorRect,
    required this.alignment,
    required this.gap,
    required this.overflow,
    required this.screenPadding,
    required this.offset,
  });

  final Rect anchorRect;
  final OiFloatingAlignment alignment;
  final double gap;
  final OiFloatingOverflow overflow;
  final EdgeInsets screenPadding;
  final Offset offset;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // Cap the child at the safe area so it can never measure itself larger
    // than what fits on screen.
    final maxW =
        (constraints.maxWidth - screenPadding.left - screenPadding.right)
            .clamp(0.0, double.infinity);
    final maxH =
        (constraints.maxHeight - screenPadding.top - screenPadding.bottom)
            .clamp(0.0, double.infinity);
    return BoxConstraints(maxWidth: maxW, maxHeight: maxH);
  }

  @override
  Offset getPositionForChild(Size screenSize, Size childSize) {
    final w = childSize.width;
    final h = childSize.height;

    // Safe rect = screen inset by screenPadding.
    final safeLeft = screenPadding.left;
    final safeTop = screenPadding.top;
    final safeRight = screenSize.width - screenPadding.right;
    final safeBottom = screenSize.height - screenPadding.bottom;

    // ── Step 1: Compute ideal top-left from alignment + gap ────────────────
    double x;
    double y;

    switch (alignment) {
      case OiFloatingAlignment.bottomStart:
        x = anchorRect.left;
        y = anchorRect.bottom + gap;
      case OiFloatingAlignment.bottomCenter:
        x = anchorRect.center.dx - w / 2;
        y = anchorRect.bottom + gap;
      case OiFloatingAlignment.bottomEnd:
        x = anchorRect.right - w;
        y = anchorRect.bottom + gap;
      case OiFloatingAlignment.topStart:
        x = anchorRect.left;
        y = anchorRect.top - gap - h;
      case OiFloatingAlignment.topCenter:
        x = anchorRect.center.dx - w / 2;
        y = anchorRect.top - gap - h;
      case OiFloatingAlignment.topEnd:
        x = anchorRect.right - w;
        y = anchorRect.top - gap - h;
      case OiFloatingAlignment.rightStart:
        x = anchorRect.right + gap;
        y = anchorRect.top;
      case OiFloatingAlignment.rightCenter:
        x = anchorRect.right + gap;
        y = anchorRect.center.dy - h / 2;
      case OiFloatingAlignment.rightEnd:
        x = anchorRect.right + gap;
        y = anchorRect.bottom - h;
      case OiFloatingAlignment.leftStart:
        x = anchorRect.left - gap - w;
        y = anchorRect.top;
      case OiFloatingAlignment.leftCenter:
        x = anchorRect.left - gap - w;
        y = anchorRect.center.dy - h / 2;
      case OiFloatingAlignment.leftEnd:
        x = anchorRect.left - gap - w;
        y = anchorRect.bottom - h;
    }

    // ── Step 2: Apply manual offset ────────────────────────────────────────
    x += offset.dx;
    y += offset.dy;

    // ── Step 3: Overflow handling (independent per axis) ──────────────────
    if (overflow != OiFloatingOverflow.none) {
      switch (alignment) {
        // ── Vertical primary (top / bottom) ──────────────────────────────
        case OiFloatingAlignment.bottomStart:
        case OiFloatingAlignment.bottomCenter:
        case OiFloatingAlignment.bottomEnd:
          // Primary axis: Y — flip down→up if overflows bottom
          if (overflow == OiFloatingOverflow.flip &&
              y + h > safeBottom) {
            final flippedY = anchorRect.top - gap - h + offset.dy;
            if (flippedY >= safeTop) y = flippedY;
          } else if (overflow == OiFloatingOverflow.shift) {
            y = y.clamp(safeTop, safeBottom - h);
          }
          // Cross axis: X — shift/flip horizontal edge alignment
          x = _adjustCrossX(x, w, safeLeft, safeRight, isStart: alignment == OiFloatingAlignment.bottomStart, isEnd: alignment == OiFloatingAlignment.bottomEnd, anchorRect: anchorRect);

        case OiFloatingAlignment.topStart:
        case OiFloatingAlignment.topCenter:
        case OiFloatingAlignment.topEnd:
          // Primary axis: Y — flip up→down if overflows top
          if (overflow == OiFloatingOverflow.flip && y < safeTop) {
            final flippedY = anchorRect.bottom + gap + offset.dy;
            if (flippedY + h <= safeBottom) y = flippedY;
          } else if (overflow == OiFloatingOverflow.shift) {
            y = y.clamp(safeTop, safeBottom - h);
          }
          // Cross axis: X
          x = _adjustCrossX(x, w, safeLeft, safeRight, isStart: alignment == OiFloatingAlignment.topStart, isEnd: alignment == OiFloatingAlignment.topEnd, anchorRect: anchorRect);

        // ── Horizontal primary (left / right) ────────────────────────────
        case OiFloatingAlignment.rightStart:
        case OiFloatingAlignment.rightCenter:
        case OiFloatingAlignment.rightEnd:
          // Primary axis: X — flip right→left if overflows right
          if (overflow == OiFloatingOverflow.flip &&
              x + w > safeRight) {
            final flippedX = anchorRect.left - gap - w + offset.dx;
            if (flippedX >= safeLeft) x = flippedX;
          } else if (overflow == OiFloatingOverflow.shift) {
            x = x.clamp(safeLeft, safeRight - w);
          }
          // Cross axis: Y
          y = _adjustCrossY(y, h, safeTop, safeBottom, isStart: alignment == OiFloatingAlignment.rightStart, isEnd: alignment == OiFloatingAlignment.rightEnd, anchorRect: anchorRect);

        case OiFloatingAlignment.leftStart:
        case OiFloatingAlignment.leftCenter:
        case OiFloatingAlignment.leftEnd:
          // Primary axis: X — flip left→right if overflows left
          if (overflow == OiFloatingOverflow.flip && x < safeLeft) {
            final flippedX = anchorRect.right + gap + offset.dx;
            if (flippedX + w <= safeRight) x = flippedX;
          } else if (overflow == OiFloatingOverflow.shift) {
            x = x.clamp(safeLeft, safeRight - w);
          }
          // Cross axis: Y
          y = _adjustCrossY(y, h, safeTop, safeBottom, isStart: alignment == OiFloatingAlignment.leftStart, isEnd: alignment == OiFloatingAlignment.leftEnd, anchorRect: anchorRect);
      }
    }

    // ── Step 4: Final safety clamp (always) ───────────────────────────────
    x = x.clamp(safeLeft, (safeRight - w).clamp(safeLeft, safeRight));
    y = y.clamp(safeTop, (safeBottom - h).clamp(safeTop, safeBottom));

    return Offset(x, y);
  }

  /// Adjusts the cross-axis X position for top/bottom aligned overlays.
  ///
  /// Prefers snapping to an anchor edge for a clean visual connection:
  /// 1. If the ideal position already fits → keep it.
  /// 2. If it overflows right → try aligning the overlay's right edge with the
  ///    anchor's right edge.
  /// 3. If it overflows left → try aligning the overlay's left edge with the
  ///    anchor's left edge.
  /// 4. If neither anchor-edge alignment fits → clamp to screen bounds.
  double _adjustCrossX(
    double x,
    double w,
    double safeLeft,
    double safeRight, {
    required bool isStart,
    required bool isEnd,
    required Rect anchorRect,
  }) {
    // Already fits — no adjustment needed.
    if (x >= safeLeft && x + w <= safeRight) return x;

    // Overflows right → snap right edge of child to right edge of anchor.
    if (x + w > safeRight) {
      final snapped = anchorRect.right - w + offset.dx;
      if (snapped >= safeLeft && snapped + w <= safeRight) return snapped;
    }

    // Overflows left → snap left edge of child to left edge of anchor.
    if (x < safeLeft) {
      final snapped = anchorRect.left + offset.dx;
      if (snapped >= safeLeft && snapped + w <= safeRight) return snapped;
    }

    // Neither anchor-edge alignment fits → clamp to safe screen bounds.
    return x.clamp(safeLeft, (safeRight - w).clamp(safeLeft, safeRight));
  }

  /// Adjusts the cross-axis Y position for left/right aligned overlays.
  ///
  /// Same strategy as [_adjustCrossX] but for the vertical axis.
  double _adjustCrossY(
    double y,
    double h,
    double safeTop,
    double safeBottom, {
    required bool isStart,
    required bool isEnd,
    required Rect anchorRect,
  }) {
    if (y >= safeTop && y + h <= safeBottom) return y;

    if (y + h > safeBottom) {
      final snapped = anchorRect.bottom - h + offset.dy;
      if (snapped >= safeTop && snapped + h <= safeBottom) return snapped;
    }

    if (y < safeTop) {
      final snapped = anchorRect.top + offset.dy;
      if (snapped >= safeTop && snapped + h <= safeBottom) return snapped;
    }

    return y.clamp(safeTop, (safeBottom - h).clamp(safeTop, safeBottom));
  }

  @override
  bool shouldRelayout(_FloatingLayoutDelegate old) {
    return anchorRect != old.anchorRect ||
        alignment != old.alignment ||
        gap != old.gap ||
        overflow != old.overflow ||
        screenPadding != old.screenPadding ||
        offset != old.offset;
  }
}
