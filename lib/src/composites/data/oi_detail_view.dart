import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/components/display/oi_field_display.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_field_type.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';

/// A field entry within an [OiDetailSection].
///
/// {@category Composites}
///
/// Coverage: REQ-0015, REQ-0026
@immutable
class OiDetailField {
  /// Creates an [OiDetailField].
  const OiDetailField({
    required this.label,
    required this.value,
    this.type = OiFieldType.text,
    this.columnSpan = 1,
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
  });

  /// The label displayed beside the value.
  final String label;

  /// The value to display.
  final dynamic value;

  /// The field type that determines rendering.
  final OiFieldType type;

  /// Number of columns this field spans in a multi-column layout.
  final int columnSpan;

  /// Whether the value can be copied to the clipboard.
  final bool copyable;

  /// Maximum number of text lines before truncation.
  final int? maxLines;

  /// Date format pattern string.
  final String? dateFormat;

  /// Number format pattern string.
  final String? numberFormat;

  /// ISO 4217 currency code.
  final String? currencyCode;

  /// Currency symbol.
  final String? currencySymbol;

  /// Decimal places for number/currency formatting.
  final int? decimalPlaces;

  /// Maps select values to display labels.
  final Map<String, String>? choices;

  /// Maps select values to badge colors.
  final Map<String, OiBadgeColor>? choiceColors;

  /// Custom value formatter.
  final String Function(dynamic value)? formatValue;

  /// Called when the field value is tapped.
  final VoidCallback? onTap;

  /// Widget displayed before the value.
  final Widget? leading;
}

/// A titled group of [OiDetailField] entries within an [OiDetailView].
///
/// {@category Composites}
///
/// Coverage: REQ-0015, REQ-0026
@immutable
class OiDetailSection {
  /// Creates an [OiDetailSection].
  const OiDetailSection({required this.fields, this.title});

  /// Optional section heading.
  final String? title;

  /// The fields in this section.
  final List<OiDetailField> fields;
}

/// A read-only record detail layout that renders [OiFieldDisplay.pair]
/// widgets in a structured layout with sections.
///
/// Supports single-column and two-column grid layouts with configurable
/// [columnGap] and [rowGap]. Composes [OiColumn], [OiFieldDisplay.pair],
/// [OiLabel], [OiDivider], [OiCard], [OiSurface].
///
/// {@category Composites}
///
/// Coverage: REQ-0015, REQ-0026
class OiDetailView extends StatelessWidget {
  /// Creates an [OiDetailView].
  const OiDetailView({
    required this.sections,
    this.label,
    this.columns = 1,
    this.columnGap = 16.0,
    this.rowGap = 12.0,
    this.fieldDirection = Axis.horizontal,
    this.labelWidth,
    this.emptyText = '\u2014',
    this.showDividers = true,
    this.wrapInCard = true,
    this.padding,
    super.key,
  });

  /// The sections of fields to render.
  final List<OiDetailSection> sections;

  /// Semantic label for the detail view.
  final String? label;

  /// Number of columns in the grid layout.
  final int columns;

  /// Horizontal gap between columns.
  final double columnGap;

  /// Vertical gap between rows.
  final double rowGap;

  /// Direction for label/value pairs within each field.
  final Axis fieldDirection;

  /// Default label width for horizontal field pairs.
  final double? labelWidth;

  /// Text shown for null or empty values.
  final String emptyText;

  /// Whether to render dividers between sections.
  final bool showDividers;

  /// Whether to wrap the entire detail view in an [OiCard].
  final bool wrapInCard;

  /// Padding around the entire detail view.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final nonEmptySections = sections
        .where((s) => s.fields.isNotEmpty)
        .toList();

    if (nonEmptySections.isEmpty) {
      return const SizedBox.shrink();
    }

    final bp = context.breakpoint;

    Widget content = OiColumn(
      breakpoint: bp,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < nonEmptySections.length; i++) ...[
          _buildSection(context, nonEmptySections[i], i, bp),
          if (i < nonEmptySections.length - 1 && showDividers)
            Padding(
              padding: EdgeInsets.symmetric(vertical: rowGap),
              child: const OiDivider(),
            ),
          if (i < nonEmptySections.length - 1 && !showDividers)
            SizedBox(height: rowGap),
        ],
      ],
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (wrapInCard) {
      content = OiCard(child: content);
    }

    if (label != null) {
      content = Semantics(label: label, child: content);
    }

    return content;
  }

  Widget _buildSection(
    BuildContext context,
    OiDetailSection section,
    int index,
    OiBreakpoint bp,
  ) {
    return OiSurface(
      child: OiColumn(
        breakpoint: bp,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (section.title != null)
            Padding(
              padding: EdgeInsets.only(bottom: rowGap),
              child: OiLabel.h4(section.title!),
            ),
          _buildSectionFields(context, section, bp),
        ],
      ),
    );
  }

  Widget _buildSectionFields(
    BuildContext context,
    OiDetailSection section,
    OiBreakpoint bp,
  ) {
    if (columns <= 1) {
      return OiColumn(
        breakpoint: bp,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < section.fields.length; i++) ...[
            _buildField(context, section.fields[i]),
            if (i < section.fields.length - 1) SizedBox(height: rowGap),
          ],
        ],
      );
    }

    // Multi-column layout using Wrap.
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGap = columnGap * (columns - 1);
        final columnWidth = (constraints.maxWidth - totalGap) / columns;

        final children = <Widget>[];
        for (var i = 0; i < section.fields.length; i++) {
          final field = section.fields[i];
          final span = field.columnSpan.clamp(1, columns);
          final fieldWidth = columnWidth * span + columnGap * (span - 1);

          children.add(
            SizedBox(
              width: fieldWidth,
              child: Padding(
                padding: EdgeInsets.only(bottom: rowGap),
                child: _buildField(context, field),
              ),
            ),
          );
        }

        return Wrap(spacing: columnGap, children: children);
      },
    );
  }

  Widget _buildField(BuildContext context, OiDetailField field) {
    return OiFieldDisplay.pair(
      label: field.label,
      value: field.value,
      type: field.type,
      direction: fieldDirection,
      labelWidth: labelWidth,
      emptyText: emptyText,
      copyable: field.copyable,
      maxLines: field.maxLines,
      dateFormat: field.dateFormat,
      numberFormat: field.numberFormat,
      currencyCode: field.currencyCode,
      currencySymbol: field.currencySymbol,
      decimalPlaces: field.decimalPlaces,
      choices: field.choices,
      choiceColors: field.choiceColors,
      formatValue: field.formatValue,
      onTap: field.onTap,
      leading: field.leading,
    );
  }
}
