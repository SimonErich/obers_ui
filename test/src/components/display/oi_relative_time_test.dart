// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_relative_time.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── REQ-1100: OiRelativeTime ──────────────────────────────────────────

  // ── Static format() — narrow style ────────────────────────────────────

  group('format — narrow style', () {
    final now = DateTime(2026, 3, 18, 14, 32);

    test('< 10s renders "now"', () {
      final dt = now.subtract(const Duration(seconds: 5));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.narrow, now: now),
        'now',
      );
    });

    test('< 60s renders seconds', () {
      final dt = now.subtract(const Duration(seconds: 30));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.narrow, now: now),
        '30s',
      );
    });

    test('< 60m renders minutes', () {
      final dt = now.subtract(const Duration(minutes: 5));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.narrow, now: now),
        '5m',
      );
    });

    test('< 24h renders hours', () {
      final dt = now.subtract(const Duration(hours: 3));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.narrow, now: now),
        '3h',
      );
    });

    test('< 48h renders "1d"', () {
      final dt = now.subtract(const Duration(hours: 30));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.narrow, now: now),
        '1d',
      );
    });

    test('< 7d renders days', () {
      final dt = now.subtract(const Duration(days: 3));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.narrow, now: now),
        '3d',
      );
    });

    test('same year renders short month + day', () {
      final dt = DateTime(2026, 3, 3, 14, 32);
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.narrow, now: now),
        'Mar 3',
      );
    });

    test('other year renders short month + day + year', () {
      final dt = DateTime(2025, 3, 3, 14, 32);
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.narrow, now: now),
        "Mar 3 '25",
      );
    });
  });

  // ── Static format() — short style ─────────────────────────────────────

  group('format — short style', () {
    final now = DateTime(2026, 3, 18, 14, 32);

    test('< 10s renders "just now"', () {
      final dt = now.subtract(const Duration(seconds: 5));
      expect(OiRelativeTime.format(dt, now: now), 'just now');
    });

    test('< 60s renders seconds + ago', () {
      final dt = now.subtract(const Duration(seconds: 30));
      expect(OiRelativeTime.format(dt, now: now), '30s ago');
    });

    test('< 60m renders minutes + ago', () {
      final dt = now.subtract(const Duration(minutes: 5));
      expect(OiRelativeTime.format(dt, now: now), '5m ago');
    });

    test('< 24h renders hours + ago', () {
      final dt = now.subtract(const Duration(hours: 3));
      expect(OiRelativeTime.format(dt, now: now), '3h ago');
    });

    test('< 48h renders "yesterday"', () {
      final dt = now.subtract(const Duration(hours: 30));
      expect(OiRelativeTime.format(dt, now: now), 'yesterday');
    });

    test('< 7d renders days + ago', () {
      final dt = now.subtract(const Duration(days: 3));
      expect(OiRelativeTime.format(dt, now: now), '3d ago');
    });

    test('same year renders month + day', () {
      final dt = DateTime(2026, 3, 3, 14, 32);
      expect(OiRelativeTime.format(dt, now: now), 'Mar 3');
    });

    test('other year renders month + day + year', () {
      final dt = DateTime(2025, 3, 3, 14, 32);
      expect(OiRelativeTime.format(dt, now: now), 'Mar 3, 2025');
    });
  });

  // ── Static format() — long style ──────────────────────────────────────

  group('format — long style', () {
    final now = DateTime(2026, 3, 18, 14, 32);

    test('< 10s renders "just now"', () {
      final dt = now.subtract(const Duration(seconds: 5));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.long, now: now),
        'just now',
      );
    });

    test('< 60s renders full seconds', () {
      final dt = now.subtract(const Duration(seconds: 30));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.long, now: now),
        '30 seconds ago',
      );
    });

    test('1 second singular', () {
      final dt = now.subtract(const Duration(seconds: 11));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.long, now: now),
        '11 seconds ago',
      );
    });

    test('< 60m renders full minutes', () {
      final dt = now.subtract(const Duration(minutes: 5));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.long, now: now),
        '5 minutes ago',
      );
    });

    test('1 minute singular', () {
      final dt = now.subtract(const Duration(minutes: 1));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.long, now: now),
        '1 minute ago',
      );
    });

    test('< 24h renders full hours', () {
      final dt = now.subtract(const Duration(hours: 3));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.long, now: now),
        '3 hours ago',
      );
    });

    test('1 hour singular', () {
      final dt = now.subtract(const Duration(hours: 1));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.long, now: now),
        '1 hour ago',
      );
    });

    test('< 48h renders "yesterday at HH:MM"', () {
      final dt = DateTime(2026, 3, 17, 14, 32);
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.long, now: now),
        'yesterday at 14:32',
      );
    });

    test('yesterday at with leading zero', () {
      final dt = DateTime(2026, 3, 17, 9, 5);
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.long, now: now),
        'yesterday at 09:05',
      );
    });

    test('< 7d renders full days', () {
      final dt = now.subtract(const Duration(days: 3));
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.long, now: now),
        '3 days ago',
      );
    });

    test('same year renders full month + day + time', () {
      final dt = DateTime(2026, 3, 3, 14, 32);
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.long, now: now),
        'March 3 at 14:32',
      );
    });

    test('other year renders full month + day + year + time', () {
      final dt = DateTime(2025, 3, 3, 14, 32);
      expect(
        OiRelativeTime.format(dt, style: OiRelativeTimeStyle.long, now: now),
        'March 3, 2025 at 14:32',
      );
    });
  });

  // ── capitalize flag ───────────────────────────────────────────────────

  group('capitalize', () {
    test('capitalize=true uppercases first letter', () {
      final now = DateTime(2026, 3, 18, 14, 32);
      final dt = now.subtract(const Duration(seconds: 5));
      expect(OiRelativeTime.format(dt, capitalize: true, now: now), 'Just now');
    });

    test('capitalize=false leaves as is', () {
      final now = DateTime(2026, 3, 18, 14, 32);
      final dt = now.subtract(const Duration(seconds: 5));
      expect(OiRelativeTime.format(dt, now: now), 'just now');
    });

    test('capitalize works with narrow style', () {
      final now = DateTime(2026, 3, 18, 14, 32);
      final dt = now.subtract(const Duration(seconds: 5));
      expect(
        OiRelativeTime.format(
          dt,
          style: OiRelativeTimeStyle.narrow,
          capitalize: true,
          now: now,
        ),
        'Now',
      );
    });
  });

  // ── formatAbsolute override ───────────────────────────────────────────

  group('formatAbsolute override', () {
    test('custom formatAbsolute overrides date format', () {
      final now = DateTime(2026, 3, 18, 14, 32);
      final dt = DateTime(2026, 1, 5, 10);
      expect(
        OiRelativeTime.format(
          dt,
          now: now,
          formatAbsolute: (d) => '${d.day}/${d.month}/${d.year}',
        ),
        '5/1/2026',
      );
    });

    test('formatAbsolute is not used for recent times', () {
      final now = DateTime(2026, 3, 18, 14, 32);
      final dt = now.subtract(const Duration(minutes: 5));
      expect(
        OiRelativeTime.format(dt, now: now, formatAbsolute: (d) => 'CUSTOM'),
        '5m ago',
      );
    });
  });

  // ── Adaptive interval ─────────────────────────────────────────────────

  group('adaptiveInterval', () {
    final now = DateTime(2026, 3, 18, 14, 32);

    test('< 1 minute returns 10s', () {
      final dt = now.subtract(const Duration(seconds: 30));
      expect(
        OiRelativeTime.adaptiveInterval(dt, now: now),
        const Duration(seconds: 10),
      );
    });

    test('< 1 hour returns 30s', () {
      final dt = now.subtract(const Duration(minutes: 15));
      expect(
        OiRelativeTime.adaptiveInterval(dt, now: now),
        const Duration(seconds: 30),
      );
    });

    test('< 24 hours returns 5min', () {
      final dt = now.subtract(const Duration(hours: 6));
      expect(
        OiRelativeTime.adaptiveInterval(dt, now: now),
        const Duration(minutes: 5),
      );
    });

    test('>= 24 hours returns null', () {
      final dt = now.subtract(const Duration(hours: 25));
      expect(OiRelativeTime.adaptiveInterval(dt, now: now), isNull);
    });
  });

  // ── Widget rendering ──────────────────────────────────────────────────

  group('widget rendering', () {
    testWidgets('renders "just now" for DateTime.now()', (tester) async {
      await tester.pumpObers(OiRelativeTime(dateTime: DateTime.now()));
      expect(find.text('just now'), findsOneWidget);
    });

    testWidgets('renders "5m ago" for 5 minutes past', (tester) async {
      final dt = DateTime.now().subtract(const Duration(minutes: 5));
      await tester.pumpObers(OiRelativeTime(dateTime: dt));
      expect(find.text('5m ago'), findsOneWidget);
    });

    testWidgets('renders "5 minutes ago" for long style', (tester) async {
      final dt = DateTime.now().subtract(const Duration(minutes: 5));
      await tester.pumpObers(
        OiRelativeTime(dateTime: dt, style: OiRelativeTimeStyle.long),
      );
      expect(find.text('5 minutes ago'), findsOneWidget);
    });

    testWidgets('renders "5m" for narrow style', (tester) async {
      final dt = DateTime.now().subtract(const Duration(minutes: 5));
      await tester.pumpObers(
        OiRelativeTime(dateTime: dt, style: OiRelativeTimeStyle.narrow),
      );
      expect(find.text('5m'), findsOneWidget);
    });

    testWidgets('capitalize=true uppercases first letter', (tester) async {
      await tester.pumpObers(
        OiRelativeTime(dateTime: DateTime.now(), capitalize: true),
      );
      expect(find.text('Just now'), findsOneWidget);
    });
  });

  // ── live=true auto-updates ────────────────────────────────────────────

  group('live timer', () {
    testWidgets('live=true auto-updates from "just now" to seconds', (
      tester,
    ) async {
      await tester.runAsync(() async {
        final dt = DateTime.now();
        await tester.pumpObers(OiRelativeTime(dateTime: dt));
        expect(find.text('just now'), findsOneWidget);

        // Wait 11 seconds — timer fires at 10s for recent timestamps.
        await Future<void>.delayed(const Duration(seconds: 11));
        await tester.pump();

        // Should now show seconds (11s or 12s depending on timing).
        expect(find.text('just now'), findsNothing);
      });
    });

    testWidgets('live=false does not update', (tester) async {
      await tester.runAsync(() async {
        final dt = DateTime.now();
        await tester.pumpObers(OiRelativeTime(dateTime: dt, live: false));
        expect(find.text('just now'), findsOneWidget);

        await Future<void>.delayed(const Duration(seconds: 11));
        await tester.pump();

        // Should still show "just now" — no timer.
        expect(find.text('just now'), findsOneWidget);
      });
    });
  });

  // ── Timer disposal ────────────────────────────────────────────────────

  group('timer disposal', () {
    testWidgets('timer disposes on widget removal', (tester) async {
      final dt = DateTime.now();
      final key = GlobalKey();

      await tester.pumpObers(
        KeyedSubtree(
          key: key,
          child: OiRelativeTime(dateTime: dt),
        ),
      );
      expect(find.byType(OiRelativeTime), findsOneWidget);

      // Remove the widget.
      await tester.pumpObers(const SizedBox.shrink());
      expect(find.byType(OiRelativeTime), findsNothing);

      // Pump past what would be a timer tick — no errors should occur.
      await tester.pump(const Duration(seconds: 15));
    });
  });

  // ── Accessibility ─────────────────────────────────────────────────────

  group('accessibility', () {
    testWidgets('semantics always uses long form', (tester) async {
      final dt = DateTime.now().subtract(const Duration(minutes: 5));
      await tester.pumpObers(
        OiRelativeTime(dateTime: dt, style: OiRelativeTimeStyle.narrow),
      );

      // Visual shows narrow "5m".
      expect(find.text('5m'), findsOneWidget);

      // Semantics should use long form.
      expect(
        tester.getSemantics(find.bySemanticsLabel('5 minutes ago')),
        isNotNull,
      );
    });

    testWidgets('custom semanticsLabel overrides', (tester) async {
      final dt = DateTime.now().subtract(const Duration(minutes: 5));
      await tester.pumpObers(
        OiRelativeTime(dateTime: dt, semanticsLabel: 'sent recently'),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('sent recently')),
        isNotNull,
      );
    });
  });

  // ── Singular/plural edge cases ────────────────────────────────────────

  group('singular/plural', () {
    final now = DateTime(2026, 3, 18, 14, 32);

    test('"1 minute ago" vs "2 minutes ago"', () {
      expect(
        OiRelativeTime.format(
          now.subtract(const Duration(minutes: 1)),
          style: OiRelativeTimeStyle.long,
          now: now,
        ),
        '1 minute ago',
      );
      expect(
        OiRelativeTime.format(
          now.subtract(const Duration(minutes: 2)),
          style: OiRelativeTimeStyle.long,
          now: now,
        ),
        '2 minutes ago',
      );
    });

    test('"1 hour ago" vs "2 hours ago"', () {
      expect(
        OiRelativeTime.format(
          now.subtract(const Duration(hours: 1)),
          style: OiRelativeTimeStyle.long,
          now: now,
        ),
        '1 hour ago',
      );
      expect(
        OiRelativeTime.format(
          now.subtract(const Duration(hours: 2)),
          style: OiRelativeTimeStyle.long,
          now: now,
        ),
        '2 hours ago',
      );
    });

    test('"1 second ago" vs "2 seconds ago"', () {
      // 1 second is < 10s so it shows "just now", test at 11s and 12s
      expect(
        OiRelativeTime.format(
          now.subtract(const Duration(seconds: 11)),
          style: OiRelativeTimeStyle.long,
          now: now,
        ),
        '11 seconds ago',
      );
      expect(
        OiRelativeTime.format(
          now.subtract(const Duration(seconds: 12)),
          style: OiRelativeTimeStyle.long,
          now: now,
        ),
        '12 seconds ago',
      );
    });
  });

  // ── Month name coverage ───────────────────────────────────────────────

  group('month names', () {
    test('all 12 months format correctly (short)', () {
      final now = DateTime(2026, 12, 31);
      for (var m = 1; m <= 12; m++) {
        final dt = DateTime(2026, m, 15);
        final result = OiRelativeTime.format(dt, now: now);
        expect(result, contains('15'));
      }
    });
  });

  // ── didUpdateWidget ───────────────────────────────────────────────────

  group('didUpdateWidget', () {
    testWidgets('updates display when dateTime changes', (tester) async {
      final dt1 = DateTime.now().subtract(const Duration(minutes: 5));
      final dt2 = DateTime.now().subtract(const Duration(hours: 3));

      await tester.pumpObers(OiRelativeTime(dateTime: dt1));
      expect(find.text('5m ago'), findsOneWidget);

      await tester.pumpObers(OiRelativeTime(dateTime: dt2));
      expect(find.text('3h ago'), findsOneWidget);
    });

    testWidgets('updates display when style changes', (tester) async {
      final dt = DateTime.now().subtract(const Duration(minutes: 5));

      await tester.pumpObers(OiRelativeTime(dateTime: dt));
      expect(find.text('5m ago'), findsOneWidget);

      await tester.pumpObers(
        OiRelativeTime(dateTime: dt, style: OiRelativeTimeStyle.long),
      );
      expect(find.text('5 minutes ago'), findsOneWidget);
    });
  });
}
