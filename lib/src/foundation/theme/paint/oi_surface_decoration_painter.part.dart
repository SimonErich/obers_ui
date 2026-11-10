part of '../oi_surface_decoration.dart';

class _OiSurfacePainter extends BoxPainter {
  _OiSurfacePainter(this.base, this.shadows, VoidCallback? onChanged)
    : background = base
          .copyWith(
            border: switch (base.border) {
              Border() => _OiDeferredBorder(base.border! as Border),
              BorderDirectional() => _OiDeferredDirectionalBorder(
                base.border! as BorderDirectional,
              ),
              null => const Border(),
              // Custom BoxBorder has no SDK opaque-side adjustment. Its actual
              // geometry/paint remain on base, not on this background stand-in.
              _ => const Border(),
            },
          )
          .createBoxPainter(onChanged),
      super(onChanged);

  final BoxDecoration base;
  final List<OiInsetShadow> shadows;
  final BoxPainter background;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & configuration.size!;
    final insets =
        base.border?.dimensions.resolve(
          configuration.textDirection ?? TextDirection.ltr,
        ) ??
        EdgeInsets.zero;
    final outer = base.shape == BoxShape.circle
        ? RRect.fromRectAndRadius(
            Rect.fromCircle(center: rect.center, radius: rect.shortestSide / 2),
            Radius.circular(rect.shortestSide / 2),
          )
        : (base.borderRadius?.resolve(configuration.textDirection) ??
                  BorderRadius.zero)
              .toRRect(rect)
              .scaleRadii();
    final padding = RRect.fromLTRBAndCorners(
      outer.left + insets.left,
      outer.top + insets.top,
      outer.right - insets.right,
      outer.bottom - insets.bottom,
      topLeft: Radius.elliptical(
        (outer.tlRadiusX - insets.left).clamp(0, double.infinity),
        (outer.tlRadiusY - insets.top).clamp(0, double.infinity),
      ),
      topRight: Radius.elliptical(
        (outer.trRadiusX - insets.right).clamp(0, double.infinity),
        (outer.trRadiusY - insets.top).clamp(0, double.infinity),
      ),
      bottomLeft: Radius.elliptical(
        (outer.blRadiusX - insets.left).clamp(0, double.infinity),
        (outer.blRadiusY - insets.bottom).clamp(0, double.infinity),
      ),
      bottomRight: Radius.elliptical(
        (outer.brRadiusX - insets.right).clamp(0, double.infinity),
        (outer.brRadiusY - insets.bottom).clamp(0, double.infinity),
      ),
    ).scaleRadii();
    background.paint(canvas, offset, configuration);
    // Retained native border sides preserve SDK collapsed background geometry.
    // One delegate also avoids a second image subscription after resizing.
    if (!padding.isEmpty) {
      canvas
        ..save()
        ..clipRRect(padding);
      for (final shadow in shadows.reversed) {
        final hole = padding.shift(shadow.offset).deflate(shadow.spread);
        final path = Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(padding.outerRect.inflate(4 * shadow.blurSigma + 1));
        if (!hole.isEmpty) path.addRRect(hole);
        final paint = Paint()..color = shadow.color;
        if (shadow.blurSigma > 0) {
          paint.maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            shadow.blurSigma,
          );
        }
        canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
    base.border?.paint(
      canvas,
      rect,
      shape: base.shape,
      borderRadius: base.borderRadius?.resolve(configuration.textDirection),
      textDirection: configuration.textDirection,
    );
  }

  @override
  void dispose() {
    background.dispose();
    super.dispose();
  }
}
