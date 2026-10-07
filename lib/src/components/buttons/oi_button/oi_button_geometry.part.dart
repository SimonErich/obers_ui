part of '../oi_button.dart';

extension _OiButtonGeometry on _OiButtonState {
  double _buttonHeight(OiDensity density) {
    final theme = _buttonTheme(context);
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

  OiButtonSizeStyle? _sizeStyle(BuildContext context) => switch (widget.size) {
    OiButtonSize.small => _buttonTheme(context)?.sizeStyles?.small,
    OiButtonSize.medium => _buttonTheme(context)?.sizeStyles?.medium,
    OiButtonSize.large => _buttonTheme(context)?.sizeStyles?.large,
  };

  double _fontSize(BuildContext context) {
    final scale = _buttonTheme(context)?.fontSizes;
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
    final scale = _buttonTheme(context)?.fontSizes;
    switch (widget.size) {
      case OiButtonSize.small:
        return scale?.weightSmall ?? FontWeight.w500;
      case OiButtonSize.medium:
        return scale?.weightMedium ?? FontWeight.w500;
      case OiButtonSize.large:
        return scale?.weightLarge ?? FontWeight.w500;
    }
  }

  TextStyle _labelStyle(BuildContext context, Color foreground) {
    final theme = _buttonTheme(context);
    final legacy = context.textTheme.body
        .merge(theme?.textStyle)
        .copyWith(
          fontSize: theme?.textStyle?.fontSize ?? _fontSize(context),
          fontWeight: theme?.textStyle?.fontWeight ?? _fontWeight(context),
          color: foreground,
          height: 1,
        );
    final selected = _sizeStyle(context);
    if (selected?.textStyle == null) return legacy;
    final merged = legacy.merge(selected!.textStyle);
    return merged.foreground == null
        ? merged.copyWith(color: foreground)
        : merged.copyWith(foreground: Paint()..color = foreground);
  }

  EdgeInsetsGeometry _padding(BuildContext context) {
    if (_sizeStyle(context)?.iconLabelPadding case final padding?
        when widget.icon != null && widget.label != null) {
      return widget.iconPosition == OiIconPosition.leading
          ? padding
          : EdgeInsetsDirectional.fromSTEB(
              padding.end,
              padding.top,
              padding.start,
              padding.bottom,
            );
    }
    if (_sizeStyle(context)?.padding case final padding?) return padding;
    if (_buttonTheme(context)?.iconLabelPadding case final padding?
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
    if (_buttonTheme(context)?.padding case final padding?) return padding;
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
}
