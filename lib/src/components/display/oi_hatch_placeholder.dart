import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// A quiet hatched region explaining content that needs a prior selection.
/// Unlike a skeleton, this surface does not imply a request is in progress.
class OiHatchPlaceholder extends StatelessWidget {
  /// Creates a labeled, noninteractive placeholder using the surrounding theme.
  const OiHatchPlaceholder({
    required this.label,
    this.height = 96,
    this.child,
    this.backgroundColor,
    this.stripeColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    super.key,
  }) : assert(height > 0, 'height must be positive.');

  /// Visible explanation of the empty region.
  final String label;

  /// Minimum height, growing naturally for large text or a long explanation.
  final double height;

  /// Optional populated preview; the label remains the accessible explanation.
  final Widget? child;

  /// Optional override of the subtle surface color.
  final Color? backgroundColor;

  /// Optional override of the decorative diagonal line color.
  final Color? stripeColor;

  /// Shape shared by the clipped pattern and its boundary.
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: borderRadius,
    child: CustomPaint(
      painter: _HatchPainter(
        backgroundColor ?? context.colors.surfaceSubtle,
        stripeColor ?? context.colors.borderSubtle,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: child == null
                ? math.min(
                    20,
                    math.max(
                      0,
                      (height -
                              ((context.textTheme.caption.fontSize ?? 12) *
                                      (context.textTheme.caption.height ?? 1.4))
                                  .ceilToDouble() -
                              8) /
                          2,
                    ),
                  )
                : 12,
          ),
          child: Center(
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: context.radius.xs,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: child == null
                    ? OiLabel.caption(
                        label,
                        textAlign: TextAlign.center,
                        color: context.colors.textMuted,
                      )
                    : Semantics(label: label, child: child),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _HatchPainter extends CustomPainter {
  const _HatchPainter(this.background, this.stripes);
  final Color background;
  final Color stripes;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final paint = Paint()
      ..color = stripes
      ..strokeWidth = 1;
    for (var x = -size.height; x < size.width; x += 8) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HatchPainter previous) =>
      background != previous.background || stripes != previous.stripes;
}
