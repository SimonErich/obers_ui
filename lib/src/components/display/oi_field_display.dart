import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_field_type.dart';
import 'package:obers_ui/src/primitives/clipboard/oi_copyable.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A universal read-only field renderer that formats values based on
/// [OiFieldType].
///
/// Supports 16 field types with appropriate formatting, icons, and link
/// behavior. Composes [OiLabel], [OiIcon], [OiImage], [OiBadge],
/// [OiTappable], [OiCopyable], and [OiTooltip].
///
/// Use [OiFieldDisplay.pair] to render a label + value side by side or
/// stacked, replicating shadcn-admin-kit's `<Show>` field list pattern.
///
/// {@category Components}
///
/// Coverage: REQ-0001
class OiFieldDisplay extends StatelessWidget {
  /// Creates an [OiFieldDisplay] that renders a single read-only value.
  const OiFieldDisplay({
    required this.value,
    this.type = OiFieldType.text,
    this.label,
    this.emptyText = '\u2014',
    this.copyable = false,
    this.maxLines,
    this.dateFormat,
    this.numberFormat,
    this.currencyCode,
    this.currencySymbol,
    this.decimalPlaces,
    this.choices,
    this.choiceColors,
    this.formatValue,
    this.onTap,
    this.leading,
    super.key,
  }) : _isPair = false,
       _direction = Axis.horizontal,
       _labelWidth = null;

  /// Creates a label + value pair layout.
  ///
  /// In [Axis.horizontal] mode the label sits to the left of the value;
  /// in [Axis.vertical] mode the label sits above. Use [labelWidth] in
  /// horizontal mode to align multiple pairs in a column.
  const OiFieldDisplay.pair({
    required String label,
    required this.value,
    this.type = OiFieldType.text,
    Axis direction = Axis.horizontal,
    double? labelWidth,
    this.emptyText = '\u2014',
    this.copyable = false,
    this.maxLines,
    this.dateFormat,
    this.numberFormat,
    this.currencyCode,
    this.currencySymbol,
    this.decimalPlaces,
    this.choices,
    this.choiceColors,
    this.formatValue,
    this.onTap,
    this.leading,
    super.key,
  }) : _isPair = true,
       _direction = direction,
       _labelWidth = labelWidth,
       label = label;

  /// The value to display. May be any type; the widget coerces it based on
  /// [type].
  final dynamic value;

  /// The field type that determines rendering.
  final OiFieldType type;

  /// An optional label displayed above or beside the value.
  final String? label;

  /// Text shown when [value] is null or empty.
  final String emptyText;

  /// Whether the displayed value can be copied to the clipboard on tap.
  final bool copyable;

  /// Maximum number of lines for text display before truncation.
  final int? maxLines;

  /// A date format pattern string (e.g. `'yyyy-MM-dd'`).
  final String? dateFormat;

  /// A number format pattern string.
  final String? numberFormat;

  /// ISO 4217 currency code (e.g. `'USD'`). Defaults to `'USD'` for
  /// [OiFieldType.currency].
  final String? currencyCode;

  /// Currency symbol (e.g. `'\$'`). When provided, takes precedence over
  /// [currencyCode] for display.
  final String? currencySymbol;

  /// Number of decimal places for number and currency formatting.
  final int? decimalPlaces;

  /// Maps raw select values to human-readable labels.
  final Map<String, String>? choices;

  /// Maps raw select values to badge colors for [OiFieldType.select].
  final Map<String, OiBadgeColor>? choiceColors;

  /// Custom formatting callback. When provided, its return value is displayed
  /// instead of the default format.
  final String Function(dynamic value)? formatValue;

  /// Called when the field value is tapped. Wraps content in [OiTappable].
  final VoidCallback? onTap;

  /// A widget displayed before the value content (e.g. an icon).
  final Widget? leading;

  final bool _isPair;
  final Axis _direction;
  final double? _labelWidth;

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get _isEmpty =>
      value == null || (value is String && (value as String).isEmpty);

  String get _valueString => value?.toString() ?? '';

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isPair) {
      return _buildPairLayout(context);
    }
    return _wrapInteraction(context, _buildContent(context));
  }

  Widget _buildPairLayout(BuildContext context) {
    final colors = context.colors;
    final labelWidget = OiLabel.small(
      label ?? '',
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

    // Horizontal layout
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
    Widget result = child;

    if (copyable && !_isEmpty) {
      result = OiCopyable(value: _valueString, child: result);
    }

    if (onTap != null) {
      result = OiTappable(
        onTap: onTap,
        semanticLabel: label ?? _valueString,
        child: result,
      );
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

  Widget _buildContent(BuildContext context) {
    // Custom formatter takes precedence.
    if (formatValue != null) {
      return _wrapTooltip(_buildCustomFormatted(context));
    }

    // Boolean type handles null as a distinct "unknown" state.
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
      // Form-only types fall back to text display.
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

  /// Wraps [child] in [OiTooltip] when truncation is possible (maxLines set)
  /// or when the field type is color (to show hex code on swatch hover).
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
        label: label ?? 'Full value',
        message: _valueString,
        child: child,
      );
    }

    return child;
  }

  // ── Type renderers ────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
    final colors = context.colors;
    return OiLabel.small(emptyText, color: colors.textMuted);
  }

  Widget _buildCustomFormatted(BuildContext context) {
    try {
      final formatted = formatValue!(value);
      return OiLabel.body(
        formatted,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    } catch (_) {
      return OiLabel.body(
        _valueString,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }
  }

  Widget _buildTextDisplay(BuildContext context) {
    return OiLabel.body(
      _valueString,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  Widget _buildNumberDisplay(BuildContext context) {
    final num? numValue = value is num
        ? value as num
        : num.tryParse(_valueString);

    if (numValue == null) {
      return _buildTextDisplay(context);
    }

    final formatted = _formatNumber(numValue);
    return OiLabel.body(formatted);
  }

  /// Formats a number using [numberFormat] pattern if provided, falling back
  /// to [NumberFormat.decimalPattern] with grouping separators.
  String _formatNumber(num numValue) {
    if (numberFormat != null) {
      try {
        return NumberFormat(numberFormat).format(numValue);
      } catch (_) {
        // Invalid pattern — fall through to default formatting.
      }
    }
    final places = decimalPlaces ?? 0;
    final formatter = NumberFormat.decimalPattern()
      ..minimumFractionDigits = places
      ..maximumFractionDigits = places;
    return formatter.format(numValue);
  }

  Widget _buildCurrencyDisplay(BuildContext context) {
    final num? numValue = value is num
        ? value as num
        : num.tryParse(_valueString);

    if (numValue == null) {
      return _buildTextDisplay(context);
    }

    final symbol = currencySymbol ?? '';
    final code = currencyCode ?? (currencySymbol == null ? 'USD' : '');
    final formatted = _formatCurrencyNumber(numValue);

    final parts = <String>[];
    if (symbol.isNotEmpty) parts.add(symbol);
    parts.add(formatted);
    if (code.isNotEmpty && symbol.isEmpty) parts.add(code);

    return OiLabel.body(parts.join(symbol.isNotEmpty ? '' : ' '));
  }

  /// Formats a currency number using [numberFormat] pattern if provided,
  /// falling back to [NumberFormat.decimalPattern] with grouping separators.
  String _formatCurrencyNumber(num numValue) {
    if (numberFormat != null) {
      try {
        return NumberFormat(numberFormat).format(numValue);
      } catch (_) {
        // Invalid pattern — fall through to default formatting.
      }
    }
    final places = decimalPlaces ?? 2;
    final formatter = NumberFormat.decimalPattern()
      ..minimumFractionDigits = places
      ..maximumFractionDigits = places;
    return formatter.format(numValue);
  }

  Widget _buildDateDisplay(BuildContext context) {
    final DateTime? date = _parseDate();
    if (date == null) {
      assert(
        false,
        'OiFieldDisplay: date value is not a DateTime or parseable string',
      );
      return _buildTextDisplay(context);
    }

    final formatted = _formatDate(date);
    return OiLabel.body(formatted);
  }

  Widget _buildDateTimeDisplay(BuildContext context) {
    final DateTime? date = _parseDate();
    if (date == null) {
      assert(
        false,
        'OiFieldDisplay: dateTime value is not a DateTime or parseable string',
      );
      return _buildTextDisplay(context);
    }

    final formatted = _formatDateTime(date);
    return OiLabel.body(formatted);
  }

  Widget _buildBooleanDisplay(BuildContext context) {
    final colors = context.colors;

    // Handle null as a distinct third state.
    if (value == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OiIcon.decorative(
            icon: const IconData(
              0xe15b,
              fontFamily: 'MaterialIcons',
            ), // remove (dash)
            color: colors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 4),
          OiLabel.body('Unknown', color: colors.textMuted),
        ],
      );
    }

    final bool boolValue;
    if (value is bool) {
      boolValue = value as bool;
    } else {
      // Coerce via truthiness.
      boolValue = value != 0 && value != '' && value != false;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiIcon.decorative(
          icon: boolValue
              ? const IconData(0xf00c, fontFamily: 'MaterialIcons') // check
              : const IconData(0xe16a, fontFamily: 'MaterialIcons'), // close
          color: boolValue ? colors.success.base : colors.error.base,
          size: 18,
        ),
        const SizedBox(width: 4),
        OiLabel.body(boolValue ? 'Yes' : 'No'),
      ],
    );
  }

  Widget _buildEmailDisplay(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiIcon.decorative(
          icon: const IconData(0xe22a, fontFamily: 'MaterialIcons'), // mail
          color: colors.textMuted,
          size: 16,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: OiLabel.body(
            _valueString,
            color: colors.primary.base,
            decoration: TextDecoration.underline,
            decorationColor: colors.primary.base,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUrlDisplay(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiIcon.decorative(
          icon: const IconData(0xe157, fontFamily: 'MaterialIcons'), // link
          color: colors.textMuted,
          size: 16,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: OiLabel.body(
            _valueString,
            color: colors.primary.base,
            decoration: TextDecoration.underline,
            decorationColor: colors.primary.base,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneDisplay(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiIcon.decorative(
          icon: const IconData(0xe4a2, fontFamily: 'MaterialIcons'), // phone
          color: colors.textMuted,
          size: 16,
        ),
        const SizedBox(width: 6),
        OiLabel.body(_valueString, color: colors.primary.base),
      ],
    );
  }

  Widget _buildFileDisplay(BuildContext context) {
    final colors = context.colors;

    String filename;
    String? sizeLabel;

    if (value is Map) {
      final map = value as Map;
      filename = (map['name'] ?? '').toString();
      if (map.containsKey('size') && map['size'] is num) {
        sizeLabel = _formatFileSize((map['size'] as num).toInt());
      }
    } else {
      // Extract filename from path.
      filename = _valueString.split('/').last.split('\\').last;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiIcon.decorative(
          icon: const IconData(
            0xe873,
            fontFamily: 'MaterialIcons',
          ), // insert_drive_file
          color: colors.textMuted,
          size: 16,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: OiLabel.body(
            filename,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (sizeLabel != null) ...[
          const SizedBox(width: 6),
          OiLabel.small(sizeLabel, color: colors.textMuted),
        ],
      ],
    );
  }

  /// Formats a file size in bytes to a human-readable string.
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildImageDisplay(BuildContext context) {
    return OiImage(
      src: _valueString,
      alt: label ?? 'Image',
      width: 64,
      height: 64,
      fit: BoxFit.cover,
    );
  }

  Widget _buildSelectDisplay(BuildContext context) {
    final stringValue = _valueString;
    final displayLabel = choices?[stringValue] ?? stringValue;

    if (choiceColors != null || choices != null) {
      final badgeColor = choiceColors?[stringValue] ?? OiBadgeColor.neutral;
      return OiBadge.soft(label: displayLabel, color: badgeColor);
    }

    return OiLabel.body(displayLabel);
  }

  Widget _buildTagsDisplay(BuildContext context) {
    final List<String> tagList;
    if (value is List) {
      tagList = (value as List).map((e) => e.toString()).toList();
    } else {
      tagList = [_valueString];
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tagList
          .map((tag) => OiBadge.soft(label: tag, color: OiBadgeColor.neutral))
          .toList(),
    );
  }

  Widget _buildColorDisplay(BuildContext context) {
    final hex = _valueString.replaceFirst('#', '');
    final parsed = int.tryParse(hex, radix: 16);

    if (parsed == null) {
      return _buildTextDisplay(context);
    }

    final color = Color(parsed | 0xFF000000);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0x33000000)),
          ),
        ),
        const SizedBox(width: 8),
        OiLabel.body('#$hex'),
      ],
    );
  }

  Widget _buildJsonDisplay(BuildContext context) {
    String formatted;
    try {
      final encoded = value is String ? jsonDecode(value as String) : value;
      formatted = const JsonEncoder.withIndent('  ').convert(encoded);
    } catch (_) {
      formatted = _valueString;
    }

    return OiLabel.code(
      formatted,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  // ── Date helpers ──────────────────────────────────────────────────────────

  DateTime? _parseDate() {
    if (value is DateTime) return value as DateTime;
    if (value is String) return DateTime.tryParse(value as String);
    return null;
  }

  String _formatDate(DateTime date) {
    if (dateFormat != null) {
      return _applyDateFormat(date, dateFormat!);
    }
    // Default: yyyy-MM-dd
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDateTime(DateTime date) {
    if (dateFormat != null) {
      return _applyDateFormat(date, dateFormat!);
    }
    // Default: yyyy-MM-dd HH:mm
    final datePart = _formatDate(date);
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$datePart $h:$min';
  }

  String _applyDateFormat(DateTime date, String format) {
    // Simple pattern replacement without intl package.
    return format
        .replaceAll('yyyy', date.year.toString().padLeft(4, '0'))
        .replaceAll('yy', (date.year % 100).toString().padLeft(2, '0'))
        .replaceAll('MM', date.month.toString().padLeft(2, '0'))
        .replaceAll('dd', date.day.toString().padLeft(2, '0'))
        .replaceAll('HH', date.hour.toString().padLeft(2, '0'))
        .replaceAll('mm', date.minute.toString().padLeft(2, '0'))
        .replaceAll('ss', date.second.toString().padLeft(2, '0'));
  }
}
