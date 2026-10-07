part of '../oi_button.dart';

class _OiButtonGhost extends StatelessWidget {
  const _OiButtonGhost({required this.state});
  final _OiButtonState state;
  @override
  Widget build(BuildContext context) {
    final widget = state.widget;

    final density = OiDensityScope.of(context);
    final bt = _buttonTheme(context);
    final height = bt?.height ?? state._buttonHeight(density);
    final padding = state._padding(context);
    final foreground = state._foregroundColor(context, widget.variant);
    final isActive = widget.enabled && !widget.loading;

    Widget content = Container(
      height: height,
      padding: padding,
      decoration: state._decoration(
        context,
        widget.variant,
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        widthFactor: 1,
        child: _OiButtonContentView(
          state: state,
          label: widget.label,
          icon: widget.icon,
          iconPosition: widget.iconPosition,
          foreground: foreground,
          loading: widget.loading,
        ),
      ),
    );

    if (!widget.enabled) {
      content = Opacity(opacity: 0.4, child: content);
    }

    content = OiTappable(
      statesController: state._states,
      applyBackgroundOverlay: !state._usesStateBackground(context),
      onTap: isActive ? widget.onTap : null,
      enabled: isActive,
      disabledOpacity: 1,
      semanticLabel: widget.semanticLabel ?? widget.label,
      clipBorderRadius:
          widget.borderRadius ?? bt?.borderRadius ?? context.radius.sm,
      child: ExcludeSemantics(child: content),
    );

    return _OiButtonFrame(
      state: state,
      applyMinWidth: true,
      applyTooltip: true,
      child: content,
    );
  }
}
