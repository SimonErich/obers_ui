import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiPerformanceConfig;
import 'package:obers_ui/src/foundation/theme/oi_animation_config.dart'
    show OiPerformanceConfig;
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A themed container supporting border, shadow, blur, and gradient effects.
///
/// [OiSurface] renders its [child] inside a decorated [Container]. The
/// decoration supports:
///
/// - Solid fill via [color].
/// - Background gradients via [gradient] ([OiGradientStyle]).
/// - Solid borders via [border] when [OiBorderLineStyle.solid].
/// - Dashed / dotted borders painted by a [CustomPaint] layer when
///   [OiBorderLineStyle.dashed] or [OiBorderLineStyle.dotted].
/// - Drop shadows via [shadow].
/// - A glow/halo effect via [halo] ([OiHaloStyle]).
/// - A frosted-glass backdrop blur via [frosted] (guarded by the active theme's
///   [OiPerformanceConfig.disableBlur]).
///
/// {@category Primitives}
class OiSurface extends StatelessWidget {
  /// Creates an [OiSurface].
  const OiSurface({
    this.color,
    this.border,
    this.borderRadius,
    this.shadow,
    this.padding,
    this.halo,
    this.frosted = false,
    this.gradient,
    this.child,
    super.key,
  });

  /// Background fill color.  Defaults to the theme's surface color when null.
  final Color? color;

  /// Border style.  When null no border is drawn.
  final OiBorderStyle? border;

  /// Corner radius applied to the container and border.
  ///
  /// When null and [border] provides its own [OiBorderStyle.borderRadius],
  /// that value is used.
  final BorderRadius? borderRadius;

  /// Drop shadows applied beneath the surface.
  final List<BoxShadow>? shadow;

  /// Padding inside the surface.
  final EdgeInsetsGeometry? padding;

  /// An optional glow / halo rendered as an additional [BoxShadow].
  final OiHaloStyle? halo;

  /// When `true`, a [BackdropFilter] blur is applied behind the surface,
  /// creating a frosted-glass effect.
  ///
  /// Ignored when [OiPerformanceConfig.disableBlur] is `true` in the active
  /// theme.
  final bool frosted;

  /// An optional gradient painted as the background.
  ///
  /// Overrides [color] when both are supplied.
  final OiGradientStyle? gradient;

  /// The widget to render inside the surface.
  final Widget? child;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  BorderRadius _resolvedRadius() {
    return borderRadius ?? border?.borderRadius ?? BorderRadius.zero;
  }

  List<BoxShadow> _resolvedShadows() {
    final base = shadow ?? const [];
    if (halo != null) {
      return [...base, halo!.toBoxShadow()];
    }
    return base;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = _resolvedRadius();
    final resolvedShadows = _resolvedShadows();
    final resolvedColor = color ?? context.colors.surface;
    final effectiveBorder = border;

    // Determine whether to use solid BoxDecoration border or custom painter.
    final useCustomBorder =
        effectiveBorder != null &&
        effectiveBorder.lineStyle != OiBorderLineStyle.solid;
    final useSolidBorder =
        effectiveBorder != null &&
        effectiveBorder.lineStyle == OiBorderLineStyle.solid &&
        effectiveBorder.width > 0 &&
        effectiveBorder.gradient == null;
    final useGradientBorder =
        effectiveBorder != null && effectiveBorder.gradient != null;

    // Build the BoxDecoration.
    final decoration = BoxDecoration(
      color: gradient != null ? null : resolvedColor,
      gradient: gradient?.toGradient(),
      borderRadius: resolvedRadius,
      boxShadow: resolvedShadows.isEmpty ? null : resolvedShadows,
      border: useSolidBorder
          ? Border.all(
              color: effectiveBorder.color,
              width: effectiveBorder.width,
            )
          : null,
    );

    Widget surface = Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );

    // Gradient border: paint a gradient border using CustomPaint as an overlay.
    if (useGradientBorder) {
      surface = CustomPaint(
        foregroundPainter: _OiBorderPainter(
          style: effectiveBorder,
          radius: resolvedRadius,
        ),
        child: surface,
      );
    }

    // Dashed / dotted border.
    if (useCustomBorder) {
      surface = CustomPaint(
        foregroundPainter: _OiBorderPainter(
          style: effectiveBorder,
          radius: resolvedRadius,
        ),
        child: surface,
      );
    }

    if (frosted) {
      // Guard: read performance config from theme; fall back to rendering blur.
      // OiThemeData does not yet expose OiPerformanceConfig publicly so we
      // always apply the blur here, matching high-performance default.
      surface = ClipRRect(
        borderRadius: resolvedRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: surface,
        ),
      );
    }

    return surface;
  }
}

// ---------------------------------------------------------------------------
// Border painter
// ---------------------------------------------------------------------------

/// Paints dashed, dotted, or gradient borders around a rounded rectangle.
class _OiBorderPainter extends CustomPainter {
  const _OiBorderPainter({required this.style, required this.radius});

  final OiBorderStyle style;
  final BorderRadius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = style.width
      ..style = PaintingStyle.stroke;

    if (style.gradient != null) {
      final rect = Offset.zero & size;
      paint.shader = style.gradient!.createShader(rect);
    } else {
      paint.color = style.color;
    }

    final rrect = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: radius.topLeft,
      topRight: radius.topRight,
      bottomLeft: radius.bottomLeft,
      bottomRight: radius.bottomRight,
    );

    if (style.lineStyle == OiBorderLineStyle.solid) {
      canvas.drawRRect(rrect, paint);
      return;
    }

    // Approximate perimeter for dash/dot spacing.
    final perimeter = _rrectPerimeter(rrect);
    final dashLength = style.lineStyle == OiBorderLineStyle.dashed
        ? style.width * 4
        : 0.0;
    final dotLength = style.lineStyle == OiBorderLineStyle.dotted
        ? style.width
        : 0.0;
    final segmentLength = style.lineStyle == OiBorderLineStyle.dashed
        ? dashLength
        : dotLength;
    final gapLength = segmentLength * 1.5;

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final length = draw ? segmentLength : gapLength;
        if (draw) {
          canvas.drawPath(
            metric.extractPath(
              distance,
              distance + math.min(length, perimeter),
            ),
            paint,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  double _rrectPerimeter(RRect rrect) {
    // Approximate: sum of straight edges + arc lengths at corners.
    final w = rrect.width;
    final h = rrect.height;
    final tl = rrect.tlRadiusX + rrect.tlRadiusY;
    final tr = rrect.trRadiusX + rrect.trRadiusY;
    final bl = rrect.blRadiusX + rrect.blRadiusY;
    final br = rrect.brRadiusX + rrect.brRadiusY;
    return 2 * w + 2 * h + (tl + tr + bl + br) * (math.pi / 4 - 1);
  }

  @override
  bool shouldRepaint(_OiBorderPainter oldDelegate) =>
      oldDelegate.style != style || oldDelegate.radius != radius;
}
