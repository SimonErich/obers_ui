import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_code_block.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_field_type.dart';
import 'package:obers_ui/src/primitives/clipboard/oi_copyable.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

part 'oi_field_display/oi_field_display_layout.part.dart';
part 'oi_field_display/oi_field_display_core_content.part.dart';
part 'oi_field_display/oi_field_display_numeric_content.part.dart';
part 'oi_field_display/oi_field_display_datetime_content.part.dart';
part 'oi_field_display/oi_field_display_status_contact_content.part.dart';
part 'oi_field_display/oi_field_display_asset_content.part.dart';

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
/// Coverage: REQ-0008
class OiFieldDisplay extends StatelessWidget {
  /// Creates an [OiFieldDisplay] that renders a single read-only value.
  const OiFieldDisplay({
    required this.label,
    required this.value,
    this.type = OiFieldType.text,
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
    required this.label,
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
       _labelWidth = labelWidth ?? 120.0;

  /// The value to display. May be any type; the widget coerces it based on
  /// [type].
  final dynamic value;

  /// The field type that determines rendering.
  final OiFieldType type;

  /// Accessibility label for the field. Required for a11y compliance.
  final String label;

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
    final Widget child;
    if (_isPair) {
      child = _buildPairLayout(context);
    } else {
      child = _wrapInteraction(context, _buildContent(context));
    }
    return Semantics(label: label, child: child);
  }
}
