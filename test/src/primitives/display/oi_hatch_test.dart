import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/paint_pixels.dart';

void main() {
  for (final pitch in [1e12, 1e100, 1e308]) {
    for (final (phase, width) in [(-1.0, 1.0), (-1.0, 2.0), (-2.0, 1.0)]) {
      testWidgets('negative phase $phase width $width at finite pitch $pitch', (
        tester,
      ) async {
        final actual = await tester.capturePaint(
          OiHatch(
            stripeColor: const Color(0xff1c2538),
            pitch: pitch,
            stripeWidth: width,
            phase: phase,
          ),
          size: const Size(8, 8),
        );
        // Every pixel center is away from the hard edge of these local bands.
        for (var y = 0; y < 8; y++) {
          for (var x = 0; x < 8; x++) {
            final coordinate = (x + y + 1) / math.sqrt2;
            final inBand = coordinate >= phase && coordinate < phase + width;
            expect(
              actual.rgba(x, y),
              inBand ? [28, 37, 56, 255] : [0, 0, 0, 0],
              reason:
                  '($x,$y) coordinate=$coordinate, band[$phase,${phase + width})',
            );
          }
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final pitch in [1e12, 1e18, 1e40, 1e100, 1.7976931348623157e308]) {
    for (final phaseFraction in [0.0, 0.25, 0.75]) {
      testWidgets(
        'finite pitch $pitch phase $phaseFraction keeps its local bands',
        (tester) async {
          const ink = Color(0xff1c2538);
          final actual = await tester.capturePaint(
            OiHatch(
              stripeColor: ink,
              pitch: pitch,
              stripeWidth: pitch / 2,
              phase: pitch * phaseFraction,
            ),
            size: const Size(32, 32),
          );
          // At t=(x+y)/sqrt2 in this32px box, q0 is in the current band,
          // q.75 is in the previous band, and q.25 is in the transparent gap.
          final expected = await tester.capturePaint(
            ColoredBox(
              color: phaseFraction == 0.25 ? const Color(0x00000000) : ink,
            ),
            size: const Size(32, 32),
          );
          expect(actual.bytes, orderedEquals(expected.bytes));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'subpixel finite stripes cannot introduce unauthored opaque alpha',
    (tester) async {
      for (final pitch in [1e-100, 1e-300, 5e-323]) {
        final pixels = await tester.capturePaint(
          OiHatch(
            stripeColor: const Color.fromRGBO(19, 20, 23, 0.28),
            pitch: pitch,
            stripeWidth: pitch / 2,
          ),
          size: const Size(32, 32),
        );
        for (var i = 3; i < pixels.bytes.length; i += 4) {
          expect(pixels.bytes[i], lessThanOrEqualTo(72));
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  final reference =
      jsonDecode(
            File(
              'test/goldens/primitives/oi_hatch/reference.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  for (final item in reference['rows'] as List<dynamic>) {
    final row = item as Map<String, dynamic>;
    testWidgets('matches all browser pixels: ${row['fixture']}', (
      tester,
    ) async {
      final opaque = row['mode'] == 'opaque';
      final pixels = await tester.capturePaint(
        OiHatch(
          stripeColor: opaque
              ? const Color(0xff191a1f)
              : const Color.fromRGBO(19, 20, 23, 0.28),
          backgroundColor: opaque
              ? const Color(0xfff8f7f3)
              : const Color(0x00000000),
          pitch: (row['pitch'] as num).toDouble(),
          phase: (row['phase'] as num).toDouble(),
        ),
        size: const Size(80, 24),
      );
      final expected = (await tester.runAsync(
        () => PaintPixels.readPng(
          'test/goldens/primitives/oi_hatch/${row['filename']}',
        ),
      ))!;
      expect([pixels.width, pixels.height], [80, 24]);
      expect(pixels.bytes, orderedEquals(expected.bytes));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('local-span rendering preserves every top-left reference pixel', (
    tester,
  ) async {
    for (final item in reference['rows'] as List<dynamic>) {
      final row = item as Map<String, dynamic>;
      final opaque = row['mode'] == 'opaque';
      final actual = await tester.capturePaint(
        OiHatch(
          stripeColor: opaque
              ? const Color(0xff191a1f)
              : const Color.fromRGBO(19, 20, 23, 0.28),
          backgroundColor: opaque
              ? const Color(0xfff8f7f3)
              : const Color(0x00000000),
          pitch: (row['pitch'] as num).toDouble(),
          phase: (row['phase'] as num).toDouble(),
        ),
        size: const Size(2, 1),
      );
      final referencePixels = (await tester.runAsync(
        () => PaintPixels.readPng(
          'test/goldens/primitives/oi_hatch/${row['filename']}',
        ),
      ))!;
      expect(actual.bytes, orderedEquals(referencePixels.bytes.sublist(0, 8)));
      expect(tester.takeException(), isNull);
    }
  });

  test('hatch validates finite geometry before rendering', () {
    OiHatch hatch({double pitch = 5, double width = 1, double phase = 0}) =>
        OiHatch(
          stripeColor: const Color(0xff191a1f),
          pitch: pitch,
          stripeWidth: width,
          phase: phase,
        );
    for (final pitch in [
      0.0,
      -1.0,
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(() => hatch(pitch: pitch), throwsArgumentError);
    }
    for (final width in [
      -1.0,
      6.0,
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(() => hatch(width: width), throwsArgumentError);
    }
    for (final phase in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(() => hatch(phase: phase), throwsArgumentError);
    }
    expect(hatch(width: 0).stripeWidth, 0);
    expect(hatch(width: 5, phase: -0.5).phase, -0.5);
  });

  testWidgets('stripe phase is periodic and preserves explicit paint colors', (
    tester,
  ) async {
    Future<PaintPixels> capture(double phase) => tester.capturePaint(
      OiHatch(
        stripeColor: const Color(0xff191a1f),
        backgroundColor: const Color(0xfff8f7f3),
        phase: phase,
      ),
      size: const Size(80, 24),
    );
    final initial = await capture(0);
    final complete = await capture(5);
    final negative = await capture(-0.5);
    final wrapped = await capture(4.5);
    expect(complete.bytes, orderedEquals(initial.bytes));
    expect(wrapped.bytes, orderedEquals(negative.bytes));
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero/full width retain exact authored color and alpha', (
    tester,
  ) async {
    const ink = Color.fromRGBO(19, 20, 23, 0.28);
    const background = Color.fromRGBO(71, 113, 151, 0.7);
    final empty = await tester.capturePaint(
      OiHatch(stripeColor: ink, backgroundColor: background, stripeWidth: 0),
      size: const Size(40, 20),
    );
    final backgroundOnly = await tester.capturePaint(
      const ColoredBox(color: background),
      size: const Size(40, 20),
    );
    expect(empty.bytes, orderedEquals(backgroundOnly.bytes));
    final solid = await tester.capturePaint(
      OiHatch(stripeColor: ink, stripeWidth: 5, phase: -0.375),
      size: const Size(40, 20),
    );
    final stripeOnly = await tester.capturePaint(
      const ColoredBox(color: ink),
      size: const Size(40, 20),
    );
    expect(solid.bytes, orderedEquals(stripeOnly.bytes));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'hatch paint stays inside its box, child clipping stays caller-owned',
    (tester) async {
      Widget box({Widget? child}) => Center(
        child: SizedBox(
          width: 40,
          height: 20,
          child: OiHatch(
            stripeColor: const Color(0xff191a1f),
            backgroundColor: const Color(0xfff8f7f3),
            child: child,
          ),
        ),
      );
      final clipped = await tester.capturePaint(
        box(),
        size: const Size(80, 40),
      );
      for (var y = 0; y < 40; y++) {
        for (var x = 0; x < 80; x++) {
          if (x < 20 || x >= 60 || y < 10 || y >= 30) {
            expect(clipped.rgba(x, y), [0, 0, 0, 0]);
          } else {
            expect(clipped.rgba(x, y).last, 255);
          }
        }
      }
      final child = await tester.capturePaint(
        box(
          child: const OverflowBox(
            minWidth: 60,
            maxWidth: 60,
            minHeight: 30,
            maxHeight: 30,
            child: ColoredBox(color: Color(0xff00ff00)),
          ),
        ),
        size: const Size(80, 40),
      );
      expect(child.rgba(10, 5), [0, 255, 0, 255]);
      expect(child.rgba(69, 34), [0, 255, 0, 255]);
      expect(child.rgba(9, 4), [0, 0, 0, 0]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'decorative paint passes pointers through, child stays interactive',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var underlayTaps = 0;
      var childTaps = 0;
      Widget frame({Widget? child}) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => underlayTaps++,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned.fill(
            child: OiHatch(stripeColor: const Color(0xff191a1f), child: child),
          ),
        ],
      );
      try {
        await tester.capturePaint(frame(), size: const Size(80, 40));
        await tester.tapAt(tester.getCenter(find.byType(OiHatch)));
        await tester.pump();
        expect(underlayTaps, 1);
        await tester.capturePaint(
          frame(
            child: Semantics(
              label: 'Authored hatch child',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => childTaps++,
                child: const SizedBox.expand(),
              ),
            ),
          ),
          size: const Size(80, 40),
        );
        expect(find.bySemanticsLabel('Authored hatch child'), findsOneWidget);
        await tester.tapAt(tester.getCenter(find.byType(OiHatch)));
        await tester.pump();
        expect(childTaps, 1);
        expect(underlayTaps, 1);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('zero-size constrained paint remains valid and static', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox.shrink(
            child: OiHatch(stripeColor: const Color(0xff191a1f)),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(OiHatch)), Size.zero);
    await tester.pump(const Duration(days: 1));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });
}
