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

extension _OiButtonStyling on _OiButtonState {
  double _buttonHeight(OiDensity density) {
    switch (widget.size) {
      case OiButtonSize.small:
        switch (density) {
          case OiDensity.comfortable:
            return 28;
          case OiDensity.compact:
            return 24;
          case OiDensity.dense:
            return 20;
        }
      case OiButtonSize.medium:
        switch (density) {
          case OiDensity.comfortable:
            return 36;
          case OiDensity.compact:
            return 32;
          case OiDensity.dense:
            return 28;
        }
      case OiButtonSize.large:
        switch (density) {
          case OiDensity.comfortable:
            return 44;
          case OiDensity.compact:
            return 40;
          case OiDensity.dense:
            return 36;
        }
    }
  }

  double _iconSize() {
    switch (widget.size) {
      case OiButtonSize.small:
        return 14;
      case OiButtonSize.medium:
        return 16;
      case OiButtonSize.large:
        return 18;
    }
  }

  double _fontSize() {
    switch (widget.size) {
      case OiButtonSize.small:
        return 12;
      case OiButtonSize.medium:
        return 14;
      case OiButtonSize.large:
        return 16;
    }
  }

  double _hPadding(BuildContext context) {
    final sp = context.spacing;
    switch (widget.size) {
      case OiButtonSize.small:
        return sp.sm;
      case OiButtonSize.medium:
        return sp.md;
      case OiButtonSize.large:
        return sp.lg;
    }
  }

  Color _backgroundColor(BuildContext context, OiButtonVariant variant) {
    final vs = _variantStyle(context.components.button, variant);
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
    final vs = _variantStyle(context.components.button, variant);
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
    final bt = context.components.button;
    final bg = _backgroundColor(context, variant);
    final themeRadius = bt?.borderRadius;
    final effectiveRadius = borderRadius ?? themeRadius ?? context.radius.sm;

    final vs = _variantStyle(bt, variant);
    final Border? border;
    if (vs?.border != null) {
      border = Border.all(color: vs!.border!);
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
