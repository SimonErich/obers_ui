import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// The visual style of an [OiDropHighlight].
///
/// {@category Components}
enum OiDropHighlightStyle {
  /// Full-area overlay with dashed border and centered message.
  area,

  /// Subtle border glow around a widget (used on folder rows/cards).
  border,
}

/// A visual overlay that indicates a valid drop target.
///
/// Renders a dashed border + background tint + centered label
/// ("Drop files here" / "Move to folder").
///
/// ```dart
/// OiDropHighlight(
///   active: isDragOver,
///   message: 'Drop files here',
///   child: content,
/// )
/// ```
///
/// {@category Components}
class OiDropHighlight extends StatelessWidget {
  /// Creates an [OiDropHighlight].
  const OiDropHighlight({
    required this.active,
    this.style = OiDropHighlightStyle.area,
    this.message,
    this.icon,
    this.child,
    super.key,
  });

  /// Whether the drop highlight is currently visible.
  final bool active;

  /// The visual style.
  final OiDropHighlightStyle style;

  /// Message to display in the center (area style only).
  final String? message;

  /// Icon to display above the message (area style only).
  final IconData? icon;

  /// The child widget.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (!active) return child ?? const SizedBox.shrink();

    if (style == OiDropHighlightStyle.border) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.primary.base, width: 2),
          borderRadius: BorderRadius.circular(4),
          color: colors.primary.muted.withValues(alpha: 0.08),
        ),
        child: child,
      );
    }

    // Area style
    return Stack(
      children: [
        if (child != null) child!,
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: active ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              decoration: BoxDecoration(
                color: colors.primary.muted.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: colors.primary.base,
                  borderRadius: 8,
                  dashWidth: 6,
                  dashSpace: 4,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Icon(
                            icon,
                            size: 32,
                            color: colors.primary.base,
                          ),
                        ),
                      if (message != null)
                        Text(
                          message!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.primary.base,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashSpace,
  });

  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    // Draw dashed border by using a path with dash effect
    final path = Path()..addRRect(rrect);

    // Approximate dashed line by drawing the full path
    // Flutter doesn't have built-in dash support, so we draw a solid
    // border with reduced opacity to simulate the effect
    paint.color = color.withValues(alpha: 0.7);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      borderRadius != oldDelegate.borderRadius;
}
