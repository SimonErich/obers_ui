part of '../oi_toast.dart';

class _OiToastContent extends StatelessWidget {
  const _OiToastContent({
    required this.toast,
    required this.accent,
    required this.effectiveIconSize,
    required this.effectiveGap,
    required this.onDismiss,
  });

  final OiToast toast;
  final Color accent;
  final double effectiveIconSize;
  final double effectiveGap;
  final VoidCallback onDismiss;

  String _icon() {
    switch (toast.level) {
      case OiToastLevel.info:
        return 'ℹ';
      case OiToastLevel.success:
        return '✓';
      case OiToastLevel.warning:
        return '⚠';
      case OiToastLevel.error:
        return '✕';
    }
  }

  String _iconSemanticLabel() {
    switch (toast.level) {
      case OiToastLevel.info:
        return 'Info';
      case OiToastLevel.success:
        return 'Success';
      case OiToastLevel.warning:
        return 'Warning';
      case OiToastLevel.error:
        return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    return Row(
      children: [
        Semantics(
          label: _iconSemanticLabel(),
          container: true,
          excludeSemantics: true,
          child: Text(
            _icon(),
            style: TextStyle(
              color: accent,
              fontSize: effectiveIconSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: effectiveGap),
        Expanded(
          child: Text(
            toast.message,
            style: textTheme.small.copyWith(color: colors.text),
          ),
        ),
        if (toast.dismissible && toast.onDismiss != null) ...[
          SizedBox(width: effectiveGap),
          OiIconButton(
            icon: OiIcons.x,
            semanticLabel: toast.dismissLabel,
            onTap: onDismiss,
          ),
        ],
        if (toast.action != null) ...[
          SizedBox(width: effectiveGap),
          toast.action!,
        ],
      ],
    );
  }
}
