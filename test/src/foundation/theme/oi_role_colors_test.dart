import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  test('optional interaction colors can be explicitly cleared', () {
    const color = Color(0xFF123456);
    const role = OiRoleColors(
      base: color,
      onColor: color,
      ink: color,
      soft: color,
      hover: color,
      pressed: color,
      softHover: color,
    );
    expect(role.copyWith(clearHover: true).hover, isNull);
    expect(role.copyWith(clearPressed: true).pressed, isNull);
    expect(role.copyWith(clearSoftHover: true).softHover, isNull);
    expect(role.copyWith(clearHover: true).pressed, color);
    expect(role.hover, color);
  });

  test('semantic role copies are independent immutable values', () {
    const role = OiRoleColors(
      base: Color(0xFF625FAC),
      onColor: Color(0xFFFFFFFF),
      ink: Color(0xFF5B58A0),
      soft: Color(0xFFEEEFFC),
    );
    final changed = role.copyWith(ink: const Color(0xFF000000));
    expect(changed.ink, const Color(0xFF000000));
    expect(role.ink, const Color(0xFF5B58A0));
    expect(changed.base, const Color(0xFF625FAC));
    expect(changed.onColor, const Color(0xFFFFFFFF));
    expect(changed.soft, const Color(0xFFEEEFFC));
    final restored = changed.copyWith(ink: const Color(0xFF5B58A0));
    expect(restored, role);
    expect(restored.hashCode, role.hashCode);
    expect(restored.hover, isNull);
    expect(restored.pressed, isNull);
    expect(restored.softHover, isNull);
  });
}
