import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Decorative, continuous 135-degree hatch bands behind an optional [child].
///
/// [pitch], [stripeWidth] and [phase] are perpendicular logical-pixel distances,
/// not horizontal spacing. Positive phase translates the bands forward; adding
/// one pitch leaves the paint unchanged. Paint clips to this box, without adding
/// intrinsic size, semantics, hit targets, theme defaults or an animation loop.
/// The caller supplies constraints and controls phase only when motion is wanted.
///
/// {@category Primitives}
class OiHatch extends StatelessWidget {
  /// Creates a hatch, rejecting invalid geometry in release builds too.
  factory OiHatch({
    required Color stripeColor,
    Color backgroundColor = const Color(0x00000000),
    double pitch = 5,
    double stripeWidth = 1,
    double phase = 0,
    Widget? child,
    Key? key,
  }) {
    if (!pitch.isFinite || pitch <= 0) {
      throw ArgumentError.value(pitch, 'pitch', 'Must be finite and positive');
    }
    if (!stripeWidth.isFinite || stripeWidth < 0 || stripeWidth > pitch) {
      throw ArgumentError.value(
        stripeWidth,
        'stripeWidth',
        'Must be finite, nonnegative and at most pitch',
      );
    }
    if (!phase.isFinite) {
      throw ArgumentError.value(phase, 'phase', 'Must be finite');
    }
    return OiHatch._(
      stripeColor: stripeColor,
      backgroundColor: backgroundColor,
      pitch: pitch,
      stripeWidth: stripeWidth,
      phase: phase,
      key: key,
      child: child,
    );
  }

  const OiHatch._({
    required this.stripeColor,
    required this.backgroundColor,
    required this.pitch,
    required this.stripeWidth,
    required this.phase,
    this.child,
    super.key,
  });

  /// Color of each band, including its authored alpha.
  final Color stripeColor;

  /// Color underneath the bands; transparent by default.
  final Color backgroundColor;

  /// Positive perpendicular distance between repeated bands.
  final double pitch;

  /// Band thickness from zero to [pitch], inclusive.
  final double stripeWidth;

  /// Finite perpendicular translation, wrapping at [pitch].
  final double phase;

  /// Optional content painted above the hatch, with its own interaction policy.
  final Widget? child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _OiHatchPainter(
      stripeColor,
      backgroundColor,
      pitch,
      stripeWidth,
      phase.remainder(pitch),
    ),
    child: child,
  );
}

class _OiHatchPainter extends CustomPainter {
  const _OiHatchPainter(
    this.stripes,
    this.background,
    this.pitch,
    this.width,
    this.phase,
  );

  final Color stripes;
  final Color background;
  final double pitch;
  final double width;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    canvas
      ..save()
      ..clipRect(rect)
      ..drawRect(rect, Paint()..color = background);
    if (width > 0) {
      final paint = Paint()..color = stripes;
      if (width < pitch) {
        const direction = Offset(1 / math.sqrt2, 1 / math.sqrt2);
        const transparent = Color(0x00000000);
        final span = (size.width + size.height) / math.sqrt2;
        if (pitch >= span) {
          // Localize at most two visible bands: huge native shader coordinates
          // lose precision or overflow, even when every authored value is finite.
          // Preserve a small negative phase before adding a huge pitch.
          final start = phase < 0 ? phase + pitch : phase;
          final previousEnd = phase < 0
              ? phase + width
              : (phase - pitch) + width;
          final colors = <Color>[
            if (phase == 0 || previousEnd > 0) stripes else transparent,
          ];
          final stops = <double>[0];
          for (final (distance, after) in [
            (previousEnd, transparent),
            (start, stripes),
            if (start < span && width < span - start)
              (start + width, transparent),
          ]) {
            if (distance <= 0 || distance >= span) continue;
            colors.addAll([colors.last, after]);
            stops.addAll([distance / span, distance / span]);
          }
          paint.color = colors.last;
          if (colors.length > 1) {
            colors.add(colors.last);
            stops.add(1);
            paint
              ..color = const Color(0xff000000)
              ..shader = ui.Gradient.linear(
                Offset.zero,
                direction * span,
                colors,
                stops,
              );
          }
        } else {
          paint
            ..color = const Color(0xff000000)
            ..shader = ui.Gradient.linear(
              direction * (phase < 0 ? phase : phase - pitch),
              direction * (phase < 0 ? phase + pitch : phase),
              [stripes, stripes, transparent, transparent],
              [0, width / pitch, width / pitch, 1],
              ui.TileMode.repeated,
            );
        }
      }
      canvas.drawRect(rect, paint);
    }
    canvas.restore();
  }

  @override
  bool? hitTest(Offset position) => false;

  @override
  bool shouldRepaint(_OiHatchPainter old) =>
      stripes != old.stripes ||
      background != old.background ||
      pitch != old.pitch ||
      width != old.width ||
      phase != old.phase;
}
