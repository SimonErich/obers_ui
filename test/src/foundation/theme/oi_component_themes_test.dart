// Tests for OiComponentThemes — no public API docs needed in test files.

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_component_themes.dart';

void main() {
  group('OiComponentThemes.empty', () {
    test('button is null', () {
      expect(const OiComponentThemes.empty().button, isNull);
    });

    test('textInput is null', () {
      expect(const OiComponentThemes.empty().textInput, isNull);
    });

    test('select is null', () {
      expect(const OiComponentThemes.empty().select, isNull);
    });

    test('card is null', () {
      expect(const OiComponentThemes.empty().card, isNull);
    });

    test('dialog is null', () {
      expect(const OiComponentThemes.empty().dialog, isNull);
    });

    test('toast is null', () {
      expect(const OiComponentThemes.empty().toast, isNull);
    });

    test('tooltip is null', () {
      expect(const OiComponentThemes.empty().tooltip, isNull);
    });

    test('table is null', () {
      expect(const OiComponentThemes.empty().table, isNull);
    });

    test('tabs is null', () {
      expect(const OiComponentThemes.empty().tabs, isNull);
    });

    test('badge is null', () {
      expect(const OiComponentThemes.empty().badge, isNull);
    });

    test('checkbox is null', () {
      expect(const OiComponentThemes.empty().checkbox, isNull);
    });

    test('switchTheme is null', () {
      expect(const OiComponentThemes.empty().switchTheme, isNull);
    });

    test('sheet is null', () {
      expect(const OiComponentThemes.empty().sheet, isNull);
    });

    test('avatar is null', () {
      expect(const OiComponentThemes.empty().avatar, isNull);
    });

    test('progress is null', () {
      expect(const OiComponentThemes.empty().progress, isNull);
    });

    test('sidebar is null', () {
      expect(const OiComponentThemes.empty().sidebar, isNull);
    });
  });

  group('OiComponentThemes.copyWith', () {
    test('overrides button only', () {
      const original = OiComponentThemes.empty();
      final buttonTheme = OiButtonThemeData(
        borderRadius: BorderRadius.circular(8),
      );
      final copy = original.copyWith(button: buttonTheme);
      expect(copy.button, equals(buttonTheme));
      expect(copy.card, isNull);
      expect(copy.textInput, isNull);
    });

    test('overrides card only', () {
      const original = OiComponentThemes.empty();
      const cardTheme = OiCardThemeData(elevation: 4);
      final copy = original.copyWith(card: cardTheme);
      expect(copy.card, equals(cardTheme));
      expect(copy.button, isNull);
    });

    test('overrides sidebar only', () {
      const original = OiComponentThemes.empty();
      const sidebarTheme = OiSidebarThemeData(width: 240, compactWidth: 64);
      final copy = original.copyWith(sidebar: sidebarTheme);
      expect(copy.sidebar, equals(sidebarTheme));
      expect(copy.progress, isNull);
    });

    test('multiple overrides apply independently', () {
      const original = OiComponentThemes.empty();
      const toastTheme = OiToastThemeData(elevation: 6);
      const switchTheme = OiSwitchThemeData(width: 44, height: 24);
      final copy = original.copyWith(
        toast: toastTheme,
        switchTheme: switchTheme,
      );
      expect(copy.toast, equals(toastTheme));
      expect(copy.switchTheme, equals(switchTheme));
      expect(copy.badge, isNull);
    });
  });

  group('OiComponentThemes equality', () {
    test('two empty instances are equal', () {
      const a = OiComponentThemes.empty();
      const b = OiComponentThemes.empty();
      expect(a, equals(b));
    });

    test('hashCode is consistent for empty instances', () {
      const a = OiComponentThemes.empty();
      const b = OiComponentThemes.empty();
      expect(a.hashCode, equals(b.hashCode));
    });

    test('instances with same overrides are equal', () {
      const theme = OiCardThemeData(elevation: 2);
      final a = const OiComponentThemes.empty().copyWith(card: theme);
      final b = const OiComponentThemes.empty().copyWith(card: theme);
      expect(a, equals(b));
    });

    test('instances with different overrides are not equal', () {
      final a = const OiComponentThemes.empty().copyWith(
        card: const OiCardThemeData(elevation: 2),
      );
      final b = const OiComponentThemes.empty().copyWith(
        card: const OiCardThemeData(elevation: 4),
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('individual component theme data', () {
    test('OiButtonThemeData copyWith overrides textStyle only', () {
      const original = OiButtonThemeData(padding: EdgeInsets.all(8));
      const newStyle = TextStyle(fontSize: 14);
      final copy = original.copyWith(textStyle: newStyle);
      expect(copy.textStyle, equals(newStyle));
      expect(copy.padding, equals(const EdgeInsets.all(8)));
    });

    test('OiTextInputThemeData equality', () {
      const a = OiTextInputThemeData(borderColor: Color(0xFF000000));
      const b = OiTextInputThemeData(borderColor: Color(0xFF000000));
      expect(a, equals(b));
    });

    test('OiTableThemeData copyWith overrides rowHeight only', () {
      const original = OiTableThemeData(headerHeight: 48, rowHeight: 40);
      final copy = original.copyWith(rowHeight: 56);
      expect(copy.rowHeight, equals(56));
      expect(copy.headerHeight, equals(48));
    });

    test('OiSwitchThemeData equality', () {
      const a = OiSwitchThemeData(width: 44, height: 24);
      const b = OiSwitchThemeData(width: 44, height: 24);
      expect(a, equals(b));
    });

    test('OiSidebarThemeData equality', () {
      const a = OiSidebarThemeData(width: 240, compactWidth: 64);
      const b = OiSidebarThemeData(width: 240, compactWidth: 64);
      expect(a, equals(b));
    });

    test('OiProgressThemeData copyWith overrides height only', () {
      const original = OiProgressThemeData(height: 4);
      final copy = original.copyWith(height: 8);
      expect(copy.height, equals(8));
      expect(copy.borderRadius, isNull);
    });
  });
}
