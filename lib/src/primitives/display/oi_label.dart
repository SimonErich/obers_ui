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
/// - Color and decoration overrides via [color], [decoration],
///   and [decorationColor].
/// - Responsive font scaling for the [OiLabelVariant.display],
///   [OiLabelVariant.h1], and [OiLabelVariant.h2] variants:
///   × 1.0 on compact, × 1.1 on medium, × 1.2 on expanded+.
///
/// Use the named constructors to select a typographic variant:
/// - [OiLabel.display]: hero / marketing display text.
/// - [OiLabel.h1]: top-level heading.
/// - [OiLabel.h2]: second-level heading.
/// - [OiLabel.h3]: third-level heading.
/// - [OiLabel.h4]: fourth-level heading.
/// - [OiLabel.body]: standard paragraph body text.
/// - [OiLabel.bodyStrong]: bold / emphasized body text.
/// - [OiLabel.small]: small body text for secondary information.
/// - [OiLabel.smallStrong]: bold small body text.
/// - [OiLabel.tiny]: extra-small text for dense UI elements.
/// - [OiLabel.caption]: caption text below images or media.
/// - [OiLabel.code]: monospace code / preformatted text.
/// - [OiLabel.overline]: all-caps label with letter-spacing.
/// - [OiLabel.link]: inline hyperlink text.
///
/// ```dart
/// OiLabel.body('Hello world')
/// OiLabel.display('Hero text')
/// OiLabel.small('Secondary info')
/// ```
///
/// {@category Primitives}
class OiLabel extends StatelessWidget {
  // ── Private base constructor ──────────────────────────────────────────────

  const OiLabel._({
    required this.variant,
    required this.text,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.copyable = false,
    this.selectable = false,
    this.semanticsLabel,
    this.color,
    this.decoration,
    this.decorationColor,
    super.key,
  });

  // ── Named variant constructors ────────────────────────────────────────────

  /// Creates a display label — hero / marketing display text.
  const OiLabel.display(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.display,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates an h1 label — top-level heading.
  const OiLabel.h1(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.h1,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates an h2 label — second-level heading.
  const OiLabel.h2(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.h2,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates an h3 label — third-level heading.
  const OiLabel.h3(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.h3,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates an h4 label — fourth-level heading.
  const OiLabel.h4(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.h4,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates a body label — standard paragraph body text.
  const OiLabel.body(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.body,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates a bodyStrong label — bold / emphasized body text.
  const OiLabel.bodyStrong(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.bodyStrong,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates a small label — small body text for secondary information.
  const OiLabel.small(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.small,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates a smallStrong label — bold small body text.
  const OiLabel.smallStrong(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.smallStrong,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates a tiny label — extra-small text for dense UI elements.
  const OiLabel.tiny(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.tiny,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates a caption label — caption text below images or media.
  const OiLabel.caption(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.caption,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates a code label — monospace code / preformatted text.
  const OiLabel.code(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.code,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates an overline label — all-caps label with letter-spacing.
  const OiLabel.overline(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.overline,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

  /// Creates a link label — inline hyperlink text.
  const OiLabel.link(
    String text, {
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
    bool copyable = false,
    bool selectable = false,
    String? semanticsLabel,
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
    Key? key,
  }) : this._(
         variant: OiLabelVariant.link,
         text: text,
         maxLines: maxLines,
         overflow: overflow,
         textAlign: textAlign,
         copyable: copyable,
         selectable: selectable,
         semanticsLabel: semanticsLabel,
         color: color,
         decoration: decoration,
         decorationColor: decorationColor,
         key: key,
       );

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

  /// Optional color override. When non-null, takes priority over the
  /// variant's default text color.
  final Color? color;

  /// Optional text decoration override (e.g. [TextDecoration.lineThrough]).
  final TextDecoration? decoration;

  /// Color of the text decoration. Only used when [decoration] is set.
  final Color? decorationColor;

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

    var style = baseStyle;
    if (scale != 1 && baseStyle.fontSize != null) {
      style = style.copyWith(fontSize: baseStyle.fontSize! * scale);
    }

    if (color != null || decoration != null || decorationColor != null) {
      style = style.copyWith(
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
      );
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
