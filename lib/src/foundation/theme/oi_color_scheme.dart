import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:obers_ui/src/foundation/theme/oi_color_swatch.dart';

/// A complete semantic color palette for the Obers UI design system.
///
/// [OiColorScheme] holds all color tokens used by Obers UI widgets — semantic
/// swatches (primary, accent, success, warning, error, info), surface / overlay
/// colors, text colors, border colors, glass-effect colors, and a categorical
/// chart palette.
///
/// Two built-in palettes are provided via factory constructors:
/// - [OiColorScheme.light] — a light-background palette.
/// - [OiColorScheme.dark] — a dark-background palette.
///
/// Instances are immutable; use [copyWith] to derive a modified copy or
/// [OiColorScheme.lerp] to animate between two schemes.
///
/// {@category Foundation}
@immutable
class OiColorScheme {
  /// Creates an [OiColorScheme] with all color fields specified explicitly.
  const OiColorScheme({
    required this.primary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.background,
    required this.surface,
    required this.surfaceHover,
    required this.surfaceActive,
    required this.surfaceSubtle,
    required this.overlay,
    required this.text,
    required this.textSubtle,
    required this.textMuted,
    required this.textInverse,
    required this.textOnPrimary,
    required this.border,
    required this.borderSubtle,
    required this.borderFocus,
    required this.borderError,
    required this.glassBackground,
    required this.glassBorder,
    required this.chart,
  });

  /// A light-background color scheme.
  ///
  /// Uses a blue primary, teal accent, and light grey surfaces.
  factory OiColorScheme.light() {
    return OiColorScheme(
      primary: OiColorSwatch.from(const Color(0xFF2563EB)),
      accent: OiColorSwatch.from(const Color(0xFF0D9488)),
      success: OiColorSwatch.from(const Color(0xFF16A34A)),
      warning: OiColorSwatch.from(const Color(0xFFD97706)),
      error: OiColorSwatch.from(const Color(0xFFDC2626)),
      info: OiColorSwatch.from(const Color(0xFF0284C7)),
      background: const Color(0xFFF9FAFB),
      surface: const Color(0xFFFFFFFF),
      surfaceHover: const Color(0xFFF3F4F6),
      surfaceActive: const Color(0xFFE5E7EB),
      surfaceSubtle: const Color(0xFFF9FAFB),
      overlay: const Color(0x66000000),
      text: const Color(0xFF111827),
      textSubtle: const Color(0xFF374151),
      textMuted: const Color(0xFF6B7280),
      textInverse: const Color(0xFFFFFFFF),
      textOnPrimary: const Color(0xFFFFFFFF),
      border: const Color(0xFFD1D5DB),
      borderSubtle: const Color(0xFFE5E7EB),
      borderFocus: const Color(0xFF2563EB),
      borderError: const Color(0xFFDC2626),
      glassBackground: const Color(0x99FFFFFF),
      glassBorder: const Color(0x33FFFFFF),
      chart: const [
        Color(0xFF2563EB),
        Color(0xFF0D9488),
        Color(0xFFD97706),
        Color(0xFFDC2626),
        Color(0xFF7C3AED),
        Color(0xFF0284C7),
        Color(0xFF16A34A),
        Color(0xFFDB2777),
      ],
    );
  }

  /// A dark-background color scheme.
  ///
  /// Uses a blue primary, teal accent, and near-black surfaces.
  factory OiColorScheme.dark() {
    return OiColorScheme(
      primary: OiColorSwatch.from(const Color(0xFF3B82F6)),
      accent: OiColorSwatch.from(const Color(0xFF14B8A6)),
      success: OiColorSwatch.from(const Color(0xFF22C55E)),
      warning: OiColorSwatch.from(const Color(0xFFF59E0B)),
      error: OiColorSwatch.from(const Color(0xFFEF4444)),
      info: OiColorSwatch.from(const Color(0xFF38BDF8)),
      background: const Color(0xFF0A0A0F),
      surface: const Color(0xFF111118),
      surfaceHover: const Color(0xFF1C1C26),
      surfaceActive: const Color(0xFF252533),
      surfaceSubtle: const Color(0xFF0D0D14),
      overlay: const Color(0x99000000),
      text: const Color(0xFFF9FAFB),
      textSubtle: const Color(0xFFD1D5DB),
      textMuted: const Color(0xFF9CA3AF),
      textInverse: const Color(0xFF111827),
      textOnPrimary: const Color(0xFFFFFFFF),
      border: const Color(0xFF374151),
      borderSubtle: const Color(0xFF1F2937),
      borderFocus: const Color(0xFF3B82F6),
      borderError: const Color(0xFFEF4444),
      glassBackground: const Color(0x33FFFFFF),
      glassBorder: const Color(0x1AFFFFFF),
      chart: const [
        Color(0xFF3B82F6),
        Color(0xFF14B8A6),
        Color(0xFFF59E0B),
        Color(0xFFEF4444),
        Color(0xFF8B5CF6),
        Color(0xFF38BDF8),
        Color(0xFF22C55E),
        Color(0xFFF472B6),
      ],
    );
  }

  /// Linearly interpolates between two [OiColorScheme]s.
  ///
  /// [t] must be in the range [0, 1]. At [t] = 0 the result equals [a];
  /// at [t] = 1 the result equals [b].
  OiColorScheme.lerp(OiColorScheme a, OiColorScheme b, double t)
      : primary = OiColorSwatch.lerp(a.primary, b.primary, t),
        accent = OiColorSwatch.lerp(a.accent, b.accent, t),
        success = OiColorSwatch.lerp(a.success, b.success, t),
        warning = OiColorSwatch.lerp(a.warning, b.warning, t),
        error = OiColorSwatch.lerp(a.error, b.error, t),
        info = OiColorSwatch.lerp(a.info, b.info, t),
        background = Color.lerp(a.background, b.background, t)!,
        surface = Color.lerp(a.surface, b.surface, t)!,
        surfaceHover = Color.lerp(a.surfaceHover, b.surfaceHover, t)!,
        surfaceActive = Color.lerp(a.surfaceActive, b.surfaceActive, t)!,
        surfaceSubtle = Color.lerp(a.surfaceSubtle, b.surfaceSubtle, t)!,
        overlay = Color.lerp(a.overlay, b.overlay, t)!,
        text = Color.lerp(a.text, b.text, t)!,
        textSubtle = Color.lerp(a.textSubtle, b.textSubtle, t)!,
        textMuted = Color.lerp(a.textMuted, b.textMuted, t)!,
        textInverse = Color.lerp(a.textInverse, b.textInverse, t)!,
        textOnPrimary = Color.lerp(a.textOnPrimary, b.textOnPrimary, t)!,
        border = Color.lerp(a.border, b.border, t)!,
        borderSubtle = Color.lerp(a.borderSubtle, b.borderSubtle, t)!,
        borderFocus = Color.lerp(a.borderFocus, b.borderFocus, t)!,
        borderError = Color.lerp(a.borderError, b.borderError, t)!,
        glassBackground =
            Color.lerp(a.glassBackground, b.glassBackground, t)!,
        glassBorder = Color.lerp(a.glassBorder, b.glassBorder, t)!,
        chart = List<Color>.generate(
          a.chart.length,
          (i) => Color.lerp(
            a.chart[i],
            b.chart[i < b.chart.length ? i : b.chart.length - 1],
            t,
          )!,
        );

  // ── Semantic swatches ────────────────────────────────────────────────────

  /// The primary brand color swatch (base, light, dark, muted, foreground).
  final OiColorSwatch primary;

  /// The accent / secondary brand color swatch.
  final OiColorSwatch accent;

  /// The success / positive state color swatch.
  final OiColorSwatch success;

  /// The warning / caution state color swatch.
  final OiColorSwatch warning;

  /// The error / destructive state color swatch.
  final OiColorSwatch error;

  /// The informational state color swatch.
  final OiColorSwatch info;

  // ── Background / surface ─────────────────────────────────────────────────

  /// The app-level page background color.
  final Color background;

  /// The default card / panel surface color.
  final Color surface;

  /// Surface color for hover states.
  final Color surfaceHover;

  /// Surface color for active / pressed states.
  final Color surfaceActive;

  /// A very subtle surface tint, useful for zebra-striped rows or sidebars.
  final Color surfaceSubtle;

  /// Semi-transparent overlay used for modals and drawers.
  final Color overlay;

  // ── Text ─────────────────────────────────────────────────────────────────

  /// Primary text color (highest contrast).
  final Color text;

  /// Secondary / subdued text color.
  final Color textSubtle;

  /// Tertiary / muted text color (placeholders, captions).
  final Color textMuted;

  /// Inverse text color, intended for use on dark surfaces in a light scheme
  /// and vice-versa.
  final Color textInverse;

  /// Text color for content placed directly on the [primary] swatch base.
  final Color textOnPrimary;

  // ── Borders ───────────────────────────────────────────────────────────────

  /// Default border / divider color.
  final Color border;

  /// Subtle border color, lighter than [border].
  final Color borderSubtle;

  /// Border color used to indicate keyboard focus.
  final Color borderFocus;

  /// Border color used to indicate a validation error.
  final Color borderError;

  // ── Glass / frosted ───────────────────────────────────────────────────────

  /// Semi-transparent background for glass / frosted-glass effect surfaces.
  final Color glassBackground;

  /// Semi-transparent border for glass / frosted-glass effect surfaces.
  final Color glassBorder;

  // ── Chart palette ─────────────────────────────────────────────────────────

  /// An ordered list of 8 categorical colors for charts and data visualization.
  final List<Color> chart;

  // ── Utilities ─────────────────────────────────────────────────────────────

  /// Creates a copy of this scheme with the specified fields replaced.
  OiColorScheme copyWith({
    OiColorSwatch? primary,
    OiColorSwatch? accent,
    OiColorSwatch? success,
    OiColorSwatch? warning,
    OiColorSwatch? error,
    OiColorSwatch? info,
    Color? background,
    Color? surface,
    Color? surfaceHover,
    Color? surfaceActive,
    Color? surfaceSubtle,
    Color? overlay,
    Color? text,
    Color? textSubtle,
    Color? textMuted,
    Color? textInverse,
    Color? textOnPrimary,
    Color? border,
    Color? borderSubtle,
    Color? borderFocus,
    Color? borderError,
    Color? glassBackground,
    Color? glassBorder,
    List<Color>? chart,
  }) {
    return OiColorScheme(
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      surfaceActive: surfaceActive ?? this.surfaceActive,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      overlay: overlay ?? this.overlay,
      text: text ?? this.text,
      textSubtle: textSubtle ?? this.textSubtle,
      textMuted: textMuted ?? this.textMuted,
      textInverse: textInverse ?? this.textInverse,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderFocus: borderFocus ?? this.borderFocus,
      borderError: borderError ?? this.borderError,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      chart: chart ?? this.chart,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiColorScheme) return false;
    if (chart.length != other.chart.length) return false;
    for (var i = 0; i < chart.length; i++) {
      if (chart[i] != other.chart[i]) return false;
    }
    return other.primary == primary &&
        other.accent == accent &&
        other.success == success &&
        other.warning == warning &&
        other.error == error &&
        other.info == info &&
        other.background == background &&
        other.surface == surface &&
        other.surfaceHover == surfaceHover &&
        other.surfaceActive == surfaceActive &&
        other.surfaceSubtle == surfaceSubtle &&
        other.overlay == overlay &&
        other.text == text &&
        other.textSubtle == textSubtle &&
        other.textMuted == textMuted &&
        other.textInverse == textInverse &&
        other.textOnPrimary == textOnPrimary &&
        other.border == border &&
        other.borderSubtle == borderSubtle &&
        other.borderFocus == borderFocus &&
        other.borderError == borderError &&
        other.glassBackground == glassBackground &&
        other.glassBorder == glassBorder;
  }

  @override
  int get hashCode => Object.hashAll([
        primary,
        accent,
        success,
        warning,
        error,
        info,
        background,
        surface,
        surfaceHover,
        surfaceActive,
        surfaceSubtle,
        overlay,
        text,
        textSubtle,
        textMuted,
        textInverse,
        textOnPrimary,
        border,
        borderSubtle,
        borderFocus,
        borderError,
        glassBackground,
        glassBorder,
        ...chart,
      ]);

  @override
  String toString() => 'OiColorScheme(background: $background, '
      'surface: $surface, primary: $primary)';
}
