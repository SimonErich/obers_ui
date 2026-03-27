import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/components/display/oi_field_display.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/clipboard/oi_copyable.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// Lightweight label-value pair for read-only data display.
///
/// Simpler alternative to [OiFieldDisplay.pair] when you don't need
/// type-based formatting. Just shows a label and a value as strings.
///
/// ```dart
/// const OiKeyValue(label: 'Name', value: 'John Doe')
/// const OiKeyValue(label: 'Email', value: null, emptyText: 'Not provided')
/// ```
///
/// {@category Components}
class OiKeyValue extends StatelessWidget {
  /// Creates an [OiKeyValue].
  const OiKeyValue({
    required this.label,
    required this.value,
    this.direction,
    this.labelWidth,
    this.leading,
    this.trailing,
    this.valueWidget,
    this.emptyText = '---',
    this.copyable = false,
    this.onTap,
    this.dense = false,
    this.semanticLabel,
    super.key,
  });

  /// The field label.
  final String label;

  /// The field value as a string. If null or empty, [emptyText] is shown.
  final String? value;

  /// Layout direction. Defaults to horizontal on expanded+, vertical on
  /// compact.
  final Axis? direction;

  /// Fixed width for the label column (horizontal direction only).
  final double? labelWidth;

  /// Leading widget before the label (e.g., icon).
  final Widget? leading;

  /// Trailing widget after the value (e.g., action button, badge).
  final Widget? trailing;

  /// Custom widget to render instead of a text value.
  /// When provided, [value] is ignored for display (but still used for copy).
  final Widget? valueWidget;

  /// Placeholder when [value] is null or empty.
  final String emptyText;

  /// Whether the value can be tapped to copy to clipboard.
  final bool copyable;

  /// Makes the entire row tappable.
  final VoidCallback? onTap;

  /// Reduced vertical padding.
  final bool dense;

  /// Accessibility label.
  final String? semanticLabel;

  /// Group multiple [OiKeyValue] rows into a visual section.
  ///
  /// Adds dividers between rows and optional title/card wrapper.
  static Widget group({
    required List<OiKeyValue> children,
    String? title,
    bool dividers = true,
    bool wrapInCard = false,
    Axis? direction,
    double? labelWidth,
    Key? key,
  }) {
    return _OiKeyValueGroup(
      title: title,
      dividers: dividers,
      wrapInCard: wrapInCard,
      direction: direction,
      labelWidth: labelWidth,
      key: key,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final breakpoint = context.breakpoint;

    final effectiveDirection =
        direction ??
        (breakpoint.compareTo(OiBreakpoint.compact) <= 0
            ? Axis.vertical
            : Axis.horizontal);

    final hasValue = value != null && value!.isNotEmpty;
    final displayValue = hasValue ? value! : emptyText;

    Widget valueContent;
    if (valueWidget != null) {
      valueContent = valueWidget!;
    } else if (copyable && hasValue) {
      valueContent = OiCopyable(
        value: value!,
        child: OiLabel.body(displayValue, color: colors.text),
      );
    } else {
      valueContent = OiLabel.body(
        displayValue,
        color: hasValue ? colors.text : colors.textMuted,
      );
    }

    final labelWidget = SizedBox(
      width: effectiveDirection == Axis.horizontal ? labelWidth : null,
      child: OiLabel.small(label, color: colors.textSubtle),
    );

    final paddingVertical = dense ? spacing.xs / 2 : spacing.xs;

    Widget content;
    if (effectiveDirection == Axis.horizontal) {
      content = Padding(
        padding: EdgeInsets.symmetric(vertical: paddingVertical),
        child: OiRow(
          breakpoint: breakpoint,
          gap: OiResponsive<double>(spacing.sm),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) leading!,
            labelWidget,
            Expanded(child: valueContent),
            if (trailing != null) trailing!,
          ],
        ),
      );
    } else {
      content = Padding(
        padding: EdgeInsets.symmetric(vertical: paddingVertical),
        child: OiColumn(
          breakpoint: breakpoint,
          gap: OiResponsive<double>(spacing.xs / 2),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null)
              OiRow(
                breakpoint: breakpoint,
                gap: OiResponsive<double>(spacing.xs),
                children: [leading!, labelWidget],
              )
            else
              labelWidget,
            valueContent,
            if (trailing != null) trailing!,
          ],
        ),
      );
    }

    if (onTap != null) {
      content = OiTappable(
        onTap: onTap,
        semanticLabel: semanticLabel ?? '$label: $displayValue',
        child: content,
      );
    } else if (semanticLabel != null) {
      content = Semantics(label: semanticLabel, child: content);
    }

    return content;
  }
}

class _OiKeyValueGroup extends StatelessWidget {
  const _OiKeyValueGroup({
    required this.children,
    this.title,
    this.dividers = true,
    this.wrapInCard = false,
    this.direction,
    this.labelWidth,
    super.key,
  });

  final List<OiKeyValue> children;
  final String? title;
  final bool dividers;
  final bool wrapInCard;
  final Axis? direction;
  final double? labelWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final breakpoint = context.breakpoint;

    final items = <Widget>[];

    if (title != null) {
      items.add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing.sm),
          child: OiLabel.bodyStrong(title!),
        ),
      );
    }

    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      items.add(
        OiKeyValue(
          label: child.label,
          value: child.value,
          direction: direction ?? child.direction,
          labelWidth: labelWidth ?? child.labelWidth,
          leading: child.leading,
          trailing: child.trailing,
          valueWidget: child.valueWidget,
          emptyText: child.emptyText,
          copyable: child.copyable,
          onTap: child.onTap,
          dense: child.dense,
          semanticLabel: child.semanticLabel,
        ),
      );

      if (dividers && i < children.length - 1) {
        items.add(Container(height: 1, color: colors.borderSubtle));
      }
    }

    Widget result = OiColumn(
      breakpoint: breakpoint,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );

    if (wrapInCard) {
      result = OiCard.flat(child: result);
    }

    return result;
  }
}
