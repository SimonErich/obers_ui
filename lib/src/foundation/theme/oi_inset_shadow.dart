import 'dart:ui' show ColorSpace;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// An inner shadow with an explicit Gaussian standard deviation.
///
/// Unlike a CSS blur radius, [blurSigma] is the value supplied to a Gaussian
/// mask filter. Construction validates geometry at runtime, including release.
///
/// {@category Foundation}
@immutable
class OiInsetShadow {
  /// Creates a validated inner shadow.
  factory OiInsetShadow({
    required Color color,
    Offset offset = Offset.zero,
    double blurSigma = 0,
    double spread = 0,
  }) {
    if (!color.a.isFinite ||
        color.a < 0 ||
        color.a > 1 ||
        !color.r.isFinite ||
        !color.g.isFinite ||
        !color.b.isFinite) {
      throw ArgumentError.value(
        color,
        'color',
        'Must be finite with alpha in [0,1].',
      );
    }
    if (!blurSigma.isFinite || blurSigma < 0) {
      throw ArgumentError.value(
        blurSigma,
        'blurSigma',
        'Must be finite and ≥0.',
      );
    }
    if (!offset.dx.isFinite || !offset.dy.isFinite) {
      throw ArgumentError.value(
        offset,
        'offset',
        'Must have finite coordinates.',
      );
    }
    if (!spread.isFinite) {
      throw ArgumentError.value(spread, 'spread', 'Must be finite.');
    }
    return OiInsetShadow._(
      color: color,
      offset: offset,
      blurSigma: blurSigma,
      spread: spread,
    );
  }

  const OiInsetShadow._({
    required this.color,
    required this.offset,
    required this.blurSigma,
    required this.spread,
  });

  /// Finite shadow color with alpha in [0,1]; extended RGB is not clipped.
  final Color color;

  /// Gaussian standard deviation in logical pixels; zero means sharp edges.
  final double blurSigma;

  /// Translation of the interior hole; positive y reveals the top edge.
  final Offset offset;

  /// Distance contracting the interior hole; negative values expand it.
  final double spread;

  /// Returns a validated copy with the supplied fields replaced.
  OiInsetShadow copyWith({
    Color? color,
    Offset? offset,
    double? blurSigma,
    double? spread,
  }) => OiInsetShadow(
    color: color ?? this.color,
    offset: offset ?? this.offset,
    blurSigma: blurSigma ?? this.blurSigma,
    spread: spread ?? this.spread,
  );

  /// Interpolates fields; null fades from transparent zero geometry.
  ///
  /// Finite extrapolation is supported, with negative sigma clamped to zero.
  /// Exact endpoints retain their original values; two nulls return null.
  /// Ordinary colors retain [Color.lerp]'s semantics. If either input is extended
  /// sRGB, SDK color-space conversion precedes straight raw-channel interpolation
  /// without RGB clipping; alpha is clamped to [0,1]. Null fades retain RGB.
  /// This is not CSS-premultiplied color mixing.
  static OiInsetShadow? lerp(OiInsetShadow? a, OiInsetShadow? b, double t) {
    if (!t.isFinite) throw ArgumentError.value(t, 't', 'Must be finite.');
    if (t == 0) return a;
    if (t == 1) return b;
    if (a == null && b == null) return null;
    final x = a?.color;
    final y = b?.color;
    final Color color;
    if (x?.colorSpace == ColorSpace.extendedSRGB ||
        y?.colorSpace == ColorSpace.extendedSRGB) {
      final start = (x ?? y!).withValues(colorSpace: ColorSpace.extendedSRGB);
      final end = (y ?? x!).withValues(colorSpace: ColorSpace.extendedSRGB);
      color = Color.from(
        alpha: ((x?.a ?? 0) * (1 - t) + (y?.a ?? 0) * t).clamp(0, 1),
        red: start.r + (end.r - start.r) * t,
        green: start.g + (end.g - start.g) * t,
        blue: start.b + (end.b - start.b) * t,
        colorSpace: ColorSpace.extendedSRGB,
      );
    } else {
      color = Color.lerp(x, y, t)!;
    }
    return OiInsetShadow(
      color: color,
      offset: Offset.lerp(
        a?.offset ?? Offset.zero,
        b?.offset ?? Offset.zero,
        t,
      )!,
      blurSigma: ((a?.blurSigma ?? 0) * (1 - t) + (b?.blurSigma ?? 0) * t)
          .clamp(0, double.infinity),
      spread: (a?.spread ?? 0) * (1 - t) + (b?.spread ?? 0) * t,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiInsetShadow &&
          other.color == color &&
          other.offset == offset &&
          other.blurSigma == blurSigma &&
          other.spread == spread;

  @override
  int get hashCode => Object.hash(color, offset, blurSigma, spread);
}
