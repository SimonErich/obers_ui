import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiPerformanceConfig;
import 'package:obers_ui/src/foundation/theme/oi_animation_config.dart'
    show OiPerformanceConfig;
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_inset_shadow.dart';
import 'package:obers_ui/src/foundation/theme/oi_surface_decoration.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

part 'oi_surface_border_painter.part.dart';

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
    this.insetShadows,
    this.padding,
    this.halo,
    this.frosted = false,
    this.gradient,
    this.child,
    super.key,
  });

  /// Creates a transparent surface that provides clipping and hit-test
  /// boundary without any visual styling. Useful for wrapping overlay content
  /// or replacing `Material(color: transparent)`.
  const OiSurface.transparent({
    this.child,
    this.borderRadius,
    super.key,
  }) : color = const Color(0x00000000),
       border = null,
       shadow = null,
       insetShadows = null,
       padding = null,
       halo = null,
       frosted = false,
       gradient = null;

  /// Creates a surface with elevation shadow but no background fill.
  /// Useful for adding shadow to a transparent container.
  const OiSurface.elevated({
    required List<BoxShadow> elevation,
    this.child,
    this.borderRadius,
    super.key,
  }) : color = const Color(0x00000000),
       border = null,
       shadow = elevation,
       insetShadows = null,
       padding = null,
       halo = null,
       frosted = false,
       gradient = null;

  /// Background fill color.  Defaults to the theme's surface color when null.
  final Color? color;

  /// Border style.  When null no border is drawn.
  final OiBorderStyle? border;

  /// Corner radius applied to the container and border.
  ///
  /// Null uses [border]'s radius, then [BorderRadius.zero].
  final BorderRadius? borderRadius;

  /// Drop shadows applied beneath the surface.
  final List<BoxShadow>? shadow;

  /// Optional inner shadows, painted beneath the border and child.
  ///
  /// Null or empty preserves the existing decoration and layout exactly.
  final List<OiInsetShadow>? insetShadows;

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

  /// Background gradient, overriding [color] when supplied.
  final OiGradientStyle? gradient;

  /// The widget to render inside the surface.
  final Widget? child;

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

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = _resolvedRadius();
    final resolvedShadows = _resolvedShadows();
    final resolvedColor = color ?? context.colors.surface;
    final effectiveBorder = border;
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
      decoration: insetShadows?.isNotEmpty ?? false
          ? OiSurfaceDecoration(base: decoration, insetShadows: insetShadows!)
          : decoration,
      padding: padding,
      child: child,
    );

    if (useGradientBorder) {
      surface = CustomPaint(
        foregroundPainter: _OiBorderPainter(
          style: effectiveBorder,
          radius: resolvedRadius,
        ),
        child: surface,
      );
    }

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
