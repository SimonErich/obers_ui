import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import 'oi_button_evidence_fixture.dart';

const _expected =
    '1745241685,2967681285,510390373,2967681285,671795285,3445526349,'
    '3064360397,3662389413,1286569917,3262033669,2823787093,332811557,'
    '2819490229,4119192901,2603291765,1148644885,1745241685,1068255861,'
    '3345902197,1904368037,3492642933,1620413237,2925938340,3185114117,'
    '1714697189,1679787669,1450271829,31150005,3766305461,1620413237,'
    '3385819045,191911429,2650843949,671795285,257981541,620661285,'
    '2204048421,474168421,3385819045,3040823301,1801913297,2550320709,'
    '772635941,1559626389,3203114453,11456661,3199582933,3040823301';

void main() {
  testWidgets('legacy button raster and geometry remain unchanged', (
    tester,
  ) async {
    final fingerprints = <String, int>{};
    Future<void> record(
      String id,
      Widget button, {
      OiThemeData? theme,
      OiDensity density = OiDensity.compact,
      TextDirection direction = TextDirection.ltr,
      OiInputModality modality = OiInputModality.pointer,
    }) async {
      final pixels = await captureButtonEvidence(
        tester,
        button,
        theme: theme,
        density: density,
        direction: direction,
        modality: modality,
      );
      fingerprints[id] = pixels.fingerprint;
      final bounds = tester.getRect(find.byKey(buttonEvidenceKey));
      debugPrint(
        jsonEncode({
          'legacy': id,
          'fnv1a32': pixels.fingerprint,
          'frame': [pixels.width, pixels.height],
          'bounds': [bounds.left, bounds.top, bounds.width, bounds.height],
        }),
      );
      expect(pixels.bytes.any((byte) => byte != 0), isTrue);
      expect(tester.takeException(), isNull);
    }

    for (final dark in [false, true]) {
      final theme = dark ? OiThemeData.dark() : OiThemeData.light();
      for (final variant in OiButtonVariant.values) {
        final button = switch (variant) {
          OiButtonVariant.primary => const OiButton.primary(
            key: buttonEvidenceKey,
            label: 'Action Hg',
          ),
          OiButtonVariant.secondary => const OiButton.secondary(
            key: buttonEvidenceKey,
            label: 'Action Hg',
          ),
          OiButtonVariant.outline => const OiButton.outline(
            key: buttonEvidenceKey,
            label: 'Action Hg',
          ),
          OiButtonVariant.ghost => const OiButton.ghost(
            key: buttonEvidenceKey,
            label: 'Action Hg',
          ),
          OiButtonVariant.destructive => const OiButton.destructive(
            key: buttonEvidenceKey,
            label: 'Action Hg',
          ),
          OiButtonVariant.soft => const OiButton.soft(
            key: buttonEvidenceKey,
            label: 'Action Hg',
          ),
        };
        await record(
          '${dark ? 'dark' : 'light'}-${variant.name}',
          button,
          theme: theme,
        );
      }
    }
    for (final density in OiDensity.values) {
      for (final size in OiButtonSize.values) {
        await record(
          'size-${density.name}-${size.name}',
          OiButton.primary(
            key: buttonEvidenceKey,
            label: 'Action Hg',
            size: size,
          ),
          density: density,
        );
      }
    }
    for (final size in OiButtonSize.values) {
      await record(
        'icon-${size.name}',
        OiButton.icon(
          key: buttonEvidenceKey,
          label: 'Add',
          icon: OiIcons.plus,
          size: size,
        ),
      );
      await record(
        'split-${size.name}',
        OiButton.split(
          key: buttonEvidenceKey,
          label: 'Action Hg',
          onTap: () {},
          dropdown: const SizedBox(),
          size: size,
        ),
      );
      await record(
        'countdown-${size.name}',
        OiButton.countdown(
          key: buttonEvidenceKey,
          label: 'Action Hg',
          onTap: () {},
          seconds: 1,
          size: size,
        ),
      );
      await record(
        'confirm-${size.name}',
        OiButton.confirm(
          key: buttonEvidenceKey,
          label: 'Action Hg',
          confirmLabel: 'Confirm Hg',
          onConfirm: () {},
          size: size,
        ),
      );
      for (final direction in TextDirection.values) {
        for (final position in OiIconPosition.values) {
          await record(
            'insets-${size.name}-${direction.name}-${position.name}',
            OiButton.secondary(
              key: buttonEvidenceKey,
              label: 'Action Hg',
              icon: OiIcons.plus,
              iconPosition: position,
              size: size,
            ),
            direction: direction,
          );
        }
      }
      await record(
        'touch-icon-${size.name}',
        OiButton.icon(
          key: buttonEvidenceKey,
          label: 'Add',
          icon: OiIcons.plus,
          size: size,
        ),
        modality: OiInputModality.touch,
      );
    }
    await tester.pumpWidget(const SizedBox());
    expect(
      fingerprints.values.toList(),
      _expected.split(',').map(int.parse).toList(),
    );
  });
}
