import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';

/// Wraps [child] and enforces a minimum hit area on touch platforms.
///
/// By default reads [OiA11y.minTouchTarget] from context (48 dp on touch,
/// 0 dp on pointer). Use [OiTouchTarget.custom] to supply an explicit
/// minSize instead.
///
/// This widget only inflates the layout size — the child's visual appearance
/// is unchanged. The extra area is transparent; a tap in it counts as a tap
/// on the child's centre, ensuring WCAG minimum tap-target compliance. A
/// child smaller than the target is placed in it by [alignment] (centred by
/// default), so a small icon lines up with the controls around it.
///
/// The child gets the incoming constraints unchanged: in a slot that forces
/// its width (an `Expanded` row) it fills that width, and only its height
/// is aligned.
///
/// {@category Primitives}
class OiTouchTarget extends StatelessWidget {
  /// Creates an [OiTouchTarget] that reads its minimum size from
  /// [OiA11y.minTouchTarget].
  const OiTouchTarget({
    required this.child,
    this.alignment = Alignment.center,
    super.key,
  }) : _minSize = null;

  /// Creates an [OiTouchTarget] with an explicit [minSize] override.
  const OiTouchTarget.custom({
    required double minSize,
    required this.child,
    this.alignment = Alignment.center,
    super.key,
  }) : _minSize = minSize;

  /// The child widget whose hit area is enforced.
  final Widget child;

  /// Where a child smaller than the touch target sits in it.
  ///
  /// Defaults to [Alignment.center].
  final AlignmentGeometry alignment;

  /// Explicit minimum size override, or `null` to read from context.
  final double? _minSize;

  @override
  Widget build(BuildContext context) {
    final minTarget = _minSize ?? OiA11y.minTouchTarget(context);
    // Always render _TouchTargetPadding so the widget-tree structure is stable
    // across input-modality changes (pointer ↔ touch).  When minTarget is zero
    // or negative, _TouchTargetPadding behaves as a no-op pass-through because
    // max(childSize, 0) == childSize.  Keeping a consistent subtree prevents
    // in-flight gesture recognisers from being dropped when a modality rebuild
    // removes or adds this wrapping render-object mid-gesture.
    return _TouchTargetPadding(
      minSize: minTarget,
      alignment: alignment,
      child: child,
    );
  }
}

// ── Internal render object ─────────────────────────────────────────────────

/// Wraps its child and enforces a minimum hit area of [minSize] x [minSize] dp,
/// placing a smaller child by [alignment].
class _TouchTargetPadding extends SingleChildRenderObjectWidget {
  const _TouchTargetPadding({
    required super.child,
    required this.minSize,
    required this.alignment,
  });

  final double minSize;
  final AlignmentGeometry alignment;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTouchTargetPadding(
        minSize: minSize,
        alignment: alignment,
        textDirection: Directionality.maybeOf(context),
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTouchTargetPadding renderObject,
  ) {
    renderObject
      ..minSize = minSize
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context);
  }
}

class _RenderTouchTargetPadding extends RenderShiftedBox {
  _RenderTouchTargetPadding({
    required double minSize,
    required AlignmentGeometry alignment,
    required TextDirection? textDirection,
  }) : _minSize = minSize,
       _alignment = alignment,
       _textDirection = textDirection,
       super(null);

  double _minSize;

  double get minSize => _minSize;

  set minSize(double value) {
    if (_minSize == value) return;
    _minSize = value;
    markNeedsLayout();
  }

  AlignmentGeometry _alignment;

  AlignmentGeometry get alignment => _alignment;

  set alignment(AlignmentGeometry value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsLayout();
  }

  TextDirection? _textDirection;

  TextDirection? get textDirection => _textDirection;

  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  Size _sizeFor(BoxConstraints constraints, Size childSize) =>
      constraints.constrain(
        Size(
          math.max(childSize.width, _minSize),
          math.max(childSize.height, _minSize),
        ),
      );

  Offset _childOffset(Size size, Size childSize) => _alignment
      .resolve(_textDirection)
      .alongOffset(size - childSize as Offset);

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(super.computeMinIntrinsicWidth(height), _minSize);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(super.computeMaxIntrinsicWidth(height), _minSize);

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.max(super.computeMinIntrinsicHeight(width), _minSize);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      math.max(super.computeMaxIntrinsicHeight(width), _minSize);

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final child = this.child;
    final childSize = child == null
        ? Size.zero
        : child.getDryLayout(constraints);
    return _sizeFor(constraints, childSize);
  }

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final child = this.child;
    if (child == null) return null;
    final result = child.getDryBaseline(constraints, baseline);
    if (result == null) return null;
    final childSize = child.getDryLayout(constraints);
    final size = _sizeFor(constraints, childSize);
    return result + _childOffset(size, childSize).dy;
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = _sizeFor(constraints, Size.zero);
      return;
    }
    child.layout(constraints, parentUsesSize: true);
    size = _sizeFor(constraints, child.size);
    (child.parentData! as BoxParentData).offset = _childOffset(
      size,
      child.size,
    );
  }

  // A tap in the padding around a smaller child counts as a tap on the
  // child's centre, so a gesture detector inside this widget gets the whole
  // touch target, not only the child's own area (as Material's buttons do).
  // A tap on the child itself is left alone, so a transparent spot there
  // stays transparent.
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) return true;
    final child = this.child;
    if (child == null || !size.contains(position)) return false;
    final childOffset = (child.parentData! as BoxParentData).offset;
    if ((childOffset & child.size).contains(position)) return false;
    final center = child.size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (result, position) => child.hitTest(result, position: center),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('minSize', _minSize))
      ..add(DiagnosticsProperty<AlignmentGeometry>('alignment', _alignment))
      ..add(EnumProperty<TextDirection>('textDirection', _textDirection));
  }
}
