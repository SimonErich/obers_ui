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
/// is unchanged. The extra area is transparent and responds to hit-testing,
/// ensuring WCAG minimum tap-target compliance.
///
/// {@category Primitives}
class OiTouchTarget extends StatelessWidget {
  /// Creates an [OiTouchTarget] that reads its minimum size from
  /// [OiA11y.minTouchTarget].
  const OiTouchTarget({required this.child, super.key}) : _minSize = null;

  /// Creates an [OiTouchTarget] with an explicit [minSize] override.
  const OiTouchTarget.custom({
    required double minSize,
    required this.child,
    super.key,
  }) : _minSize = minSize;

  /// The child widget whose hit area is enforced.
  final Widget child;

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
    return _TouchTargetPadding(minSize: minTarget, child: child);
  }
}

// ── Internal render object ─────────────────────────────────────────────────

/// Wraps its child and enforces a minimum hit area of [minSize] x [minSize] dp.
class _TouchTargetPadding extends SingleChildRenderObjectWidget {
  const _TouchTargetPadding({required super.child, required this.minSize});

  final double minSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTouchTargetPadding(minSize: minSize);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTouchTargetPadding renderObject,
  ) {
    renderObject.minSize = minSize;
  }
}

class _RenderTouchTargetPadding extends RenderProxyBox {
  _RenderTouchTargetPadding({required double minSize}) : _minSize = minSize;

  double _minSize;

  double get minSize => _minSize;

  set minSize(double value) {
    if (_minSize == value) return;
    _minSize = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(super.computeMinIntrinsicWidth(height), _minSize);

  @override
  double computeMinIntrinsicHeight(double width) =>
      math.max(super.computeMinIntrinsicHeight(width), _minSize);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childSize = super.computeDryLayout(constraints);
    return constraints.constrain(
      Size(
        math.max(childSize.width, _minSize),
        math.max(childSize.height, _minSize),
      ),
    );
  }

  @override
  void performLayout() {
    super.performLayout();
    size = constraints.constrain(
      Size(math.max(size.width, _minSize), math.max(size.height, _minSize)),
    );
  }
}
