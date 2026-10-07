part of '../oi_surface_decoration.dart';

// Flutter's BoxDecoration adjusts background geometry from opaque Border sides.
// Retaining that native subtype preserves its SDK-owned geometry; defer ONLY
// border paint until after the inset layer, without reimplementing backgrounds.
class _OiDeferredBorder extends Border {
  _OiDeferredBorder(Border border)
    : super(
        top: border.top,
        right: border.right,
        bottom: border.bottom,
        left: border.left,
      );

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {}
}
