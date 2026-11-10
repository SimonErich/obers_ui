import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// Balances up to six short lines without rewriting the source text.
///
/// Measures the same resolved style, locale, direction, leading and system
/// text scaler that [OiLabel] paints. Single lines, long paragraphs and
/// unbounded layouts use ordinary wrapping. Explicit line breaks are retained.
class OiBalancedText extends StatelessWidget {
  /// Creates a balanced heading or short paragraph.
  const OiBalancedText(
    this.text, {
    this.variant = OiLabelVariant.h1,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
    this.strutStyle,
    this.textHeightBehavior,
    super.key,
  });

  /// Original text, also used by accessibility and selection.
  final String text;

  /// Semantic typography role.
  final OiLabelVariant variant;

  /// Overrides merged over the typography role.
  final TextStyle? style;

  /// Alignment within the available width.
  final TextAlign textAlign;

  /// Optional line limit, applied after balancing.
  final int? maxLines;

  /// How overflow beyond [maxLines] is painted.
  final TextOverflow? overflow;

  /// Optional accessible name.
  final String? semanticsLabel;

  /// Optional minimum line metrics.
  final StrutStyle? strutStyle;

  /// Paragraph leading policy; otherwise uses the text theme.
  final TextHeightBehavior? textHeightBehavior;

  @override
  Widget build(BuildContext context) {
    final label = OiLabel.variant(
      text,
      variant: variant,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      strutStyle: strutStyle,
      textHeightBehavior: textHeightBehavior,
    );
    return LayoutBuilder(
      builder: (context, bounds) {
        if (!bounds.hasBoundedWidth || bounds.maxWidth <= 0) return label;
        final painter = TextPainter(
          text: TextSpan(text: text, style: label.resolveStyle(context)),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          locale: Localizations.maybeLocaleOf(context),
          strutStyle: strutStyle,
          textHeightBehavior:
              textHeightBehavior ?? context.textTheme.textHeightBehavior,
        );
        try {
          painter.layout(maxWidth: bounds.maxWidth);
          final lines = painter.computeLineMetrics().length;
          if (lines < 2 ||
              lines > 6 ||
              (maxLines != null && lines > maxLines!)) {
            return label;
          }
          // Preserve ordinary Unicode break opportunities. Searching below the
          // minimum intrinsic width can split a word solely to keep line count.
          // Words wider than the original constraint retain normal wrapping.
          final longestRun = painter.minIntrinsicWidth.clamp(
            0.0,
            bounds.maxWidth,
          );
          var lower = (bounds.maxWidth / lines).clamp(
            longestRun,
            bounds.maxWidth,
          );
          var upper = bounds.maxWidth;
          // Search line-break opportunities using Flutter's own paragraph engine,
          // including scripts without spaces and nonlinear accessibility scaling.
          for (var i = 0; i < 16 && upper - lower > .01; i++) {
            final middle = (lower + upper) / 2;
            painter.layout(maxWidth: middle);
            if (painter.computeLineMetrics().length > lines) {
              lower = middle;
            } else {
              upper = middle;
            }
          }
          final alignment = switch (textAlign) {
            TextAlign.center => AlignmentDirectional.topCenter,
            TextAlign.end => AlignmentDirectional.topEnd,
            TextAlign.right => Alignment.topRight,
            TextAlign.left => Alignment.topLeft,
            _ => AlignmentDirectional.topStart,
          };
          return Align(
            alignment: alignment,
            child: SizedBox(width: upper, child: label),
          );
        } finally {
          painter.dispose();
        }
      },
    );
  }
}
