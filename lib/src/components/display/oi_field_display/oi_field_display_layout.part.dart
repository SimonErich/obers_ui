part of '../oi_field_display.dart';

extension _OiFieldDisplayLayout on OiFieldDisplay {
  Widget _buildPairLayout(BuildContext context) {
    final colors = context.colors;
    final labelWidget = OiLabel.smallStrong(
      label,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    final valueWidget = _wrapInteraction(context, _buildContent(context));

    if (_direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DefaultTextStyle(
            style: TextStyle(color: colors.textMuted),
            child: labelWidget,
          ),
          const SizedBox(height: 4),
          valueWidget,
        ],
      );
    }

    final labelChild = DefaultTextStyle(
      style: TextStyle(color: colors.textMuted),
      child: labelWidget,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_labelWidth != null)
          SizedBox(width: _labelWidth, child: labelChild)
        else
          labelChild,
        if (_labelWidth == null) const SizedBox(width: 8),
        Expanded(child: valueWidget),
      ],
    );
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
