part of '../oi_toast.dart';

class _OiToastSurface extends StatelessWidget {
  const _OiToastSurface({required this.toast, required this.onDismiss});

  final OiToast toast;
  final VoidCallback onDismiss;

  Color _accentColor(OiColorScheme colors) {
    switch (toast.level) {
      case OiToastLevel.info:
        return colors.info.base;
      case OiToastLevel.success:
        return colors.success.base;
      case OiToastLevel.warning:
        return colors.warning.base;
      case OiToastLevel.error:
        return colors.error.base;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = _accentColor(colors);
    final tt = context.components.toast;

    final effectiveBorderRadius = tt?.borderRadius ?? BorderRadius.circular(8);
    final effectivePadding =
        tt?.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    final effectiveIconSize = tt?.iconSize ?? 16.0;
    final effectiveGap = tt?.gap ?? 8.0;
    final effectiveBgColor = tt?.backgroundColor ?? colors.surface;
    final effectiveShadow =
        tt?.shadow ??
        [
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ];

    return Semantics(
      label: toast.label,
      liveRegion: true,
      explicitChildNodes: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 240, maxWidth: 400),
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: effectiveBorderRadius,
          border: Border.all(color: colors.border),
          boxShadow: effectiveShadow,
        ),
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored left-border accent strip.
                Container(width: 4, color: accent),
                Expanded(
                  child: Padding(
                    padding: effectivePadding,
                    child: _OiToastContent(
                      toast: toast,
                      accent: accent,
                      effectiveIconSize: effectiveIconSize,
                      effectiveGap: effectiveGap,
                      onDismiss: onDismiss,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
