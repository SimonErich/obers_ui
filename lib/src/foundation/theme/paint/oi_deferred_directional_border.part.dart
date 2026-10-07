part of '../oi_surface_decoration.dart';

// As with the physical Border subtype, leave Flutter's direction-aware opaque
// side adjustment intact and defer ONLY its border paint to the final layer.
class _OiDeferredDirectionalBorder extends BorderDirectional {
  _OiDeferredDirectionalBorder(BorderDirectional border)
    : super(
        top: border.top,
        start: border.start,
        end: border.end,
        bottom: border.bottom,
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
