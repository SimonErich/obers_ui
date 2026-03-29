// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_navigation_item.dart';

void main() {
  group('OiNavigationItem', () {
    // ── Construction ─────────────────────────────────────────────────────────

    test('default construction has expected defaults', () {
      const item = OiNavigationItem(
        icon: IconData(0xe88a),
        label: 'Home',
      );
      expect(item.icon, const IconData(0xe88a));
      expect(item.label, 'Home');
      expect(item.activeIcon, isNull);
      expect(item.badge, isNull);
      expect(item.tooltip, isNull);
      expect(item.semanticLabel, isNull);
    });

    test('all fields are stored', () {
      const item = OiNavigationItem(
        icon: IconData(1),
        label: 'Tab',
        activeIcon: IconData(2),
        badge: '3',
        tooltip: 'Hover me',
        semanticLabel: 'Tab button',
      );
      expect(item.icon, const IconData(1));
      expect(item.label, 'Tab');
      expect(item.activeIcon, const IconData(2));
      expect(item.badge, '3');
      expect(item.tooltip, 'Hover me');
      expect(item.semanticLabel, 'Tab button');
    });

    // ── Equality ─────────────────────────────────────────────────────────────

    test('equal instances are ==', () {
      const a = OiNavigationItem(icon: IconData(1), label: 'Home');
      const b = OiNavigationItem(icon: IconData(1), label: 'Home');
      expect(a, equals(b));
    });

    test('equal instances have the same hashCode', () {
      const a = OiNavigationItem(icon: IconData(1), label: 'Home');
      const b = OiNavigationItem(icon: IconData(1), label: 'Home');
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when label differs', () {
      const a = OiNavigationItem(icon: IconData(1), label: 'Home');
      const b = OiNavigationItem(icon: IconData(1), label: 'Search');
      expect(a, isNot(equals(b)));
    });

    test('inequality when icon differs', () {
      const a = OiNavigationItem(icon: IconData(1), label: 'Home');
      const b = OiNavigationItem(icon: IconData(2), label: 'Home');
      expect(a, isNot(equals(b)));
    });

    test('inequality when badge differs', () {
      const a = OiNavigationItem(
        icon: IconData(1),
        label: 'Home',
        badge: '3',
      );
      const b = OiNavigationItem(icon: IconData(1), label: 'Home');
      expect(a, isNot(equals(b)));
    });

    // ── fromLegacy ───────────────────────────────────────────────────────────

    test('fromLegacy converts badge count to string', () {
      final item = OiNavigationItem.fromLegacy(
        icon: const IconData(1),
        label: 'X',
        badgeCount: 5,
      );
      expect(item.badge, '5');
    });

    test('fromLegacy caps badge at 99+', () {
      final item = OiNavigationItem.fromLegacy(
        icon: const IconData(1),
        label: 'X',
        badgeCount: 150,
      );
      expect(item.badge, '99+');
    });

    test('fromLegacy with exactly 99 shows 99', () {
      final item = OiNavigationItem.fromLegacy(
        icon: const IconData(1),
        label: 'X',
        badgeCount: 99,
      );
      expect(item.badge, '99');
    });

    test('fromLegacy with exactly 100 shows 99+', () {
      final item = OiNavigationItem.fromLegacy(
        icon: const IconData(1),
        label: 'X',
        badgeCount: 100,
      );
      expect(item.badge, '99+');
    });

    test('fromLegacy with showBadge false produces null badge', () {
      final item = OiNavigationItem.fromLegacy(
        icon: const IconData(1),
        label: 'X',
        badgeCount: 5,
        showBadge: false,
      );
      expect(item.badge, isNull);
    });

    test('fromLegacy with null badgeCount produces null badge', () {
      final item = OiNavigationItem.fromLegacy(
        icon: const IconData(1),
        label: 'X',
      );
      expect(item.badge, isNull);
    });

    test('fromLegacy with zero badgeCount produces null badge', () {
      final item = OiNavigationItem.fromLegacy(
        icon: const IconData(1),
        label: 'X',
        badgeCount: 0,
      );
      expect(item.badge, isNull);
    });

    test('fromLegacy preserves icon, label, and activeIcon', () {
      final item = OiNavigationItem.fromLegacy(
        icon: const IconData(42),
        label: 'Messages',
        activeIcon: const IconData(43),
      );
      expect(item.icon, const IconData(42));
      expect(item.label, 'Messages');
      expect(item.activeIcon, const IconData(43));
    });
  });
}
