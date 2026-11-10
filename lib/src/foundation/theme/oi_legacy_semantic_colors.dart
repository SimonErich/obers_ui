import 'package:obers_ui/src/foundation/theme/oi_chart_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_swatch.dart';
import 'package:obers_ui/src/foundation/theme/oi_ink_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_rail_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_role_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_semantic_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_surface_colors.dart';

/// Projects legacy colors without deriving a new palette or changing widgets.
///
/// {@category Foundation}
abstract final class OiLegacySemanticColors {
  /// Snapshots an existing scheme into explicit groups.
  ///
  /// Legacy accent supplies both secondary and highlight. Swatch dark/muted
  /// supply ink/soft, light/dark supply hover/pressed. Missing chart slots use
  /// primary, accent, success, warning, error and info respectively. Overlay
  /// remains the scrim; overlaySurface uses surface. No halo/ramp is invented.
  /// Legacy hover/pressed surfaces are retained even if they are opaque.
  static OiSemanticColors fromScheme(OiColorScheme scheme) {
    final fallback = [
      scheme.primary.base,
      scheme.accent.base,
      scheme.success.base,
      scheme.warning.base,
      scheme.error.base,
      scheme.info.base,
    ];
    final chart = List.generate(
      6,
      (index) =>
          index < scheme.chart.length ? scheme.chart[index] : fallback[index],
    );
    return OiSemanticColors(
      surfaces: OiSurfaceColors(
        canvas: scheme.background,
        sheet: scheme.surface,
        well: scheme.surfaceSubtle,
        overlaySurface: scheme.surface,
        line: scheme.borderSubtle,
        lineStrong: scheme.border,
        border: scheme.border,
        hoverWash: scheme.surfaceHover,
        pressedWash: scheme.surfaceActive,
        scrim: scheme.overlay,
        inverse: scheme.text,
      ),
      inks: OiInkColors(
        primary: scheme.text,
        muted: scheme.textSubtle,
        subtle: scheme.textMuted,
        onInverse: scheme.textInverse,
        inverseMuted: scheme.textMuted,
      ),
      primary: _role(scheme.primary),
      secondary: _role(scheme.accent),
      highlight: _role(scheme.accent),
      info: _role(scheme.info),
      rail: OiRailColors(
        surface: scheme.surface,
        ink: scheme.textSubtle,
        hoverWash: scheme.surfaceHover,
        line: scheme.borderSubtle,
        active: scheme.primary.base,
        onActive: scheme.primary.foreground,
        badge: scheme.accent.base,
        onBadge: scheme.accent.foreground,
      ),
      charts: OiChartColors(
        first: chart[0],
        second: chart[1],
        third: chart[2],
        fourth: chart[3],
        fifth: chart[4],
        sixth: chart[5],
        muted: scheme.textMuted,
        positive: scheme.success.base,
        middle: scheme.textMuted,
        negative: scheme.error.base,
      ),
      focus: scheme.borderFocus,
    );
  }

  static OiRoleColors _role(OiColorSwatch swatch) => OiRoleColors(
    base: swatch.base,
    onColor: swatch.foreground,
    ink: swatch.dark,
    soft: swatch.muted,
    hover: swatch.light,
    pressed: swatch.dark,
    softHover: swatch.light,
  );
}
