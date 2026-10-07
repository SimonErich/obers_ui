part of '../oi_button.dart';

/// Returns the per-variant style override from the button theme, if any.
OiButtonVariantStyle? _variantStyle(
  OiButtonThemeData? bt,
  OiButtonVariant variant,
) {
  return switch (variant) {
    OiButtonVariant.primary => bt?.primaryStyle,
    OiButtonVariant.secondary => bt?.secondaryStyle,
    OiButtonVariant.outline => bt?.outlineStyle,
    OiButtonVariant.ghost => bt?.ghostStyle,
    OiButtonVariant.destructive => bt?.destructiveStyle,
    OiButtonVariant.soft => bt?.softStyle,
  };
}

extension _OiButtonColors on _OiButtonState {
  Color _backgroundColor(BuildContext context, OiButtonVariant variant) {
    final vs = _variantStyle(_buttonTheme(context), variant);
    if (!widget.enabled && vs?.backgroundDisabled != null) {
      return vs!.backgroundDisabled!;
    }
    if (widget.enabled &&
        !widget.loading &&
        _states.value.contains(WidgetState.pressed) &&
        vs?.backgroundPressed != null) {
      return vs!.backgroundPressed!;
    }
    if (widget.enabled &&
        !widget.loading &&
        _states.value.contains(WidgetState.hovered) &&
        vs?.backgroundHover != null) {
      return vs!.backgroundHover!;
    }
    if (vs?.background != null) return vs!.background!;
    final c = context.colors;
    switch (variant) {
      case OiButtonVariant.primary:
        return c.primary.base;
      case OiButtonVariant.secondary:
        return c.surfaceSubtle;
      case OiButtonVariant.outline:
        return const Color(0x00000000);
      case OiButtonVariant.ghost:
        return const Color(0x00000000);
      case OiButtonVariant.destructive:
        return c.error.base;
      case OiButtonVariant.soft:
        return c.primary.muted;
    }
  }

  Color _foregroundColor(BuildContext context, OiButtonVariant variant) {
    final vs = _variantStyle(_buttonTheme(context), variant);
    if (!widget.enabled && vs?.foregroundDisabled != null) {
      return vs!.foregroundDisabled!;
    }
    if (widget.enabled &&
        !widget.loading &&
        _states.value.contains(WidgetState.pressed) &&
        vs?.foregroundPressed != null) {
      return vs!.foregroundPressed!;
    }
    if (widget.enabled &&
        !widget.loading &&
        _states.value.contains(WidgetState.hovered) &&
        vs?.foregroundHover != null) {
      return vs!.foregroundHover!;
    }
    if (vs?.foreground != null) return vs!.foreground!;
    final c = context.colors;
    switch (variant) {
      case OiButtonVariant.primary:
        return c.primary.foreground;
      case OiButtonVariant.secondary:
        return c.text;
      case OiButtonVariant.outline:
        return c.text;
      case OiButtonVariant.ghost:
        return c.text;
      case OiButtonVariant.destructive:
        return c.error.foreground;
      case OiButtonVariant.soft:
        return c.primary.base;
    }
  }

  BoxDecoration _decoration(
    BuildContext context,
    OiButtonVariant variant, {
    BorderRadius? borderRadius,
  }) {
    final bt = _buttonTheme(context);
    final bg = _backgroundColor(context, variant);
    final themeRadius = bt?.borderRadius;
    final effectiveRadius = borderRadius ?? themeRadius ?? context.radius.sm;

    final vs = _variantStyle(bt, variant);
    final Border? border;
    final stateBorder = !widget.enabled
        ? vs?.borderDisabled
        : _states.value.contains(WidgetState.pressed)
        ? vs?.borderPressed
        : _states.value.contains(WidgetState.hovered)
        ? vs?.borderHover
        : null;
    if (stateBorder != null || vs?.border != null) {
      border = Border.all(color: stateBorder ?? vs!.border!);
    } else if (variant == OiButtonVariant.outline) {
      border = Border.all(color: context.colors.border);
    } else {
      border = null;
    }

    return BoxDecoration(
      color: bg,
      borderRadius: effectiveRadius,
      border: border,
    );
  }
}
