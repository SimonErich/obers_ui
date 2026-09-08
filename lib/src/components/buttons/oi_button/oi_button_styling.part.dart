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

  /// Resolves the per-state override for [state] from [vs], falling back to
  /// the variant's default colour when the theme leaves it unset.
  ///
  /// Disabled wins over hovered when both apply, since a disabled button never
  /// reacts to the pointer.
  Color? _stateOverride(
    OiButtonVariantStyle? vs,
    _OiButtonVisualState state, {
    required Color? Function(OiButtonVariantStyle vs) hovered,
    required Color? Function(OiButtonVariantStyle vs) disabled,
  }) {
    if (vs == null) return null;
    switch (state) {
      case _OiButtonVisualState.disabled:
        return disabled(vs);
      case _OiButtonVisualState.hovered:
        return hovered(vs);
      case _OiButtonVisualState.normal:
        return null;
    }
  }

  Color _backgroundColor(
    BuildContext context,
    OiButtonVariant variant, {
    _OiButtonVisualState state = _OiButtonVisualState.normal,
  }) {
    final vs = _variantStyle(context.components.button, variant);
    final override = _stateOverride(
      vs,
      state,
      hovered: (s) => s.backgroundHover,
      disabled: (s) => s.backgroundDisabled,
    );
    if (override != null) return override;
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

  Color _foregroundColor(
    BuildContext context,
    OiButtonVariant variant, {
    _OiButtonVisualState state = _OiButtonVisualState.normal,
  }) {
    final vs = _variantStyle(context.components.button, variant);
    final override = _stateOverride(
      vs,
      state,
      hovered: (s) => s.foregroundHover,
      disabled: (s) => s.foregroundDisabled,
    );
    if (override != null) return override;
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
    _OiButtonVisualState state = _OiButtonVisualState.normal,
  }) {
    final bt = context.components.button;
    final bg = _backgroundColor(context, variant, state: state);
    final themeRadius = bt?.borderRadius;
    final effectiveRadius = borderRadius ?? themeRadius ?? context.radius.sm;

    final vs = _variantStyle(bt, variant);
    final borderOverride = _stateOverride(
      vs,
      state,
      hovered: (s) => s.borderHover,
      disabled: (s) => s.borderDisabled,
    );
    final Border? border;
    if (borderOverride != null) {
      border = Border.all(color: borderOverride);
    } else if (vs?.border != null) {
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
