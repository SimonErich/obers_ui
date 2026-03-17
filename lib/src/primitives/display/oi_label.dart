import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/clipboard/oi_copyable.dart';

/// Renders styled text using an [OiLabelVariant] from the active theme.
///
/// [OiLabel] resolves its [TextStyle] from the nearest [OiTheme], and
/// optionally supports:
/// - Semantic labelling via [semanticsLabel].
/// - Clipboard copy on tap via [copyable] (backed by [OiCopyable]).
/// - Text selection via [selectable].
/// - Responsive font scaling for the [OiLabelVariant.display],
///   [OiLabelVariant.h1], and [OiLabelVariant.h2] variants:
///   × 1.0 on compact, × 1.1 on medium, × 1.2 on expanded+.
///
/// {@category Primitives}
class OiLabel extends StatelessWidget {
  /// Creates an [OiLabel] with the given [variant] and [text].
  const OiLabel(
    this.text, {
    this.variant = OiLabelVariant.body,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.copyable = false,
    this.selectable = false,
    this.semanticsLabel,
    super.key,
  });

  /// The text content to render.
  final String text;

  /// The typographic variant that determines the text style.
  final OiLabelVariant variant;

  /// Maximum number of lines before overflow handling kicks in.
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// When `true`, tapping the label copies [text] to the system clipboard.
  ///
  /// Backed by [OiCopyable].
  final bool copyable;

  /// When `true`, the text is rendered inside a [SelectableRegion] so the
  /// user can select and copy it manually.
  final bool selectable;

  /// An optional override for the accessibility label announced by screen
  /// readers.  When null the value of [text] is used.
  final String? semanticsLabel;

  // ---------------------------------------------------------------------------
  // Responsive scale helpers
  // ---------------------------------------------------------------------------

  static const Set<OiLabelVariant> _responsiveVariants = {
    OiLabelVariant.display,
    OiLabelVariant.h1,
    OiLabelVariant.h2,
  };

  double _scaleFactor(BuildContext context) {
    if (!_responsiveVariants.contains(variant)) return 1;
    final width = MediaQuery.sizeOf(context).width;
    if (width >= OiBreakpoint.expanded.minWidth) return 1.2;
    if (width >= OiBreakpoint.medium.minWidth) return 1.1;
    return 1;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final baseStyle = context.textTheme.styleFor(variant);
    final scale = _scaleFactor(context);

    final TextStyle style;
    if (scale != 1 && baseStyle.fontSize != null) {
      style = baseStyle.copyWith(fontSize: baseStyle.fontSize! * scale);
    } else {
      style = baseStyle;
    }

    Widget textWidget = Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );

    if (selectable) {
      textWidget = SelectableRegion(
        focusNode: FocusNode(),
        selectionControls: emptyTextSelectionControls,
        child: textWidget,
      );
    }

    if (copyable) {
      textWidget = OiCopyable(value: text, child: textWidget);
    }

    if (semanticsLabel != null) {
      textWidget = Semantics(
        label: semanticsLabel,
        child: ExcludeSemantics(child: textWidget),
      );
    }

    return textWidget;
  }
}
