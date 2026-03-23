import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

// Material Icons codepoints.
const IconData _kHeartOutline = OiIcons.heart; // favorite_border

/// A heart toggle button for adding or removing a product from a wishlist.
///
/// Coverage: REQ-0071
///
/// When [active] is `true` the heart is filled with the error color (red).
/// When `false` the heart is outlined. The [loading] state disables the
/// button and shows reduced opacity to indicate a pending server round-trip.
///
/// {@category Components}
class OiWishlistButton extends StatefulWidget {
  /// Creates an [OiWishlistButton].
  const OiWishlistButton({
    required this.label,
    this.active = false,
    this.onToggle,
    this.loading = false,
    super.key,
  });

  /// Accessibility label announced by screen readers.
  final String label;

  /// Whether the product is currently wishlisted.
  final bool active;

  /// Called when the user taps the heart.
  final VoidCallback? onToggle;

  /// When `true` the button is disabled and shows reduced opacity.
  final bool loading;

  @override
  State<OiWishlistButton> createState() => _OiWishlistButtonState();
}

class _OiWishlistButtonState extends State<OiWishlistButton> {
  bool _hovered = false;

  bool get _interactive => !widget.loading && widget.onToggle != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeColor = colors.error.base;
    final inactiveColor = colors.textMuted;

    Widget content;
    if (widget.active) {
      // Filled heart when active.
      content = SizedBox(
        width: 24,
        height: 24,
        child: _FilledHeart(color: activeColor, size: 24),
      );
    } else if (_hovered) {
      // Outlined heart with active-colored stroke on hover.
      content = Icon(_kHeartOutline, size: 24, color: activeColor);
    } else {
      content = Icon(_kHeartOutline, size: 24, color: inactiveColor);
    }

    if (widget.loading) {
      content = Opacity(opacity: 0.4, child: content);
    }

    if (_interactive) {
      content = MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onToggle,
          child: content,
        ),
      );
    }

    return Semantics(
      label: widget.label,
      toggled: widget.active,
      button: true,
      child: ExcludeSemantics(child: content),
    );
  }
}

/// Draws a filled heart shape using [CustomPaint].
class _FilledHeart extends StatelessWidget {
  const _FilledHeart({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FilledHeartPainter(color: color),
    );
  }
}

class _FilledHeartPainter extends CustomPainter {
  _FilledHeartPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Heart path scaled to the given size. The shape uses two cubic bezier
    // curves forming the classic heart outline.
    final path = Path()
      ..moveTo(w * 0.5, h * 0.85)
      ..cubicTo(w * 0.15, h * 0.65, w * 0.0, h * 0.4, w * 0.15, h * 0.2)
      ..cubicTo(w * 0.25, h * 0.05, w * 0.45, h * 0.1, w * 0.5, h * 0.3)
      ..cubicTo(w * 0.55, h * 0.1, w * 0.75, h * 0.05, w * 0.85, h * 0.2)
      ..cubicTo(w * 1.0, h * 0.4, w * 0.85, h * 0.65, w * 0.5, h * 0.85)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FilledHeartPainter oldDelegate) =>
      color != oldDelegate.color;
}
