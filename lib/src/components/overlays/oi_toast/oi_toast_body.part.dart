part of '../oi_toast.dart';

enum _OiToastSlot { lead, action, dismiss }

/// Lays out a toast's content: the icon and message ([lead]), an optional
/// [action] and an optional [dismiss] control.
///
/// Wide enough, they share one row with the action beside the dismiss control
/// at the trailing edge. When the message would be squeezed below
/// [minLeadWidth] by the action, the action drops to a row of its own under
/// the message, aligned to the trailing edge, and the dismiss control stays
/// beside the message. A plain [Row] cannot do this: it has no way to move one
/// child to another line, so a wide action overflowed a narrow toast.
class _OiToastBody
    extends SlottedMultiChildRenderObjectWidget<_OiToastSlot, RenderBox> {
  const _OiToastBody({
    required this.lead,
    required this.gap,
    required this.minLeadWidth,
    this.action,
    this.dismiss,
  });

  /// The icon and message. Laid out at a tight width, so it may expand.
  final Widget lead;

  /// An optional action beside, or under, the message.
  final Widget? action;

  /// An optional dismiss control at the trailing edge of the first row.
  final Widget? dismiss;

  /// The space between the lead, the action and the dismiss control, and
  /// between the rows.
  final double gap;

  /// The narrowest the lead may become before the action wraps.
  final double minLeadWidth;

  @override
  Iterable<_OiToastSlot> get slots => _OiToastSlot.values;

  @override
  Widget? childForSlot(_OiToastSlot slot) => switch (slot) {
    _OiToastSlot.lead => lead,
    _OiToastSlot.action => action,
    _OiToastSlot.dismiss => dismiss,
  };

  @override
  SlottedContainerRenderObjectMixin<_OiToastSlot, RenderBox> createRenderObject(
    BuildContext context,
  ) => _RenderOiToastBody(gap: gap, minLeadWidth: minLeadWidth);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderOiToastBody renderObject,
  ) {
    renderObject
      ..gap = gap
      ..minLeadWidth = minLeadWidth;
  }
}

class _OiToastBodyLayout {
  const _OiToastBodyLayout({
    required this.size,
    required this.leadOffset,
    required this.actionOffset,
    required this.dismissOffset,
  });

  final Size size;
  final Offset leadOffset;
  final Offset actionOffset;
  final Offset dismissOffset;
}

class _RenderOiToastBody extends RenderBox
    with SlottedContainerRenderObjectMixin<_OiToastSlot, RenderBox> {
  _RenderOiToastBody({required double gap, required double minLeadWidth})
    : _gap = gap,
      _minLeadWidth = minLeadWidth;

  double _gap;
  double get gap => _gap;
  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  double _minLeadWidth;
  double get minLeadWidth => _minLeadWidth;
  set minLeadWidth(double value) {
    if (_minLeadWidth == value) return;
    _minLeadWidth = value;
    markNeedsLayout();
  }

  RenderBox get _lead => childForSlot(_OiToastSlot.lead)!;
  RenderBox? get _action => childForSlot(_OiToastSlot.action);
  RenderBox? get _dismiss => childForSlot(_OiToastSlot.dismiss);

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BoxParentData) child.parentData = BoxParentData();
  }

  _OiToastBodyLayout _layoutChildren(
    BoxConstraints constraints,
    Size Function(RenderBox child, BoxConstraints constraints) layoutChild,
  ) {
    final maxWidth = constraints.maxWidth;
    final loose = BoxConstraints(
      maxWidth: maxWidth,
      maxHeight: constraints.maxHeight,
    );
    final action = _action;
    final dismiss = _dismiss;
    final actionSize = action == null ? Size.zero : layoutChild(action, loose);
    final dismissSize = dismiss == null
        ? Size.zero
        : layoutChild(dismiss, loose);
    final actionSpan = action == null ? 0.0 : actionSize.width + _gap;
    final dismissSpan = dismiss == null ? 0.0 : dismissSize.width + _gap;

    // The action wraps only when it would squeeze the message too far.
    final stacked =
        action != null && maxWidth - actionSpan - dismissSpan < _minLeadWidth;
    final leadWidth = (stacked
        ? maxWidth - dismissSpan
        : maxWidth - actionSpan - dismissSpan);
    final leadSize = layoutChild(
      _lead,
      BoxConstraints.tightFor(width: leadWidth.clamp(0, maxWidth)),
    );

    var firstRowHeight = leadSize.height;
    if (dismissSize.height > firstRowHeight) {
      firstRowHeight = dismissSize.height;
    }
    if (!stacked && actionSize.height > firstRowHeight) {
      firstRowHeight = actionSize.height;
    }
    double centered(double rowHeight, Size child) =>
        (rowHeight - child.height) / 2;

    final leadOffset = Offset(0, centered(firstRowHeight, leadSize));
    final dismissOffset = Offset(
      maxWidth - dismissSize.width,
      centered(firstRowHeight, dismissSize),
    );
    if (!stacked) {
      return _OiToastBodyLayout(
        size: constraints.constrain(Size(maxWidth, firstRowHeight)),
        leadOffset: leadOffset,
        actionOffset: Offset(
          leadSize.width + _gap,
          centered(firstRowHeight, actionSize),
        ),
        dismissOffset: dismissOffset,
      );
    }
    final actionTop = firstRowHeight + _gap / 2;
    return _OiToastBodyLayout(
      size: constraints.constrain(
        Size(maxWidth, actionTop + actionSize.height),
      ),
      leadOffset: leadOffset,
      actionOffset: Offset(maxWidth - actionSize.width, actionTop),
      dismissOffset: dismissOffset,
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => _layoutChildren(
    constraints,
    ChildLayoutHelper.dryLayoutChild,
  ).size;

  @override
  void performLayout() {
    final layout = _layoutChildren(constraints, ChildLayoutHelper.layoutChild);
    size = layout.size;
    (_lead.parentData! as BoxParentData).offset = layout.leadOffset;
    final action = _action;
    if (action != null) {
      (action.parentData! as BoxParentData).offset = layout.actionOffset;
    }
    final dismiss = _dismiss;
    if (dismiss != null) {
      (dismiss.parentData! as BoxParentData).offset = layout.dismissOffset;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    final action = _action?.getMinIntrinsicWidth(height) ?? 0;
    final dismiss = _dismiss?.getMinIntrinsicWidth(height) ?? 0;
    final lead = _lead.getMinIntrinsicWidth(height);
    final firstRow = lead + (dismiss > 0 ? dismiss + _gap : 0);
    return firstRow > action ? firstRow : action;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    var width = _lead.getMaxIntrinsicWidth(height);
    final action = _action;
    if (action != null) width += _gap + action.getMaxIntrinsicWidth(height);
    final dismiss = _dismiss;
    if (dismiss != null) width += _gap + dismiss.getMaxIntrinsicWidth(height);
    return width;
  }

  /// The height at [width], from the children's intrinsic sizes and the same
  /// wrapping rule as [_layoutChildren]. Intrinsic sizes ignore a touch
  /// target's extra padding, so the toast keeps one height as the input
  /// modality changes, as it did when this was a plain row.
  double _intrinsicHeight(double width) {
    final action = _action;
    final dismiss = _dismiss;
    final actionWidth = action == null
        ? 0.0
        : action.getMaxIntrinsicWidth(double.infinity).clamp(0.0, width);
    final dismissWidth = dismiss == null
        ? 0.0
        : dismiss.getMaxIntrinsicWidth(double.infinity).clamp(0.0, width);
    final actionSpan = action == null ? 0.0 : actionWidth + _gap;
    final dismissSpan = dismiss == null ? 0.0 : dismissWidth + _gap;
    final stacked =
        action != null && width - actionSpan - dismissSpan < _minLeadWidth;
    final leadWidth =
        (stacked ? width - dismissSpan : width - actionSpan - dismissSpan)
            .clamp(0.0, width);
    final actionHeight = action?.getMaxIntrinsicHeight(actionWidth) ?? 0;
    var firstRow = _lead.getMaxIntrinsicHeight(leadWidth);
    final dismissHeight = dismiss?.getMaxIntrinsicHeight(dismissWidth) ?? 0;
    if (dismissHeight > firstRow) firstRow = dismissHeight;
    if (!stacked) return actionHeight > firstRow ? actionHeight : firstRow;
    return firstRow + _gap / 2 + actionHeight;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final child in children) {
      context.paintChild(
        child,
        (child.parentData! as BoxParentData).offset + offset,
      );
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final child in children.toList().reversed) {
      final parentData = child.parentData! as BoxParentData;
      final hit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (result, transformed) =>
            child.hitTest(result, position: transformed),
      );
      if (hit) return true;
    }
    return false;
  }
}

/// Keeps a toast's action inside the toast: at its natural size when it fits,
/// scaled down to the available width when it does not.
///
/// An action such as a button sizes itself to its label and ignores a width
/// limit, so on a very narrow viewport it would overflow the toast.
class _OiToastActionFit extends SingleChildRenderObjectWidget {
  const _OiToastActionFit({required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderOiToastActionFit();
}

class _RenderOiToastActionFit extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  double _scale = 1;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! BoxParentData) child.parentData = BoxParentData();
  }

  /// The child's natural width, but never taller than the toast allows.
  BoxConstraints _childConstraints(BoxConstraints constraints) =>
      BoxConstraints(maxHeight: constraints.maxHeight);

  (Size, double) _fit(BoxConstraints constraints, Size childSize) {
    final scale = childSize.width > constraints.maxWidth && childSize.width > 0
        ? constraints.maxWidth / childSize.width
        : 1.0;
    return (
      constraints.constrain(
        Size(childSize.width * scale, childSize.height * scale),
      ),
      scale,
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    return _fit(
      constraints,
      child.getDryLayout(_childConstraints(constraints)),
    ).$1;
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_childConstraints(constraints), parentUsesSize: true);
    final (fitted, scale) = _fit(constraints, child.size);
    size = fitted;
    _scale = scale;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      child?.getMinIntrinsicWidth(height) ?? 0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      child?.getMaxIntrinsicWidth(height) ?? 0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      child?.getMinIntrinsicHeight(double.infinity) ?? 0;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      child?.getMaxIntrinsicHeight(double.infinity) ?? 0;

  Matrix4 get _transform => Matrix4.diagonal3Values(_scale, _scale, 1);

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    if (_scale == 1) {
      context.paintChild(child, offset);
      return;
    }
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _transform,
      (context, offset) => context.paintChild(child, offset),
      oldLayer: layer as TransformLayer?,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null) return false;
    return result.addWithPaintTransform(
      transform: _transform,
      position: position,
      hitTest: (result, transformed) =>
          child.hitTest(result, position: transformed),
    );
  }
}
