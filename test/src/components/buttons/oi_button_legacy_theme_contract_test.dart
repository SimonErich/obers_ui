import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import 'oi_button_evidence_fixture.dart';

OiButtonVariantStyle _variant(List<Color?> colors) => OiButtonVariantStyle(
  background: colors[0],
  backgroundHover: colors[1],
  backgroundPressed: colors[2],
  backgroundDisabled: colors[3],
  foreground: colors[4],
  foregroundHover: colors[5],
  foregroundPressed: colors[6],
  foregroundDisabled: colors[7],
  border: colors[8],
  borderHover: colors[9],
  borderPressed: colors[10],
  borderDisabled: colors[11],
);

List<Color?> _fields(OiButtonVariantStyle style) => [
  style.background,
  style.backgroundHover,
  style.backgroundPressed,
  style.backgroundDisabled,
  style.foreground,
  style.foregroundHover,
  style.foregroundPressed,
  style.foregroundDisabled,
  style.border,
  style.borderHover,
  style.borderPressed,
  style.borderDisabled,
];

void main() {
  test(
    'variant defaults are null and all twelve state colors are retained',
    () {
      expect(_fields(const OiButtonVariantStyle()), everyElement(isNull));
      final colors = List<Color>.generate(
        12,
        (index) => Color(0xff000100 + index),
      );
      expect(_fields(_variant(colors)), orderedEquals(colors));
    },
  );

  test('variant equality and keyed lookup depend on every state color', () {
    final colors = List<Color>.generate(
      12,
      (index) => Color(0xff000100 + index),
    );
    final left = _variant(colors);
    final equivalent = _variant([
      for (final color in colors) Color(color.toARGB32()),
    ]);
    final sameInstance = left;
    expect(identical(left, equivalent), isFalse);
    expect(left == sameInstance, isTrue);
    expect(left == Object(), isFalse);
    expect(left == equivalent, isTrue);
    expect(equivalent == left, isTrue);
    expect(left.hashCode, equivalent.hashCode);
    final values = <OiButtonVariantStyle, String>{left: 'authored colors'};
    expect(values[equivalent], 'authored colors');
    for (var index = 0; index < colors.length; index++) {
      final changed = <Color?>[...colors]..[index] = null;
      final different = _variant(changed);
      expect(left == different, isFalse, reason: 'nullable state field $index');
      expect(different == left, isFalse, reason: 'symmetry at field $index');
      expect(values[different], isNull);
    }
    final empty = _variant(List<Color?>.filled(12, null));
    expect(empty == const OiButtonVariantStyle(), isTrue);
    expect(empty.hashCode, const OiButtonVariantStyle().hashCode);
  });

  testWidgets('legacy global scale sets actual size-specific label metrics', (
    tester,
  ) async {
    const fonts = [13.0, 15.0, 17.0];
    const weights = [FontWeight.w300, FontWeight.w600, FontWeight.w800];
    const heights = [24.0, 32.0, 40.0];
    final base = OiThemeData.light();
    final theme = base.copyWith(
      components: base.components.copyWith(
        button: const OiButtonThemeData(
          textStyle: TextStyle(fontFamily: 'Ahem'),
          fontSizes: OiButtonFontSizeScale(
            small: 13,
            medium: 15,
            large: 17,
            weightSmall: FontWeight.w300,
            weightMedium: FontWeight.w600,
            weightLarge: FontWeight.w800,
          ),
          primaryStyle: OiButtonVariantStyle(foreground: Color(0xff125634)),
        ),
      ),
    );
    for (final size in OiButtonSize.values) {
      var taps = 0;
      await captureButtonEvidence(
        tester,
        OiButton.primary(
          key: buttonEvidenceKey,
          label: 'Scale Hg',
          size: size,
          onTap: () => taps++,
        ),
        theme: theme,
      );
      final paragraph = buttonEvidenceParagraph(tester, 'Scale Hg');
      final style = paragraph.text.style!;
      final bounds = tester.getRect(find.byKey(buttonEvidenceKey));
      expect(style.fontSize, fonts[size.index]);
      expect(style.fontWeight, weights[size.index]);
      expect(style.height, 1);
      expect(style.color, const Color(0xff125634));
      expect(paragraph.size.height, fonts[size.index]);
      expect(bounds.height, heights[size.index]);
      expect(bounds.width, greaterThan(paragraph.size.width));
      await tester.tapAt(bounds.center);
      await tester.pump();
      expect(taps, 1);
      expect(tester.getRect(find.byKey(buttonEvidenceKey)), bounds);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('runtime destructive and soft variants keep bounds and actions', (
    tester,
  ) async {
    final theme = OiThemeData.light();
    for (final destructive in [true, false]) {
      for (final size in OiButtonSize.values) {
        var taps = 0;
        final button = destructive
            ? OiButton.destructive(
                key: buttonEvidenceKey,
                label: 'Act',
                size: size,
                onTap: () => taps++,
              )
            : OiButton.soft(
                key: buttonEvidenceKey,
                label: 'Act',
                size: size,
                onTap: () => taps++,
              );
        await captureButtonEvidence(tester, button, theme: theme);
        final bounds = tester.getRect(find.byKey(buttonEvidenceKey));
        final paragraph = buttonEvidenceParagraph(tester, 'Act');
        expect(bounds.height, [24.0, 32.0, 40.0][size.index]);
        expect(bounds.width, greaterThan(paragraph.size.width));
        expect(
          paragraph.text.style!.color,
          destructive
              ? theme.colors.error.foreground
              : theme.colors.primary.base,
        );
        await tester.tapAt(bounds.center);
        await tester.pump();
        expect(taps, 1);
        expect(tester.getRect(find.byKey(buttonEvidenceKey)), bounds);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
