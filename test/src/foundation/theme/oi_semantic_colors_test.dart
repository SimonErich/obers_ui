import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  test('const groups copy every field independently and compare by value', () {
    const alternate = Color(0xFF654321);
    final variations = <Object>[
      _surfaces.copyWith(canvas: alternate),
      _surfaces.copyWith(sheet: alternate),
      _surfaces.copyWith(well: alternate),
      _surfaces.copyWith(overlaySurface: alternate),
      _surfaces.copyWith(line: alternate),
      _surfaces.copyWith(lineStrong: alternate),
      _surfaces.copyWith(border: alternate),
      _surfaces.copyWith(hoverWash: alternate),
      _surfaces.copyWith(pressedWash: alternate),
      _surfaces.copyWith(scrim: alternate),
      _surfaces.copyWith(inverse: alternate),
    ];
    for (final changed in variations) {
      expect(changed, isNot(equals(_surfaces)));
    }
    final inks = [
      _inks.copyWith(primary: alternate),
      _inks.copyWith(muted: alternate),
      _inks.copyWith(subtle: alternate),
      _inks.copyWith(onInverse: alternate),
      _inks.copyWith(inverseMuted: alternate),
    ];
    for (final changed in inks) {
      expect(changed, isNot(equals(_inks)));
    }
    final rail = [
      _rail.copyWith(surface: alternate),
      _rail.copyWith(ink: alternate),
      _rail.copyWith(hoverWash: alternate),
      _rail.copyWith(line: alternate),
      _rail.copyWith(active: alternate),
      _rail.copyWith(onActive: alternate),
      _rail.copyWith(badge: alternate),
      _rail.copyWith(onBadge: alternate),
    ];
    for (final changed in rail) {
      expect(changed, isNot(equals(_rail)));
    }
    final ramp = [
      _ramp.copyWith(first: alternate),
      _ramp.copyWith(second: alternate),
      _ramp.copyWith(third: alternate),
      _ramp.copyWith(fourth: alternate),
      _ramp.copyWith(fifth: alternate),
      _ramp.copyWith(sixth: alternate),
    ];
    for (final changed in ramp) {
      expect(changed, isNot(equals(_ramp)));
    }
    final charts = [
      _charts.copyWith(first: alternate),
      _charts.copyWith(second: alternate),
      _charts.copyWith(third: alternate),
      _charts.copyWith(fourth: alternate),
      _charts.copyWith(fifth: alternate),
      _charts.copyWith(sixth: alternate),
      _charts.copyWith(muted: alternate),
      _charts.copyWith(positive: alternate),
      _charts.copyWith(middle: alternate),
      _charts.copyWith(negative: alternate),
      _charts.copyWith(sequential: ramp.first),
    ];
    for (final changed in charts) {
      expect(changed, isNot(equals(_charts)));
    }
    final roles = [
      _role.copyWith(base: alternate),
      _role.copyWith(onColor: alternate),
      _role.copyWith(ink: alternate),
      _role.copyWith(soft: alternate),
      _role.copyWith(hover: alternate),
      _role.copyWith(pressed: alternate),
      _role.copyWith(softHover: alternate),
    ];
    for (final changed in roles) {
      expect(changed, isNot(equals(_role)));
    }
    final root = [
      _semantic.copyWith(surfaces: variations.first as OiSurfaceColors),
      _semantic.copyWith(inks: inks.first),
      _semantic.copyWith(primary: roles.first),
      _semantic.copyWith(secondary: roles.first),
      _semantic.copyWith(highlight: roles.first),
      _semantic.copyWith(info: roles.first),
      _semantic.copyWith(rail: rail.first),
      _semantic.copyWith(charts: charts.first),
      _semantic.copyWith(focus: alternate),
      _semantic.copyWith(focusHalo: alternate),
    ];
    for (final changed in root) {
      expect(changed, isNot(equals(_semantic)));
    }
    final brandCharts = [
      _brandCharts.copyWith(first: alternate),
      _brandCharts.copyWith(second: alternate),
      _brandCharts.copyWith(third: alternate),
      _brandCharts.copyWith(positive: alternate),
      _brandCharts.copyWith(middle: alternate),
      _brandCharts.copyWith(muted: alternate),
      _brandCharts.copyWith(sequential: ramp.first),
    ];
    for (final changed in brandCharts) {
      expect(changed, isNot(equals(_brandCharts)));
    }
    final brands = [
      _brand.copyWith(primary: roles.first),
      _brand.copyWith(secondary: roles.first),
      _brand.copyWith(highlight: roles.first),
      _brand.copyWith(surfaces: variations.first as OiSurfaceColors),
      _brand.copyWith(inks: inks.first),
      _brand.copyWith(infoColor: alternate),
      _brand.copyWith(infoSoft: alternate),
      _brand.copyWith(rail: rail.first),
      _brand.copyWith(focus: alternate),
      _brand.copyWith(focusHalo: alternate),
      _brand.copyWith(charts: brandCharts.first),
    ];
    for (final changed in brands) {
      expect(changed, isNot(equals(_brand)));
    }
    for (final value in <Object>[
      _surfaces,
      _inks,
      _role,
      _rail,
      _ramp,
      _charts,
      _semantic,
      _brandCharts,
      _brand,
    ]) {
      expect(value, isNot(equals('different type')));
    }
    expect(_surfaces.canvas, _color);
    expect(_semantic.copyWith(), _semantic);
    expect(_semantic.copyWith().hashCode, _semantic.hashCode);
    expect(_brand.copyWith(), _brand);
    expect(_brand.copyWith().hashCode, _brand.hashCode);
  });

  test(
    'optional semantic halo and sequential ramp can be explicitly cleared',
    () {
      final base = OiLegacySemanticColors.fromScheme(OiColorScheme.light());
      const color = Color(0xFF123456);
      const ramp = OiColorRamp(
        first: color,
        second: color,
        third: color,
        fourth: color,
        fifth: color,
        sixth: color,
      );
      final custom = base.copyWith(
        focusHalo: color,
        charts: base.charts.copyWith(sequential: ramp),
      );
      expect(custom.copyWith(clearFocusHalo: true).focusHalo, isNull);
      expect(custom.charts.copyWith(clearSequential: true).sequential, isNull);
      expect(custom.focusHalo, color);
      expect(custom.charts.sequential, ramp);
    },
  );

  test(
    'legacy projection preserves roles and never turns scrim into a surface',
    () {
      for (final scheme in [OiColorScheme.light(), OiColorScheme.dark()]) {
        final semantic = OiLegacySemanticColors.fromScheme(scheme);
        expect(semantic.surfaces.canvas, scheme.background);
        expect(semantic.surfaces.sheet, scheme.surface);
        expect(semantic.surfaces.overlaySurface, scheme.surface);
        expect(semantic.surfaces.scrim, scheme.overlay);
        expect(semantic.inks.primary, scheme.text);
        expect(semantic.inks.muted, scheme.textSubtle);
        expect(semantic.inks.subtle, scheme.textMuted);
        expect(semantic.primary.base, scheme.primary.base);
        expect(semantic.primary.onColor, scheme.primary.foreground);
        expect(semantic.secondary.base, scheme.accent.base);
        expect(semantic.highlight.base, scheme.accent.base);
        expect(semantic.info.soft, scheme.info.muted);
        expect(semantic.focus, scheme.borderFocus);
        expect(semantic.focusHalo, isNull);
        expect(semantic.charts.sequential, isNull);
        expect(semantic.charts.categorical, scheme.chart.take(6).toList());
        expect(semantic.charts.negative, scheme.error.base);
        expect(
          () => semantic.charts.categorical.clear(),
          throwsUnsupportedError,
        );
        expect(semantic.copyWith(), semantic);
        expect(semantic.copyWith().hashCode, semantic.hashCode);
        expect(semantic.charts.copyWith(), semantic.charts);
        expect(semantic.charts.copyWith().hashCode, semantic.charts.hashCode);
        expect(scheme.chart, hasLength(8));
      }
    },
  );

  test(
    'legacy chart projection snapshots a mutable short or empty palette',
    () {
      final colors = [const Color(0xFF123456)];
      final scheme = OiColorScheme.light().copyWith(chart: colors);
      final semantic = OiLegacySemanticColors.fromScheme(scheme);
      colors[0] = const Color(0xFF654321);
      expect(semantic.charts.first, const Color(0xFF123456));
      expect(semantic.charts.second, scheme.accent.base);
      expect(semantic.charts.sixth, scheme.info.base);
      final empty = OiLegacySemanticColors.fromScheme(
        scheme.copyWith(chart: []),
      );
      expect(empty.charts.first, scheme.primary.base);
    },
  );
}

const _color = Color(0xFF123456);
const _surfaces = OiSurfaceColors(
  canvas: _color,
  sheet: _color,
  well: _color,
  overlaySurface: _color,
  line: _color,
  lineStrong: _color,
  border: _color,
  hoverWash: _color,
  pressedWash: _color,
  scrim: _color,
  inverse: _color,
);
const _inks = OiInkColors(
  primary: _color,
  muted: _color,
  subtle: _color,
  onInverse: _color,
  inverseMuted: _color,
);
const _role = OiRoleColors(
  base: _color,
  onColor: _color,
  ink: _color,
  soft: _color,
);
const _rail = OiRailColors(
  surface: _color,
  ink: _color,
  hoverWash: _color,
  line: _color,
  active: _color,
  onActive: _color,
  badge: _color,
  onBadge: _color,
);
const _ramp = OiColorRamp(
  first: _color,
  second: _color,
  third: _color,
  fourth: _color,
  fifth: _color,
  sixth: _color,
);
const _charts = OiChartColors(
  first: _color,
  second: _color,
  third: _color,
  fourth: _color,
  fifth: _color,
  sixth: _color,
  muted: _color,
  positive: _color,
  middle: _color,
  negative: _color,
  sequential: _ramp,
);
const _semantic = OiSemanticColors(
  surfaces: _surfaces,
  inks: _inks,
  primary: _role,
  secondary: _role,
  highlight: _role,
  info: _role,
  rail: _rail,
  charts: _charts,
  focus: _color,
);
const _brandCharts = OiBrandCharts(
  first: _color,
  second: _color,
  third: _color,
  positive: _color,
  middle: _color,
  muted: _color,
  sequential: _ramp,
);
const _brand = OiBrandPalette(
  primary: _role,
  secondary: _role,
  highlight: _role,
  surfaces: _surfaces,
  inks: _inks,
  infoColor: _color,
  infoSoft: _color,
  rail: _rail,
  focus: _color,
  focusHalo: _color,
  charts: _brandCharts,
);
