import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';

/// A visual ghost shown under the pointer or finger during a drag operation.
///
/// Applies [opacity], a [rotation] (in radians), and a [scale] transform to
/// its [child].  When [scale] or [rotation] are omitted the defaults are
/// chosen based on the current input modality:
///
/// | Modality | scale | rotation |
/// |----------|-------|----------|
/// | touch    | 1.0   | 0.05 rad |
/// | pointer  | 1.05  | 0.0 rad  |
///
/// {@category Primitives}
class OiDragGhost extends StatelessWidget {
  /// Creates an [OiDragGhost].
  const OiDragGhost({
    required this.child,
    this.scale,
    this.rotation,
    this.opacity = 0.85,
    super.key,
  });

  /// The widget to render as the drag ghost.
  final Widget child;

  /// Scale factor applied to the ghost.
  ///
  /// When null, defaults to `1.0` on touch and `1.05` on pointer.
  final double? scale;

  /// Rotation in radians applied to the ghost.
  ///
  /// When null, defaults to `0.05` on touch and `0.0` on pointer.
  final double? rotation;

  /// Opacity of the ghost widget.
  ///
  /// Defaults to `0.85`.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final density = OiDensityScope.of(context);
    final isTouch = density == OiDensity.comfortable;

    final effectiveRotation = rotation ?? (isTouch ? 0.05 : 0.0);
    final effectiveScale = scale ?? (isTouch ? 1.0 : 1.05);

    var result = child;

    if (effectiveRotation != 0.0) {
      result = Transform.rotate(
        angle: effectiveRotation,
        child: result,
      );
    }

    if (effectiveScale != 1.0) {
      result = Transform.scale(
        scale: effectiveScale,
        child: result,
      );
    }

    return Opacity(
      opacity: opacity,
      child: result,
    );
  }
}
