part of '../oi_button.dart';

extension _OiButtonStandardVariants on _OiButtonState {
  Widget _buildStandardButton(BuildContext context) {
    if (widget.variant == OiButtonVariant.ghost) {
      return _buildGhostButton(context);
    }

    final density = OiDensityScope.of(context);
    final bt = context.components.button;
    final height = bt?.height ?? _buttonHeight(density);
    final padding = _padding(context);
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
      statesController: _states,
      applyBackgroundOverlay: !_usesStateBackground(context),
      onTap: isActive ? widget.onTap : null,
      enabled: isActive,
      disabledOpacity: 1,
      semanticLabel: widget.semanticLabel ?? widget.label,
      clipBorderRadius: effectiveRadius,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.4,
          child: Container(
            height: height,
            padding: padding,
            decoration: decoration,
            child: Center(
              widthFactor: 1,
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
        excludeFromSemantics:
            widget.tooltip == (widget.semanticLabel ?? widget.label),
        child: button,
      );
    }
    return button;
  }

  Widget _buildGhostButton(BuildContext context) {
    final density = OiDensityScope.of(context);
    final bt = context.components.button;
    final height = bt?.height ?? _buttonHeight(density);
    final padding = _padding(context);
    final foreground = _foregroundColor(context, widget.variant);
    final isActive = widget.enabled && !widget.loading;

    Widget content = Container(
      height: height,
      padding: padding,
      decoration: _decoration(
        context,
        widget.variant,
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        widthFactor: 1,
        child: _buildContent(
          context,
          label: widget.label,
          icon: widget.icon,
          iconPosition: widget.iconPosition,
          foreground: foreground,
          loading: widget.loading,
        ),
      ),
    );

    if (!widget.enabled) {
      content = Opacity(opacity: 0.4, child: content);
    }

    content = OiTappable(
      statesController: _states,
      applyBackgroundOverlay: !_usesStateBackground(context),
      onTap: isActive ? widget.onTap : null,
      enabled: isActive,
      disabledOpacity: 1,
      semanticLabel: widget.semanticLabel ?? widget.label,
      clipBorderRadius:
          widget.borderRadius ?? bt?.borderRadius ?? context.radius.sm,
      child: ExcludeSemantics(child: content),
    );

    var button = content;

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
        excludeFromSemantics:
            widget.tooltip == (widget.semanticLabel ?? widget.label),
        child: button,
      );
    }
    return button;
  }

  Widget _buildIconButton(BuildContext context) {
    final density = OiDensityScope.of(context);
    final height = context.components.button?.height ?? _buttonHeight(density);
    final foreground = _foregroundColor(context, widget.variant);
    final isActive = widget.enabled && !widget.loading;
    final iconSize = context.components.button?.iconSize ?? _iconSize();

    final radius =
        widget.borderRadius ??
        context.components.button?.borderRadius ??
        context.radius.sm;
    Widget content = Container(
      width: height,
      height: height,
      decoration: _decoration(
        context,
        widget.variant,
        borderRadius: widget.borderRadius,
      ),
      child: Center(
        child: OiIcon.raw(
          widget.icon,
          size: iconSize,
          color: foreground,
        ),
      ),
    );

    if (!widget.enabled) {
      content = Opacity(opacity: 0.4, child: content);
    }

    content = OiTappable(
      statesController: _states,
      applyBackgroundOverlay: !_usesStateBackground(context),
      onTap: isActive ? widget.onTap : null,
      enabled: isActive,
      disabledOpacity: 1,
      semanticLabel: widget.semanticLabel ?? widget.label,
      clipBorderRadius: radius,
      child: ExcludeSemantics(child: content),
    );

    // Keep the icon control's explicit square geometry even when input
    // modality changes. The interaction layer must fit the same constraints
    // as the visible control (including compact table and quantity actions).
    return SizedBox(width: height, height: height, child: content);
  }
}
