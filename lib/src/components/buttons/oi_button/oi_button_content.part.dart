part of '../oi_button.dart';

Widget _buildLoadingIndicator(Color color) {
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

extension _OiButtonContent on _OiButtonState {
  Widget _buildContent(
    BuildContext context, {
    required String? label,
    required IconData? icon,
    required OiIconPosition iconPosition,
    required Color foreground,
    required bool loading,
    bool bold = false,
  }) {
    if (loading) {
      return _buildLoadingIndicator(foreground);
    }

    final bt = context.components.button;
    final effectiveIconSize = bt?.iconSize ?? _iconSize();
    final effectiveIconGap = bt?.iconGap ?? context.spacing.xs;
    final iconWidget = icon != null
        ? Padding(
            padding: EdgeInsets.only(
              right: (iconPosition == OiIconPosition.leading && label != null)
                  ? effectiveIconGap
                  : 0,
              left: (iconPosition == OiIconPosition.trailing && label != null)
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
        ? Text(
            label,
            style: TextStyle(
              fontSize: _fontSize(),
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: foreground,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : null;

    if (iconWidget == null && labelWidget != null) return labelWidget;
    if (iconWidget != null && labelWidget == null) return iconWidget;
    if (iconWidget == null && labelWidget == null) return const SizedBox();

    final children = iconPosition == OiIconPosition.leading
        ? [iconWidget!, labelWidget!]
        : [labelWidget!, iconWidget!];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
