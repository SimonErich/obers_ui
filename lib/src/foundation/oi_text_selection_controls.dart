import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// Custom [TextSelectionControls] that render selection handles using
/// obers_ui theme tokens instead of Material or Cupertino styles.
///
/// Handles are drawn as filled circles with a short stem, painted with
/// the theme's `primary.base` colour. The deprecated toolbar API is
/// suppressed — use [buildOiSelectionToolbar] as the
/// `contextMenuBuilder` on [EditableText] instead.
///
/// {@category Foundation}
class OiTextSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  /// Creates [OiTextSelectionControls].
  OiTextSelectionControls();

  static const double _kStemLength = 4;

  static double _radius(double textLineHeight) =>
      math.max(textLineHeight * 0.25, 6);

  @override
  Size getHandleSize(double textLineHeight) {
    final d = _radius(textLineHeight) * 2;
    return Size(d, d + _kStemLength);
  }

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    final colors = OiTheme.maybeOf(context)?.colors;
    final color = colors?.primary.base ?? const Color(0xFF2563EB);
    final r = _radius(textLineHeight);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: SizedBox(
        width: r * 2,
        height: r * 2 + _kStemLength,
        child: CustomPaint(
          painter: _HandlePainter(color: color, type: type, radius: r),
        ),
      ),
    );
  }

  @override
  Offset getHandleAnchor(
    TextSelectionHandleType type,
    double textLineHeight,
  ) {
    final r = _radius(textLineHeight);
    switch (type) {
      case TextSelectionHandleType.left:
        return Offset(r * 2, 0);
      case TextSelectionHandleType.right:
        return Offset.zero;
      case TextSelectionHandleType.collapsed:
        return Offset(r, 0);
    }
  }
}

// ── Handle painter ──────────────────────────────────────────────────────────

class _HandlePainter extends CustomPainter {
  const _HandlePainter({
    required this.color,
    required this.type,
    required this.radius,
  });

  final Color color;
  final TextSelectionHandleType type;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const stem = OiTextSelectionControls._kStemLength;

    switch (type) {
      case TextSelectionHandleType.left:
        canvas.drawRect(Rect.fromLTWH(radius * 2 - 1, 0, 2, stem), paint);
        canvas.drawCircle(Offset(radius, radius + stem), radius, paint);
      case TextSelectionHandleType.right:
        canvas.drawRect(const Rect.fromLTWH(0, 0, 2, stem), paint);
        canvas.drawCircle(Offset(radius, radius + stem), radius, paint);
      case TextSelectionHandleType.collapsed:
        canvas.drawCircle(Offset(radius, radius), radius * 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(_HandlePainter old) =>
      color != old.color || type != old.type || radius != old.radius;
}

// ── Context menu builder ────────────────────────────────────────────────────

/// Builds an obers_ui–styled text-selection toolbar.
///
/// Pass this as the `contextMenuBuilder` argument of [EditableText]
/// (or [OiRawInput]) to replace the platform-default context menu.
Widget buildOiSelectionToolbar(
  BuildContext context,
  EditableTextState editableTextState,
) {
  final items = editableTextState.contextMenuButtonItems;
  if (items.isEmpty) return const SizedBox.shrink();

  return _OiSelectionToolbar(
    anchor: editableTextState.contextMenuAnchors.primaryAnchor,
    buttonItems: items,
  );
}

// ── Toolbar widget ──────────────────────────────────────────────────────────

class _OiSelectionToolbar extends StatelessWidget {
  const _OiSelectionToolbar({
    required this.anchor,
    required this.buttonItems,
  });

  final Offset anchor;
  final List<ContextMenuButtonItem> buttonItems;

  @override
  Widget build(BuildContext context) {
    final theme = OiTheme.maybeOf(context);
    final colors = theme?.colors;
    final sp = theme?.spacing;

    return CustomSingleChildLayout(
      delegate: _ToolbarPositionDelegate(anchor: anchor),
      child: OiSurface(
        color: colors?.surface,
        shadow: theme?.shadows.sm,
        borderRadius: theme?.radius.md,
        padding: EdgeInsets.symmetric(
          horizontal: sp?.xs ?? 4,
          vertical: sp?.xs ?? 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in buttonItems)
              OiTappable(
                onTap: item.onPressed,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sp?.sm ?? 8,
                    vertical: sp?.xs ?? 4,
                  ),
                  child: OiLabel.caption(
                    _labelFor(item),
                    color: item.onPressed == null
                        ? colors?.textMuted
                        : colors?.text,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _labelFor(ContextMenuButtonItem item) {
    if (item.label != null && item.label!.isNotEmpty) return item.label!;
    return switch (item.type) {
      ContextMenuButtonType.cut => 'Cut',
      ContextMenuButtonType.copy => 'Copy',
      ContextMenuButtonType.paste => 'Paste',
      ContextMenuButtonType.selectAll => 'Select All',
      ContextMenuButtonType.delete => 'Delete',
      ContextMenuButtonType.lookUp => 'Look Up',
      ContextMenuButtonType.searchWeb => 'Search',
      ContextMenuButtonType.share => 'Share',
      ContextMenuButtonType.liveTextInput => 'Scan Text',
      ContextMenuButtonType.custom => '',
    };
  }
}

class _ToolbarPositionDelegate extends SingleChildLayoutDelegate {
  const _ToolbarPositionDelegate({required this.anchor});

  final Offset anchor;

  static const double _kGap = 8;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final x = (anchor.dx - childSize.width / 2).clamp(
      _kGap,
      size.width - childSize.width - _kGap,
    );
    final y = (anchor.dy - childSize.height - _kGap).clamp(
      _kGap,
      size.height - childSize.height - _kGap,
    );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_ToolbarPositionDelegate old) => anchor != old.anchor;
}
