part of '../oi_button.dart';

class _OiButtonContentView extends StatelessWidget {
  const _OiButtonContentView({
    required this.state,
    required this.label,
    required this.icon,
    required this.iconPosition,
    required this.foreground,
    required this.loading,
  });
  final _OiButtonState state;
  final String? label;
  final IconData? icon;
  final OiIconPosition iconPosition;
  final Color foreground;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    final widget = state.widget;

    if (loading) {
      return _OiButtonLoadingIndicator(color: foreground);
    }

    final bt = _buttonTheme(context);
    final selected = state._sizeStyle(context);
    final effectiveIconSize =
        selected?.iconSize ?? bt?.iconSize ?? state._iconSize();
    final effectiveIconGap =
        selected?.iconGap ??
        (widget.size == OiButtonSize.small ? bt?.smallIconGap : null) ??
        bt?.iconGap ??
        context.spacing.xs;
    final iconWidget = icon != null
        ? Padding(
            padding: selected?.iconGap != null
                ? EdgeInsetsDirectional.only(
                    end: iconPosition == OiIconPosition.leading && label != null
                        ? effectiveIconGap
                        : 0,
                    start:
                        iconPosition == OiIconPosition.trailing && label != null
                        ? effectiveIconGap
                        : 0,
                  )
                : EdgeInsets.only(
                    right:
                        (iconPosition == OiIconPosition.leading &&
                            label != null)
                        ? effectiveIconGap
                        : 0,
                    left:
                        (iconPosition == OiIconPosition.trailing &&
                            label != null)
                        ? effectiveIconGap
                        : 0,
                  ),
            child: OiIcon.decorative(
              icon: icon,
              size: effectiveIconSize,
              color: foreground,
            ),
          )
        : null;

    final labelWidget = label != null
        ? _OiButtonLabel(
            state: state,
            label: label!,
            foreground: foreground,
          )
        : null;

    if (iconWidget == null && labelWidget != null) return labelWidget;
    if (iconWidget != null && labelWidget == null) return iconWidget;
    if (iconWidget == null && labelWidget == null) return const SizedBox();

    final children = iconPosition == OiIconPosition.leading
        ? [iconWidget!, labelWidget!]
        : [labelWidget!, iconWidget!];

    return OiRow(
      breakpoint: context.breakpoint,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

class _OiButtonLoadingIndicator extends StatelessWidget {
  const _OiButtonLoadingIndicator({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return OiPulse(
      child: SizedBox(
        width: 16,
        height: 16,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
