import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_tooltip.dart';

/// A standalone tooltip display widget that renders [OiChartTooltipModel]
/// data without requiring a behavior or overlay system.
///
/// Use [OiChartTooltipWidget] when you manage tooltip visibility yourself
/// and want to embed the tooltip directly in your widget tree, rather than
/// relying on [OiChartTooltipBehavior]'s overlay-driven display.
///
/// A custom [builder] can override the entire tooltip content. When
/// [builder] is null, a default card-style tooltip is rendered.
///
/// ```dart
/// if (tooltipModel != null)
///   OiChartTooltipWidget(model: tooltipModel!)
/// ```
///
/// {@category Components}
class OiChartTooltipWidget extends StatelessWidget {
  /// Creates an [OiChartTooltipWidget].
  const OiChartTooltipWidget({
    required this.model,
    super.key,
    this.builder,
    this.theme,
  });

  /// The tooltip data model to display.
  final OiChartTooltipModel model;

  /// An optional custom content builder.
  ///
  /// When provided, this widget is used instead of the default tooltip
  /// rendering. The [BuildContext] and [OiChartTooltipModel] are supplied
  /// to the builder.
  final OiChartTooltipBuilder? builder;

  /// Optional theme data; visual tokens fall back to built-in defaults
  /// when null.
  final OiChartThemeData? theme;

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      return builder!(context, model);
    }
    return _OiDefaultTooltipContent(model: model, theme: theme);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Default tooltip content
// ─────────────────────────────────────────────────────────────────────────────

class _OiDefaultTooltipContent extends StatelessWidget {
  const _OiDefaultTooltipContent({required this.model, this.theme});

  final OiChartTooltipModel model;
  final OiChartThemeData? theme;

  @override
  Widget build(BuildContext context) {
    final tooltipTheme = theme?.tooltip;

    final bgColor = tooltipTheme?.backgroundColor ?? const Color(0xF0222222);
    final borderColor = tooltipTheme?.borderColor;
    final borderWidth = tooltipTheme?.borderWidth ?? 0.0;
    final borderRadius = tooltipTheme?.borderRadius ?? BorderRadius.circular(6);
    final textStyle = tooltipTheme?.textStyle ?? const TextStyle(fontSize: 12);
    final textColor = tooltipTheme?.textColor ?? const Color(0xFFFFFFFF);
    final padding =
        tooltipTheme?.padding ??
        const EdgeInsets.symmetric(horizontal: 10, vertical: 6);

    final effectiveTextStyle = textStyle.copyWith(color: textColor);
    final labelStyle = effectiveTextStyle.copyWith(
      color: const Color(0xFFAAAAAA),
    );
    final titleStyle = effectiveTextStyle.copyWith(
      color: const Color(0xFFCCCCCC),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    final footerStyle = effectiveTextStyle.copyWith(
      color: const Color(0xFF999999),
      fontSize: 10,
    );

    BoxBorder? border;
    if (borderColor != null && borderWidth > 0) {
      border = Border.all(color: borderColor, width: borderWidth);
    }

    final shadow =
        tooltipTheme?.shadow ??
        const BoxShadow(
          color: Color(0x40000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        );

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        border: border,
        boxShadow: [shadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (model.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: OiLabel.small(model.title!, color: titleStyle.color),
            ),
          for (final entry in model.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (entry.color != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: entry.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  OiLabel.caption(
                    '${entry.seriesLabel}: ',
                    color: labelStyle.color,
                  ),
                  OiLabel.caption(
                    entry.pointLabel ?? entry.formattedY,
                    color: effectiveTextStyle.color,
                  ),
                ],
              ),
            ),
          if (model.footer != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: OiLabel.caption(model.footer!, color: footerStyle.color),
            ),
        ],
      ),
    );
  }
}
