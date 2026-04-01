part of '../oi_context_menu.dart';

// ── Cursor-relative positioning delegate ───────────────────────────────────

class _CursorPositionDelegate extends SingleChildLayoutDelegate {
  const _CursorPositionDelegate({
    required this.cursorPosition,
    required this.screenPadding,
  });

  final Offset cursorPosition;
  final EdgeInsets screenPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxW =
        (constraints.maxWidth - screenPadding.left - screenPadding.right).clamp(
          0.0,
          double.infinity,
        );
    final maxH =
        (constraints.maxHeight - screenPadding.top - screenPadding.bottom)
            .clamp(0.0, double.infinity);
    return BoxConstraints(maxWidth: maxW, maxHeight: maxH);
  }

  @override
  Offset getPositionForChild(Size screenSize, Size childSize) {
    final safeRight = screenSize.width - screenPadding.right;
    final safeBottom = screenSize.height - screenPadding.bottom;

    var x = cursorPosition.dx;
    var y = cursorPosition.dy;

    if (x + childSize.width > safeRight) {
      x = safeRight - childSize.width;
    }
    if (y + childSize.height > safeBottom) {
      y = safeBottom - childSize.height;
    }

    x = x.clamp(screenPadding.left, safeRight);
    y = y.clamp(screenPadding.top, safeBottom);

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_CursorPositionDelegate old) =>
      cursorPosition != old.cursorPosition ||
      screenPadding != old.screenPadding;
}

// ── Sub-menu positioning delegate ──────────────────────────────────────────

class _SubMenuPositionDelegate extends SingleChildLayoutDelegate {
  const _SubMenuPositionDelegate({
    required this.parentRect,
    required this.screenPadding,
  });

  final Rect parentRect;
  final EdgeInsets screenPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxW =
        (constraints.maxWidth - screenPadding.left - screenPadding.right).clamp(
          0.0,
          double.infinity,
        );
    final maxH =
        (constraints.maxHeight - screenPadding.top - screenPadding.bottom)
            .clamp(0.0, double.infinity);
    return BoxConstraints(maxWidth: maxW, maxHeight: maxH);
  }

  @override
  Offset getPositionForChild(Size screenSize, Size childSize) {
    final safeLeft = screenPadding.left;
    final safeTop = screenPadding.top;
    final safeRight = screenSize.width - screenPadding.right;
    final safeBottom = screenSize.height - screenPadding.bottom;

    var x = parentRect.right;
    var y = parentRect.top;

    if (x + childSize.width > safeRight) {
      final flippedX = parentRect.left - childSize.width;
      if (flippedX >= safeLeft) {
        x = flippedX;
      } else {
        x = safeRight - childSize.width;
      }
    }

    if (y + childSize.height > safeBottom) {
      y = safeBottom - childSize.height;
    }

    x = x.clamp(safeLeft, math.max(safeLeft, safeRight - childSize.width));
    y = y.clamp(safeTop, math.max(safeTop, safeBottom - childSize.height));

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_SubMenuPositionDelegate old) =>
      parentRect != old.parentRect || screenPadding != old.screenPadding;
}
