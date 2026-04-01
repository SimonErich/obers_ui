part of '../oi_field_display.dart';

extension _OiFieldDisplayNumericContent on OiFieldDisplay {
  Widget _buildNumberDisplay(BuildContext context) {
    final numValue = value is num ? value as num : num.tryParse(_valueString);
    if (numValue == null) return _buildTextDisplay(context);
    return OiLabel.small(_formatNumber(numValue));
  }

  String _formatNumber(num numValue) {
    if (numberFormat != null) {
      try {
        return NumberFormat(numberFormat).format(numValue);
      } on Exception catch (_) {}
    }
    final places = decimalPlaces ?? 0;
    final formatter = NumberFormat.decimalPattern()
      ..minimumFractionDigits = places
      ..maximumFractionDigits = places;
    return formatter.format(numValue);
  }

  Widget _buildCurrencyDisplay(BuildContext context) {
    final numValue = value is num ? value as num : num.tryParse(_valueString);
    if (numValue == null) return _buildTextDisplay(context);

    final symbol = currencySymbol ?? '';
    final code = currencyCode ?? (currencySymbol == null ? 'USD' : '');
    final formatted = _formatCurrencyNumber(numValue);

    final parts = <String>[];
    if (symbol.isNotEmpty) parts.add(symbol);
    parts.add(formatted);
    if (code.isNotEmpty && symbol.isEmpty) parts.add(code);

    return OiLabel.small(parts.join(symbol.isNotEmpty ? '' : ' '));
  }

  String _formatCurrencyNumber(num numValue) {
    if (numberFormat != null) {
      try {
        return NumberFormat(numberFormat).format(numValue);
      } on Exception catch (_) {}
    }
    final places = decimalPlaces ?? 2;
    final formatter = NumberFormat.decimalPattern()
      ..minimumFractionDigits = places
      ..maximumFractionDigits = places;
    return formatter.format(numValue);
  }
}
