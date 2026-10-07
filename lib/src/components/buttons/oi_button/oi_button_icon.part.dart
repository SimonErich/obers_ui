part of '../oi_button.dart';

class _OiButtonIcon extends StatelessWidget {
  const _OiButtonIcon({required this.state});
  final _OiButtonState state;
  @override
  Widget build(BuildContext context) {
    final widget = state.widget;

    final density = OiDensityScope.of(context);
    final height =
        _buttonTheme(context)?.height ?? state._buttonHeight(density);
    final foreground = state._foregroundColor(context, widget.variant);
    final isActive = widget.enabled && !widget.loading;
    final selected = state._sizeStyle(context);
    final iconSize =
        selected?.iconOnlySize ??
        selected?.iconSize ??
        _buttonTheme(context)?.iconSize ??
        state._iconSize();

    final radius =
        widget.borderRadius ??
        _buttonTheme(context)?.borderRadius ??
        context.radius.sm;
    Widget content = Container(
      width: height,
      height: height,
      padding: selected?.padding,
      decoration: state._decoration(
        context,
        widget.variant,
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: OiIcon.raw(
          widget.icon,
          size: iconSize,
          color: foreground,
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
      clipBorderRadius: radius,
      child: ExcludeSemantics(child: content),
    );

    // Keep the icon control's explicit square geometry even when input
    // modality changes. The interaction layer must fit the same constraints
    // as the visible control (including compact table and quantity actions).
    return SizedBox(width: height, height: height, child: content);
  }
}
