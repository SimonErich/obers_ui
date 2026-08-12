import 'package:flutter/foundation.dart';

/// The icon-size scale for the design system.
///
/// Icons need their own ladder rather than borrowing the body font size: an
/// interface whose body text is 15dp does not want 15dp icons, and a glyph
/// sized off a text style drifts every time the type scale is retuned.
///
/// Four steps, matched to where icons actually appear:
///
/// | token | default | used by |
/// |---|---|---|
/// | [sm] | 14 | inline with small text, chips, dense metadata rows |
/// | [md] | 16 | the default — buttons, list leading, menu items |
/// | [lg] | 18 | toolbar and header actions |
/// | [xl] | 24 | navigation rails, empty states, feature glyphs |
///
/// Sizes are in logical pixels. Prefer these over a literal: a call site
/// passing `size: 18` cannot be retuned centrally, which is how a codebase
/// ends up with four undocumented icon sizes and no way to change them.
///
/// {@category Foundation}
@immutable
class OiIconSizeScale {
  /// Creates an [OiIconSizeScale] with explicit values.
  const OiIconSizeScale({
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  /// The standard icon-size scale.
  const OiIconSizeScale.standard() : sm = 14, md = 16, lg = 18, xl = 24;

  /// Small (14dp). Inline with small text, chips, dense metadata rows.
  final double sm;

  /// Medium (16dp). The default: buttons, list leading, menu items.
  final double md;

  /// Large (18dp). Toolbar and header actions.
  final double lg;

  /// Extra-large (24dp). Navigation rails, empty states, feature glyphs.
  final double xl;

  /// Creates a copy with optionally overridden values.
  OiIconSizeScale copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return OiIconSizeScale(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiIconSizeScale &&
        other.sm == sm &&
        other.md == md &&
        other.lg == lg &&
        other.xl == xl;
  }

  @override
  int get hashCode => Object.hashAll([sm, md, lg, xl]);
}
