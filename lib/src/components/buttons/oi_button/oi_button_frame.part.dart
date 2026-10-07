part of '../oi_button.dart';

class _OiButtonFrame extends StatelessWidget {
  const _OiButtonFrame({
    required this.state,
    required this.child,
    this.applyMinWidth = false,
    this.applyTooltip = false,
  });
  final _OiButtonState state;
  final Widget child;
  final bool applyMinWidth;
  final bool applyTooltip;
  @override
  Widget build(BuildContext context) {
    final widget = state.widget;
    final bt = _buttonTheme(context);
    final minWidth =
        state._sizeStyle(context)?.minWidth ??
        (applyMinWidth ? bt?.minWidth : null);
    var button = child;
    if (minWidth != null) {
      button = ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: button,
      );
    }
    // Keep the action separate from indexed/sliver header text. Place the
    // boundary around the fitted frame so its semantic bounds stay precise.
    button = Semantics(container: true, child: button);
    button = widget.fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : UnconstrainedBox(constrainedAxis: Axis.vertical, child: button);
    if (applyTooltip && widget.tooltip != null) {
      return OiTooltip(
        label: widget.tooltip!,
        message: widget.tooltip!,
        excludeFromSemantics:
            widget.tooltip == (widget.semanticLabel ?? widget.label),
        child: button,
      );
    }
    return button;
  }
}
