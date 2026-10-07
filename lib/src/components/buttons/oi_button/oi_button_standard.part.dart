part of '../oi_button.dart';

class _OiButtonStandard extends StatelessWidget {
  const _OiButtonStandard({required this.state});
  final _OiButtonState state;
  @override
  Widget build(BuildContext context) {
    final widget = state.widget;

    if (widget.variant == OiButtonVariant.ghost) {
      return _OiButtonGhost(state: state);
    }

    final density = OiDensityScope.of(context);
    final bt = _buttonTheme(context);
    final height = bt?.height ?? state._buttonHeight(density);
    final padding = state._padding(context);
    final foreground = state._foregroundColor(context, widget.variant);
    final themeRadius = bt?.borderRadius;
    final effectiveRadius =
        widget.borderRadius ?? themeRadius ?? context.radius.sm;
    final decoration = state._decoration(
      context,
      widget.variant,
      borderRadius: widget.borderRadius,
    );
    final isActive = widget.enabled && !widget.loading;

    final button = OiTappable(
      statesController: state._states,
      applyBackgroundOverlay: !state._usesStateBackground(context),
      onTap: isActive ? widget.onTap : null,
      enabled: isActive,
      disabledOpacity: 1,
      semanticLabel: widget.semanticLabel ?? widget.label,
      clipBorderRadius: effectiveRadius,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.4,
          child: Container(
            height: height,
            padding: padding,
            decoration: decoration,
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
          ),
        ),
      ),
    );

    return _OiButtonFrame(
      state: state,
      applyMinWidth: true,
      applyTooltip: true,
      child: button,
    );
  }
}
