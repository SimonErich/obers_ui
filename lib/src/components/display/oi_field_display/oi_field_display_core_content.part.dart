part of '../oi_field_display.dart';

extension _OiFieldDisplayCoreContent on OiFieldDisplay {
  Widget _buildContent(BuildContext context) {
    if (formatValue != null) {
      return _wrapTooltip(_buildCustomFormatted(context));
    }

    if (_isEmpty && type != OiFieldType.boolean) {
      return _buildEmpty(context);
    }

    Widget content;
    switch (type) {
      case OiFieldType.text:
        content = _buildTextDisplay(context);
      case OiFieldType.number:
        content = _buildNumberDisplay(context);
      case OiFieldType.currency:
        content = _buildCurrencyDisplay(context);
      case OiFieldType.date:
        content = _buildDateDisplay(context);
      case OiFieldType.dateTime:
        content = _buildDateTimeDisplay(context);
      case OiFieldType.boolean:
        content = _buildBooleanDisplay(context);
      case OiFieldType.email:
        content = _buildEmailDisplay(context);
      case OiFieldType.url:
        content = _buildUrlDisplay(context);
      case OiFieldType.phone:
        content = _buildPhoneDisplay(context);
      case OiFieldType.file:
        content = _buildFileDisplay(context);
      case OiFieldType.image:
        content = _buildImageDisplay(context);
      case OiFieldType.select:
        content = _buildSelectDisplay(context);
      case OiFieldType.tags:
        content = _buildTagsDisplay(context);
      case OiFieldType.color:
        content = _buildColorDisplay(context);
      case OiFieldType.json:
        content = _buildJsonDisplay(context);
      case OiFieldType.custom:
        content = _buildTextDisplay(context);
      case OiFieldType.time:
      case OiFieldType.checkbox:
      case OiFieldType.switchField:
      case OiFieldType.radio:
      case OiFieldType.slider:
      case OiFieldType.tag:
        content = _buildTextDisplay(context);
    }

    return _wrapTooltip(content);
  }

  Widget _wrapTooltip(Widget child) {
    if (type == OiFieldType.color && !_isEmpty) {
      return OiTooltip(
        label: 'Color value',
        message: _valueString,
        child: child,
      );
    }

    if (maxLines != null && !_isEmpty) {
      return OiTooltip(
        label: label.isEmpty ? 'Full value' : label,
        message: _valueString,
        child: child,
      );
    }

    return child;
  }

  Widget _buildEmpty(BuildContext context) {
    final colors = context.colors;
    return OiLabel.small(emptyText, color: colors.textMuted);
  }

  Widget _buildCustomFormatted(BuildContext context) {
    try {
      final formatted = formatValue!(value);
      return OiLabel.small(
        formatted,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    } on Exception catch (_) {
      return OiLabel.small(
        _valueString,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }
  }

  Widget _buildTextDisplay(BuildContext context) {
    return OiLabel.small(
      _valueString,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}
