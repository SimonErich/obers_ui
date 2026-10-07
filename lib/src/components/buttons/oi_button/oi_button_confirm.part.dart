part of '../oi_button.dart';

class _OiButtonConfirm extends StatelessWidget {
  const _OiButtonConfirm({required this.state});
  final _OiButtonState state;
  @override
  Widget build(BuildContext context) {
    final widget = state.widget;

    final density = OiDensityScope.of(context);
    final height =
        _buttonTheme(context)?.height ?? state._buttonHeight(density);
    final padding = state._padding(context);

    final activeVariant = state._confirmPending
        ? OiButtonVariant.destructive
        : widget.variant;
    final displayLabel = state._confirmPending
        ? (widget.confirmLabel ?? widget.label ?? '')
        : (widget.label ?? '');
    final foreground = state._foregroundColor(context, activeVariant);
    final decoration = state._decoration(context, activeVariant);

    final button = OiTappable(
      statesController: state._states,
      applyBackgroundOverlay: !state._usesStateBackground(context),
      onTap: () {
        if (state._confirmPending) {
          state._setConfirmPending(false);
          widget.onConfirm?.call();
        } else {
          state._setConfirmPending(true);
        }
      },
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
