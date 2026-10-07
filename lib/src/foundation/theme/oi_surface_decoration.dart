import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/oi_inset_shadow.dart';

part 'paint/oi_surface_decoration_painter.part.dart';
part 'paint/oi_deferred_border.part.dart';
part 'paint/oi_deferred_directional_border.part.dart';

/// A box decoration with additional inner shadows beneath its border/content.
///
/// Only [insetShadows] and [BoxDecoration.boxShadow] are defensively snapshotted.
/// Other authored Flutter values retain [BoxDecoration]'s input semantics.
/// Padding, shape, hit testing, and clipping delegate to [base]; empty insets
/// use its original painter. Image changes/disposal follow its painter lifecycle.
///
/// {@category Foundation}
class OiSurfaceDecoration extends Decoration {
  /// Creates an inner-shadow decoration over [base].
  OiSurfaceDecoration({
    required BoxDecoration base,
    List<OiInsetShadow> insetShadows = const [],
  }) : base = base.boxShadow == null
           ? base
           : base.copyWith(
               boxShadow: List<BoxShadow>.unmodifiable(base.boxShadow!),
             ),
       insetShadows = List<OiInsetShadow>.unmodifiable(insetShadows);

  /// Background, outer shadows, shape, and border of the surface.
  final BoxDecoration base;

  /// Inner shadows, in front-to-back order.
  final List<OiInsetShadow> insetShadows;

  /// Interpolates base fields and front-to-back inset lists.
  ///
  /// Unequal lists are padded with transparent zero-geometry shadows.
  /// Shape changes follow [BoxDecoration.lerp]'s discrete shape policy.
  static OiSurfaceDecoration? lerp(
    OiSurfaceDecoration? a,
    OiSurfaceDecoration? b,
    double t,
  ) {
    if (!t.isFinite) throw ArgumentError.value(t, 't', 'Must be finite.');
    if (t == 0) return a;
    if (t == 1) return b;
    if (a == null && b == null) return null;
    final left = a?.insetShadows ?? const <OiInsetShadow>[];
    final right = b?.insetShadows ?? const <OiInsetShadow>[];
    final count = left.length > right.length ? left.length : right.length;
    return OiSurfaceDecoration(
      base: BoxDecoration.lerp(a?.base, b?.base, t)!,
      insetShadows: [
        for (var i = 0; i < count; i++)
          OiInsetShadow.lerp(
            i < left.length ? left[i] : null,
            i < right.length ? right[i] : null,
            t,
          )!,
      ],
    );
  }

  @override
  OiSurfaceDecoration? lerpFrom(Decoration? a, double t) => switch (a) {
    null => lerp(null, this, t),
    OiSurfaceDecoration() => lerp(a, this, t),
    BoxDecoration() => lerp(OiSurfaceDecoration(base: a), this, t),
    _ => null,
  };

  @override
  OiSurfaceDecoration? lerpTo(Decoration? b, double t) => switch (b) {
    null => lerp(this, null, t),
    OiSurfaceDecoration() => lerp(this, b, t),
    BoxDecoration() => lerp(this, OiSurfaceDecoration(base: b), t),
    _ => null,
  };

  /// Copies the decoration, snapshotting replacement shadow lists.
  OiSurfaceDecoration copyWith({
    BoxDecoration? base,
    List<OiInsetShadow>? insetShadows,
  }) => OiSurfaceDecoration(
    base: base ?? this.base,
    insetShadows: insetShadows ?? this.insetShadows,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiSurfaceDecoration &&
          other.base == base &&
          listEquals(other.insetShadows, insetShadows);

  @override
  int get hashCode => Object.hash(base, Object.hashAll(insetShadows));

  @override
  EdgeInsetsGeometry get padding => base.padding;

  @override
  bool get isComplex => insetShadows.isNotEmpty || base.isComplex;

  @override
  bool hitTest(Size size, Offset position, {TextDirection? textDirection}) =>
      base.hitTest(size, position, textDirection: textDirection);

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) =>
      base.getClipPath(rect, textDirection);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => insetShadows.isEmpty
      ? base.createBoxPainter(onChanged)
      : _OiSurfacePainter(base, insetShadows, onChanged);
}
