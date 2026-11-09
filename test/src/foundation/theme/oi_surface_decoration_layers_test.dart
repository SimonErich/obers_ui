import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/paint_pixels.dart';

void main() {
  testWidgets(
    'capture independent sheet layers without altering base paint semantics',
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
        const white = BoxShadow(color: Color(0x0DFFFFFF), spreadRadius: 1);
        const black = BoxShadow(
          color: Color(0x66000000),
          offset: Offset(0, 1),
          blurRadius: .5 / .57735,
        );
        expect(black.blurSigma, 1);
        expect(black.toPaint().maskFilter, isNotNull);
        for (final entry in <String, Color>{
          'dark-calibration': const Color(0xFF131417),
          'source-sheet': const OiOklch(
            lightness: .192,
            chroma: .007,
            hue: 280,
          ).toColor(),
        }.entries) {
          for (final layer in [
            'background',
            'white',
            'black',
            'outer',
            'inset',
            'full',
          ]) {
            final shadows = switch (layer) {
              'white' => const [white],
              'black' => const [black],
              'outer' || 'full' => const [black, white],
              _ => const <BoxShadow>[],
            };
            final base = BoxDecoration(
              color: entry.value,
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              boxShadow: shadows.isEmpty ? null : shadows,
            );
            final decoration = layer == 'inset' || layer == 'full'
                ? OiSurfaceDecoration(
                    base: base,
                    insetShadows: [
                      OiInsetShadow(
                        color: const Color(0x0AFFFFFF),
                        offset: const Offset(0, 1),
                      ),
                    ],
                  )
                : base;
            final pixels = await tester.capturePaint(
              Center(
                child: SizedBox(
                  width: 100,
                  height: 64,
                  child: DecoratedBox(decoration: decoration),
                ),
              ),
              size: const Size(132, 96),
              evidencePath: output == null
                  ? null
                  : '$output/${entry.key}-$layer-margin.png',
            );
            expect(pixels.width, 132);
            expect(pixels.height, 96);
            expect(pixels.rgba(66, 48), [19, 20, 23, 255]);
            expect(
              pixels.rgba(66, 16),
              layer == 'inset' || layer == 'full'
                  ? [28, 29, 32, 255]
                  : [19, 20, 23, 255],
            );
          }
        }
      } finally {
        debugDisableShadows = previousDisableShadows;
      }
    },
  );
}
