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
    final theme = context.components.button;
    final configured = switch (widget.size) {
      OiButtonSize.small => theme?.smallHeight,
      OiButtonSize.medium => theme?.mediumHeight,
      OiButtonSize.large => theme?.largeHeight,
    };
    if (configured != null) return configured;
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

  double _fontSize(BuildContext context) {
    final scale = context.components.button?.fontSizes;
    switch (widget.size) {
      case OiButtonSize.small:
        return scale?.small ?? 12;
      case OiButtonSize.medium:
        return scale?.medium ?? 14;
      case OiButtonSize.large:
        return scale?.large ?? 16;
    }
  }

  FontWeight _fontWeight(BuildContext context) {
    final scale = context.components.button?.fontSizes;
    switch (widget.size) {
      case OiButtonSize.small:
        return scale?.weightSmall ?? FontWeight.w500;
      case OiButtonSize.medium:
        return scale?.weightMedium ?? FontWeight.w500;
      case OiButtonSize.large:
        return scale?.weightLarge ?? FontWeight.w500;
    }
  }

  EdgeInsetsGeometry _padding(BuildContext context) {
    if (context.components.button?.iconLabelPadding case final padding?
        when widget.size != OiButtonSize.small &&
            widget.icon != null &&
            widget.label != null) {
      return widget.iconPosition == OiIconPosition.leading
          ? padding
          : EdgeInsetsDirectional.fromSTEB(
              padding.end,
              padding.top,
              padding.start,
              padding.bottom,
            );
    }
    if (context.components.button?.padding case final padding?) return padding;
    final sp = context.spacing;
    switch (widget.size) {
      case OiButtonSize.small:
        return EdgeInsets.symmetric(horizontal: sp.sm);
      case OiButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: sp.md);
      case OiButtonSize.large:
        return EdgeInsets.symmetric(horizontal: sp.lg);
    }
  }

  Color _backgroundColor(BuildContext context, OiButtonVariant variant) {
    final vs = _variantStyle(context.components.button, variant);
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
    final vs = _variantStyle(context.components.button, variant);
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
    final bt = context.components.button;
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
