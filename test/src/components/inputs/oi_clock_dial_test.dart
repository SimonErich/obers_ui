// Tests do not require documentation comments.

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const size = 240.0;

  Future<List<OiTimeOfDay>> pump(
    WidgetTester tester, {
    OiTimeOfDay? value,
  }) async {
    final picked = <OiTimeOfDay>[];
    await tester.pumpObers(
      Center(
        child: OiClockDial(value: value, onChanged: picked.add),
      ),
    );
    await tester.pumpAndSettle();
    return picked;
  }

  /// The point on the face at [angle] (0 at the top, clockwise) and
  /// [radius] from its centre.
  Offset at(WidgetTester tester, double angle, double radius) {
    final centre = tester.getCenter(
      find.descendant(
        of: find.byType(OiClockDial),
        matching: find.byType(CustomPaint),
      ),
    );
    return centre + Offset(math.sin(angle) * radius, -math.cos(angle) * radius);
  }

  testWidgets('starts at 9:00 on the hours face', (tester) async {
    await pump(tester);

    expect(find.text('09'), findsOneWidget);
    expect(find.text('00'), findsOneWidget);
  });

  testWidgets('tapping an outer hour turns the face to minutes', (
    tester,
  ) async {
    final picked = await pump(tester);

    await tester.tapAt(at(tester, math.pi / 2, size / 2 - 24)); // 3
    await tester.pumpAndSettle();

    expect(find.text('03'), findsOneWidget);
    expect(picked, isEmpty);
  });

  testWidgets('the inner ring is the afternoon, 00 at the top', (tester) async {
    await pump(tester);

    await tester.tapAt(at(tester, math.pi / 2, size / 2 - 64)); // 15
    await tester.pumpAndSettle();
    expect(find.text('15'), findsOneWidget);

    await tester.tap(find.text('15')); // back to hours
    await tester.pumpAndSettle();
    await tester.tapAt(at(tester, 0, size / 2 - 64)); // 00
    await tester.pumpAndSettle();
    expect(find.text('00'), findsNWidgets(2));
  });

  testWidgets('a tapped minute snaps to five and reports the time', (
    tester,
  ) async {
    final picked = await pump(
      tester,
      value: const OiTimeOfDay(hour: 14, minute: 0),
    );

    await tester.tapAt(at(tester, math.pi / 2, size / 2 - 24)); // 3 → minutes
    await tester.pumpAndSettle();
    await tester.tapAt(at(tester, math.pi + 0.1, size / 2 - 24)); // about :30
    await tester.pumpAndSettle();

    expect(picked, [const OiTimeOfDay(hour: 3, minute: 30)]);
  });

  testWidgets('dragging picks the exact minute', (tester) async {
    final picked = await pump(
      tester,
      value: const OiTimeOfDay(hour: 9, minute: 0),
    );

    await tester.tapAt(at(tester, 0, size / 2 - 24)); // 12 → minutes
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(at(tester, 0, size / 2 - 24));
    await gesture.moveTo(at(tester, 7 * 2 * math.pi / 60, size / 2 - 24));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(picked, [const OiTimeOfDay(hour: 12, minute: 7)]);
  });

  testWidgets('the readout switches faces', (tester) async {
    await pump(tester, value: const OiTimeOfDay(hour: 9, minute: 15));

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Minute'), findsWidgets);

    await tester.tap(find.text('09'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Hour'), findsWidgets);
  });
}
