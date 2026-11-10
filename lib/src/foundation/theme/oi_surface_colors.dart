import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_semantic_color_interpolation.dart';

/// Explicit surface, outline and wash colors.
///
/// Values may be raw extended sRGB; no gamut mapping is performed.
///
/// {@category Foundation}
@immutable
class OiSurfaceColors {
  /// Creates explicitly authored semantic colors.
  const OiSurfaceColors({
    required this.canvas,
    required this.sheet,
    required this.well,
    required this.overlaySurface,
    required this.line,
    required this.lineStrong,
    required this.border,
    required this.hoverWash,
    required this.pressedWash,
    required this.scrim,
    required this.inverse,
  });

  /// Interpolates raw sRGB with premultiplied alpha, without gamut clipping.
  ///
  /// Exact endpoints are retained. Optional values carry a sole endpoint.
  /// Throws [ArgumentError] for fractions outside finite 0–1.
  factory OiSurfaceColors.lerp(
    OiSurfaceColors first,
    OiSurfaceColors second,
    double fraction,
  ) {
    if (fraction == 0) return first;
    if (fraction == 1) return second;
    Color mix(Color firstColor, Color secondColor) =>
        OiSemanticColorInterpolation.color(firstColor, secondColor, fraction);
    return OiSurfaceColors(
      canvas: mix(first.canvas, second.canvas),
      sheet: mix(first.sheet, second.sheet),
      well: mix(first.well, second.well),
      overlaySurface: mix(first.overlaySurface, second.overlaySurface),
      line: mix(first.line, second.line),
      lineStrong: mix(first.lineStrong, second.lineStrong),
      border: mix(first.border, second.border),
      hoverWash: mix(first.hoverWash, second.hoverWash),
      pressedWash: mix(first.pressedWash, second.pressedWash),
      scrim: mix(first.scrim, second.scrim),
      inverse: mix(first.inverse, second.inverse),
    );
  }

  /// Application canvas.
  final Color canvas;

  /// Main elevated content surface.
  final Color sheet;

  /// Recessed content surface.
  final Color well;

  /// Opaque overlay surface; distinct from the translucent scrim.
  final Color overlaySurface;

  /// Subtle divider.
  final Color line;

  /// Emphasized divider.
  final Color lineStrong;

  /// Control outline.
  final Color border;

  /// Translucent hover wash.
  final Color hoverWash;

  /// Translucent pressed wash.
  final Color pressedWash;

  /// Modal backdrop; never an opaque overlay surface.
  final Color scrim;

  /// Inverse content surface.
  final Color inverse;

  /// Returns an independent value with supplied colors overridden.
  OiSurfaceColors copyWith({
    Color? canvas,
    Color? sheet,
    Color? well,
    Color? overlaySurface,
    Color? line,
    Color? lineStrong,
    Color? border,
    Color? hoverWash,
    Color? pressedWash,
    Color? scrim,
    Color? inverse,
  }) => OiSurfaceColors(
    canvas: canvas ?? this.canvas,
    sheet: sheet ?? this.sheet,
    well: well ?? this.well,
    overlaySurface: overlaySurface ?? this.overlaySurface,
    line: line ?? this.line,
    lineStrong: lineStrong ?? this.lineStrong,
    border: border ?? this.border,
    hoverWash: hoverWash ?? this.hoverWash,
    pressedWash: pressedWash ?? this.pressedWash,
    scrim: scrim ?? this.scrim,
    inverse: inverse ?? this.inverse,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiSurfaceColors &&
          other.canvas == canvas &&
          other.sheet == sheet &&
          other.well == well &&
          other.overlaySurface == overlaySurface &&
          other.line == line &&
          other.lineStrong == lineStrong &&
          other.border == border &&
          other.hoverWash == hoverWash &&
          other.pressedWash == pressedWash &&
          other.scrim == scrim &&
          other.inverse == inverse;

  @override
  int get hashCode => Object.hash(
    canvas,
    sheet,
    well,
    overlaySurface,
    line,
    lineStrong,
    border,
    hoverWash,
    pressedWash,
    scrim,
    inverse,
  );
}
