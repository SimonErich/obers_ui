// Tests for OiEffectsTheme — no public API docs needed in test files.
// ignore_for_file: public_member_api_docs

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';

void main() {
  group('OiHaloStyle', () {
    test('from sets alpha from intensity', () {
      const base = Color(0xFF2563EB);
      final halo = OiHaloStyle.from(base, intensity: 0.4);
      expect(halo.color.a, closeTo(0.4, 0.01));
    });

    test('from uses default intensity 0.3 when omitted', () {
      const base = Color(0xFF2563EB);
      final halo = OiHaloStyle.from(base);
      expect(halo.color.a, closeTo(0.3, 0.01));
    });

    test('toBoxShadow returns BoxShadow with matching values', () {
      const halo = OiHaloStyle(color: Color(0x402563EB), spread: 3, blur: 10);
      final shadow = halo.toBoxShadow();
      expect(shadow.color, equals(halo.color));
      expect(shadow.spreadRadius, equals(halo.spread));
      expect(shadow.blurRadius, equals(halo.blur));
    });

    test('none is fully transparent with zero spread and blur', () {
      expect(OiHaloStyle.none.color.a, equals(0.0));
      expect(OiHaloStyle.none.spread, equals(0));
      expect(OiHaloStyle.none.blur, equals(0));
    });

    test('copyWith overrides only specified fields', () {
      const original = OiHaloStyle(
        color: Color(0xFF000000),
        spread: 2,
        blur: 8,
      );
      final copy = original.copyWith(blur: 12);
      expect(copy.blur, equals(12));
      expect(copy.spread, equals(original.spread));
      expect(copy.color, equals(original.color));
    });

    test('equality holds for identical values', () {
      const a = OiHaloStyle(color: Color(0xFF000000), spread: 2, blur: 8);
      const b = OiHaloStyle(color: Color(0xFF000000), spread: 2, blur: 8);
      expect(a, equals(b));
    });

    test('hashCode is consistent', () {
      const a = OiHaloStyle(color: Color(0xFF000000), spread: 2, blur: 8);
      const b = OiHaloStyle(color: Color(0xFF000000), spread: 2, blur: 8);
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('OiFocusRingStyle', () {
    test('standard factory sets color from primaryColor with alpha 0.85', () {
      const primary = Color(0xFF2563EB);
      final ring = OiFocusRingStyle.standard(primary);
      expect(ring.color.a, closeTo(0.85, 0.01));
      expect(ring.width, equals(2.0));
    });

    test('enforced clamps zero-alpha color to 0.5', () {
      const ring = OiFocusRingStyle(color: Color(0x00FF0000), width: 2.0);
      expect(ring.enforced.color.a, greaterThanOrEqualTo(0.5));
    });

    test('enforced clamps sub-minimum width to 2.0', () {
      const ring = OiFocusRingStyle(color: Color(0xFFFF0000), width: 0.5);
      expect(ring.enforced.width, equals(2.0));
    });

    test('enforced preserves already-valid values', () {
      const ring = OiFocusRingStyle(color: Color(0xCCFF0000), width: 3.0);
      final enforced = ring.enforced;
      expect(enforced.color.a, closeTo(ring.color.a, 0.01));
      expect(enforced.width, equals(3.0));
    });

    test('copyWith overrides only specified fields', () {
      const ring = OiFocusRingStyle(color: Color(0xFFFF0000), width: 2.0);
      final copy = ring.copyWith(width: 4.0);
      expect(copy.width, equals(4.0));
      expect(copy.color, equals(ring.color));
    });

    test('hashCode is consistent for equal values', () {
      const a = OiFocusRingStyle(color: Color(0xFF2563EB), width: 2.0);
      const b = OiFocusRingStyle(color: Color(0xFF2563EB), width: 2.0);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality holds for identical values', () {
      const a = OiFocusRingStyle(color: Color(0xFF2563EB), width: 2.0);
      const b = OiFocusRingStyle(color: Color(0xFF2563EB), width: 2.0);
      expect(a, equals(b));
    });
  });

  group('OiInteractiveStyle', () {
    test('copyWith overrides only specified fields', () {
      const original = OiInteractiveStyle(
        backgroundOverlay: Color(0x0A000000),
        halo: OiHaloStyle.none,
        scale: 0.97,
      );
      final copy = original.copyWith(scale: 1.0);
      expect(copy.scale, equals(1.0));
      expect(copy.backgroundOverlay, equals(original.backgroundOverlay));
      expect(copy.halo, equals(original.halo));
    });

    test('none has zero-alpha overlay and no halo', () {
      expect(OiInteractiveStyle.none.backgroundOverlay.a, equals(0.0));
      expect(OiInteractiveStyle.none.halo, equals(OiHaloStyle.none));
    });

    test('hashCode is consistent for equal values', () {
      const a = OiInteractiveStyle(
        backgroundOverlay: Color(0x0A000000),
        halo: OiHaloStyle.none,
      );
      const b = OiInteractiveStyle(
        backgroundOverlay: Color(0x0A000000),
        halo: OiHaloStyle.none,
      );
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('OiEffectsTheme.standard', () {
    const primary = Color(0xFF2563EB);
    late OiEffectsTheme theme;

    setUp(() {
      theme = OiEffectsTheme.standard(primaryColor: primary);
    });

    test('returns non-null hover style', () {
      expect(theme.hover, isNotNull);
    });

    test('returns non-null focus style', () {
      expect(theme.focus, isNotNull);
    });

    test('returns non-null active style', () {
      expect(theme.active, isNotNull);
    });

    test('returns non-null disabled style', () {
      expect(theme.disabled, isNotNull);
    });

    test('returns non-null selected style', () {
      expect(theme.selected, isNotNull);
    });

    test('returns non-null dragging style', () {
      expect(theme.dragging, isNotNull);
    });

    test('returns non-null focusRing', () {
      expect(theme.focusRing, isNotNull);
    });

    test('focusRing width is at least 2.0', () {
      expect(theme.focusRing.width, greaterThanOrEqualTo(2.0));
    });

    test('focusRing color has non-zero alpha', () {
      expect(theme.focusRing.color.a, greaterThan(0.0));
    });

    test('focus has a non-zero halo blur', () {
      expect(theme.focus.halo.blur, greaterThan(0));
    });

    test('focus has a non-zero halo spread', () {
      expect(theme.focus.halo.spread, greaterThan(0));
    });

    test('active scale is less than 1', () {
      expect(theme.active.scale, lessThan(1.0));
    });

    test('dragging scale is greater than 1', () {
      expect(theme.dragging.scale, greaterThan(1.0));
    });

    test('hover scale is 1.0', () {
      expect(theme.hover.scale, equals(1.0));
    });

    test('disabled has no halo', () {
      expect(theme.disabled.halo, equals(OiHaloStyle.none));
    });
  });

  group('OiEffectsTheme.copyWith', () {
    test('overrides only specified field', () {
      const primary = Color(0xFF2563EB);
      final theme = OiEffectsTheme.standard(primaryColor: primary);
      const newHover = OiInteractiveStyle(
        backgroundOverlay: Color(0x20FF0000),
        halo: OiHaloStyle.none,
      );
      final copy = theme.copyWith(hover: newHover);
      expect(copy.hover, equals(newHover));
      expect(copy.focus, equals(theme.focus));
      expect(copy.active, equals(theme.active));
    });

    test('equality holds when no fields change', () {
      const primary = Color(0xFF2563EB);
      final theme = OiEffectsTheme.standard(primaryColor: primary);
      final copy = theme.copyWith();
      expect(copy, equals(theme));
    });

    test('hashCode is consistent', () {
      const primary = Color(0xFF2563EB);
      final a = OiEffectsTheme.standard(primaryColor: primary);
      final b = OiEffectsTheme.standard(primaryColor: primary);
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
