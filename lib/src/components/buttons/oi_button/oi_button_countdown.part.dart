part of '../oi_button.dart';

class _OiButtonCountdown extends StatelessWidget {
  const _OiButtonCountdown({required this.state});
  final _OiButtonState state;
  @override
  Widget build(BuildContext context) {
    final widget = state.widget;

    final isExpired = state._remaining <= 0;
    final displayLabel = isExpired
        ? widget.label ?? ''
        : '${widget.label ?? ''} (${state._remaining})';

    final density = OiDensityScope.of(context);
    final height =
        _buttonTheme(context)?.height ?? state._buttonHeight(density);
    final padding = state._padding(context);
    final foreground = state._foregroundColor(context, widget.variant);
    final decoration = state._decoration(context, widget.variant);

    final button = OiTappable(
      statesController: state._states,
      applyBackgroundOverlay: !state._usesStateBackground(context),
      onTap: widget.onTap,
      enabled: isExpired,
      child: Container(
        height: height,
        padding: padding,
        decoration: decoration,
        child: Center(
          widthFactor: 1,
          child: _OiButtonLabel(
            state: state,
            label: displayLabel,
            foreground: foreground,
          ),
        ),
      ),
    );

    return _OiButtonFrame(state: state, child: button);
  }
}
