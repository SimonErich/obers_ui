part of '../oi_button.dart';

class _OiButtonSplit extends StatelessWidget {
  const _OiButtonSplit({required this.state});
  final _OiButtonState state;
  @override
  Widget build(BuildContext context) {
    final widget = state.widget;
    return OiFloating(
      visible: state._dropdownVisible,
      alignment: OiFloatingAlignment.bottomEnd,
      anchor: OiRow(
        breakpoint: context.breakpoint,
        children: [
          _OiButtonSplitMain(state: state),
          _OiButtonSplitTrigger(state: state),
        ],
      ),
      child: widget.dropdown ?? const SizedBox(),
    );
  }
}

class _OiButtonSplitMain extends StatelessWidget {
  const _OiButtonSplitMain({required this.state});
  final _OiButtonState state;
  @override
  Widget build(BuildContext context) {
    final widget = state.widget;

    final density = OiDensityScope.of(context);
    final height =
        _buttonTheme(context)?.height ?? state._buttonHeight(density);
    final padding = state._padding(context);
    final minWidth = state._sizeStyle(context)?.minWidth;
    final foreground = state._foregroundColor(context, widget.variant);
    final bgColor = state._backgroundColor(context, widget.variant);
    final borderRadius =
        _buttonTheme(context)?.borderRadius ?? context.radius.sm;

    final leftRadius = BorderRadius.only(
      topLeft: borderRadius.topLeft,
      bottomLeft: borderRadius.bottomLeft,
    );

    final mainPart = OiTappable(
      statesController: state._states,
      applyBackgroundOverlay: !state._usesStateBackground(context),
      onTap: widget.onTap,
      enabled: widget.enabled,
      child: Container(
        height: height,
        constraints: minWidth == null
            ? null
            : BoxConstraints(minWidth: minWidth),
        padding: padding,
        decoration: BoxDecoration(color: bgColor, borderRadius: leftRadius),
        child: Center(
          child: _OiButtonLabel(
            state: state,
            label: widget.label ?? '',
            foreground: foreground,
            singleLine: false,
          ),
        ),
      ),
    );

    return mainPart;
  }
}

class _OiButtonSplitTrigger extends StatelessWidget {
  const _OiButtonSplitTrigger({required this.state});
  final _OiButtonState state;
  @override
  Widget build(BuildContext context) {
    final widget = state.widget;

    final density = OiDensityScope.of(context);
    final height =
        _buttonTheme(context)?.height ?? state._buttonHeight(density);
    final foreground = state._foregroundColor(context, widget.variant);
    final bgColor = state._backgroundColor(context, widget.variant);
    final borderRadius =
        _buttonTheme(context)?.borderRadius ?? context.radius.sm;

    final rightRadius = BorderRadius.only(
      topRight: borderRadius.topRight,
      bottomRight: borderRadius.bottomRight,
    );

    final chevronPart = OiTappable(
      statesController: state._states,
      applyBackgroundOverlay: !state._usesStateBackground(context),
      onTap: widget.enabled ? state._toggleDropdownVisible : null,
      enabled: widget.enabled,
      child: Container(
        height: height,
        width: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: rightRadius,
          border: Border(
            left: BorderSide(color: foreground.withValues(alpha: 0.3)),
          ),
        ),
        child: Center(
          child: OiIcon.raw(
            OiIcons.arrowDown,
            size: state._sizeStyle(context)?.iconSize ?? state._iconSize(),
            color: foreground,
          ),
        ),
      ),
    );

    return chevronPart;
  }
}
