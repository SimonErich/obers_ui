part of '../oi_field_display.dart';

extension _OiFieldDisplayLayout on OiFieldDisplay {
  Widget _buildPairLayout(BuildContext context) {
    final colors = context.colors;
    final theme = context.components.fieldDisplay;
    final pairGap = theme?.pairGap ?? 4.0;
    final labelStyle = theme?.labelStyle;
    final labelWidget = OiLabel.variant(
      label,
      variant: OiLabelVariant.small,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      color: labelStyle?.color ?? colors.textSubtle,
      style: labelStyle,
    );

    final valueWidget = _wrapInteraction(context, _buildContent(context));

    Widget content;
    if (_direction == Axis.vertical) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          labelWidget,
          SizedBox(height: pairGap),
          valueWidget,
        ],
      );
    } else {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_labelWidth != null)
            SizedBox(width: _labelWidth, child: labelWidget)
          else
            labelWidget,
          if (_labelWidth == null) SizedBox(width: pairGap + 4),
          Expanded(child: valueWidget),
        ],
      );
    }

    final padding = theme?.padding;
    if (padding == null) return content;
    return Padding(padding: padding, child: content);
  }

  Widget _wrapInteraction(BuildContext context, Widget child) {
    var result = child;

    if (copyable && !_isEmpty) {
      result = OiCopyable(value: _valueString, child: result);
    }

    if (onTap != null) {
      result = OiTappable(onTap: onTap, semanticLabel: label, child: result);
    }

    if (leading != null) {
      result = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading!,
          const SizedBox(width: 6),
          Flexible(child: result),
        ],
      );
    }

    return result;
  }
}
