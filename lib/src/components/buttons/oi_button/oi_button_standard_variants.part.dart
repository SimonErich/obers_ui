part of '../oi_button.dart';

extension _OiButtonStandardVariants on _OiButtonState {
  Widget _buildStandardButton(BuildContext context) {
    if (widget.variant == OiButtonVariant.ghost) {
      return _buildGhostButton(context);
    }

    final density = OiDensityScope.of(context);
    final bt = context.components.button;
    final height = bt?.height ?? _buttonHeight(density);
    final hPad = _hPadding(context);
    final foreground = _foregroundColor(context, widget.variant);
    final themeRadius = bt?.borderRadius;
    final effectiveRadius =
        widget.borderRadius ?? themeRadius ?? context.radius.sm;
    final decoration = _decoration(
      context,
      widget.variant,
      borderRadius: widget.borderRadius,
    );
    final isActive = widget.enabled && !widget.loading;

    Widget button = OiTappable(
      onTap: isActive ? widget.onTap : null,
      enabled: isActive,
      semanticLabel: widget.semanticLabel ?? widget.label,
      clipBorderRadius: effectiveRadius,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.4,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          decoration: decoration,
          child: Center(
            widthFactor: 1.0,
            child: _buildContent(
              context,
              label: widget.label,
              icon: widget.icon,
              iconPosition: widget.iconPosition,
              foreground: foreground,
              loading: widget.loading,
            ),
          ),
        ),
      ),
    );

    if (bt?.minWidth != null) {
      button = ConstrainedBox(
        constraints: BoxConstraints(minWidth: bt!.minWidth!),
        child: button,
      );
    }
    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    } else {
      button = UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        child: button,
      );
    }
    if (widget.tooltip != null) {
      return OiTooltip(
        label: widget.tooltip!,
        message: widget.tooltip!,
        child: button,
      );
    }
    return button;
  }

  Widget _buildGhostButton(BuildContext context) {
    final density = OiDensityScope.of(context);
    final bt = context.components.button;
    final height = bt?.height ?? _buttonHeight(density);
    final hPad = _hPadding(context);
    final foreground = _foregroundColor(context, widget.variant);
    final isActive = widget.enabled && !widget.loading;

    Widget content = Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Center(
        widthFactor: 1.0,
        child: _buildContent(
          context,
          label: widget.label,
          icon: widget.icon,
          iconPosition: widget.iconPosition,
          foreground: foreground,
          loading: widget.loading,
          bold: _highlighted,
        ),
      ),
    );

    if (!widget.enabled) {
      content = Opacity(opacity: 0.4, child: content);
    }

    content = GestureDetector(
      onTap: isActive ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: content,
    );

    content = MouseRegion(
      cursor: isActive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isActive) _setHighlighted(true);
      },
      onExit: (_) => _setHighlighted(false),
      child: content,
    );

    content = Focus(
      canRequestFocus: isActive,
      onFocusChange: (focused) {
        _setHighlighted(focused);
      },
      child: content,
    );

    if (widget.semanticLabel != null) {
      content = Semantics(
        label: widget.semanticLabel,
        button: true,
        enabled: widget.enabled,
        child: content,
      );
    }

    Widget button = content;

    if (bt?.minWidth != null) {
      button = ConstrainedBox(
        constraints: BoxConstraints(minWidth: bt!.minWidth!),
        child: button,
      );
    }
    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    } else {
      button = UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        child: button,
      );
    }
    if (widget.tooltip != null) {
      return OiTooltip(
        label: widget.tooltip!,
        message: widget.tooltip!,
        child: button,
      );
    }
    return button;
  }

  Widget _buildIconButton(BuildContext context) {
    final density = OiDensityScope.of(context);
    final height = context.components.button?.height ?? _buttonHeight(density);
    final foreground = _foregroundColor(context, widget.variant);
    final highlightColor = context.colors.primary.base;
    final isActive = widget.enabled && !widget.loading;
    final iconSize = _iconSize();
    final highlightedSize = iconSize + 2;

    Widget content = SizedBox(
      width: height,
      height: height,
      child: Center(
        child: Icon(
          widget.icon,
          size: _highlighted ? highlightedSize : iconSize,
          color: _highlighted ? highlightColor : foreground,
        ),
      ),
    );

    if (!widget.enabled) {
      content = Opacity(opacity: 0.4, child: content);
    }

    content = GestureDetector(
      onTap: isActive ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: content,
    );

    content = MouseRegion(
      cursor: isActive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isActive) _setHighlighted(true);
      },
      onExit: (_) => _setHighlighted(false),
      child: content,
    );

    content = Focus(
      canRequestFocus: isActive,
      onFocusChange: (focused) {
        _setHighlighted(focused);
      },
      child: content,
    );

    if (widget.semanticLabel != null) {
      content = Semantics(
        label: widget.semanticLabel,
        button: true,
        enabled: widget.enabled,
        child: content,
      );
    }

    return content;
  }
}
