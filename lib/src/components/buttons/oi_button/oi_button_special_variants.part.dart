part of '../oi_button.dart';

extension _OiButtonSpecialVariants on _OiButtonState {
  /// The hover state for a special button's label colour.
  ///
  /// Only ghost buttons react here: the other variants keep their resting
  /// foreground and rely on [OiTappable]'s background overlay for hover.
  _OiButtonVisualState _textHoverState(
    OiButtonVariant variant, {
    required bool active,
  }) {
    return variant == OiButtonVariant.ghost && active && _hovered
        ? _OiButtonVisualState.hovered
        : _OiButtonVisualState.normal;
  }

  Widget _buildSplitButton(BuildContext context) {
    final density = OiDensityScope.of(context);
    final height = context.components.button?.height ?? _buttonHeight(density);
    final hPad = _hPadding(context);
    final isGhost = widget.variant == OiButtonVariant.ghost;
    final foreground = _foregroundColor(
      context,
      widget.variant,
      state: _textHoverState(widget.variant, active: widget.enabled),
    );
    final bgColor = _backgroundColor(context, widget.variant);
    final borderRadius =
        context.components.button?.borderRadius ?? context.radius.sm;

    final leftRadius = BorderRadius.only(
      topLeft: borderRadius.topLeft,
      bottomLeft: borderRadius.bottomLeft,
    );
    final rightRadius = BorderRadius.only(
      topRight: borderRadius.topRight,
      bottomRight: borderRadius.bottomRight,
    );

    final mainPart = OiTappable(
      onTap: widget.onTap,
      onHover: _setHovered,
      enabled: widget.enabled,
      applyBackgroundOverlay: !isGhost,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        decoration: BoxDecoration(color: bgColor, borderRadius: leftRadius),
        child: Center(
          child: Text(
            widget.label ?? '',
            style: TextStyle(
              fontSize: _fontSize(context),
              fontWeight: _fontWeight(context),
              color: foreground,
              height: 1,
            ),
          ),
        ),
      ),
    );

    final chevronPart = OiTappable(
      onTap: widget.enabled ? _toggleDropdownVisible : null,
      onHover: _setHovered,
      enabled: widget.enabled,
      applyBackgroundOverlay: !isGhost,
      child: Container(
        height: height,
        width: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: rightRadius,
          border: Border(
            left: BorderSide(color: foreground.withValues(alpha: 0.3)),
          ),
        ),
        child: Center(
          child: Icon(OiIcons.arrowDown, size: _iconSize(), color: foreground),
        ),
      ),
    );

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [mainPart, chevronPart],
    );

    return OiFloating(
      visible: _dropdownVisible,
      alignment: OiFloatingAlignment.bottomEnd,
      anchor: row,
      child: widget.dropdown ?? const SizedBox(),
    );
  }

  Widget _buildCountdownButton(BuildContext context) {
    final isExpired = _remaining <= 0;
    final displayLabel = isExpired
        ? widget.label ?? ''
        : '${widget.label ?? ''} ($_remaining)';

    final density = OiDensityScope.of(context);
    final height = context.components.button?.height ?? _buttonHeight(density);
    final hPad = _hPadding(context);
    final foreground = _foregroundColor(
      context,
      widget.variant,
      state: _textHoverState(widget.variant, active: isExpired),
    );
    final decoration = _decoration(context, widget.variant);

    Widget button = OiTappable(
      onTap: widget.onTap,
      onHover: _setHovered,
      enabled: isExpired,
      applyBackgroundOverlay: widget.variant != OiButtonVariant.ghost,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        decoration: decoration,
        child: Center(
          widthFactor: 1,
          child: Text(
            displayLabel,
            style: TextStyle(
              fontSize: _fontSize(context),
              fontWeight: _fontWeight(context),
              color: foreground,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    } else {
      button = UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        child: button,
      );
    }
    return button;
  }

  Widget _buildConfirmButton(BuildContext context) {
    final density = OiDensityScope.of(context);
    final height = context.components.button?.height ?? _buttonHeight(density);
    final hPad = _hPadding(context);

    final activeVariant = _confirmPending
        ? OiButtonVariant.destructive
        : widget.variant;
    final displayLabel = _confirmPending
        ? (widget.confirmLabel ?? widget.label ?? '')
        : (widget.label ?? '');
    final foreground = _foregroundColor(
      context,
      activeVariant,
      state: _textHoverState(activeVariant, active: true),
    );
    final decoration = _decoration(context, activeVariant);

    Widget button = OiTappable(
      onHover: _setHovered,
      applyBackgroundOverlay: activeVariant != OiButtonVariant.ghost,
      onTap: () {
        if (_confirmPending) {
          _setConfirmPending(false);
          widget.onConfirm?.call();
        } else {
          _setConfirmPending(true);
        }
      },
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        decoration: decoration,
        child: Center(
          widthFactor: 1,
          child: Text(
            displayLabel,
            style: TextStyle(
              fontSize: _fontSize(context),
              fontWeight: _fontWeight(context),
              color: foreground,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    } else {
      button = UnconstrainedBox(
        constrainedAxis: Axis.vertical,
        child: button,
      );
    }
    return button;
  }
}
