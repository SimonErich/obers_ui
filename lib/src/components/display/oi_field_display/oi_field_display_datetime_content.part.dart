part of '../oi_field_display.dart';

extension _OiFieldDisplayDateTimeContent on OiFieldDisplay {
  Widget _buildDateDisplay(BuildContext context) {
    final date = _parseDate();
    if (date == null) {
      assert(
        false,
        'OiFieldDisplay: date value is not a DateTime or parseable string',
      );
      return _buildTextDisplay(context);
    }
    final theme = context.components.fieldDisplay;
    return OiLabel.body(_formatDate(date), style: theme?.valueStyle);
  }

  Widget _buildDateTimeDisplay(BuildContext context) {
    final date = _parseDate();
    if (date == null) {
      assert(
        false,
        'OiFieldDisplay: dateTime value is not a DateTime or parseable string',
      );
      return _buildTextDisplay(context);
    }
    final theme = context.components.fieldDisplay;
    return OiLabel.body(_formatDateTime(date), style: theme?.valueStyle);
  }

  DateTime? _parseDate() {
    if (value is DateTime) return value as DateTime;
    if (value is String) return DateTime.tryParse(value as String);
    return null;
  }

  String _formatDate(DateTime date) {
    if (dateFormat != null) return DateFormat(dateFormat).format(date);
    return DateFormat.yMMMd().format(date);
  }

  String _formatDateTime(DateTime date) {
    if (dateFormat != null) return DateFormat(dateFormat).format(date);
    return DateFormat.yMMMd().add_jm().format(date);
  }
}
