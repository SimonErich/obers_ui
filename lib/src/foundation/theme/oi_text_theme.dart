import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Semantic text-style variants used throughout the Obers UI design system.
///
/// Each value corresponds to a named [TextStyle] on [OiTextTheme].
///
/// {@category Foundation}
enum OiLabelVariant {
  /// Hero / marketing display text — largest size.
  display,

  /// Top-level heading.
  h1,

  /// Second-level heading.
  h2,

  /// Third-level heading.
  h3,

  /// Fourth-level heading.
  h4,

  /// Standard paragraph body text.
  body,

  /// Bold / emphasized paragraph body text.
  bodyStrong,

  /// Small body text, suitable for secondary information.
  small,

  /// Bold small body text.
  smallStrong,

  /// Extra-small text, suitable for dense UI elements.
  tiny,

  /// Caption text below images or media.
  caption,

  /// Monospace code / preformatted text.
  code,

  /// All-caps label with letter-spacing, used above sections.
  overline,

  /// Inline hyperlink text.
  link,
}

/// A complete set of [TextStyle]s for the Obers UI design system.
///
/// Use [OiTextTheme.standard] to obtain the default type scale, optionally
/// customising the font families. Use [copyWith] to override individual
/// styles, [OiTextTheme.lerp] to animate between two themes, and
/// [styleFor] to look up a style by its [OiLabelVariant] token.
///
/// {@category Foundation}
@immutable
class OiTextTheme {
  /// Creates an [OiTextTheme] with all styles specified explicitly.
  const OiTextTheme({
    required this.display,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.body,
    required this.bodyStrong,
    required this.small,
    required this.smallStrong,
    required this.tiny,
    required this.caption,
    required this.code,
    required this.overline,
    required this.link,
  });

  /// Builds the standard Obers UI type scale.
  ///
  /// [fontFamily] is applied to every style except [code].
  /// [monoFontFamily] is applied to [code].  When omitted both fall back to
  /// system defaults.
  factory OiTextTheme.standard({String? fontFamily, String? monoFontFamily}) {
    const defaultMono = 'monospace';
    return OiTextTheme(
      display: TextStyle(
        fontFamily: fontFamily,
        fontSize: 56,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.5,
      ),
      h1: TextStyle(
        fontFamily: fontFamily,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.25,
      ),
      h2: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      h3: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h4: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      body: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyStrong: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      small: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      smallStrong: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      tiny: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      caption: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      code: TextStyle(
        fontFamily: monoFontFamily ?? defaultMono,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
      ),
      overline: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 1.5,
      ),
      link: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        decoration: TextDecoration.underline,
      ),
    );
  }

  /// Linearly interpolates between two [OiTextTheme]s.
  ///
  /// [t] must be in the range [0, 1]. At [t] = 0 the result equals [a];
  /// at [t] = 1 the result equals [b].
  OiTextTheme.lerp(OiTextTheme a, OiTextTheme b, double t)
    : display = TextStyle.lerp(a.display, b.display, t)!,
      h1 = TextStyle.lerp(a.h1, b.h1, t)!,
      h2 = TextStyle.lerp(a.h2, b.h2, t)!,
      h3 = TextStyle.lerp(a.h3, b.h3, t)!,
      h4 = TextStyle.lerp(a.h4, b.h4, t)!,
      body = TextStyle.lerp(a.body, b.body, t)!,
      bodyStrong = TextStyle.lerp(a.bodyStrong, b.bodyStrong, t)!,
      small = TextStyle.lerp(a.small, b.small, t)!,
      smallStrong = TextStyle.lerp(a.smallStrong, b.smallStrong, t)!,
      tiny = TextStyle.lerp(a.tiny, b.tiny, t)!,
      caption = TextStyle.lerp(a.caption, b.caption, t)!,
      code = TextStyle.lerp(a.code, b.code, t)!,
      overline = TextStyle.lerp(a.overline, b.overline, t)!,
      link = TextStyle.lerp(a.link, b.link, t)!;

  // ── Styles ────────────────────────────────────────────────────────────────

  /// Hero / marketing display text — largest size.
  final TextStyle display;

  /// Top-level heading.
  final TextStyle h1;

  /// Second-level heading.
  final TextStyle h2;

  /// Third-level heading.
  final TextStyle h3;

  /// Fourth-level heading.
  final TextStyle h4;

  /// Standard paragraph body text.
  final TextStyle body;

  /// Bold / emphasized paragraph body text.
  final TextStyle bodyStrong;

  /// Small body text, suitable for secondary information.
  final TextStyle small;

  /// Bold small body text.
  final TextStyle smallStrong;

  /// Extra-small text, suitable for dense UI elements.
  final TextStyle tiny;

  /// Caption text below images or media.
  final TextStyle caption;

  /// Monospace code / preformatted text.
  final TextStyle code;

  /// All-caps label with letter-spacing, used above sections.
  final TextStyle overline;

  /// Inline hyperlink text.
  final TextStyle link;

  // ── Utilities ─────────────────────────────────────────────────────────────

  /// Returns the [TextStyle] corresponding to the given [OiLabelVariant].
  TextStyle styleFor(OiLabelVariant variant) {
    switch (variant) {
      case OiLabelVariant.display:
        return display;
      case OiLabelVariant.h1:
        return h1;
      case OiLabelVariant.h2:
        return h2;
      case OiLabelVariant.h3:
        return h3;
      case OiLabelVariant.h4:
        return h4;
      case OiLabelVariant.body:
        return body;
      case OiLabelVariant.bodyStrong:
        return bodyStrong;
      case OiLabelVariant.small:
        return small;
      case OiLabelVariant.smallStrong:
        return smallStrong;
      case OiLabelVariant.tiny:
        return tiny;
      case OiLabelVariant.caption:
        return caption;
      case OiLabelVariant.code:
        return code;
      case OiLabelVariant.overline:
        return overline;
      case OiLabelVariant.link:
        return link;
    }
  }

  /// Creates a copy of this theme with the specified styles replaced.
  OiTextTheme copyWith({
    TextStyle? display,
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? h4,
    TextStyle? body,
    TextStyle? bodyStrong,
    TextStyle? small,
    TextStyle? smallStrong,
    TextStyle? tiny,
    TextStyle? caption,
    TextStyle? code,
    TextStyle? overline,
    TextStyle? link,
  }) {
    return OiTextTheme(
      display: display ?? this.display,
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      h4: h4 ?? this.h4,
      body: body ?? this.body,
      bodyStrong: bodyStrong ?? this.bodyStrong,
      small: small ?? this.small,
      smallStrong: smallStrong ?? this.smallStrong,
      tiny: tiny ?? this.tiny,
      caption: caption ?? this.caption,
      code: code ?? this.code,
      overline: overline ?? this.overline,
      link: link ?? this.link,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTextTheme &&
        other.display == display &&
        other.h1 == h1 &&
        other.h2 == h2 &&
        other.h3 == h3 &&
        other.h4 == h4 &&
        other.body == body &&
        other.bodyStrong == bodyStrong &&
        other.small == small &&
        other.smallStrong == smallStrong &&
        other.tiny == tiny &&
        other.caption == caption &&
        other.code == code &&
        other.overline == overline &&
        other.link == link;
  }

  @override
  int get hashCode => Object.hashAll([
    display,
    h1,
    h2,
    h3,
    h4,
    body,
    bodyStrong,
    small,
    smallStrong,
    tiny,
    caption,
    code,
    overline,
    link,
  ]);

  @override
  String toString() => 'OiTextTheme(body: $body, h1: $h1, display: $display)';
}
