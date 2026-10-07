import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/paint_pixels.dart';

void main() {
  testWidgets(
    'independent Chrome sharp/border references and source sheet captures',
    (tester) async {
      final output = Platform.environment['OI_F4A_PAINT_OUTPUT'];
      if (output != null && !output.startsWith('/')) {
        throw ArgumentError(
          'Paint evidence output must be an explicit absolute path.',
        );
      }
      final previousDisableShadows = debugDisableShadows;
      debugDisableShadows = false;
      try {
        expect(debugDisableShadows, isFalse);
        const black = BoxShadow(
          color: Color(0x66000000),
          offset: Offset(0, 1),
          blurRadius: .5 / .57735,
        );
        expect(black.blurSigma, 1);
        expect(black.toPaint().maskFilter, isNotNull);
        final cases = <String, BoxDecoration>{
          'sharp': const BoxDecoration(color: Color(0xFF000000)),
          'border': const BoxDecoration(
            color: Color(0xFF000000),
            border: Border.fromBorderSide(
              BorderSide(color: Color(0xFFFF0000), width: 2),
            ),
          ),
          'dark-calibration': const BoxDecoration(
            color: Color(0xFF131417),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          'source-sheet': BoxDecoration(
            color: const OiOklch(
              lightness: .192,
              chroma: .007,
              hue: 280,
            ).toColor(),
            borderRadius: const BorderRadius.all(Radius.circular(14)),
          ),
        };
        for (final entry in cases.entries) {
          final sheet =
              entry.key.endsWith('calibration') || entry.key == 'source-sheet';
          final base = sheet
              ? entry.value.copyWith(
                  boxShadow: const [
                    // App-owned CSS list adaptation: Flutter paints later outers on top.
                    BoxShadow(
                      color: Color(0x66000000),
                      offset: Offset(0, 1),
                      blurRadius: .5 / .57735,
                    ),
                    BoxShadow(color: Color(0x0DFFFFFF), spreadRadius: 1),
                  ],
                )
              : entry.value;
          final actual = await tester.capturePaint(
            DecoratedBox(
              decoration: OiSurfaceDecoration(
                base: base,
                insetShadows: [
                  OiInsetShadow(
                    color: sheet
                        ? const Color(0x0AFFFFFF)
                        : const Color(0xFFFFFFFF),
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            size: const Size(100, 64),
            evidencePath: output == null ? null : '$output/${entry.key}.png',
          );
          expect(actual.width, 100);
          expect(actual.height, 64);
          if (!sheet) {
            final expected = (await tester.runAsync(
              () =>
                  PaintPixels.readPng('test/assets/paint/f4a/${entry.key}.png'),
            ))!;
            expect(
              actual.bytes,
              expected.bytes,
              reason: 'Every straight RGBA channel, no mask/tolerance.',
            );
          } else {
            // This is capture calibration, NOT rounded Chrome parity acceptance.
            // The parent's unchanged strict tool compares every edge/alpha pixel.
            expect(actual.rgba(50, 32), [19, 20, 23, 255]);
            expect(actual.rgba(50, 0), [28, 29, 32, 255]);
          }
        }
      } finally {
        debugDisableShadows = previousDisableShadows;
      }
    },
  );
}
